#lang rosette

(require racket/cmdline
         json
         threading
         "./ast.rkt"
         "./utils.rkt"
         "./configuration.rkt"
         "./examples/2d-conv.rkt"
         "./examples/matrix-add.rkt"
         "./examples/matrix-multiply.rkt"
         "./examples/matrix-add.rkt"
         "./examples/matrix-subtract.rkt"
         "./examples/dot-product.rkt"
         ;"./examples/standard-deviation.rkt"
         ;"./examples/vector-distance.rkt"
         ;"./examples/vector-midpoint.rkt"
         "./examples/discrete-fourier-transform.rkt")


; Set of known benchmarks we can run.
(define known-benches
  (list "mat-mul"
        "mat-add"
        "mat-sub"
        "dot-product"
        ;"standard-deviation"
        ;"vec-distance"
        ;"vec-midpoint"
        "2d-conv"
        "dft"))

(define (create-base-directory out-dir)
  (define base
    (if (absolute-path? out-dir)
      out-dir
      (build-path (current-directory) out-dir)))
  ; Create the base directory
  (when (pr (not (directory-exists? base)))
    (pretty-print (format "Creating output directory: ~a" base))
    (make-directory base))
  base)

; Return a function that creates a new file in the out-dir.
(define (make-out-dir-writer out-dir)
  (define base (create-base-directory out-dir))

  ; Assumes that all files have a unique costs associated with them.
  (lambda (prog cost)
    (define conc-prog (concretize-prog prog))
    (let ([cost-path (~> cost
                         bitvector->integer
                         number->string
                         (format "sol-~a.rkt" _)
                         string->path
                         (build-path base _))])
      (call-with-output-file cost-path
        (lambda (out) (pretty-print conc-prog out))
        #:exists 'replace))))

; Return a function that creates a new file in the out-dir with a given name.
(define (make-spec-out-dir-writer out-dir)
  (define base (create-base-directory out-dir))
  (lambda (spec name)
    (let ([path (~> name
                    (format "~a.rkt" _)
                    string->path
                    (build-path base _))])
      (call-with-output-file path
        (lambda (out) (pretty-print spec out))
        #:exists 'replace))))

(define (run-bench name params out-dir print-spec)
  (define-values (run only-spec keys)
    (case name
      [("2d-conv") (values conv2d:run-experiment
                           conv2d:only-spec
                           conv2d:keys)]
      [("mat-mul") (values matrix-mul:run-experiment
                           matrix-mul:only-spec
                           matrix-mul:keys)]
      [("mat-add") (values matrix-add:run-experiment
                           (lambda (_)
                            (pretty-print "mat-add only-spec not implemented"))
                           matrix-add:keys)]
      [("mat-sub") (values matrix-sub:run-experiment
                           (lambda (_)
                            (pretty-print "mat-sub only-spec not implemented"))
                           matrix-sub:keys)]
      [("dft")     (values dft:run-experiment
                           dft:only-spec
                           dft:keys)]
      [("dot-product") (values dot-product:run-experiment
                               (lambda (_)
                                 (pretty-print "dot-product only-spec not implemented"))
                               dot-product:keys)]
      ;[("standard-deviation") (values standard-deviation:run-experiment
      ;                     (lambda (_)
      ;                      (pretty-print "standard-deviation only-spec not implemented"))
      ;                     standard-deviation:keys)]
      ;[("vec-distance") (values vector-distance:run-experiment
      ;                     (lambda (_)
      ;                      (pretty-print "vector-distance only-spec not implemented"))
      ;                     vector-distance:keys)]
      ;[("vec-midpoint") (values vector-midpoint:run-experiment
      ;                     (lambda (_)
      ;                      (pretty-print "vector-midpoint only-spec not implemented"))
      ;                     vector-midpoint:keys)]
      [else (error 'run-bench
                   "Unknown benchmark ~a"
                   name)]))

  (define validator
    (lambda (spec)
      (for ([key keys])
        (when (not (hash-has-key? spec key))
          (error 'run-bench
                 "Missing key `~a' required by benchmark ~a"
                 key name)))
      spec))

  (define config
    (call-with-input-file params
      (lambda (in) (validator (read-json in)))))

  (if print-spec
    (begin
      (pretty-print (only-spec config))
      ; TODO: write out prefix and postfix in dios DSL
      ((make-spec-out-dir-writer out-dir) (only-spec config) "spec"))
    (run config (make-out-dir-writer out-dir))))

(define bench-name (make-parameter #f))
(define param-file (make-parameter #f))
(define output-dir (make-parameter #f))
(define only-spec (make-parameter #f))

(define bench-help
  (~a "Benchmark to run. Possibilities: "
      (string-join known-benches ", ")))

(module+ main
  (command-line
    #:program "Run and save examples for Diospyros."
    #:once-each
    [("-b" "--benchmark") bench ; name of the benchmark
                          "Name of the benchmark to run."
                          (bench-name bench)]
    [("-p" "--param") params
                      "Location of the parameter file."
                      (param-file params)]
    [("-s" "--only-spec")
                      "Location of the parameter file."
                      (only-spec #t)]
    [("-o" "--output-dir") out-dir
                           "Directory to save solutions in."
                           (output-dir out-dir)])

  (when (not (bench-name))
    (error 'main
           "Missing benchmark name. Choices: ~a."
           (string-join known-benches ", ")))

  (when (not (param-file))
    (error 'main
           "Missing parameter file."))

  (when (not (or (output-dir) (only-spec)))
    (error 'main
           "Missing output directory for saving solutions in."))

  (run-bench (bench-name) (param-file) (output-dir) (only-spec)))
