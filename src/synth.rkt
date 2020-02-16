#lang rosette

(require racket/generator)

(provide (all-defined-out))

; Verify input-output behavior of programs.
(define (verify-prog spec
                     sketch
                     sym-args
                     #:get-inps get-inps)

  (define spec-out (spec sym-args))
  (define sketch-out (sketch sym-args))

  ; Sanity checks
  (assert (vector? spec-out) "VERIFY-PROG: spec output is not a vector")
  (assert (vector? sketch-out) "VERIFY-PROG: sketch output is not a vector")
  (assert (equal? (vector-length spec-out)
                  (vector-length sketch-out))
          (format
            "VERIFY-PROG: lengths of sketch and spec outputs don't match. Spec: ~a. Sketch: ~a"
            (vector-length spec-out)
            (vector-length sketch-out)))

  (define sol
    (verify
      (assert (equal? (spec sym-args) (sketch sym-args)))))

  (if (unsat? sol)
    (pretty-print "Verification Succeeded.")
    (let ([conc-args (evaluate sym-args sol)])
    (display (~a "Verification Failed.\nSpec output:\n"
                      (pretty-format (spec conc-args))
                      "\nSketch output:\n"
                      (pretty-format (sketch conc-args))
                      "\nArguments: "
                      (pretty-format conc-args))))))

; Synthesize values for sketch given a spec and symbolic arguments.
; If a `cost-fn` is specified, run the synthesis procedure in a loop till it
; can find a solution as close to `min-cost` as possible.
(define (synth-prog spec
                    sketch
                    sym-args
                    #:get-inps get-inps
                    #:max-cost max-cost
                    #:min-cost [min-cost 0])

  (generator ()
    (let loop ([cur-cost max-cost]
               [cur-model (unsat)])
      (pretty-print `(current-cost: ,cur-cost))
      (define spec-out (spec sym-args))
      (define-values (sketch-out cost) (sketch sym-args ))

      (assert (vector? spec-out) "SYNTH-PROG: spec output is not a vector")
      (assert (vector? sketch-out) "SYNTH-PROG: sketch output is not a vector")
      (assert (equal? (vector-length spec-out)
                      (vector-length sketch-out))
              (format
                "SYNTH-PROG: lengths of sketch and spec outputs don't match. Spec: ~a. Sketch: ~a"
                (vector-length spec-out)
                (vector-length sketch-out)))

      (define-symbolic* c integer?)
      (assert (equal? c cost))

      (define-values (synth-res cpu-time real-time gc-time)
        (time-apply
          (thunk
            (synthesize #:forall (get-inps sym-args)
                        #:guarantee (begin
                                      (assert (equal? spec-out sketch-out))
                                      (assert (<= cost cur-cost)))))
          (list)))

      (pretty-print (~a "cpu time: "
                        (/ cpu-time 1000.0)
                        "s, real time: "
                        (/ real-time 1000.0)
                        "s"))

      (define model (first synth-res))

      (define new-cost
        (if (sat? model)
          (let ([cost (evaluate c model)])
            ; If a satisfying model was found, yield it back.
            (yield model cost)
            cost)
          cur-cost))

      (cond
        [(not (sat? model)) (pretty-print `(final-cost: ,new-cost))]
        [(<= new-cost min-cost) (pretty-print `(final-cost: ,new-cost))]
        [else (loop (sub1 new-cost) model)]))))

(define (sol-producer model-generator)
  (define (is-done? model cost)
    (equal? (void) model))
  (in-producer model-generator is-done?))
