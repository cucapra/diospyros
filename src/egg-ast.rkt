#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "utils.rkt"
         "translation-validation.rkt")

(provide (all-defined-out))

(define-values (add mul)
  (values 'add
          'mul))

(define-values (vec-add vec-mul vec-mac)
  (values 'vec-add
          'vec-mul
          'vec-mac))

(struct egg-get (name idx) #:transparent)
(struct egg-vec-op (op args) #:transparent)
(struct egg-list (args) #:transparent)
(struct egg-vec (vs) #:transparent)
(struct egg-concat (hd tl) #:transparent)
(struct egg-unnop (op v) #:transparent)
(struct egg-binop (op lhs rhs) #:transparent)

(define (parse-from-string s)
  (parse (open-input-string s)))

(define (parse port)
  (define s-exp (read port))
  (s-exp-to-ast s-exp))

; Replace unnecessary padding elements at the end of each vector with no-ops,
; keeping keep elements
(define (truncate e keep)
  (define (tr e) (truncate e keep))
  (define add (- (current-reg-size) keep))
  (match e
    [`(VecMAC ,acc ,v1 ,v2)
      `(VecMAC ,(tr acc) ,(tr v1) ,(tr v2))]
    [`(VecMul ,v1 ,v2)
      `(VecMul ,(tr v1) ,(tr v2))]
    [`(VecMulSgn ,v1 ,v2)
      `(VecMulSgn ,(tr v1) ,(tr v2))]
    [`(VecAdd ,v1 ,v2)
      `(VecAdd ,(tr v1) ,(tr v2))]
    [`(VecDiv ,v1 ,v2)
      `(VecDiv ,(tr v1) ,(tr v2))]
    [`(VecNeg ,v)
      `(VecNeg ,(tr v))]
    [`(VecSqrt ,v)
      `(VecSqrt ,(tr v))]
    [`(VecSgn ,v)
      `(VecSgn ,(tr v))]
    ; Use -1 to indicate "don't care"
    [`(Vec , vs ...)
      (define trunc_vs (append (take vs keep) (make-list add `nop)))
      (cons `Vec trunc_vs)]
    [`(LitVec , vs ...)
      (define trunc_vs (append (take vs keep) (make-list add `nop)))
      (cons `LitVec trunc_vs)]
    ))

; Replace unnecessary padding elements at the end of each output with no-ops
(define (truncate-output e sizes)
  (match e
    [`(Concat ,v1 ,v2)
      (begin
        (match-define (cons size o-rest) sizes)
        (define new-size (- size (current-reg-size)))
        (define trunc-v1
          (if (< new-size 0)
            (truncate v1 (- new-size))
            v1))
        (define trunc-v2
          (truncate-output v2 (if (<= new-size 0) o-rest (cons new-size o-rest))))
        (quasiquote (Concat (unquote trunc-v1) (unquote trunc-v2))))]
    [_
      (define keep (first sizes))
      (if (eq? keep (current-reg-size)) e (truncate e (first sizes)))]))

(define (s-exp-to-ast-with-outputs e outputs)
  (define output-map make-hash)
  (define output-sizes (for/list ([o outputs])
  (match-define (list _ size) o) size))
  (define truncated (truncate-output e output-sizes))
  (s-exp-to-ast truncated))

(define (s-exp-to-ast e)
  (match e
    [(? number? a) a]
    [`nop `nop]
    [`(VecMAC ,acc ,v1 ,v2)
      (egg-vec-op `vec-mac (map s-exp-to-ast (list acc v1 v2)))]
    [`(VecMul ,v1 ,v2)
      (egg-vec-op `vec-mul (map s-exp-to-ast (list v1 v2)))]
    [`(VecMulSgn ,v1 ,v2)
      (egg-vec-op `vec-mul-sgn (map s-exp-to-ast (list v1 v2)))]
    [`(VecAdd ,v1 ,v2)
      (egg-vec-op `vec-add (map s-exp-to-ast (list v1 v2)))]
    [`(VecDiv ,v1 ,v2)
      (egg-vec-op `vec-div (map s-exp-to-ast (list v1 v2)))]
    [`(VecNeg ,v)
      (egg-vec-op `vec-neg (list (s-exp-to-ast v)))]
    [`(VecSqrt ,v)
      (egg-vec-op `vec-sqrt (list (s-exp-to-ast v)))]
    [`(VecSgn ,v)
      (egg-vec-op `vec-sgn (list (s-exp-to-ast v)))]
    [(or `(Vec , vs ...) `(LitVec , vs ...))
      (egg-vec (map s-exp-to-ast vs))]
    [`(List , vs ...)
      (egg-list (map s-exp-to-ast vs))]
    [`(Get ,a ,idx)
      (egg-get a idx)]
    [`(Concat ,v1 ,v2)
      (egg-concat (s-exp-to-ast v1) (s-exp-to-ast v2))]
    [`(+ , vs ...)
      (assert (> (length vs) 1) "+")
      (let ([xs (map s-exp-to-ast vs)])
        (foldr (curry egg-binop '+) (last xs) (drop-right xs 1)))]
    [`(* , vs ...)
      (assert (> (length vs) 1) "*")
      (let ([xs (map s-exp-to-ast vs)])
        (foldr (curry egg-binop '*) (last xs) (drop-right xs 1)))]
    [`(/ , vs ...)
      (assert (> (length vs) 1) "/")
      (let ([xs (map s-exp-to-ast vs)])
        (foldr (curry egg-binop '/) (last xs) (drop-right xs 1)))]
    [`(neg , v)
      (egg-unnop 'neg (s-exp-to-ast v))]
    [`(- , v)
      (egg-unnop 'neg (s-exp-to-ast v))]
    [`(sgn , v)
      (egg-unnop 'sgn (s-exp-to-ast v))]
    [`(sqrt , v)
      (egg-unnop 'sqrt (s-exp-to-ast v))]
    [_ (error 's-exp-to-ast "invalid s-expression: ~a" e)]))
