#lang racket

(require "dsp-insts.rkt"
         "matrix-utils.rkt"
         "ast.rkt"
         "dsp-api.rkt")

(provide (all-defined-out))

;XXX(alexa) : parametrize
(define function-name "kernel")

(struct align-pos (align offset))

(define (cmds-to-lines cmds)
  (define sep ";\n")
  (string-join cmds sep #:after-last sep))

(define (emit program mem-size)
  (define align-env (make-hash))
  (define (align-env-set! key val)
    (hash-set! align-env key val))
  (define (align-env-ref key)
    (hash-ref align-env key))
  (define (has-align? key)
    (hash-has-key? align-env key))

  (define shuffle-globals (box (list)))
  (define (add-shuffle-global g)
    (set-box! shuffle-globals (cons g (unbox shuffle-globals))))

  ;XXX(alexa) : handle input memory for multiple input arrays
  (define memory "memory")

  (define (emit-cmds inst)
    (match inst
      [(vec-load id start size)
       (cond
         [(has-align? memory)
          (match-define (align-pos align offset) (align-env-ref memory))
          (unless (= offset start) (error "non-aligning load"))
          (align-env-set! memory (align-pos align (+ offset size)))
          (emit-load id memory size align)]
         [else
          (unless (= start 0) (error "non-aligning load"))
          (match-define (cons align cmd) (emit-align memory))
          (align-env-set! memory (align-pos align size))
          (list cmd (emit-load id memory size align))])]
      [(vec-unload id start)
       ""]
      [(vec-const id init)
       (add-shuffle-global (emit-global-vector id init))
       (list)]
      [(vec-shuffle id idxs inp)
       (emit-shuffle id inp idxs)]
      [(vec-select id idxs inp1 inp2)
       (emit-select id inp1 inp2 idxs)]
      [(vec-shuffle-set! out-vec idxs inp)
       ""]
      [(vec-app id f inps)
       ;XXX(alexa): handle intrinsics with return values
       (emit-app f inps)]))

  (define cmds (flatten
                (for/list ([inst (prog-insts program)])
    (emit-cmds inst))))

  (display (cmds-to-lines (list (emit-memory "memory" mem-size))))
  (display (cmds-to-lines (unbox shuffle-globals)))
  (display (cmds-to-lines cmds)))

(define/prog pg
  ('a = vec-load 0 10)
  ('b = vec-load 10 20)
  ('c = vec-shuffle (vector 0 1 2 3) 'a )
  ('d = vec-select (vector 0 1 4 5) 'a 'b))

;(emit pg 30)