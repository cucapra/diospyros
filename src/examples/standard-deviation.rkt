#lang rosette

(require "../ast.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../utils.rkt"
         "../prog-sketch.rkt"
         "../synth.rkt"
         "../configuration.rkt"
         racket/trace
         racket/generator
         rosette/lib/angelic)

(provide standard-deviation:keys
         standard-deviation:run-experiment)

;; Generate a spec for standard deviation between two lists of bitvectors.
(define (standard-deviation-spec V A H)
  (assert (= (length A) (length H)))
    (define C
            (make-bv-list-zeros 4))
  vector-standard-deviation V A H
  C)

(define (print v)
  (pretty-print v) v)

;Generate program skecth for standard deviation
(define (standard-deviation-shuffle-sketch V A H iterations)
  ;Porgram preamble to define the inputs
  (define preamble
    (list
     (vec-extern-decl 'A (length V) input-tag)
     (vec-extern-decl 'B (length A) input-tag)
     (vec-extern-decl 'C (length H) input-tag)
     (vec-extern-decl 'D 4 output-tag)
     (vec-decl 'reg-D (current-reg-size))))

  (define-values (D-reg-ids D-reg-loads D-reg-stores)
    (partition-bv-list 'D 4))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated three shuffle vectors
    (match-define (list shuf-A shuf-B shuf-C) shufs)

    ; Shuffle the inputs with symbolic shuffle vectors
    (define input-shuffle
      (list
       (vec-shuffle 'reg-A shuf-A (list 'A))
       (vec-shuffle 'reg-B shuf-B (list 'B))
       (vec-shuffle 'reg-C shuf-C (list 'C))))

    ; Use choose* to select an output register to both read and write
    (define output-standard-deviation
      (apply choose*
             (map (lambda (out-reg)
                    (list
                     (vec-write 'reg-D out-reg)
                     (vec-app 'out 'vec-standard-deviation (list 'reg-A 'reg-B 'reg-C))
                     (vec-write out-reg 'out)))
                  D-reg-ids)))

    (append input-shuffle output-standard-deviation))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 3))

  (prog
   (append preamble
           D-reg-loads
           (sketch-compute-shuffle-interleave
            shuffle-gen
            compute-gen
            iterations)
            D-reg-stores)))

; Run Standard-deviation sketch with symbolic inputs. If input bitvectors
; are missing, interp will generate freash symbolic values.
(define (run-standard-deviation-sketch sketch
                                       D-size
                                       cost-fn
                                       [V-1 #f]
                                       [V-2 #f]
                                       [V-3 #f])
  (define env (make-hash))
  (when (and V-1 V-2 V-3)
    (hash-set! env 'A V-1)
    (hash-set! env 'B V-2)
    (hash-set! env 'C V-3)
    (hash-set! env 'D (make-bv-list-zeros D-size)))

  (define-values (_ cost)
    (interp sketch
            env
            #:symbolic? #t
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-combine vector-combine
                           'vec-sum vector-reduce-sum
                           'vec-amount? vector-amount
                           'vec-average vector-average
                           'vec-standard-deviation vector-standard-deviation)))

  (list (take (hash-ref env 'D) D-size) cost))

; Get statistics on a proposed synthesis solution

(define (get-statistics D-size sol reg-of)
  (let*
     ([regs-cost (last (run-standard-deviation-sketch
                      sol
                      D-size
                      (make-register-cost reg-of)))]
     [class-uniq-cost (last (run-standard-deviation-sketch
                            sol
                            D-size
                            (make-shuffle-unique-cost prefix-equiv)))])
    (pretty-print `(class-based-unique-idxs-cost: ,(bitvector->integer class-uniq-cost)))
    (pretty-print `(registers-touched-cost: ,(bitvector->integer regs-cost)))
    (pretty-print '-------------------------------------------------------)))

; Describe the configuration parameters for this benchmark
(define standard-deviation:keys
  (list 'V-1 'V-2 'V-3 'iterations 'reg-size))


; Run standard deviation with the given spec.
; Requires that spec be a hash with all the keys describes in standard-deviation:keys.
(define (standard-deviation:run-experiment spec file-writer)
  (pretty-print (~a "Running standard deviation with config: " spec))
  (define V-1 (hash-ref spec 'V-1))
  (define V-2 (hash-ref spec 'V-2))
  (define V-3 (hash-ref spec 'V-3))
  (define iterations (hash-ref spec 'iterations))
  (define reg-size (hash-ref spec 'reg-size))
  (define pre-reg-of (and (hash-has-key? spec 'pre-reg-of)
                          (hash-ref spec 'pre-reg-of)))

  (assert (equal? V-2 V-3)
          "standard-deviation:run-experiment: Invalid bitvector sizes. V-2 not equal to V-3")

  ; Run the synthesis query
  (parameterize [(current-reg-size reg-size)]
    (define A (make-symbolic-bv-list (bitvector (value-fin)) 1))
    (define B (make-symbolic-bv-list (bitvector (value-fin)) 1))
    (define C (make-symbolic-bv-list (bitvector (value-fin)) 1))
    (define D-size 4)

    ; Generate sketch prog
    (define standard-d (standard-deviation-shuffle-sketch A B C iterations))

    ; Determine whether to use the pre-computed register-of uninterpreted
    ; function, or pass the implementation to the solver directly
    ; assume is a list of booleans to be asserted, reg-of specifies which function
    ; to use for that computation
    (define-values (assume reg-of)
      (if pre-reg-of
          (build-register-of-map)
          (values (list) reg-of-idx)))

    ; Define the cost function
    (define (cost-fn)
      (let ([cost-1 (make-shuffle-unique-cost prefix-equiv)]
            [cost-2 (make-register-cost reg-of)])
        (lambda (inst env)
          (bvadd (cost-1 inst env) (cost-2 inst env)))))

    ;Create function for sketch evaluation
    (define (sketch-func args)
      (apply (curry run-standard-deviation-sketch
                    standard-d
                    D-size
                    (cost-fn))
             args))

     ; Functionalize spec for minimization prog
    (define (spec-func args)
      (apply standard-deviation-spec args))

    ; Get a generator back from the synthesis procedure
    (define model-generator
      (synth-prog spec-func
                  sketch-func
                  (list A B C)
                  #:get-inps (lambda (args) (flatten args))
                  #:min-cost (bv-cost 0)
                  #:assume assume))

    ; Keep minimizing solution in the synthesis procedure and generating new
    ; solutions.
    (for ([(model cost) (sol-producer model-generator)])
      (if (sat? model)
        (let ([prog (evaluate standard-d model)])
          (file-writer prog cost)
          (pretty-print (concretize-prog prog)))
        (pretty-print (~a "failed to find solution: " model))))))








