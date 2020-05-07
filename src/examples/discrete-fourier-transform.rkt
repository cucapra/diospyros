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
         rosette/solver/smt/boolector
         rosette/lib/synthax)

; Given an array x of length N, compute the real and imaginary coefficients
; and the power spectrum
(define (dft-spec N x x-real x-img P fn-map)
  (for ([k (in-range N)])
    (define bv-k (bv-index k))
    (bv-list-set! x-real bv-k (bv-value 0))
    (bv-list-set! x-img bv-k (bv-value 0))
    (for ([n (in-range N)])
      (define partial (/ (* pi 2 n k) N))

      ; Real part of x[k]
      (define cosine (hash-ref fn-map `cos))
      (define sine (hash-ref fn-map `sin))
      (define real-val (bvmul (bv-list-get x (bv-index n))
                              (bv-value (round (cosine partial)))))
      (bv-list-set! x-real bv-k (bvadd (bv-list-get x-real bv-k)
                                       real-val))

      ; Imaginary part of x[k]
      (define img-val (bvmul (bv-list-get x (bv-index n))
                             (bv-value (round (sine partial)))))
      (bv-list-set! x-img bv-k (bvsub (bv-list-get x-img bv-k) img-val)))

    ; Power at kth frequency bin
    (define val
      (let* ([x-r (bv-list-get x-real bv-k)]
             [x-i (bv-list-get x-img bv-k)])
        (bvadd (bvmul x-r x-r)
               (bvmul x-i x-i))))
    (bv-list-set! P bv-k val))
  x-real)

(define (dft-sketch N x x-real x-img P c s iterations)

  ; Program preamble to define the "zero" vector, inputs and constants
  (define 2-pi-div-N (/ (* 2 pi) N))
  (define preamble
    (list
     (vec-extern-decl 'x N input-tag)
     (vec-extern-decl 'x-real N output-tag)
     ;(vec-extern-decl 'x-img N output-tag)
     ;(vec-extern-decl 'P N output-tag)
     (vec-const 'Z (make-bv-list-zeros 1))
     (vec-const '2-pi-div-N (make-bv-list (current-reg-size) 2-pi-div-N))))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated 4 shuffle vectors
    (match-define (list shuf-x shuf-x-real shuf-x-img shuf-P) shufs)

    ;(define (choose-idx)(choose 0 1))
    (define (choose-idx) 1)

    (list
     (vec-shuffle 'reg-x shuf-x (list 'x 'Z))
     (vec-shuffle 'reg-x-real shuf-x-real (list 'x-real))
     ;(vec-shuffle 'reg-x-img shuf-x-img (list 'x-img))
     ;(vec-shuffle 'reg-P shuf-P (list 'P))

     (vec-const 'idxs-outer (make-bv-list (current-reg-size) (choose-idx)))
     (vec-const 'idxs-inner (make-bv-list (current-reg-size) (choose-idx)))
     ; TODO: continuous aligned
     (vec-app 'mul-tmp-1 'vec-mul (list 'idxs-outer 'idxs-inner))
     (vec-app 'mul-tmp-2 'vec-mul (list 'mul-tmp-1 '2-pi-div-N))
     ;(vec-app 'cos-tmp 'vec-cos (list 'mul-tmp-2))
     (vec-app 'cos-tmp `vec-mul (list 'mul-tmp-2 'mul-tmp-2))
     (vec-app 'out 'vec-mac (list 'reg-x-real 'reg-x 'cos-tmp))
     (vec-shuffle-set! 'x-real shuf-x-real 'out)))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 4))

  (prog
   (append preamble
           (sketch-compute-shuffle-interleave
            shuffle-gen
            compute-gen
            iterations))))

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
  (values (vector-take (hash-ref out-env 'x-real) N)
          cost))

#|
; Run the synthesis query
(parameterize [(current-reg-size 4)]

  ; Define inputs
  (define N 2)
  (match-define (list x x-real x-img P)
    (for/list ([n (in-range 4)])
      (make-bv-list-empty  N)))

  (define fn-map (hash `cos cosine `sin sine))
  (pretty-print fn-map)
  (dft-spec N x x-real x-img P fn-map)

  ; Generate sketch prog
  (define sketch (dft-sketch N x x-real x-img P cosine sine 1))

  ; Define cost function
    (define (cost-fn)
      (let ([cost-1 (make-shuffle-unique-cost prefix-equiv)]
            [cost-2 (make-register-cost 4)])
        (lambda (inst env)
          (+ (cost-1 inst env) (cost-2 inst env)))))

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
                             (flatten (list (filter vector? args)
                                            (filter fv? args))))
                #:min-cost 0))

  ; Keep minimizing solution in the synthesis procedure and generating new
  ; solutions.
  ;void
  ;#|
  (for ([model (in-producer model-generator (void))])
    (if (sat? model)
      (begin
        (pretty-print "MODEL")
        (pretty-print (evaluate sketch model)))
      (pretty-print (~a "failed to find solution: " model))))
;|#
  )

|#


; DFT(5,6,7,8)

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
       (value-bv-list 13 -1 -1 -1))
     (define gold-img
       (value-bv-list 0 -1 0 1))
     (define fn-map (hash `cos cos `sin sin))
     (dft-spec N x xReal xImg P fn-map)
     (check-within xReal gold-real 0.001)
     (check-within xImg gold-img 0.001)))))
