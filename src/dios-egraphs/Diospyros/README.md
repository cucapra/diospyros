# Diospyros for LLVM

This directory contains an experimental [LLVM][] pass that optimizes programs using Diospyros.

## Build It

To get started, you will need **LLVM 11.x.x**.
Using [Homebrew][] on macOS, for example, try `brew install llvm@11` to get the right version.

You will also need Rust, for the main Diospyros library, and a version of Python3, for testing using [turnt][].

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

Further, add a build directory in your current directory with the command:

    $ mkdir build

If you would like, you can build the pass library with:

    $ cargo build

Otherwise, running with any of the commands in the next section should also work.

Finally, note that the code for the Diospyros pass, in directory,  `dios-egraphs`,  must be in the directory immediately above the current one you are in, for the LLVM pass to build properly.

## Run the Pass

To build and run the [Clang][] pass, with Diospyros, use the Makefile command:

    $ make run-opt test=llvm-tests/a.c

where `llvm-tests/a.c` is the path to any test file, for insstance `c-tests/add.c`.

To build and run the [Clang][] pass, with Diospyros printing out the vectorization choices, use the Makefile command:

    $ make print-opt test=llvm-tests/a.c

To build and run the [Clang][] pass, with no usage of Diospyros, use the Makefile command:

    $ make no-opt test=llvm-tests/a.c

To build and see emitted LLVM IR code, run any of the above build commands for the file you are interested in, then look in the `build` directory and open the `dce.ll` file, which is the final pre-executable IR code file.

To run all the tests, run:

    $ turnt c-tests/*.c

Or alternately:

    $ make test

To set up macOS settings, run:

    $ make set-up-mac

To clean the repository of build files, run:

    $ make clean

## Testing

Test files provided in the `c-tests/` folder can be run with [turnt][]. To install or update Turnt, run the command:

    $ pip3 install --user turnt

Then, ensure that the test files produce the right output with:

    $ turnt c-tests/*.c

You can also pass the `--diff` flag to compare your output with the `.expect` files, and use the `--save` flag to save new `.expect` files.

## Measuring Runtime

The efficiency of the compiled test programs can be measured and compared using `runtime.py`. You can modify how many runs of the file you'd like in the `main()` function. 

Pass in a test suite like so:

    $ python3 runtime.py c-tests

    $ python3 runtime.py polybench-tests

The produced plots of runtimes can be found in the `runtimes/` directory. The file compiled using our custom Diospyros LLVM pass is labeled "llvm-pass". The file compiled using an unoptimized Clang call is labeled "no-opt", whereas "O2-opt" uses O2 optimization.

When running the script on Gorgonzola, you'll need a developer toolset:

    $ scl enable devtoolset-8 -- python3 runtime.py c-tests

[llvm]: https://llvm.org
[clang]: https://clang.llvm.org
[llvm-sys]: https://crates.io/crates/llvm-sys
[homebrew]: https://brew.sh
[turnt]: https://github.com/cucapra/turnt
