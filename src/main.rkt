#lang rosette

(require racket/cmdline
         "./examples/2d-conv.rkt"
         "./examples/matrix-multiply.rkt")


; Set of known benchmarks we can run.
(define known-benches
  (list "mat-mul"
        "conv-2d"))

(define bench-name (make-parameter #f))
(define param-file (make-parameter #f))

(define bench-help
  (~a "Benchmark to run. Possibilities: "
      (string-join known-benches ", ")))

(module+ main
  (command-line
    #:program "Diospyros compiler"
    #:once-each
    [("-b" "--benchmark") bench ; name of the benchmark
                          "Name of the benchmark to run."
                          (bench-name bench)]
    [("-p" "--param") params
                      "Location of the parameter file"
                      (param-file params)])

  (when (not (bench-name))
    (error 'main
           "Missing benchmark name. Choices: ~a."
           (string-join known-benches ", ")))

  (when (not (param-file))
    (error 'main
           "Missing parameter file."
           )))
