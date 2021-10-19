# Diospyros for LLVM

This directory contains an experimental [LLVM][] pass that optimizes programs using Diospyros.

## Build It

To get started, you will need **LLVM 11.x.x**.
Using [Homebrew][] on macOS, for example, try `brew install llvm@11` to get the right version.

Because our Rust library relies on [the `llvm-sys` crate][llvm-sys], you will need an existing installation of `llvm-config` on your `$PATH`.
To use a Homebrew-installed LLVM, for example, you may need something like this:

    $ export PATH=`brew --prefix llvm@11`/bin:$PATH

If you're on macOS, you will also need an annoying hack to make the library build (in these [Rust](https://github.com/rust-lang/rust/issues/62874) [bugs](https://github.com/rust-lang/cargo/issues/8628)).
Add a file `.cargo/config` here, in this directory, with these [contents](https://pyo3.rs/v0.5.2/):

    [target.x86_64-apple-darwin]
    rustflags = [
      "-C", "link-arg=-undefined",
      "-C", "link-arg=dynamic_lookup",
    ]

Then, build the pass library with:

    $ cargo build

## Run the Pass

To build and run the [Clang][] pass on a test file, use this Makefile command:

    $ make run test=llvm-tests/a.c

where `llvm-tests/a.c` is the path to any test file.

To build and run the Clang pass, with optimization, use the Makefile command:

    $ make run-opt test=llvm-tests/a.c

where `llvm-tests/a.c` is the path to any test file.

To build and see emitted LLVM IR code, , with optimization, use the Makefile command:

$ make run-opt test=llvm-tests/a.c

where, again, `llvm-tests/a.c` is the path to any test file.

To emit the generated LLVM IR code, either unoptimized or optimized:

    $ make emit test=llvm-tests/a.c
    $ make emit-o2 test=llvm-tests/a.c


To build, run the [Clang][] pass, and the run the associated program `./a.out`, run:

    $ make run-out test=llvm-tests/a.c

To run all the tests, run:

    $ make test

To run all tests and get output, run:

    $ make run-all

To set up macOS settings, run:

    $ make set-up-mac

To clean the repository of build files, run:

    $ make clean

## Testing

Test files provided in the llvm-tests/ folder can be run with [Runt][]. To install or update Runt: 

    $ cargo install runt

Then, ensure that the test files produce the right output with:

    $ runt

You can also pass the `--diff` flag to compare your output with the `.expect` files.


[llvm]: https://llvm.org
[clang]: https://clang.llvm.org
[llvm-sys]: https://crates.io/crates/llvm-sys
[homebrew]: https://brew.sh
[runt]: https://github.com/rachitnigam/runt
