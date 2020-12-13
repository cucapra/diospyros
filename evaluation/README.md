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
computer vision application (Theia Structure From Motion library) with a single
kernel compiled by Diospyros(QR decomposition).

We have split this artifact into two components:
1. **Diospyros compiler.** This is our publicly available compiler that
  produces C/C++ code with intrinsics. This component can be run on the provided
  VirtualBox virtual machine, or installed from source and run locally on the
  reviewer's machine.
2. **Evaluation on licensed instruction set simulator (ISS)**
  Our compiler targets the Tensilica Fusion G3, which does not have an
  publicly accessible compiler or ISS (the vendor provides free academic licenses,
  but the process is not automated). To reproduce the cycle-level simulation
  statistics from our paper, we have provided reviews limited access to our
  research server (with permission from the AEC chairs).

## Prerequisites

### Artifact Sources

[virtualbox]: https://www.virtualbox.org/
