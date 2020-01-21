#lang rosette

(provide (all-defined-out))

; Synthesize values for sketch given a spec and symbolic arguments.
; If a `cost-fn` is specified, run the synthesis procedure in a loop till it
; can find a solution as close to `min-cost` as possible.
(define (synth-prog spec
                    sketch
                    sym-args
                    #:get-inps get-inps
                    #:max-cost [max-cost #f]
                    #:min-cost [min-cost #f])

  (define (loop cur-cost [cur-model (unsat)])
    (pretty-print `(current-cost: ,cur-cost))
    (define spec-out (spec sym-args))
    (define-values (sketch-out cost) (sketch sym-args ))

    (define-symbolic* c integer?)
    (assert (equal? c cost))

    (define model
      (synthesize #:forall (get-inps sym-args)
                  #:guarantee (begin
                                (assert (equal? spec-out sketch-out))
                                (assert (<= cost cur-cost)))))
    (define new-cost
      (if (sat? model)
        (evaluate c model)
        cur-cost))

    (cond
      [(not (sat? model)) cur-model]
      [(equal? new-cost min-cost) model]
      [else (loop (sub1 new-cost) model)]))

  (loop max-cost))
