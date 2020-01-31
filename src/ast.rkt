#lang rosette

(provide (all-defined-out))

; Default register size.
(define current-reg-size
  (make-parameter 4))

; XXX(rachit): Every instruction has an `id` which seems bad.
; A program is a sequence of instructions.
(struct prog (insts) #:transparent)

; Set constant vector in memory.
(struct vec-extern-decl (id size) #:transparent)

; Set constant vector in memory.
(struct vec-const (id init) #:transparent)

; Shuffle instructions inside memory.
(struct vec-shuffle (id idxs inps) #:transparent)
(struct vec-shuffle-set! (out-vec idxs inp) #:transparent)

; Apply functions on vectors.
(struct vec-app (id f inps) #:transparent)

; Nodes used internally for passes

; Vector load.
(struct vec-load (id start end) #:transparent)

(require (for-syntax racket/base
                     syntax/parse)
         racket/syntax
         racket/stxparam)

(define-syntax (define/prog stx)
  (define-syntax-class instruction
    ; #:description "instruction specification"
    #:datum-literals (=)
    (pattern
      (id:expr = inst:id param:expr ...)
      #:with to-inst #'(inst id param ...))
    (pattern
      (inst:id param:expr ...)
      #:with to-inst #'(inst param ...)))

  (syntax-parse stx
    ; Parse functions that return values
    [(_ name:id inst:instruction ...)
     #'(define name (prog (list inst.to-inst ...)))]))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "AST tests"
      (test-case
        "syntax macro generates a valid program"
        (define/prog p
          ('x = vec-const (vector 0))
          (vec-shuffle-set! 'y 'x 20))
        (define prog-gold
          (prog
            `(
              ,(vec-const 'x (vector 0))
              ,(vec-shuffle-set! 'y 'x 20))))
        (check-equal? p prog-gold)))))
