# Diospyros for LLVM

This directory contains an experimental [LLVM][] pass that optimizes programs using Diospyros.

There are two components here: the LLVM pass and the Diospyros library.
They need to be built separately (for now).

To get started, you will need **LLVM 11.x.x**.
Because our Rust library relies on [the `llvm-sys` crate][llvm-sys], you will need an existing installation of `llvm-config` on your `$PATH`.
To use a [Homebrew][homebrew]-installed (Cask-only) LLVM, for example, you may need something like this:

    $ export PATH=`brew --prefix llvm`/bin:$PATH

## Build the LLVM Pass

Using Homebrew, you may need to set something like this to let CMake find the appropriate LLVM build files:

    $ export LLVM_DIR=`brew --prefix llvm`/lib/cmake/llvm

Then, to build the LLVM pass:

    $ mkdir build
    $ cd build
    $ cmake ..
    $ cd ..
    $ make -C build

## Build the Diospyros (Rust) Library

If you're on macOS, you will need an annoying hack to make the library build (in these [Rust](https://github.com/rust-lang/rust/issues/62874) [bugs](https://github.com/rust-lang/cargo/issues/8628)).
Add a file `.cargo/config` here, in this directory, with these [contents](https://pyo3.rs/v0.5.2/):

    [target.x86_64-apple-darwin]
    rustflags = [
      "-C", "link-arg=-undefined",
      "-C", "link-arg=dynamic_lookup",
    ]

Then, build the library with:

    $ cargo build

## Run the Pass

You'll need this ridiculously long [Clang][] invocation to run the optimization on a C source file:

    $ clang -Xclang -load -Xclang build/Diospyros/libDiospyrosPass.* -Xclang -load -Xclang target/debug/libllvmlib.so a.c

As usual, make sure that the `clang` you invoke here is from the same LLVM installation against which you built the pass above.

[llvm]: https://llvm.org
[clang]: https://clang.llvm.org
[llvm-sys]: https://crates.io/crates/llvm-sys
[homebrew]: https://brew.sh
