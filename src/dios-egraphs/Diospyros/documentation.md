# Documentation

This is the documentation for work on Diospyros for LLVM, up until the end of the Spring 2022 semester. Below, documentation and design and decisions are split by file name.

## Diospyros.cpp

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
