#lang rosette

(require "dsp-insts.rkt"
         rosette/lib/match)

(provide (all-defined-out))

; XXX(rachit): Every instruction has an `id` which seems bad.
; A program is a sequence of instructions.
(struct prog (insts) #:transparent)

; Load and unload vectors from memory.
(struct vec-load (id start end) #:transparent)
(struct vec-unload (id start) #:transparent)

; Set constant vector in memory.
(struct vec-const (id init) #:transparent)

; Shuffle instructions inside memory.
(struct vec-shuffle (id inp idxs) #:transparent)
(struct vec-select (id inp1 inp2 idxs) #:transparent)
(struct vec-shuffle-set! (id inp idxs) #:transparent)

; Apply functions on vectors.
(struct vec-app (id f inps) #:transparent)

; Interpretation function that takes a program and an external memory.
(define (interp program memory)
  (define env (make-hash))
  (define (env-set! key val)
    (hash-set! env key val))
  (define (env-ref key)
    (hash-ref env key))

  (for ([inst (prog-insts program)])
    (match
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
      [(vec-shuffle-set! id inp idxs)
       (env-set! id (vector-shuffle-set!
                      (env-ref inp)
                      (env-ref idxs)))]
      [(vec-app f inps)
       (apply f (map env-ref inps))]))

  memory)
