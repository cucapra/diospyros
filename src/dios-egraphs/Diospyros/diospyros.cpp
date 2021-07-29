#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <llvm-c/Core.h>
#include <vector>

using namespace llvm;
using namespace std;

extern "C" void optimize(LLVMBuilderRef builder, LLVMValueRef const *bb, std::size_t size);

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

namespace {
  struct DiospyrosPass : public FunctionPass {
    static char ID;
    DiospyrosPass() : FunctionPass(ID) {}

    virtual bool runOnFunction(Function &F) {
      for (auto &B : F) {
        std::vector<LLVMValueRef> vec;
        for (auto &I : B) {
          if (auto *op = dyn_cast<BinaryOperator>(&I)) {
            vec.push_back(wrap(op));
          }
        }
        IRBuilder<> builder(dyn_cast<Instruction>(unwrap(vec.back())));
        builder.SetInsertPoint(&B, ++++++builder.GetInsertPoint());

        optimize(wrap(&builder), vec.data(),vec.size());
      }
      return true;
    };
  };
}

char DiospyrosPass::ID = 0;

// Automatically enable the pass.
// http://adriansampson.net/blog/clangpass.html
static void registerDiospyrosPass(const PassManagerBuilder &,
                         legacy::PassManagerBase &PM) {
  PM.add(new DiospyrosPass());
}
static RegisterStandardPasses
  RegisterMyPass(PassManagerBuilder::EP_EarlyAsPossible,
                 registerDiospyrosPass);
