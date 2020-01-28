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
                 (* (matrix-ref input (+ top-left-x i) (+ top-left-y j))
                    (matrix-ref filter i j))))))
    (matrix-set! output inp-row inp-col conv-res)))
