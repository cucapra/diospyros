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

const std::string MAIN_FUNCTION_NAME = "main";
const std::string NO_OPT_PREFIX = "no_opt_";

namespace {
struct LoadStoreMovementPass : public FunctionPass {
    static char ID;
    LoadStoreMovementPass() : FunctionPass(ID) {}

    void getAnalysisUsage(AnalysisUsage &AU) const override {
        AU.addRequired<AAResultsWrapperPass>();
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
                
                // Place any non-Load Instructions at the end of the list of instructions
                if (!isa<LoadInst>(instr)) {
                    final_instrs_vec.push_back(instr);
                    continue;
                }

                // Handle Load Instructions
                int insertion_offset = final_instrs_vec.size();
                while (true) {
                    Instruction *load_instr = instr;
                    // If there is no prior instruction, push back at current offset, and stop.
                    if (insertion_offset - 1 < 0) {
                        final_instrs_vec.insert(final_instrs_vec.begin() + insertion_offset, load_instr);
                        break;
                    }
                    Instruction *prior_instr = final_instrs_vec[insertion_offset - 1];
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
                                final_instrs_vec.insert(final_instrs_vec.begin() + insertion_offset, load_instr);
                                break_while = true;
                                break;
                            }
                        }
                    } 
                    if (break_while) {
                        break;
                    }
                    // If the prior instruction alias with the load
                    // instruction, do not push it back
                    if (!AA->isNoAlias(load_instr, prior_instr)) {
                        final_instrs_vec.insert(final_instrs_vec.begin() + insertion_offset, load_instr);
                        break;
                    }
                    // Otherwise, keep pushing back the load instruction
                    --insertion_offset;
                }
            }
                
            // TODO
            // First, insert clone all instructions, and insert them into the basic block at the very beginning

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
                // The cloned instruction has arguments pointing backwards to prior original instructions
                // Some of these prior instructions themselves will themselves be cloned.
                // We need to replace the prior original instructions with clones instructions
                int num_operands = cloned_instr->getNumOperands();
                for (int i = 0; i < num_operands; i++) {
                    Value *clone_operand = cloned_instr->getOperand(i);
                    Instruction *clone_operand_instr = dyn_cast<Instruction>(clone_operand);
                    if (clone_operand_instr != NULL) {
                        if (original_to_clone_map.count(clone_operand_instr) > 0) {
                            Instruction *replacement_operand = original_to_clone_map[clone_operand_instr];
                            Value *replacement_value = dyn_cast<Value>(replacement_operand);
                            assert(replacement_value != NULL);
                            cloned_instr->setOperand(i, replacement_value);
                        }
                    } else {
                        Instruction *original_instr = clone_to_original_map[cloned_instr];
                        cloned_instr->setOperand(i, original_instr->getOperand(i));
                    }
                }

                builder.Insert(cloned_instr);
                
                // Furthermore, we need to change all uses of the original instruction to be the new cloned instruction
                Instruction *original_instr = clone_to_original_map[cloned_instr];
                for (auto &U : original_instr->uses()) {
                    User *user = U.getUser();
                    user->setOperand(U.getOperandNo(), cloned_instr);
                }

                // Finish by inserting cloned instruction
                // builder.Insert(cloned_instr);
            }

            // To be safe, we also check if any of the new cloned instructions uses an original instruction, and if so, raise an error
            // for (Instruction *cloned_instr : cloned_instrs) {
            //     int num_operands = cloned_instr->getNumOperands();
            //     for (int i = 0; i < num_operands; i++) {
            //         Value *operand =  cloned_instr->getOperand(i);
            //     }
            // }

            // for (Instruction *original_instr : all_instrs) {
            //     Instruction *cloned_instr = original_to_clone_map[original_instr];
            //     for (auto &U : original_instr->uses()) {
            //         User *user = U.getUser();
            //         user->setOperand(U.getOperandNo(), cloned_instr);
            //     }
            // }
            
            // Finally, delete all the original instructions in the basic block
            // Do this in reverse order.
            // std::reverse(all_instrs.begin(), all_instrs.end());
            // for (Instruction *instr : all_instrs) {
            //     instr->eraseFromParent();
            // }
        }
    }

    /**
     * Move Stores Back As Far As Possible in the LLVM IR
    */
    void rewrite_stores(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();
        for (auto &B : F) {
            // Collect all instructions

            // Collect all stores
            // If a store 
        }
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
        rewrite_loads(F);
        // rewrite_stores(F);

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