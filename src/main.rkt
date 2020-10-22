#lang rosette

(require "compiler.rkt"
         "ast.rkt"
         "c-ast.rkt"
         "configuration.rkt"
         "uninterp-fns.rkt"
         "utils.rkt"
         "backend/tensilica-g3.rkt"
         "backend/backend-utils.rkt"
         "egg-to-dios-dsl.rkt"
         threading
         racket/cmdline)

(error-print-width 999999999999999999999999999)
(pretty-print-depth #f)

(define include #<<here-string-delimiter
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>
#include "../../../../src/scalars.h"

here-string-delimiter
)

(define (read-file-from-path path file)
  (define dir-path
    (if (absolute-path? path)
      path
      (build-path (current-directory) path)))
  (read (open-input-file (build-path dir-path (format "~a.rkt" file)))))

(module+ main
  (define out-file (make-parameter #f))
  (define egg (make-parameter #f))
  (define validation (make-parameter #f))
  (define intermediate (make-parameter #f))
  (define vec-width (make-parameter 4))

  (define input-path
    (command-line
      #:program "Diospyros compiler"
      #:once-each
      [("-o" "--out-file") out
                           "C file to write to."
                           (out-file out)]
      [("-e" "--egg") "Input is an egg kernel (input should be a directory)"
                      (egg #t)]
      [("-v" "--validation") "Translation validation on the input. Only valid with --egg."
                      (validation #t)]
      [("--no-compile") "Output intermediate vector-lang program"
                        (intermediate #t)]
      [("--suppress-git") "Don't write git info out"
                        (suppress-git-info #t)]
      [("-w" "--vec-width") width
                            "Vector width (default is 4)"
                            (vec-width (string->number width))]
      #:args (path)
      path))

  (define-namespace-anchor a)

  (parameterize [(current-reg-size (vec-width))]
    (when (and (not (egg)) (validation))
      (error "Translation validation flag not valid when not in egg mode"))

    (pretty-display (format "Reading input program from ~a" input-path))

    ; To eval the input, use the current namespace
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

    (pretty-display "Optimizing intermediate program")

    ; Translation validation hook
    (when (validation)
      (check-transform-with-fn-map uninterp-fn-map))

    (define compile-prog
      (if (validation)
        (lambda (x) (compile x
                            #:spec (read-file-from-path input-path egg-spec)))
        compile))

    ; Compute the intermediate program.
    (define i-prog
      (~> input-program
          compile-prog))

    (cond
      [(intermediate) (display (pretty-format i-prog))]
      [else
        (define (write-out prog)
          (if (out-file)
            (call-with-output-file
              (if (absolute-path? (out-file))
                (out-file)
                (build-path (current-directory) (out-file)))
              (lambda (out) (display include out) (display prog out))
              #:exists 'replace)
            (begin (display include) (display prog))))

         (pretty-display "Compiling to Tensilica backend")

        (~> i-prog
            tensilica-g3-compile
            to-string
            write-out)])))
