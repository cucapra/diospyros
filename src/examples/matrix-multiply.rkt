#lang rosette

(require "../ast.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../utils.rkt"
         "../prog-sketch.rkt"
         "../synth.rkt"
         racket/trace
         racket/generator
         rosette/solver/smt/z3
         rosette/solver/smt/boolector)

(provide matrix-mul:keys
         matrix-mul:run-experiment)

(define example
    (prog
      (list
        (vec-extern-decl 'A 6 input-tag)
        (vec-extern-decl 'B 9 input-tag)
        (vec-extern-decl 'C 6 output-tag)
        (vec-const 'Z '#(0))
        (vec-const 'shuf0-0 '#(3 5 1 2))
        (vec-const 'shuf1-0 '#(0 8 4 8))
        (vec-const 'shuf2-0 '#(3 5 1 2))
        (vec-shuffle 'reg-A 'shuf0-0 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-0 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-0 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-0 'out)
        (vec-const 'shuf0-1 '#(4 3 2 0))
        (vec-const 'shuf1-1 '#(3 2 7 2))
        (vec-const 'shuf2-1 '#(3 5 1 2))
        (vec-shuffle 'reg-A 'shuf0-1 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-1 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-1 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-1 'out)
        (vec-const 'shuf0-2 '#(3 5 1 2))
        (vec-const 'shuf1-2 '#(1 6 5 6))
        (vec-const 'shuf2-2 '#(4 3 2 0))
        (vec-shuffle 'reg-A 'shuf0-2 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-2 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-2 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-2 'out)
        (vec-const 'shuf0-3 '#(1 6 5 6))
        (vec-const 'shuf1-3 '#(3 2 7 2))
        (vec-const 'shuf2-3 '#(0 1 4 5))
        (vec-shuffle 'reg-A 'shuf0-3 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-3 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-3 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-3 'out)
        (vec-const 'shuf0-4 '#(0 0 4 4))
        (vec-const 'shuf1-4 '#(0 1 4 5))
        (vec-const 'shuf2-4 '#(0 1 4 5))
        (vec-shuffle 'reg-A 'shuf0-4 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-4 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-4 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-4 'out))))

(current-solver (boolector))
(current-bitwidth 3)

;; Generate a spec for matrix multiply of a given size.
(define (matrix-multiply-spec mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (assert (= A-cols B-rows))
  (define C
    (matrix A-rows
            B-cols
            (build-vector (* A-rows B-cols)
                          (lambda (_) 0))))
  (for* ([i A-rows]
         [j B-cols])
    (define sum
      (apply
        +
        (for/list ([k A-cols])
          (* (matrix-ref mat-A i k)
             (matrix-ref mat-B k j)))))
    (matrix-set! C i j sum))

  (matrix-elements C))

(define (pr v)
  (pretty-print v)
  v)

; Generate program sketch for matrix multiply
(define (matrix-mul-shuffle-sketch mat-A mat-B iterations)
  (match-define (matrix A-rows A-cols _) mat-A)
  (match-define (matrix B-rows B-cols _) mat-B)
  ; Program preamble to define the inputs
  (define preamble
    (list
     (vec-extern-decl 'A (* A-rows A-cols) input-tag)
     (vec-extern-decl 'B (* B-rows B-cols) input-tag)
     (vec-extern-decl 'C (* A-rows B-cols) output-tag)))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated three shuffle vectors
    (match-define (list shuf-A shuf-B shuf-C) shufs)

    (define-symbolic* start integer?)
    (define-symbolic* end integer?)

    (list
     (vec-shuffle'reg-A shuf-A (list 'A))
     (vec-shuffle 'reg-B shuf-B (list 'B))
     (vec-shuffle 'reg-C shuf-C (list 'C))
     ; Uncomment to force the output writes to be continuous.
     (vec-void-app 'continuous-aligned-vec? (list shuf-C))
     (vec-app 'out 'vec-mac (list 'reg-C 'reg-A 'reg-B))
     (vec-shuffle-set! 'C shuf-C 'out)))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 3))

  (prog
   (append preamble
           (sketch-compute-shuffle-interleave
            shuffle-gen
            compute-gen
            iterations))))

; Run a matrix multiply sketch with symbolic inputs. If input matrices
; are missing, interp will generate fresh symbolic values.
(define (run-matrix-mul-sketch sketch
                               C-size
                               cost-fn
                               [mat-A #f]
                               [mat-B #f])

  (define env (make-hash))
  (when (and mat-A mat-B)
    (match-define (matrix A-rows _ A-elements) mat-A)
    (match-define (matrix _ B-cols B-elements) mat-B)
    (hash-set! env 'A A-elements)
    (hash-set! env 'B B-elements)
    (hash-set! env 'C (make-vector C-size 0)))

  (define-values (_ cost)
    (interp sketch
            env
            #:symbolic? #t
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac
                           'continuous-aligned-vec?
                           (curry continuous-aligned-vec? (current-reg-size)))))

  (list (vector-take (hash-ref env 'C) C-size) cost))

; Get statistics on a proposed synthesis solution
(define (get-statistics C-size sol)
  (match-let*
    ([(list _ uniq-cost) (run-matrix-mul-sketch
                      sol
                      C-size
                      (make-shuffle-unique-cost))]
     [(list _ regs-cost) (run-matrix-mul-sketch
                      sol
                      C-size
                      (make-register-cost 4))]
     [(list _ class-uniq-cost) (run-matrix-mul-sketch
                            sol
                            C-size
                            (make-shuffle-unique-cost prefix-equiv))])
    (pretty-print sol)
    (pretty-print `(unique-idxs-cost: ,uniq-cost))
    (pretty-print `(class-based-unique-idxs-cost: ,class-uniq-cost))
    (pretty-print `(registers-touched-cost: ,regs-cost))
    (pretty-print '-------------------------------------------------------)))


; Describe the configuration parameters for this benchmarks
(define matrix-mul:keys
  (list 'A-rows 'A-cols 'B-rows 'B-cols 'iterations 'reg-size))


; Run matrix multiply experiment with the given spec.
; Requires that spec be a hash with all the keys describes in matrix-mul:keys.
(define (matrix-mul:run-experiment spec file-writer)
  (pretty-print `("Running matrix multiply with config: "
                  ,spec))
  (define A-rows (hash-ref spec 'A-rows))
  (define A-cols (hash-ref spec 'A-cols))
  (define B-rows (hash-ref spec 'B-rows))
  (define B-cols (hash-ref spec 'B-cols))
  (define iterations (hash-ref spec 'iterations))
  (define reg-size (hash-ref spec 'reg-size))

  (assert (equal? A-cols B-rows)
          "matrix-mul:run-experiment: Invalid matrix sizes. A-cols not equal to B-rows")

  ; Run the synthesis query
  (parameterize [(current-reg-size reg-size)]
    (define A (make-symbolic-matrix A-rows A-cols))
    (define B (make-symbolic-matrix B-rows B-cols))
    (define C-size (* A-rows B-cols))

    (define reg-upper-bound
      (max (quotient (* A-rows A-cols) (current-reg-size))
           (quotient (* B-rows B-cols) (current-reg-size))
           (current-reg-size)))

    ; Generate sketch prog
    (define mmul (matrix-mul-shuffle-sketch A B iterations))

    ; Define the cost function
    (define cost-fn
      (let ([cost-1 (make-shuffle-unique-cost prefix-equiv)]
            [cost-2 (make-register-cost reg-upper-bound)])
        (lambda (inst env)
          (+ (cost-1 inst env) (cost-2 inst env)))))

    ; Create function for sketch evaluation
    (define (sketch-func args)
      (apply (curry run-matrix-mul-sketch
                    mmul
                    C-size
                    cost-fn)
             args))

    ; Functionalize spec for minimization prog
    (define (spec-func args)
      (apply matrix-multiply-spec args))

    ; Get a generator back from the synthesis procedure
    (define model-generator
      (synth-prog spec-func
                  sketch-func
                  (list A B)
                  #:get-inps (lambda (args) (flatten
                                              (map matrix-elements args)))
                  #:min-cost 0))

    ; Keep minimizing solution in the synthesis procedure and generating new
    ; solutions.
    (for ([(model cost) (sol-producer model-generator)])
      (if (sat? model)
        (let ([prog (evaluate mmul model)])
          (pretty-print prog)
          #;(verify-prog example prog
                       #:fn-map (hash 'vec-mac vector-mac
                                      'continuous-aligned-vec?
                                      (curry continuous-aligned-vec? (current-reg-size))))
          #;(file-writer prog cost))
        (pretty-print (~a "failed to find solution: " model))))))
