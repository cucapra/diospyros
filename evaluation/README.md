# Diospyros Evaluation

This directory contains the evaluation scripts for our ASPLOS 2021 paper,
"Vectorizarion for Digital Signal Processors via Equality Saturation".


This artifact is intended to reproduce the 4 main experimental results from the
paper:
- **Compiling benchmarks (Table 1; Figure 4)** Compilation and simulated
cycle-level performance of 20 kernels (across 4 distinct functions). We compare
kernels compiled by Diospyros with kernels compiled with the vendor's optimizing
compiler and optimized library functions.
- **Translation validation (Section 3)**  Translation validation
for all 20 kernels that the scalar specification and vectorized result (both in
our abstract vector domain specific language) are equivalent.
- **Timeout ablation study (Figure 5)** Ablation study on a single kernel
(10×10 by 10×10 `MatMul`) over a range of equality saturation timeouts.
- **Application case study (Section 5.6)** Speedup of an open source
computer vision application (the [Theia][] structure-from-motion library) with a single
kernel compiled by Diospyros (QR decomposition).

We have split this artifact into two components:
1. **Diospyros compiler.** This is our publicly available compiler that
  produces C/C++ code with intrinsics. This component can be run on the provided
  [VirtualBox][] virtual machine, or installed from source and run locally on the
  reviewer's machine.
2. **Evaluation on licensed instruction set simulator (ISS).**
  Our compiler targets the Tensilica Fusion G3, which does not have an
  publicly accessible compiler or ISS (the vendor provides free academic licenses,
  but the process is not automated). To reproduce the cycle-level simulation
  statistics from our paper, we have provided reviews limited access to our
  research server (with permission from the AEC chairs).

[virtualbox]: https://www.virtualbox.org/
[theia]: https://github.com/sweeneychris/TheiaSfM

## Prerequisites

If you use the provided VirtualBox virtual machine, it has all dependencies
pre-installed.

To run locally, clone this repository and follow the instructions for installing prerequisites from the top-level README.

### Generating C/C++ with Intrinsics

To start with, we will generate most of the compiled C/C++ with intrinsics off the research server (either on the provided VM or locally). To skip running on the licensed simulator, we pass the `--skip-run` flag to the followijng commands.

First, to sanity check the setup, run the following test command, which compiles the smallest size of each unique kernel with a 10 second timeout for each:

#### Time estimate: 30 seconds
```
python3 evaluation/eval_benchmarks.py --timeout 10 --skip-run --test
```

Once that succeeds, we can run the benchmarks with the default 180 second timeout.  For now,
we suggest skipping the one kernel `4x4 QRDecomp` that requires 38 GB of memory, since it is infeasible to run in a VM. If you are running this locally on a machine with sufficient memory, you ran run the command without the `--skiplargemem` flag.  
#### Time estimate: 45 minutes (+4.5 hours if no `--skiplargemem`)
```
python3 evaluation/eval_benchmarks.py --skip-run --skiplargemem
```

### Seeing the Results

Now that we have collected the data, the next step is to analyze the results to draw the charts and tables you see in the ASPLOS paper.
First, use `charts.py` to generate the plots:

    python3 charts.py

[TK: Probably needs some command-line flags on that? Not sure. Also describe what files have been produced. --AS]

The `charts.py` script also produces a file called `combined.csv` that contains all the raw data that went into the plots.
You can look at it directly if you're curious about specific numbers.
To see some statistics about the compilation process, run the `benchtbl.py` script:

    python3 benchtbl.py --plain

This script reads `combined.csv` to make a table like Table 1 in the ASPLOS paper.
The `--plain` flag emits a plain-text table for reading directly; omit this flag to generate a LaTeX fragment instead.

### Theia Case Study

The ASPLOS paper puts the QR decomposition kernel into context by measuring the impact on performance in an application: the [Theia][] structure-from-motion library.
The `theia` subdirectory in this evaluation package contains the code necessary to reproduce those end-to-end results.

The first step is to get the generated C code for the QR decomposition kernel.
Copy the `egg_kernel.c` file from
[TK: where? not sure where this comes from --AS]
to the Theia directory.

Then, type `make run` to compile and execute both versions of the `DecomposeProjectionMatrix` function: one using Eigen (as the original open-source code does) and one using the Diospyros-generated QR kernel.

To post-process this output into the final numbers you see in the paper, pipe it into the `dpmresults.py` analysis script:

    make run | python3 dpmresults.py

This will produce a JSON document with three values: the cycle count for the Eigen- and Diospyros-based executions, and the speedup (which is just the ratio of the two cycle counts).