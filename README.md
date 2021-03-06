# Diospyros

Diospyros is a compiler for generating high-performance, intrinsics-based
code for linear algebra kernels running on digital signal processors (DSPs).

At a high level, Diospyros takes fixed-size linear algebra kernels (specified
in either a Racket DSL or with a minimal subset of C), uses [Rosette][]'s symbolic
evaluation to generate a specification, runs a vector rewrite equality saturation engine written in
[egg][], then emits C with DSP-specific intrinsics. Diospyros currently targets the [Tensilica Fusion G3 DSP][fusiong3].

## ASPLOS artifact

See our [evaluation README][eval] for instructions on generating the data for our ASPLOS 2021 paper.

[eval]: https://github.com/cucapra/diospyros/blob/master/evaluation/README.md

## Prerequisites

### Python
- Install [Python][] > 3.0.
- You will also need the following packages:
    - `pip3 -mpip install sexpdata`

### Racket
- Install [Racket][] > 8.0.
- Install [Rosette][] by running `raco pkg install rosette`.
- Install additional Racket libraries:
    - `raco pkg install threading`
    - `raco pkg install c-utils`

### Z3
- Install [z3][]:
    - MacOS: `brew install z3`
    - Linux example: `sudo apt-get install -y z3`

### Rust
- Install [Rust][].
- Install dependencies for rewrite engine: `cargo install --path ./src/dios-egraphs`

## (Work in progress) Compiling from C: `cdios` minimal C frontend
The minimal C frontend requires only a single file to specify a new kernel, but
it is currently limited in expressiveness.

To install `cdios`, run the following in the root directory:
```
pip3 install --user -e .
```

You can run a simple example with:
```
cdios cdios-tests/matrix-multiply.c
```

By default, this will compile the last function in the file and emit the
generated C and header files to `build/compile-out/kernel.c` and
`build/compile-out/kernel.h`, respectively. To compile a specific function,
pass the name with `--function`. For example, `cdios cdios-tests/matrix-multiply.c --function matrix_multiply`
writes the header to `build/compile-out/matrix_multiply.h` and the
implementation to `build/compile-out/matrix_multiply.c`.

`cdios` runs programs through a standard C compiler (currently `gcc`) to sanity
check correctness, then does a best-effort translation to equivalent Racket.

Currently, programs must have one outermost C function that consumes and
mutates arrays and scalars of type `float`. This outermost function must follow
the specific naming conventions and restrictions below.

- Arrays must have statically-specified sizes, which can be `#define`'d at the
 start of the file.
- Inputs and outputs are identified via a suffix naming convention. Inputs
should be suffixed with `_in`, and outputs should be suffixed with `out`.
- Control flow cannot be data dependent (i.e., you can branch on an index, but
not based on the value of an array at that index).

The following restrictions currently apply, but are likely to be improved/eliminated
soon:
- Early returns are not supported.
- Array access via pointer dereference may not compile, and arrays should be specified
with, for example, `float a_in[SIZE]`.

Example matrix multiply:
```
#define A_ROWS 2
#define A_COLS 2
#define B_COLS 2

void matrix_multiply(float a_in[A_ROWS*A_COLS], float b_in[A_COLS*B_COLS], float c_out[A_ROWS*B_COLS]) {
  for (int y = 0; y < A_ROWS; y++) {
    for (int x = 0; x < B_COLS; x++) {
      c_out[B_COLS * y + x] = 0;
      for (int k = 0; k < A_COLS; k++) {
        c_out[B_COLS * y + x] += a_in[A_COLS * y + k] * b_in[B_COLS * k + x];
      }
    }
  }
}
```

## Compiling from Racket DSL

Specifying programs in Racket (currently useful for multi-function kernels, and
those with control flow constructs not handled by `cdios`) involves editing the
Racket source code in a few places.

- Create a new file in `src/examples/<new>.rkt`. This file must implement an
    `only-spec` functiont that consumes a configuration, and produces (1) the
    resulting specification, (2) a prelude including inputs and outputs, and (3)
    the output names and sizes of the kernel. See
     `src/examples/matrix-multiply.rkt` for an example. The configuration is a
     key value map that will be specified in JSON for a specific invocation,
     and should include a key for `'reg-size` for the register wide (typically
     4) and keys for any kernel-specific sizes.
- In `src/example-gen.rkt`, add your new file to the `require` list, then add
    the new example to the functions `known-benches` and `run-bench`.
- Run `make` to rebuild the Racket source with your new changes.
- To run your new benchmark, create a file named `<new>-params` and enter the
    desired configuration in JSON. For example, for `QProd`, we would create a
    file `q-prod-params`.

```
{
    "reg-size": 4
}
```
- Finally, run `make <new>-egg` (i.e., `make q-prod-egg`). This will emit both
    intermediate files and the final kernel (`kernel.c`) to a directory
    `<new>-out`.

## Testing

### Unit tests

To run all unit tests:
```
make test-all
```

To run the inline Racket or Rust tests, respectively:
```
make test-racket
make test-rust
```

[boolector]: https://github.com/Boolector/boolector
[egg]:https://docs.rs/egg/0.5.0/egg/index.html
[fusiong3]: https://ip.cadence.com/uploads/1085/Fusion_G3_DSP_DS_FINAL-pdf
[pypy]: https://doc.pypy.org/en/latest/install.html
[python]: https://www.python.org/downloads/
[racket]: https://github.com/racket/racket
[rosette]: https://docs.racket-lang.org/rosette-guide/index.html
[runt]: https://github.com/rachitnigam/runt
[rust]: https://www.rust-lang.org/
[rust]: https://www.rust-lang.org/tools/install
[z3]: https://github.com/Z3Prover/z3
