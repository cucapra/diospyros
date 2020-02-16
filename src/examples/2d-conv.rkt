#lang rosette

(require "../ast.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../utils.rkt"
         "../prog-sketch.rkt"
         "../synth.rkt"
         threading
         racket/trace
         racket/generator
         rosette/solver/smt/z3
         rosette/solver/smt/boolector)

(provide conv2d:keys
         conv2d:run-experiment)

(current-solver (boolector))
(current-bitwidth 10)

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
        (apply +
               (for*/list ([i (in-range f-rows)]
                           [j (in-range f-cols)])
                 (let* ([filter-x (- f-rows 1 i)]
                        [filter-y (- f-cols 1 j)]
                        [input-x (+ inp-row (- f-center-x filter-x))]
                        [input-y (+ inp-col (- f-center-y filter-y))])
                   (* (safe-access-input input-x input-y)
                      (matrix-ref filter filter-x filter-y))))))
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
          (vector 0 1 2
                  3 4 5
                  6 7 8))
        (define filter
          (vector 0 1
                  2 3))
        (define gold
          (vector 5  11 11
                  23 29 23
                  32 37 24))
        (check-equal? (matrix-conv-spec (matrix 3 3 input)
                                        (matrix 2 2 filter))
                      (matrix 3 3 gold))))))

; ============================ MANUAL ATTEMPT =================

(define man-sol
  (prog
    (list
      (vec-extern-decl 'I 4 input-tag)
      (vec-extern-decl 'F 4 input-tag)
      (vec-extern-decl 'O 4 output-tag)
      (vec-const 'Z '#(0))
      (vec-const 'shuf0-0 (vector 0 0 0 0))
      (vec-const 'shuf1-0 (vector 3 2 1 0))
      (vec-const 'shuf2-0 (vector 0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-0 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-0 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-0 '(O))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-0 'out)
      (vec-const 'shuf0-1 (vector 4 1 2 3))
      (vec-const 'shuf1-1 (vector 3 3 3 3))
      (vec-const 'shuf2-1 (vector 0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-1 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-1 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-1 '(O))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-1 'out)
      (vec-const 'shuf0-2 (vector 4 4 4 1))
      (vec-const 'shuf1-2 (vector 4 4 4 1))
      (vec-const 'shuf2-2 (vector 0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-2 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-2 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-2 '(O))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-2 'out)
      (vec-const 'shuf0-3 (vector 4 4 4 2))
      (vec-const 'shuf1-3 (vector 4 4 4 2))
      (vec-const 'shuf2-3 (vector 0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-3 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-3 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-3 '(O))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-3 'out))))

(define (sol-func I F)
  (define-values (env _)
    (interp man-sol
            (list (cons 'I (matrix-elements I))
                  (cons 'F (matrix-elements F))
                  (cons 'O (make-vector (vector-length (matrix-elements I)) 0)))
            #:fn-map (hash 'vec-mac vector-mac)))
  (hash-ref env 'O))


; ================= Verify manual solution ======================
#|

Currently, the manual solution no longer verifies because our implementation
details have changed.

(begin
  (define I (make-symbolic-matrix 2 2))
  (define F (make-symbolic-matrix 2 2))
  (verify-prog (lambda (args) (apply sol-func args))
               (lambda (args) (matrix-elements
                                (apply matrix-conv-spec args)))
               (list I F)
               #:get-inps (lambda (args)
                            (~> model
                                (map (lambda (mat) (matrix-elements mat)) _)
                                flatten))))
|#
; ==================== Sketch Generation =========================

(define (conv-2d-sketch inp filt iterations)
  (match-define (matrix _ _ I-elements) inp)
  (match-define (matrix _ _ F-elements) filt)

  ;Program preamble to define the "zero" vector.
  (define preamble
    (list
     (vec-extern-decl 'I (vector-length I-elements) input-tag)
     (vec-extern-decl 'F (vector-length F-elements) input-tag)
     (vec-extern-decl 'O (vector-length I-elements) output-tag)
     (vec-const 'Z (vector 0))))

  ;Compute description for the sketch
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
     (vec-void-app 'continuous-vec? (list shuf-O))
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

(define (run-sketch sketch cost-fn I F)
  (define-values (out-env cost)
    (interp sketch
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac
                           'continuous-vec?
                           (curry continuous-aligned-vec? (current-reg-size)))
            (list (cons 'I (matrix-elements I))
                  (cons 'F (matrix-elements F))
                  (cons 'O (~> I
                               matrix-elements
                               vector-length
                               (make-vector _ 0))))))

  (values (vector-take (hash-ref out-env 'O)
                       (vector-length
                         (matrix-elements I)))
          cost))

(define conv2d:keys
  (list 'input-rows 'input-cols
        'filter-rows 'filter-cols
        'reg-size
        'iterations))

(define (conv2d:run-experiment spec file-writer)
  (define I-rows (hash-ref spec 'input-rows))
  (define I-cols (hash-ref spec 'input-cols))
  (define F-rows (hash-ref spec 'filter-rows))
  (define F-cols (hash-ref spec 'filter-cols))
  (define reg-size (hash-ref spec 'reg-size))
  (define iterations (hash-ref spec 'iterations))

; Run the synthesis query
(parameterize [(current-reg-size reg-size)]

  (define reg-upper-bound
    (max (exact-ceiling (/ (* I-rows I-cols) (current-reg-size)))
         (exact-ceiling (/ (* F-rows F-cols) (current-reg-size)))
         (current-reg-size)))

  ; Define inputs
  (define-values (I F)
    (values
    (make-symbolic-matrix I-rows I-cols)
    (make-symbolic-matrix F-rows I-cols)))

  ; Generate sketch prog
  (define conv-2d (conv-2d-sketch I F iterations))

  ; Define cost function
  (define (cost-fn)
    (let ([cost-1 (make-shuffle-unique-cost prefix-equiv)]
          [cost-2 (make-register-cost reg-upper-bound)])
      (lambda (inst env)
        (+ (cost-1 inst env) (cost-2 inst env)))))

  ; Create function for sketch evaluation
  (define (sketch-func args)
    (apply (curry run-sketch
                  conv-2d
                  (cost-fn))
           args))

  ; Function for spec evaluation
  (define (spec-func args)
    (matrix-elements (apply matrix-conv-spec args)))

  ; Show the shape of the spec
  (pretty-print (spec-func (list I F)))

  ; Get a generator back from the synthesis procedure.
  (define model-generator
    (synth-prog spec-func
                sketch-func
                (list I F)
                #:get-inps (lambda (args) (flatten
                                            (map matrix-elements args)))
                #:max-cost 500
                #:min-cost 0))

  ; Keep generating solutions.
  (for ([(model cost) (sol-producer model-generator)])
    (if (sat? model)
      (let ([prog (evaluate conv-2d model)])
        (file-writer prog cost)
        (pretty-print prog))
      (pretty-print (~a "failed to find solution: " model))))))
