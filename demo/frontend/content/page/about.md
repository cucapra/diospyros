---
title: About
comments: false
---

### Frequently Asked Questions

#### What is Dahlia?

Dahlia is a typed imperative programming language for designing FPGA accelerators.
It targets High-Level Synthesis toolchains such as [Vivado HLS][vivado-hls]
as its compilation target. Dahlia aims to reduce pitfalls of HLS programming,
from simple interface issues which are not checked by vendor tools to complex
and unsuspecting behavior due to interaction between different optimizations.

[vivado-hls]: https://www.xilinx.com/products/design-tools/vivado/integration/esl-design.html

#### What is predictable accelerator design?

High performance HLS designs require tuning hardware optimizations such as
loop unrolling, pipelining, memory banking etc. These parameters have subtle
interactions with each other and design constraints of FPGA programming.

For example, when a parallel loop tries to read five values from a memory that
can only service two reads per cycle, the HLS compiler will *multiplex* the
reads and spread them across multiple cycles. This will result in a design that
consumes more area for the parallel loop body with suboptimal improvement in
performance.

This is unpredictable design--FPGA designs should improve latency when loop
bodies run in parallel. Dahlia statically reasons about memory use and rejects
designs that don't behave predictably.

#### Why design a new language?

Dahlia implements its own language constructs and semantics to cleanly reason
about HLS programs and explore new ideas. Concepts such as logical time steps
and affine reasoning are not commonly supported in modern programming languages.
Implementing our own compiler and type checker simplifies these implementation
challenges.

#### How does Dahlia work?

Hardware resources are reused through *time-multiplexing*---the compiler
separates resource use in time by reasoning about use locations and latencies
and guarantees that they are never used in a conflicting manner. In order
to model this, Dahlia extends [affine types][affine] with a notion of
time-sensitivity.

At a high level, Dahlia guarantees that complex time-multiplexing is represented
in the source program. By default, Dahlia rejects programs with complex memory
access patterns that require extensive compiler transformations to be implemented
as hardware. Instead of relying on the compiler to automatically generate
additional hardware, Dahlia requires the programmer to explicitly choose
complex transformations.

[affine]: https://en.wikipedia.org/wiki/Substructural_type_system#Affine_type_systems

----------

### Projects

Dahlia is built and maintained by the [CAPRA][] research group at Cornell
University.

As a part of the Dahlia project, have built and open-sourced several research
artifacts:

- [Dahlia](https://github.com/cucapra/dahlia): A compiler from Dahlia to HLS C.
- [Dahlia Evaluation](https://github.com/cucapra/dahlia-evaluation): Large scale evaluation of the Dahlia compiler.
- [FuTIL](https://github.com/cucapra/futil): An Intermediary Representation (IR) for HLS.
- [Polyphemus](https://github.com/cucapra/polyphemus): A framework for managing large scale, distributed experiments with AWS F1.


[capra]: https://capra.cs.cornell.edu


