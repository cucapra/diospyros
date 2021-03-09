#lang rosette

(require "configuration.rkt")

(provide (all-defined-out))

(define-values (input-array-tag input-scalar-tag output-tag)
  (values 'extern-input-array
          'extern-input-scalar
          'extern-output))

(define-values (int-type float-type)
  (values 'int
          'float))

; Default register size.
(define current-reg-size
  (make-parameter 4))

; XXX(rachit): Every instruction has an `id` which seems bad.
; A program is a sequence of instructions.
(struct prog (insts) #:transparent)

; Set constant vector in memory, with initialization.
(struct vec-const (id init type) #:transparent)

; Vector composed of compound expressions. Used to represent {a[0], b[1], a[1]}
(struct vec-lit (id elems type) #:transparent)

; Vector declaration, no initialization.
(struct vec-decl (id size) #:transparent)

; Set externally-declared vector in memory, must be loaded from.
; Tag says if this is an input or an output.
(struct vec-extern-decl (id size tag) #:transparent)

; Shuffle instructions inside memory.
(struct vec-shuffle (id idxs inps) #:transparent)
(struct vec-shuffle-set! (out-vec idxs inp) #:transparent)

; Apply functions on vectors (with a result).
(struct vec-app (id f inps) #:transparent)

; Apply functions on vectors (with no result).
(struct vec-void-app (f inps) #:transparent)

; Vector load.
(struct vec-load (dest-id src-id start end) #:transparent)

; Vector store.
(struct vec-store (dest-id src-id start end) #:transparent)

; Vector write (copy).
(struct vec-write (dst src) #:transparent)

;; ========== Scalar Operations ===========
; Get a value from a array and assign it to `id`.
(struct array-get (id arr-id idx) #:transparent)

; Perform a binary op on scalar operations. Does not allow for nested
; expressions: l-id and r-id must be variable names.
(struct scalar-binop (id op l-id r-id) #:transparent)

; Perform a unary op on scalar operations. Does not allow for nested
; expressions: v-id must be a variable name.
(struct scalar-unnop (id op v-id) #:transparent)

; Perform a ternary op on scalar operations. Does not allow for nested
; expressions: v-id must be a variable name.
(struct scalar-ternop (id cond-id i-id e-id) #:transparent)

; Let binding
(struct let-bind (id e type) #:transparent)

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
          ('x = vec-const (list) int-type)
          (vec-shuffle-set! 'y 'x 20))
        (define prog-gold
          (prog
            `(
              ,(vec-const 'x (list) int-type)
              ,(vec-shuffle-set! 'y 'x 20))))
        (check-equal? p prog-gold)))))
