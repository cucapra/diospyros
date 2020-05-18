#lang rosette

(require "../ast.rkt"
         "../configuration.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../utils.rkt"
         "../prog-sketch.rkt"
         "../synth.rkt"
         racket/trace
         racket/generator
         rosette/solver/smt/z3
         rosette/solver/smt/boolector
         rosette/lib/synthax
         rosette/lib/angelic)

; Given an array x of length N, compute the real and imaginary coefficients
; and the power spectrum
(define (dft-spec N x fn-map)
  (match-define (list x-real x-img P)
    (for/list ([n (in-range 3)])
      (make-bv-list-zeros N)))

  (for ([k (in-range N)])
    (define bv-k (bv-index k))
    (bv-list-set! x-real bv-k (bv-value 0))
    (bv-list-set! x-img bv-k (bv-value 0))
    (for ([n (in-range N)])
      ; Uninterpreted functions
      (define cosine (hash-ref fn-map `cos))
      (define sine (hash-ref fn-map `sin))
      (define pi (hash-ref fn-map `pi))

      (define partial (bvsdiv (bvmul pi (bv-value (* 2 n k)))
                              (bv-value N)))

      ; Real part of x[k]: x-real[k] += x[n] * cos(2*pi*n*k/N)
      (define real-val (bvmul (cosine partial)
                              (bv-list-get x (bv-index n))))

      (bv-list-set! x-real bv-k (bvadd (bv-list-get x-real bv-k)
                                       real-val))

      ; Imaginary part of x[k]: x-img[k] -= x[n] * sin(2*pi*n*k/N)
      (define img-val (bvmul (sine partial)
                      (bv-list-get x (bv-index n))))
      (bv-list-set! x-img bv-k (bvsub (bv-list-get x-img bv-k)
                                      img-val)))

    ; Power at kth frequency bin
    (define val
      (let* ([x-r (bv-list-get x-real bv-k)]
             [x-i (bv-list-get x-img bv-k)])
        (bvadd (bvmul x-r x-r)
               (bvmul x-i x-i))))
    (bv-list-set! P bv-k val))
  ;(flatten (list x-real x-img P)))
  (flatten (list x-real x-img)))

(define (dft-sketch N x fn-map iterations)

  ; Program preamble to define the "zero" vector, inputs and constants
  (define pi (hash-ref fn-map `pi))
  (define preamble
    (list
     (vec-extern-decl 'x N input-tag)
     (vec-extern-decl 'x-real N output-tag)
     (vec-extern-decl 'x-img N output-tag)
     (vec-extern-decl 'P N output-tag)
     (vec-const 'Z (make-bv-list-zeros 1))
     (vec-const 'pi-vec (make-bv-list-bvs (current-reg-size) pi))
     (vec-const 'N-vec (make-bv-list (current-reg-size) N))
     (vec-decl 'reg-x-real (current-reg-size))
     (vec-decl 'reg-x-img (current-reg-size))))

  (define-values (x-real-ids x-real-loads x-real-stores)
    (partition-bv-list 'x-real N))

  (define-values (x-img-ids x-img-loads x-img-stores)
    (partition-bv-list 'x-img N))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated 4 shuffle vectors
    (match-define (list shuf-x) shufs)

    ; Shuffle the inputs with symbolic shuffle vectors
    (define input-shuffles
      (list
        (vec-shuffle 'reg-x shuf-x (list 'x 'Z))))

    ; Partial products are 2*pi*n*k/N. n and k <= N
    (define (choose-idx)
      (apply choose*
        (for/list ([i (in-range (* N N))])
          (bv-value i))))

    (define (choose-idx-vec)
      (for/list ([_ (in-range (current-reg-size))])
        (box (bvmul (bv-value 2) (choose-idx)))))

    ; Choose an output partition based on the iteration to both read and write
    (define out-idx (floor (/ iteration N)))
    (define real-out (list-ref x-real-ids out-idx))
    (define img-out (list-ref x-img-ids out-idx))
    (define compute-core
      (list
        ; 2*pi*n*k/N
        (vec-const 'idxs-prod (choose-idx-vec))
        (vec-app 'mul-prod 'vec-mul (list 'idxs-prod 'pi-vec))
        (vec-app 'div 'vec-s-div (list 'mul-prod 'N-vec))

        ; Real part of x[k]: x-real[k] += x[n] * cos(2*pi*n*k/N)
        (vec-write 'reg-x-real real-out)
        (vec-app 'cos-tmp 'vec-cos (list 'div))
        (vec-app 'real-out 'vec-mac (list 'reg-x-real 'reg-x 'cos-tmp))
        (vec-write real-out 'real-out)

        ; Imaginary part of x[k]: x-img[k] -= x[n] * sin(2*pi*n*k/N)
        (vec-write 'reg-x-img img-out)
        (vec-app 'sin-tmp 'vec-sin (list 'div))
        (vec-void-app 'vec-negate (list 'sin-tmp))
        (vec-app 'img-out 'vec-mac (list 'reg-x-img 'reg-x 'sin-tmp))
        (vec-write img-out 'img-out)))

    (append input-shuffles compute-core))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 1))

  (prog
   (append preamble
           x-real-loads
           x-img-loads
           (sketch-compute-shuffle-interleave
             shuffle-gen
             compute-gen
             iterations)
           x-real-stores
           x-img-stores)))

(define (run-sketch sketch cost-fn N x)
  (define-values (out-env cost)
    (interp sketch
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac
                           'vec-mul vector-multiply
                           'vec-s-div vector-s-divide
                           'vec-cos vector-cos
                           'vec-sin vector-sin
                           'vec-negate vector-negate)
            (list (cons 'x x)
                  (cons 'x-real (make-bv-list-zeros N))
                  (cons 'x-img (make-bv-list-zeros N))
                  (cons 'P (make-bv-list-zeros N)))))

  ; For now, append x-real, x-img, and P
  (list (flatten (list
                       (take (hash-ref out-env 'x-real) N)
                       (take (hash-ref out-env 'x-img) N)
                              ))
                             ; (take (hash-ref out-env 'P) N)))
        cost))

(define (trig-facts pi-sym)
  (list
    ; ; Pi facts
    (bvslt pi-sym (bv-value 4))
    (bvslt (bv-value 1) pi-sym)

    ; Cosine facts
    ; (bveq (cosine (bv-value 0)) (bv-value 1))
    ; (bveq (cosine pi-sym) (bv-value -1))
    ; (bveq (cosine (bvmul pi-sym (bv-value 2))) (bv-value 1))
    ; (bveq (cosine (bvsdiv pi-sym (bv-value 2))) (bv-value 0))
    ; (bveq (cosine (bvmul (bv-value 3)
    ;                              (bvsdiv pi-sym (bv-value 2))))
    ;               (bv-value 0))

    ; ; Sine facts
    ; (bveq (sine (bv-value 0)) (bv-value 0))
    ; (bveq (sine pi-sym) (bv-value 0))
    ; (bveq (sine (bvmul pi-sym (bv-value 2))) (bv-value 0))
    ; (bveq (sine (bvsdiv pi-sym (bv-value 2))) (bv-value 1))
    ))

;Run the synthesis query
(parameterize [(current-reg-size 4)]

  ; Define inputs
  (define N 5)
  (match-define (list x)
    (for/list ([n (in-range 1)])
      (make-symbolic-bv-list-values N)))

  ; Sanity check value finitization
  (when (>= (* 4 2 N N) (expt 2 (value-fin)))
    (error "Need larger value bitvector for DFT"))

  (define-symbolic* pi-sym (bitvector (value-fin)))
  (define fn-map (hash `cos cosine `sin sine `pi pi-sym))

    ; Functionalize spec for minimization prog
  (define (spec-func args)
    (apply dft-spec (append (take args 2) (list fn-map))))

  ; Define cost function
  (define (cost-fn)
    (let ([cost-1 (make-shuffle-unique-cost prefix-equiv)]
          [cost-2 (make-register-cost reg-of-idx)])
      (lambda (inst env)
        (bvadd (cost-1 inst env) (cost-2 inst env)))))

  (define iterations
    (let* ([out-reg-count (exact-ceiling (/ N (current-reg-size)))]
           [comp-per-reg N])
      (* out-reg-count comp-per-reg)))

  ; Generate sketch prog
  (define sketch (dft-sketch N x fn-map iterations))

  ; Create function for sketch evaluation
  (define (sketch-func args)
    (apply (curry run-sketch
                  sketch
                  (cost-fn))
           (take args 2)))

  ; Get a generator back from the synthesis procedure
  (define model-generator
    (synth-prog spec-func
                sketch-func
                (list N x fn-map)
                #:get-inps (lambda (args)
                             (flatten
                               (list
                                 ; bv-list inputs
                                 (map (curry map unbox) (filter list? args))
                                 ; trig functions
                                 (let ([fn-map (first (filter hash? args))])
                                   (map (curry hash-ref fn-map)
                                        (list `cos `sin ))))))
                #:min-cost (bv-cost 0)
                #:assume (trig-facts pi-sym)))

  ; Keep minimizing solution in the synthesis procedure and generating new
  ; solutions.
  ;void
  (for ([(model cost) (sol-producer model-generator)])
    (if (sat? model)
      (let ([prog (evaluate sketch model)])
          (pretty-print model)
          (pretty-print (bitvector->integer cost))
          (pretty-print (concretize-prog prog)))
        (pretty-print (~a "failed to find solution: " model)))))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
   (test-suite
    "dft tests"
    (test-case
      "Spec correctness"
      (define N 4)
      (define x (value-bv-list 5 6 7 8))
      (define gold-real
        (value-bv-list 26 -2 -2 -2))
      (define gold-img
        (value-bv-list 0 2 0 -2))
      (define-symbolic* pi-sym (bitvector (value-fin)))

      (define fn-map (hash `cos cosine `sin sine `pi pi-sym))

      (define-values (x-real)
        (dft-spec N x fn-map))

      (define (true-with-trig exprs)
        (define res (verify #:assume (begin
                                       (for ([to-assert (trig-facts pi-sym)])
                                         (assert to-assert)))
                            #:guarantee (begin
                                          (for ([to-assert exprs])
                                            (assert to-assert)))))
        (unsat? res))

      ; (check-true
      ;   (true-with-trig
      ;     (for/list ([x-I xImg]
      ;                [g-I gold-img])
      ;       (bveq (unbox x-I) (unbox g-I)))))
      ; (check-true
      ;   (true-with-trig
      ;     (for/list ([x-R x-real]
      ;                [g-R gold-real])
      ;       (bveq (unbox x-R) (unbox g-R)))))
      void
      ))))
