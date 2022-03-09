#include <assert.h>
#include <llvm-c/Core.h>

#include <cstdint>
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
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/User.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar/LoopUnrollPass.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;

int main(int argc, char **argv) {
    llvm::cl::ParseCommandLineOptions(argc, argv);
}

llvm::cl::opt<bool> RunOpt("r", llvm::cl::desc("Enable Egg Optimization."));
llvm::cl::alias RunOptAlias("opt", llvm::cl::desc("Alias for -r"),
                            llvm::cl::aliasopt(RunOpt));

llvm::cl::opt<bool> PrintOpt("p", llvm::cl::desc("Print Egg Optimization."));
llvm::cl::alias PrintOptAlias("print", llvm::cl::desc("Alias for -p"),
                              llvm::cl::aliasopt(PrintOpt));

typedef struct IntLLVMPair {
    uint32_t node_int;
    LLVMValueRef arg;
} IntLLVMPair;

typedef struct LLVMPair {
    LLVMValueRef original_value;
    LLVMValueRef new_value;
} LLVMPair;

typedef struct VectorPointerSize {
    LLVMPair const *llvm_pointer;
    std::size_t llvm_pointer_size;
} VectorPointerSize;

extern "C" VectorPointerSize optimize(LLVMModuleRef mod, LLVMContextRef context,
                                      LLVMBuilderRef builder,
                                      LLVMValueRef const *bb, std::size_t size,
                                      LLVMPair const *past_instrs,
                                      std::size_t past_size, bool run_egg,
                                      bool print_opt);

const string ARRAY_NAME = "no-array-name";
const string TEMP_NAME = "no-temp-name";
const string SQRT64_FUNCTION_NAME = "llvm.sqrt.f64";
const string SQRT32_FUNCTION_NAME = "llvm.sqrt.f32";
const string MEMSET_PREFIX = "memset";
const string LLVM_MEMSET_PREFIX = "llvm.memset";
const string MEMMOVE_PREFIX = "memmove";
const string MEMCOPY_PREFIX = "memcopy";
const string MAIN_FUNCTION_NAME = "main";
const string NO_OPT_PREFIX = "no_opt_";
const int SQRT_OPERATOR = 3;
const int BINARY_OPERATOR = 2;

/** Number of instructions to search back and see if translated - we keep less
 * to search faster; but actually cutting it short is unsound. */
const int NUM_TRANSLATED_INSTRUCTIONS = 2000;

/**
 * Fresh counters for temps and array generation
 */
static int FRESH_INT_COUNTER = 0;
static int FRESH_ARRAY_COUNTER = 0;
static int FRESH_TEMP_COUNTER = 0;

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
 * True iff a value is an LLVM IntPTr/LLVMValueRef IntPtr
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
 * True iff a value is an LLVM FloatPtr/LLVMValueRef FloatPtr
 */
extern "C" bool isa_floatptr(LLVMValueRef val) {
    auto unwrapped = unwrap(val);
    if (unwrapped == NULL) {
        return false;
    }
    Type *t = unwrapped->getType();
    return t->isPointerTy() && t->getContainedType(0)->isFloatTy();
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
    } else if (auto *num = dyn_cast<ConstantInt>(v)) {
        return num->getValue().bitsToFloat();
    }
    errs() << "Not a Constant Float or Constant Int " << *unwrap(val) << "\n";
    throw "LLVM Value Must be a Constant Float or Constant Int";
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

// Instruction *dfs_instructions(Instruction *current_instr,
//                               std::vector<LLVMPair> &translated_exprs,
//                               BasicBlock *B) {
//     for (LLVMPair pair : translated_exprs) {
//         Instruction *original_val =
//             dyn_cast<Instruction>(unwrap(pair.original_value));
//         Instruction *new_val = dyn_cast<Instruction>(unwrap(pair.new_value));
//         if (current_instr == original_val) {
//             return new_val;
//         }
//     }

//     Instruction *cloned_instr = current_instr->clone();

//     int num_operands = current_instr->getNumOperands();
//     if (num_operands == 0) {
//         BasicBlock::InstListType &intermediate_instrs = B->getInstList();
//         intermediate_instrs.push_back(cloned_instr);

//         LLVMPair new_pair;
//         new_pair.original_value = wrap(current_instr);
//         new_pair.new_value = wrap(cloned_instr);
//         translated_exprs.push_back(new_pair);

//         return cloned_instr;
//     }

//     for (int i = 0; i < num_operands; i++) {
//         Instruction *arg =
//         dyn_cast<Instruction>(current_instr->getOperand(i)); if (arg != NULL)
//         {
//             Instruction *cloned_arg =
//                 dfs_instructions(arg, translated_exprs, B);
//             cloned_instr->setOperand(i, cloned_arg);

//             LLVMPair new_pair;
//             new_pair.original_value = wrap(arg);
//             new_pair.new_value = wrap(cloned_arg);
//             translated_exprs.push_back(new_pair);
//         }
//     }
//     LLVMPair new_pair;
//     new_pair.original_value = wrap(current_instr);
//     new_pair.new_value = wrap(cloned_instr);
//     translated_exprs.push_back(new_pair);

//     BasicBlock::InstListType &intermediate_instrs = B->getInstList();
//     intermediate_instrs.push_back(cloned_instr);
//     return cloned_instr;
// }

Instruction *dfs_instructions(Instruction *current_instr,
                              std::vector<LLVMPair> &translated_exprs,
                              BasicBlock *B) {
    Instruction *cloned_instr = current_instr->clone();
    if (isa<Argument>(current_instr)) {
        return current_instr;
    } else if (isa<Constant>(current_instr)) {
        return current_instr;
    } else if (isa<AllocaInst>(current_instr)) {
        for (LLVMPair pair : translated_exprs) {
            Instruction *original_val =
                dyn_cast<Instruction>(unwrap(pair.original_value));
            Instruction *new_val =
                dyn_cast<Instruction>(unwrap(pair.new_value));
            if (current_instr == original_val) {
                return new_val;
            }
        }
        LLVMPair new_pair;
        new_pair.original_value = wrap(current_instr);
        new_pair.new_value = wrap(cloned_instr);
        translated_exprs.push_back(new_pair);

        BasicBlock::InstListType &intermediate_instrs = B->getInstList();
        intermediate_instrs.push_back(cloned_instr);
        return cloned_instr;
    }

    int num_operands = current_instr->getNumOperands();
    for (int i = 0; i < num_operands; i++) {
        Instruction *arg = dyn_cast<Instruction>(current_instr->getOperand(i));
        if (arg != NULL) {
            Instruction *cloned_arg =
                dfs_instructions(arg, translated_exprs, B);
            cloned_instr->setOperand(i, cloned_arg);
        }
    }
    BasicBlock::InstListType &intermediate_instrs = B->getInstList();
    intermediate_instrs.push_back(cloned_instr);
    return cloned_instr;
}

bool is_memset_variety(CallInst *inst) {
    Function *function = inst->getCalledFunction();
    if (function != NULL) {
        StringRef name = function->getName();
        return (name.size() > MEMSET_PREFIX.size() &&
                name.substr(0, MEMSET_PREFIX.size()) == MEMSET_PREFIX) ||
               (name.size() > LLVM_MEMSET_PREFIX.size() &&
                name.substr(0, LLVM_MEMSET_PREFIX.size()) ==
                    LLVM_MEMSET_PREFIX);
    }
    return false;
}

bool is_memcopy_variety(CallInst *inst) {
    Function *function = inst->getCalledFunction();
    if (function != NULL) {
        StringRef name = function->getName();
        return name.size() > MEMCOPY_PREFIX.size() &&
               name.substr(0, MEMCOPY_PREFIX.size()) == MEMCOPY_PREFIX;
    }
    return false;
}

bool is_memmove_variety(CallInst *inst) {
    Function *function = inst->getCalledFunction();
    if (function != NULL) {
        StringRef name = function->getName();
        return name.size() > MEMMOVE_PREFIX.size() &&
               name.substr(0, MEMMOVE_PREFIX.size()) == MEMMOVE_PREFIX;
    }
    return false;
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
        // do not optimize on main function or no_opt functions.
        if (F.getName() == MAIN_FUNCTION_NAME ||
            (F.getName().size() > NO_OPT_PREFIX.size() &&
             F.getName().substr(0, NO_OPT_PREFIX.size()) == NO_OPT_PREFIX)) {
            return false;
        }
        bool has_changes = false;
        std::vector<LLVMPair> translated_exprs = {};
        for (auto &B : F) {
            // We skip over basic blocks without floating point types
            bool has_float = false;
            for (auto &I : B) {
                if (I.getType()->isFloatTy()) {
                    has_float = true;
                }
            }
            if (!has_float) {
                for (auto &I : B) {
                    auto *op = wrap(dyn_cast<Instruction>(&I));
                    LLVMPair new_pair;
                    new_pair.original_value = op;
                    new_pair.new_value = op;
                    translated_exprs.push_back(new_pair);
                }
                continue;
            }
            // We also skip over all basic blocks without stores
            bool has_store_or_mem_intrinsic = false;
            for (auto &I : B) {
                if (auto *op = dyn_cast<StoreInst>(&I)) {
                    has_store_or_mem_intrinsic = true;
                } else if (auto *op = dyn_cast<MemSetInst>(&I)) {
                    has_store_or_mem_intrinsic = true;
                } else if (auto *op = dyn_cast<MemCpyInst>(&I)) {
                    has_store_or_mem_intrinsic = true;
                } else if (auto *op = dyn_cast<MemMoveInst>(&I)) {
                    has_store_or_mem_intrinsic = true;
                } else if (CallInst *op = dyn_cast<CallInst>(&I)) {
                    if (is_memset_variety(op)) {
                        has_store_or_mem_intrinsic = true;
                    } else if (is_memcopy_variety(op)) {
                        has_store_or_mem_intrinsic = true;
                    } else if (is_memmove_variety(op)) {
                        has_store_or_mem_intrinsic = true;
                    }
                }
            }
            if (!has_store_or_mem_intrinsic) {
                for (auto &I : B) {
                    auto *op = wrap(dyn_cast<Instruction>(&I));
                    LLVMPair new_pair;
                    new_pair.original_value = op;
                    new_pair.new_value = op;
                    translated_exprs.push_back(new_pair);
                }
                continue;
            }

            // We also skip over all basic blocks with Select as that is not
            // translatable into Egg
            bool has_select = false;
            for (auto &I : B) {
                if (auto *op = dyn_cast<SelectInst>(&I)) {
                    has_select = true;
                }
            }
            if (has_select) {
                for (auto &I : B) {
                    auto *op = wrap(dyn_cast<Instruction>(&I));
                    LLVMPair new_pair;
                    new_pair.original_value = op;
                    new_pair.new_value = op;
                    translated_exprs.push_back(new_pair);
                }
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
                } else if (auto *op = dyn_cast<MemSetInst>(&I)) {
                    if (!inner_vector.empty()) {
                        vectorization_accumulator.push_back(inner_vector);
                    }
                    inner_vector = {wrap(op)};
                    vectorization_accumulator.push_back(inner_vector);
                    inner_vector = {};
                    store_locations.clear();
                } else if (auto *op = dyn_cast<MemCpyInst>(&I)) {
                    if (!inner_vector.empty()) {
                        vectorization_accumulator.push_back(inner_vector);
                    }
                    inner_vector = {wrap(op)};
                    vectorization_accumulator.push_back(inner_vector);
                    inner_vector = {};
                    store_locations.clear();
                } else if (auto *op = dyn_cast<MemMoveInst>(&I)) {
                    if (!inner_vector.empty()) {
                        vectorization_accumulator.push_back(inner_vector);
                    }
                    inner_vector = {wrap(op)};
                    vectorization_accumulator.push_back(inner_vector);
                    inner_vector = {};
                    store_locations.clear();
                } else if (CallInst *call_inst = dyn_cast<CallInst>(&I)) {
                    if (is_memset_variety(call_inst)) {
                        if (!inner_vector.empty()) {
                            vectorization_accumulator.push_back(inner_vector);
                        }
                        Instruction *memset = dyn_cast<CallInst>(call_inst);
                        inner_vector = {wrap(memset)};
                        vectorization_accumulator.push_back(inner_vector);
                        inner_vector = {};
                        store_locations.clear();
                    } else if (is_memcopy_variety(call_inst)) {
                        if (!inner_vector.empty()) {
                            vectorization_accumulator.push_back(inner_vector);
                        }
                        Instruction *memcopy = dyn_cast<CallInst>(call_inst);
                        inner_vector = {wrap(memcopy)};
                        vectorization_accumulator.push_back(inner_vector);
                        inner_vector = {};
                        store_locations.clear();
                    } else if (is_memmove_variety(call_inst)) {
                        if (!inner_vector.empty()) {
                            vectorization_accumulator.push_back(inner_vector);
                        }
                        Instruction *memmove = dyn_cast<CallInst>(call_inst);
                        inner_vector = {wrap(memmove)};
                        vectorization_accumulator.push_back(inner_vector);
                        inner_vector = {};
                        store_locations.clear();
                    }
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
            if (!inner_vector.empty()) {
                vectorization_accumulator.push_back(inner_vector);
            }

            // Acquire each of the instructions in the "run" that terminates at
            // a store We will send these instructions to optimize.

            int vec_length = vectorization_accumulator.size();
            int counter = 0;
            // std::vector<LLVMPair> translated_exprs = {};
            for (auto &vec : vectorization_accumulator) {
                ++counter;
                if (not vec.empty()) {
                    has_changes = has_changes || true;
                    Value *last_store = unwrap(vec.back());
                    IRBuilder<> builder(dyn_cast<Instruction>(last_store));
                    Instruction *store_instr =
                        dyn_cast<Instruction>(last_store);
                    if (auto *op = dyn_cast<StoreInst>(store_instr)) {
                        assert(isa<StoreInst>(store_instr));
                        builder.SetInsertPoint(store_instr);
                        builder.SetInsertPoint(&B);
                        Module *mod = F.getParent();
                        LLVMContext &context = F.getContext();
                        VectorPointerSize pair = optimize(
                            wrap(mod), wrap(&context), wrap(&builder),
                            vec.data(), vec.size(), translated_exprs.data(),
                            translated_exprs.size(), RunOpt, PrintOpt);
                        int size = pair.llvm_pointer_size;

                        LLVMPair const *expr_array = pair.llvm_pointer;
                        // translated_exprs = {};
                        for (int i = 0; i < size; i++) {
                            translated_exprs.push_back(expr_array[i]);
                        }
                    } else {
                        assert(isa<MemSetInst>(last_store) ||
                               isa<MemCpyInst>(last_store) ||
                               isa<MemMoveInst>(last_store) ||
                               (isa<CallInst>(last_store) &&
                                is_memset_variety(
                                    dyn_cast<CallInst>(last_store))) ||
                               (isa<CallInst>(last_store) &&
                                is_memcopy_variety(
                                    dyn_cast<CallInst>(last_store))) ||
                               (isa<CallInst>(last_store) &&
                                is_memmove_variety(
                                    dyn_cast<CallInst>(last_store))));

                        dfs_instructions(store_instr, translated_exprs, &B);
                    }

                    // Trim down translated_exprs
                    std::vector<LLVMPair> new_translated_exprs = {};
                    if (translated_exprs.size() >=
                        NUM_TRANSLATED_INSTRUCTIONS) {
                        for (int i = 0; i < NUM_TRANSLATED_INSTRUCTIONS; i++) {
                            LLVMPair final_instr = translated_exprs.back();
                            translated_exprs.pop_back();
                            new_translated_exprs.push_back(final_instr);
                        }
                        translated_exprs = new_translated_exprs;
                    }
                }
            }
            std::reverse(bb_instrs.begin(), bb_instrs.end());
            for (auto &I : bb_instrs) {
                if (I->isTerminator()) {
                    I->eraseFromParent();
                } else if (isa<StoreInst>(I)) {
                    I->eraseFromParent();
                } else if ((isa<CallInst>(I) &&
                            is_memset_variety(dyn_cast<CallInst>(I))) ||
                           (isa<CallInst>(I) &&
                            is_memcopy_variety(dyn_cast<CallInst>(I))) ||
                           (isa<CallInst>(I) &&
                            is_memmove_variety(dyn_cast<CallInst>(I)))) {
                    I->eraseFromParent();
                } else if (isa<MemSetInst>(I)) {
                    I->eraseFromParent();
                } else if (isa<MemCpyInst>(I)) {
                    I->eraseFromParent();
                } else if (isa<MemMoveInst>(I)) {
                    I->eraseFromParent();
                }
            }
            BasicBlock::InstListType &final_instrs = B.getInstList();
            final_instrs.push_back(cloned_terminator);

            // Trim down translated_exprs
            std::vector<LLVMPair> new_translated_exprs = {};
            if (translated_exprs.size() >= NUM_TRANSLATED_INSTRUCTIONS) {
                for (int i = 0; i < NUM_TRANSLATED_INSTRUCTIONS; i++) {
                    LLVMPair final_instr = translated_exprs.back();
                    translated_exprs.pop_back();
                    new_translated_exprs.push_back(final_instr);
                }
                translated_exprs = new_translated_exprs;
            }
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
