#include <assert.h>
#include <llvm-c/Core.h>

#include <set>
#include <stdexcept>
#include <string>
#include <tuple>
#include <vector>

#include "llvm/IR/Argument.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/User.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar/LoopUnrollPass.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

typedef struct VectorPointerSize {
    LLVMValueRef const *vec_pointer;
    std::size_t size;
} VectorPointerSize;

extern "C" VectorPointerSize optimize(LLVMModuleRef mod, LLVMContextRef context,
                                      LLVMBuilderRef builder,
                                      LLVMValueRef const *bb, std::size_t size);

const string ARRAY_NAME = "no-array-name";
const string TEMP_NAME = "no-temp-name";
const string SQRT64_FUNCTION_NAME = "llvm.sqrt.f64";
const string SQRT32_FUNCTION_NAME = "llvm.sqrt.f32";
const int SQRT_OPERATOR = 3;
const int BINARY_OPERATOR = 2;

/**
 * Fresh counters for temps and array generation
 */
int FRESH_INT_COUNTER = 0;
int FRESH_ARRAY_COUNTER = 0;
int FRESH_TEMP_COUNTER = 0;

/**
 * Generates a Fresh Index
 */
int gen_fresh_index() {
    --FRESH_INT_COUNTER;
    return FRESH_INT_COUNTER;
}

/**
 * Generates a fresh name for an array name
 */
const char *gen_fresh_array() {
    ++FRESH_ARRAY_COUNTER;
    string array_str = ARRAY_NAME + to_string(FRESH_ARRAY_COUNTER);
    char *cstr = new char[array_str.length() + 1];
    std::strcpy(cstr, array_str.c_str());
    return cstr;
}

/**
 * Generates a fresh name for a temporary variable that was taken from LLVM
 */
const char *gen_fresh_temp() {
    ++FRESH_TEMP_COUNTER;
    string temp_str = TEMP_NAME + to_string(FRESH_TEMP_COUNTER);
    char *cstr = new char[temp_str.length() + 1];
    std::strcpy(cstr, temp_str.c_str());
    return cstr;
}

/* The following are convenience functions used on the Rust library code. The
reason is that the functionality does not exist in the LLVM-C interface for
Rust, so we must use the C++ LLVM interface to provide the Rust functionality.
*/

/**
 * Finds name of an LLVM Array, if there is one. Otherwise, generates fresh name
 * for array.
 */
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

/**
 * Finds name of an LLVM Array, if there is one. Otherwise, generates fresh name
 * for array.
 */
extern "C" int llvm_index(LLVMValueRef val, int index) {
    Value *v = unwrap(val);
    if (auto *num = dyn_cast<GEPOperator>(v)) {
        if (auto *i = dyn_cast<ConstantInt>(num->getOperand(index))) {
            return i->getSExtValue();
        }
    }
    return gen_fresh_index();
}

/**
 * True iff a value is an LLVM Unary Operation
 */
extern "C" bool isa_unop(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<UnaryOperator>(unwrapped);
}

/**
 * True iff a value is an LLVM Binary Operation
 */
extern "C" bool isa_bop(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<BinaryOperator>(unwrapped);
}

/**
 * True iff a value is an LLVM constant/LLVMValueRef Constant
 */
extern "C" bool isa_constant(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<Constant>(unwrapped);
}

/**
 * True iff a value is an LLVM GEP/LLVMValueRef GEP
 */
extern "C" bool isa_gep(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<GEPOperator>(unwrapped);
}

/**
 * True iff a value is an LLVM Load/LLVMValueRef Load
 */
extern "C" bool isa_load(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<LoadInst>(unwrapped);
}

/**
 * True iff a value is an LLVM Store/LLVMValueRef Store
 */
extern "C" bool isa_store(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<StoreInst>(unwrapped);
}

/**
 * True iff a value is an LLVM Argument/LLVMValueRef Argument
 */
extern "C" bool isa_argument(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<Argument>(unwrapped);
}

/**
 * True iff a value is an LLVM CallInst/LLVMValueRef CallInst
 */
extern "C" bool isa_call(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<CallInst>(unwrapped);
}

/**
 * True iff a value is an LLVM FPTruncInst/LLVMValueRef FPTruncInst
 */
extern "C" bool isa_fptrunc(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<FPTruncInst>(unwrapped);
}

/**
 * True iff a value is an LLVM FPExtInst/LLVMValueRef FPExtInst
 */
extern "C" bool isa_fpext(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<FPExtInst>(unwrapped);
}

/**
 * True iff a value is an LLVM AllocInst/LLVMValueRef AllocInst
 */
extern "C" bool isa_alloca(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<AllocaInst>(unwrapped);
}

/**
 * True iff a value is an LLVM SExtInst/LLVMValueRef SExtInst
 */
extern "C" bool isa_sextint(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<SExtInst>(unwrapped);
}

/**
 * True iff a value is an LLVM PHINode/LLVMValueRef PHINode
 */
extern "C" bool isa_phi(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<PHINode>(unwrapped);
}

/**
 * True iff a value is an LLVM 	SIToFPInst/LLVMValueRef 	SIToFPInst
 */
extern "C" bool isa_sitofp(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<SIToFPInst>(unwrapped);
}

/**
 * True iff a value is an LLVM Int/LLVMValueRef 	Int
 */
extern "C" bool isa_integertype(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return unwrapped->getType()->isIntegerTy();
}

/**
 * True iff a value is an LLVM IntPTr/LLVMValueRef ItPtr
 */
extern "C" bool isa_intptr(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    Type *t = unwrapped->getType();
    return t->isPointerTy() && t->getContainedType(0)->isIntegerTy();
}

/**
 * True iff a value is an LLVM Float/LLVMValueRef Float
 */
extern "C" bool isa_floattype(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return unwrapped->getType()->isFloatTy();
}

/**
 * True iff a value is an LLVM 	ConstantAggregateZero/LLVMValueRef
 * ConstantAggregateZero
 */
extern "C" bool isa_constaggregatezero(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<ConstantAggregateZero>(unwrapped);
}

/**
 * True iff a value is an LLVM ConstFP/LLVMValueRef
 * ConstFP
 */
extern "C" bool isa_constfp(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<ConstantFP>(unwrapped);
}

/**
 * True iff a value is an LLVM 	ConstantAggregate/LLVMValueRef
 * ConstantAggregate
 */
extern "C" bool isa_constaggregate(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<ConstantAggregate>(unwrapped);
}

/**
 * True iff a value is an LLVM 	bitcast/LLVMValueRef
 * bitcast
 */
extern "C" bool isa_bitcast(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    return isa<BitCastInst>(unwrapped);
}

/**
 * True iff a value is an LLVM 	SQRT F32/LLVMValueRef
 * SQRT F32
 */
extern "C" bool isa_sqrt32(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    if (auto *op = dyn_cast<CallInst>(unwrapped)) {
        return op->getCalledFunction()->getName() == SQRT32_FUNCTION_NAME;
    }
    // it is not a square root nor a call
    return false;
}

/**
 * True iff a value is an LLVM 	SQRT F64/LLVMValueRef
 * SQRT F64
 */
extern "C" bool isa_sqrt64(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    if (auto *op = dyn_cast<CallInst>(unwrapped)) {
        return op->getCalledFunction()->getName() == SQRT64_FUNCTION_NAME;
    }
    // it is not a square root nor a call
    return false;
}

/**
 * Gets constant float from LLVMValueRef value
 */
extern "C" float get_constant_float(LLVMValueRef val) {
    Value *v = unwrap(val);
    if (auto *num = dyn_cast<ConstantFP>(v)) {
        return num->getValue().convertToFloat();
    }
    return -1;
}

extern "C" LLVMValueRef build_constant_float(double n, LLVMContextRef context) {
    LLVMContext *c = unwrap(context);
    Type *float_type = Type::getFloatTy(*c);
    return wrap(ConstantFP::get(float_type, n));
}

/**
 * DFS backwards from current instruction to see if any past insdtruction
 * matches match_instr.
 *
 * Terminates when no more previous expressions, or reaches a
 * cosntant/argument/alloca instruction in LLVM.
 *
 * Searches for consecutive load/store instructions to same addresses,
 * which LLVM generates at -01 optimization.
 */
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

/**
 * Main method to call dfs llvm_value
 */
extern "C" bool dfs_llvm_value_ref(LLVMValueRef current_instr,
                                   LLVMValueRef match_instr) {
    auto current_user = dyn_cast<User>(unwrap(current_instr));
    auto match_user = dyn_cast<User>(unwrap(match_instr));
    if (current_user == NULL || match_user == NULL) {
        throw std::invalid_argument("Could not convert Value * to User *");
    }
    return dfs_llvm_instrs(current_user, match_user);
}

/**
 * Below is the main DiospyrosPass that activates the Rust lib.rs code,
 * which calls the Egg vectorizer and rewrites the optimized code in place.
 */

namespace {
struct DiospyrosPass : public FunctionPass {
    static char ID;
    DiospyrosPass() : FunctionPass(ID) {}

    virtual bool runOnFunction(Function &F) override {
        // do not optimize on main function.
        if (F.getName() == "main") {
            return false;
        }
        bool has_changes = false;
        for (auto &B : F) {
            // We skip over basic blocks without floating point types
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

            // Grab the terminator from the LLVM Basic Block
            Instruction *terminator = B.getTerminator();
            Instruction *cloned_terminator = terminator->clone();

            std::vector<std::vector<LLVMValueRef>> vectorization_accumulator;
            std::vector<LLVMValueRef> inner_vector = {};
            std::set<Value *> store_locations;
            std::vector<Instruction *> bb_instrs = {};
            for (auto &I : B) {
                if (auto *op = dyn_cast<StoreInst>(&I)) {
                    Value *store_loc = op->getOperand(1);
                    store_locations.insert(store_loc);
                    inner_vector.push_back(wrap(op));
                } else if (auto *op = dyn_cast<LoadInst>(&I)) {
                    Value *load_loc = op->getOperand(0);
                    if (!inner_vector.empty()) {
                        vectorization_accumulator.push_back(inner_vector);
                    }
                    inner_vector = {};
                    store_locations.clear();
                }
                bb_instrs.push_back(dyn_cast<Instruction>(&I));
            }
            vectorization_accumulator.push_back(inner_vector);

            // Acquire each of the instructions in the "run" that terminates at
            // a store We will send these instructions to optimize.

            int vec_length = vectorization_accumulator.size();
            int counter = 0;
            std::vector<LLVMValueRef> translated_exprs = {};
            for (auto &vec : vectorization_accumulator) {
                ++counter;
                if (not vec.empty()) {
                    has_changes = has_changes || true;
                    Value *last_store = unwrap(vec.back());
                    IRBuilder<> builder(dyn_cast<Instruction>(last_store));
                    Instruction *store_instr =
                        dyn_cast<Instruction>(last_store);
                    assert(isa<StoreInst>(store_instr));
                    builder.SetInsertPoint(store_instr);
                    builder.SetInsertPoint(&B);
                    Module *mod = F.getParent();
                    LLVMContext &context = F.getContext();
                    // std::vector<LLVMValueRef> new_translated_exprs =
                    VectorPointerSize pair =
                        optimize(wrap(mod), wrap(&context), wrap(&builder),
                                 vec.data(), vec.size());
                    int size = pair.size;
                    errs() << "length\n";
                    errs() << size << "\n";
                    LLVMValueRef const *expr_array = pair.vec_pointer;
                    for (int i = 0; i < size; i++) {
                        errs() << "element " << i << "\n";
                        errs() << *unwrap(expr_array[i]) << "\n";
                    }
                    // std::vector<LLVMValueRef> concat = {};
                    // concat.reserve(
                    //     translated_exprs.size() +
                    //     new_translated_exprs.size());  // preallocate memory
                    // concat.insert(concat.end(), translated_exprs.begin(),
                    //               translated_exprs.end());
                    // concat.insert(concat.end(), new_translated_exprs.begin(),
                    //               new_translated_exprs.end());
                    // translated_exprs = concat;
                }
                for (auto e : translated_exprs) {
                    errs() << e << "\n";
                }
            }
            std::reverse(bb_instrs.begin(), bb_instrs.end());
            for (auto &I : bb_instrs) {
                if (I->isTerminator()) {
                    I->eraseFromParent();
                } else if (isa<StoreInst>(I)) {
                    I->eraseFromParent();
                }
            }
            BasicBlock::InstListType &final_instrs = B.getInstList();
            final_instrs.push_back(cloned_terminator);
        }
        return true;
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
