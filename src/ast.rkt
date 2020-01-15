#lang rosette

(provide (all-defined-out))

; Default register size.
(define current-reg-size
  (make-parameter 4))

; XXX(rachit): Every instruction has an `id` which seems bad.
; A program is a sequence of instructions.
(struct prog (insts) #:transparent)

; Load and unload vectors from memory.
(struct vec-load (id start size) #:transparent)
(struct vec-unload (id start) #:transparent)

; Set constant vector in memory.
(struct vec-const (id init) #:transparent)

; Shuffle instructions inside memory.
(struct vec-shuffle (id idxs inp) #:transparent)
(struct vec-select (id idxs inp1 inp2) #:transparent)
(struct vec-shuffle-set! (out-vec idxs inp) #:transparent)

; Apply functions on vectors.
(struct vec-app (id f inps) #:transparent)

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
          ('x = vec-load 10 20)
          (vec-unload 'x 20))
        (define prog-gold
          (prog
            `(
              ,(vec-load 'x 10 20)
              ,(vec-unload 'x 20))))
        (check-equal? p prog-gold)))))
