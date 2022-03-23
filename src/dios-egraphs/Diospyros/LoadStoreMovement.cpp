#include <assert.h>

#include <map>
#include <utility>
#include <vector>

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
using namespace llvm;

namespace {
struct LoadStoreMovementPass : public FunctionPass {
    static char ID;
    LoadStoreMovementPass() : FunctionPass(ID) {}

    void getAnalysisUsage(AnalysisUsage &AU) const override {
        AU.addRequired<AAResultsWrapperPass>();
    }

    void rewrite_stores(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();
        for (auto &B : F) {
            bool has_float = false;
            for (auto &I : B) {
                if (I.getType()->isFloatTy()) {
                    has_float = true;
                }
            }
            if (!has_float) {
                continue;
            }
            // We also skip over all basic blocks without stores
            bool has_store = false;
            for (auto &I : B) {
                if (auto *op = dyn_cast<StoreInst>(&I)) {
                    has_store = true;
                }
            }
            if (!has_store) {
                continue;
            }

            std::vector<Instruction *> reversed_instructions = {};
            std::vector<Instruction *> all_instructions = {};
            int head_pointer =
                -1;  // points to head location in all_instructions
            Instruction *first_instr = NULL;
            for (BasicBlock::reverse_iterator iter = B.rbegin();
                 iter != B.rend(); ++iter) {
                Instruction *I = &(*iter);
                first_instr = I;
                if (auto *store_op = dyn_cast<StoreInst>(I)) {
                    if (head_pointer < 0) {
                        reversed_instructions.push_back(I);
                    } else {
                        int current_counter = head_pointer;
                        while (current_counter >= 0) {
                            Instruction *curr_instr =
                                reversed_instructions[current_counter];
                            if (curr_instr->isTerminator()) {
                                ++current_counter;
                                break;
                            } else if (auto *other_store_op =
                                           dyn_cast<StoreInst>(curr_instr)) {
                                if (AA->isNoAlias(
                                        store_op->getOperand(1),
                                        other_store_op->getOperand(1))) {
                                    --current_counter;
                                } else {
                                    break;
                                }
                            } else if (auto *load_op =
                                           dyn_cast<LoadInst>(curr_instr)) {
                                if (AA->isNoAlias(store_op->getOperand(1),
                                                  load_op->getOperand(0))) {
                                    --current_counter;
                                } else {
                                    break;
                                }
                            } else {
                                --current_counter;
                            }
                        }
                        // Do the insertion
                        reversed_instructions.insert(
                            reversed_instructions.begin() + current_counter, I);
                    }
                } else {
                    reversed_instructions.push_back(I);
                }
                ++head_pointer;
                all_instructions.push_back(I);
            }
            if (first_instr == NULL) {
                assert(false);
            }
            IRBuilder<> builder(first_instr);
            // we add the instructions at the end
            builder.SetInsertPoint(&B);
            // here we are going to add back our instructions
            std::reverse(reversed_instructions.begin(),
                         reversed_instructions.end());
            BasicBlock::InstListType &bb_instrs = B.getInstList();
            std::map<Instruction *, Instruction *> original_to_clone_map = {};
            for (auto &I : reversed_instructions) {
                // we clone the original instruciton, then insert into builder
                Instruction *cloned_instr = I->clone();
                // when adding, need to take caution about the users
                original_to_clone_map[I] = cloned_instr;
                for (unsigned int i = 0; i < I->getNumOperands(); i++) {
                    Value *operand = I->getOperand(i);
                    Instruction *operand_instr = dyn_cast<Instruction>(operand);
                    if (original_to_clone_map.find(operand_instr) !=
                        original_to_clone_map.end()) {
                        Instruction *clone_instr =
                            original_to_clone_map[operand_instr];
                        Value *clone_value = dyn_cast<Value>(clone_instr);
                        cloned_instr->setOperand(i, clone_value);
                    } else {
                        cloned_instr->setOperand(i, operand);
                    }
                }
                bb_instrs.push_back(cloned_instr);
                for (auto &U : I->uses()) {
                    User *user = U.getUser();
                    user->setOperand(U.getOperandNo(), cloned_instr);
                }
            }
            // here we need to delete all original instructions, going forwards
            // with no reversal as they are in reversed order
            for (auto &I : all_instructions) {
                I->eraseFromParent();
            }
        }
    }

    void rewrite_loads(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();
        std::map<Instruction *, Instruction *> original_to_clone_map = {};
        std::vector<Instruction *> all_instructions = {};
        for (auto &B : F) {
            std::vector<Instruction *> instructions = {};

            int head_pointer =
                -1;  // points to head location in all_instructions
            Instruction *first_instr = NULL;
            for (auto &I : B) {
                first_instr = &I;
                if (auto *load_op = dyn_cast<LoadInst>(&I)) {
                    if (isa<Argument>(load_op->getOperand(0))) {
                        if (head_pointer < 0) {
                            instructions.push_back(&I);
                        } else {
                            int current_counter = head_pointer;
                            while (current_counter > 0) {
                                Instruction *curr_instr =
                                    instructions[current_counter];
                                if (auto *op = dyn_cast<AllocaInst>(&I)) {
                                    ++current_counter;
                                    break;
                                }
                                // else if (auto *other_load_op =
                                //                dyn_cast<LoadInst>(curr_instr))
                                //                {
                                //     if (AA->isNoAlias(
                                //             other_load_op->getOperand(0),
                                //             load_op->getOperand(0))) {
                                //         --current_counter;
                                //     } else {
                                //         break;
                                //     }
                                // }
                                else if (auto *store_op =
                                             dyn_cast<StoreInst>(curr_instr)) {
                                    if (AA->isNoAlias(store_op->getOperand(1),
                                                      load_op->getOperand(0))) {
                                        --current_counter;
                                    } else {
                                        break;
                                    }
                                } else {
                                    --current_counter;
                                }
                            }
                            // Do the insertion
                            assert(current_counter >= 0);
                            instructions.insert(
                                instructions.begin() + current_counter, &I);
                        }
                    } else {
                        instructions.push_back(&I);
                    }
                } else {
                    instructions.push_back(&I);
                }
                ++head_pointer;
                all_instructions.push_back(&I);
            }
            if (first_instr == NULL) {
                assert(false);
            }
            IRBuilder<> builder(first_instr);
            // we add the instructions at the end
            builder.SetInsertPoint(&B);
            // here we are going to add back our instructions
            BasicBlock::InstListType &bb_instrs = B.getInstList();
            for (auto &I : instructions) {
                // we clone the original instruciton, then insert into builder
                Instruction *cloned_instr = I->clone();
                // when adding, need to take caution about the users
                original_to_clone_map[I] = cloned_instr;
                for (unsigned int i = 0; i < I->getNumOperands(); i++) {
                    Value *operand = I->getOperand(i);
                    Instruction *operand_instr = dyn_cast<Instruction>(operand);
                    if (operand_instr != NULL) {
                        if (original_to_clone_map.find(operand_instr) !=
                            original_to_clone_map.end()) {
                            Instruction *clone_instr =
                                original_to_clone_map[operand_instr];
                            Value *clone_value = dyn_cast<Value>(clone_instr);
                            cloned_instr->setOperand(i, clone_value);
                        } else {
                            cloned_instr->setOperand(i, operand);
                        }
                    }
                }
                bb_instrs.push_back(cloned_instr);
                Instruction *instr = &(*I);
                for (auto &U : instr->uses()) {
                    User *user = U.getUser();
                    user->setOperand(U.getOperandNo(), cloned_instr);
                }
            }
        }
        // here we need to delete all original instructions, going
        // forwards with no reversal as they are in reversed order
        std::reverse(all_instructions.begin(), all_instructions.end());
        for (auto &I : all_instructions) {
            I->eraseFromParent();
        }
    }

    virtual bool runOnFunction(Function &F) override {
        /**
         * In this pass, we walk backwards finding the first load from the
         * bottom, and push it up as far as we can. We continue upwards,
         * pushing loads upward.
         *
         * We gr
         */
        if (F.getName() == "main" ||
            (F.getName().size() > 7 && F.getName().substr(0, 7) == "no_opt_")) {
            return false;
        }
        rewrite_stores(F);
        rewrite_loads(F);

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
static RegisterStandardPasses RegisterMyPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerLoadStoreMovementPass);