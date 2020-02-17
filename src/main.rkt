#lang rosette

(require "compiler.rkt"
         "ast.rkt"
         "c-ast.rkt"
         "backend/tensilica-g3.rkt"
         threading
         racket/cmdline)

(module+ main
  (define out-file (make-parameter #f))

  (define file-to-compile
    (command-line
      #:program "Diospyros compiler"
      #:once-each
      [("-o" "--out-file") out
                           "C file to write to."
                           (out-file out)]
      #:args (filename)
      filename))

  (define input-string (read (open-input-file file-to-compile)))

  ; To eval the input, use the current namespace
  (define-namespace-anchor a)
  (define ns (namespace-anchor->namespace a))
  (define input-program (eval input-string ns))

  (when (not (out-file))
    (error 'dios
           "Missing output file."))

  (call-with-output-file (build-path (current-directory) (out-file))
    (lambda (out)
      (~> input-program
          compile
          tensilica-g3-compile
          to-string
          (display _ out)))))
