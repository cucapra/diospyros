#include <assert.h>

#include <map>
#include <utility>
#include <vector>

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/MemoryLocation.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Type.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;

const std::string MAIN_FUNCTION_NAME = "main";
const std::string NO_OPT_PREFIX = "no_opt_";
const std::string GATHER_NAME = "llvm.masked.gather.v4f32.v4p0f32";
const uint32_t VECTOR_WIDTH = 4;

namespace {
struct LoadStoreMovementPass : public FunctionPass {
    static char ID;
    LoadStoreMovementPass() : FunctionPass(ID) {}

    void getAnalysisUsage(AnalysisUsage &AU) const override {
        AU.addRequired<AAResultsWrapperPass>();
        AU.addRequired<BasicAAWrapperPass>();
    }

    bool isa_gather_instruction(Instruction *instr) {
        if (CallInst *call_instr = dyn_cast<CallInst>(instr)) {
            Function *fun = call_instr->getCalledFunction();
            // Source:
            // https://stackoverflow.com/questions/11686951/how-can-i-get-function-name-from-callinst-in-llvm
            // Fun Could be NULL, in which case indirect call occurs, i cannot
            // get name.
            if (fun) {
                if (fun->getName() == GATHER_NAME) {
                    return true;
                }
            }
        }
        return false;
    }

    bool may_alias(Value *mem_addr1, Value *mem_addr2, AliasAnalysis *AA) {
        return (!AA->isNoAlias(
                    mem_addr1,
                    LocationSize::precise(
                        mem_addr1->getType()->getPrimitiveSizeInBits()),
                    mem_addr2,
                    LocationSize::precise(
                        mem_addr2->getType()->getPrimitiveSizeInBits())) ||
                AA->isMustAlias(mem_addr1, mem_addr2));
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
        for (int i = 0; i < VECTOR_WIDTH; i++) {
            Value *pointer = insert_element_instr->getOperand(1);
            gather_addresses.push_back(pointer);
            Instruction *new_insert_element_instr =
                dyn_cast<Instruction>(insert_element_instr->getOperand(0));
            insert_element_instr = new_insert_element_instr;
        }
        return gather_addresses;
    }

    std::vector<Instruction *> get_gather_insert_instrs(
        Instruction *call_to_gather) {
        assert(isa_gather_instruction(call_to_gather));

        Instruction *insert_element_instr =
            dyn_cast<Instruction>(call_to_gather->getOperand(0));
        if (insert_element_instr == NULL) {
            throw "Gather Arguments Pointer Vector was NULL";
        }

        std::vector<Instruction *> insert_instrs = {};
        // hardcode to gathers of length 4 only
        for (int i = 0; i < VECTOR_WIDTH; i++) {
            Value *pointer = insert_element_instr->getOperand(1);
            insert_instrs.push_back(insert_element_instr);
            Instruction *new_insert_element_instr =
                dyn_cast<Instruction>(insert_element_instr->getOperand(0));
            insert_element_instr = new_insert_element_instr;
        }
        return insert_instrs;
    }

    /**
     * True iff the gather instr can be moved before prior_instr
     */
    bool can_move_gather_instruction_before(Instruction *gather_instr,
                                            Instruction *prior_instr,
                                            AliasAnalysis *AA) {
        // If the prior instruction is a phi node, you cannot move the
        // instrution back
        if (isa<PHINode>(prior_instr)) {
            return false;
        }

        // If the prior Instruction is a call inst [which is not to a gather
        // intrinsic], do not push the current instruction back A call
        // instruciton could have side effects to memory In addition, a call
        // could be to @llvm.memset.p0i8.i64(i8* nonnull align 16
        // dereferenceable(40) %2, i8 0, i64 40, i1 false) or
        // @memset_pattern16(i8* nonnull %2, i8* bitcast
        // ([4 x float]* @.memset_pattern to i8*), i64 40) #6 which
        // require alias analysis as well

        if (isa<CallInst>(prior_instr) &&
            !isa_gather_instruction(prior_instr)) {
            return false;
        }

        // If the prior instruction is a gather instruction, do comparisons of
        // the addresses

        std::vector<Value *> current_instr_addrs =
            get_gather_addresses(gather_instr);
        if (isa<CallInst>(prior_instr) && isa_gather_instruction(prior_instr)) {
            std::vector<Value *> prior_instr_addrs =
                get_gather_addresses(prior_instr);
            for (auto curr_addr : current_instr_addrs) {
                for (auto prior_addr : prior_instr_addrs) {
                    assert(curr_addr->getType()->isPointerTy());
                    assert(prior_addr->getType()->isPointerTy());
                    if (may_alias(curr_addr, prior_addr, AA)) {
                        return false;
                    }
                }
            }
        }

        // If the prior instruction is used in the load's
        // arguments, do not push it back

        // In this case, the prior instruction could only be the geps in
        // the current instruction addreses accessed
        std::vector<Instruction *> current_uses =
            get_gather_insert_instrs(gather_instr);
        for (auto current_use : current_uses) {
            if (current_use == prior_instr) {
                return false;
            }
        }

        // If the prior instruction alias with the load
        // instruction, do not push the store back
        // We do not rehandle gather instructions, which were already handled.
        if (prior_instr->mayReadOrWriteMemory() &&
            !isa_gather_instruction(prior_instr)) {
            Value *prior_addr = NULL;
            if (isa<LoadInst>(prior_instr)) {
                prior_addr =
                    dyn_cast<LoadInst>(prior_instr)->getPointerOperand();
            } else if (isa<StoreInst>(prior_instr)) {
                prior_addr =
                    dyn_cast<StoreInst>(prior_instr)->getPointerOperand();
            } else {
                errs() << *prior_instr << "\n";
                throw "Unmatched Instruction Type";
            }
            for (auto curr_addr : current_instr_addrs) {
                assert(curr_addr->getType()->isPointerTy());
                assert(prior_addr->getType()->isPointerTy());
                if (may_alias(curr_addr, prior_addr, AA)) {
                    return false;
                }
            }
        }
        return true;
    }

    void move_forward_gather_instrs(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

        for (auto &B : F) {
            // Grab all instructions
            std::vector<Instruction *> all_instrs = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);
                all_instrs.push_back(instr);
            }

            // Perform Pushing Back of Gather Instructions
            std::vector<Instruction *> final_instrs_vec = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);

                // Place any non-Gather Instructions at the end of the list of
                // instructions
                if (!(isa_gather_instruction(instr))) {
                    final_instrs_vec.push_back(instr);
                    continue;
                }

                // Handle Load Instructions
                int insertion_offset = final_instrs_vec.size();
                while (true) {
                    Instruction *gather_instr = instr;
                    // If there is no prior instruction, push back at current
                    // offset, and stop.
                    if (insertion_offset - 1 < 0) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            gather_instr);
                        break;
                    }

                    Instruction *prior_instr =
                        final_instrs_vec[insertion_offset - 1];

                    if (!can_move_gather_instruction_before(gather_instr,
                                                            prior_instr, AA)) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            gather_instr);
                        break;
                    }

                    // Otherwise, keep pushing back the load instruction
                    --insertion_offset;
                    assert(insertion_offset >= 0);
                }
            }

            // First, insert clone all instructions, and insert them into the
            // basic block at the very beginning

            // build ordered vector of cloned instructions
            // build map from original vector to cloned vector
            std::vector<Instruction *> cloned_instrs = {};
            std::map<Instruction *, Instruction *> original_to_clone_map = {};
            std::map<Instruction *, Instruction *> clone_to_original_map = {};
            for (Instruction *instr : final_instrs_vec) {
                Instruction *cloned_instr = instr->clone();
                cloned_instrs.push_back(cloned_instr);
                original_to_clone_map[instr] = cloned_instr;
                clone_to_original_map[cloned_instr] = instr;
            }

            // Grab first instruction to build before at.
            Instruction *first_instr = NULL;
            for (auto &I : B) {
                first_instr = dyn_cast<Instruction>(&I);
                assert(first_instr != NULL);
                break;
            }
            IRBuilder<> builder(first_instr);
            builder.SetInsertPoint(&B);

            for (Instruction *cloned_instr : cloned_instrs) {
                // set insert point to be before beginning if inserting phi
                // instruction
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(first_instr);
                }
                builder.Insert(cloned_instr);
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(&B);
                }
                // The cloned instruction has arguments pointing backwards to
                // prior original instructions. Some of these prior instructions
                // themselves will themselves be cloned. We need to replace the
                // prior original instructions with clones instructions
                int num_operands = cloned_instr->getNumOperands();
                for (int i = 0; i < num_operands; i++) {
                    Value *clone_operand = cloned_instr->getOperand(i);
                    Instruction *clone_operand_instr =
                        dyn_cast<Instruction>(clone_operand);
                    if (clone_operand_instr != NULL) {
                        if (original_to_clone_map.count(clone_operand_instr) >
                            0) {
                            Instruction *replacement_operand =
                                original_to_clone_map[clone_operand_instr];
                            Value *replacement_value =
                                dyn_cast<Value>(replacement_operand);
                            assert(replacement_value != NULL);
                            cloned_instr->setOperand(i, replacement_value);
                        }
                    } else {
                        Instruction *original_instr =
                            clone_to_original_map[cloned_instr];
                        cloned_instr->setOperand(i,
                                                 original_instr->getOperand(i));
                    }
                }

                // Furthermore, we need to change all uses of the original
                // instruction to be the new cloned instruction
                Instruction *original_instr =
                    clone_to_original_map[cloned_instr];
                if (Value *original_val = dyn_cast<Value>(original_instr)) {
                    Value *cloned_val = dyn_cast<Value>(cloned_instr);
                    assert(cloned_val != NULL);
                    original_val->replaceAllUsesWith(cloned_val);
                }
            }

            // Finally, delete all the original instructions in the basic block
            // Do this in reverse order.
            std::reverse(all_instrs.begin(), all_instrs.end());
            for (Instruction *instr : all_instrs) {
                instr->eraseFromParent();
            }
        }
    }

    void move_forward_gep_instrs(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

        for (auto &B : F) {
            // Grab all instructions
            std::vector<Instruction *> all_instrs = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);
                all_instrs.push_back(instr);
            }

            // Perform Pushing Back of Gep Instructions
            std::vector<Instruction *> final_instrs_vec = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);

                // Place any non-Gep Instructions at the end of the list of
                // instructions
                if (!(isa<GEPOperator>(instr))) {
                    final_instrs_vec.push_back(instr);
                    continue;
                }

                // Handle Gep Instructions
                int insertion_offset = final_instrs_vec.size();
                while (true) {
                    Instruction *load_instr = instr;
                    // If there is no prior instruction, push back at current
                    // offset, and stop.
                    if (insertion_offset - 1 < 0) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    Instruction *prior_instr =
                        final_instrs_vec[insertion_offset - 1];

                    // If the prior instruction is a phi node, do not push the
                    // current instruction back
                    if (isa<PHINode>(prior_instr)) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    // If the prior instruction is used in the load's
                    // arguments, do not push it back
                    int num_operands = load_instr->getNumOperands();
                    bool break_while = false;
                    for (int i = 0; i < num_operands; i++) {
                        Value *load_operand = load_instr->getOperand(i);
                        Instruction *load_operand_instr =
                            dyn_cast<Instruction>(load_operand);
                        if (load_operand_instr != NULL) {
                            if (load_operand_instr == prior_instr) {
                                final_instrs_vec.insert(
                                    final_instrs_vec.begin() + insertion_offset,
                                    load_instr);
                                break_while = true;
                                break;
                            }
                        }
                    }
                    if (break_while) {
                        break;
                    }

                    // Otherwise, keep pushing back the load instruction
                    --insertion_offset;
                    assert(insertion_offset >= 0);
                }
            }

            // First, insert clone all instructions, and insert them into the
            // basic block at the very beginning

            // build ordered vector of cloned instructions
            // build map from original vector to cloned vector
            std::vector<Instruction *> cloned_instrs = {};
            std::map<Instruction *, Instruction *> original_to_clone_map = {};
            std::map<Instruction *, Instruction *> clone_to_original_map = {};
            for (Instruction *instr : final_instrs_vec) {
                Instruction *cloned_instr = instr->clone();
                cloned_instrs.push_back(cloned_instr);
                original_to_clone_map[instr] = cloned_instr;
                clone_to_original_map[cloned_instr] = instr;
            }

            // Grab first instruction to build before at.
            Instruction *first_instr = NULL;
            for (auto &I : B) {
                first_instr = dyn_cast<Instruction>(&I);
                assert(first_instr != NULL);
                break;
            }
            IRBuilder<> builder(first_instr);
            builder.SetInsertPoint(&B);

            for (Instruction *cloned_instr : cloned_instrs) {
                // set insert point to be before beginning if inserting phi
                // instruction
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(first_instr);
                }
                builder.Insert(cloned_instr);
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(&B);
                }
                // The cloned instruction has arguments pointing backwards to
                // prior original instructions. Some of these prior instructions
                // themselves will themselves be cloned. We need to replace the
                // prior original instructions with clones instructions
                int num_operands = cloned_instr->getNumOperands();
                for (int i = 0; i < num_operands; i++) {
                    Value *clone_operand = cloned_instr->getOperand(i);
                    Instruction *clone_operand_instr =
                        dyn_cast<Instruction>(clone_operand);
                    if (clone_operand_instr != NULL) {
                        if (original_to_clone_map.count(clone_operand_instr) >
                            0) {
                            Instruction *replacement_operand =
                                original_to_clone_map[clone_operand_instr];
                            Value *replacement_value =
                                dyn_cast<Value>(replacement_operand);
                            assert(replacement_value != NULL);
                            cloned_instr->setOperand(i, replacement_value);
                        }
                    } else {
                        Instruction *original_instr =
                            clone_to_original_map[cloned_instr];
                        cloned_instr->setOperand(i,
                                                 original_instr->getOperand(i));
                    }
                }

                // Furthermore, we need to change all uses of the original
                // instruction to be the new cloned instruction
                Instruction *original_instr =
                    clone_to_original_map[cloned_instr];
                if (Value *original_val = dyn_cast<Value>(original_instr)) {
                    Value *cloned_val = dyn_cast<Value>(cloned_instr);
                    assert(cloned_val != NULL);
                    original_val->replaceAllUsesWith(cloned_val);
                }
            }

            // Finally, delete all the original instructions in the basic block
            // Do this in reverse order.
            std::reverse(all_instrs.begin(), all_instrs.end());
            for (Instruction *instr : all_instrs) {
                instr->eraseFromParent();
            }
        }
    }

    void move_forward_bitcast_instrs(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

        for (auto &B : F) {
            // Grab all instructions
            std::vector<Instruction *> all_instrs = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);
                all_instrs.push_back(instr);
            }

            // Perform Pushing Back of Bitcast Instructions
            std::vector<Instruction *> final_instrs_vec = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);

                // Place any non-Bitcast Instructions at the end of the list of
                // instructions
                if (!(isa<BitCastInst>(instr))) {
                    final_instrs_vec.push_back(instr);
                    continue;
                }

                // Handle Gep Instructions
                int insertion_offset = final_instrs_vec.size();
                while (true) {
                    Instruction *load_instr = instr;
                    // If there is no prior instruction, push back at current
                    // offset, and stop.
                    if (insertion_offset - 1 < 0) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    Instruction *prior_instr =
                        final_instrs_vec[insertion_offset - 1];

                    // If the prior instruction is a phi node, do not push the
                    // current instruction back
                    if (isa<PHINode>(prior_instr)) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    // If the prior instruction is used in the load's
                    // arguments, do not push it back
                    int num_operands = load_instr->getNumOperands();
                    bool break_while = false;
                    for (int i = 0; i < num_operands; i++) {
                        Value *load_operand = load_instr->getOperand(i);
                        Instruction *load_operand_instr =
                            dyn_cast<Instruction>(load_operand);
                        if (load_operand_instr != NULL) {
                            if (load_operand_instr == prior_instr) {
                                final_instrs_vec.insert(
                                    final_instrs_vec.begin() + insertion_offset,
                                    load_instr);
                                break_while = true;
                                break;
                            }
                        }
                    }
                    if (break_while) {
                        break;
                    }

                    // Otherwise, keep pushing back the load instruction
                    --insertion_offset;
                    assert(insertion_offset >= 0);
                }
            }

            // First, insert clone all instructions, and insert them into the
            // basic block at the very beginning

            // build ordered vector of cloned instructions
            // build map from original vector to cloned vector
            std::vector<Instruction *> cloned_instrs = {};
            std::map<Instruction *, Instruction *> original_to_clone_map = {};
            std::map<Instruction *, Instruction *> clone_to_original_map = {};
            for (Instruction *instr : final_instrs_vec) {
                Instruction *cloned_instr = instr->clone();
                cloned_instrs.push_back(cloned_instr);
                original_to_clone_map[instr] = cloned_instr;
                clone_to_original_map[cloned_instr] = instr;
            }

            // Grab first instruction to build before at.
            Instruction *first_instr = NULL;
            for (auto &I : B) {
                first_instr = dyn_cast<Instruction>(&I);
                assert(first_instr != NULL);
                break;
            }
            IRBuilder<> builder(first_instr);
            builder.SetInsertPoint(&B);

            for (Instruction *cloned_instr : cloned_instrs) {
                // set insert point to be before beginning if inserting phi
                // instruction
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(first_instr);
                }
                builder.Insert(cloned_instr);
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(&B);
                }
                // The cloned instruction has arguments pointing backwards to
                // prior original instructions. Some of these prior instructions
                // themselves will themselves be cloned. We need to replace the
                // prior original instructions with clones instructions
                int num_operands = cloned_instr->getNumOperands();
                for (int i = 0; i < num_operands; i++) {
                    Value *clone_operand = cloned_instr->getOperand(i);
                    Instruction *clone_operand_instr =
                        dyn_cast<Instruction>(clone_operand);
                    if (clone_operand_instr != NULL) {
                        if (original_to_clone_map.count(clone_operand_instr) >
                            0) {
                            Instruction *replacement_operand =
                                original_to_clone_map[clone_operand_instr];
                            Value *replacement_value =
                                dyn_cast<Value>(replacement_operand);
                            assert(replacement_value != NULL);
                            cloned_instr->setOperand(i, replacement_value);
                        }
                    } else {
                        Instruction *original_instr =
                            clone_to_original_map[cloned_instr];
                        cloned_instr->setOperand(i,
                                                 original_instr->getOperand(i));
                    }
                }

                // Furthermore, we need to change all uses of the original
                // instruction to be the new cloned instruction
                Instruction *original_instr =
                    clone_to_original_map[cloned_instr];
                if (Value *original_val = dyn_cast<Value>(original_instr)) {
                    Value *cloned_val = dyn_cast<Value>(cloned_instr);
                    assert(cloned_val != NULL);
                    original_val->replaceAllUsesWith(cloned_val);
                }
            }

            // Finally, delete all the original instructions in the basic block
            // Do this in reverse order.
            std::reverse(all_instrs.begin(), all_instrs.end());
            for (Instruction *instr : all_instrs) {
                instr->eraseFromParent();
            }
        }
    }

    void move_forward_insert_element_instrs(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

        for (auto &B : F) {
            // Grab all instructions
            std::vector<Instruction *> all_instrs = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);
                all_instrs.push_back(instr);
            }

            // Perform Pushing Back of Gep Instructions
            std::vector<Instruction *> final_instrs_vec = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);

                // Place any non-Gep Instructions at the end of the list of
                // instructions
                if (!(isa<InsertElementInst>(instr))) {
                    final_instrs_vec.push_back(instr);
                    continue;
                }

                // Handle Gep Instructions
                int insertion_offset = final_instrs_vec.size();
                while (true) {
                    Instruction *load_instr = instr;
                    // If there is no prior instruction, push back at current
                    // offset, and stop.
                    if (insertion_offset - 1 < 0) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    Instruction *prior_instr =
                        final_instrs_vec[insertion_offset - 1];

                    // If the prior instruction is a phi node, do not push the
                    // current instruction back
                    if (isa<PHINode>(prior_instr)) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    // If the prior instruction is used in the load's
                    // arguments, do not push it back
                    int num_operands = load_instr->getNumOperands();
                    bool break_while = false;
                    for (int i = 0; i < num_operands; i++) {
                        Value *load_operand = load_instr->getOperand(i);
                        Instruction *load_operand_instr =
                            dyn_cast<Instruction>(load_operand);
                        if (load_operand_instr != NULL) {
                            if (load_operand_instr == prior_instr) {
                                final_instrs_vec.insert(
                                    final_instrs_vec.begin() + insertion_offset,
                                    load_instr);
                                break_while = true;
                                break;
                            }
                        }
                    }
                    if (break_while) {
                        break;
                    }

                    // Otherwise, keep pushing back the load instruction
                    --insertion_offset;
                    assert(insertion_offset >= 0);
                }
            }

            // First, insert clone all instructions, and insert them into the
            // basic block at the very beginning

            // build ordered vector of cloned instructions
            // build map from original vector to cloned vector
            std::vector<Instruction *> cloned_instrs = {};
            std::map<Instruction *, Instruction *> original_to_clone_map = {};
            std::map<Instruction *, Instruction *> clone_to_original_map = {};
            for (Instruction *instr : final_instrs_vec) {
                Instruction *cloned_instr = instr->clone();
                cloned_instrs.push_back(cloned_instr);
                original_to_clone_map[instr] = cloned_instr;
                clone_to_original_map[cloned_instr] = instr;
            }

            // Grab first instruction to build before at.
            Instruction *first_instr = NULL;
            for (auto &I : B) {
                first_instr = dyn_cast<Instruction>(&I);
                assert(first_instr != NULL);
                break;
            }
            IRBuilder<> builder(first_instr);
            builder.SetInsertPoint(&B);

            for (Instruction *cloned_instr : cloned_instrs) {
                // set insert point to be before beginning if inserting phi
                // instruction
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(first_instr);
                }
                builder.Insert(cloned_instr);
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(&B);
                }
                // The cloned instruction has arguments pointing backwards to
                // prior original instructions. Some of these prior instructions
                // themselves will themselves be cloned. We need to replace the
                // prior original instructions with clones instructions
                int num_operands = cloned_instr->getNumOperands();
                for (int i = 0; i < num_operands; i++) {
                    Value *clone_operand = cloned_instr->getOperand(i);
                    Instruction *clone_operand_instr =
                        dyn_cast<Instruction>(clone_operand);
                    if (clone_operand_instr != NULL) {
                        if (original_to_clone_map.count(clone_operand_instr) >
                            0) {
                            Instruction *replacement_operand =
                                original_to_clone_map[clone_operand_instr];
                            Value *replacement_value =
                                dyn_cast<Value>(replacement_operand);
                            assert(replacement_value != NULL);
                            cloned_instr->setOperand(i, replacement_value);
                        }
                    } else {
                        Instruction *original_instr =
                            clone_to_original_map[cloned_instr];
                        cloned_instr->setOperand(i,
                                                 original_instr->getOperand(i));
                    }
                }

                // Furthermore, we need to change all uses of the original
                // instruction to be the new cloned instruction
                Instruction *original_instr =
                    clone_to_original_map[cloned_instr];
                if (Value *original_val = dyn_cast<Value>(original_instr)) {
                    Value *cloned_val = dyn_cast<Value>(cloned_instr);
                    assert(cloned_val != NULL);
                    original_val->replaceAllUsesWith(cloned_val);
                }
            }

            // Finally, delete all the original instructions in the basic block
            // Do this in reverse order.
            std::reverse(all_instrs.begin(), all_instrs.end());
            for (Instruction *instr : all_instrs) {
                instr->eraseFromParent();
            }
        }
    }

    /**
     * Move Loads as far forward as possible in LLVM IR
     */
    void rewrite_loads(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

        for (auto &B : F) {
            // Grab all instructions
            std::vector<Instruction *> all_instrs = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);
                all_instrs.push_back(instr);
            }

            // Perform Pushing Back of Load Instructions
            std::vector<Instruction *> final_instrs_vec = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);

                // Place any non-Load Instructions at the end of the list of
                // instructions
                if (!(isa<LoadInst>(instr) || isa<GEPOperator>(instr))) {
                    final_instrs_vec.push_back(instr);
                    continue;
                }

                // Handle Load Instructions
                int insertion_offset = final_instrs_vec.size();
                while (true) {
                    Instruction *load_instr = instr;
                    // If there is no prior instruction, push back at current
                    // offset, and stop.
                    if (insertion_offset - 1 < 0) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    Instruction *prior_instr =
                        final_instrs_vec[insertion_offset - 1];

                    // If the prior instruction is a phi node, do not push the
                    // current instruction back
                    if (isa<PHINode>(prior_instr)) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    // If the prior Instruction is a call inst, do not push the
                    // current instruction back
                    // A call instruciton could have side effects to memory
                    // In addition, a call could be to @llvm.memset.p0i8.i64(i8*
                    // nonnull align 16 dereferenceable(40) %2, i8 0, i64 40, i1
                    // false) or @memset_pattern16(i8* nonnull %2, i8* bitcast
                    // ([4 x float]* @.memset_pattern to i8*), i64 40) #6 which
                    // require alias analysis as well

                    // TODO: discriminate calls to llvm memset
                    if (isa<CallInst>(prior_instr)) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            load_instr);
                        break;
                    }

                    // If the prior instruction is used in the load's
                    // arguments, do not push it back
                    int num_operands = load_instr->getNumOperands();
                    bool break_while = false;
                    for (int i = 0; i < num_operands; i++) {
                        Value *load_operand = load_instr->getOperand(i);
                        Instruction *load_operand_instr =
                            dyn_cast<Instruction>(load_operand);
                        if (load_operand_instr != NULL) {
                            if (load_operand_instr == prior_instr) {
                                final_instrs_vec.insert(
                                    final_instrs_vec.begin() + insertion_offset,
                                    load_instr);
                                break_while = true;
                                break;
                            }
                        }
                    }
                    if (break_while) {
                        break;
                    }

                    // If the prior instruction alias with the load
                    // instruction, do not push the store back
                    if (prior_instr->mayReadOrWriteMemory()) {
                        Value *prior_addr = NULL;
                        if (isa<LoadInst>(prior_instr)) {
                            prior_addr = dyn_cast<LoadInst>(prior_instr)
                                             ->getPointerOperand();
                            // prior_addr = prior_instr->getOperand(0);
                        } else if (isa<StoreInst>(prior_instr)) {
                            prior_addr = dyn_cast<StoreInst>(prior_instr)
                                             ->getPointerOperand();
                            // prior_addr = prior_instr->getOperand(1);
                        } else {
                            throw "Unmatched Instruction Type";
                        }
                        Value *load_addr = dyn_cast<Value>(load_instr);
                        if (isa<LoadInst>(load_instr)) {
                            load_addr = dyn_cast<LoadInst>(load_instr)
                                            ->getPointerOperand();
                            // load_addr = load_instr->getOperand(0);
                        }
                        assert(load_addr != NULL);
                        if (!AA->isNoAlias(
                                load_addr,
                                LocationSize::precise(
                                    load_addr->getType()
                                        ->getPrimitiveSizeInBits()),
                                prior_addr,
                                LocationSize::precise(
                                    prior_addr->getType()
                                        ->getPrimitiveSizeInBits())) ||
                            AA->isMustAlias(
                                load_addr,
                                prior_addr)) {  // IDK WTF is happening, but
                                                // apparently, the same pointers
                                                // that mod / ref causes no
                                                // alias?!
                            final_instrs_vec.insert(
                                final_instrs_vec.begin() + insertion_offset,
                                load_instr);
                            break;
                        }
                    }

                    // if (isa_gather_instruction(prior_instr)) {
                    //     std::vector<Value *> gather_addresses =
                    //         get_gather_addresses(prior_instr);
                    //     Value *load_addr = dyn_cast<Value>(load_instr);
                    //     if (isa<LoadInst>(load_instr)) {
                    //         load_addr = dyn_cast<LoadInst>(load_instr)
                    //                         ->getPointerOperand();
                    //     }
                    //     assert(load_addr != NULL);
                    //     bool gather_break = false;
                    //     for (auto gather_address : gather_addresses) {
                    //         if (may_alias(gather_address, load_addr, AA)) {
                    //             gather_break = true;
                    //             break;
                    //         }
                    //     }
                    //     if (gather_break) {
                    //         final_instrs_vec.insert(
                    //             final_instrs_vec.begin() + insertion_offset,
                    //             load_instr);
                    //         break;
                    //     }
                    // }

                    // Otherwise, keep pushing back the load instruction
                    --insertion_offset;
                    assert(insertion_offset >= 0);
                }
            }

            // First, insert clone all instructions, and insert them into the
            // basic block at the very beginning

            // build ordered vector of cloned instructions
            // build map from original vector to cloned vector
            std::vector<Instruction *> cloned_instrs = {};
            std::map<Instruction *, Instruction *> original_to_clone_map = {};
            std::map<Instruction *, Instruction *> clone_to_original_map = {};
            for (Instruction *instr : final_instrs_vec) {
                Instruction *cloned_instr = instr->clone();
                cloned_instrs.push_back(cloned_instr);
                original_to_clone_map[instr] = cloned_instr;
                clone_to_original_map[cloned_instr] = instr;
            }

            // Grab first instruction to build before at.
            Instruction *first_instr = NULL;
            for (auto &I : B) {
                first_instr = dyn_cast<Instruction>(&I);
                assert(first_instr != NULL);
                break;
            }
            IRBuilder<> builder(first_instr);
            builder.SetInsertPoint(&B);

            for (Instruction *cloned_instr : cloned_instrs) {
                // set insert point to be before beginning if inserting phi
                // instruction
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(first_instr);
                }
                builder.Insert(cloned_instr);
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(&B);
                }
                // The cloned instruction has arguments pointing backwards to
                // prior original instructions. Some of these prior instructions
                // themselves will themselves be cloned. We need to replace the
                // prior original instructions with clones instructions
                int num_operands = cloned_instr->getNumOperands();
                for (int i = 0; i < num_operands; i++) {
                    Value *clone_operand = cloned_instr->getOperand(i);
                    Instruction *clone_operand_instr =
                        dyn_cast<Instruction>(clone_operand);
                    if (clone_operand_instr != NULL) {
                        if (original_to_clone_map.count(clone_operand_instr) >
                            0) {
                            Instruction *replacement_operand =
                                original_to_clone_map[clone_operand_instr];
                            Value *replacement_value =
                                dyn_cast<Value>(replacement_operand);
                            assert(replacement_value != NULL);
                            cloned_instr->setOperand(i, replacement_value);
                        }
                    } else {
                        Instruction *original_instr =
                            clone_to_original_map[cloned_instr];
                        cloned_instr->setOperand(i,
                                                 original_instr->getOperand(i));
                    }
                }

                // Furthermore, we need to change all uses of the original
                // instruction to be the new cloned instruction
                Instruction *original_instr =
                    clone_to_original_map[cloned_instr];
                if (Value *original_val = dyn_cast<Value>(original_instr)) {
                    Value *cloned_val = dyn_cast<Value>(cloned_instr);
                    assert(cloned_val != NULL);
                    original_val->replaceAllUsesWith(cloned_val);
                }
            }

            // Finally, delete all the original instructions in the basic block
            // Do this in reverse order.
            std::reverse(all_instrs.begin(), all_instrs.end());
            for (Instruction *instr : all_instrs) {
                instr->eraseFromParent();
            }
        }
    }

    /**
     * Move Stores Back As Far As Possible in the LLVM IR
     */
    void rewrite_stores(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();
        for (auto &B : F) {
            // Grab all instructions
            std::vector<Instruction *> all_instrs = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);
                all_instrs.push_back(instr);
            }

            // Perform Pushing Back of Store Instructions
            std::vector<Instruction *> final_instrs_vec = {};
            for (BasicBlock::reverse_iterator iter = B.rbegin();
                 iter != B.rend(); ++iter) {
                Instruction *instr = &(*iter);
                assert(instr != NULL);

                // Place any non-Load Instructions at the end of the list of
                // instructions
                if (!(isa<StoreInst>(instr) || isa<GEPOperator>(instr))) {
                    final_instrs_vec.push_back(instr);
                    continue;
                }

                // Handle Load Instructions
                int insertion_offset = final_instrs_vec.size();
                while (true) {
                    Instruction *store_instr = instr;

                    // If there is no prior instruction, push back at current
                    // offset, and stop.
                    if (insertion_offset - 1 < 0) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            store_instr);
                        break;
                    }

                    // If the prior instruction is a terminator, do not push the
                    // current instruction back
                    Instruction *prior_instr =
                        final_instrs_vec[insertion_offset - 1];
                    if (prior_instr->isTerminator()) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            store_instr);
                        break;
                    }

                    // If the prior Instruction is a call inst, do not push the
                    // current instruction back
                    // A call instruciton could have side effects to memory
                    // In addition, a call could be to @llvm.memset.p0i8.i64(i8*
                    // nonnull align 16 dereferenceable(40) %2, i8 0, i64 40, i1
                    // false) or @memset_pattern16(i8* nonnull %2, i8* bitcast
                    // ([4 x float]* @.memset_pattern to i8*), i64 40) #6 which
                    // require alias analysis as well

                    // TODO: discriminate calls to llvm memset
                    if (isa<CallInst>(prior_instr)) {
                        final_instrs_vec.insert(
                            final_instrs_vec.begin() + insertion_offset,
                            store_instr);
                        break;
                    }

                    // If the prior instruction is used in the store's
                    // arguments, do not push it back
                    // int num_operands = store_instr->uses();
                    bool break_while = false;
                    // https://stackoverflow.com/questions/35370195/llvm-difference-between-uses-and-user-in-instruction-or-value-classes
                    for (auto U : store_instr->users()) {
                        if (auto use_instr = dyn_cast<Instruction>(U)) {
                            for (Instruction *older_instr : final_instrs_vec) {
                                if (use_instr == older_instr) {
                                    final_instrs_vec.insert(
                                        final_instrs_vec.begin() +
                                            insertion_offset,
                                        store_instr);
                                    break_while = true;
                                    break;
                                }
                            }
                        }
                    }

                    if (break_while) {
                        break;
                    }

                    // If the prior instruction alias with the store
                    // instruction, do not push the store back
                    if (prior_instr->mayReadOrWriteMemory()) {
                        Value *prior_addr = NULL;
                        if (isa<LoadInst>(prior_instr)) {
                            prior_addr = prior_instr->getOperand(0);
                        } else if (isa<StoreInst>(prior_instr)) {
                            prior_addr = prior_instr->getOperand(1);
                        } else {
                            throw "Unmatched Instruction Type";
                        }
                        Value *store_addr = store_instr->getOperand(1);
                        if (!AA->isNoAlias(
                                store_addr,
                                LocationSize::precise(
                                    store_addr->getType()
                                        ->getPrimitiveSizeInBits()),
                                prior_addr,
                                LocationSize::precise(
                                    prior_addr->getType()
                                        ->getPrimitiveSizeInBits())) ||
                            AA->isMustAlias(store_addr, prior_addr)) {
                            final_instrs_vec.insert(
                                final_instrs_vec.begin() + insertion_offset,
                                store_instr);
                            break;
                        }
                    }

                    // if (isa_gather_instruction(prior_instr)) {
                    //     std::vector<Value *> gather_addresses =
                    //         get_gather_addresses(prior_instr);
                    //     Value *store_addr = dyn_cast<Value>(store_instr);
                    //     if (isa<LoadInst>(store_instr)) {
                    //         store_addr = dyn_cast<LoadInst>(store_instr)
                    //                          ->getPointerOperand();
                    //     }
                    //     assert(store_addr != NULL);
                    //     bool gather_break = false;
                    //     for (auto gather_address : gather_addresses) {
                    //         if (may_alias(gather_address, store_addr, AA)) {
                    //             gather_break = true;
                    //             break;
                    //         }
                    //     }
                    //     if (gather_break) {
                    //         final_instrs_vec.insert(
                    //             final_instrs_vec.begin() + insertion_offset,
                    //             store_instr);
                    //         break;
                    //     }
                    // }

                    // Otherwise, keep pushing back the str instruction
                    --insertion_offset;
                    assert(insertion_offset >= 0);
                }
            }

            // build ordered vector of cloned instructions
            // build map from original vector to cloned vector
            std::reverse(final_instrs_vec.begin(), final_instrs_vec.end());
            std::vector<Instruction *> cloned_instrs = {};
            std::map<Instruction *, Instruction *> original_to_clone_map = {};
            std::map<Instruction *, Instruction *> clone_to_original_map = {};
            for (Instruction *instr : final_instrs_vec) {
                Instruction *cloned_instr = instr->clone();
                cloned_instrs.push_back(cloned_instr);
                original_to_clone_map[instr] = cloned_instr;
                clone_to_original_map[cloned_instr] = instr;
            }

            // Grab first instruction to build before at.
            Instruction *first_instr = NULL;
            for (auto &I : B) {
                first_instr = dyn_cast<Instruction>(&I);
                assert(first_instr != NULL);
                break;
            }
            IRBuilder<> builder(first_instr);
            builder.SetInsertPoint(&B);

            for (Instruction *cloned_instr : cloned_instrs) {
                // set insert point to be before beginning if inserting phi
                // instruction
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(first_instr);
                }
                builder.Insert(cloned_instr);
                if (isa<PHINode>(cloned_instr)) {
                    builder.SetInsertPoint(&B);
                }

                // The cloned instruction has arguments pointing backwards to
                // prior original instructions. Some of these prior instructions
                // themselves will themselves be cloned. We need to replace the
                // prior original instructions with clones instructions
                int num_operands = cloned_instr->getNumOperands();
                for (int i = 0; i < num_operands; i++) {
                    Value *clone_operand = cloned_instr->getOperand(i);
                    Instruction *clone_operand_instr =
                        dyn_cast<Instruction>(clone_operand);
                    if (clone_operand_instr != NULL) {
                        if (original_to_clone_map.count(clone_operand_instr) >
                            0) {
                            Instruction *replacement_operand =
                                original_to_clone_map[clone_operand_instr];
                            Value *replacement_value =
                                dyn_cast<Value>(replacement_operand);
                            assert(replacement_value != NULL);
                            cloned_instr->setOperand(i, replacement_value);
                        }
                    } else {
                        Instruction *original_instr =
                            clone_to_original_map[cloned_instr];
                        cloned_instr->setOperand(i,
                                                 original_instr->getOperand(i));
                    }
                }

                // Furthermore, we need to change all uses of the original
                // instruction to be the new cloned instruction
                Instruction *original_instr =
                    clone_to_original_map[cloned_instr];
                if (Value *original_val = dyn_cast<Value>(original_instr)) {
                    Value *cloned_val = dyn_cast<Value>(cloned_instr);
                    assert(cloned_val != NULL);
                    original_val->replaceAllUsesWith(cloned_val);
                }
            }

            // Finally, delete all the original instructions in the basic block
            // Do this in reverse order.
            std::reverse(all_instrs.begin(), all_instrs.end());
            for (Instruction *instr : all_instrs) {
                instr->eraseFromParent();
            }
        }
    }

    std::vector<Instruction *> func_to_vec(Function &F) {
        std::vector<Instruction *> result = {};
        for (auto &B : F) {
            for (auto &I : B) {
                result.push_back(&I);
            }
        }
        return result;
    }

    virtual bool runOnFunction(Function &F) override {
        /**
         * In this pass, we walk backwards finding the first load from the
         * bottom, and push it up as far as we can. We continue upwards,
         * pushing loads upward.
         */
        if (F.getName() == MAIN_FUNCTION_NAME ||
            (F.getName().size() > NO_OPT_PREFIX.size() &&
             F.getName().substr(0, NO_OPT_PREFIX.size()) == NO_OPT_PREFIX)) {
            return false;
        }
        // Might want to iterate to convergence
        const int N_ITER = 1;
        for (int i = 0; i < N_ITER; i++) {
            std::vector<Instruction *> original_func = func_to_vec(F);
            // move_forward_gep_instrs(F);
            // move_forward_insert_element_instrs(F);
            // move_forward_bitcast_instrs(F);
            // move_forward_gather_instrs(F);
            rewrite_loads(F);
            rewrite_stores(F);
            std::vector<Instruction *> rewritten_func = func_to_vec(F);
            if (original_func == rewritten_func) {
                break;
            }
        }

        return true;
    }
};
}  // namespace

char LoadStoreMovementPass::ID = 0;

// Automatically enable the pass.
// http://adriansampson.net/blog/clangpass.html
static void registerLoadStoreMovementPass(const PassManagerBuilder &,
                                          legacy::PassManagerBase &PM) {
    PM.add(new LoadStoreMovementPass());
}

static RegisterPass<LoadStoreMovementPass> X("lsmovement",
                                             "Load Store Movement Pass",
                                             false /* Only looks at CFG */,
                                             true /* Analysis Pass */);

static RegisterStandardPasses RegisterMyPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerLoadStoreMovementPass);