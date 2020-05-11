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
(define (dft-spec N x x-real x-img P fn-map)
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
      (define real-val (bvmul (bv-list-get x (bv-index n))
                              (cosine partial)))
      (bv-list-set! x-real bv-k (bvadd (bv-list-get x-real bv-k)
                                       real-val))

      ; Imaginary part of x[k]: x-img[k] -= x[n] * sin(2*pi*n*k/N)
      (define img-val (bvmul (bv-list-get x (bv-index n))
                             (sine partial)))
      (bv-list-set! x-img bv-k (bvsub (bv-list-get x-img bv-k)
                                      img-val)))

    ; Power at kth frequency bin
    (define val
      (let* ([x-r (bv-list-get x-real bv-k)]
             [x-i (bv-list-get x-img bv-k)])
        (bvadd (bvmul x-r x-r)
               (bvmul x-i x-i))))
    (bv-list-set! P bv-k val))
  x-real)

(define (dft-sketch N x x-real x-img P fn-map iterations)

  ; Program preamble to define the "zero" vector, inputs and constants
  (define pi (hash-ref fn-map `pi))
  (define 2-pi-div-N (bvsdiv (bvmul pi (bv-value 2))
                             (bv-value N)))
  (define preamble
    (list
     (vec-extern-decl 'x N input-tag)
     (vec-extern-decl 'x-real N output-tag)
     ;(vec-extern-decl 'x-img N output-tag)
     ;(vec-extern-decl 'P N output-tag)
     (vec-const 'Z (make-bv-list-zeros 1))
     (vec-const '2-pi-div-N (for/list ([_ (in-range (current-reg-size))])
                              (box 2-pi-div-N)))))

  (define-values (x-real-ids x-real-loads x-real-stores)
    (partition-bv-list 'x-real N))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated 4 shuffle vectors
    (match-define (list shuf-x shuf-x-real shuf-x-img shuf-P) shufs)

    ; Shuffle the inputs with symbolic shuffle vectors
    (define input-shuffles
      (list
        (vec-shuffle 'reg-x shuf-x (list 'x 'Z))
        (vec-shuffle 'reg-x-real shuf-x-real (list 'x-real))))

    ;(define (choose-idx)(choose 0 1))
    (define (choose-idx) 1)

    ; Use choose* to select an output register to both read and write
    (define output-mac
      (apply choose*
        (map (lambda (out-reg)
          (list
            (vec-write 'reg-x-real out-reg)
            (vec-const 'idxs-outer (make-bv-list (current-reg-size) (choose-idx)))
            (vec-const 'idxs-inner (make-bv-list (current-reg-size) (choose-idx)))
            ; TODO: continuous aligned
            (vec-app 'mul-tmp-1 'vec-mul (list 'idxs-outer 'idxs-inner))
            (vec-app 'mul-tmp-2 'vec-mul (list 'mul-tmp-1 '2-pi-div-N))
            ;(vec-app 'cos-tmp 'vec-cos (list 'mul-tmp-2))
            (vec-app 'cos-tmp `vec-mul (list 'mul-tmp-2 'mul-tmp-2))
            (vec-app 'out 'vec-mac (list 'reg-x-real 'reg-x 'cos-tmp))
            (vec-write out-reg 'out)))
        x-real-ids)))

    (append input-shuffles output-mac))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 4))

  (prog
   (append preamble
           x-real-loads
           (sketch-compute-shuffle-interleave
             shuffle-gen
             compute-gen
             iterations)
           x-real-stores)))

(define (run-sketch sketch cost-fn N x x-real x-img P)
  (define-values (out-env cost)
    (interp sketch
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac
                           'vec-mul vector-multiply
                           'vec-cos vector-cos)
            (list (cons 'x x)
                  (cons 'x-real x-real)
                  (cons 'x-img x-img)
                  (cons 'P P))))

  ; Just process x-real for now
  (list (take (hash-ref out-env 'x-real) N)
        cost))

;Run the synthesis query
(parameterize [(current-reg-size 4)]

  ; Define inputs
  (define N 2)
  (match-define (list x x-real x-img P)
    (for/list ([n (in-range 4)])
      (make-bv-list-zeros N)))

  (define-symbolic* pi-sym (bitvector (value-fin)))
  (define fn-map (hash `cos cosine `sin sine `pi pi-sym))
  (dft-spec N x x-real x-img P fn-map)

  ; Generate sketch prog
  (define sketch (dft-sketch N x x-real x-img P fn-map 1))

  ; Define cost function
  (define (cost-fn)
    (let ([cost-1 (make-shuffle-unique-cost prefix-equiv)]
          [cost-2 (make-register-cost reg-of-idx)])
      (lambda (inst env)
        (bvadd (cost-1 inst env) (cost-2 inst env)))))

  ; Create function for sketch evaluation
  (define (sketch-func args)
    (apply (curry run-sketch
                  sketch
                  (cost-fn))
           (take args 5)))

  ; Functionalize spec for minimization prog
  (define (spec-func args)
    (apply dft-spec (append (take args 5) (list fn-map))))

  ; Get a generator back from the synthesis procedure
  (define model-generator
    (synth-prog spec-func
                sketch-func
                (list N x x-real x-img P cosine sine)
                #:get-inps (lambda (args)
                             (flatten (list (filter list args)
                                            (filter fv? args))))
                #:min-cost (bv-cost 0)))

  ; Keep minimizing solution in the synthesis procedure and generating new
  ; solutions.
  ;void
  (for ([(model cost) (sol-producer model-generator)])
    (if (sat? model)
      (let ([prog (evaluate sketch model)])
          (pretty-print cost)
          (pretty-print (concretize-prog prog)))
        (pretty-print (~a "failed to find solution: " model)))))


(define (trig-facts pi-sym)
  (begin
    ; Pi facts
    (assert (bvslt pi-sym (bv-value 4)))
    (assert (bvslt (bv-value 2) pi-sym))

    ; Cosine facts
    (assert (bveq (cosine (bv-value 0)) (bv-value 1)))
    (assert (bveq (cosine pi-sym) (bv-value -1)))
    (assert (bveq (cosine (bvmul pi-sym (bv-value 2))) (bv-value 1)))
    (assert (bveq (cosine (bvsdiv pi-sym (bv-value 2))) (bv-value 0)))
    (assert (bveq (cosine (bvmul (bv-value 3)
                                 (bvsdiv pi-sym (bv-value 2))))
                  (bv-value 0)))

    ; Sine facts
    (assert (bveq (sine (bv-value 0)) (bv-value 0)))
    (assert (bveq (sine pi-sym) (bv-value 0)))
    (assert (bveq (sine (bvmul pi-sym (bv-value 2))) (bv-value 0)))
    (assert (bveq (sine (bvsdiv pi-sym (bv-value 2))) (bv-value 1)))))

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
      (match-define (list xReal xImg P)
        (for/list ([n (in-range 3)])
          (make-bv-list-zeros N)))
      (define gold-real
        (value-bv-list 26 -2 -2 -2))
      (define gold-img
        (value-bv-list 0 2 0 -2))
      (define-symbolic* pi-sym (bitvector (value-fin)))

      (define fn-map (hash `cos cosine `sin sine `pi pi-sym))
      (dft-spec N x xReal xImg P fn-map)

      (define (true-with-trig exprs)
        (pretty-print exprs)
        (define res (verify #:assume (trig-facts pi-sym)
                            #:guarantee (begin
                                          (for ([to-assert exprs])
                                            (pretty-print to-assert)
                                            (assert to-assert)))))
        (unsat? res))

      (check-true
        (true-with-trig
          (for/list ([x-I xImg]
                     [g-I gold-img])
            (bveq (unbox x-I) (unbox g-I)))))

      (check-true
        (true-with-trig
          (for/list ([x-R xReal]
                     [g-R gold-real])
            (bveq (unbox x-R) (unbox g-R)))))))))
