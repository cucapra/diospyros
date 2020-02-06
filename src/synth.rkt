#lang rosette

(require racket/generator)

(provide (all-defined-out))

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

      (pretty-print spec-out)
      ;(pretty-print sketch-out)

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

      (pretty-print (~a "cpu time: " (/ cpu-time 1000.0) "s, real time: " (/ real-time 1000.0) "s"))

      (define model (first synth-res))
      ;(pretty-print model)

      (define new-cost
        (if (sat? model)
          (begin
            ; If a satisfying model was found, yield it back.
            (yield model)
            (evaluate c model))
          cur-cost))

      (cond
        [(not (sat? model)) (pretty-print `(final-cost: ,new-cost))]
        [(<= new-cost min-cost) (pretty-print `(final-cost: ,new-cost))]
        [else (loop (sub1 new-cost) model)]))))
