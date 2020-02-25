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
(define (dft-spec N x x-real x-img P)

  (for ([k (in-range N)])
    (vector-set! x-real k 0)
    (vector-set! x-img k 0)
    (for ([n (in-range N)])
      (define partial (/ (* pi 2 n k) N))

      ; Real part of x[k]
      (define real-val (* (vector-ref x n) (cos partial)))
      (vector-set! x-real k (+ (vector-ref x-real k) real-val))

      ; Imaginary part of x[k]
      (define img-val (* (vector-ref x n) (sin partial)))
      (vector-set! x-img k (- (vector-ref x-img k) img-val)))

    ; Power at kth frequency bin
    (define val
      (+ (expt (vector-ref x-real k) 2) (expt (vector-ref x-img k) 2)))
    (vector-set! P k val))
  x-real)

(define (dft-sketch N x x-real x-img P iterations)

  ; Program preamble to define the "zero" vector, inputs and constants
  (define 2-pi-div-N (/ (* 2 pi) N))
  (define preamble
    (list
     (vec-extern-decl 'x N)
     (vec-extern-decl 'x-real N)
     (vec-extern-decl 'x-img N)
     (vec-extern-decl 'P N)
     (vec-const 'Z (vector 0))
     (vec-const '2-pi-div-N (make-vector (current-reg-size) 2-pi-div-N))))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated 4 shuffle vectors
    (match-define (list shuf-x shuf-x-real shuf-x-img shuf-P) shufs)

    (define (choose-idx)
      (choose 0 1 2 3 4 5 6 7))

    (list
     (vec-shuffle'reg-x shuf-x (list 'x 'Z))
     (vec-shuffle 'reg-x-real shuf-x-real (list 'x-real))
     (vec-shuffle 'reg-x-img shuf-x-img (list 'x-img))
     (vec-shuffle 'reg-P shuf-P (list 'P))

     (vec-const 'idxs-outer (make-vector (current-reg-size) (choose-idx)))
     (vec-const 'idxs-inner (make-vector (current-reg-size) (choose-idx)))
     ; TODO: continuous aligned
     (vec-app 'mul-tmp-1 'vec-mul (list 'idxs-outer 'idxs-inner))
     (vec-app 'mul-tmp-2 'vec-mul (list 'mul-tmp-1 '2-pi-div-N))
     (vec-app 'cos-tmp 'vec-cos (list 'mul-tmp-2))
     (vec-app 'out 'vec-mac (list 'reg-x-real 'reg-x 'cos-tmp))
     (vec-shuffle-set! 'x-real shuf-x-real 'out)
     (vec-void-app 'continuous-aligned-vec? (list shuf-x-real))))

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
  ; TODO: replace with real implementations
  (define dummy-func (thunk* (make-vector 4 0)))

  (define-values (out-env cost)
    (interp sketch
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac
                           'vec-mul dummy-func
                           'vec-cos dummy-func
                           'continuous-aligned-vec?
                           (curry continuous-aligned-vec? (current-reg-size)))
            (list (cons 'x x)
                  (cons 'x-real x-real)
                  (cons 'x-img x-img)
                  (cons 'P P))))

  ; Just process x-real for now
  (values (vector-take (hash-ref out-env 'x-real) N)
          cost))

; Run the synthesis query
(parameterize [(current-reg-size 4)]

  ; Define inputs
  (define N 8)
  (match-define (list x x-real x-img P)
    (for/list ([n (in-range 4)])
      (make-symbolic-vector real? N)))

  (dft-spec N x x-real x-img P)

  ; Generate sketch prog
  (define sketch (dft-sketch N x x-real x-img P 16))

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
           args))

  ; Functionalize spec for minimization prog
  (define (spec-func args)
    (apply dft-spec args))

  ; Get a generator back from the synthesis procedure
  (define model-generator
    (synth-prog spec-func
                sketch-func
                (list N x x-real x-img P)
                #:get-inps (lambda (args)
                             (flatten (map vector->list
                                           (filter vector? args))))
                #:min-cost 0))

  ; Keep minimizing solution in the synthesis procedure and generating new
  ; solutions.
  (for ([model (in-producer model-generator (void))])
    (if (sat? model)
      (begin
        (pretty-print "MODEL")
        (pretty-print (evaluate sketch model)))
      (pretty-print (~a "failed to find solution: " model)))))


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
