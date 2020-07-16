#lang rosette

(define-values (add mul)
  (values 'add
          'mul))

(define-values (vec-add vec-mul vec-mac)
  (values 'vec-add
          'vec-mul
          'vec-mac))

(struct egg-sym (name) #:transparent)
(struct egg-scalar-op (op args) #:transparent)
(struct egg-vec-op (op args) #:transparent)
(struct egg-list (args) #:transparent)
(struct egg-vec-4 (v0 v1 v2 v3) #:transparent)
(struct egg-concat (hd tl) #:transparent)

(define (parse-from-string s)
  (parse (open-input-string s)))

(define (parse port)
  (define s-exp (read port))
  (s-exp-to-ast s-exp))

(define (s-exp-to-ast e)
  (match e
    [`(VecMAC ,acc , v1, v2)
      (egg-vec-op `vec-mac (map s-exp-to-ast (list acc v1 v2)))]
    [`(VecMul , v1, v2)
      (egg-vec-op `vec-mul (map s-exp-to-ast (list v1 v2)))]
    [`(Vec4 , v1, v2, v3, v4)
      (apply egg-vec-4 (map s-exp-to-ast (list v1 v2 v3 v4)))]
    [id (egg-sym e)]
    [_ (error 's-exp-to-ast "invalid s-expression: ~a" e)]))

(define (egg-to-dios e)
  (match e
    [(egg-sym name) e]
    [(egg-vec-4 v1 v2 v3 v4) e]
    [(egg-scalar-op op args) e]
    [(egg-vec-op `vec-mac (list acc v1 v2)) e]))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "egg AST tests"
      (test-case
        "2x2 2x2 mat mul"
        (define egg-s-exp "(VecMAC
          (VecMul
            (Vec4 v0 v0 v4 v5)
            (Vec4 v4 v5 v2 v2))
          (Vec4 v1 v1 v6 v7)
          (Vec4 v6 v7 v3 v3))")
        (define gold-ast
          (egg-vec-op 'vec-mac
                      (list
                        (egg-vec-op 'vec-mul
                                    (list
                                      (egg-vec-4 (egg-sym `v0)
                                                 (egg-sym `v0)
                                                 (egg-sym `v4)
                                                 (egg-sym `v5))
                                      (egg-vec-4 (egg-sym `v4)
                                                 (egg-sym `v5)
                                                 (egg-sym `v2)
                                                 (egg-sym `v2))))
                        (egg-vec-4 (egg-sym `v1)
                                   (egg-sym `v1)
                                   (egg-sym `v6)
                                   (egg-sym `v7))
                        (egg-vec-4 (egg-sym `v6)
                                   (egg-sym `v7)
                                   (egg-sym `v3)
                                   (egg-sym `v3)))))
        (define to-ast (parse-from-string egg-s-exp))
        (check-equal? to-ast gold-ast)
        (pretty-print to-ast)
        (pretty-print (egg-to-dios to-ast))))))
