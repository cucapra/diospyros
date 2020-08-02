#lang rosette

(require threading)

(provide (all-defined-out))

(define current-nest (make-parameter 2))

(struct c-ast (prog) #:transparent)

; expression
(struct c-id (id)
  #:transparent
  #:guard (lambda (id type-name)
            (define str (cond
              [(string? id) id]
              [(symbol? id) (symbol->string id)]
              [else (error type-name
                           "Invalid identifier: ~e"
                           id)]))
            (string-replace str "-" "_")))

(struct c-num (num)
  #:transparent
  #:guard (lambda (num type-name)
            (cond
              [(number? num) num]
              [else (error type-name
                           "Invalid number: ~e"
                           num)])))
; Wrap a bare construct.
(struct c-bare (str) #:transparent)

(struct c-cast (typ expr) #:transparent)
(struct c-call (func args)
  #:transparent
  #:guard (lambda (func args type-name)
            (cond
              [(not (c-id? func))
               (error type-name
                      "Function name not an identifier: ~a"
                      func)]
              [(not (list? args))
               (error type-name
                      "Arguments not in list: ~a. Func: ~a."
                      args
                      func)]
              [else (values func args)])))
(struct c-deref (expr) #:transparent)

; statements
(struct c-decl (typ ann id size init)
  #:transparent
  #:guard (lambda (typ ann id size init type-name)
            (cond
              [(not (string? typ))
               (error type-name
                      "Invalid type: ~a."
                      typ)]
              [(not (c-id? id))
               (error type-name
                      "Invalid identifier: ~a."
                      id)]
              [(not (or (false? ann)
                        (string? ann)))
               (error type-name
                      "Invalid annotation: ~a. Id: ~a."
                      ann
                      id)]
              [(not (or (false? size)
                        (number? size)))
               (error type-name
                      "Invalid size: ~a. Id: ~a."
                      size
                      id)]
              [(not (or (false? init)
                        (c-bare? init)
                        (c-id? init)
                        (c-deref? init)))
               (error type-name
                      "Invalid init: ~a. Id: ~a."
                      init
                      id)]
              [else (values typ ann id size init)])))

(struct c-assign (id expr)
  #:transparent
  #:guard (lambda (id expr type-name)
            (cond
              [(not (c-id? id))
               (error type-name
                      "Invalid LHS: ~a"
                      id)]
              [else (values id expr)])))

; scopes & composition
(struct c-func-decl (out-typ name args body) #:transparent)
(struct c-scope (body) #:transparent)
(struct c-seq (stmts)
  #:transparent
  #:guard (lambda (stmts type-name)
            (cond
              [(not (list? stmts))
               (error type-name
                      "Not a list: ~a"
                      stmts)]
              [else (values stmts)])))
(struct c-if (con tr fal) #:transparent)
(struct c-stmt (expr) #:transparent)

(struct c-comment (str) #:transparent)

(struct c-empty () #:transparent)

(define (to-string prog [tab-size 0])
  (match prog
    [(c-empty) ""]
    [(c-ast prog) (to-string prog)]
    [(c-bare str) str]
    [(c-num num) (number->string num)]
    [(c-id id) id]
    [(c-deref expr) (format "*(~a)" (to-string expr))]
    [(c-cast typ expr)
     (format "(~a) ~a" typ (to-string expr))]
    [(c-call func args)
     (format "~a(~a)" (to-string func)
             (~> args
                 (map (lambda (arg) (to-string arg tab-size)) _)
                 (string-join _ ", ")))]
    [(c-decl typ ann id size init)
     (string-append
       typ
       (if ann (format " ~a" ann) "")
       " "
       (to-string id)
       (if size
         (format "[~a]" size)
         "")
       (if init
         (format " = ~a;" (to-string init))
         ";"))]
    [(c-assign id expr)
     (format "~a = ~a;" (to-string id) (to-string expr tab-size))]
    [(c-func-decl out-typ name args body)
     (format "~a ~a(~a) {\n~a\n}"
             out-typ
             name
             (~> args
                 (map (lambda (arg) (string-append
                                      (car arg)
                                      " "
                                      (cdr arg))) _)
                 (string-join _ ", "))
             (to-string body (+ (current-nest) tab-size)))]
    [(c-scope body)
     (format "{\n~a\n}"
             (to-string body (+ (current-nest) tab-size)))]
    [(c-seq stmts)
     (string-join (map
                    (lambda (stmt) (to-string stmt tab-size))
                    stmts)
                  (string-append "\n" (make-string tab-size #\ )))]
    [(c-if con tr fal)
     (format "if (~a) {\n~a\n} else {\n~a\n}"
             (to-string con tab-size)
             (to-string tr tab-size)
             (to-string fal tab-size))]
    [(c-stmt expr)
     (format "~a;" (to-string expr))]
    [(c-comment str)
      (format "/*\n~a\n*/" str)]
    [else (error 'to-string
                 "Invalid AST Node: ~a"
                 prog)]))
