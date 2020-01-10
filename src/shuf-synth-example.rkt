#lang rosette

(require "dsp-insts.rkt"
         "matrix-utils.rkt"
         racket/trace)

;; Interface to the data movememnt synthesis code.
(struct spec (inputs outputs) #:transparent)

;; Generate a spec for matrix multiply of a given size.
(define (matrix-multiply-spec A-rows A-cols B-rows B-cols)
  (assert (= A-cols B-rows))
  (define A-sym (make-symbolic-matrix A-rows A-cols))
  (define B-sym (make-symbolic-matrix B-rows B-cols))
  (define C
    (matrix A-rows B-cols (build-vector (* A-rows B-cols) (lambda (_) 0))))
  (for* ([i A-rows]
         [j B-cols])
    (define sum
      (apply
        +
        (for/list ([k A-cols])
          (* (matrix-ref A-sym i k)
             (matrix-ref B-sym k j)))))
    (matrix-set! C i j sum))

  (spec (list (matrix-elements A-sym)
              (matrix-elements B-sym))
        (list (matrix-elements C))))


(pretty-print (matrix-multiply-spec 2 3 3 3))

'done
