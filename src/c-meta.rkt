#lang rosette


(require racket/cmdline
         json
         threading
         "./ast.rkt"
         "./utils.rkt"
         "./configuration.rkt")

(require c)

; Convert a subset of C to equivalent Racket, operating on lists of boxed
; Rosette real values.

(error-print-width 9999999999999999999999999999999)
(pretty-print-depth #f)

(define debug #t)

; Returns tuple (<base type>, <total size across dimensions>)
(define (multi-array-length array-ty)
  (define length (translate (type:array-length array-ty)))
  (define base (type:array-base array-ty))
  (cond
    [(type:primitive? base) length]
    [(eq? base #f) length]
    [(type:array? base) (* length (multi-array-length base))]
    [else (error "Can't handle array type ~a" array-ty)]))

(define (get-array-dim array-ty)
  (define (get-array-dim-rec array-ty dim size-list)
    (define length (translate (type:array-length array-ty)))
    (define base (type:array-base array-ty))
    (cond
      [(type:primitive? base) 
        (quasiquote 
          ((unquote (+ dim 1))
          (unquote-splicing size-list)
          (unquote length)))]
      [(eq? base #f) 
        (quasiquote 
          ((unquote (+ dim 1))
          (unquote-splicing size-list)
          (unquote length)))]
      [(type:array? base) 
        (get-array-dim-rec 
          base 
          (+ dim 1)
          (quasiquote 
            ((unquote-splicing size-list)
              (unquote length))))]
      [else (error "Can't handle array type ~a" array-ty)]))
  (get-array-dim-rec array-ty 0 '()))

(define (translate-array-offset translated-stmt translated-offset)
  (if (pair? translated-stmt)
    (let* ([arr-name (car (cdr translated-stmt))]
          [row (car (cdr (cdr translated-stmt)))]
          [nrows (car (cdr (hash-ref array-ctx arr-name)))]
          [col translated-offset]
          [new-offset (+ col (* row nrows))])
      new-offset)
    translated-offset))

(define (translate-array-name translated-stmt) 
  (if (pair? translated-stmt)
    (let* ([arr-name (car (cdr translated-stmt))])
      arr-name)
    translated-stmt))

(define array-ctx (make-hash))

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
              (let* ([translated-stmt (translate (expr:array-ref-expr (expr:assign-left stmt)))]
                    [translated-offset (translate (expr:array-ref-offset (expr:assign-left stmt)))]
                    [offset (translate-array-offset translated-stmt translated-offset)]
                    [left (translate-array-name translated-stmt)]) 
                (quasiquote
                  (v-list-set!
                    (unquote left)
                    (unquote offset)
                    (unquote
                      (match op
                        [`= right]
                        [`+= (quasiquote (+
                                        (v-list-get (unquote left) (unquote offset))
                                        (unquote right)))]
                        [`-= (quasiquote (-
                                        (v-list-get (unquote left) (unquote offset))
                                        (unquote right)))]
                        [`*= (quasiquote (*
                                        (v-list-get (unquote left) (unquote offset))
                                        (unquote right)))]
                        [`>>= (quasiquote (arithmetic-shift
                                          (v-list-get (unquote left) (unquote offset))
                                          (- (unquote right))))]
                        [else (error  "can't handle assign op" op)]))))))
              
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
                      [`+= (quasiquote (+ (unquote left) (unquote right)))]
                      [`-= (quasiquote (- (unquote left) (unquote right)))]
                      [`*= (quasiquote (* (unquote left) (unquote right)))]
                      [`>>= (quasiquote (arithmetic-shift (unquote left) (- (unquote right))))]
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
          (let* ([translated-stmt (translate (expr:array-ref-expr stmt))]
                [translated-offset (translate (expr:array-ref-offset stmt))]
                [left (translate-array-name translated-stmt)]
                [offset (translate-array-offset translated-stmt translated-offset)])
            (quasiquote
                (v-list-get
                  (unquote left)
                  (unquote offset))))]
        [(expr:if? stmt)
          (quasiquote
            (if
              (unquote (translate (expr:if-test stmt)))
              (unquote (translate (expr:if-cons stmt)))
              (unquote (translate (expr:if-alt stmt)))))]
        [(expr:call? stmt)
          (define fn-name 
            (let* ([fn (translate (expr:call-function stmt))])
              ; Function translations
              (match fn
                [`powf `expt]
                ; [else (error "cant handle fn" fn)]
                [else fn])))
          (define args
             (for/list ([arg (expr:call-arguments stmt)])
              (translate arg)))
          (cons fn-name args)]

        [else (error "can't handle expr" stmt)])]
    [(decl? stmt)
      (cond
        [(decl:vars? stmt)
          (define stmts
            (for/list ([decl (decl:vars-declarators stmt)])
              (let* ([init (decl:declarator-initializer decl)]
                     [type (decl:declarator-type decl)])
                ; Assumes this is float or float array
                (if (init:compound? init)
                  (begin 
                    (define arr-name (translate (decl:declarator-id decl)))
                    (define translated-values 
                      (map 
                        (lambda (expr) 
                          (translate (init:expr-expr expr))) 
                        (init:compound-elements init)))
                    (define boxed-list 
                      (map 
                        (lambda (v) 
                          (quasiquote (box (unquote v)))) 
                        translated-values))
                    (quasiquote 
                      (define (unquote arr-name) (list unquote boxed-list))))
                  (begin 
                    (define initializer
                      (cond
                        [init
                          (translate (init:expr-expr init))]
                        [(type:array? type)
                          (define array-dim-info-list (get-array-dim type))
                          (hash-set! 
                            array-ctx 
                            (translate (decl:declarator-id decl)) 
                            (quasiquote (unquote array-dim-info-list)))
                          `(make-v-list-zeros (unquote (multi-array-length type)))]
                        [(type:primitive? type) 0]
                        [else (error "unexpected initializer in declaration" stmt)]))
                    (quasiquote
                      (define
                        (unquote (translate (decl:declarator-id decl)))
                        (unquote initializer))))))))
          (cond
            [(empty? stmts) `void]
            [(equal? 1 (length stmts)) (first stmts)]
            [else `(begin (unquote stmts))])]
        [else (error "can't handle declaration" stmt)])]
    [(id? stmt)
      (cond
        [(id:var? stmt) (id:var-name stmt)]
        [(id:op? stmt)
          (define name (id:op-name stmt))
          (match name
            ['>> '(lambda (x y) (arithmetic-shift x (- y)))]
            ['<< 'arithmetic-shift]
            ['\|\| 'or]
            ['&& 'and]
            ['\| 'bitwise-ior]
            ['^ 'bitwise-xor]
            ['& 'bitwise-and]
            ['!= '(lambda (x y) (not (equal? x y)))]
            ['== 'equal?]
            [else name])]
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
    [(stmt:while? stmt)
      (define test (translate (stmt:while-test stmt)))
      (define body (translate (stmt:while-body stmt)))
      (define while-name
        (string->symbol (~a "while"
                             (src-start-line (expr-src (stmt:while-test stmt))))))
      (quasiquote
        (begin
          (define ((unquote while-name))
            (if (unquote test)
                (begin
                  (unquote body)
                  ((unquote while-name)))
                '()))
          ((unquote while-name))))]
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
       ; TODO: handle early returns
      (define value (translate (stmt:return-result stmt)))
      value]
    [else (error "can't handle statement" stmt)]))

(define (translate-fn-decl fn-decl)
  (match fn-decl
    [(decl:function decl-stmt
                    decl:function-storage-class
                    decl:function-inline?
                    decl:function-return-type
                    decl:function-declarator
                    decl:function-preamble
                    decl:function-body)

      (define fn-body (translate decl:function-body))
      (quasiquote
        (define
          (unquote
            (append
              (list (translate (decl:declarator-id decl:function-declarator)))
              (for/list ([arg (type:function-formals
                                (decl:declarator-type decl:function-declarator))])
                (translate (decl:declarator-id (decl:formal-declarator arg))))))
               ; TODO: handle early returns
              (unquote fn-body)))]
    [else (error "can't translate function" fn-decl)]))

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

(module+ main

  (define input-path
    (command-line
      #:program "Diospyros C-metaprogramming"
      #:args (path)
      path))

  (define program (parse-program (string->path (~a input-path "/preprocessed.c"))))

  (define outer-function (last program))
  (define (program-to-c program)
    (define helper-functions (drop-right program 1))
    (if (empty? helper-functions)
      (translate-fn-decl outer-function)
      (begin
        (define helper-trans (map translate-fn-decl helper-functions))
        (define outer-trans (translate-fn-decl outer-function))

        (append (list `begin)
                helper-trans
                (list outer-trans)))))

  (define racket-fn (program-to-c program))

  (when debug
    (pretty-print racket-fn))

  (define-namespace-anchor anc)
  (define ns (namespace-anchor->namespace anc))

  ; Assumes args are arrays of floats (potentially multi-dimensional) or scalar
  ; floats
  (define args (match outer-function
    [(decl:function decl-stmt
                    decl:function-storage-class
                    decl:function-inline?
                    decl:function-return-type
                    decl:function-declarator
                    decl:function-preamble
                    decl:function-body)
      (for/list ([arg (type:function-formals
                      (decl:declarator-type decl:function-declarator))])
        (define ty (decl:declarator-type (decl:formal-declarator arg)))
        ; array-len if false if scalar
        (define array-len
          (if (type:array? ty) (multi-array-length ty) #f))
        (list
          array-len
          (translate (decl:declarator-id (decl:formal-declarator arg)))))]))

  (when debug
    (pretty-print args))

  (define fn-name
    (match outer-function
      [(decl:function decl-stmt
                      decl:function-storage-class
                      decl:function-inline?
                      decl:function-return-type
                      decl:function-declarator
                      decl:function-preamble
                      decl:function-body)
        (translate (decl:declarator-id decl:function-declarator))]
      [else (error "can't handle decl" stmt)]))

  (define out-writer (make-spec-out-dir-writer input-path))

  (eval racket-fn ns)

  (define arg-names (for/list ([arg args])
    (define arg-name (second arg))
    (define arg-name-str (symbol->string (second arg)))
    (define arg-len (first arg))
    (cond
      ; Input
      [(string-suffix? arg-name-str "_in")
        (define defn-input
          (if arg-len
          `(define (unquote arg-name)
                       (make-symbolic-v-list (unquote (first arg))
                                             (unquote arg-name-str)))
          `(define (unquote arg-name)
                       (make-symbolic-with-prefix (unquote arg-name-str)
                                                  real?))))
        (when debug (pretty-print defn-input))
        (eval defn-input ns)
        ]
      ; Output
      [(string-suffix? arg-name-str "_out")
        (when (not arg-len)
          (error "Scalar output arguments (tagged _out) unsupported " arg-name-str))
        (define defn-output
          `(define (unquote arg-name)
                     (make-v-list-zeros (unquote (first arg)))))
        (when debug (pretty-print defn-output))
        (eval defn-output ns)
        ]
      [else (error "Arguments should be tagged _in or _out, got " arg-name-str)])
    arg-name))

  (define racket-prog-with-args `(unquote (append (list fn-name) arg-names)))

  (when debug (pretty-print racket-prog-with-args))

  ; Run it!
  (eval racket-prog-with-args ns)

  (define output-names
    (filter (lambda (a) (string-suffix? (symbol->string a) "_out")) arg-names))
  (when (empty? output-names)
    (error "Need to specify an output with suffix _out"))

  (define get-spec
    `(flatten (map align-to-reg-size (unquote (cons list output-names)))))

  (define args-decls (for/list ([arg args])
    (define arg-name (second arg))
    (define arg-name-str (symbol->string (second arg)))
    (define len (first arg))
    (define tag
      (cond
        [(string-suffix? arg-name-str "_out") `output-tag]
        [len `input-array-tag]
        [else `input-scalar-tag]))
    `(vec-extern-decl '(unquote arg-name)
                      (unquote (if len len 1))
                      (unquote tag))))

  (define get-prelude
    `(prog (cons (vec-const 'Z (make-v-list-zeros 1) float-type)
           (unquote (cons list args-decls)))))

  (define outputs
    (for/list ([arg (filter (lambda (a) (string-suffix?  (symbol->string (second a)) "_out")) args)])
      (define arg-name (second arg))
      `(list '(unquote arg-name) (unquote (first arg)))))
  (define get-outputs `(unquote (cons list outputs)))

  ; Get spec and check for forms we can't handle
  (define spec (eval get-spec ns))
  (define spec-string (pretty-format spec))
  (cond
    [(string-contains? spec-string "ite")
      (pretty-print "WARNING: Cannot handle data dependent control flow")]
    [else void])

  ; Write out
  (out-writer spec egg-spec)
  (out-writer (concretize-prog (eval get-prelude ns)) egg-prelude)
  (out-writer (eval get-outputs ns) egg-outputs)
  (out-writer racket-fn `racket-fn))
