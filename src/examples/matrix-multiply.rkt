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

(provide matrix-mul:keys
         matrix-mul:only-spec
         matrix-mul:run-experiment
         matrix-multiply-spec)

(define (prelude A-rows A-cols B-rows B-cols)
  (list
    (vec-extern-decl 'A (* A-rows A-cols) input-tag)
    (vec-extern-decl 'B (* B-rows B-cols) input-tag)
    (vec-extern-decl 'C (* A-rows B-cols) output-tag)
    (vec-const 'Z (make-bv-list-zeros 1) float-type)))

(define (postlude output-names)
  (for/list ([n output-names]
             [i (in-naturals 0)])
    (let* ([start (* i (current-reg-size))]
           [end (* (+ i 1) (current-reg-size))])
      (vec-store 'C n start end))))

;; Runs the spec with symbolic inputs and returns:
;; - the resulting formula.
;; - the prelude instructions (list)
;; - outputs that the postlude should write to
(define (matrix-mul:only-spec config)
  (define A-rows (hash-ref config 'A-rows))
  (define A-cols (hash-ref config 'A-cols))
  (define B-rows (hash-ref config 'B-rows))
  (define B-cols (hash-ref config 'B-cols))
  (define A (make-symbolic-matrix A-rows A-cols 'A))
  (define B (make-symbolic-matrix B-rows B-cols 'B))

  (values (matrix-multiply-spec A B)
          (prog (prelude A-rows A-cols B-rows B-cols))
          (list 'C)))

;; Generate a spec for matrix multiply of a given size.
(define (matrix-multiply-spec mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (assert (= A-cols B-rows))
  (define C
    (matrix A-rows
            B-cols
            (make-bv-list-zeros (* A-rows B-cols))))
  (for* ([i A-rows]
         [j B-cols])
    (define sum
      (apply
        bvadd
        (for/list ([k A-cols])
          (bvmul (matrix-ref mat-A i k)
             (matrix-ref mat-B k j)))))
    (matrix-set! C i j sum))

  (matrix-elements C))

(define (pr v)
  (pretty-print v)
  v)

; Generate program sketch for matrix multiply
(define (matrix-mul-shuffle-sketch mat-A mat-B iterations)
  (match-define (matrix A-rows A-cols _) mat-A)
  (match-define (matrix B-rows B-cols _) mat-B)

  ; Program preamble to define the inputs
  (define preamble
    (append
     (prelude A-rows A-cols B-rows B-cols)
     (list (vec-decl 'reg-C (current-reg-size)))))

  (define-values (C-reg-ids C-reg-loads C-reg-stores)
    (partition-bv-list 'C (* A-rows B-cols)))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated two shuffle vectors
    (match-define (list shuf-A shuf-B) shufs)

    ; Shuffle the inputs with symbolic shuffle vectors
    (define input-shuffles
      (list
       (vec-shuffle 'reg-A shuf-A (list 'A))
       (vec-shuffle 'reg-B shuf-B (list 'B))))

    ; Use choose* to select an output register to both read and write
    (define output-mac
      (apply choose*
        (map (lambda (out-reg)
          (list
            (vec-write 'reg-C out-reg)
            (vec-app 'out 'vec-mac (list 'reg-C 'reg-A 'reg-B))
            (vec-write out-reg 'out)))
        C-reg-ids)))

    (append input-shuffles output-mac))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 2))

  (prog
   (append preamble
           C-reg-loads
           (sketch-compute-shuffle-interleave
            shuffle-gen
            compute-gen
            iterations)
           C-reg-stores)))

; Run a matrix multiply sketch with symbolic inputs. If input matrices
; are missing, interp will generate fresh symbolic values.
(define (run-matrix-mul-sketch sketch
                               C-size
                               cost-fn
                               [mat-A #f]
                               [mat-B #f])

  (define env (make-hash))
  (when (and mat-A mat-B)
    (match-define (matrix A-rows _ A-elements) mat-A)
    (match-define (matrix _ B-cols B-elements) mat-B)
    (hash-set! env 'A A-elements)
    (hash-set! env 'B B-elements)
    (hash-set! env 'C (make-bv-list-zeros C-size)))

  (define-values (_ cost)
    (interp sketch
            env
            #:symbolic? #t
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac)))

  (list (take (hash-ref env 'C) C-size) cost))

; Get statistics on a proposed synthesis solution
(define (get-statistics C-size sol reg-of)
  (let*
     ([regs-cost (last (run-matrix-mul-sketch
                      sol
                      C-size
                      (make-register-cost reg-of)))]
     [class-uniq-cost (last (run-matrix-mul-sketch
                            sol
                            C-size
                            (make-shuffle-unique-cost prefix-equiv)))])
    (pretty-print `(class-based-unique-idxs-cost: ,(bitvector->integer class-uniq-cost)))
    (pretty-print `(registers-touched-cost: ,(bitvector->integer regs-cost)))
    (pretty-print '-------------------------------------------------------)))


; Describe the configuration parameters for this benchmarks
(define matrix-mul:keys
  (list 'A-rows 'A-cols 'B-rows 'B-cols 'iterations 'reg-size))


; Run matrix multiply experiment with the given spec.
; Requires that spec be a hash with all the keys describes in matrix-mul:keys.
(define (matrix-mul:run-experiment spec file-writer)
  (pretty-print (~a "Running matrix multiply with config: " spec))
  (define A-rows (hash-ref spec 'A-rows))
  (define A-cols (hash-ref spec 'A-cols))
  (define B-rows (hash-ref spec 'B-rows))
  (define B-cols (hash-ref spec 'B-cols))
  (define iterations (hash-ref spec 'iterations))
  (define reg-size (hash-ref spec 'reg-size))
  (define pre-reg-of (and (hash-has-key? spec 'pre-reg-of)
                          (hash-ref spec 'pre-reg-of)))

  (assert (equal? A-cols B-rows)
          "matrix-mul:run-experiment: Invalid matrix sizes. A-cols not equal to B-rows")

  ; Run the synthesis query
  (parameterize [(current-reg-size reg-size)]
    (define A (make-symbolic-matrix A-rows A-cols))
    (define B (make-symbolic-matrix B-rows B-cols))
    (define C-size (* A-rows B-cols))

    (define reg-upper-bound
      (max (quotient (* A-rows A-cols) (current-reg-size))
           (quotient (* B-rows B-cols) (current-reg-size))
           (current-reg-size)))

    ; Generate sketch prog
    (define mmul (matrix-mul-shuffle-sketch A B iterations))

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

    ; Create function for sketch evaluation
    (define (sketch-func args)
      (apply (curry run-matrix-mul-sketch
                    mmul
                    C-size
                    (cost-fn))
             args))

    ; Functionalize spec for minimization prog
    (define (spec-func args)
      (apply matrix-multiply-spec args))

    ; Get a generator back from the synthesis procedure
    (define model-generator
      (synth-prog spec-func
                  sketch-func
                  (list A B)
                  #:get-inps (lambda (args) (flatten
                                              (map matrix-elements args)))
                  #:min-cost (bv-cost 0)
                  #:assume assume))

    ; Keep minimizing solution in the synthesis procedure and generating new
    ; solutions.
    (for ([(model cost) (sol-producer model-generator)])
      (if (sat? model)
        (let ([prog (evaluate mmul model)])
          (file-writer prog cost)
          (pretty-print (concretize-prog prog)))
        (pretty-print (~a "failed to find solution: " model))))))
