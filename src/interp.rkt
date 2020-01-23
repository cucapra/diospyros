#lang rosette

(require "dsp-insts.rkt"
         "ast.rkt"
         "matrix-utils.rkt"
         "prog-sketch.rkt"
         rosette/lib/match)

(provide (all-defined-out))

; Read a vector of `size` starting at location `start` from `memory`
(define (read-vec memory start size)
  (vector-copy memory start (+ start size)))

; Write a vector to `memory` to the location `start` and return the updated
; memory.
; MUTATES the argument `memory`.
(define (write-vec! memory start vec)
  (vector-copy! memory start vec))

(define (default-fn-defns f)
  (error "attempt to apply undefined function ~a" f))

; Interpretation function that takes a program and an external memory.
; MUTATES the memory in place during program interpretation.
; Returns the cost of the program using `cost-fn`.
; `cost-fn` takes an instruction returns an integer value describing the cost
; of the instruction. It ASSUMES that the instruction does not contain any free
; variables.
; `fn-defns` is an optional argument to provide external function definitions
(define (interp program
                env
                #:cost-fn [cost-fn (thunk* 0)]
                #:fn-map [fn-map default-fn-defns])
  ; The environment mapping for the program.
  (define (env-set! key val)
    (hash-set! env key val))
  (define (env-ref key)
    (hash-ref env key))
  (define (env-has? key)
    (hash-has-key? env key))

  ; Track the cost of the program
  (define cur-cost 0)
  (define (incr-cost! val)
    (set! cur-cost (+ cur-cost val)))

  (for ([inst (prog-insts program)])
    (define inst-cost
      (match inst
        [(vec-extern-decl id size)
         (unless (env-has? id)
           (error "Declared extern vector ~a undefined" id))
         (let ([def-len (vector-length (env-ref id))])
           (unless (= def-len size)
             (error "Mismatch vector size, expected ~a got ~a" size def-len)))
         (cost-fn inst)]
        [(vec-const id init)
         (env-set! id init)
         (cost-fn inst)]
        [(vec-shuffle id idxs inp)
         (let ([inp-val (env-ref inp)]
               [idxs-val (env-ref idxs)])
           (env-set! id (vector-shuffle inp-val idxs-val))
           ; Pass a deferenced version of vec-shuffle to cost-fn
           (cost-fn (vec-shuffle id idxs-val inp-val)))]
        [(vec-select id idxs inp1 inp2)
         (let ([inp1-val (env-ref inp1)]
               [inp2-val (env-ref inp2)]
               [idxs-val (env-ref idxs)])
           (env-set! id (vector-select inp1-val inp2-val idxs-val))
           (cost-fn (vec-select id idxs-val inp1-val inp2-val)))]
        [(vec-shuffle-set! out-vec idxs inp)
         (let ([out-vec-val (env-ref out-vec)]
               [inp-val (env-ref inp)]
               [idxs-val (env-ref idxs)])
           (vector-shuffle-set! out-vec-val idxs-val inp-val)
           (cost-fn (vec-shuffle-set! out-vec-val idxs-val inp-val)))]
        [(vec-app id f inps)
         (let ([inps-val (map env-ref inps)]
               [fn (hash-ref fn-map f)])
           (env-set! id (apply fn inps-val))
           (cost-fn (vec-app id f inps-val)))]
        [_ (assert #f (~a "unknown instruction " inst))]))

    (incr-cost! inst-cost))

  cur-cost)


; Cost of a program is the sum of the registers touched by each indices vector
; passed to a shuffle-like instruction.
(define (make-register-cost reg-upper-bound)
  (lambda (inst)
    (match inst
      [(or (vec-shuffle _ idxs _)
           (vec-select _ idxs _ _)
           (vec-shuffle-set! _ idxs _))
       (reg-used idxs (current-reg-size) reg-upper-bound)]
      [_ 0])))

; Cost of program is the number of unique shuffle idxs used.
(define (make-shuffle-unique-cost)
  (define idxs-def (list))
  (lambda (inst)
    (match inst
      [(or (vec-shuffle _ idxs _)
           (vec-select _ idxs _ _)
           (vec-shuffle-set! _ idxs _))
       ; begin0 evaluate the whole body and returns the value from the first
       ; expression.
       (begin0
         (if (ormap (lambda (el) (equal? el idxs)) idxs-def) 0 1)
         ; Add this idxs to the currently defined idxs
         (set! idxs-def (cons idxs idxs-def)))]
      [_ 0])))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "interp tests"
      (test-case
        "Write out constant vector"
        (define env (make-hash))
        (define gold
          (vector 1 2 3 4))
        (define/prog p
          ('x = vec-const gold))
        (interp p env)
        (check-equal? (hash-ref env 'x) gold))

      (test-case
        "create shuffled vector"
        (define env (make-hash))
        (define gold (vector 3 1 2 0))
        (define/prog p
          ('const = vec-const (vector 0 1 2 3))
          ('idxs = vec-const (vector 3 1 2 0))
          ('shuf = vec-shuffle 'idxs 'const))
        (interp p env)
        (check-equal? (hash-ref env 'shuf) gold))

      (test-case
       "check external declared vector defined"
       (define env (make-hash))
       (hash-set! env `x (make-vector 2 0))
       (define gold (vector 0 0))
       (define p (prog (list (vec-extern-decl `x 2))))
       (interp p env)
       (check-equal? (hash-ref env `x) gold))

      (test-case
       "check external declared vector undefined"
       (define env (make-hash))
       (define p (prog (list (vec-extern-decl `x 2))))
       (check-exn exn:fail? (thunk (interp p env))))

      (test-case
       "check external declared vector wrong size"
       (define env (make-hash))
       (hash-set! env `x (make-vector 1 0))
       (define p (prog (list (vec-extern-decl `x 2))))
       (check-exn exn:fail? (thunk (interp p env))))

      (test-case
        "make-register-cost calculates cost correctly"
        (define/prog p
          ('a = vec-const (vector 0 1 2 3 4 5 6 7))
          ('b = vec-const (vector 8 9 10 11 12 13 14 15))
          ('i1 = vec-const (vector 1 4 7 5))
          ('i2 = vec-const (vector 0 3 2 1))
          ('i3 = vec-const (vector 0 1 8 9))
          ('s1 = vec-shuffle 'i1 'a)
          ('s2 = vec-shuffle 'i2 'a)
          ('s2 = vec-select 'i3 'a 'b))
        (check-equal?
          (interp p
                  (make-hash)
                  #:cost-fn (make-register-cost 3)) 5)
        ; cost depends on the current-reg-size
        (parameterize ([current-reg-size 2])
          (check-equal?
            (interp p
                    (make-hash)
                    #:cost-fn (make-register-cost 5)) 7)))

      (test-case
        "shuffle-unique-cost does not increase cost for repeated idxs"
        (define/prog p
          ('a = vec-const (vector 0 1 2 3 4 5 6 7))
          ('b = vec-const (vector 8 9 10 11 12 13 14 15))
          ('i1 = vec-const (vector 1 2 3 0))
          ('i2 = vec-const (vector 0 3 2 1))
          ('i3 = vec-const (vector 0 1 8 9))
          ('s1 = vec-shuffle 'i1 'a)
          ('s2 = vec-shuffle 'i1 'a)
          ('s2 = vec-select 'i3 'a 'b))
        (check-equal?
          (interp p
                  (make-hash)
                  #:cost-fn (make-shuffle-unique-cost)) 6))

      (test-case
        "shuffle-unique-cost calculates different cost for unique idxs"
        (define/prog p
          ('a = vec-const (vector 0 1 2 3 4 5 6 7))
          ('b = vec-const (vector 8 9 10 11 12 13 14 15))
          ('i1 = vec-const (vector 1 2 3 0))
          ('i2 = vec-const (vector 0 3 2 1))
          ('i3 = vec-const (vector 0 1 8 9))
          ('s1 = vec-shuffle 'i1 'a)
          ('s2 = vec-shuffle 'i2 'a)    ; different from previous test
          ('s2 = vec-select 'i3 'a 'b))
        (check-equal?
          (interp p
                  (make-hash)
                  #:cost-fn (make-shuffle-unique-cost)) 7))
      )))
