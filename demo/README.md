# `cdios`/Diospyros Example Tutorial

The following example will walk through using the `cdios` frontend for the
Diospyros compiler. `cdios` takes code in a subset of C/C++ and produces a
single equivalent output function with Tensilica G3 vector intrinsics.

For any issues you encounter in this demo, please [file an issue on our Github repo][issue].
If the issue cannot be public, you can contact the author at avh@cs.cornell.edu.

# Installation

This tutorial assumes a machine with Xtensa tools installed and accessible on
your path. For example:
```
export LM_LICENSE_FILE=<path>.lic
export XTENSA_SYSTEM=<path>/RI-2019.2-linux/
export XTENSA_CORE=XRC_FUSIONG3_MAX_BM
```

To install `cdios`, follow the instructions in the top-level README under the sections
**Prerequisites** and **(Work in progress) Compiling from C: `cdios` minimal
 C frontend**. Note that these instructions have been testes on MacOS and Linux;
 we suggest using [Windows Subsystem for Linux][wsl] if running on Windows.

# Scope

As described in the top-level README, the tool currently supports functions that
take as input arguments matrices and scalars of type `float`, and write to one
or more output matrix of type `float`. In addition, the tool currently requires
data-independent control flow (branches/loop bounds must be statically resolved,
rather than depending on dynamic input values). The tool performs best on small-to-medium
matrix sizes (performance degrades, especially in memory consumption, with over 100 elements).

# Example: transpose then multiply

For this example, we want to process two arrays of data, `a` and `b`, in
small-sized blocks. For each block, we take the transpose of the section of `a`
and multiply it by the corresponding section of `b`. We process `ITERATIONS`
many sections of data. This example assumes you are running commands from the
`diospyros/demo` directory.

## Completed example: expected speedup

A completed version of this tutorial is in the `src-completed` directory. We
can run this first to see the performance benefits of using `cdios`/Diospyros.


First, run `make completed`. You can checkout the `Makefile` to see what
this does. In short, we use `xt-clang++` with (`-O3 -mlongcalls -mtext-section-literals -fvectorize`)
to compile the code, then `xt-run` (with `--mem_model`) to simulate its runtime
performance. We print the result matrices for the naive version and the
optimized version of the code, and the cycle counts (from `XT_RSR_CCOUNT()` in
`XT_ISS_CYCLE_ACCURATE` mode) for each.

You should see something like this:
```
Naive : 288 cycles

82.440002, 52.220001, 69.760002, 78.220001, ;
82.180000, 51.880005, 70.190002, 81.420006, ;
42.860001, 27.370001, 47.660000, 61.360004, ;

146.700012, 158.060013, 110.740005, 134.750000, ;
137.080002, 152.920013, 100.630005, 122.259995, ;
66.639999, 101.770004, 56.180004, 66.320000, ;
Optimized : 138 cycles

82.440002, 52.220001, 69.760002, 78.220001, ;
82.180000, 51.880001, 70.190002, 81.420006, ;
42.860001, 27.370001, 47.660000, 61.360001, ;

146.700012, 158.060013, 110.740005, 134.750000, ;
137.080002, 152.920013, 100.630005, 122.260002, ;
66.639999, 101.770004, 56.180000, 66.320000, ;
```


## Example walk through: using `cdios` to get these results.

The naive functionality is implemented in `src/example.c`.

To compile and run the code as-is with the Xtensa simulator, run `make` from
the `demo` directory. You should see something like this:
```
xt-clang++ -O3 -mlongcalls -mtext-section-literals -fvectorize src/example.c src/transpose_and_multiply.c -o example.o
xt-run --nosummary --mem_model example.o
Naive : 6099 cycles
Optimized : 15 cycles
82.440002
mismatch at (0,0) reference = 82.440002, actual = 0.000000, error = 82.440002
```
The mismatch error is expected (as is the very low cycle count), because we haven't implemented the optimized
version yet.

There are multiple ways we can use `cdios` to vectorize this code. We could
vectorize the `transpose` and `matrix_multiply` functions seperately by passing
each with `--function` to `cdios`. Instead, this tutorial will walk through
vectorizing the two together into a single kernel that first takes the transpose
then multiplies.

To start with, create a new file `kernel.c` in the `src` directory. `cdios` can
only support a subset of C, so it's easiest to start with a clean slate.

Copy the `transpose` and `matrix_multiply` functions into your new file. You'll
also need to copy the `#define` size lines.


If we
run `cdios` on the file now, it will fail because we have not annotated any
function arguments with inputs and outputs:
```
CDIOS: Compiling C->Racket failed
Arguments should be tagged _in or _out, got  "a"
```

Since we want to vectorize the functionality if these two functions together,
let's create a new function that combines their functionality. Add a new function
`transpose_then_multiply` to your `kernel.c` file. The return type should still be
void, and the arguments should still be `a`, `b`, and `c`.

However, we need to tag the inputs and outputs. `a` and `b` become `a_in` and
 `b_in` and `c` becomes `c_out`. Your function should look something like this:
```
void transpose_and_multiply(float *a_in, float *b_in, float *c_out) {
}
```

We have one last change to make to the function signature to enable `cdios`.
Diospyros relies on fixed sizes to vectorize, so modify your function signature
to the following:
```
void transpose_and_multiply(float a_in[A_SIZE * A_SIZE],
                            float b_in[B_ROWS * B_COLS],
                            float c_out[A_SIZE * B_COLS]) {
}
```

Now, combine the functionality into the implementation of this function. For example:
```

void transpose_and_multiply(float a_in[A_SIZE * A_SIZE],
                            float b_in[B_ROWS * B_COLS],
                            float c_out[A_SIZE * B_COLS]) {

  float tmp[A_SIZE * A_SIZE];
  transpose(a_in, tmp, A_SIZE);
  matrix_multiply(tmp, b_in, c_out);
}
```

We can now run `cdios` with: `cdios src/example.c --function transpose_and_multiply`. On success, we see:
```
Standard C compilation successful
Writing intermediate files to: build/compile-out
Header written to build/compile-out/transpose_and_multiply.h
Implementation written to build/compile-out/transpose_and_multiply.c
```

To incorporate this into our example, move the two files to the `src` directory, and add an import:
```
#include "transpose_and_multiply.h"
```

Now, we can modify the `process_data_optimized` function to use our new version:
```
diospyros::transpose_and_multiply(a_ref, b_ref, c_ref);
```

Finally, add the source to our Makefile:
```
SRCS := src/example.c src/transpose_and_multiply.c
```

And run again with `make` to see the results.

## Adjusting parameters

You can change the `ITERATIONS` variable in `src/example.c` to see
how the performance varies with the outer loop size (you don't need to rerun
`cdios` because the inner code size stays fixed).

You can also adjust the inner loop size by editing the `A_SIZE`, `B_ROWS`, and
`B_COLS` variables in `src/example.c`. For these changes, `cdios` needs to run
again to optimize for the new inner loop size.

# Running your own code

The above example illustrates the main steps to running your own desired
kernel or operator through the `cdios` compiler:
1. Identify functionality that is data-independent and operates on relatively
small chunks of data at once.
2. Create a new C file with the naive implementation of that functionality. Tag
input and output names with suffixes.
3. Pass the file and function name to the `cdios` tool.
4. Move the optimized header and implementation to where you want it, and call
the new code in place of your kernel.
5. Profit? There are some cases where `cdios`/Diospyros will produce code that
is worse than the default compilers (especially `xt-clang++`), so be sure to benchmark the results.

Thanks for taking the time to read this example, and please [file bugs][issue] if you hit any issues!

# More information

You can find the full ASPLOS 2021 paper describing the Diospyros system (but not the `cdios` frontend, which is new) [here][paper]. We also have [5 minute][short] and [17 minute][long] talks describing the paper results.

[issue]: https://github.com/cucapra/diospyros/issues/new
[wsl]: https://docs.microsoft.com/en-us/windows/wsl/install-win10
[paper]: https://www.cs.cornell.edu/~avh/diospyros-asplos-2021-preprint.pdf
[short]: https://youtu.be/pGHjvPLrmRc
[long]: https://youtu.be/RvMI4prTqHY
