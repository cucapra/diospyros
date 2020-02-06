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

(current-solver (boolector))
(current-bitwidth 8)

; Given an NxN input matrix, returns a smaller convolved matrix.
(define (matrix-conv-spec input filter)
  (match-define (matrix i-rows i-cols _) input)
  (match-define (matrix f-rows f-cols _) filter)

  ; Return 0 if the access to the input matrix was out of bounds.
  (define (safe-access-input row col)
    (if (and (>= row 0) (>= col 0) (< row i-rows) (< col i-cols))
      (matrix-ref input row col)
      0))

  (define output
    (matrix i-rows i-cols (make-vector (* i-rows i-cols) 0)))

  (define-values (f-center-x f-center-y)
    (values (exact-floor (/ f-rows 2))
            (exact-floor (/ f-cols 2))))

  (for* ([inp-row (in-range i-rows)]
         [inp-col (in-range i-cols)])

    (define conv-res
      (let ([top-left-x (- inp-row f-center-x)]
            [top-left-y (- inp-col f-center-y)])
        (apply +
               (for*/list ([i (in-range f-rows)]
                           [j (in-range f-cols)])
                 (* (safe-access-input (+ top-left-x i) (+ top-left-y j))
                    (matrix-ref filter i j))))))
    (matrix-set! output inp-row inp-col conv-res))

  output)

; Tests to check conv implementation
(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "Convolution test"
      (test-case
        "Implementation works"
        (define input
          (vector 1 2 3
                  4 5 6
                  7 8 9))
        (define filter
          (vector -1 -2 -1
                  0  0  0
                  1  2  1))
        (define gold
          (vector  13  20  17
                   18  24  18
                  -13 -20 -17))
        (check-equal? (matrix-conv-spec (matrix 3 3 input)
                                        (matrix 3 3 filter))
                      (matrix 3 3 gold))))))


(define (conv-2d-sketch inp filt iterations)
  (match-define (matrix _ _ I-elements) inp)
  (match-define (matrix _ _ F-elements) filt)
  ; Program preamble to define the "zero" vector.
  (define preamble
    (list
     (vec-extern-decl 'I (vector-length I-elements))
     (vec-extern-decl 'O (vector-length I-elements))
     (vec-extern-decl 'F (vector-length F-elements))
     (vec-const 'Z (vector 0))))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated three shuffle vectors
    (match-define (list shuf-I shuf-F shuf-O) shufs)

    (define-symbolic* start integer?)
    (define-symbolic* end integer?)

    (list
     (vec-shuffle'reg-I shuf-I (list 'I 'Z))
     (vec-shuffle 'reg-F shuf-F (list 'F 'Z))
     (vec-shuffle 'reg-O shuf-O (list 'O))
     ; Uncomment to force the output writes to be continuous.
     ;(vec-app 'out 'continuous-vec? (list shuf-O))
     (vec-app 'out 'vec-mac (list 'reg-O 'reg-I 'reg-F))
     (vec-shuffle-set! 'O shuf-O 'out)))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 3))

  (prog
   (append preamble
           (sketch-compute-shuffle-interleave
            shuffle-gen
            compute-gen
            iterations))))


(define (run-sketch sketch cost-fn
                    [mat-I #f]
                    [mat-F #f])

  (define env (make-hash))
  (when (and mat-I mat-F)
    (match-define (matrix _ _ I-elements) mat-I)
    (match-define (matrix _ _ F-elements) mat-F)
    (hash-set! env 'I I-elements)
    (hash-set! env 'F F-elements)
    (hash-set! env 'O (make-vector (vector-length I-elements) 0)))

  (define cost
    (interp sketch
            env
            #:symbolic? #f
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac)))

  (values (hash-ref env 'O) cost))

(define I (make-symbolic-matrix 2 2))
(define F (make-symbolic-matrix 2 2))
; Run the synthesis query
(parameterize [(current-reg-size 4)]
  (pretty-print I)
  (pretty-print F)

  ; Generate sketch prog
  (define mmul (conv-2d-sketch I F 4))

  ;(pretty-print mmul)

  ; Define the cost function
  (define (cost-fn inst env)
    1)

  ; Create function for sketch evaluation
  (define (sketch-func args)
    (apply (curry run-sketch mmul cost-fn)
           args))

  ; Functionalize spec for minimization prog
  (define (spec-func args)
    (apply matrix-conv-spec args))

  ; Get a generator back from the synthesis procedure
  (define model-generator
    (synth-prog spec-func
                sketch-func
                (list I F)
                #:get-inps (lambda (args) (flatten
                                            (map matrix-elements args)))
                #:max-cost 100
                #:min-cost 1))

  ; Keep minimizing solution in the synthesis procedure and generating new
  ; solutions.
  (for ([model (in-producer model-generator (void))])
    (if (sat? model)
      (pretty-print (evaluate mmul model))
      (pretty-print (~a "failed to find solution: " model)))))

; ======================================= MANUAL ATTEMPT =================
(define man-sol
  (prog
    (list
      (vec-extern-decl 'I 4)
      (vec-extern-decl 'O 4)
      (vec-extern-decl 'F 4)
      (vec-const 'Z '#(0))
      (vec-const 'shuf0-0 (vector 0 0 0 0))
      (vec-const 'shuf1-0 (vector 3 2 1 0))
      (vec-const 'shuf2-0 (vector 0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-0 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-0 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-0 '(O))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-0 'out)
      (vec-const 'shuf0-1 (vector 5 1 2 3))
      (vec-const 'shuf1-1 (vector 3 3 3 3))
      (vec-const 'shuf2-1 (vector 0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-1 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-1 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-1 '(O))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-1 'out)
      (vec-const 'shuf0-2 (vector 5 5 5 1))
      (vec-const 'shuf1-2 (vector 5 5 5 1))
      (vec-const 'shuf2-2 (vector 0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-2 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-2 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-2 '(O))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-2 'out)
      (vec-const 'shuf0-3 (vector 5 5 5 2))
      (vec-const 'shuf1-3 (vector 5 5 5 2))
      (vec-const 'shuf2-3 (vector 0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-3 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-3 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-3 '(O))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-3 'out))))

(define env (make-hash))
(hash-set! env 'I (matrix-elements I))
(hash-set! env 'F (matrix-elements F))
(hash-set! env 'O (make-vector (vector-length (matrix-elements I)) 0))
(interp man-sol
        env
        #:fn-map (hash 'vec-mac vector-mac))
(pretty-print (hash-ref env 'O))
