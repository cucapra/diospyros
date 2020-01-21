#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "matrix-utils.rkt"
         "prog-sketch.rkt"
         "synth.rkt"
         racket/trace
         rosette/solver/smt/z3
         rosette/solver/smt/boolector)

(current-solver (boolector))
(current-bitwidth 8)

(define reg-size 4)

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


; Generate program sketch for matrix multiply
(define (matrix-mul-shuffle-sketch mat-A mat-B iterations)
  (match-define (matrix A-rows _ _) mat-A)
  (match-define (matrix _ B-cols _) mat-B)
  ; Program preamble to define the "zero" vector.
  (define preamble
    (list
      (vec-const 'Z (vector 0))))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated three shuffle vectors
    (match-define (list shuf-A shuf-B shuf-C) shufs)
    (list
      (vec-select 'reg-A shuf-A 'A 'Z)
      (vec-select 'reg-B shuf-B 'B 'Z)
      (vec-shuffle 'reg-C shuf-C 'C)
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

(define (run-matrix-mul-sketch sketch mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (define env (make-hash))
  (hash-set! env 'A A-elements)
  (hash-set! env 'B B-elements)
  (hash-set! env 'C (make-vector (* A-rows B-cols)
                                 0))

  (define cost
    (interp sketch
            env
            #:cost-fn (curry simple-shuffle-cost 4)
            #:fn-map (hash 'vec-mac vector-mac)))

  (values (hash-ref env 'C) cost))


(parameterize [(current-reg-size 4)]
  (define A (make-symbolic-matrix 2 3))
  (define B (make-symbolic-matrix 3 3))

  ; Generate sketch prog
  (define mmul (matrix-mul-shuffle-sketch A B 5))
  (define (sketch-func args)
    (apply (curry run-matrix-mul-sketch mmul) args))

  ; Functionalize spec for minimization prog
  (define (spec-func args)
    (apply matrix-multiply-spec args))

  (define model
    (synth-prog spec-func
                sketch-func
                (list A B)
                #:get-inps (lambda (args) (flatten
                                            (map matrix-elements args)))
                #:max-cost 40
                #:min-cost 20))

  (pretty-print (if (sat? model) (evaluate mmul model) model)))

