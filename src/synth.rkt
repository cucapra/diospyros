#lang rosette

(require racket/generator
         threading
         "ast.rkt"
         "prog-sketch.rkt"
         "configuration.rkt"
         "engine.rkt"
         "interp.rkt"
         "compile-passes.rkt"
         "utils.rkt")

(provide (all-defined-out))

; Generate string for keys that have different values.
(define (show-diff env1 env2 keys)
  (string-join
    (for/list ([key keys])
      (if (equal? (hash-ref env1 key)
                  (hash-ref env2 key))
        ""
        (~a key " differs: "
            (hash-ref env1 key)
            " "
            (hash-ref env2 key))))
    "\n"))

; Verify input-output behavior of programs.
(define (verify-prog spec
                     sketch
                     #:fn-map [fn-map (make-hash)])

  (define-values (spec-ins spec-outs)
    (get-inputs-and-outputs spec))

  (define-values (sketch-ins sketch-outs)
    (get-inputs-and-outputs sketch))

  ; Transform a list of vec-extern-decl to a set with (id size).
  (define (to-size-set lst)
    (define (get-id-size decl)
      (cons (vec-extern-decl-id decl)
            (vec-extern-decl-size decl)))
    (list->set (map get-id-size lst)))

  ; Check spec and sketch have the same set of inputs and outputs.
  (let ([ins-diff (set-symmetric-difference
                    (to-size-set spec-ins)
                    (to-size-set sketch-ins))]
        [outs-diff (set-symmetric-difference
                     (set-map (to-size-set spec-outs) car)
                     (set-map (to-size-set sketch-outs) car))])

    (assert (set-empty? ins-diff)
            (~a "VERIFY-PROG: Input mismatch. " ins-diff))
    (assert (set-empty? outs-diff)
            (~a "VERIFY-PROG: Output mismatch. " outs-diff)))

  ; Generate symbolic inputs for spec and sketch.
  (define init-env
    (append
      (~> spec-ins
          to-size-set
          set->list
          (map (lambda (decl)
                 (cons (car decl)
                       (make-symbolic-bv-list-values (cdr decl))))
               _))
      (~> spec-outs
          to-size-set
          set->list
          (map (lambda (decl)
                 (cons (car decl)
                       (make-vector (cdr decl) 0)))
               _))))

  (define (interp-and-env prog init-env)
    (define-values (env _)
      (interp prog
              init-env
              #:fn-map fn-map))
    env)

  (define spec-env (interp-and-env spec init-env))
  (define sketch-env (interp-and-env sketch init-env))

  ; Outputs from sketch are allowed to be bigger than the spec. Only consider
  ; elements upto the size in the spec for each output.
  (define assertions
    (andmap (lambda (decl)
              (let ([id (car decl)]
                    [size (cdr decl)])
                (equal? (vector-take (hash-ref spec-env id) size)
                        (vector-take (hash-ref sketch-env id) size))))
            (set->list (to-size-set spec-outs))))


  (define model
    (verify
      ; Since get-outs extracts outputs in the same order for both, we can
      ; just check for list equality.
      (assert assertions)))

  (when (not (unsat? model))
    (pretty-display (~a "Verification unsuccessful. Environment differences:\n"
                      (show-diff
                        (interp-and-env spec (evaluate init-env model))
                        (interp-and-env sketch (evaluate init-env model))
                        (map vec-extern-decl-id spec-outs)))))

  model)


; Synthesize values for sketch given a spec and symbolic arguments.
; If a `cost-fn` is specified, run the synthesis procedure in a loop till it
; can find a solution as close to `min-cost` as possible.
(define (synth-prog spec
                    sketch
                    sym-args
                    #:get-inps get-inps
                    #:max-cost [max-cost #f]
                    #:min-cost [min-cost 0])

  ; synth-prog needs to explicitly manage all created assertions to correctly
  ; function with the incremental solving engine. Make sure the assertion
  ; store is empty.
  (when (not (empty? (asserts)))
    (error 'synth-prog "Called with a non-empty assertion store: ~a"
           (pretty-format (asserts))))

  ; Get the values and generated assertions from running the spec and
  ; sketch on symbolic inputs.
  (define-values (spec-out spec-asserts)
    (with-asserts (spec sym-args)))
  (define-values (sketch-res sketch-asserts)
    (with-asserts (sketch sym-args)))
  (match-define (list sketch-out cost) sketch-res)


  ; NOTE(rachit): Unfortunately there doesn't seem to be a `boxof` contract
  ; that would let us check (listof (boxof bv?)) so we just check if it is
  ; list of boxes.
  (assert ((listof box?) spec-out) "SYNTH-PROG: spec output is not a list")
  (assert ((listof box?) sketch-out) "SYNTH-PROG: sketch output is not a list")
  (assert (equal? (length spec-out)
                  (length sketch-out))
          (format
            "SYNTH-PROG: lengths of sketch and spec outputs don't match. Spec: ~a. Sketch: ~a"
            (vector-length spec-out)
            (vector-length sketch-out)))

  ; Use this named variable to get back the cost from the model.
  (define-symbolic* c (bitvector (cost-fin)))

  (generator ()
     (let loop ([cur-cost #f]
                [cur-model (unsat)]
                [cur-solver #f])

      (if (equal? cur-cost #f)
        (pretty-display
          "Skipping cost constraint for the first synthesis query")
        (pretty-print `(current-cost: ,(bitvector->integer cur-cost))))

      ; synth requires all assertions to be inside the #:guarantee clause.
      ; Fail synthesis when assertion store is not empty.
      (when (not (empty? (asserts)))
        (error 'synth-prog "Called with a non-empty assertion store: ~a"
               (pretty-format (asserts))))

      ; Run the solver. Returns the new model and a new solver object.
      ; NOTE(rachit): `next` is NOT a new solver. It is the old solver that
      ; generated the current model. Reusing the solver allows us to
      ; implement incremental solving.
      (define-values (model next)
        (if (not cur-solver)
          (synth #:forall (get-inps sym-args)
                 #:guarantee (begin
                               (assert (equal? spec-out sketch-out))
                               (assert (equal? c cost))
                               (for ([to-assert (append sketch-asserts
                                                        spec-asserts)])
                                 (assert to-assert))))
          (values (cur-solver (bvsle cost cur-cost)) cur-solver)))

      ; If the model is unsat on the first query, there are no solutions for
      ; the current parameters
      (when (and (not (sat? model))
                 (equal? cur-cost max-cost))
        (error "Initial query unsat. No satisfying model found"))

      (define new-cost
        (cond
          [(sat? model)
           (let ([cost (evaluate c model)])
             ; If a satisfying model was found, yield it back.
             (yield model cost)
             cost)]
          [(equal? cur-cost #f) max-cost]
          [else cur-cost]))

      (cond
        [(or (not (sat? model)) (bvsle new-cost min-cost))
         (pretty-print `(final-cost: ,(bitvector->integer new-cost)))
         (values (void) new-cost)]
        [else (loop (bvsub new-cost (bv-cost 1))
                    model
                    next)]))))

; Convinience function to turn a generator into a producer that can be
; iterated over.
(define (sol-producer model-generator)
  (define (is-done? model cost)
    (void? model))
  (in-producer model-generator is-done?))
