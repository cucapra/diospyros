#lang rosette

(require "dsp-insts.rkt"
         "ast.rkt"
         "utils.rkt"
         "prog-sketch.rkt"
         racket/trace
         rosette/lib/match)

(provide (all-defined-out))

(define (pr v)
  (pretty-print v)
  v)

; Read a vector of `size` starting at location `start` from `memory`
(define (read-vec memory start size)
  (vector-copy memory start (+ start size)))

; Write a vector to `memory` to the location `start` and return the updated
; memory.
; MUTATES the argument `memory`.
(define (write-vec! memory start vec)
  (vector-copy! memory start vec))

; Align vectors by padding to a multiple of current-reg-size
(define (align vec)
  (define len (vector-length vec))
  (define align-len
    (* (current-reg-size) (exact-ceiling (/ len (current-reg-size)))))
  (let ([fill (make-vector (- align-len len) 0)])
    (vector-append vec fill)))

; Interpretation function that takes a program and an external memory.
; MUTATES the memory in place during program interpretation.
; Returns the cost of the program using `cost-fn`.
; `cost-fn` takes an instruction and the current environment and returns an
; integer value describing the cost of the instruction. It ASSUMES that the
; instruction does not contain any free variables.
; `fn-defns` is an optional argument to provide external function definitions
; When `symbolic?` is true, create symbolic vectors for extenally defined
; inputs.
(define (interp program
                init-env
                #:cost-fn [cost-fn (thunk* 0)]
                #:fn-map [fn-map (make-hash)]
                #:symbolic? [symbolic? #f])
  ; Setup the environment if it is an associative list.
  (define env
    (if ((listof pair?) init-env)
      (let ([new-env (make-hash)])
        (for ([bind init-env])
          (hash-set! new-env (car bind) (cdr bind)))
        new-env)
      init-env))

  ; The environment mapping for the program.
  (define (env-set! key val)
    (hash-set! env key (align val)))
  (define (env-ref key)
    (hash-ref env key))
  (define (env-has? key)
    (hash-has-key? env key))

  ; Track the cost of the program
  (define cur-cost 0)
  (define (incr-cost! val)
    (set! cur-cost (+ cur-cost val)))

  (for ([inst (prog-insts program)])
    ; Increase the cost based on the current env
    (incr-cost! (cost-fn inst env))

    ; Execute the program instruction
    (match inst

      [(vec-extern-decl id size)
       ; The identifier is not already bound, create a symbolic vector of the
       ; correct size and add it to the environment.
       (if (and symbolic? (not (env-has? id)))
         (env-set! id (align (make-vector size)))
         (begin
           (assert (env-has? id)
                   (~a "INTERP: missing extern vector: " id))
           (assert (= (vector-length (env-ref id)) size)
                   (~a "INTERP: size mistmatch: " id
                       ". Expected: " size
                       " Given: " (vector-length (env-ref id))))
           (env-set! id (align (env-ref id)))))]

      [(vec-const id init)
       (env-set! id init)]

      [(vec-shuffle id idxs inps)
       (let ([inp-vals (map env-ref inps)]
             [idxs-val (env-ref idxs)])
         (env-set! id (vector-shuffle inp-vals idxs-val)))]

      [(vec-shuffle-set! out-vec idxs inp)
       (let ([out-vec-val (env-ref out-vec)]
             [inp-val (env-ref inp)]
             [idxs-val (env-ref idxs)])
         (vector-shuffle-set! out-vec-val idxs-val inp-val))]

      [(vec-app id f inps)
       (let ([inps-val (map env-ref inps)]
             [fn (hash-ref fn-map f)])
         (env-set! id (apply fn inps-val)))]

      [(vec-void-app f inps)
       (let ([inps-val (map env-ref inps)]
             [fn (hash-ref fn-map f)])
         (apply fn inps-val))]

      [(vec-load dest-id src-id start end)
       (let ([dest (make-vector (current-reg-size) 0)]
             [src (env-ref src-id)])
         (vector-copy! dest 0 src start end)
         (env-set! dest-id dest))]

      [(vec-store dest-id src-id start end)
       (let ([dest (env-ref dest-id)]
             [src (env-ref src-id)])
         (vector-copy! dest start src 0 (- end start)))]

      [(vec-write dst-id src-id)
       (let ([dest (env-ref dst-id)]
             [src (env-ref src-id)])
         (vector-copy! dest 0 src))]

      [_ (assert #f (~a "unknown instruction " inst))]))

  (values env cur-cost))


; Cost of a program is the sum of the registers touched by each indices vector
; passed to a shuffle-like instruction.
(define (make-register-cost reg-upper-bound)
  (lambda (inst env)
    (match inst
      [(or (vec-shuffle _ idxs _)
           (vec-shuffle-set! _ idxs _))
       (reg-used (hash-ref env idxs)
                 (current-reg-size)
                 reg-upper-bound)]
      [_ 0])))

; Cost of program is the number of unique shuffle idxs used.
; Uses `shuf-name-eq?` on the name of the shuffle to separate them into
; different equivalence classes.
(define (make-shuffle-unique-cost [shuf-name-class (thunk* 0)])
  ; Store the various equivalence classes separately
  (define idxs-def-class (make-vector 10 (list)))

  (lambda (inst env)
    (match inst
      [(or (vec-shuffle _ idxs _)
           (vec-shuffle-set! _ idxs _))
       ; If this is equal to any idxs previously defined for its equivalence
       ; class, it costs nothing.
       (let* ([conc-idxs (hash-ref env idxs)]
              [equiv-class (shuf-name-class idxs)]
              [idxs-def (vector-ref idxs-def-class equiv-class)])
         (begin0
           (if (ormap (lambda (el) (equal? el conc-idxs)) idxs-def) 0 1)
           ; Add to equivalence class
           (vector-set! idxs-def-class
                        equiv-class
                        (cons conc-idxs idxs-def))))]
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
          ('shuf = vec-shuffle 'idxs (list 'const)))
        (interp p env)
        (check-equal? (hash-ref env 'shuf) gold))

      (test-case
       "check external declared vector defined"
       (define env (make-hash))
       (hash-set! env `x (make-vector 2 0))
       (define gold (vector 0 0 0 0))
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
          ('s1 = vec-shuffle 'i1 (list 'a))
          ('s2 = vec-shuffle 'i2 (list 'a))
          ('s2 = vec-shuffle 'i3 (list 'a 'b)))
        (define-values (_ cost)
          (interp p
                  (make-hash)
                  #:cost-fn (make-register-cost 3)))
        (check-equal? cost 5)
        ; cost depends on the current-reg-size
        (define-values (__ cost-2)
          (interp p
                  (make-hash)
                  #:cost-fn (make-register-cost 5)))
        (parameterize ([current-reg-size 2])
          (check-equal? cost-2 5)))

      (test-case
        "shuffle-unique-cost does not increase cost for repeated idxs"
        (define/prog p
          ('a = vec-const (vector 0 1 2 3 4 5 6 7))
          ('b = vec-const (vector 8 9 10 11 12 13 14 15))
          ('i1 = vec-const (vector 1 2 3 0))
          ('i2 = vec-const (vector 0 3 2 1))
          ('i3 = vec-const (vector 0 1 8 9))
          ('s1 = vec-shuffle 'i1 (list 'a))
          ('s2 = vec-shuffle 'i1 (list 'a))
          ('s2 = vec-shuffle 'i3 (list 'a 'b)))
        (define-values (_ cost)
          (interp p
                  (make-hash)
                  #:cost-fn (make-shuffle-unique-cost)))
        (check-equal? cost 2))

      (test-case
        "shuffle-unique-cost calculates different cost for unique idxs"
        (define/prog p
          ('a = vec-const (vector 0 1 2 3 4 5 6 7))
          ('b = vec-const (vector 8 9 10 11 12 13 14 15))
          ('i1 = vec-const (vector 1 2 3 0))
          ('i2 = vec-const (vector 0 3 2 1))
          ('i3 = vec-const (vector 0 1 8 9))
          ('s1 = vec-shuffle 'i1 (list 'a))
          ('s2 = vec-shuffle 'i2 (list 'a))    ; different from previous test
          ('s2 = vec-shuffle 'i3 (list 'a 'b)))
        (define-values (_ cost)
          (interp p
                  (make-hash)
                  #:cost-fn (make-shuffle-unique-cost)))
        (check-equal? cost 3))
      )))
