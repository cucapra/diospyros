#lang rosette

(require "../ast.rkt"
         "../configuration.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../utils.rkt"
         "../prog-sketch.rkt"
         "../verify.rkt"
         racket/trace
         racket/generator
         rosette/solver/smt/z3
         rosette/solver/smt/boolector
         rosette/lib/synthax
         rosette/lib/angelic)

(provide dft:keys
         dft:only-spec)

(define (dft:only-spec config)
  (error 'dft:only-spec "Only spec generation not supported for DFT"))

; Given an array x of length N, compute the real and imaginary coefficients
; and the power spectrum
(define (dft-spec N x fn-map)
  (match-define (list x-real x-img P)
    (for/list ([n (in-range 3)])
      (make-v-list-zeros N)))

  (for ([k (in-range N)])
    (v-list-set! x-real k 0)
    (v-list-set! x-img k 0)
    (for ([n (in-range N)])
      ; Uninterpreted functions
      (define cosine (hash-ref fn-map `cos))
      (define sine (hash-ref fn-map `sin))
      (define pi (hash-ref fn-map `pi))

      (define partial (/ (* pi (* 2 n k))
                              N))

      ; Real part of x[k]: x-real[k] += x[n] * cos(2*pi*n*k/N)
      (define real-val (* (cosine partial) (v-list-get x n)))
      (v-list-set! x-real k (+ (v-list-get x-real k) real-val))

      ; Imaginary part of x[k]: x-img[k] -= x[n] * sin(2*pi*n*k/N)
      (define img-val (* (sine partial) (v-list-get x n)))
      (v-list-set! x-img k (- (v-list-get x-img k) img-val)))

    ; Power at kth frequency bin
    (define val
      (let* ([x-r (v-list-get x-real k)]
             [x-i (v-list-get x-img k)])
        (+ (* x-r x-r) (* x-i x-i))))
    (v-list-set! P k val))
  ;(flatten (list x-real x-img P)))
  (flatten (list x-real x-img)))

; Describe the configuration parameters for this benchmarks
(define dft:keys
  (list 'N 'reg-size))


(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
   (test-suite
    "dft tests"
    (test-case
      "Spec correctness"
      (define N 2)
      (define x (v-list 0 1))
      (define-symbolic* pi-sym real?)

      (define gold-real
        (list
          (box (cosine 0))
          (box (cosine (/ (* 2 pi-sym) N)))))
      (define gold-img
        (list
          (box (- (sine 0)))
          (box (- (sine (/ (* 2 pi-sym) N))))))

      (define fn-map (hash `cos cosine `sin sine `pi pi-sym))

      (define-values (results)
        (dft-spec N x fn-map))

      (for/list ([x results]
                 [g (append gold-real gold-img)])
        (check-equal? (unbox x) (unbox g)))))))

      ; This strategy does not work, presumably  because the theory of
      ; bitvectors can't reason about fractional values in the sin and cosine,
      ; thus asserting conflicting values for (sine 0), for example
      ; (define (trig pi-sym)
      ;   (define-symbolic* x (bitvector (value-fin)))
      ;   (list
        ; Cosine facts
        ; (forall (list x)
        ;         (=>
        ;           (bveq 0
        ;                 (bvsrem x
        ;                         (bv-value 8)))
        ;           (bveq (cosine (bvsdiv (bvmul (bv-value x) pi-sym)
        ;                               (bv-value 4))
        ;                 (bv-value 1)))))
        ; (forall (list x)
        ;         (=>
        ;           (bveq 0
        ;                 (bvsrem (bvsub x (bv-value 4))
        ;                         (bv-value 8)))
        ;           (bveq (cosine (bvsdiv (bvmul (bv-value x) pi-sym)
        ;                               (bv-value 4))
        ;                 (bv-value -1)))))
        ; (forall (list x)
        ;         (=>
        ;           (bveq 0
        ;                 (bvsrem (bvsub x 2)
        ;                         (bv-value 8)))
        ;           (bveq (cosine (bvsdiv (bvmul (bv-value x) pi-sym)
        ;                               (bv-value 4))
        ;                 0))))
        ; Sine facts
        ; (forall (list x) (bveq (sine (bvmul x pi-sym))
        ;                        0))
        ; (forall (list x)
        ;         (=>
        ;           (bveq 0
        ;                 (bvsrem (bvsub x 2)
        ;                         (bv-value 8)))
        ;           (bveq (sine (bvsdiv (bvmul (bv-value x) pi-sym)
        ;                               (bv-value 4))
        ;                 (bv-value 1)))))
        ; (forall (list x)
        ;         (=>
        ;           (bveq 0
        ;                 (bvsrem (bvsub x (bv-value 6))
        ;                         (bv-value 8)))
        ;           (bveq (sine (bvsdiv (bvmul (bv-value x) pi-sym)
        ;                               (bv-value 4))
        ;                 (bv-value -1)))))))
        ; (define (true-with-trig exprs)
        ;   (define res (verify #:assume (begin
        ;                                  (for ([to-assert (trig pi-sym)])
        ;                                    (assert to-assert)))
        ;                       #:guarantee (begin
        ;                                     (for ([to-assert exprs])
        ;                                       (assert to-assert)))))
        ;   (unsat? res))
