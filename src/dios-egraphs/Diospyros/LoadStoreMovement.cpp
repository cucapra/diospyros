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

    void rewrite_stores(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();
        for (auto &B : F) {

            // Perform Pushing Back of Store Instructions
            std::vector<Instruction *> final_instrs_list = {};
            for (auto &I : B) {
                Instruction *instr = dyn_cast<Instruction>(&I);
                assert(instr != NULL);
                
                // Place any non-Store Instructions at the end of the list of instructions
                if (!isa<StoreInst>(instr)) {
                    final_instrs_list.push_back(instr);
                    continue;
                }

                // Handle Store Instructions
                int insertion_offset = final_instrs_list.size();
                while (true) {
                    Instruction *store_instr = instr;
                    // If there is no prior instruction, push back at current offset, and stop.
                    if (insertion_offset - 1 < 0) {
                        final_instrs_list.insert(final_instrs_list.begin() + insertion_offset, store_instr);
                        break;
                    }
                    Instruction *prior_instr = final_instrs_list[insertion_offset - 1];
                    // If the prior instruction is used in the store's
                    // arguments, do not push it back
                    int num_operands = store_instr->getNumOperands();
                    bool break_while = false;
                    for (int i = 0; i < num_operands; i++) {
                        Value *store_operand = store_instr->getOperand(i);
                        Instruction *store_operand_instr =
                            dyn_cast<Instruction>(store_operand);
                        assert(store_operand_instr != NULL);
                        if (store_operand_instr == prior_instr) {
                            final_instrs_list.insert(final_instrs_list.begin() + insertion_offset, store_instr);
                            break_while = true;
                            break;
                        }
                    } 
                    if (break_while) {
                        break;
                    }
                    // If the prior instruction alias with the store
                    // instruction, do not push it back
                    if (!AA->isNoAlias(store_instr, prior_instr)) {
                        final_instrs_list.insert(final_instrs_list.begin() + insertion_offset, store_instr);
                        break;
                    }
                    // Otherwise, keep pushing back the store instruction
                    --insertion_offset;
                }
                
                // TODO
                // First, insert clone all instructions, and insert them into the basic block at the very beginning
                // Next,  
                // Then, 
                // Finally, delete all the original instructions in the basic block
                
            }
        }
    }

    void rewrite_loads(Function &F) {
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();
        for (auto &B : F) {
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