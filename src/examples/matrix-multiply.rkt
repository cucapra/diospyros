#lang rosette

(require "../ast.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../utils.rkt"
         "../prog-sketch.rkt"
         "../verify.rkt"
         "../configuration.rkt"
         racket/trace
         racket/generator
         rosette/lib/angelic)

(provide matrix-mul:keys
         matrix-mul:only-spec
         matrix-multiply-spec)

(define (prelude A-rows A-cols B-rows B-cols)
  (list
    (vec-extern-decl 'A (* A-rows A-cols) input-tag)
    (vec-extern-decl 'B (* B-rows B-cols) input-tag)
    (vec-extern-decl 'C (* A-rows B-cols) output-tag)
    (vec-const 'Z (make-v-list-zeros 1) float-type)))

(define (postlude output-names)
  (for/list ([n output-names]
             [i (in-naturals 0)])
    (let* ([start (* i (current-reg-size))]
           [end (* (+ i 1) (current-reg-size))])
      (vec-store 'C n start end))))

;; Runs the spec with symbolic inputs and returns:
;; - the resulting formula.
;; - the prelude instructions (list)
;; - outputs that the postlude should write to
(define (matrix-mul:only-spec config)
  (define A-rows (hash-ref config 'A-rows))
  (define A-cols (hash-ref config 'A-cols))
  (define B-rows (hash-ref config 'B-rows))
  (define B-cols (hash-ref config 'B-cols))
  (define A (make-symbolic-matrix A-rows A-cols 'A))
  (define B (make-symbolic-matrix B-rows B-cols 'B))

  (define spec (align-to-reg-size (matrix-multiply-spec A B)))

  (values spec
          (prog (prelude A-rows A-cols B-rows B-cols))
          (list (list 'C (length spec)))))

;; Generate a spec for matrix multiply of a given size.
(define (matrix-multiply-spec mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (assert (= A-cols B-rows))
  (define C
    (matrix A-rows
            B-cols
            (make-v-list-zeros (* A-rows B-cols))))
  (for* ([i A-rows]
         [j B-cols])
    (define sum
      (apply
        +
        (for/list ([k A-cols])
          (* (matrix-ref mat-A i k)
             (matrix-ref mat-B k j)))))
    (matrix-set! C i j sum))

  (matrix-elements C))

(define (pr v)
  (pretty-print v)
  v)

; Describe the configuration parameters for this benchmarks
(define matrix-mul:keys
  (list 'A-rows 'A-cols 'B-rows 'B-cols 'reg-size))
