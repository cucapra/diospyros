#lang racket

(require "dsp-insts.rkt"
         "matrix-utils.rkt"
         "interp.rkt"
         "dsp-api.rkt")

(provide (all-defined-out))

;XXX(alexa) : parametrize 
(define function-name "kernel")

(struct align-pos (align offset))

(define (cmds-to-lines cmds)
  (define sep ";\n")
  (string-join cmds sep #:after-last sep))

(define (emit program)
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
      [(vec-load id start end)
       (cond
         [(has-align? memory)
          (match-define (align-pos align offset) (align-env-ref memory))
          (unless (< start end) (error "malformed load range"))
          (unless (= offset start) (error "non-aligning load"))
          (align-env-set! memory (align-pos align (+ offset (- end start))))
          (list (emit-load id memory (- start offset) (- end offset) align))]
         [else
          (unless (= start 0) (error "non-aligning load"))
          (match-define (cons align cmd) (emit-align memory))
          (align-env-set! memory (align-pos align end))
          (list cmd (emit-load id memory start end align))])]
      [(vec-unload id start)
       void]
      [(vec-const id init)
       void]
      [(vec-shuffle id inp idxs)
       (match-define (cons shuffle-g cmd) (emit-shuffle id inp idxs))
       (add-shuffle-global shuffle-g)
       cmd]
      [(vec-select id inp1 inp2 idxs)
       (match-define (cons shuffle-g cmd) (emit-select id inp1 inp2 idxs))
       (add-shuffle-global shuffle-g)
       cmd]
      [(vec-shuffle-set! out-vec inp idxs)
       void]
      [(vec-app id f inps)
       void]))

  (define cmds (flatten
                (for/list ([inst (prog-insts program)])
    (emit-cmds inst))))

  (display (cmds-to-lines (unbox shuffle-globals)))
  (display (cmds-to-lines cmds)))

(define/prog pg
  ('a = vec-load 0 10)
  ('b = vec-load 10 20)
  ('c = vec-shuffle 'a (vector 0 1 2 3))
  ('d = vec-select 'a 'b (vector 0 1 4 5)))

(emit (prog pg))