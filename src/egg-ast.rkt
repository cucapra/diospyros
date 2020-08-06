#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "utils.rkt"
         "synth.rkt")

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
(struct egg-vec-4 (v0 v1 v2 v3) #:transparent)
(struct egg-concat (hd tl) #:transparent)
(struct egg-unnop (op v) #:transparent)
(struct egg-binop (op lhs rhs) #:transparent)

(define (parse-from-string s)
  (parse (open-input-string s)))

(define (parse port)
  (define s-exp (read port))
  (s-exp-to-ast s-exp))

(define (s-exp-to-ast e)
  (match e
    [(? number? a) a]
    [`(VecMAC ,acc ,v1 ,v2)
      (egg-vec-op `vec-mac (map s-exp-to-ast (list acc v1 v2)))]
    [`(VecMul ,v1 ,v2)
      (egg-vec-op `vec-mul (map s-exp-to-ast (list v1 v2)))]
    [`(VecAdd ,v1 ,v2)
      (egg-vec-op `vec-add (map s-exp-to-ast (list v1 v2)))]
    [(or `(Vec4 ,v1 ,v2 ,v3 ,v4) `(LitVec4 ,v1 ,v2 ,v3 ,v4))
      (apply egg-vec-4 (map s-exp-to-ast (list v1 v2 v3 v4)))]
    [`(List , vs ...)
      (egg-list (map s-exp-to-ast vs))]
    [`(Get ,a ,idx)
      (egg-get a idx)]
    [`(Concat ,v1 ,v2)
      (egg-concat (s-exp-to-ast v1) (s-exp-to-ast v2))]
    [`(+ , vs ...)
      (assert (> (length vs) 1) "+")
      (let ([xs (map s-exp-to-ast vs)])
        (foldl (curry egg-binop '+) (first xs) (rest xs)))]
    [`(* , vs ...)
      (assert (> (length vs) 1) "*")
      (let ([xs (map s-exp-to-ast vs)])
        (foldl (curry egg-binop '*) (first xs) (rest xs)))]
    [`(/ , vs ...)
      (assert (> (length vs) 1) "/")
      (let ([xs (map s-exp-to-ast vs)])
        (foldl (curry egg-binop '/) (first xs) (rest xs)))]
    [`(neg , v)
      (egg-unnop 'neg (s-exp-to-ast v))]
    [`(sgn , v)
      (egg-unnop 'sgn (s-exp-to-ast v))]
    [`(sqrt , v)
      (egg-unnop 'sqrt (s-exp-to-ast v))]
    [_ (error 's-exp-to-ast "invalid s-expression: ~a" e)]))
