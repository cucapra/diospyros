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

namespace {
struct LoadStoreMovementPass : public FunctionPass {
    static char ID;
    LoadStoreMovementPass() : FunctionPass(ID) {}

    void getAnalysisUsage(AnalysisUsage &AU) const override {
        AU.addRequired<AAResultsWrapperPass>();
        AU.addRequired<BasicAAWrapperPass>();
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

    // Move All Bitcasts as early as possible, avoiding moving instructions
    // by removing dependencies. The idea behind this is to move bitcasts
    // out of the way so that vectorization can occur properlu.
    void rewrite_bitcasts(Function &F) {
        for (auto &B : F) {
            for (auto &I : B) {
            }
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
        // Might want to iterate to convergence
        // first move bitcasts
        rewrite_loads(F);
        rewrite_stores(F);

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