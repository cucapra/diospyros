#include <assert.h>

#include <algorithm>
#include <map>
#include <set>
#include <utility>
#include <vector>

#include "VectorizationUtilities.cpp"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/MemoryLocation.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
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
const std::string GATHER_NAME = "llvm.masked.gather.v4f32.v4p0f32";
const uint32_t VECTOR_WIDTH = 4;
const uint32_t FLOAT_WIDTH = 4;

namespace {
struct AddressRewritingPass : public FunctionPass {
    static char ID;
    AddressRewritingPass() : FunctionPass(ID) {}

    void getAnalysisUsage(AnalysisUsage &AU) const override {
        AU.addRequired<AAResultsWrapperPass>();
        AU.addRequired<BasicAAWrapperPass>();
        AU.addRequired<ScalarEvolutionWrapperPass>();
        AU.addRequired<TargetLibraryInfoWrapperPass>();
    }

    using chunks_t = Chunking::chunks_t;
    using chunk_t = Chunking::chunk_t;

    std::vector<Instruction *> get_gather_calls(chunk_t chunk) {
        std::vector<Instruction *> gather_calls = {};
        for (auto instr : chunk) {
            if (Gather::isa_gather_instruction(instr)) {
                gather_calls.push_back(instr);
            }
        }
        return gather_calls;
    }

    Instruction *get_first_non_phi_instr(chunk_t chunk) {
        assert(!chunk.empty());
        for (auto instr : chunk) {
            if (!isa<PHINode>(instr)) {
                return instr;
            }
        }
        return chunk.back();
    }

    std::map<Instruction *, std::vector<Value *>>
    get_gather_addresses_from_chunk(chunk_t chunk) {
        std::map<Instruction *, std::vector<Value *>> result = {};
        for (auto instr : chunk) {
            if (Gather::isa_gather_instruction(instr)) {
                std::vector<Value *> addresses =
                    Gather::get_gather_addresses(instr);
                result.emplace(instr, addresses);
            }
        }
        return result;
    }

    std::vector<Value *> join_all_addresses(
        std::map<Instruction *, std::vector<Value *>> gather_map) {
        std::vector<Value *> result = {};
        for (auto [_, addresses] : gather_map) {
            result.insert(result.end(), addresses.begin(), addresses.end());
        }
        return result;
    }

    std::map<Value *, std::pair<int, int>> get_base_offsets(
        std::vector<Value *> addresses, std::vector<Value *> array_bases,
        ScalarEvolution *SE) {
        std::map<Value *, std::pair<int, int>> result = {};
        for (auto address : addresses) {
            result.emplace(address,
                           Array::get_base_reference(address, array_bases, SE));
        }
        return result;
    }

    std::vector<uint32_t> find_minimum_cover_for_offsets(
        std::set<int> offsets) {
        std::set<uint32_t> minimum_cover = {};
        for (auto offset : offsets) {
            assert(offset >= 0);
            int remainder =
                ((offset / FLOAT_WIDTH) % VECTOR_WIDTH) * FLOAT_WIDTH;
            int aligned_addr = offset - remainder;
            minimum_cover.insert(aligned_addr);
        }
        std::vector<uint32_t> result = {};
        for (auto offset : minimum_cover) {
            assert(offset >= 0);
            result.push_back(offset);
        }
        std::sort(result.begin(), result.end());
        return result;
    }

    /**
     * Rewrites Load-Gather Addresses in a Chunk
     *
     * Grabs Chunks
     * For each chunk:
     *      Gets Gather Addresses
     *      Gets Gather call instruction
     *      Builds a map from Gather Address to Gather call instruction [many to
     * one]
     *
     *      Maps each address to pair of an array base and an offset from the
     *       array base
     *      Remove addresses with unknown array base or array offset
     *      Build a map between gather call instruction and the array base(s)
     *              and the correspoding offsets
     *          Use the Gather Map from address to call and
     *               map from address to pair of base / offset
     *
     *      For each gather represented
     *          Generate a "cover" for all the unique array offsets using
     *              aligned & consecutive load operations
     *          Build a map from each load to the array offsets and base
     *               it corresponds to
     *          Generate appropriate shuffles
     *          Stitch in the shuffles to the old gather call instruction
     *              by inserting at the beginning of the chunk
     *          Remove the old gather call instruction
     *
     *
     *  E.g. suppose we do a gather from A[3], A[5], B[2], C[7]
     *  We build a load(A[0-3]), load(A[4-7]), load(B[0-3]), load(c[4-7])
     *  We then build the appropriate shuffles, here 3 shuffles are needed
     *  Then we stitch in the instruction
     *
     * We would have gathered
     */
    void rewrite_addresses(BasicBlock &B, std::vector<Value *> array_bases,
                           AliasAnalysis *AA, ScalarEvolution *SE,
                           LLVMContext &C, unsigned address_space) {
        chunks_t chunks = Chunking::build_chunks(&B, AA);

        // Define floating point 4 wide vector pointer type, e.g. <4 x float> *
        Type *float_ty = Type::getFloatTy(C);
        VectorType *vector_4_float_ty = VectorType::get(float_ty, VECTOR_WIDTH);
        PointerType *pointer_to_vector_4_float_ty =
            PointerType::get(vector_4_float_ty, address_space);

        for (chunk_t chunk : chunks) {
            if (chunk.empty()) {
                continue;
            }
            errs() << "This is the chunk\n";
            for (auto instr : chunk) {
                errs() << *instr << "\n";
            }
            std::vector<Instruction *> gather_calls = get_gather_calls(chunk);
            std::map<Instruction *, std::vector<Value *>> gather2addresses =
                get_gather_addresses_from_chunk(chunk);
            std::vector<Value *> all_addresses =
                join_all_addresses(gather2addresses);
            // get offsets and base arrays for all addresses
            std::map<Value *, std::pair<int, int>> addresses2base_and_offset =
                get_base_offsets(all_addresses, array_bases, SE);

            // start construction after the first element that is non-phi in the
            // chunk
            Instruction *first_instr = get_first_non_phi_instr(chunk);
            assert(first_instr != NULL);
            IRBuilder<> builder(first_instr);
            for (auto gather : gather_calls) {
                assert(Gather::isa_gather_instruction(gather));
                errs() << "Gather Instruction\n";
                errs() << *gather << "\n";
                // get all base arrays and offsets required for the gather
                std::set<std::pair<int, int>> all_base_offset_pairs = {};
                for (auto address : gather2addresses[gather]) {
                    all_base_offset_pairs.insert(
                        addresses2base_and_offset[address]);
                }
                // if any of the base array or offsets are negative, skip this
                // gather
                // Also get all base arrays required for the cover
                // And for each base array, get all the offsets needed
                std::set<int> base_arrays = {};
                std::map<int, std::set<int>> base2offsets = {};
                bool continue_loop = false;
                for (auto [base, offset] : all_base_offset_pairs) {
                    base_arrays.insert(base);
                    if (base2offsets.count(base) == 1) {
                        base2offsets[base].insert(offset);
                    } else {
                        base2offsets[base] = {offset};
                    }
                    if (base < 0 || offset < 0) {
                        continue_loop = true;
                        break;
                    }
                }
                if (continue_loop) {
                    continue;
                }

                std::map<std::pair<uint32_t, std::vector<uint32_t>>,
                         std::vector<bool>>
                    vector_load_addresses2usage_flags = {};
                std::map<std::pair<uint32_t, std::vector<uint32_t>>, Value *>
                    vector_load_addresses2load_instr = {};
                // find minimium covers for each offsets
                for (auto [base, offsets] : base2offsets) {
                    assert(base >= 0);
                    std::vector<uint32_t> minimum_cover =
                        find_minimum_cover_for_offsets(offsets);
                    // build the minimum covers
                    for (auto aligned_offset : minimum_cover) {
                        Value *bitcast_instr = builder.CreateBitOrPointerCast(
                            array_bases[base], pointer_to_vector_4_float_ty,
                            "bitcast-for-alignment");
                        Value *aligned_gep_instr = builder.CreateConstGEP1_32(
                            vector_4_float_ty, bitcast_instr,
                            (aligned_offset / (FLOAT_WIDTH * VECTOR_WIDTH)),
                            "gep-for-aligned-addr");
                        Value *aligned_load = builder.CreateLoad(
                            vector_4_float_ty, aligned_gep_instr, false,
                            "load-aligned-addr");
                        std::vector<uint32_t> load_addresses = {};
                        for (int i = 0; i < VECTOR_WIDTH; i++) {
                            load_addresses.push_back(aligned_offset +
                                                     i * FLOAT_WIDTH);
                        }
                        if (vector_load_addresses2usage_flags.count(
                                {base, load_addresses}) == 0) {
                            std::vector<bool> all_false = {};
                            for (int i = 0; i < VECTOR_WIDTH; i++) {
                                all_false.push_back(false);
                            }
                            vector_load_addresses2usage_flags[{
                                base, load_addresses}] = all_false;
                        }
                        for (auto offset : offsets) {
                            std::vector<unsigned int>::iterator itr =
                                std::find(load_addresses.begin(),
                                          load_addresses.end(), offset);
                            if (itr != load_addresses.cend()) {
                                int index =
                                    std::distance(load_addresses.begin(), itr);
                                vector_load_addresses2usage_flags[{
                                    base, load_addresses}][index] = true;
                            }
                        }
                        vector_load_addresses2load_instr[{
                            base, load_addresses}] = aligned_load;
                    }
                }
                // the correct order of the base/offset pairs for the gather
                std::vector<std::pair<uint32_t, uint32_t>>
                    actual_ordered_base_offsets = {};
                std::vector<Value *> addresses = gather2addresses[gather];
                std::reverse(addresses.begin(), addresses.end());
                for (auto address : addresses) {
                    actual_ordered_base_offsets.push_back(
                        addresses2base_and_offset[address]);
                }
                errs() << "Actual Gather Ordered Base and Offsets\n";
                for (auto [base, offset] : actual_ordered_base_offsets) {
                    errs() << base << ", " << offset << "\n";
                }

                std::vector<
                    std::pair<std::pair<uint32_t, std::vector<uint32_t>>,
                              std::vector<bool>>>
                    to_merge = {};
                for (auto [pair, usage_flags] :
                     vector_load_addresses2usage_flags) {
                    to_merge.push_back({pair, usage_flags});
                }
                assert(to_merge.size() != 0);
                auto [first_base, first_load_addresses] =
                    to_merge.front().first;
                std::vector<bool> first_usage = to_merge.front().second;
                Value *final_shuffle = vector_load_addresses2load_instr[{
                    first_base, first_load_addresses}];
                Value *initial_load = final_shuffle;

                // merge size of 1:
                if (to_merge.size() == 1) {
                    std::vector<int> shuffle_indices = {};
                    for (auto [actual_base, actual_offset] :
                         actual_ordered_base_offsets) {
                        bool found_and_added = false;
                        for (int i = 0; i < first_load_addresses.size(); i++) {
                            auto first_load_address = first_load_addresses[i];
                            if ((first_base == actual_base) &&
                                (first_load_address == actual_offset)) {
                                shuffle_indices.push_back(i);
                                found_and_added = true;
                            }
                        }
                        if (!found_and_added) {
                            shuffle_indices.push_back(0);
                        }
                    }
                    assert(shuffle_indices.size() == VECTOR_WIDTH);
                    const std::vector<int> mask_vector = shuffle_indices;
                    // build the shuffles back to the gather
                    ArrayRef<int> mask = ArrayRef<int>(mask_vector);
                    final_shuffle = builder.CreateShuffleVector(
                        final_shuffle, final_shuffle, mask, "one-shuffle-only");

                    // if the shuffle indices is the identity, just use the load
                    std::vector<int> identity{0, 1, 2, 3};
                    if (shuffle_indices == identity) {
                        final_shuffle = initial_load;
                    }
                } else {
                    // merge size of 2 or more
                    auto [second_base, second_load_addresses] =
                        to_merge[1].first;

                    // do the first 2 together
                    std::vector<int> shuffle_indices = {};
                    for (auto [actual_base, actual_offset] :
                         actual_ordered_base_offsets) {
                        bool found_and_added = false;
                        for (int i = 0; i < first_load_addresses.size(); i++) {
                            auto first_load_address = first_load_addresses[i];
                            if ((first_base == actual_base) &&
                                (first_load_address == actual_offset)) {
                                shuffle_indices.push_back(i);
                                found_and_added = true;
                            }
                        }
                        for (int i = 0; i < second_load_addresses.size(); i++) {
                            auto second_load_address = second_load_addresses[i];
                            if ((second_base == actual_base) &&
                                (second_load_address == actual_offset)) {
                                shuffle_indices.push_back(i + VECTOR_WIDTH);
                                found_and_added = true;
                            }
                        }
                        if (!found_and_added) {
                            shuffle_indices.push_back(0);
                        }
                    }
                    assert(shuffle_indices.size() == VECTOR_WIDTH);
                    const std::vector<int> mask_vector = shuffle_indices;
                    // build the shuffles back to the gather
                    ArrayRef<int> mask = ArrayRef<int>(mask_vector);
                    Value *second_load = vector_load_addresses2load_instr[{
                        second_base, second_load_addresses}];
                    final_shuffle = builder.CreateShuffleVector(
                        final_shuffle, second_load, mask, "one-shuffle-only");

                    // do the remainder
                    // finish after first merge
                    for (int i = 2; i < to_merge.size(); i++) {
                        auto [remaining_pair, _] = to_merge[i];
                        uint32_t remaining_base = remaining_pair.first;
                        std::vector<uint32_t> remaining_offsets =
                            remaining_pair.second;
                        // do a shuffle into the correct positions
                        std::vector<int> shuffle_indices = {};
                        int j = 0;
                        for (auto [actual_base, actual_offset] :
                             actual_ordered_base_offsets) {
                            bool found_and_added = false;
                            for (int i = 0; i < remaining_offsets.size(); i++) {
                                uint32_t remaining_offset =
                                    remaining_offsets[i];
                                if ((actual_base == remaining_base) &&
                                    (actual_offset == remaining_offset)) {
                                    shuffle_indices.push_back(i);
                                    found_and_added = true;
                                }
                            }
                            if (!found_and_added) {
                                shuffle_indices.push_back(j + VECTOR_WIDTH);
                            }
                            ++j;
                        }
                        assert(shuffle_indices.size() == VECTOR_WIDTH);
                        const std::vector<int> mask_vector = shuffle_indices;
                        // build the shuffles back to the gather
                        ArrayRef<int> mask = ArrayRef<int>(mask_vector);
                        final_shuffle = builder.CreateShuffleVector(
                            vector_load_addresses2load_instr[remaining_pair],
                            final_shuffle, mask, "one-shuffle-only");
                    }
                }

                // // for the first pair, do the shuffling into correct position
                // // do a shuffle into the correct positions

                // std::vector<int> shuffle_indices = {};
                // for (auto [actual_base, actual_offset] :
                //      actual_ordered_base_offsets) {
                //     bool found_and_added = false;
                //     for (int i = 0; i < first_load_addresses.size(); i++) {
                //         auto first_load_address = first_load_addresses[i];
                //         if ((first_base == actual_base) &&
                //             (first_load_address == actual_offset)) {
                //             shuffle_indices.push_back(i);
                //             found_and_added = true;
                //         }
                //     }
                //     if (!found_and_added) {
                //         shuffle_indices.push_back(0);
                //     }
                // }
                // assert(shuffle_indices.size() == VECTOR_WIDTH);
                // const std::vector<int> mask_vector = shuffle_indices;
                // // build the shuffles back to the gather
                // ArrayRef<int> mask = ArrayRef<int>(mask_vector);
                // final_shuffle = builder.CreateShuffleVector(
                //     final_shuffle, final_shuffle, mask, "one-shuffle-only");

                // // finish after first merge
                // for (int i = 1; i < to_merge.size(); i++) {
                //     auto [remaining_pair, _] = to_merge[i];
                //     uint32_t remaining_base = remaining_pair.first;
                //     std::vector<uint32_t> remaining_offsets =
                //         remaining_pair.second;
                //     // do a shuffle into the correct positions
                //     std::vector<int> shuffle_indices = {};
                //     int j = 0;
                //     for (auto [actual_base, actual_offset] :
                //          actual_ordered_base_offsets) {
                //         bool found_and_added = false;
                //         for (int i = 0; i < remaining_offsets.size(); i++) {
                //             uint32_t remaining_offset = remaining_offsets[i];
                //             if ((actual_base == remaining_base) &&
                //                 (actual_offset == remaining_offset)) {
                //                 shuffle_indices.push_back(i);
                //                 found_and_added = true;
                //             }
                //         }
                //         if (!found_and_added) {
                //             shuffle_indices.push_back(j + VECTOR_WIDTH);
                //         }
                //         ++j;
                //     }
                //     assert(shuffle_indices.size() == VECTOR_WIDTH);
                //     const std::vector<int> mask_vector = shuffle_indices;
                //     // build the shuffles back to the gather
                //     ArrayRef<int> mask = ArrayRef<int>(mask_vector);
                //     final_shuffle = builder.CreateShuffleVector(
                //         vector_load_addresses2load_instr[remaining_pair],
                //         final_shuffle, mask, "one-shuffle-only");
                // }

                // replace all uses of gather with the final shuffle
                // then remove gather
                gather->replaceAllUsesWith(final_shuffle);
                gather->eraseFromParent();
            }
        }
    }

    virtual bool runOnFunction(Function &F) override {
        if (F.getName() == MAIN_FUNCTION_NAME ||
            (F.getName().size() > NO_OPT_PREFIX.size() &&
             F.getName().substr(0, NO_OPT_PREFIX.size()) == NO_OPT_PREFIX)) {
            return false;
        }
        AliasAnalysis *AA = &getAnalysis<AAResultsWrapperPass>().getAAResults();
        ScalarEvolution *SE =
            &getAnalysis<ScalarEvolutionWrapperPass>().getSE();
        TargetLibraryInfo *TLI =
            &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);
        std::vector<Value *> array_bases = Array::get_array_bases(F, TLI);
        LLVMContext &C = F.getContext();
        unsigned address_space = 0;
        bool found_address_space = false;
        for (auto &B : F) {
            for (auto &I : B) {
                if (GetElementPtrInst *gep = dyn_cast<GetElementPtrInst>(&I)) {
                    address_space = gep->getAddressSpace();
                    found_address_space = true;
                    break;
                }
            }
        }
        if (!found_address_space) {
            return false;
        }
        for (auto &B : F) {
            rewrite_addresses(B, array_bases, AA, SE, C, address_space);
        }
        return true;
    }
};
}  // namespace

char AddressRewritingPass::ID = 0;

// Automatically enable the pass.
// http://adriansampson.net/blog/clangpass.html
static void registerAddressRewritingPass(const PassManagerBuilder &,
                                         legacy::PassManagerBase &PM) {
    PM.add(new AddressRewritingPass());
}

static RegisterPass<AddressRewritingPass> X("addressrw",
                                            "Address Rewriting Pass",
                                            false /* Only looks at CFG */,
                                            true /* Analysis Pass */);

static RegisterStandardPasses RegisterMyPass(
    PassManagerBuilder::EP_EarlyAsPossible, registerAddressRewritingPass);