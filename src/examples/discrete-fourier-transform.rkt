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

(provide dft:keys
         dft:only-spec
         dft:run-experiment)

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

(define (dft-sketch N x fn-map iterations)

  ; Program preamble to define the "zero" vector, inputs and constants
  (define preamble
    (list
     (vec-extern-decl 'x N input-tag)
     (vec-extern-decl 'x-real N output-tag)
     (vec-extern-decl 'x-img N output-tag)
     (vec-extern-decl 'P N output-tag)
     (vec-const 'Z (make-v-list-zeros 1) float-type)
     (vec-const 'pi-vec (make-v-list (current-reg-size) `pi) float-type)
     (vec-const 'N-vec (make-v-list (current-reg-size) N) float-type)
     (vec-decl 'reg-x-real (current-reg-size))
     (vec-decl 'reg-x-img (current-reg-size))))

  (define-values (x-real-ids x-real-loads x-real-stores)
    (partition-v-list 'x-real N))

  (define-values (x-img-ids x-img-loads x-img-stores)
    (partition-v-list 'x-img N))

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
        (for/list ([i (in-range (* N N))]) i)))

    (define (choose-idx-vec)
      (for/list ([_ (in-range (current-reg-size))])
        (box (* 2 (choose-idx)))))

    ; Choose an output partition based on the iteration to both read and write
    (define out-idx (floor (/ iteration N)))
    (define real-out (list-ref x-real-ids out-idx))
    (define img-out (list-ref x-img-ids out-idx))
    (define compute-core
      (list
        ; 2*pi*n*k/N
        (vec-const 'idxs-prod (choose-idx-vec) float-type)
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

(define (run-sketch sketch cost-fn pi-sym N x)
  (define-values (out-env cost)
    (interp sketch
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac
                           'vec-mul vector-multiply
                           'vec-s-div vector-s-divide
                           'vec-cos vector-cos
                           'vec-sin vector-sin
                           'vec-negate vector-negate
                           'pi pi-sym)
            (list (cons 'x x)
                  (cons 'x-real (make-v-list-zeros N))
                  (cons 'x-img (make-v-list-zeros N))
                  (cons 'P (make-v-list-zeros N)))))

  ; For now, append x-real, x-img, and P
  (list (flatten (list (take (hash-ref out-env 'x-real) N)
                       (take (hash-ref out-env 'x-img) N)
                     ; (take (hash-ref out-env 'P) N)))
                       ))
        cost))

; Describe the configuration parameters for this benchmarks
(define dft:keys
  (list 'N 'reg-size))

; Run DFT experiment with the given spec.
; Requires that spec be a hash with all the keys describes in dft:keys.
(define (dft:run-experiment spec file-writer)
  (pretty-print (~a "Running DFT with config: " spec))
  (define N (hash-ref spec 'N))
  (define reg-size (hash-ref spec 'reg-size))
  (define pre-reg-of (and (hash-has-key? spec 'pre-reg-of)
                          (hash-ref spec 'pre-reg-of)))

  ; Run the synthesis query
  (parameterize [(current-reg-size reg-size)]

    ; Define input
    (match-define (list x)
      (for/list ([n (in-range 1)])
        (make-symbolic-v-list N)))

    ; Calculate the number of iterations necessary
    (define iterations
      (let* ([out-reg-count (exact-ceiling (/ N (current-reg-size)))]
             [comp-per-reg N])
        (* out-reg-count comp-per-reg)))

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

    ; Generate sketch prog
    (define sketch (dft-sketch N x fn-map iterations))

    ; Create function for sketch evaluation
    (define (sketch-func args)
      (apply (curry run-sketch
                    sketch
                    (cost-fn)
                    pi-sym)
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
                                          (list `cos `sin))))))
                  #:min-cost 0
                  ; #:assume (trig-facts pi-sym)
                  ))

    ; Keep minimizing solution in the synthesis procedure and generating new
    ; solutions.
    (for ([(model cost) (sol-producer model-generator)])
      (if (sat? model)
        ; We need to resolve the choose* expressions to constant constants even
        ; if unconstrained, so call complete-solution
        (let* ([sol (complete-solution model (symbolics sketch))]
               [prog (evaluate sketch sol)])
            (pretty-print (bitvector->integer cost))
            (file-writer prog cost))
          (pretty-print (~a "failed to find solution: " model))))))

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
      (define-symbolic* pi-sym (bitvector (value-fin)))

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
