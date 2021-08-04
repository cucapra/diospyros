#include <llvm-c/Core.h>

#include <string>
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

const char *NAME_FRESH_PREFIX = "no-array-name";

int FRESH_INT_COUNTER = 0;

extern "C" void optimize(LLVMModuleRef mod, LLVMBuilderRef builder,
                         LLVMValueRef const *bb, std::size_t size);

const char *gen_fresh_name() { return NAME_FRESH_PREFIX; }

int gen_fresh_index() {
    --FRESH_INT_COUNTER;
    return FRESH_INT_COUNTER;
}

extern "C" const char *llvm_name(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *gep = dyn_cast<GEPOperator>(v)) {
        auto name = gep->getOperand(0)->getName();
        if (name.empty()) {
            return gen_fresh_name();
        }
        return name.data();
    } else if (auto *load = dyn_cast<LoadInst>(v)) {
        auto name = load->getOperand(0)->getName();
        return name.data();
    }
    return gen_fresh_name();
}

extern "C" int llvm_index(LLVMValueRef val, int index) {
    Value *v = unwrap(val);
    if (auto *num = dyn_cast<GEPOperator>(v)) {
        if (auto *i = dyn_cast<ConstantInt>(num->getOperand(index))) {
            return i->getSExtValue();
        }
    }
    return gen_fresh_index();
}

extern "C" bool isa_constant(LLVMValueRef val) {
    return isa<Constant>(unwrap(val));
}

extern "C" bool isa_gep(LLVMValueRef val) {
    return isa<GEPOperator>(unwrap(val));
}

extern "C" bool isa_load(LLVMValueRef val) {
    return isa<LoadInst>(unwrap(val));
}

extern "C" float get_constant_float(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *num = dyn_cast<ConstantFP>(v)) {
        return num->getValue().convertToFloat();
    }
    return -1;
}

bool check_binop_is_float(BinaryOperator *op) {
    auto *lhs = op->getOperand(0);
    auto *rhs = op->getOperand(1);
    return lhs->getType()->isFloatTy() && rhs->getType()->isFloatTy();
}

namespace {
struct DiospyrosPass : public FunctionPass {
    static char ID;
    DiospyrosPass() : FunctionPass(ID) {}

    virtual bool runOnFunction(Function &F) {
        bool has_changes = false;
        for (auto &B : F) {
            std::vector<LLVMValueRef> vec;
            for (auto &I : B) {
                if (auto *op = dyn_cast<BinaryOperator>(&I)) {
                    // only include floating point operations
                    if (check_binop_is_float(op)) {
                        vec.push_back(wrap(op));
                    }
                }
            }

            if (not vec.empty()) {
                has_changes = has_changes || true;
                IRBuilder<> builder(dyn_cast<Instruction>(unwrap(vec.back())));
                // builder.SetInsertPoint(&B, ++++++builder.GetInsertPoint());
                builder.SetInsertPoint(&B, ++builder.GetInsertPoint());

                Module *mod = F.getParent();

                optimize(wrap(mod), wrap(&builder), vec.data(), vec.size());
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
static RegisterStandardPasses RegisterMyPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerDiospyrosPass);
