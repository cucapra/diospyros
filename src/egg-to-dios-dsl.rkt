#lang rosette

(require "ast.rkt"
         "egg-ast.rkt"
         "dsp-insts.rkt"
         "utils.rkt"
         "translation-validation.rkt")

(provide egg-to-dios-dsl)

(define (egg-to-dios-dsl egg-res prelude outputs)
  (define egg-ast (s-exp-to-ast-with-outputs egg-res outputs))
  (define-values (out-names body) (egg-to-dios-prog egg-ast))

  (define out-name-list (box (flatten out-names)))
  (define postlude
    (flatten
      (for/list ([o outputs])
        (match-define (list o-name size) o)
        (for/list ([n (in-range 0 size (current-reg-size))])
          (let* ([start n]
                 [end (min size (+ start (current-reg-size)))])
            (define store-inst
              (vec-store o-name (first (unbox out-name-list)) start end))
            (set-box! out-name-list (rest (unbox out-name-list)))
            store-inst)))))

  (prog
    (append (prog-insts prelude)
            body
            postlude)))

(define new-name (make-name-gen))

(define (egg-get-list-to-shuffle gets shuf-name out-name)
  (define has-zero (ormap (curry equal? 0) gets))
  (define start (if has-zero (current-reg-size) 0))
  (define (get-idx v)
    (if (egg-get? v)
        (+ start (egg-get-idx v))
        0))
  (define idxs (map get-idx gets))

  ; Use -1 to indicate "don't care"
  (define mems-used
    (append
      (if has-zero `(Z) `())
      (remove-duplicates (map egg-get-name
                              (filter egg-get? gets)))))
  (values
    out-name
    (list
      (vec-const shuf-name (list->vector idxs) 'int)
      (vec-shuffle out-name shuf-name mems-used))))

; Functional expression -> (name, list of DSL instructions)
(define (egg-to-dios-prog p)

  (define mapped-consts-or-gets (make-hash))
  (define has-const-or-get? (curry hash-has-key? mapped-consts-or-gets))
  (define const-or-get-name (curry hash-ref mapped-consts-or-gets))
  (define (set-const-or-get v name) (hash-set! mapped-consts-or-gets v name))

  ; Don't redefine constants or array accesses
  (define seen-const-or-get-names (mutable-set))
  (define seen? (curry set-member? seen-const-or-get-names))
  (define mark-seen (curry set-add! seen-const-or-get-names))

  (define (egg-to-dios e)
    (match e
      [(? number? a)
       (define name (format "const_~v" a))
       (values
         name
         (if (seen? name)
           (list)
           ; TODO: handle int type
           (begin
             (mark-seen name)
             (let-bind name (format "~v" a) float-type))))]
      [(egg-get name idx)
       (define get-name (format "get_~v_~v" name idx))
       (values
         get-name
         (if (seen? get-name)
           (list)
           (begin
             (mark-seen get-name)
             (array-get get-name name idx))))]
      [(egg-binop op lhs rhs)
       (define-values (l-name l-prog) (egg-to-dios lhs))
       (define-values (r-name r-prog) (egg-to-dios rhs))
       (define op-res (new-name 'op))
       (define op-out
         (scalar-binop op-res op l-name r-name))
       (values op-res
               (flatten
                 (list l-prog
                       r-prog
                       op-out)))]
      [(egg-unnop op v)
       (define-values (v-name v-prog) (egg-to-dios v))
       (define op-res (new-name 'op))
       (define op-out
         (scalar-unnop op-res op v-name))
       (values op-res
               (flatten
                 (list v-prog
                       op-out)))]
      [(egg-vec vs)
        ; replace nop with first element
        (define new-vs (map (lambda (x) (if (eq? x `nop) (first vs) x)) vs))
        (define (get-or-zero? v) (or (egg-get? v) (equal? v 0)))
        (if (andmap get-or-zero? new-vs)
          (egg-get-list-to-shuffle new-vs
                                   (new-name `shufs)
                                   (new-name `shuf-out))
          (begin
            (define (egg-to-tuple v)
              (define-values (n p) (egg-to-dios v))
              (list n p))
            (define vs-egg (map egg-to-tuple new-vs))
            (define names (map first vs-egg))
            (define progs (map second vs-egg))
            (define name (new-name 'lit))
            (define vlit
              (vec-lit name names float-type))
            (values name
                    (flatten
                      (list progs vlit)))))]
      [(egg-list vs)
        (define-values (zero-n zero-p) (egg-to-dios 0))
        (define (egg-to-tuple v)
          (define-values (n p) (egg-to-dios v))
          (list n p))
        (define vs-egg (map egg-to-tuple vs))
        (define names (map first vs-egg))
        (define progs (map second vs-egg))
        (define vlits
          (for/list ([i (in-range 0 (length vs) (current-reg-size))])
            (define (access-or-zero j)
              (if (< (+ i j) (length names))
                  (list-ref names (+ i j))
                  zero-n))
            (define name (new-name 'lit))
            (list name
                  (vec-lit name
                           (map access-or-zero (stream->list (in-range (current-reg-size))))
                           float-type))))

        (values (map first vlits)
                (flatten
                  (list zero-p progs (map second vlits))))]
      [(egg-vec-op `vec-mac (list acc v1 v2))
        (define-values (acc-name acc-prog) (egg-to-dios acc))
        (define-values (v1-name v1-prog) (egg-to-dios v1))
        (define-values (v2-name v2-prog) (egg-to-dios v2))
        (define mac-name (new-name 'mac-out))
        (define mac
          (vec-app mac-name 'vec-mac (list acc-name v1-name v2-name)))
        (values mac-name
                (flatten
                  (list acc-prog
                        v1-prog
                        v2-prog
                        mac)))]
      [(egg-vec-op op (list v1 v2))
        (define-values (v1-name v1-prog) (egg-to-dios v1))
        (define-values (v2-name v2-prog) (egg-to-dios v2))
        (define out-name (new-name (string->symbol (format "~a-out" op))))
        (define op-inst
          (vec-app out-name op (list v1-name v2-name)))
        (values out-name
                (flatten
                  (list v1-prog
                        v2-prog
                        op-inst)))]
      [(egg-vec-op op (list v))
        (define-values (v-name v-prog) (egg-to-dios v))
        (define out-name (new-name (string->symbol (format "~a-out" op))))
        (define op-inst
          (vec-app out-name op (list v-name)))
        (values out-name
                (flatten
                  (list v-prog
                        op-inst)))]
      [(egg-concat v1 v2)
        (define-values (v1-name v1-prog) (egg-to-dios v1))
        (define-values (v2-name v2-prog) (egg-to-dios v2))
        ; TODO: abusing the meaning of the first value here slightly
        (values (list v1-name v2-name)
          (flatten
            (list v1-prog
                  v2-prog)))]
      [_ (error 'egg-to-dios "cannot compile: ~a" e)]))

  (egg-to-dios p))

(define partial
  "(VecMAC
     (Vec
      0
      (* (Get I 0) (Get F 2))
      (+
       (* (Get I 1) (Get F 2))
       (+
        (* (Get F 1) (Get I 4))
        (* (Get F 0) (Get I 5))))
      (+
       (* (Get I 2) (Get F 2))
       (+
        (* (Get F 1) (Get I 5))
        (* (Get F 0) (Get I 6)))))
     (LitVec 0 0 0 0)
     (LitVec 0 0 0 0))")

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
               (LitVec
                 (Get A 0)
                 (Get A 0)
                 (Get A 2)
                 (Get A 2))
               (LitVec
                 (Get B 0)
                 (Get B 1)
                 (Get B 0)
                 (Get B 1)))
             (LitVec
               (Get A 1)
               (Get A 1)
               (Get A 3)
               (Get A 3))
             (LitVec
               (Get B 2)
               (Get B 3)
               (Get B 2)
               (Get B 3)))")
        (define gold-ast
          (egg-vec-op 'vec-mac
                      (list
                        (egg-vec-op 'vec-mul
                                    (list
                                      (egg-vec (list
                                                 (egg-get `A 0)
                                                 (egg-get `A 0)
                                                 (egg-get `A 2)
                                                 (egg-get `A 2)))
                                      (egg-vec (list
                                                 (egg-get `B 0)
                                                 (egg-get `B 1)
                                                 (egg-get `B 0)
                                                 (egg-get `B 1)))))
                        (egg-vec (list (egg-get `A 1)
                                       (egg-get `A 1)
                                       (egg-get `A 3)
                                       (egg-get `A 3)))
                        (egg-vec (list (egg-get `B 2)
                                       (egg-get `B 3)
                                       (egg-get `B 2)
                                       (egg-get `B 3))))))
        (define prog-smt
          (prog
           (list
            (vec-extern-decl 'A 4 'extern-input-array)
            (vec-extern-decl 'B 4 'extern-input-array)
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
            (vec-extern-decl 'A 4 'extern-input-array)
            (vec-extern-decl 'B 4 'extern-input-array)
            (vec-extern-decl 'C 4 'extern-output)))
        (define postlude
          (list
            (vec-store 'C 'mac-out_0 0 4)))

        ; Check parsing from s-expression
        (define egg-ast (parse-from-string egg-s-exp))
        (check-equal? egg-ast gold-ast)
        (pretty-print egg-ast)

        ; Conversion from egg to dios dsl
        (define-values (_ egg-res) (egg-to-dios-prog egg-ast))
        (define full-egg-prog
          (prog (flatten (list prelude egg-res postlude))))
        (pretty-print full-egg-prog)

        ; Check equality to SMT-found version
        (assert
          (equal?
            (unsat)
            (verify-prog (to-v-list-prog prog-smt)
                         (to-v-list-prog full-egg-prog)
                         #:fn-map (hash 'vec-mac vector-mac
                                        'vec-mul vector-multiply)))))
      (test-case
        "2x3 3x3 mat mul"
        (define egg-s-exp
          "(Concat
             (VecMAC
               (VecMAC
                 (VecMul
                   (LitVec
                     (Get A 2)
                     (Get A 2)
                     (Get A 2)
                     (Get A 5))
                   (LitVec
                     (Get B 6)
                     (Get B 7)
                     (Get B 8)
                     (Get B 6)))
                 (LitVec
                   (Get A 1)
                   (Get A 1)
                   (Get A 1)
                   (Get A 4))
                 (LitVec
                   (Get B 3)
                   (Get B 4)
                   (Get B 5)
                   (Get B 3)))
               (LitVec
                 (Get A 0)
                 (Get A 0)
                 (Get A 0)
                 (Get A 3))
               (LitVec
                 (Get B 0)
                 (Get B 1)
                 (Get B 2)
                 (Get B 0)))
             (VecMAC
               (VecMAC
                 (VecMul
                   (Vec (Get B 7) (Get B 8) 0 0)
                   (Vec (Get A 5) (Get A 5) 0 0))
                 (Vec (Get B 4) (Get B 5) 0 0)
                 (Vec (Get A 4) (Get A 4) 0 0))
               (Vec (Get B 1) (Get B 2) 0 0)
               (Vec (Get A 3) (Get A 3) 0 0)))")

        (define prog-smt
          (prog
           (list
            (vec-extern-decl 'A 6 'extern-input-array)
            (vec-extern-decl 'B 9 'extern-input-array)
            (vec-extern-decl 'C 6 'extern-output)
            (vec-decl 'reg-C 4)
            (vec-load 'C_0_4 'C 0 4)
            (vec-load 'C_4_6 'C 4 6)
            (vec-const 'shuf0-0 '#(2 1 1 5) 'int)
            (vec-const 'shuf1-0 '#(6 4 5 6) 'int)
            (vec-shuffle 'reg-A 'shuf0-0 '(A))
            (vec-shuffle 'reg-B 'shuf1-0 '(B))
            (vec-write 'reg-C 'C_0_4)
            (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
            (vec-write 'C_0_4 'out)
            (vec-const 'shuf0-1 '#(0 0 0 4) 'int)
            (vec-const 'shuf1-1 '#(0 1 2 3) 'int)
            (vec-shuffle 'reg-A 'shuf0-1 '(A))
            (vec-shuffle 'reg-B 'shuf1-1 '(B))
            (vec-write 'reg-C 'C_0_4)
            (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
            (vec-write 'C_0_4 'out)
            (vec-const 'shuf0-2 '#(5 5 5 4) 'int)
            (vec-const 'shuf1-2 '#(7 8 8 6) 'int)
            (vec-shuffle 'reg-A 'shuf0-2 '(A))
            (vec-shuffle 'reg-B 'shuf1-2 '(B))
            (vec-write 'reg-C 'C_4_6)
            (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
            (vec-write 'C_4_6 'out)
            (vec-const 'shuf0-3 '#(4 4 4 5) 'int)
            (vec-const 'shuf1-3 '#(4 5 4 4) 'int)
            (vec-shuffle 'reg-A 'shuf0-3 '(A))
            (vec-shuffle 'reg-B 'shuf1-3 '(B))
            (vec-write 'reg-C 'C_4_6)
            (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
            (vec-write 'C_4_6 'out)
            (vec-const 'shuf0-4 '#(1 2 2 3) 'int)
            (vec-const 'shuf1-4 '#(3 7 8 0) 'int)
            (vec-shuffle 'reg-A 'shuf0-4 '(A))
            (vec-shuffle 'reg-B 'shuf1-4 '(B))
            (vec-write 'reg-C 'C_0_4)
            (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
            (vec-write 'C_0_4 'out)
            (vec-const 'shuf0-5 '#(3 3 2 3) 'int)
            (vec-const 'shuf1-5 '#(1 2 1 0) 'int)
            (vec-shuffle 'reg-A 'shuf0-5 '(A))
            (vec-shuffle 'reg-B 'shuf1-5 '(B))
            (vec-write 'reg-C 'C_4_6)
            (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
            (vec-write 'C_4_6 'out)
            (vec-store 'C 'C_0_4 0 4)
            (vec-store 'C 'C_4_6 4 6))))
        (define prelude
          (list
            (vec-extern-decl 'A 6 'extern-input-array)
            (vec-extern-decl 'B 9 'extern-input-array)
            (vec-extern-decl 'C 6 'extern-output)
            (vec-const 'Z '#(0) 'float)))

        ; Parse from s-expression
        (define egg-ast (parse-from-string egg-s-exp))
        ; Conversion from egg to dios dsl
        (define-values (names egg-res) (egg-to-dios-prog egg-ast))

        (define postlude
          (for/list ([n names]
                     [i (in-naturals 0)])
            (vec-store 'C n (* i 4) (* (+ i 1) 4))))

        (define full-egg-prog
          (prog (flatten (list prelude egg-res postlude))))
        (pretty-print full-egg-prog)

        ; Check equality to SMT-found version
        (assert
          (equal?
            (unsat)
            (verify-prog (to-v-list-prog prog-smt)
                         (to-v-list-prog full-egg-prog)
                         #:fn-map (hash 'vec-mac vector-mac
                                        'vec-mul vector-multiply)))))
      (test-case
        "2x2 2x2 2d conv"
        (define egg-s-exp
          "(Concat
            (VecMAC
              (VecMul
                (LitVec
                  (Get I 0)
                  (Get I 0)
                  (Get I 1)
                  (Get I 0))
                (LitVec
                  (Get F 0)
                  (Get F 1)
                  (Get F 1)
                  (Get F 2)))
              (LitVec 0 (Get F 0) 0 (Get F 0))
              (LitVec 0 (Get I 1) 0 (Get I 2)))
            (Concat
              (VecMAC
                (VecMAC
                  (VecMAC
                    (VecMul
                      (LitVec (Get I 3) 0 0 0)
                      (LitVec (Get F 0) 0 0 0))
                    (LitVec (Get F 1) (Get F 1) 0 0)
                    (LitVec (Get I 2) (Get I 3) 0 0))
                  (LitVec (Get I 1) 0 0 (Get I 3))
                  (LitVec (Get F 2) 0 0 (Get F 2)))
                (LitVec
                  (Get I 0)
                  (Get I 1)
                  (Get I 2)
                  (Get I 2))
                (LitVec
                  (Get F 3)
                  (Get F 3)
                  (Get F 2)
                  (Get F 3)))
              (VecMul
                (LitVec (Get F 3) 0 0 0)
                (LitVec (Get I 3) 0 0 0))))")

        (define prog-smt
          (prog
            (list
              (vec-extern-decl 'I 4 'extern-input-array)
              (vec-extern-decl 'F 4 'extern-input-array)
              (vec-extern-decl 'O 9 'extern-output)
              (vec-const 'Z '#(0) 'float)
              (vec-decl 'reg-O 4)
              (vec-load 'O_0_4 'O 0 4)
              (vec-load 'O_4_8 'O 4 8)
              (vec-load 'O_8_9 'O 8 9)
              (vec-const 'shuf0-0 '#(2 3 2 3) 'int)
              (vec-const 'shuf1-0 '#(1 1 2 2) 'int)
              (vec-shuffle 'reg-I 'shuf0-0 '(I Z))
              (vec-shuffle 'reg-F 'shuf1-0 '(F Z))
              (vec-write 'reg-O 'O_4_8)
              (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
              (vec-write 'O_4_8 'out)
              (vec-const 'shuf0-1 '#(0 1 1 2) 'int)
              (vec-const 'shuf1-1 '#(3 3 7 3) 'int)
              (vec-shuffle 'reg-I 'shuf0-1 '(I Z))
              (vec-shuffle 'reg-F 'shuf1-1 '(F Z))
              (vec-write 'reg-O 'O_4_8)
              (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
              (vec-write 'O_4_8 'out)
              (vec-const 'shuf0-2 '#(1 5 6 4) 'int)
              (vec-const 'shuf1-2 '#(2 0 3 0) 'int)
              (vec-shuffle 'reg-I 'shuf0-2 '(I Z))
              (vec-shuffle 'reg-F 'shuf1-2 '(F Z))
              (vec-write 'reg-O 'O_4_8)
              (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
              (vec-write 'O_4_8 'out)
              (vec-const 'shuf0-3 '#(0 1 1 2) 'int)
              (vec-const 'shuf1-3 '#(0 0 1 0) 'int)
              (vec-shuffle 'reg-I 'shuf0-3 '(I Z))
              (vec-shuffle 'reg-F 'shuf1-3 '(F Z))
              (vec-write 'reg-O 'O_0_4)
              (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
              (vec-write 'O_0_4 'out)
              (vec-const 'shuf0-4 '#(6 0 4 0) 'int)
              (vec-const 'shuf1-4 '#(3 1 2 2) 'int)
              (vec-shuffle 'reg-I 'shuf0-4 '(I Z))
              (vec-shuffle 'reg-F 'shuf1-4 '(F Z))
              (vec-write 'reg-O 'O_0_4)
              (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
              (vec-write 'O_0_4 'out)
              (vec-const 'shuf0-5 '#(3 0 2 3) 'int)
              (vec-const 'shuf1-5 '#(0 5 6 6) 'int)
              (vec-shuffle 'reg-I 'shuf0-5 '(I Z))
              (vec-shuffle 'reg-F 'shuf1-5 '(F Z))
              (vec-write 'reg-O 'O_4_8)
              (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
              (vec-write 'O_4_8 'out)
              (vec-const 'shuf0-6 '#(3 0 2 3) 'int)
              (vec-const 'shuf1-6 '#(3 1 2 2) 'int)
              (vec-shuffle 'reg-I 'shuf0-6 '(I Z))
              (vec-shuffle 'reg-F 'shuf1-6 '(F Z))
              (vec-write 'reg-O 'O_8_9)
              (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
              (vec-write 'O_8_9 'out)
              (vec-store 'O 'O_0_4 0 4)
              (vec-store 'O 'O_4_8 4 8)
              (vec-store 'O 'O_8_9 8 9))))

        (define prelude
          (list
            (vec-extern-decl 'I 4 'extern-input-array)
            (vec-extern-decl 'F 4 'extern-input-array)
            (vec-extern-decl 'O 9 'extern-output)
            (vec-const 'Z '#(0) 'float)))

        ; Parse from s-expression
        (define egg-ast (parse-from-string egg-s-exp))

        ; Conversion from egg to dios dsl
        (define-values (names egg-res) (egg-to-dios-prog egg-ast))
        (pretty-print egg-res)

        (define postlude
          (for/list ([n (flatten names)]
                     [i (in-naturals 0)])
            (vec-store 'O n (* i 4) (* (+ i 1) 4))))

        (define full-egg-prog
          (prog (flatten (list prelude egg-res postlude))))
        (pretty-print full-egg-prog)

        ; Check equality to SMT-found version
        (assert
          (equal?
            (unsat)
            (verify-prog (to-v-list-prog prog-smt)
                         (to-v-list-prog full-egg-prog)
                         #:fn-map (hash 'vec-mac vector-mac
                                        'vec-mul vector-multiply))))))))
