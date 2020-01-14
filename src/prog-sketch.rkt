#lang rosette

(require "ast.rkt"
         "matrix-utils.rkt")

(define (make-symbolic-vector size)
  (for/vector ([_ (in-range size)])
    (define-symbolic* v integer?)
    v))

(define (make-symbolic-indices-restriced size reg-limit reg-upper-bound)
  (define vec (make-symbolic-vector size))
  (assert (<= (reg-used vec size) reg-limit))
  vec)

(define (make-symbolic-matrix rows cols)
  (matrix rows cols (make-symbolic-vector (* rows cols))))

;;=================== SKETCH DEFINITIONS =========================

; Generate a sketch that interleaves computation and shuffling `iterations`
; times.
; `shuffle-thunk` takes one argument, the current iteration, and returns a list
; of program insts and names of shuffle vectors defined.
; `compute-thunk` takes two arguments, the current iteration and the names of the
; shuffle vectors for this iteration, and returs a list of program insts.
(define (sketch-compute-shuffle-interleave shuffle-thunk
                                           compute-thunk
                                           number)
  (define instructions
    (for/list ([i (in-range number)])
      (define-values (shuffle-defs shuffle-names)
        (shuffle-thunk i))
      (define compute
        (compute-thunk i shuffle-names))
      (append shuffle-defs compute)))

  (prog instructions))

; Returns a function that generates `shuf-num` shuffle vectors of size
; `reg-size` to be used for a program sketch.
(define (symbolic-shuffle-gen shuf-num reg-size)
  (lambda (iteration)
    (define shuf-names
      (for/list ([n (in-range shuf-num)])
        (string->symbol
          (string-append "shuf"
                         (number->string n)
                         "-"
                         (number->string iteration)))))
    (define insts
      (map (lambda (shuf-name)
             (vec-const shuf-name (make-symbolic-vector reg-size)))
           shuf-names))
    (values insts shuf-names)))


; TODO(rachit): Define a sketch where the compute can use previously defined
; shuffle vectors. The sketch should take a parameter `n` that specifies the
; "history" of shuffle vectors the compute at iteration `i` can use.
; For example, for n = 3, computation at `i` can choose to use shuffle
; vectors from `i-2`, `i-1`, and `i`. This choice allows the sketch to
; discover reuse of shuffle vectors while also giving us a parameter to
; tune the complexity of the synthesis formulation.
;
; Note that this "history" based mechanism doesn't disallow global reuse
; patterns as long as the compute kernels can commute. To reuse a shuffle
; vector that is further away, the synthesizer can simply reorder the
; computation.
