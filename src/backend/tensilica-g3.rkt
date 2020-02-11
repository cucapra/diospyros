#lang rosette

(require "../c-ast.rkt"
         "../ast.rkt"
         "../compile-passes.rkt"
         "../utils.rkt")

(provide tensilica-g3-compile)

(define fresh-name (make-name-gen identity))

(define (vector->string vec)
  (string-join (vector->list (vector-map number->string vec))
               ", "
               #:before-first "{"
               #:after-last "}"))

(define (tensilica-g3-compile p inputs outputs)
  ; Hoist all the constants to the top of the program.
  (define rprog (reorder-prog p))
  (pretty-print rprog)

  (define ast
    (for/list ([inst (prog-insts rprog)])
      (match inst
        [(vec-const id init)
         (list
           (c-decl "int"
                   "_LOCAL_DRAM0_"
                   (fresh-name "const")
                   (current-reg-size)
                   (vector->string init)))]
        [(vec-extern-decl id _)
         (let* ([inp-name (fresh-name "input")]
                [decl
                 (c-decl "float*"
                         "__restrict"
                         (symbol->string id)
                         #f
                         inp-name)]
               [load-name (string-append "load_"
                                         (symbol->string id))])
         (when (findf (lambda (arg) (equal? id arg)) inputs)
           (cons decl
                 (list
                   (c-decl "valign" #f load-name #f #f)
                   (c-assign load-name
                             (c-call "PDX_LA_MXF32_PP"
                                     (list
                                       (c-cast
                                         "xb_vecMxf32*"
                                         inp-name))))))))]
        [_ (void)])))

  (c-ast (flatten ast)))
