#lang rosette

(require "dsp-insts.rkt"
         "ast.rkt"
         rosette/lib/match)

(provide (all-defined-out))

; Interpretation function that takes a program and an external memory.
; Returns a vector representing the state of the final memory.
(define (interp program memory)
  (define env (make-hash))
  (define (env-set! key val)
    (hash-set! env key val))
  (define (env-ref key)
    (hash-ref env key))

  (for ([inst (prog-insts program)])
    (match inst
      [(vec-load id start end)
       (env-set! id (vector-copy memory
                                 start
                                 end))]
      [(vec-unload id start)
       (vector-copy! memory start (env-ref id))]
      [(vec-const id init)
       (env-set! id init)]
      [(vec-shuffle id inp idxs)
       (env-set! id
                 (vector-shuffle (env-ref inp)
                                 (env-ref idxs)))]
      [(vec-select id inp1 inp2 idxs)
       (env-set! id (vector-select
                     (env-ref inp1)
                     (env-ref inp2)
                     (env-ref idxs)))]
      [(vec-shuffle-set! out-vec inp idxs)
       (vector-shuffle-set!
        (env-ref out-vec)
        (env-ref inp)
        (env-ref idxs))]
      [(vec-app id f inps)
       (env-set! id (apply f (map env-ref inps)))]))

  memory)
