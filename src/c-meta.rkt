#lang rosette


(require racket/cmdline
         json
         threading
         "./ast.rkt"
         "./utils.rkt"
         "./configuration.rkt")

(require c)

(define program (parse-program (string->path "compile-out/preprocessed.c")))

(assert (eq? (length program) 1))

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
            ; Array update
            (let* ([left (translate (expr:array-ref-expr (expr:assign-left stmt)))]
                   [offset (translate (expr:array-ref-offset (expr:assign-left stmt)))]
                   [right (translate (expr:assign-right stmt))]
                   [op (translate (expr:assign-op stmt))])
              (quasiquote
                (v-list-set!
                  (unquote left)
                  (unquote offset)
                  (unquote
                    (match op
                      [`= right]
                      [`+= (quasiquote (+
                                       (unquote right)
                                       (v-list-get (unquote left) (unquote offset))))]
                      [`-= (quasiquote (-
                                       (unquote right)
                                       (v-list-get (unquote left) (unquote offset))))]
                      [`*= (quasiquote (*
                                       (unquote right)
                                       (v-list-get (unquote left) (unquote offset))))]
                      [else (error  "can't handle assign op" op)])))))
            ; Variable update
            (let* ([left (translate (expr:assign-left stmt))]
                   [right (translate (expr:assign-right stmt))]
                   [op (translate (expr:assign-op stmt))])
              (quasiquote
                (set!
                  (unquote left)
                  (unquote
                    (match (translate (expr:assign-op stmt))
                      [`= right]
                      [`+= (quasiquote (+ (unquote right) (unquote left)))]
                      [`-= (quasiquote (- (unquote right) (unquote left)))]
                      [`*= (quasiquote (* (unquote right) (unquote left)))]
                      [else (error  "can't handle assign op" op)]))))))]

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
          (define stmts
            (for/list ([decl (decl:vars-declarators stmt)])
              (let* ([init (decl:declarator-initializer decl)]
                     [type (decl:declarator-type decl)])

                ; Assumes this is a variable declaration
                (quasiquote
                  (define
                    (unquote (translate (decl:declarator-id decl)))
                    (unquote (translate (init:expr-expr init))))))))
          (cond
            [(empty? stmts) `void]
            [(equal? 1 (length stmts)) (first stmts)]
            [else `(begin (unquote stmts))])]
        [else (error "can't handle declaration" stmt)])]
    [(id? stmt)
      (cond
        [(id:var? stmt) (id:var-name stmt)]
        [(id:op? stmt) (id:op-name stmt)]
        [(id:label? stmt) (error "can't handle labels")])]
    [(stmt:expr? stmt)
      (translate (stmt:expr-expr stmt))]
    [(stmt:block? stmt)
      (if (empty? (stmt:block-items stmt))
          `void
          (append (list `begin)
            (for/list ([s (stmt:block-items stmt)])
              (translate s))))]
    [(stmt:if? stmt)
      (if (not (stmt:if-alt stmt))
        (quasiquote
          (when
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

        ; TODO: handle reverse iteration
        (define t-update (translate update))
        (define update-skip
          (match t-update
            [`(++ (unquote idx)) 1]
            [`(+= (unquote idx) , n) n]
            [`(set! (unquote idx) (+ (unquote n) (unquote idx))) n]
            [else (error "can't handle for loop update" t-update)]))

        (define-values (bound reverse)
          (match (translate test)
            [`(< (unquote idx) ,bound) (values bound #f)]
            [`(<= (unquote idx) ,bound) (values (- bound update-skip) #f)]
            [else (error "can't handle for loop bound" t-update)]))

        `(for ([(unquote idx) (in-range (unquote idx-init) (unquote bound) (unquote update-skip))])
          (unquote (translate (stmt:for-body stmt)))))]
    [(stmt:return? stmt)
      (when (stmt:return-result stmt) (error "can't handle non-void return"))
      `(raise 'return)]
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

      ; TODO: check return type is void
      (quasiquote
        (define
          (unquote
            (append
              (list (translate (decl:declarator-id decl:function-declarator)))
              (for/list ([arg (type:function-formals
                                (decl:declarator-type decl:function-declarator))])
                (translate (decl:declarator-id (decl:formal-declarator arg))))))
          ; `(with-handlers ([(lambda (x) (eq? x 'return)) void])
            (unquote (translate decl:function-body))))
      ; )
]))

(define (create-base-directory out-dir)
  (define base
    (if (absolute-path? out-dir)
      out-dir
      (build-path (current-directory) out-dir)))
  ; Create the base directory
  (when (pr (not (directory-exists? base)))
    (make-directory base))
  base)

; Return a function that creates a new file in the out-dir with a given name.
(define (make-spec-out-dir-writer out-dir)
  (define base (create-base-directory out-dir))
  (lambda (spec name)
    (let ([path (~> name
                    (format "~a.rkt" _)
                    string->path
                    (build-path base _))])
      (call-with-output-file path
        (lambda (out) (pretty-print spec out))
        #:exists 'replace))))

(define racket-fn (translate-fn-decl (first program)))

(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))

; Returns tuple (<base type>, <total size across dimensions>)
(define (multi-array-length array-ty)
  (define length (translate (type:array-length array-ty)))
  (define base (type:array-base array-ty))
  (cond
    [(type:primitive? base) length]
    [(eq? base #f) length]
    [(type:array? base) (* length (multi-array-length base))]
    [else (error "Can't handle array type ~a" array-ty)]))

; Assumes args are arrays of floats (potentially multi-dimensional)
(define args (match (first program)
  [(decl:function decl-stmt
                  decl:function-storage-class
                  decl:function-inline?
                  decl:function-return-type
                  decl:function-declarator
                  decl:function-preamble
                  decl:function-body)
    (for/list ([arg (type:function-formals
                      (decl:declarator-type decl:function-declarator))])
      (list
        (multi-array-length (decl:declarator-type (decl:formal-declarator arg)))
        (translate (decl:declarator-id (decl:formal-declarator arg)))))]))

(define fn-name (match (first program)
  [(decl:function decl-stmt
                  decl:function-storage-class
                  decl:function-inline?
                  decl:function-return-type
                  decl:function-declarator
                  decl:function-preamble
                  decl:function-body)
    (translate (decl:declarator-id decl:function-declarator))]))

(define out-writer (make-spec-out-dir-writer "compile-out"))

(eval racket-fn ns)

(define arg-names (for/list ([arg args])
  (define arg-name (second arg))
  (define arg-name-str (symbol->string (second arg)))
  (cond
    ; Input
    [(string-suffix? arg-name-str "_in")
      (eval `(define (unquote arg-name)
                     (make-symbolic-v-list (unquote (first arg))
                                           (unquote arg-name-str)))
            ns)
      ]
    ; Output
    [(string-suffix? arg-name-str "_out")
      (eval `(define (unquote arg-name)
                   (make-v-list-zeros (unquote (first arg))))
            ns)
      ]
    [else (error "Arguments should be tagged _in or _out, got " arg-name-str)])
  arg-name))

; Run it!
(eval `(unquote (append (list fn-name) arg-names)) ns)

(define output-names
  (filter (lambda (a) (string-suffix? (symbol->string a) "_out")) arg-names))
(when (empty? output-names)
  (error "Need to specify an output with suffix _out"))

(define get-spec `(unquote (cons flatten output-names)))

(define args-decls (for/list ([arg args])
  (define arg-name (second arg))
  (define arg-name-str (symbol->string (second arg)))
  `(vec-extern-decl '(unquote arg-name)
                    (unquote (first arg))
                    (unquote (if (string-suffix? arg-name-str "_in")
                        `input-tag
                        `output-tag)))))

(define get-prelude
  `(prog (cons (vec-const 'Z (make-v-list-zeros 1) float-type)
         (unquote (cons list args-decls)))))

(define outputs (for/list ([arg (filter (lambda (a) (string-suffix?  (symbol->string (second a)) "_out")) args)])
  (define arg-name (second arg))
  `(list '(unquote arg-name) (unquote (first arg)))))
(define get-outputs `(unquote (cons list outputs)))

; Write out
(out-writer (eval get-spec ns) egg-spec)
(out-writer (concretize-prog (eval get-prelude ns)) egg-prelude)
(out-writer (eval get-outputs ns) egg-outputs)
(out-writer racket-fn `racket-fn)

