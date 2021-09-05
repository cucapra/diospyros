#include <assert.h>
#include <llvm-c/Core.h>

#include <set>
#include <stdexcept>
#include <string>
#include <vector>

#include "llvm/IR/Argument.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/User.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

extern "C" void optimize(LLVMModuleRef mod, LLVMBuilderRef builder,
                         LLVMValueRef const *bb, std::size_t size);

const string ARRAY_NAME = "no-array-name";
const string TEMP_NAME = "no-temp-name";

int FRESH_INT_COUNTER = 0;
int FRESH_ARRAY_COUNTER = 0;
int FRESH_TEMP_COUNTER = 0;

int gen_fresh_index() {
    --FRESH_INT_COUNTER;
    return FRESH_INT_COUNTER;
}

const char *gen_fresh_array() {
    ++FRESH_ARRAY_COUNTER;
    string array_str = ARRAY_NAME + to_string(FRESH_ARRAY_COUNTER);
    char *cstr = new char[array_str.length() + 1];
    std::strcpy(cstr, array_str.c_str());
    return cstr;
}

const char *gen_fresh_temp() {
    ++FRESH_TEMP_COUNTER;
    string temp_str = TEMP_NAME + to_string(FRESH_TEMP_COUNTER);
    char *cstr = new char[temp_str.length() + 1];
    std::strcpy(cstr, temp_str.c_str());
    return cstr;
}

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
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<Constant>(unwrapped);
}

extern "C" bool isa_gep(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<GEPOperator>(unwrapped);
}

extern "C" bool isa_load(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<LoadInst>(unwrapped);
}

extern "C" bool isa_store(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<StoreInst>(unwrapped);
}

extern "C" float get_constant_float(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *num = dyn_cast<ConstantFP>(v)) {
        return num->getValue().convertToFloat();
    }
    return -1;
}

bool dfs_llvm_instrs(User *current_instr, User *match_instr) {
    if (current_instr == NULL) {
        return false;
    }
    if (current_instr == match_instr) {
        return true;
    }
    if (isa<AllocaInst>(current_instr) || isa<Argument>(current_instr) ||
        isa<Constant>(current_instr)) {
        return false;
    }
    bool result = false;
    // special case for loads: check if prev is store and continue
    // in fact this test will VERY LIKELY lead to errors on some well-crafted
    // test cases if LLVM decides to load and store values to the same locations
    // multiple times, this could mess up the final result badly, if the some of
    // the previous values need to be stored back before revectorizing after.
    if (auto load_instr = dyn_cast<LoadInst>(current_instr)) {
        if (auto prev_node = load_instr->getPrevNode()) {
            if (auto store_instr = dyn_cast<StoreInst>(prev_node)) {
                Value *load_pointer_operand = load_instr->getPointerOperand();
                Value *store_pointer_operand = store_instr->getPointerOperand();
                if (load_pointer_operand == store_pointer_operand) {
                    Value *value_operand = store_instr->getValueOperand();

                    auto user_cast = dyn_cast<User>(value_operand);
                    result |= dfs_llvm_instrs(user_cast, match_instr);
                    user_cast = dyn_cast<User>(store_pointer_operand);
                    result |= dfs_llvm_instrs(user_cast, match_instr);
                    return result;
                }
            }
        }
        return false;
    }
    // remainder of instructions, besides stores
    for (auto i = 0; i < current_instr->getNumOperands(); i++) {
        Value *operand = current_instr->getOperand(i);
        auto user_cast = dyn_cast<User>(operand);
        if (user_cast == NULL) {
            throw std::invalid_argument("Could not convert Value * to User *");
        }
        result |= dfs_llvm_instrs(user_cast, match_instr);
    }
    return result;
}

extern "C" bool dfs_llvm_value_ref(LLVMValueRef current_instr,
                                   LLVMValueRef match_instr) {
    auto current_user = dyn_cast<User>(unwrap(current_instr));
    auto match_user = dyn_cast<User>(unwrap(match_instr));
    if (current_user == NULL || match_user == NULL) {
        throw std::invalid_argument("Could not convert Value * to User *");
    }
    return dfs_llvm_instrs(current_user, match_user);
}

namespace {
struct DiospyrosPass : public FunctionPass {
    static char ID;
    DiospyrosPass() : FunctionPass(ID) {}

    virtual bool runOnFunction(Function &F) {
        bool has_changes = false;
        for (auto &B : F) {
            // uncomment to see basic block: good for debugging.
            // errs() << B << "\n";

            // We need to identify sequences of stores and loads to the same
            // location and split them up into separate vectorizations
            // We walk over a basic block, and identify binary operators, loads,
            // stores and calls.
            // When a call is identified, we split up vectorization.
            // For each store, we put it in a set. If a load uses a Value in the
            // store clear the set, and split up vectorization.
            // Otherwise, add binary operators to the current vectorizxation
            // vector.
            // Order matters in each vector; we push back in the same order
            // binary operators are found.
            std::vector<std::vector<LLVMValueRef>> vectorization_accumulator;
            std::vector<LLVMValueRef> inner_vector = {};
            std::set<Value *> store_locations;
            for (auto &I : B) {
                if (auto *op = dyn_cast<BinaryOperator>(&I)) {
                    // only include floating point operations
                    if (op->getType()->isFloatTy()) {
                        inner_vector.push_back(wrap(op));
                    }
                } else if (auto *op = dyn_cast<StoreInst>(&I)) {
                    // get the store location (pointer)
                    Value *store_loc = op->getOperand(1);
                    store_locations.insert(store_loc);
                } else if (auto *op = dyn_cast<LoadInst>(&I)) {
                    Value *load_loc = op->getOperand(0);
                    if (store_locations.find(load_loc) !=
                        store_locations.end()) {
                        store_locations.clear();
                        if (!inner_vector.empty()) {
                            vectorization_accumulator.push_back(inner_vector);
                        }
                        inner_vector = {};
                    }
                } else if (auto *op = dyn_cast<CallInst>(&I)) {
                    store_locations.clear();
                    if (!inner_vector.empty()) {
                        vectorization_accumulator.push_back(inner_vector);
                    }
                    inner_vector = {};
                }
            }
            vectorization_accumulator.push_back(inner_vector);

            for (auto vec : vectorization_accumulator) {
                if (not vec.empty()) {
                    has_changes = has_changes || true;
                    Value *last_val = unwrap(vec.back());
                    IRBuilder<> builder(dyn_cast<Instruction>(last_val));
                    Instruction *last_instr = dyn_cast<Instruction>(last_val);
                    // figure out where next store is located after the last
                    // binary operation
                    while (not isa<StoreInst>(last_instr)) {
                        Instruction *next_instr =
                            last_instr->getNextNonDebugInstruction();
                        if (next_instr != NULL) {
                            last_instr = next_instr;
                            builder.SetInsertPoint(&B,
                                                   ++builder.GetInsertPoint());
                        } else {
                            // This is a problematic situation: we depend on
                            // knowing the stored address to write back an
                            // extract element to. Should the code go here, the
                            // llvm pass will be incorrect.
                            assert(false);
                        }
                    }
                    builder.SetInsertPoint(&B, ++builder.GetInsertPoint());

                    Module *mod = F.getParent();

                    optimize(wrap(mod), wrap(&builder), vec.data(), vec.size());
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
static RegisterStandardPasses RegisterMyPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerDiospyrosPass);
