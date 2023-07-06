#include <assert.h>
#include <llvm-c/Core.h>

#include <algorithm>
#include <cstdint>
#include <optional>
#include <set>
#include <stdexcept>
#include <string>
#include <tuple>
#include <vector>

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/LoopAccessAnalysis.h"
#include "llvm/Analysis/MemoryBuiltins.h"
#include "llvm/Analysis/MemoryLocation.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/User.h"
#include "llvm/Pass.h"
#include "llvm/Support/Alignment.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar/LoopUnrollPass.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Vectorize/SLPVectorizer.h"

using namespace llvm;

int main(int argc, char **argv) {
    llvm::cl::ParseCommandLineOptions(argc, argv);
}

llvm::cl::opt<bool> RunOpt("r", llvm::cl::desc("Enable Egg Optimization."));
llvm::cl::alias RunOptAlias("opt", llvm::cl::desc("Alias for -r"),
                            llvm::cl::aliasopt(RunOpt));

llvm::cl::opt<bool> PrintOpt("z", llvm::cl::desc("Print Egg Optimization."));
llvm::cl::alias PrintOptAlias("print", llvm::cl::desc("Alias for -z"),
                              llvm::cl::aliasopt(PrintOpt));

/// Struct representing load info, same as on Rust side
typedef struct load_info {
    LLVMValueRef load;
    int32_t base_id;
    int32_t offset;
} load_info_t;

/// Forward Declaration of Optimize function
extern "C" bool optimize(
    LLVMModuleRef mod, LLVMContextRef context, LLVMBuilderRef builder,
    LLVMValueRef const *chunk_instrs, std::size_t chunk_size,
    LLVMValueRef const *restricted_instrs, std::size_t restricted_size,
    load_info_t const *load_info, std::size_t load_info_size, bool run_egg,
    bool print_opt);

const std::string ARRAY_NAME = "no-array-name";
const std::string TEMP_NAME = "no-temp-name";
const std::string SQRT64_FUNCTION_NAME = "llvm.sqrt.f64";
const std::string SQRT32_FUNCTION_NAME = "llvm.sqrt.f32";
const std::string MEMSET_PREFIX = "memset";
const std::string LLVM_MEMSET_PREFIX = "llvm.memset";
const std::string MEMMOVE_PREFIX = "memmove";
const std::string MEMCOPY_PREFIX = "memcopy";
const std::string MAIN_FUNCTION_NAME = "main";
const std::string NO_OPT_PREFIX = "no_opt_";
const int SQRT_OPERATOR = 3;
const int BINARY_OPERATOR = 2;

const uint32_t VECTOR_WIDTH = 4;
const uint32_t FLOAT_SIZE_IN_BYTES = 4;

/**
 * Fresh counters for temps and array generation
 */
static int FRESH_INT_COUNTER = 0;
static int FRESH_ARRAY_COUNTER = 0;
static int FRESH_TEMP_COUNTER = 0;

/**
 * Generates a Fresh Index
 */
int gen_fresh_index() {
    --FRESH_INT_COUNTER;
    return FRESH_INT_COUNTER;
}

/**
 * Generates a fresh name for an array name
 */
const char *gen_fresh_array() {
    ++FRESH_ARRAY_COUNTER;
    std::string array_str = ARRAY_NAME + std::to_string(FRESH_ARRAY_COUNTER);
    char *cstr = new char[array_str.length() + 1];
    std::strcpy(cstr, array_str.c_str());
    return cstr;
}

/**
 * Generates a fresh name for a temporary variable that was taken from LLVM
 */
const char *gen_fresh_temp() {
    ++FRESH_TEMP_COUNTER;
    std::string temp_str = TEMP_NAME + std::to_string(FRESH_TEMP_COUNTER);
    char *cstr = new char[temp_str.length() + 1];
    std::strcpy(cstr, temp_str.c_str());
    return cstr;
}

/* The following are convenience functions used on the Rust library code. The
reason is that the functionality does not exist in the LLVM-C interface for
Rust, so we must use the C++ LLVM interface to provide the Rust functionality.
*/

/**
 * Finds name of an LLVM Array, if there is one. Otherwise, generates fresh name
 * for array.
 */
extern "C" const char *llvm_name(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *gep = dyn_cast<GEPOperator>(v)) {
        auto name = gep->getOperand(0)->getName();
        if (name.empty()) {
            return gen_fresh_array();
        }
        return name.data();
    } else if (auto *load = dyn_cast<LoadInst>(v)) {
        auto name = load->getOperand(0)->getName();
        if (name.empty()) {
            return gen_fresh_temp();
        }
        return name.data();
    }
    return gen_fresh_array();
}

/**
 * Finds name of an LLVM Array, if there is one. Otherwise, generates fresh name
 * for array.
 */
extern "C" int llvm_index(LLVMValueRef val, int index) {
    Value *v = unwrap(val);
    if (auto *num = dyn_cast<GEPOperator>(v)) {
        if (auto *i = dyn_cast<ConstantInt>(num->getOperand(index))) {
            return i->getSExtValue();
        }
    }
    return gen_fresh_index();
}

/**
 * Generates an LLVM Opaque Pointer Type wrapped as an LLVMType Ref
 */
extern "C" LLVMTypeRef generate_opaque_pointer(LLVMTypeRef element_type) {
    return wrap(PointerType::getUnqual(unwrap(element_type)));
}

/**
 * True iff a value is an LLVM Unary Operation
 */
extern "C" bool isa_unop(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<UnaryOperator>(unwrapped);
}

/**
 * True iff a value is an LLVM Binary Operation
 */
extern "C" bool isa_bop(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<BinaryOperator>(unwrapped);
}

/**
 * True iff a value is an LLVM constant/LLVMValueRef Constant
 */
extern "C" bool isa_constant(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<Constant>(unwrapped);
}

/**
 * True iff a value is an LLVM GEP/LLVMValueRef GEP
 */
extern "C" bool isa_gep(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<GEPOperator>(unwrapped);
}

/**
 * True iff a value is an LLVM Load/LLVMValueRef Load
 */
extern "C" bool isa_load(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<LoadInst>(unwrapped);
}

/**
 * True iff a value is an LLVM Store/LLVMValueRef Store
 */
extern "C" bool isa_store(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<StoreInst>(unwrapped);
}

/**
 * True iff a value is an LLVM Argument/LLVMValueRef Argument
 */
extern "C" bool isa_argument(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<Argument>(unwrapped);
}

/**
 * True iff a value is an LLVM CallInst/LLVMValueRef CallInst
 */
extern "C" bool isa_call(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<CallInst>(unwrapped);
}

/**
 * True iff a value is an LLVM FPTruncInst/LLVMValueRef FPTruncInst
 */
extern "C" bool isa_fptrunc(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<FPTruncInst>(unwrapped);
}

/**
 * True iff a value is an LLVM FPExtInst/LLVMValueRef FPExtInst
 */
extern "C" bool isa_fpext(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<FPExtInst>(unwrapped);
}

/**
 * True iff a value is an LLVM AllocInst/LLVMValueRef AllocInst
 */
extern "C" bool isa_alloca(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<AllocaInst>(unwrapped);
}

/**
 * True iff a value is an LLVM SExtInst/LLVMValueRef SExtInst
 */
extern "C" bool isa_sextint(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<SExtInst>(unwrapped);
}

/**
 * True iff a value is an LLVM PHINode/LLVMValueRef PHINode
 */
extern "C" bool isa_phi(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<PHINode>(unwrapped);
}

/**
 * True iff a value is an LLVM 	SIToFPInst/LLVMValueRef 	SIToFPInst
 */
extern "C" bool isa_sitofp(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<SIToFPInst>(unwrapped);
}

/**
 * True iff a value is an LLVM Int/LLVMValueRef 	Int
 */
extern "C" bool isa_integertype(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return unwrapped->getType()->isIntegerTy();
}

/**
 * True iff a value is an LLVM IntPTr/LLVMValueRef IntPtr
 */
extern "C" bool isa_intptr(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    Type *t = unwrapped->getType();
    return t->isPointerTy() && t->getContainedType(0)->isIntegerTy();
}

/**
 * True iff a value is an LLVM FloatPtr/LLVMValueRef FloatPtr
 */
extern "C" bool isa_floatptr(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    Type *t = unwrapped->getType();
    return t->isPointerTy() && t->getContainedType(0)->isFloatTy();
}

/**
 * True iff a value is an LLVM Float/LLVMValueRef Float
 */
extern "C" bool isa_floattype(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return unwrapped->getType()->isFloatTy();
}

/**
 * True iff a value is an LLVM 	ConstantAggregateZero/LLVMValueRef
 * ConstantAggregateZero
 */
extern "C" bool isa_constaggregatezero(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<ConstantAggregateZero>(unwrapped);
}

/**
 * True iff a value is an LLVM ConstFP/LLVMValueRef
 * ConstFP
 */
extern "C" bool isa_constfp(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<ConstantFP>(unwrapped);
}

/**
 * True iff a value is an LLVM 	ConstantAggregate/LLVMValueRef
 * ConstantAggregate
 */
extern "C" bool isa_constaggregate(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<ConstantAggregate>(unwrapped);
}

/**
 * True iff a value is an LLVM 	bitcast/LLVMValueRef
 * bitcast
 */
extern "C" bool isa_bitcast(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<BitCastInst>(unwrapped);
}

/**
 * True iff a value is an LLVM 	SQRT F32/LLVMValueRef
 * SQRT F32
 */
extern "C" bool isa_sqrt32(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    if (auto *op = dyn_cast<CallInst>(unwrapped)) {
        return op->getCalledFunction()->getName() == SQRT32_FUNCTION_NAME;
    }
    // it is not a square root nor a call
    return false;
}

/**
 * True iff a value is an LLVM 	SQRT F64/LLVMValueRef
 * SQRT F64
 */
extern "C" bool isa_sqrt64(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    if (auto *op = dyn_cast<CallInst>(unwrapped)) {
        return op->getCalledFunction()->getName() == SQRT64_FUNCTION_NAME;
    }
    // it is not a square root nor a call
    return false;
}

/**
 * Gets constant float from LLVMValueRef value
 */
extern "C" float get_constant_float(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *num = dyn_cast<ConstantFP>(v)) {
        return num->getValue().convertToFloat();
    } else if (auto *num = dyn_cast<ConstantInt>(v)) {
        return num->getValue().bitsToFloat();
    }
    errs() << "Not a Constant Float or Constant Int " << *unwrap(val) << "\n";
    throw "LLVM Value Must be a Constant Float or Constant Int";
}

extern "C" LLVMValueRef build_constant_float(double n, LLVMContextRef context) {
    LLVMContext *c = unwrap(context);
    Type *float_type = Type::getFloatTy(*c);
    return wrap(ConstantFP::get(float_type, n));
}

bool is_memset_variety(CallInst *inst) {
    Function *function = inst->getCalledFunction();
    if (function != NULL) {
        StringRef name = function->getName();
        return (name.size() > MEMSET_PREFIX.size() &&
                name.substr(0, MEMSET_PREFIX.size()) == MEMSET_PREFIX) ||
               (name.size() > LLVM_MEMSET_PREFIX.size() &&
                name.substr(0, LLVM_MEMSET_PREFIX.size()) ==
                    LLVM_MEMSET_PREFIX);
    }
    return false;
}

bool is_memcopy_variety(CallInst *inst) {
    Function *function = inst->getCalledFunction();
    if (function != NULL) {
        StringRef name = function->getName();
        return name.size() > MEMCOPY_PREFIX.size() &&
               name.substr(0, MEMCOPY_PREFIX.size()) == MEMCOPY_PREFIX;
    }
    return false;
}

bool is_memmove_variety(CallInst *inst) {
    Function *function = inst->getCalledFunction();
    if (function != NULL) {
        StringRef name = function->getName();
        return name.size() > MEMMOVE_PREFIX.size() &&
               name.substr(0, MEMMOVE_PREFIX.size()) == MEMMOVE_PREFIX;
    }
    return false;
}

bool call_is_not_sqrt(CallInst *inst) {
    Function *function = inst->getCalledFunction();
    if (function != NULL) {
        return !(function->getName() == SQRT32_FUNCTION_NAME ||
                 function->getName() == SQRT64_FUNCTION_NAME);
    }
    return true;  // just assume it is not a sqrt. This means no optimization
                  // will be done
}

/**
 * True iff an instruction is "vectorizable"
 */
bool can_vectorize(Value *value) {
    // TODO:
    Instruction *instr = dyn_cast<Instruction>(value);
    assert(instr != NULL);
    if (instr->getOpcode() == Instruction::FAdd) {
        return true;
    } else if (instr->getOpcode() == Instruction::FSub) {
        return true;
    } else if (instr->getOpcode() == Instruction::FDiv) {
        return true;
    } else if (instr->getOpcode() == Instruction::FMul) {
        return true;
    } else if (instr->getOpcode() == Instruction::FNeg) {
        return true;
    } else if (isa<LoadInst>(instr)) {
        return true;
    } else if (isa<GEPOperator>(instr)) {
        return true;
    } else if (isa<StoreInst>(instr)) {
        return true;
    }
    // else if (isa_sqrt32(wrap(instr))) {
    //     return true;
    // }
    return false;
}

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
        // hopefully this covers all memory intrinsics
        return true;
    }
    return false;
}

/**
 * True iff 2 addresses MIGHT alias.
 *
 * LLVM has a edge case when comparing the same pointer, which is why there is a
 * MustAlias check
 */
bool may_alias(Value *addr1, Value *addr2, AliasAnalysis *AA) {
    // IDK why I have to check both, but
    // something about comparing a address
    // to itself causes this?!~, problem
    // first found in LSMovement
    return (!AA->isNoAlias(addr1,
                           LocationSize::precise(
                               addr1->getType()->getPrimitiveSizeInBits()),
                           addr2,
                           LocationSize::precise(
                               addr2->getType()->getPrimitiveSizeInBits())) ||
            AA->isMustAlias(addr1, addr2));
}

using chunk_t = std::vector<Instruction *>;
using chunks_t = std::vector<std::vector<Instruction *>>;

/**
 * True iff is a special type of instruction for chunking
 *
 */
bool isa_special_chunk_instr(Instruction *instr) {
    return isa_mem_intrinsic(instr) || isa<AllocaInst>(instr) ||
           isa<PHINode>(instr) || isa<CallInst>(instr);
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
                    if (may_alias(curr_store_addr, other_store_addr, AA)) {
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

using ad_tree_t = std::vector<Instruction *>;
using ad_trees_t = std::vector<ad_tree_t>;

/**
 * Recurse LLVM starts at an LLVM instruction and finds
 * all of its arguments, and recursively so on, until
 * either a load / number / arg is reached
 *
 * Non handled instructions are bailed out of by returning a failure
 * Instructions with a load or arg that leaks into another chunk
 * also leads to a failure bailout.
 *
 * Returns a Tuple (Success/Failure , Instructions accumulated)
 */
std::pair<bool, ad_tree_t> recurse_llvm(
    Value *value, std::set<Instruction *> chunk_instrs,
    std::set<Instruction *> basic_block_instrs, bool not_for_mem_constraint) {
    // Constants
    if (isa<Constant>(value)) {
        // DO not add constant, if i recall, constants are not llvm
        // instructions
        return std::make_pair(true, std::vector<Instruction *>{});
    }
    if (Instruction *instr = dyn_cast<Instruction>(value)) {
        if (not_for_mem_constraint) {
            // No Longer in Chunk
            if (chunk_instrs.count(instr) == 0) {
                return std::make_pair<bool, ad_tree_t>(false, {});
            }
        } else {
            // No Longer in Basic Block
            if (basic_block_instrs.count(instr) == 0) {
                return std::make_pair<bool, ad_tree_t>(false, {});
            }
        }

        // Base case instructions
        if (isa<Argument>(instr) || isa<LoadInst>(instr)) {
            // there should not be a load isntr when checking memory instrs
            if (!not_for_mem_constraint && isa<LoadInst>(instr)) {
                return std::make_pair(false, std::vector<Instruction *>{instr});
            }
            return std::make_pair(true, std::vector<Instruction *>{instr});
        }

        // allow for alloca in mem constraint checking
        if (!not_for_mem_constraint && isa<AllocaInst>(instr)) {
            return std::make_pair(true, std::vector<Instruction *>{instr});
        }

        // Phi is trouble, stop at Phis - previously caused recursion to fill
        // stack, and also change results.
        if (isa<PHINode>(instr)) {
            return std::make_pair(false, std::vector<Instruction *>{instr});
        }

        // Recurse on Store Instructions
        if (isa<StoreInst>(instr) &&
            instr->getOperand(0)->getType()->isFloatTy()) {
            auto [child_b, child_tree] =
                recurse_llvm(instr->getOperand(0), chunk_instrs,
                             basic_block_instrs, not_for_mem_constraint);
            if (child_b) {
                child_tree.push_back(instr);
                return std::make_pair(true, child_tree);
            }
        }

        // Recurse on supported unary operators OR Store Instructions
        if (instr->getOpcode() == Instruction::FNeg) {
            auto [child_b, child_tree] =
                recurse_llvm(instr->getOperand(0), chunk_instrs,
                             basic_block_instrs, not_for_mem_constraint);
            if (child_b) {
                child_tree.push_back(instr);
                return std::make_pair(true, child_tree);
            }
        }

        // Recurse on supported binary operators
        if (instr->getOpcode() == Instruction::FAdd ||
            instr->getOpcode() == Instruction::FSub ||
            instr->getOpcode() == Instruction::FDiv ||
            instr->getOpcode() == Instruction::FMul) {
            auto [left_b, left_tree] =
                recurse_llvm(instr->getOperand(0), chunk_instrs,
                             basic_block_instrs, not_for_mem_constraint);
            auto [right_b, right_tree] =
                recurse_llvm(instr->getOperand(1), chunk_instrs,
                             basic_block_instrs, not_for_mem_constraint);
            if (left_b && right_b) {
                left_tree.insert(left_tree.end(), right_tree.begin(),
                                 right_tree.end());
                left_tree.push_back(instr);
                return std::make_pair(true, left_tree);
            }
        }
    }

    if (not_for_mem_constraint) {
        // Unhandled Instruction
        return std::make_pair(false, std::vector<Instruction *>{});
    }

    if (Instruction *value_as_instr = dyn_cast<Instruction>(value)) {
        std::vector<Instruction *> combined_instrs = {};
        bool combined_result = true;
        for (auto &operand : value_as_instr->operands()) {
            auto [child_result, child_tree] =
                recurse_llvm(operand, chunk_instrs, basic_block_instrs,
                             not_for_mem_constraint);
            combined_result = combined_result && child_result;
            combined_instrs.insert(combined_instrs.end(), child_tree.begin(),
                                   child_tree.end());
        }
        return std::make_pair(combined_result, combined_instrs);
    }
    return std::make_pair(true, std::vector<Instruction *>{});
}

bool check_single_memory_address_constraint(
    Value *memory_address_value, ad_trees_t prior_ad_trees,
    std::set<Instruction *> basic_block_instrs) {
    auto [success, accumulated_instrs] =
        recurse_llvm(memory_address_value, {}, basic_block_instrs, false);
    // success only if all instructions are inside the same basic block
    // success also only if instructions tree has no memory operaitons
    // except for alloc/argument
    if (!success) {
        return false;
    }
    bool contained_in_prior_ad_tree = false;
    for (auto instr : accumulated_instrs) {
        for (auto prior_ad_tree : prior_ad_trees) {
            for (auto prior_instr : prior_ad_tree) {
                if (instr == prior_instr) {
                    contained_in_prior_ad_tree = true;
                }
            }
        }
    }
    return !contained_in_prior_ad_tree;
}

/**
    Check each memory address for each memory operation in each ad tree
    satisfies the following constraints:
    1. address computation tree contains no memory operations except for
    alloc / argument
    2. each address computation instruction is not contained in a prior ad
    tree
    3. each address computation only exists within 1 single basic block
*/
bool check_memory_constraints(ad_tree_t curr_ad_tree, ad_trees_t prior_ad_trees,
                              std::set<Instruction *> basic_block_instrs) {
    bool constraint_success = true;
    for (auto instr : curr_ad_tree) {
        if (StoreInst *store = dyn_cast<StoreInst>(instr)) {
            Value *store_pointer = store->getPointerOperand();
            if (!check_single_memory_address_constraint(
                    store_pointer, prior_ad_trees, basic_block_instrs)) {
                constraint_success = false;
                if (!constraint_success) {
                }
                break;
            }
        } else if (LoadInst *load = dyn_cast<LoadInst>(instr)) {
            Value *load_pointer = load->getPointerOperand();
            if (!check_single_memory_address_constraint(
                    load_pointer, prior_ad_trees, basic_block_instrs)) {
                constraint_success = false;
                break;
            }
        }
    }
    return constraint_success;
}

/**
 * An AD Tree is just a vector of instructions reachable from a unique store
 * instruction
 *
 */
ad_trees_t build_ad_trees(chunk_t chunk,
                          std::set<Instruction *> basic_block_instrs) {
    ad_trees_t ad_trees = {};
    std::set<Instruction *> chunk_instrs = {};
    for (auto instr : chunk) {
        chunk_instrs.insert(instr);
    }
    for (auto instr : chunk) {
        if (isa<StoreInst>(instr)) {
            // ad_tree_t new_tree = {};
            auto [success_b, ad_tree] =
                recurse_llvm(instr, chunk_instrs, {}, true);
            if (success_b) {
                assert(ad_tree.size() != 0);
            } else {
                continue;
            }

            // Check each memory address for each memory operation in each
            // ad tree
            bool mem_constraint_result =
                check_memory_constraints(ad_tree, ad_trees, basic_block_instrs);

            if (mem_constraint_result) {
                ad_trees.push_back(ad_tree);
            }
        }
    }
    return ad_trees;
}

/**
 * Joins adtrees together into vecotrs of instructions
 *
 */
std::vector<Instruction *> join_trees(
    std::vector<std::vector<Instruction *>> trees_to_join) {
    std::vector<Instruction *> final_vector = {};
    for (auto tree : trees_to_join) {
        final_vector.insert(final_vector.end(), tree.begin(), tree.end());
    }
    return final_vector;
}

/**
 * True iff there is some load in a joined section of adtrees that MIGHT
 * alias a store in the same tree.
 *
 * Load-store aliasing causes problems in some situation where you have
 * stores as functions of the same loads, but no vectoriszation occurs, so
 * the code is rewritten linearly, and a memory dependency is introduced
 *
 * From a bug in FFT.c
 */
chunks_t remove_load_store_alias(chunks_t chunks, AliasAnalysis *AA) {
    chunks_t final_chunks = {};

    std::vector<std::tuple<Value *, int>> load_addresses = {};
    std::vector<std::tuple<Value *, int>> store_addresses = {};
    int chunk_idx = 0;
    for (auto chunk : chunks) {
        chunk_idx++;

        for (auto instr : chunk) {
            if (isa<LoadInst>(instr)) {
                Value *load_address =
                    dyn_cast<LoadInst>(instr)->getPointerOperand();
                load_addresses.push_back({load_address, chunk_idx});
            } else if (isa<StoreInst>(instr)) {
                Value *store_address =
                    dyn_cast<StoreInst>(instr)->getPointerOperand();
                store_addresses.push_back({store_address, chunk_idx});
            }
        }
        bool can_add_to_final_chunks = true;
        for (auto [load_address, chunk_idx_load] : load_addresses) {
            for (auto [store_address, chunk_idx_store] : store_addresses) {
                if ((chunk_idx_load !=
                     chunk_idx_store) &&  // if thhe load and store come
                                          // from the same chunk, they
                                          // cannot alias in a problem from
                                          // the vectorizaiton as the loads
                                          // will still come before stores
                    may_alias(load_address, store_address, AA)) {
                    can_add_to_final_chunks = false;
                }
            }
        }
        if (can_add_to_final_chunks) {
            final_chunks.push_back(chunk);
        }
    }
    return final_chunks;
}

/**
 * return the index to in baseOfArrayVec that store is an offset from, or
 * NULLOPT if not matching
 */
std::pair<int, int> get_base_reference(Instruction *mem_instr,
                                       std::vector<Value *> base_of_array_vec,
                                       ScalarEvolution *SE) {
    for (int i = 0; i < base_of_array_vec.size(); i++) {
        Value *base_array_ptr = base_of_array_vec[i];
        assert(base_array_ptr->getType()->isPointerTy());
        Value *mem_instr_ptr = NULL;
        if (StoreInst *store_instr = dyn_cast<StoreInst>(mem_instr)) {
            mem_instr_ptr = store_instr->getPointerOperand();
        } else if (LoadInst *load_instr = dyn_cast<LoadInst>(mem_instr)) {
            mem_instr_ptr = load_instr->getPointerOperand();
        }
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

// Check Alignment
inline bool is_aligned(int diff_from_base) { return diff_from_base % 16 == 0; }

/**
 * Given a group of stores trees, greedily assign the store trees into
 * new sets of store trees such that each set is all consecutive and aligned
 * Returns a the sets of groups of stores trees with this property.
 */
std::vector<ad_trees_t> group_trees(
    ad_trees_t group_of_trees, std::map<StoreInst *, int> store_to_offset) {
    std::vector<bool> trees_used = {};
    for (auto _ : group_of_trees) {
        trees_used.push_back(false);
    }

    std::vector<ad_trees_t> result = {};
    uint32_t start_offset = 0;
    while (std::any_of(trees_used.begin(), trees_used.end(),
                       [](bool b) { return !b; })) {
        // get the smallest starting offset
        uint32_t min_offset = UINT32_MAX;
        for (int i = 0; i < group_of_trees.size(); i++) {
            if (trees_used[i]) {
                continue;
            }
            auto tree = group_of_trees[i];
            StoreInst *store = dyn_cast<StoreInst>(tree.back());
            int offset = store_to_offset[store] / FLOAT_SIZE_IN_BYTES;
            if (offset < min_offset) {
                min_offset = offset;
            }
        }
        min_offset = min_offset - (min_offset % VECTOR_WIDTH);
        std::set<int> required_offsets = {};
        for (int i = min_offset; i < min_offset + VECTOR_WIDTH; i++) {
            required_offsets.emplace(i);
        }
        ad_trees_t current_group = {};
        for (int i = 0; i < VECTOR_WIDTH; i++) {
            current_group.push_back({});
        }
        std::set<int> current_offsets = {};
        for (int i = 0; i < group_of_trees.size(); i++) {
            if (trees_used[i]) {
                continue;
            }
            auto tree = group_of_trees[i];
            StoreInst *store = dyn_cast<StoreInst>(tree.back());
            int offset = store_to_offset[store] / FLOAT_SIZE_IN_BYTES;
            int rounded_offset = offset % 4;
            if (required_offsets.count(offset) != 0 &&
                current_offsets.count(offset) == 0) {
                current_offsets.emplace(offset);
                trees_used[i] = true;
                current_group[rounded_offset] = tree;
            }
        }
        bool can_add_result = true;
        for (auto curr_tree : current_group) {
            if (curr_tree.empty()) {
                can_add_result = false;
            }
        }
        if (can_add_result) {
            result.push_back(current_group);
        }
    }

    return result;
}

/**
 * Sort the stores in the ad_trees so that an aligned store
 * is first, followed by consecutive stores
 */
ad_trees_t sort_ad_trees(ad_trees_t ad_trees,
                         std::vector<Value *> base_of_array_vec,
                         ScalarEvolution *SE) {
    // First, group ad_trees according to the base array they belong to.
    // If a tree does not reference a base array, exclude that tree entirely
    std::vector<std::vector<ad_tree_t>> groups_of_trees = {};
    for (int i = 0; i < base_of_array_vec.size(); i++) {
        groups_of_trees.push_back({});
    }

    std::map<StoreInst *, int> store_to_base_map = {};
    for (ad_tree_t ad_tree : ad_trees) {
        if (ad_tree.size() != 0) {
            if (StoreInst *store = dyn_cast<StoreInst>(ad_tree.back())) {
                auto [base_ref, _] =
                    get_base_reference(store, base_of_array_vec, SE);
                if (base_ref >= 0) {
                    groups_of_trees[base_ref].push_back(ad_tree);
                    store_to_base_map[store] = base_ref;
                }
            }
        }
    }

    auto store_sorter = [=](const ad_tree_t &a, const ad_tree_t &b) {
        StoreInst *store_a = dyn_cast<StoreInst>(a.back());
        StoreInst *store_b = dyn_cast<StoreInst>(b.back());

        // get the base references
        Value *ref_a = base_of_array_vec[store_to_base_map.at(store_a)];
        Value *ref_b = base_of_array_vec[store_to_base_map.at(store_b)];

        // get the difference from the store to its reference
        Value *store_a_ptr = store_a->getPointerOperand();
        const SCEV *store_a_ptr_se = SE->getSCEV(store_a_ptr);
        const SCEV *ref_a_ptr_se = SE->getSCEV(ref_a);
        const SCEV *diff_a = SE->getMinusSCEV(store_a_ptr_se, ref_a_ptr_se);
        APInt min_val_a = SE->getSignedRangeMin(diff_a);
        APInt max_val_a = SE->getSignedRangeMax(diff_a);
        assert(min_val_a == max_val_a);
        int val_a = (int)max_val_a.roundToDouble();

        Value *store_b_ptr = store_b->getPointerOperand();
        const SCEV *store_b_ptr_se = SE->getSCEV(store_b_ptr);
        const SCEV *ref_b_ptr_se = SE->getSCEV(ref_b);
        const SCEV *diff_b = SE->getMinusSCEV(store_b_ptr_se, ref_b_ptr_se);
        APInt min_val_b = SE->getSignedRangeMin(diff_b);
        APInt max_val_b = SE->getSignedRangeMax(diff_b);
        assert(min_val_b == max_val_b);
        int val_b = (int)max_val_b.roundToDouble();

        return val_a < val_b;
    };

    // Sort each group of ad_trees by the stores in each group
    for (int i = 0; i < groups_of_trees.size(); i++) {
        // NO IDEA WHY THIS WORKS, BUT ITERATING OVER ELEMENTS I SORTS
        // PROPERLY BUT ITERATING OVER USING COLON DOES NOT!
        std::sort(groups_of_trees[i].begin(), groups_of_trees[i].end(),
                  store_sorter);
    }

    // Build a map mapping stores to their respective offsets
    std::map<StoreInst *, int> store_to_offset = {};
    for (auto group : groups_of_trees) {
        // skip empty groups
        if (group.empty()) {
            continue;
        }
        for (auto tree : group) {
            // Grab basic information about the tree
            StoreInst *store = dyn_cast<StoreInst>(tree.back());
            // Get base ref for the first store
            Value *base_ref = base_of_array_vec[store_to_base_map.at(store)];
            // get the difference from the store to its reference
            Value *store_ptr = store->getPointerOperand();
            const SCEV *store_ptr_se = SE->getSCEV(store_ptr);
            const SCEV *ref_ptr_se = SE->getSCEV(base_ref);
            const SCEV *diff = SE->getMinusSCEV(store_ptr_se, ref_ptr_se);
            APInt min_val = SE->getSignedRangeMin(diff);
            APInt max_val = SE->getSignedRangeMax(diff);
            assert(min_val == max_val);
            int offset = (int)max_val.roundToDouble();
            store_to_offset[store] = offset;
        }
    }

    // Grab only ad_trees that contain a 16 byte aligned reference at the
    // beginning
    // Also the trees must be consecutive stores, e.g. the stores must
    // differ by 4 bytes each time Finally, split the trees into smaller
    // subtrees of size 4

    // We do this by accumulating a running sequence of ad_trees that
    // satisfy the prerequisite conditions above

    std::vector<std::vector<ad_tree_t>> pruned_groups_of_trees = {};
    for (auto group : groups_of_trees) {
        // skip empty groups
        if (group.empty()) {
            continue;
        }

        std::vector<ad_trees_t> new_groups_of_trees =
            group_trees(group, store_to_offset);
        for (auto new_group : new_groups_of_trees) {
            pruned_groups_of_trees.push_back(new_group);
        }
    }

    // Compress group of trees back into 1 ad_tree
    ad_trees_t result = {};
    for (auto group_of_trees : pruned_groups_of_trees) {
        chunk_t combined_chunk = join_trees(group_of_trees);
        int num_stores = 0;
        for (auto instr : combined_chunk) {
            if (isa<StoreInst>(instr)) {
                num_stores++;
            }
        }
        assert(num_stores == VECTOR_WIDTH);
        result.push_back(combined_chunk);
    }

    return result;
}

/**
 * Converts chunks into vectors, representing joined AD Trees
 *
 */
std::vector<std::vector<Instruction *>> chunks_into_joined_trees(
    chunks_t chunks, AliasAnalysis *AA, std::vector<Value *> base_of_array_vec,
    ScalarEvolution *SE, std::set<Instruction *> basic_block_instrs) {
    std::vector<std::vector<Instruction *>> trees = {};
    for (auto chunk : chunks) {
        ad_trees_t ad_trees = build_ad_trees(chunk, basic_block_instrs);

        // Join trees if the store instructions in the trees
        // do not alias each other
        std::vector<std::vector<Instruction *>> joinable_trees = {};
        std::vector<std::vector<std::vector<Instruction *>>> tree_groups = {};
        for (auto tree : ad_trees) {
            // check if stores alias in the trees
            assert(tree.size() > 0);
            Instruction *curr_store = tree.back();
            Value *curr_store_addr = curr_store->getOperand(1);
            bool can_add_tree = true;
            for (auto other_tree : joinable_trees) {
                assert(other_tree.size() > 0);
                Instruction *other_store = other_tree.back();
                Value *other_store_addr = other_store->getOperand(1);
                if (may_alias(curr_store_addr, other_store_addr, AA)) {
                    can_add_tree = false;
                    break;
                }
            }
            if (can_add_tree) {
                joinable_trees.push_back(tree);
            } else {
                assert(joinable_trees.size() > 0);
                tree_groups.push_back(joinable_trees);
                joinable_trees = {tree};
            }
        }
        if (joinable_trees.size() > 0) {
            tree_groups.push_back(joinable_trees);
        }

        // Rearrange the joinable trees by changing their store ordering
        // Then Merge Joinable trees into trees
        for (auto tree_group : tree_groups) {
            ad_trees_t new_ad_trees =
                sort_ad_trees(tree_group, base_of_array_vec, SE);
            for (auto chunk : new_ad_trees) {
                trees.push_back(chunk);
            }
        }
    }
    // Do final removal of any sequences with store-load aliasing
    return remove_load_store_alias(trees, AA);
}

/*
Build AD Trees for each Chunk
**/

/// Map instr2ref over a vector
std::vector<std::vector<LLVMValueRef>> instr2ref(chunks_t chunks) {
    std::vector<std::vector<LLVMValueRef>> mapped_instrs = {};
    for (auto chunk : chunks) {
        std::vector<LLVMValueRef> mapped_chunk = {};
        for (auto instr : chunk) {
            mapped_chunk.push_back(wrap(instr));
        }
        mapped_instrs.push_back(mapped_chunk);
    }
    return mapped_instrs;
}

/**
 * Run Optimization Procedure on Vector representing concatenated ad trees
 *
 */
bool run_optimization(std::vector<LLVMValueRef> chunk, Function &F,
                      std::vector<load_info_t> load_info) {
    assert(chunk.size() != 0);
    // Place the builder at the last instruction in the entire chunk.
    Value *last_value = unwrap(chunk.back());
    Instruction *last_instr = dyn_cast<Instruction>(last_value);
    assert(last_instr != NULL);
    IRBuilder<> builder(last_instr);

    Module *mod = F.getParent();
    LLVMContext &context = F.getContext();
    std::vector<LLVMValueRef> restricted_instrs = {};

    return optimize(wrap(mod), wrap(&context), wrap(&builder), chunk.data(),
                    chunk.size(), restricted_instrs.data(),
                    restricted_instrs.size(), load_info.data(),
                    load_info.size(), RunOpt, PrintOpt);
}

/**
 * Match each load with a pair of base id and offset
 *
 * NOTE: A load might be associated with more than 1 base, we choose the
 * first. THIS COULD BE A BUG in the future!
 */
std::vector<load_info_t> match_loads(std::vector<LoadInst *> loads,
                                     std::vector<Value *> base_load_locations,
                                     ScalarEvolution *SE) {
    std::vector<load_info_t> results = {};
    for (LoadInst *load : loads) {
        bool continue_iteration = false;
        for (Value *base_loc : base_load_locations) {
            auto [load_base, load_offset] =
                get_base_reference(load, base_load_locations, SE);
            if (load_base >= 0) {
                load_info_t new_load = {.load = wrap(load),
                                        .base_id = load_base,
                                        .offset = static_cast<int32_t>(
                                            load_offset / FLOAT_SIZE_IN_BYTES)};
                results.push_back(new_load);
                continue_iteration = true;
                break;
            }
        }
        if (continue_iteration) {
            continue;
        }
    }
    return results;
}

/**
 * Below is the main DiospyrosPass that activates the Rust lib.rs code,
 * which calls the Egg vectorizer and rewrites the optimized code in place.
 */

namespace {
struct DiospyrosPass : public FunctionPass {
    static char ID;
    DiospyrosPass() : FunctionPass(ID) {}

    void getAnalysisUsage(AnalysisUsage &AU) const override {
        AU.addRequired<AAResultsWrapperPass>();
        AU.addRequired<BasicAAWrapperPass>();
        AU.addRequired<ScalarEvolutionWrapperPass>();
        AU.addRequired<TargetLibraryInfoWrapperPass>();
    }

    virtual bool runOnFunction(Function &F) override {
        // We need Alias Analysis still, because it is possible groups of
        // stores can addresses that alias.
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();
        ScalarEvolution *SE =
            &getAnalysis<ScalarEvolutionWrapperPass>().getSE();
        TargetLibraryInfo *TLI =
            &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);

        // do not optimize on main function or no_opt functions.
        if (F.getName() == MAIN_FUNCTION_NAME ||
            (F.getName().size() > NO_OPT_PREFIX.size() &&
             F.getName().substr(0, NO_OPT_PREFIX.size()) == NO_OPT_PREFIX)) {
            return false;
        }

        // get all "Base" Arrays on which vectorization can occur. These are
        // defined as argument inputs with a pointer type
        std::vector<Value *> base_of_array_vec = {};
        for (auto &a : F.args()) {
            if (a.getType()->isPointerTy()) {
                if (Value *arg_val = dyn_cast<Value>(&a)) {
                    base_of_array_vec.push_back(arg_val);
                }
            }
        }

        // Grab information on load base locations
        std::vector<Value *> base_load_locations = {};
        for (auto &a : F.args()) {
            if (a.getType()->isPointerTy()) {
                if (Value *arg_val = dyn_cast<Value>(&a)) {
                    base_load_locations.push_back(arg_val);
                }
            }
        }
        for (auto &B : F) {
            for (auto &I : B) {
                if (Value *V = dyn_cast<Value>(&I)) {
                    if (isMallocOrCallocLikeFn(V, TLI)) {
                        base_load_locations.push_back(V);
                    }
                }
            }
        }
        std::map<Value *, int> base_load_to_id = {};
        int count = 0;
        for (auto instr : base_load_locations) {
            base_load_to_id[instr] = count++;
        }

        // Grab information on loads
        std::vector<LoadInst *> loads = {};
        for (auto &B : F) {
            for (auto &I : B) {
                if (LoadInst *load_instr = dyn_cast<LoadInst>(&I)) {
                    if (std::find(loads.begin(), loads.end(), load_instr) ==
                        loads.end()) {
                        loads.push_back(load_instr);
                    }
                }
            }
        }
        std::vector<load_info_t> load_info =
            match_loads(loads, base_load_locations, SE);

        bool has_changes = true;
        for (auto &B : F) {
            // Grab instructions in basic block
            std::set<Instruction *> basic_block_instrs = {};
            for (auto &I : B) {
                basic_block_instrs.insert(&I);
            }

            auto chunks = build_chunks(&B, AA);
            auto trees = chunks_into_joined_trees(chunks, AA, base_of_array_vec,
                                                  SE, basic_block_instrs);
            auto treerefs = instr2ref(trees);

            for (auto tree_chunk : treerefs) {
                if (tree_chunk.size() != 0) {
                    has_changes = run_optimization(tree_chunk, F, load_info);
                }
            }
        }
        return has_changes;
    };
};
}  // namespace

char DiospyrosPass::ID = 0;

// Automatically enable the pass.
// http://adriansampson.net/blog/clangpass.html
static void registerDiospyrosPass(const PassManagerBuilder &,
                                  legacy::PassManagerBase &PM) {
    PM.add(new DiospyrosPass());
}

static RegisterPass<DiospyrosPass> X("diospyros", "Diospyros Pass",
                                     false /* Only looks at CFG */,
                                     true /* Analysis Pass */);

static RegisterStandardPasses RegisterMyPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerDiospyrosPass);

// TODO check that no gep have a load in the calculation chain or some
// memory address