# Documentation

This is the documentation for work on Diospyros for LLVM, up until the end of the Spring 2022 semester. Below, documentation and design and decisions are split by file name.

## Diospyros.cpp

Diospyros.cpp is the starting point for the vectorization process. This pass is run on functions in the basic block, and only on functions that are not named `main` nor have the prefix `no_opt_` attached to their name. In addition, there are a multitude of `isa`-style functions at in this file, which are used on the Rust side to check instruction type. These `isa` functions are used because the Rust LLVM-Core library `isa` functions do not return booleans, instead returning `LLVMValueRefs`, which one cannot branch on.

The heart of the Diospyros.cpp finds __runs__ of vectorizable instructions, which are then sent to the Diospyros rewriter. Vectorible instructions are instructions that are containing `FAdd`, `FSub`, `FMul`, `FDiv` or `FNeg` instruction types. Runs of vectorizable instructions are consecutive vectorizable instructions that occur before a `StoreInst` is detected in the basic block, or before a `LoadInst` is detected in the basic block. The first condition, to be before a `StoreInst`, is because the store may use the result of the vectorized computation. The second condition, to be before a `LoadInst`, is because the `load` may alias with a `store`, causing a read-write conflict. After a run is found, it is sent via the `optimize` function to be optimized by the Rust-side of the pass.

## LoadStoreMovement.cpp

Load Store Movement moves loads forward towards the beginning of a basic block, and stores backwards, towards the end of a basic block. Load store movement depends heavily on alias analysis. As a result, alias analysis is required to be run **before** the load store movement pass, as the load store movement pass repeatedly queries the alias analysis. Load store movement only occurs to functions that are not named `main` nor have the prefix `no_opt_` attached to their name.

Generally, the algorithm works as follows: a load or a store is chosen, and call this instruction `I`. Under certain conditions, `I` may be swapped with its neighbor. If conditions are correct, then the swap occurs. Swapping continues until no more swaps are possible. This occurs to all load and store instructions in the basic block.

As a technical matter relating to LLVM, and as a note to myself for future implementation issues, replacing all uses in LLVM does not actually fix back pointers for PHI Nodes. Instead, `replaceAllUsesWith()` is the preferred approach, and does not cause crashes when the LLVM Pass is run.

As a second note, insertion of the cloned instruction must occur before any changes to the cloned instruction are effected.

As a third note, when doing alias analysis, one must make sure that instructions that are pointed typed are being compared. To make sure of this, I use the `mayReadOrWriteMemory()` function as a guard. I then use the `isNoAlias()` function to help calculate aliasing.

As a fourth note, several instructions are not handled as optimally as possible. In particular, there may be calls to intrinsics like `@llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(40) %2, i8 0, i64 40, i1 false)` or `@memset_pattern16(i8* nonnull %2, i8* bitcast([4 x float]* @.memset_pattern to i8*), i64 40) #6`. However, I do not actually check pointer aliasing with these instructions. Call Instructions are treated as black boxes, which are assumed to always cause aliasing issues. This means that any memory intrinsics are always conservatively assumed to alias with a load or a store instruction, and no swap will occur. I intend to fix this, by iterating over call arguments to check whether each argument is a pointer or not, and the check aliasing with the store or load instruction. This will be more accurate and fined grained, and eliminate instances where a swap is not allowed to occur, when in fact the swap does not affect the semantics of the program.

Finally, as a fifth note, one must insert cloned PHI Nodes **before** any prior PHI nodes in the basic block. Likewise, one must insert any cloned terminator instructions **after** any existing terminator instructions in the basic block (which always exists in LLVM). This means that the builder must shift locations constantly. As part of the implementation, I place the builder at the end of the basic block, move it before the first instruction when inserting cloned PHI Nodes, and then move it to the end of the basic block again, when inserting the remainder of the instructions, including terminator instructions.

### Store Movement

A store can be moved towards the end of a basic block, if the next instruction proceeding the store exists, is not a terminator, is not a call instruction of any sort, and is not an instruction using a pointer `p'`, which may alias with pointer `p` in the store instruction. If all of the prior conditions are met, the store is swapped with the proceeding instruction. The process continues iteratively, until there are no more possible swaps possible.

### Load Movement

A load can be moved towards the end of a basic block, if the prior instruction proceeding the store exists, is not a PHI Node, is not a call instruction of any sort, does not define an LLVM register that is used by the Load as an argument, and is not an instruction using a pointer `p'`, which may alias with pointer `p` in the load instruction. If all of the prior conditions are met, the load is swapped with the proceeding instruction. The process continues iteratively, until there are no more possible swaps possible.

Note the extra condition that regarding the Load argument. This is critical, because the load may use a prior defined value, and we cannot move the load before when the value was defined.

## lib.rs

The Diospyros rewriting engine is applied in lib.rs. In particular, this file contains a translation from LLVM to `Egg` VecLang instructions, a translation from `Egg` VecLanf Instructions back to LLVM instructions. One can specify whether to print the `Egg` rewriting output, and whether to run the `Egg` rewriter at all, via a series of flags, passed in from Diospyros.cpp.

### New VecLang

The new VecLang now has a register construct, representing a black box register computation. A register represents a computed LLVM Value. It may be used if an LLVM Register is used across multiple runs or basic blocks.  The new argument construct is similar to a register construct, and represents an LLVM argument to a function.

### LLVM To Egg

Runs are translated from a sequence of LLVM instructions to a graph of Egg nodes. LLVM instructions are recursively translated backwards to Egg nodes. Starting in reverse in ths sequence of LLVM instructions, any translatable instruction (Add, Sub, Mul, Div, Neg, Sqrt), is chosen, and translated backwards from. If an instruction has been translated already, it is not retranslated to an Egg Node.

Each LLVM instruction is translated to an appropriate Egg Node:

- Restricted Instructions (instructions that are used in multiple runs/basic blocks): Translated to a Register Node
- Instruction not in the current run: Translated to a register node, because it must have existed already in the basic block
- Binary Operations: Translated to a binary operator node of the correct binary operator, and then each LLVM operand is recursively translated.
- Unary Operations: Similar to Binary Operations
- Sqrt: Translated to a sqrt node, and the operand is recursively translated
- Constants: Translated to a number node
- Arguments: Translated to argument nodes, which are conceptually similar to a register node because they act as black boxes.

Finally, Egg Nodes are padded to be a multiple of the vector Lane Width, which is usually 4, and the binary operation nodes are added on.

Useful metadata: 

- llvm2reg: This TreeMap maps an llvm instruction to a register. 
- llvm2arg: This treemap maps an llvm argument to a register.
- start_instructions: This is a vector of instructions where llvm2egg translation began
- start_ids: This is the vector of ids corresponding to the start instructions.
- prior_translated_instructions: These are all instructions that had been translated already in the current pass.
- instructions_in_chunk: All instructions in chunk/run (they are synonyms)
- restricted_instructions: All instructions which are not be translated and are to be represented as a register node.

All metadata from this pass lies in a struct that is passed to all recursive calls in `llvm2egg`.

### Egg to LLVM

The graph of Egg nodes is translated back to LLVM instructions, and the LLVM instructions are built and inserted in place.


