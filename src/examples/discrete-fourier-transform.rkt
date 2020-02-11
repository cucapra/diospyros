#lang rosette

(require "../ast.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../matrix-utils.rkt"
         "../prog-sketch.rkt"
         "../synth.rkt"
         racket/trace
         racket/generator
         rosette/solver/smt/z3
         rosette/solver/smt/boolector)

; Given
(define (dft-spec N x x-real x-img P)

  (for ([k (in-range N)])
    ; Real part of x[k]
    (vector-set! x-real k 0)
    (for ([n (in-range N)])
      (define val
        (* (vector-ref x n) (cos (/ (* pi 2 n k) N))))
      (vector-set! x-real k (+ (vector-ref x-real k) val)))

    ; Imaginary part of x[k]
    (vector-set! x-img k 0)
    (for ([n (in-range N)])
      (define val
        (* (vector-ref x n) (sin (/ (* pi 2 n k) N))))
      (vector-set! x-img k (- (vector-ref x-img k) val)))

    ; Power at kth frequency bin
    (define val
      (+ (expt (vector-ref x-real k) 2) (expt (vector-ref x-img k) 2)))
    (vector-set! P k val)))

; Run the synthesis query
(parameterize [(current-reg-size 4)]

  (define N 8)

  ; Define inputs
  (match-define (list x x-real x-img P)
    (for/list ([n (in-range 4)])
      (make-symbolic-vector N)))

  (dft-spec N x x-real x-img P)

  ; Generate sketch prog

  ; Define cost function

  ; Create function for sketch evaluation

  ; Function for spec evaluation

  ; Show the shape of the spec

  ; Get a generator back from the synthesis procedure.

  ; Keep generating solutions.
  )


(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
   (test-suite
    "dft tests"
    (test-case
     "Spec correctness"
     (define N 8)
     (define x (vector 1 1 1 1 0 0 0 0))
     (match-define (list xReal xImg P)
       (for/list ([n (in-range 3)])
         (make-vector N 0.0)))
     (define gold-real
       (vector 4 1 0 1 0 1 0 1))
     (define gold-img
       (vector 0 -2.41421356 0 -0.41421356 0 0.41421356 0 2.41421356))
     (dft-spec N x xReal xImg P)
     (check-within xReal gold-real 0.001)
     (check-within xImg gold-img 0.001)))))
