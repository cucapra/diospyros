#lang rosette

(require racket/cmdline
         json
         threading
         "./examples/2d-conv.rkt"
         "./examples/matrix-multiply.rkt")


; Set of known benchmarks we can run.
(define known-benches
  (list "mat-mul"
        "2d-conv"))

; Return a function that creates a new file in the out-dir.
(define (make-out-dir-writer out-dir)
  (define base
    (build-path (current-directory) out-dir))
  ; Create the base directory
  (when (not (directory-exists? base))
    (pretty-print (format "Creating output directory: ~a" base))
    (make-directory base))

  ; Assumes that all files have a unique costs associated with them.
  (lambda (prog cost)
    (let ([cost-path (~> cost
                         number->string
                         (format "sol-~a.rkt" _)
                         string->path
                         (build-path base _))])
      (call-with-output-file cost-path
        (lambda (out) (pretty-print prog out))))))

(define (run-bench name params out-dir)
  (pretty-print params)

  (define-values (run keys)
    (case name
      [("2d-conv") (values conv2d:run-experiment conv2d:keys)]
      [("mat-mul") (values matrix-mul:run-experiment matrix-mul:keys)]
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

  (define spec
    (call-with-input-file params
      (lambda (in) (validator (read-json in)))))

  (run spec (make-out-dir-writer out-dir)))

(define bench-name (make-parameter #f))
(define param-file (make-parameter #f))
(define output-dir (make-parameter #f))

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

  (when (not (output-dir))
    (error 'main
           "Missing output directory for saving solutions in."))

  (run-bench (bench-name) (param-file) (output-dir)))
