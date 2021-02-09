#lang rosette

(require "../ast.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../utils.rkt"
         "../prog-sketch.rkt"
         "../translation-validation.rkt"
         threading
         racket/trace
         racket/generator
         rosette/lib/angelic)

(provide conv2d:keys
         conv2d:only-spec)

(define conv2d:keys
  (list 'input-rows 'input-cols
        'filter-rows 'filter-cols
        'reg-size))

(define (prelude I-rows I-cols F-rows F-cols)
  (define output-rows (sub1 (+ I-rows F-rows)))
  (define output-cols (sub1 (+ I-cols F-cols)))
  (list
    (vec-extern-decl 'I (* I-rows I-cols) input-array-tag)
    (vec-extern-decl 'F (* F-rows F-cols) input-array-tag)
    (vec-extern-decl 'O (* output-rows output-cols) output-tag)
    (vec-const 'Z (make-v-list-zeros 1) float-type)))

;; Runs the spec with symbolic inputs and returns:
;; - the resulting formula.
;; - the prelude instructions (list)
;; - outputs that the postlude should write to
(define (conv2d:only-spec config)
  (define I-rows (hash-ref config 'input-rows))
  (define I-cols (hash-ref config 'input-cols))
  (define F-rows (hash-ref config 'filter-rows))
  (define F-cols (hash-ref config 'filter-cols))
  (define-values (I F)
    (values
    (make-symbolic-matrix I-rows I-cols 'I)
    (make-symbolic-matrix F-rows F-cols 'F)))

  (define len (length (matrix-elements (2d-conv-spec I F))))
  (define spec (align-to-reg-size (matrix-elements (2d-conv-spec I F))))

  (values (matrix-elements (2d-conv-spec I F))
          (prog (prelude I-rows I-cols F-rows F-cols))
          (list (list 'O len))))

; Given an NxN input matrix, returns a smaller convolved matrix.
(define (2d-conv-spec input filter)
  (match-define (matrix i-rows i-cols _) input)
  (match-define (matrix f-rows f-cols _) filter)

  ; Return 0 if the access to the input matrix was out of bounds.
  (define (safe-access-input row col)
    (if (and (>= row 0) (>= col 0) (< row i-rows) (< col i-cols))
      (matrix-ref input row col)
      0))

  ; Pad the output to include the edge computations
  (define output-rows (sub1 (+ i-rows f-rows)))
  (define output-cols (sub1 (+ i-cols f-cols)))
  (define output
    (matrix output-rows
            output-cols
            (make-v-list-zeros (* output-rows output-cols))))

  (for* ([output-row (in-range output-rows)]
         [output-col (in-range output-cols)])

    (define conv-res
        (apply +
               (for*/list ([i (in-range f-rows)]
                           [j (in-range f-cols)])
                 (let* ([filter-x (- f-rows 1 i)]
                        [filter-y (- f-cols 1 j)]
                        [input-x (- output-row filter-x)]
                        [input-y (- output-col filter-y)])
                   (* (safe-access-input input-x input-y)
                      (matrix-ref filter filter-x filter-y))))))
    (matrix-set! output output-row output-col conv-res))

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
          (v-list 0 1 2
                  3 4 5
                  6 7 8))
        (define filter
          (v-list 0 1
                  2 3))
        (define gold
          (v-list 0  0  1  2
                  0  5  11 11
                  6  23 29 23
                  12 32 37 24))
        (check-equal? (2d-conv-spec (matrix 3 3 input)
                                    (matrix 2 2 filter))
                      (matrix 4 4 gold)))

      (test-case
        "4x4 by 2x2"
        (define input
          (v-list 0  1  2  3
                  4  5  6  7
                  8  9  10 11
                  12 13 14 15))
        (define filter
          (v-list 0 1
                  2 3))
        (define gold
          (v-list 0  0  1  2  3
                  0  6  12 18 16
                  8  30 36 42 32
                  16 54 60 66 48
                  24 62 67 72 45))
        (check-equal? (2d-conv-spec (matrix 4 4 input)
                                    (matrix 2 2 filter))
                      (matrix 5 5 gold))))))
