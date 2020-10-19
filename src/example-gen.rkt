#lang rosette

(require racket/cmdline
         json
         threading
         "./ast.rkt"
         "./utils.rkt"
         "./configuration.rkt"
         "./examples/2d-conv.rkt"
         "./examples/matrix-multiply.rkt"
         "./examples/discrete-fourier-transform.rkt"
         "./examples/qr-decomp.rkt"
         "./examples/q-prod.rkt")


(error-print-width 999999999999999999999999999)
(pretty-print-depth #f)

; Set of known benchmarks we can run.
(define known-benches
  (list "mat-mul"
        "2d-conv"
        "dft"
        "qr-decomp"
        "q-prod"))

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

(define (run-bench name params out-dir)
  (define-values (only-spec keys)
    (case name
      [("2d-conv") (values conv2d:only-spec
                           conv2d:keys)]
      [("mat-mul") (values matrix-mul:only-spec
                           matrix-mul:keys)]
      [("dft")     (values dft:only-spec
                           dft:keys)]
      [("qr-decomp") (values qr-decomp:only-spec
                             qr-decomp:keys)]
      [("q-prod") (values q-prod:only-spec
                          q-prod:keys)]
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

  (define-values (spec prelude outputs) (only-spec config))
  (define out-writer (make-spec-out-dir-writer out-dir))
  (out-writer spec egg-spec)
  (out-writer (concretize-prog prelude) egg-prelude)
  (out-writer outputs egg-outputs))

(define bench-name (make-parameter #f))
(define param-file (make-parameter #f))
(define output-dir (make-parameter #f))
(define vec-width (make-parameter 4))

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
                           (output-dir out-dir)]
    [("-w" "--vec-width") width
                          "Vector width (default is 4)"
                          (vec-width (string->number width))])

  (when (not (bench-name))
    (error 'main
           "Missing benchmark name. Choices: ~a."
           (string-join known-benches ", ")))

  (when (not (param-file))
    (error 'main
           "Missing parameter file."))
  (parameterize [(current-reg-size (vec-width))]
    (run-bench (bench-name) (param-file) (output-dir))))
