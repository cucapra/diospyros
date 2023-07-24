#include <assert.h>
#include <stdint.h>

#include <exception>
#include <string>
#include <vector>

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/MemoryBuiltins.h"
#include "llvm/Analysis/MemoryLocation.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Value.h"
#include "llvm/Support/Casting.h"

using namespace llvm;

namespace VectorConstants {
const std::string GATHER_NAME = "llvm.masked.gather.v4f32.v4p0f32";
const uint32_t VECTOR_WIDTH = 4;
}  // namespace VectorConstants

namespace Array {
// get all "Base" Arrays on which vectorization can occur. These are
// defined as argument inputs with a pointer type
std::vector<Value *> get_array_bases(Function &F, TargetLibraryInfo *TLI) {
    std::vector<Value *> base_of_array_vec = {};
    for (auto &a : F.args()) {
        if (a.getType()->isPointerTy()) {
            if (Value *arg_val = dyn_cast<Value>(&a)) {
                base_of_array_vec.push_back(arg_val);
            }
        }
    }
    for (auto &B : F) {
        for (auto &I : B) {
            if (Value *V = dyn_cast<Value>(&I)) {
                if (isMallocOrCallocLikeFn(V, TLI)) {
                    base_of_array_vec.push_back(V);
                }
            }
        }
    }
    return base_of_array_vec;
}

/**
 * return the index to in baseOfArrayVec that store is an offset from, or
 * NULLOPT if not matching
 */
std::pair<int, int> get_base_reference(Value *mem_instr_ptr,
                                       std::vector<Value *> base_of_array_vec,
                                       ScalarEvolution *SE) {
    for (int i = 0; i < base_of_array_vec.size(); i++) {
        Value *base_array_ptr = base_of_array_vec[i];
        assert(base_array_ptr->getType()->isPointerTy());
        const SCEV *mem_instr_ptr_se = SE->getSCEV(mem_instr_ptr);
        const SCEV *base_ptr_se = SE->getSCEV(base_array_ptr);
        const SCEV *diff = SE->getMinusSCEV(mem_instr_ptr_se, base_ptr_se);
        APInt min_val = SE->getSignedRangeMin(diff);
        APInt max_val = SE->getSignedRangeMax(diff);
        if (min_val == max_val) {
            int val = (int)max_val.roundToDouble();
            return {i, val};
        }
    }
    return {-1, -1};
}
}  // namespace Array

namespace Alias {
bool may_alias(Value *addr1, Value *addr2, AliasAnalysis *AA) {
    // Both isNoALias and isMustAlias have to be checked for unknown reasons
    return (!AA->isNoAlias(addr1,
                           LocationSize::precise(
                               addr1->getType()->getPrimitiveSizeInBits()),
                           addr2,
                           LocationSize::precise(
                               addr2->getType()->getPrimitiveSizeInBits())) ||
            AA->isMustAlias(addr1, addr2));
}
}  // namespace Alias

namespace Gather {
bool isa_gather_instruction(Instruction *instr) {
    if (CallInst *call_instr = dyn_cast<CallInst>(instr)) {
        Function *fun = call_instr->getCalledFunction();
        // Source:
        // https://stackoverflow.com/questions/11686951/how-can-i-get-function-name-from-callinst-in-llvm
        // Fun Could be NULL, in which case indirect call occurs, i cannot
        // get name.
        if (fun) {
            if (fun->getName() == VectorConstants::GATHER_NAME) {
                return true;
            }
        }
    }
    return false;
}

std::vector<Value *> get_gather_addresses(Instruction *call_to_gather) {
    assert(isa_gather_instruction(call_to_gather));

    Instruction *insert_element_instr =
        dyn_cast<Instruction>(call_to_gather->getOperand(0));
    if (insert_element_instr == NULL) {
        throw "Gather Arguments Pointer Vector was NULL";
    }

    std::vector<Value *> gather_addresses = {};
    // hardcode to gathers of length 4 only
    for (int i = 0; i < VectorConstants::VECTOR_WIDTH; i++) {
        Value *pointer = insert_element_instr->getOperand(1);
        gather_addresses.push_back(pointer);
        Instruction *new_insert_element_instr =
            dyn_cast<Instruction>(insert_element_instr->getOperand(0));
        insert_element_instr = new_insert_element_instr;
    }
    return gather_addresses;
}

}  // namespace Gather

namespace Chunking {
using chunk_t = std::vector<Instruction *>;
using chunks_t = std::vector<std::vector<Instruction *>>;

/**
 * True iff an instruction is a mem intrinsic.
 */
bool isa_mem_intrinsic(Instruction *instr) {
    if (isa<MemSetInst>(instr)) {
        return true;
    } else if (isa<MemCpyInst>(instr)) {
        return true;
    } else if (isa<MemMoveInst>(instr)) {
        return true;
    } else if (isa<MemIntrinsic>(instr)) {
        return true;
    }
    return false;
}

/**
 * True iff is a special type of instruction for chunking
 *
 */
bool isa_special_chunk_instr(Instruction *instr) {
    return isa_mem_intrinsic(instr) || isa<AllocaInst>(instr) ||
           isa<PHINode>(instr) ||
           (isa<CallInst>(instr) && !Gather::isa_gather_instruction(instr));
}

/*
Build chunks of instructions

A chunk is the longest contiguous section of instructions that ends in a
sequence of stores.

A chunk does not need to contain a store instruction.

Assumes: LoadStoreMovement pass is run before the Diospyros pass
**/
std::vector<std::vector<Instruction *>> build_chunks(BasicBlock *B,
                                                     AliasAnalysis *AA) {
    std::vector<std::vector<Instruction *>> chunks = {};

    bool has_seen_store = false;
    bool stores_alias_in_chunk = false;
    std::vector<Instruction *> curr_chunk = {};

    // Track Last Stores seen
    std::vector<Instruction *> last_stores = {};
    for (auto &I : *B) {
        // the first two cases are meant to create chunks with non-handled
        // instructions
        if (has_seen_store && isa_special_chunk_instr(&I)) {
            if (curr_chunk.size() > 0 && !stores_alias_in_chunk) {
                chunks.push_back(curr_chunk);
            }
            has_seen_store = false;
            stores_alias_in_chunk = false;
            curr_chunk = {};
            last_stores = {};
            curr_chunk.push_back(&I);
            chunks.push_back(curr_chunk);
            curr_chunk = {};
        } else if (!has_seen_store && isa_special_chunk_instr(&I)) {
            if (curr_chunk.size() > 0 && !stores_alias_in_chunk) {
                chunks.push_back(curr_chunk);
            }
            has_seen_store = false;
            stores_alias_in_chunk = false;
            curr_chunk = {};
            last_stores = {};
            curr_chunk.push_back(&I);
            chunks.push_back(curr_chunk);
            curr_chunk = {};
        } else if (!has_seen_store && isa<StoreInst>(I) &&
                   !isa_special_chunk_instr(&I)) {
            has_seen_store = true;
            curr_chunk.push_back(&I);
            last_stores.push_back(&I);
        } else if (!has_seen_store && !isa<StoreInst>(I) &&
                   !isa_special_chunk_instr(&I)) {
            curr_chunk.push_back(&I);
        } else if (has_seen_store && !isa<StoreInst>(I) &&
                   !isa_special_chunk_instr(&I)) {
            if (curr_chunk.size() > 0 && !stores_alias_in_chunk) {
                chunks.push_back(curr_chunk);
            }
            has_seen_store = false;
            stores_alias_in_chunk = false;
            curr_chunk = {};
            last_stores = {};
            curr_chunk.push_back(&I);
        } else {  // has seen store and is a store instruction
            Value *curr_store_addr = I.getOperand(1);
            for (auto other_store : last_stores) {
                if (other_store != &I) {
                    Value *other_store_addr = other_store->getOperand(1);
                    if (Alias::may_alias(curr_store_addr, other_store_addr,
                                         AA)) {
                        stores_alias_in_chunk = true;
                    }
                }
            }
            curr_chunk.push_back(&I);
            last_stores.push_back(&I);
        }
    }
    if (curr_chunk.size() > 0 && !stores_alias_in_chunk) {
        chunks.push_back(curr_chunk);
    }

    // Filter to make sure no chunks are empty
    chunks_t final_chunks = {};
    for (auto chunk : chunks) {
        if (!chunk.empty()) {
            final_chunks.push_back(chunk);
        }
    }

    return final_chunks;
}
}  // namespace Chunking