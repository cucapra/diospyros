#lang rosette

(require (only-in rosette/solver/solver solver-constructor)
         (only-in rosette/base/core/term solvable-default)
         (prefix-in $ racket)
         rackunit)

(provide synth)

(define (eval/asserts closure)
  (with-handlers ([exn:fail? (const '(#f))])
    (with-asserts-only (closure))))

; synth takes as input:
; * a list of quantified variables `qv`
; * an optional list of assumptions `pre`
; * a list of post-conditions `phi`
; and solves the synthesis query:
;   ∃ {symbolics(post) - qv}. ∀ qv. pre => post
; and returns two values:
; * the solution to the query
; * a thunk P(a) that can be called to repeat the synthesis query with new assertions `a`.
;   the assertion `a` must not mention the quantified variables `qv`.
;   calls to P(a) return a new solution to the synthesis query that also satisfies
;   all previous additional assertions passed to P
; once the thunk P returns unsat, it should not be called again.
; if the thunk P never returns unsat, it should be called one final time
;   with `a` = #f to clean up the solvers it spawned.
;
; NOTE: synth does not work with `assert` -- the assumptions and post-conditions
;       should be boolean terms
;       e.g. (synthesize #:forall a #:guarantee (assert b))
;            should be rewritten
;            (synth #:forall a #:guarantee b)
(define-syntax synth
  (syntax-rules (synth)
    [(_ #:forall inputs #:assume pre #:guarantee post rest ...)
     (synth-solve (symbolics inputs)
                  (eval/asserts (thunk pre))
                  (eval/asserts (thunk post))
                  rest ...)]
    [(_ #:forall inputs #:guarantee post rest ...)
     (synth #:forall inputs #:assume #t #:guarantee post rest ...)]
    [(_ inputs post rest ...)
     (synth #:forall inputs #:guarantee post rest ...)]))

(define (synth-solve xs pre post)
  (define solver-type (solver-constructor (current-solver)))

  ; remove any terms that appear in both pre and post
  (define post-except-pre (for/list ([p (in-list post)] #:unless ($memq p pre)) p))
  (define p (append pre post-except-pre))
  (define !p (append pre (list (apply || (map ! post-except-pre)))))

  (define cust (make-custodian))
  (parameterize ([current-custodian cust])
    (define guesser (solver-type))
    (define checker (solver-type))

    (define (solution/no-inputs s)
      (match s
        [(model m) (sat (for/hash ([(c v) (in-hash m)] #:unless ($member c xs)) (values c v)))]
        [other other]))
    (define (solution/only-inputs s)
      (match s
        [(? sat?) (sat (for/hash ([i (in-list xs)])
                         (values i (let ([v (s i)])
                                     ($if ($eq? v i)
                                          (solvable-default (term-type i))
                                          v)))))]
        [other other]))

    (define (guess)
      (solution/no-inputs (solver-check guesser)))

    (define (check sol)
      (solver-clear checker)
      (solver-assert checker (evaluate !p sol))
      (solution/only-inputs (solver-check checker)))

    (define (ret post+ [first? #f])
      ; guess the first candidate (since we have no concrete inputs)
      (solver-assert guesser (if (list? post+) post+ (list post+)))
      (define candidate (guess))

      (when first?
        (solver-clear guesser))

      ; now run the cegis loop
      (let loop ([candidate candidate])
        (cond
          [(unsat? candidate)
           (custodian-shutdown-all cust)
           candidate]
          [else
           (let ([cex (check candidate)])
             (cond
               [(unsat? cex)
                candidate]
               [else
                (solver-assert guesser (evaluate p cex))
                (loop (guess))]))])))

    (values (ret p #t) (curryr ret #f))))


; actual tests
(module+ test
  (define-symbolic a b c boolean?)
  (define-symbolic xi yi zi integer?)
  (define-symbolic xb yb zb (bitvector 4))

  ; --- basic synthesis tests ---

  (define (synth-only #:forall xs #:assume [as #t] #:guarantee ys)
    (define-values (sol next) (synth #:forall xs #:assume (assert as) #:guarantee (assert ys)))
    (begin0
      sol
      (next #f))) ; to clean up the solvers

  (check-true (unsat? (synth-only #:forall '() #:guarantee #f)))

  (check-equal?
   (model (synth-only #:forall a #:assume a #:guarantee (&& a b)))
   (hash b #t))

  (check-true (unsat? (synth-only #:forall xb #:guarantee (bvslt xb (bvadd xb yb)))))

  (check-true
   (evaluate (> yi 0) (synth-only #:forall xi #:guarantee (< xi (+ xi yi)))))

  (check-true
   (evaluate (>= yi 0) (synth-only #:forall xi #:assume (> xi 0) #:guarantee (>= xi yi))))

  ; --- incremental synthesis tests ---

  (let ()
    ; only one integer c satisfies x+1 = x+c
    (define-values (sol next) (synth #:forall xi #:guarantee (assert (= (+ xi 1) (+ xi yi)))))
    (check-true (sat? sol))
    (define sol2 (next (! (= yi 1))))
    (check-true (unsat? sol2)))

  (let ()
    ; any 4-bit BV ending in 11 is a valid solution
    ; => 4 possible solutions; we can enumerate them
    (define-values (sol next) (synth #:forall xb #:guarantee (assert (bveq (bvand xb (bv 3 4))
                                                                           (bvand xb (bvand yb (bv 3 4)))))))
    (check-true (sat? sol))
    (define sol2 (next (! (bveq yb (sol yb)))))
    (check-true (sat? sol))
    (define sol3 (next (! (bveq yb (sol2 yb)))))
    (check-true (sat? sol))
    (define sol4 (next (! (bveq yb (sol3 yb)))))
    (check-true (sat? sol))
    (define sol5 (next (! (bveq yb (sol4 yb)))))
    (check-true (unsat? sol5))))


; examples
(module+ test
  ; --- a simple little interpreter ---
  (require rosette/lib/match rosette/lib/angelic)

  (struct add (a b) #:transparent)
  (struct mul (a b) #:transparent)

  (define (interpret prog inputs)
    (define state (make-vector (+ (length prog) (length inputs)) (bv 0 4)))
    (for ([(v i) (in-indexed inputs)])
      (vector-set! state i v))
    (for ([(insn i) (in-indexed prog)])
      (define idx (+ (length inputs) i))
      (match insn
        [(add a b)
         (vector-set! state idx (bvadd (vector-ref state a) (vector-ref state b)))]
        [(mul a b)
         (vector-set! state idx (bvmul (vector-ref state a) (vector-ref state b)))]))
    (vector-ref state (- (vector-length state) 1)))

  (define (??reg) (apply choose* (range 3)))
  (define (??insn) (choose* (add (??reg) (??reg))
                            (mul (??reg) (??reg))))


  ; --- interpreter sanity checks ---
  (check-true (bveq (interpret (list (add 0 0)) (list (bv 1 4)))
                    (bv 2 4)))
  (check-true (bveq (interpret (list (mul 0 1)) (list (bv 2 4) (bv 3 4)))
                    (bv 6 4)))

  (define-symbolic x y (bitvector 4))


  ; --- verify: a + a = a * 2 ---
  (check-true (unsat? (verify (assert (bveq (interpret (list (add 0 0)) (list x))
                                            (interpret (list (mul 0 1)) (list x (bv 2 4))))))))


  ; --- synthesize: a + a = a * 2 ---
  (let ()
    (define sketch (??insn))
    (define-values (sol next)
      (synth #:forall x #:guarantee (assert (bveq (interpret (list (add 0 0)) (list x))
                                                  (interpret (list sketch) (list x (bv 2 4)))))))
    (check-true (sat? sol))
    ; force it to be an add
    (define sol2 (next (add? sketch)))
    (check-true (sat? sol2))
    ; force it not to add to itself
    (define sol3 (next (! (equal? (add-a sketch) (add-b sketch)))))
    (check-true (unsat? sol3)))


  ; --- synthesize optimally: a + a = a * 2 ---
  (let ()
    (define sketch (??insn))
    (define (cost prog) ; adds cost 2, muls cost 1
      (apply bvadd (for/list ([insn prog]) (if (add? insn) (bv 2 4) (bv 1 4)))))
    (define sketch-cost (cost (list sketch)))

    (define-values (sol next)
      (synth #:forall x #:guarantee (assert (bveq (interpret (list (add 0 0)) (list x))
                                                  (interpret (list sketch) (list x (bv 2 4)))))))
    (check-true (sat? sol))

    ; loop to find the lowest-cost solution
    (define optimal
      (let loop ([sol sol])
        (define c (cost (evaluate (list sketch) sol)))
        (define sol2 (next (bvult sketch-cost c)))
        (cond
          [(unsat? sol2) sol]
          [else (loop sol2)])))

    ; according to our cost function, it must be a*2 or 2*a
    (check-true (or (equal? (evaluate sketch optimal) (mul 0 1))
                    (equal? (evaluate sketch optimal) (mul 1 0)))))


  ; --- find all solutions for ??insn = a + a ---
  (let ()
    (define sketch (??insn))

    ; find the first solution (if it exists)
    (define-values (sol next)
      (synth #:forall x #:guarantee (assert (bveq (interpret (list (add 0 0)) (list x))
                                                  (interpret (list sketch) (list x (bv 2 4)))))))

    ; loop to find all solutions
    (define num-solutions
      (let loop ([count 0][sol sol])
        (match sol
          [(model m) ; sat
           ; rule out this solution by asserting at least one var must be different
           (define !sol (apply || (for/list ([(var val) (in-hash m)]) (! (equal? var val)))))
           (loop (+ count 1) (next !sol))]
          [_ ; unsat
           count])))

    ; we expect 3 solutions since we have no symmetry breaking:
    ;   a + a
    ;   a * 2
    ;   2 * a
    (check-equal? num-solutions 3))
  )
