#include <utility>
#include <vector>

#include "llvm/Analysis/AliasAnalysis.h"
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

    virtual bool runOnFunction(Function &F) {
        /**
         * In this pass, we walk backwards finding the first load from the
         * bottom, and push it up as far as we can. We continue upwards, pushing
         * loads upward.
         *
         * We gr
         */
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();

        if (F.getName() == "main") {
            return false;
        }
        StoreInst *store = NULL;
        LoadInst *load = NULL;
        for (auto &B : F) {
            for (auto &I : B) {
                if (auto *op = dyn_cast<StoreInst>(&I)) {
                    store = op;
                } else if (auto *op = dyn_cast<LoadInst>(&I)) {
                    load = op;
                }
            }
        }
        if (store != NULL and load != NULL) {
            errs() << "Analysis Result\n";
            if (AA->isNoAlias(store, load)) {
                errs() << *store << "\n" << *load << "\n";
            }
        }

        // for (auto &B : F) {
        //     std::vector<std::pair<std::vector<Value *>, LoadInst *>>
        //         paired_instrs;
        //     std::vector<Value *> non_load_instrs = {};
        //     for (auto &I : B) {
        //         if (auto *op = dyn_cast<LoadInst>(&I)) {
        //             std::pair<std::vector<Value *>, LoadInst *>
        //                 load_instrs_pair(non_load_instrs, op);
        //             non_load_instrs = {};
        //             paired_instrs.push_back(load_instrs_pair);
        //         } else {
        //             Value *instr = dyn_cast<Value>(&I);
        //             non_load_instrs.push_back(instr);
        //         }
        //     }
        //     for (auto &pair : paired_instrs) {
        //         std::vector<Value *> instrs;
        //         LoadInst *load;
        //         std::tie(instrs, load) = pair;
        //         errs() << "Start run\n";
        //         errs() << *load << "\n";
        //         for (auto &instr : instrs) {
        //             errs() << *instr << "\n";
        //         }
        //     }
        // }
        return false;
    }
    //     // Insert at the point where the instruction `op`
    //     appears. IRBuilder<> builder(op);

    //     // Make a multiply with the same operands as `op`.
    //     Value *lhs = op->getOperand(0);
    //     Value *rhs = op->getOperand(1);
    //     Value *mul = builder.CreateMul(lhs, rhs);

    //     // Everywhere the old instruction was used as an operand,
    //     // use our new multiply instruction instead.
    //     for (auto &U : op->uses()) {
    //         User *user =
    //             U.getUser();  // A User is anything with
    //             operands.
    //         user->setOperand(U.getOperandNo(), mul);
    //     }

    //     // We modified the code.
    //     return true;
    // }
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