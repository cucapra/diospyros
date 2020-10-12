#lang rosette

(require c)

(define prog (parse-program (string->path "../demo/tmp.txt")))

;(define-values (stdout stderr) (gcc (lambda () prog)))

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
            (v-list-set!
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
        [(expr:prefix? stmt)
          (list
            (translate (expr:prefix-op stmt))
            (translate (expr:prefix-expr stmt)))]
        [(expr:ref? stmt) (translate (expr:ref-id stmt))]
        [(expr:array-ref? stmt)
          (quasiquote
            (v-list-get
              (unquote (translate (expr:array-ref-expr stmt)))
              (unquote (translate(expr:array-ref-offset stmt)))))]
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

        (when (not init) (error "for loops must include intialization"))
        (define-values (idx idx-init)
          (cond
            [(decl:vars? init)
              (when (not (eq? 1 (length (decl:vars-declarators init))))
                (error "for loops must have a single index variable"))
              (define fi (first (decl:vars-declarators init)))
              (values
                (translate (decl:declarator-id fi))
                (translate (init:expr-expr (decl:declarator-initializer fi))))]
            [else (error "unexpected for loop initializer " init)]))
        (when (not update) (error "for loops must include update"))
        (define t-update (translate update))
        (define update-skip
          (cond
            [(eq? t-update `(++ (unquote idx))) 1]
            [else (error "can't handle update")]))

        ; TODO: handle reverse iteration
        (define-values (bound reverse)
          (match (translate test)
            [`(< (unquote idx) ,bound)
              (values bound #f)]))

        `(for ([(unquote idx) (inrange (unquote idx-init) (unquote bound) (unquote update-skip))])
          (unquote (translate (stmt:for-body stmt)))))]
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
      (quasiquote
        (define
          (unquote
            (append
              (list (translate (decl:declarator-id decl:function-declarator)))
              (for/list ([arg (type:function-formals
                                (decl:declarator-type decl:function-declarator))])
                (translate (decl:declarator-id (decl:formal-declarator arg))))))

          (unquote (translate decl:function-body))))]))

(pretty-print (translate-fn-decl (first prog)))

