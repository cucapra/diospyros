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
