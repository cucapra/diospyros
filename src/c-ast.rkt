#lang rosette

(require threading)

(provide (all-defined-out))

(define current-nest (make-parameter 2))

(struct c-ast (prog) #:transparent)

; expression
(struct c-cast (typ expr) #:transparent)
(struct c-call (func args) #:transparent)

; statements
(struct c-decl (typ ann id size init) #:transparent)
(struct c-assign (id expr) #:transparent)

; scopes & composition
(struct c-func-decl (out-typ name args body) #:transparent)
(struct c-scope (body) #:transparent)
(struct c-seq (stmts) #:transparent)
(struct c-if (con tr fal) #:transparent)


(define (to-string prog [tab-size 0])
  (match (c-ast-prog prog)
    [(c-cast typ expr)
     (format "(~a ~a)" typ expr)]
    [(c-call func args)
     (format "~a(~a)" func (~> args
                               (map (lambda (arg) (to-string arg tab-size)) _)
                               (string-join _ ", ")))]
    [(c-decl typ ann id size init)
     (string-append
       (format "~a ~a" typ id)
       (if size
         (format "[~a]" size)
         "")
       (if ann ann "")
       (if init
         (format " = ~a;" init)
         ";"))]
    [(c-assign id expr)
     (format "~a = ~a;" id (to-string expr tab-size))]
    [(c-func-decl out-typ name args body)
     (format "~a ~a(~a) {\n~a\n}"
             out-typ
             name
             (~> args
                 (map (lambda (arg) (to-string arg tab-size)) _)
                 (string-join _ ", "))
             (to-string body (+ (current-nest) tab-size)))]
    [(c-scope body)
     (format "{\n~a\n}"
             (to-string body (+ (current-nest) tab-size)))]
    [(c-seq stmts)
     (string-join (map
                    (lambda (stmt) (to-string stmt tab-size))
                    stmts)
                  (string-append "\n" (make-string tab-size " ")))]
    [(c-if con tr fal)
     (format "if (~a) {\n~a\n} else {\n~a\n}"
             (to-string con tab-size)
             (to-string tr tab-size)
             (to-string fal tab-size))]))
