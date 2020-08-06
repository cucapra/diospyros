#lang rosette

(require "compiler.rkt"
         "ast.rkt"
         "c-ast.rkt"
         "configuration.rkt"
         "backend/tensilica-g3.rkt"
         "backend/backend-utils.rkt"
         "egg-to-dios-dsl.rkt"
         threading
         racket/cmdline)

(define (read-file-from-path path file)
  (define dir-path
    (if (absolute-path? path)
      path
      (build-path (current-directory) path)))
  (read (open-input-file (build-path dir-path (format "~a.rkt" file)))))

(module+ main
  (define out-file (make-parameter #f))
  (define egg (make-parameter #f))
  (define intermediate (make-parameter #f))

  (define input-path
    (command-line
      #:program "Diospyros compiler"
      #:once-each
      [("-o" "--out-file") out
                           "C file to write to."
                           (out-file out)]
      [("-e" "--egg") "Input is an egg kernel (input should be a directory)"
                      (egg #t)]
      [("--no-compile") "Output intermediate vector-lang program"
                        (intermediate #t)]
      [("--suppress-git") "Don't write git info out"
                        (suppress-git-info #t)]
      #:args (path)
      path))

  ; To eval the input, use the current namespace
  (define-namespace-anchor a)
  (define ns (namespace-anchor->namespace a))

  (define input-program
    (if egg
      (begin
        (egg-to-dios-dsl (read-file-from-path input-path egg-res)
                         (eval
                           (read-file-from-path input-path egg-prelude)
                           ns)
                         (eval
                           (read-file-from-path input-path egg-outputs)
                           ns)))
      (begin
        (define input-string (read (open-input-file input-path)))
        (eval input-string ns))))

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
            (lambda (out) (display prog out))
            #:exists 'replace)
          (display prog)))

      (~> i-prog
          tensilica-g3-compile
          to-string
          write-out)]))
