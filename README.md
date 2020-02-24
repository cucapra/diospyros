# Diospyros

Compile code for DSPs.

## Prerequisites

- Install [Racket][] > 7.4
- Install [Rosette][] by running `raco pkg install rosette`.
- Install Racket's threading library with `raco pkg install threading`
- Install [Z3][] and [Boolector][].

[racket]: https://github.com/racket/racket
[rosette]: https://docs.racket-lang.org/rosette-guide/index.html
[z3]: https://github.com/Z3Prover/z3
[boolector]: https://github.com/Boolector/boolector

## Building

Create excutables to (1) create kernels in the DSL (`dios-example-gen`), and (2) compile kernels from the DSL to C (`dios`) with:
> make build

To make a DSL example, you'll need a JSON parameters file. For example:
```
{
  "input-rows": 2,
  "input-cols": 2,
  "filter-rows": 2,
  "filter-cols": 2,
  "iterations": 10,
  "reg-size": 4
}
```

Then run:
> ./dios-example-gen -b 2d-conv -p 2d-conv-params.json -o example-output.rkt

To compile from the DSL to C:
> ./dios -o example.c example-output.rkt

Run tests with: 
> make test`
