# Diospyros for LLVM

This directory contains an experimental [LLVM][] pass that optimizes programs using Diospyros.

There are two components here: the LLVM pass and the Diospyros library.
They need to be built separately (for now).

## Build the LLVM Pass

To build the LLVM pass:

    $ mkdir build
    $ cd build
    $ cmake ..
    $ cd ..
    $ make -C build

## Build the Diospyros (Rust) Library

Because our library relies on [the `llvm-sys` crate][], you will need an existing installation of `llvm-config` on your `$PATH`.
To use a [Homebrew][]-installed (Cask-only) LLVM, for example, you may need something like this:

    $ export PATH=$PATH:`brew --prefix llvm`/bin

Then, build the library with:

    $ cargo build

## Run the Pass

You'll need this ridiculously long [Clang][] invocation to run the optimization on a C source file:

      $ clang -Xclang -load -Xclang build/Diospyros/libDiospyrosPass.* -Xclang -load -Xclang target/debug/libllvmlib.so a.c

[llvm]: https://llvm.org
[clang]: https://clang.llvm.org
[llvm-sys]: https://crates.io/crates/llvm-sys
