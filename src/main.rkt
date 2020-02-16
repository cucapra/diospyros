#lang rosette

(require "compiler.rkt"
         "backend/tensilica-g3.rkt"
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
      #:args (filename)))

  (when (not (out-file))
    (error 'dios
           "Missing output file."))


