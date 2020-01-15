#lang rosette

; Synthesize values for sketch given a spec and symbolic arguments.
; ASSUMES Both the spec and the sketch take a memory with symbolic arguments
; laid out in the order of their appearance. Expects all symbolic arguments to
; be vectors.
; XXX(rachit): The stupidity in the description above makes me feel that
; interp should just take an env mapping.
; If a `cost-fn` is specified, run the synthesis procedure in a loop till it
; can find a solution as close to `min-cost` as possible.
(define (synth-prog spec
                    sketch
                    sym-args
                    #:cost-fn [cost-fn #f]
                    #:max-cost [max-cost #f]
                    #:min-cost [min-cost #f])

  (define (loop cur-cost)
    (synthesize #:forall sym-args
                #:
