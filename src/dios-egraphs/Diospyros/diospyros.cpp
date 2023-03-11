#include <assert.h>
#include <llvm-c/Core.h>

#include <algorithm>
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
#include "llvm/IR/Instruction.h"
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

int main(int argc, char **argv) {
    llvm::cl::ParseCommandLineOptions(argc, argv);
}

llvm::cl::opt<bool> RunOpt("r", llvm::cl::desc("Enable Egg Optimization."));
llvm::cl::alias RunOptAlias("opt", llvm::cl::desc("Alias for -r"),
                            llvm::cl::aliasopt(RunOpt));

llvm::cl::opt<bool> PrintOpt("z", llvm::cl::desc("Print Egg Optimization."));
llvm::cl::alias PrintOptAlias("print", llvm::cl::desc("Alias for -z"),
                              llvm::cl::aliasopt(PrintOpt));

extern "C" void optimize(LLVMModuleRef mod, LLVMContextRef context,
                         LLVMBuilderRef builder,
                         LLVMValueRef const *chunk_instrs,
                         std::size_t chunk_size,
                         LLVMValueRef const *restricted_instrs,
                         std::size_t restricted_size, bool run_egg,
                         bool print_opt);

const std::string ARRAY_NAME = "no-array-name";
const std::string TEMP_NAME = "no-temp-name";
const std::string SQRT64_FUNCTION_NAME = "llvm.sqrt.f64";
const std::string SQRT32_FUNCTION_NAME = "llvm.sqrt.f32";
const std::string MEMSET_PREFIX = "memset";
const std::string LLVM_MEMSET_PREFIX = "llvm.memset";
const std::string MEMMOVE_PREFIX = "memmove";
const std::string MEMCOPY_PREFIX = "memcopy";
const std::string MAIN_FUNCTION_NAME = "main";
const std::string NO_OPT_PREFIX = "no_opt_";
const int SQRT_OPERATOR = 3;
const int BINARY_OPERATOR = 2;

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
    std::string array_str = ARRAY_NAME + std::to_string(FRESH_ARRAY_COUNTER);
    char *cstr = new char[array_str.length() + 1];
    std::strcpy(cstr, array_str.c_str());
    return cstr;
}

/**
 * Generates a fresh name for a temporary variable that was taken from LLVM
 */
const char *gen_fresh_temp() {
    ++FRESH_TEMP_COUNTER;
    std::string temp_str = TEMP_NAME + std::to_string(FRESH_TEMP_COUNTER);
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

bool call_is_not_sqrt(CallInst *inst) {
    Function *function = inst->getCalledFunction();
    if (function != NULL) {
        return !(function->getName() == SQRT32_FUNCTION_NAME ||
                 function->getName() == SQRT64_FUNCTION_NAME);
    }
    return true;  // just assume it is not a sqrt. This means no optimization
                  // will be done
}

/**
 * True iff an instruction is "vectorizable"
 */
bool can_vectorize(Value *value) {
    // TODO:
    Instruction *instr = dyn_cast<Instruction>(value);
    assert(instr != NULL);
    if (instr->getOpcode() == Instruction::FAdd) {
        return true;
    } else if (instr->getOpcode() == Instruction::FSub) {
        return true;
    } else if (instr->getOpcode() == Instruction::FDiv) {
        return true;
    } else if (instr->getOpcode() == Instruction::FMul) {
        return true;
    } else if (instr->getOpcode() == Instruction::FNeg) {
        return true;
    }
    //  else if (isa<LoadInst>(instr)) {
    //     return true;
    // } else if (isa<StoreInst>(instr)) {
    //     return true;
    // }
    // else if (isa_sqrt32(wrap(instr))) {
    //     return true;
    // }
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
        for (auto &B : F) {
            // TODO: Consider removing as the new procedure can overcome this
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

            // Assumes Alias Analysis Movement Pass has been done previously
            // Pulls out Instructions into sections of code called "Chunks"
            //
            std::vector<std::vector<LLVMValueRef>> chunk_accumulator;
            std::vector<LLVMValueRef> chunk_vector = {};
            bool vectorizable_flag = false;
            for (auto &I : B) {
                Value *val = dyn_cast<Value>(&I);
                assert(val != NULL);
                if (can_vectorize(val) && !vectorizable_flag) {
                    if (!chunk_vector.empty()) {
                        chunk_accumulator.push_back(chunk_vector);
                    }
                    vectorizable_flag = true;
                    chunk_vector = {wrap(val)};
                } else if (can_vectorize(val) && vectorizable_flag) {
                    chunk_vector.push_back(wrap(val));
                } else if (!can_vectorize(val) && !vectorizable_flag) {
                    chunk_vector.push_back(wrap(val));
                } else if (!can_vectorize(val) && vectorizable_flag) {
                    if (!chunk_vector.empty()) {
                        chunk_accumulator.push_back(chunk_vector);
                    }
                    vectorizable_flag = false;
                    chunk_vector = {wrap(val)};
                } else {
                    throw "No other cases possible!";
                }
            }
            if (!chunk_vector.empty()) {
                chunk_accumulator.push_back(chunk_vector);
            }

            for (int i = 0; i < chunk_accumulator.size(); ++i) {
                auto &chunk_vector = chunk_accumulator[i];
                if (chunk_vector.empty()) {
                    continue;
                }

                // check if the chunk vector actually has instructions to
                // optimixe on
                bool has_vectorizable_instrs = false;
                for (auto &instr : chunk_vector) {
                    if (can_vectorize(unwrap(instr))) {
                        has_vectorizable_instrs = true;
                    }
                }
                if (!has_vectorizable_instrs) {
                    continue;
                }

                // If an instruction is used multiple times outside the chunk,
                // add it to a restricted list.
                // TODO: only consider future chunks!
                std::vector<LLVMValueRef> restricted_instrs = {};
                for (auto chunk_instr : chunk_vector) {
                    for (auto j = i + 1; j < chunk_accumulator.size(); ++j) {
                        // guaranteed to be a different chunk vector ahead of
                        // the origianl one.
                        bool must_restrict = false;
                        auto &other_chunk_vector = chunk_accumulator[j];
                        for (auto other_chunk_instr : other_chunk_vector) {
                            if (unwrap(chunk_instr) ==
                                unwrap(other_chunk_instr)) {
                                restricted_instrs.push_back(chunk_instr);
                                must_restrict = true;
                                break;
                            }
                        }
                        if (must_restrict) {
                            break;
                        }
                    }
                }

                has_changes = has_changes || true;
                assert(chunk_vector.size() != 0);

                // Place builder at first instruction that is not a "handled
                // instruction"
                int insert_pos = 0;
                bool has_seen_vectorizable = false;
                for (int i = 0; i < chunk_vector.size(); i++) {
                    if (can_vectorize(unwrap(chunk_vector[i]))) {
                        has_seen_vectorizable = true;
                        insert_pos++;
                    } else if (!has_seen_vectorizable) {
                        insert_pos++;
                    } else {
                        break;
                    }
                }
                Value *last_instr_val = NULL;
                if (insert_pos >= chunk_vector.size()) {
                    last_instr_val = unwrap(chunk_vector[insert_pos - 1]);
                } else {
                    last_instr_val = unwrap(chunk_vector[insert_pos]);
                }
                assert(last_instr_val != NULL);
                Instruction *last_instr = dyn_cast<Instruction>(last_instr_val);
                assert(last_instr != NULL);
                if (insert_pos >= chunk_vector.size()) {
                    last_instr = last_instr->getNextNode();
                    assert(last_instr != NULL);
                }
                IRBuilder<> builder(last_instr);

                Module *mod = F.getParent();
                LLVMContext &context = F.getContext();
                optimize(wrap(mod), wrap(&context), wrap(&builder),
                         chunk_vector.data(), chunk_vector.size(),
                         restricted_instrs.data(), restricted_instrs.size(),
                         RunOpt, PrintOpt);
            }

            // TODO: delete old instructions that are memory related; adce
            // will handle the remainder
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

static RegisterPass<DiospyrosPass> X("diospyros", "Diospyros Pass",
                                     false /* Only looks at CFG */,
                                     true /* Analysis Pass */);

static RegisterStandardPasses RegisterMyPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerDiospyrosPass);
