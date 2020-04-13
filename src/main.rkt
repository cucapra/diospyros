#lang rosette

(require "compiler.rkt"
         "ast.rkt"
         "c-ast.rkt"
         "backend/tensilica-g3.rkt"
         "backend/backend-utils.rkt"
         threading
         racket/cmdline)

(module+ main
  (define out-file (make-parameter #f))
  (define intermediate (make-parameter #f))

  (define file-to-compile
    (command-line
      #:program "Diospyros compiler"
      #:once-each
      [("-o" "--out-file") out
                           "C file to write to."
                           (out-file out)]
      [("--no-compile") "Output intermediate vector-lang program"
                        (intermediate #t)]
      [("--supress-git") "Output intermediate vector-lang program"
                        (supress-git-info #t)]
      #:args (filename)
      filename))

  (define input-string (read (open-input-file file-to-compile)))

  ; To eval the input, use the current namespace
  (define-namespace-anchor a)
  (define ns (namespace-anchor->namespace a))
  (define input-program (eval input-string ns))

  ; Compute the intermediate program.
  (define i-prog
    (~> input-program
        compile))

  (cond
    [(intermediate) (display (pretty-format i-prog))]
    [else
      (define (write-out prog)
        (if (out-file)
          (call-with-output-file
            (if (absolute-path? (out-file))
              (out-file)
              (build-path (current-directory) (out-file)))
            (lambda (out) (display prog out)))
          (display prog)))

      (~> i-prog
          tensilica-g3-compile
          to-string
          write-out)]))
