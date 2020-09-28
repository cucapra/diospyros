#lang rosette

(require c)

(define prog (parse-program (string->path "test.c")))

(assert (eq? (length prog) 1))

(define (translate stmt)
  (cond
    [(expr? stmt)
      (cond
        ; Literals: only support int and float
        [(expr:int? stmt) (expr:int-value stmt)]
        [(expr:float? stmt) (expr:float-value stmt)]

        ; Assign
        [(expr:assign? stmt)
          (if (expr:array-ref? (expr:assign-left stmt))
          (quasiquote
            (`bv-list-set!
            (unquote (translate (expr:array-ref-expr (expr:assign-left stmt))))
            (unquote (translate (expr:array-ref-offset (expr:assign-left stmt))))
            (unquote (translate (expr:assign-right stmt)))))
          (quasiquote
            ((unquote (translate (expr:assign-op stmt)))
            (unquote (translate (expr:assign-left stmt)))
            (unquote (translate (expr:assign-right stmt))))))]

        ; Operations
        [(expr:unop? stmt)
          (quasiquote
            ((unquote (translate (expr:unop-op stmt)))
            (unquote (translate (expr:unop-expr stmt)))))]
        [(expr:binop? stmt)
          (quasiquote
            ((unquote (translate (expr:binop-op stmt)))
            (unquote (translate (expr:binop-left stmt)))
            (unquote (translate (expr:binop-right stmt)))))]
        [(expr:postfix? stmt)
          (list
            (translate (expr:postfix-op stmt))
            (translate (expr:postfix-expr stmt)))]
        [(expr:ref? stmt) (translate (expr:ref-id stmt))]
        [else (error "can't handle expr" stmt)])]
    [(decl? stmt)
      (cond
        [(decl:vars? stmt)
          (for/list ([decl (decl:vars-declarators stmt)])
            (let* ([init (decl:declarator-initializer decl)]
                   [type (decl:declarator-type decl)])

              ; Assumes this is a variable declaration
              (quasiquote
                (define
                  (unquote (translate (decl:declarator-id decl)))
                  (unquote (translate (init:expr-expr init)))))))]
        [else (error "can't handle declaration" stmt)])]
    [(id? stmt)
      (cond
        [(id:var? stmt) (id:var-name stmt)]
        [(id:op? stmt) (id:op-name stmt)]
        [(id:label? stmt) (error "can't handle labels")])]
    [(stmt:expr? stmt)
      (translate (stmt:expr-expr stmt))]
    [(stmt:block? stmt)
      (for/list ([s (stmt:block-items stmt)])
        (translate s))]
    [(stmt:if? stmt)
      (if (not (stmt:if-alt stmt))
        (quasiquote
          (if
            (unquote (translate (stmt:if-test stmt)))
            (unquote (translate (stmt:if-cons stmt)))))
        (quasiquote
          (if
            (unquote (translate (stmt:if-test stmt)))
            (unquote (translate (stmt:if-cons stmt)))
            (unquote (translate (stmt:if-alt stmt))))))]
    [(stmt:for? stmt)
      (let ([init (stmt:for-init stmt)]
            [test (stmt:for-test stmt)]
            [update (stmt:for-update stmt)])
        (append
          (list 'c-for)
          (list
          (append
            (if init
                (list (translate init))
                (list #f))
            (list (translate test))
            (if update
              (list (translate update))
              (list #f))))
          (translate (stmt:for-body stmt))))]
    [(stmt:return? stmt)
      (pretty-print "return, ignoring")]
    [else (error "can't handle statement" stmt)]))

; TODO: handle multiple functions
(define (translate-fn-decl fn-decl)
  (match fn-decl
    [(decl:function decl-stmt
                    decl:function-storage-class
                    decl:function-inline?
                    decl:function-return-type
                    decl:function-declarator
                    decl:function-preamble
                    decl:function-body)

      ; TODO: check return type is void?
      (translate decl:function-body)]))

(translate-fn-decl (first prog))

