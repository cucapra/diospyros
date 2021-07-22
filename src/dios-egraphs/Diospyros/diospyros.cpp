#include <llvm-c/Core.h>

#include <vector>

#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

extern "C" LLVMValueRef optimize(LLVMValueRef const *bb, std::size_t size);

extern "C" const char *llvm_name(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *gep = dyn_cast<GEPOperator>(v)) {
        auto name = gep->getOperand(0)->getName();
        return name.data();
    }
    return "";
}

extern "C" int llvm_index(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *num = dyn_cast<GEPOperator>(v)) {
        if (auto *i = dyn_cast<ConstantInt>(num->getOperand(2))) {
            return i->getSExtValue();
        }
    }
    return -1;
}

extern "C" LLVMValueRef llvm_operand(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *gep = dyn_cast<GEPOperator>(v)) {
        auto pointer_operand = gep->getPointerOperand();
        return wrap(pointer_operand);
    }
    // bad case - should not return NULL, but if it does, need to handle
    return NULL;
}

// clang -Xclang -load -Xclang build/skeleton/libSkeletonPass.* -Xclang -load
// -Xclang target/debug/libllvm_pass_skeleton.so -emit-llvm -S -o - a.c

namespace {
struct DiospyrosPass : public FunctionPass {
    static char ID;
    DiospyrosPass() : FunctionPass(ID) {}

    virtual bool runOnFunction(Function &F) {
        for (auto &B : F) {
            std::vector<LLVMValueRef> vec;
            for (auto &I : B) {
                if (auto *op = dyn_cast<BinaryOperator>(&I)) {
                    // errs() << *op << "\n";
                    vec.push_back(wrap(op));
                }
            }
            optimize(vec.data(), vec.size());
        }
        return false;
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
static RegisterStandardPasses RegisterMyPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerDiospyrosPass);
