#lang rosette

(require racket/cmdline
         json
         threading
         "./ast.rkt"
         "./configuration.rkt"
         "./uninterp-fns.rkt"
         "./utils.rkt")

(require (prefix-in c: c))

; Convert a subset of C to equivalent Racket, operating on lists of boxed
; Rosette real values.

(error-print-width 9999999999999999999999999999999)
(print-syntax-width +inf.0)
(pretty-print-depth #f)

(define debug #t)
(define c-path (box ""))

; Returns tuple (<base type>, <total size across dimensions>)
(define (multi-array-length array-ty)
  (define length (translate (c:type:array-length array-ty)))
  (define base (c:type:array-base array-ty))
  (pretty-print array-ty)
  (cond
    [(c:type:primitive? base)
      (when (not (eq? (c:type:primitive-name base) 'float))
        (src-error "Can't handle array type" array-ty))
      length]
    [(eq? base #f) length]
    [(c:type:array? base) `(* (unquote length) (unquote (multi-array-length base)))]
    [else (src-error "Can't handle array type" array-ty)]))

(define (get-array-dim array-ty)
  (define (get-array-dim-rec array-ty dim size-list)
    (define length (translate (c:type:array-length array-ty)))
    (define base (c:type:array-base array-ty))
    (cond
      [(c:type:primitive? base)
        (quasiquote
          ((unquote (+ dim 1))
          (unquote-splicing size-list)
          (unquote length)))]
      [(eq? base #f)
        (quasiquote
          ((unquote (+ dim 1))
          (unquote-splicing size-list)
          (unquote length)))]
      [(c:type:array? base)
        (get-array-dim-rec
          base
          (+ dim 1)
          (quasiquote
            ((unquote-splicing size-list)
              (unquote length))))]
      [else (src-error "Can't handle array type" array-ty)]))
  (get-array-dim-rec array-ty 0 '()))

(define (translate-array-offset translated-stmt translated-offset)
  (if (pair? translated-stmt)
    (let* ([arr-name (car (cdr translated-stmt))]
          [row (car (cdr (cdr translated-stmt)))]
          [nrows (car (cdr (hash-ref array-ctx arr-name)))]
          [col translated-offset])
      `(+ (unquote col) (* (unquote row) (unquote nrows))))
    translated-offset))

(define (translate-array-name translated-stmt)
  (if (pair? translated-stmt)
    (let* ([arr-name (car (cdr translated-stmt))])
      arr-name)
    translated-stmt))

(define array-ctx (make-hash))

(define (translate stmt)
  (cond
    [(c:expr? stmt)
      (cond
        ; Literals: only support int and float
        [(c:expr:int? stmt) (c:expr:int-value stmt)]
        [(c:expr:float? stmt) (c:expr:float-value stmt)]

        ; Assign
        [(c:expr:assign? stmt)
          (if (c:expr:array-ref? (c:expr:assign-left stmt))
            ; Array update
            (let* ([translated-stmt (translate (c:expr:array-ref-expr (c:expr:assign-left stmt)))]
                  [translated-offset (translate (c:expr:array-ref-offset (c:expr:assign-left stmt)))]
                  [offset (translate-array-offset translated-stmt translated-offset)]
                  [left (translate-array-name translated-stmt)]
                  [right (translate (c:expr:assign-right stmt))]
                  [op (translate (c:expr:assign-op stmt))])
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
                      [else (src-error  "Can't handle assign op" op)])))))

            ; Variable update
            (let* ([left (translate (c:expr:assign-left stmt))]
                   [right (translate (c:expr:assign-right stmt))]
                   [op (translate (c:expr:assign-op stmt))])
              (quasiquote
                (set!
                  (unquote left)
                  (unquote
                    (match (translate (c:expr:assign-op stmt))
                      [`= right]
                      [`+= (quasiquote (+ (unquote left) (unquote right)))]
                      [`-= (quasiquote (- (unquote left) (unquote right)))]
                      [`*= (quasiquote (* (unquote left) (unquote right)))]
                      [`>>= (quasiquote (arithmetic-shift (unquote left) (- (unquote right))))]
                      [else (src-error  "Can't handle assign op" op)]))))))]

        ; Operations
        [(c:expr:unop? stmt)
          (quasiquote
            ((unquote (translate (c:expr:unop-op stmt)))
            (unquote (translate (c:expr:unop-expr stmt)))))]
        [(c:expr:binop? stmt)
          (quasiquote
            ((unquote (translate (c:expr:binop-op stmt)))
            (unquote (translate (c:expr:binop-left stmt)))
            (unquote (translate (c:expr:binop-right stmt)))))]
        [(c:expr:postfix? stmt)
          (list
            (translate (c:expr:postfix-op stmt))
            (translate (c:expr:postfix-expr stmt)))]
        [(c:expr:prefix? stmt)
          (list
            (translate (c:expr:prefix-op stmt))
            (translate (c:expr:prefix-expr stmt)))]
        [(c:expr:ref? stmt) (translate (c:expr:ref-id stmt))]
        [(c:expr:array-ref? stmt)
          (let* ([translated-stmt (translate (c:expr:array-ref-expr stmt))]
                [translated-offset (translate (c:expr:array-ref-offset stmt))]
                [left (translate-array-name translated-stmt)]
                [offset (translate-array-offset translated-stmt translated-offset)])
            (quasiquote
                (v-list-get
                  (unquote left)
                  (unquote offset))))]
        [(c:expr:if? stmt)
          (quasiquote
            (if
              (unquote (translate (c:expr:if-test stmt)))
              (unquote (translate (c:expr:if-cons stmt)))
              (unquote (translate (c:expr:if-alt stmt)))))]
        [(c:expr:call? stmt)
          (define fn-name
            (let* ([fn (translate (c:expr:call-function stmt))])
              ; Function translations
              (match fn
                [`powf `expt]
                [else fn])))
          (define args
             (for/list ([arg (c:expr:call-arguments stmt)])
              (translate arg)))
          (cons fn-name args)]

        [else (src-error "Can't handle expr" stmt)])]
    [(c:decl? stmt)
      (cond
        [(c:decl:vars? stmt)
          (define stmts
            (for/list ([decl (c:decl:vars-declarators stmt)])
              (let* ([init (c:decl:declarator-initializer decl)]
                     [type (c:decl:declarator-type decl)])
                ; Assumes this is float or float array
                (define initializer
                  (cond
                    [(c:init:compound? init)
                      (define translated-values
                        (map
                          (lambda (expr) (translate (c:init:expr-expr expr)))
                          (c:init:compound-elements init)))
                      (define boxed-list
                        (map
                          (lambda (v) (quasiquote (box (unquote v))))
                          translated-values))
                      (quasiquote (list unquote boxed-list))]
                    [init
                      (translate (c:init:expr-expr init))]
                    [(c:type:array? type)
                      (define array-dim-info-list (get-array-dim type))
                      (hash-set!
                        array-ctx
                        (translate (c:decl:declarator-id decl))
                        (quasiquote (unquote array-dim-info-list)))
                      `(make-v-list-zeros (unquote (multi-array-length type)))]
                    [(c:type:primitive? type) 0]
                    [else (src-error "Unexpected initializer in declaration" stmt)]))
                (quasiquote
                  (define
                    (unquote (translate (c:decl:declarator-id decl)))
                    (unquote initializer))))))
          (cond
            [(empty? stmts) `void]
            [(equal? 1 (length stmts)) (first stmts)]
            [else `(begin (unquote stmts))])]
        [else (src-error "Can't handle declaration" stmt)])]
    [(c:id? stmt)
      (cond
        [(c:id:var? stmt) (c:id:var-name stmt)]
        [(c:id:op? stmt)
          (define name (c:id:op-name stmt))
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
        [(c:id:label? stmt) (src-error "Can't handle labels" stmt)])]
    [(c:stmt:expr? stmt)
      (translate (c:stmt:expr-expr stmt))]
    [(c:stmt:block? stmt)
      (if (empty? (c:stmt:block-items stmt))
          `void
          (append (list `begin)
            (for/list ([s (c:stmt:block-items stmt)])
              (translate s))))]
    [(c:stmt:if? stmt)
      (if (not (c:stmt:if-alt stmt))
        (quasiquote
          (when
            (unquote (translate (c:stmt:if-test stmt)))
            (unquote (translate (c:stmt:if-cons stmt)))))
        (quasiquote
          (if
            (unquote (translate (c:stmt:if-test stmt)))
            (unquote (translate (c:stmt:if-cons stmt)))
            (unquote (translate (c:stmt:if-alt stmt))))))]
    [(c:stmt:while? stmt)
      (define test (translate (c:stmt:while-test stmt)))
      (define body (translate (c:stmt:while-body stmt)))
      `(call/ec (lambda (break)
        (letrec ([loop (lambda ()
          (when (unquote test)
            (call/ec (lambda (continue) (unquote body)))
          (loop)))])
        (loop))))]
    [(c:stmt:for? stmt)
      (let ([init (c:stmt:for-init stmt)]
            [test (c:stmt:for-test stmt)]
            [update (c:stmt:for-update stmt)]
            [body (translate (c:stmt:for-body stmt))])

        (when (not init) (src-error "For loops must include intialization" stmt))
        (define-values (idx idx-init)
          (cond
            [(c:decl:vars? init)
              (when (not (eq? 1 (length (c:decl:vars-declarators init))))
                (src-error "For loops must have a single index variable" init))
              (define fi (first (c:decl:vars-declarators init)))
              (values
                (translate (c:decl:declarator-id fi))
                (translate (c:init:expr-expr (c:decl:declarator-initializer fi))))]
            [else (src-error "Unexpected for loop initializer " init)]))
        (when (not update) (src-error "For loops must include update" stmt))

        (define t-update (translate update))
        (define update-skip
          (match t-update
            [`(++ (unquote idx)) 1]
            [`(+= (unquote idx) , n) n]
            [`(set! (unquote idx) (+ (unquote n) (unquote idx))) n]
            [`(-- (unquote idx)) -1]
            [`(-= (unquote idx) , n) (- n)]
            [`(set! (unquote idx) (- (unquote n) (unquote idx))) (- n)]
            [else (src-error "Can't handle for loop update" update)]))

       `(let ([(unquote idx) (unquote idx-init)])
          (call/ec (lambda (break)
            (letrec ([loop (lambda ()
              (when (unquote (translate test))
              (call/ec (lambda (continue) (unquote body)))
              (set! (unquote idx) (+ (unquote idx) (unquote update-skip)))
              (loop)))])
            (loop))))))]
    [(c:stmt:continue? stmt)
      `(continue)]
    [(c:stmt:break? stmt)
      `(break)]
    [(c:stmt:return? stmt)
       ; TODO: handle early returns
      (translate (c:stmt:return-result stmt))
    ]
    [(void? stmt)
      `void]
    [else (src-error "Can't handle statement" stmt)]))

; Extracts the number of nested holes the base type of the pointer is in
; ex: *int = 1, **int = 2, ***int = 3...
(define (extract-pointer-dimension ty)
  (cond
    [(eq? ty #f) 0]
    [else (+ 1 (extract-pointer-dimension (c:type:pointer-base ty)))]))

; Extracts n arguments from args beginning at idx as a list, if possible,
; otherwise empty list
(define (extract-next-args n idx args)
  (cond
    [(>= idx (length args)) '()]
    [(eq? n 0) '()]
    [else
      (define nth-arg (list-ref args idx))
      (define nth-ty (c:decl:declarator-type (c:decl:formal-declarator nth-arg)))
      (define nth-arg-processed (translate (c:decl:declarator-id (c:decl:formal-declarator nth-arg))))
      (if (c:type:pointer? nth-ty)
        '()
        (cons nth-arg-processed (extract-next-args (- n 1) (+ idx 1) args)))]))

; Marks however many arguments immediately after pointer as array dimensions
(define (handle-pointer-as-array ty arg idx unprocessed-args)
  (when (< (+ idx 1) (length unprocessed-args))
    (let* ([pointer-depth (extract-pointer-dimension ty)]
           [n-args (extract-next-args pointer-depth (+ idx 1) unprocessed-args)])
      (if (eq? n-args '())
        array-ctx
        (hash-set!
          array-ctx
          (translate (c:decl:declarator-id (c:decl:formal-declarator arg)))
          (quasiquote (unquote n-args)))))))

(define (translate-fn-decl fn-decl)
  (match fn-decl
    [(c:decl:function decl-stmt
                    c:decl:function-storage-class
                    c:decl:function-inline?
                    c:decl:function-return-type
                    c:decl:function-declarator
                    c:decl:function-preamble
                    c:decl:function-body)
      (define args-lst
        (let ([unprocessed-args (c:type:function-formals
                                  (c:decl:declarator-type c:decl:function-declarator))])
          (for/list ([arg unprocessed-args]
                    [idx (in-range (length unprocessed-args))])
            (define ty (c:decl:declarator-type (c:decl:formal-declarator arg)))
            ; add to array context for pointer and array arguments in function declarations
            (cond
              [(c:type:pointer? ty) (handle-pointer-as-array ty arg idx unprocessed-args)]
              [(c:type:array? ty)
                (begin
                  (define array-dim-info-list (get-array-dim ty))
                  (hash-set!
                    array-ctx
                    (translate (c:decl:declarator-id (c:decl:formal-declarator arg)))
                    (quasiquote (unquote array-dim-info-list))))])
            (translate (c:decl:declarator-id (c:decl:formal-declarator arg))))))
      (define fn-body (translate c:decl:function-body))
      (quasiquote
        (define
          (unquote
            (append
              (list (translate (c:decl:declarator-id c:decl:function-declarator)))
              (for/list ([arg (c:type:function-formals
                                (c:decl:declarator-type c:decl:function-declarator))])
                (translate (c:decl:declarator-id (c:decl:formal-declarator arg))))))
               ; TODO: handle early returns
              (unquote fn-body)))]
    [else (src-error "Can't translate function" fn-decl)]))

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


(define (position-to-string port start-offset span)
  (define pos (file-position port))
  (file-position port (sub1 start-offset))
  (define result (read-string span port))
  (file-position port pos)
  result)


(define (src-error description expr)
  (define src (cond
    [(c:src? expr) expr]
    [(c:expr? expr) (c:expr-src expr)]
    [(c:stmt? expr) (c:stmt-src expr)]
    [(c:id? expr) (c:id-src expr)]
    [(c:decl? expr) (c:decl-src expr)]
    [(c:init? expr) (c:init-src expr)]
    [(c:type? expr) (c:type-src expr)]
    [else (raise-user-error  "Unexpected expression. Please file a bug for Diospyros: https://github.com/cucapra/diospyros/issues/new" expr)]))

  (define bug-str
    "If this is unexpected, please file a bug for Diospyros: https://github.com/cucapra/diospyros/issues/new")
  (match src
    [(c:src start-offset
            start-line
            start-col
            end-offset
            end-line
            end-col
          _)
      (define span (- end-offset start-offset))
      (define c-src
        (position-to-string (open-input-file (unbox c-path))
                            start-offset
                            span))
      (define rkt-srcloc
        (srcloc (unbox c-path) start-line start-col #f span))

      (raise-user-error (~a description ":\n" (srcloc->string rkt-srcloc) ":" c-src "\n" bug-str))]))

(module+ main

  (define input-path
    (command-line
      #:program "Diospyros C-metaprogramming"
      #:args (path)
      path))

  (define path (string->path (~a input-path "/preprocessed.c")))
  (set-box! c-path path)
  (define program (c:parse-program path))

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
    [(c:decl:function decl-stmt
                    c:decl:function-storage-class
                    c:decl:function-inline?
                    c:decl:function-return-type
                    c:decl:function-declarator
                    c:decl:function-preamble
                    c:decl:function-body)
      (for/list ([arg (c:type:function-formals
                      (c:decl:declarator-type c:decl:function-declarator))])
        (define ty (c:decl:declarator-type (c:decl:formal-declarator arg)))
        ; array-len is false if scalar
        (define array-len
          (if (c:type:array? ty) (multi-array-length ty) #f))
        (list
          array-len
          (translate (c:decl:declarator-id (c:decl:formal-declarator arg)))))]))

  (when debug
    (pretty-print args))

  (define fn-name
    (match outer-function
      [(c:decl:function decl-stmt
                      c:decl:function-storage-class
                      c:decl:function-inline?
                      c:decl:function-return-type
                      c:decl:function-declarator
                      c:decl:function-preamble
                      c:decl:function-body)
        (translate (c:decl:declarator-id c:decl:function-declarator))]
      [else (src-error "Can't handle declaration" outer-function)]))

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
          (raise-user-error "Scalar output arguments (tagged _out) unsupported " arg-name-str))
        (define defn-output
          `(define (unquote arg-name)
                     (make-v-list-zeros (unquote (first arg)))))
        (when debug (pretty-print defn-output))
        (eval defn-output ns)
        ]
      [else (raise-user-error "Arguments should be tagged _in or _out, got " arg-name-str)])
    arg-name))

  (define racket-prog-with-args `(unquote (append (list fn-name) arg-names)))

  (when debug (pretty-print racket-prog-with-args))

  ; Run it!
  (eval racket-prog-with-args ns)

  (define output-names
    (filter (lambda (a) (string-suffix? (symbol->string a) "_out")) arg-names))
  (when (empty? output-names)
    (raise-user-error "Need to specify an output with suffix _out"))

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
