#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "utils.rkt"
         "synth.rkt")

(define-values (add mul)
  (values 'add
          'mul))

(define-values (vec-add vec-mul vec-mac)
  (values 'vec-add
          'vec-mul
          'vec-mac))

(struct egg-get (name idx) #:transparent)
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

(define new-name (make-name-gen))

(define (s-exp-to-ast e)
  (match e
    [`(VecMAC ,acc , v1, v2)
      (egg-vec-op `vec-mac (map s-exp-to-ast (list acc v1 v2)))]
    [`(VecMul , v1, v2)
      (egg-vec-op `vec-mul (map s-exp-to-ast (list v1 v2)))]
    [(or `(Vec4 , v1, v2, v3, v4) `(LitVec4 , v1, v2, v3, v4))
      (apply egg-vec-4 (map s-exp-to-ast (list v1 v2 v3 v4)))]
    [`(Get , a, idx)
      (egg-get a idx)]
    [_ (error 's-exp-to-ast "invalid s-expression: ~a" e)]))

(define (egg-get-list-to-shuffle gets shuf-name out-name)
  (define mems-used (remove-duplicates (map egg-get-name gets)))
  ; TODO: handle multiple memories
  (define idxs (map egg-get-idx gets))
  (values
    out-name
    (list
      (vec-const shuf-name (list->vector idxs) 'int)
      (vec-shuffle out-name shuf-name mems-used))))

; Functional expression -> (name, list of DSL instructions)
(define (egg-to-dios e)
  (match e
    [(egg-get name idx) e]
    [(egg-vec-4 v1 v2 v3 v4)
      (let ([vs (list v1 v2 v3 v4)])
        (when (not (andmap egg-get? vs))
          (error 'egg-to-dios
            "Expected only egg-get within egg-vec-4: ~a"
            vs))
        (egg-get-list-to-shuffle vs
                                 (new-name `shufs)
                                 (new-name `shuf-out)))]
    [(egg-scalar-op op args) e]
    [(egg-vec-op `vec-mac (list acc v1 v2))
      (define-values (acc-name acc-prog) (egg-to-dios acc))
      (define-values (v1-name v1-prog) (egg-to-dios v1))
      (define-values (v2-name v2-prog) (egg-to-dios v2))
      (define mac
        (vec-app 'mac-out 'vec-mac (list acc-name v1-name v2-name)))
      (values 'mac-out
              (flatten
                (list acc-prog
                      v1-prog
                      v2-prog
                      mac)))]
    [(egg-vec-op `vec-mul (list v1 v2))
      (define-values (v1-name v1-prog) (egg-to-dios v1))
      (define-values (v2-name v2-prog) (egg-to-dios v2))
      (define mul
        (vec-app 'mul-out 'vec-mul (list v1-name v1-name)))
      (values 'mul-out
              (flatten
                (list v1-prog
                      v2-prog
                      mul)))]))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "egg AST tests"
      (test-case
        "2x2 2x2 mat mul"
        (define egg-s-exp
          "(VecMAC
             (VecMul
               (LitVec4
                 (Get A 0)
                 (Get A 0)
                 (Get A 2)
                 (Get A 2))
               (LitVec4
                 (Get B 0)
                 (Get B 1)
                 (Get B 0)
                 (Get B 1)))
             (LitVec4
               (Get A 1)
               (Get A 1)
               (Get A 3)
               (Get A 3))
             (LitVec4
               (Get B 2)
               (Get B 3)
               (Get B 2)
               (Get B 3)))")
        (define gold-ast
          (egg-vec-op 'vec-mac
                      (list
                        (egg-vec-op 'vec-mul
                                    (list
                                      (egg-vec-4 (egg-get `A 0)
                                                 (egg-get `A 0)
                                                 (egg-get `A 2)
                                                 (egg-get `A 2))
                                      (egg-vec-4 (egg-get `B 0)
                                                 (egg-get `B 1)
                                                 (egg-get `B 0)
                                                 (egg-get `B 1))))
                        (egg-vec-4 (egg-get `A 1)
                                   (egg-get `A 1)
                                   (egg-get `A 3)
                                   (egg-get `A 3))
                        (egg-vec-4 (egg-get `B 2)
                                   (egg-get `B 3)
                                   (egg-get `B 2)
                                   (egg-get `B 3)))))
        (define prog-smt
          (prog
           (list
            (vec-extern-decl 'A 4 'extern-input)
            (vec-extern-decl 'B 4 'extern-input)
            (vec-extern-decl 'C 4 'extern-output)
            (vec-decl 'reg-C 4)
            (vec-load 'C_0_4 'C 0 4)
            (vec-const 'shuf0-0 '#(0 0 3 3) 'int)
            (vec-const 'shuf1-0 '#(0 1 2 3) 'int)
            (vec-shuffle 'reg-A 'shuf0-0 '(A))
            (vec-shuffle 'reg-B 'shuf1-0 '(B))
            (vec-write 'reg-C 'C_0_4)
            (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
            (vec-write 'C_0_4 'out)
            (vec-const 'shuf0-1 '#(1 1 2 2) 'int)
            (vec-const 'shuf1-1 '#(2 3 0 1) 'int)
            (vec-shuffle 'reg-A 'shuf0-1 '(A))
            (vec-shuffle 'reg-B 'shuf1-1 '(B))
            (vec-write 'reg-C 'C_0_4)
            (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
            (vec-write 'C_0_4 'out)
            (vec-store 'C 'C_0_4 0 4))))
        (define prelude
          (list
            (vec-extern-decl 'A 4 'extern-input)
            (vec-extern-decl 'B 4 'extern-input)
            (vec-extern-decl 'C 4 'extern-output)))
        (define postlude
          (list
            (vec-store 'C 'mac-out 0 4)))

        ; Check parsing from s-expression
        (define egg-ast (parse-from-string egg-s-exp))
        (check-equal? egg-ast gold-ast)
        (pretty-print egg-ast)

        ; Conversion from egg to dios dsl
        (define-values (_ egg-res) (egg-to-dios egg-ast))
        (define full-egg-prog
          (prog (flatten (list prelude egg-res postlude))))
        (pretty-print full-egg-prog)

        ; Check equality to SMT-found version
        (assert
          (equal?
            (unsat)
            (verify-prog (to-bvs-prog prog-smt)
                         (to-bvs-prog full-egg-prog)
                         #:fn-map (hash 'vec-mac vector-mac
                                        'vec-mul vector-multiply))))))))
