#lang rosette

(require "../ast.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../matrix-utils.rkt"
         "../prog-sketch.rkt"
         "../synth.rkt"
         racket/trace
         racket/generator
         rosette/solver/smt/z3
         rosette/solver/smt/boolector)

(current-solver (boolector))
(current-bitwidth 8)

;; Generate a spec for matrix multiply of a given size.
(define (matrix-multiply-spec mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (assert (= A-cols B-rows))
  (define C
    (matrix A-rows
            B-cols
            (build-vector (* A-rows B-cols)
                          (lambda (_) 0))))
  (for* ([i A-rows]
         [j B-cols])
    (define sum
      (apply
        +
        (for/list ([k A-cols])
          (* (matrix-ref mat-A i k)
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
  ; Program preamble to define the "zero" vector.
  (define preamble
    (list
     (vec-extern-decl 'A (* A-rows A-cols))
     (vec-extern-decl 'B (* B-rows B-cols))
     (vec-extern-decl 'C (* A-rows B-cols))
     (vec-const 'Z (vector 0))))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated three shuffle vectors
    (match-define (list shuf-A shuf-B shuf-C) shufs)

    (define-symbolic* start integer?)
    (define-symbolic* end integer?)

    (list
     (vec-shuffle'reg-A shuf-A (list 'A 'Z))
     (vec-shuffle 'reg-B shuf-B (list 'B 'Z))
     (vec-shuffle 'reg-C shuf-C (list 'C))
     ; Uncomment to force the output writes to be continuous.
     (vec-void-app 'continuous-aligned-vec? (list shuf-C))
     (vec-app 'out 'vec-mac (list 'reg-C 'reg-A 'reg-B))
     (vec-shuffle-set! 'C shuf-C 'out)))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 3))

  (prog
   (append preamble
           (sketch-compute-shuffle-interleave
            shuffle-gen
            compute-gen
            iterations))))

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
    (hash-set! env 'C (make-vector C-size 0)))

  (define-values (_ cost)
    (interp sketch
            env
            #:symbolic? #t
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac
                           'continuous-aligned-vec?
                           (curry continuous-aligned-vec? (current-reg-size)))))

  (values (vector-take (hash-ref env 'C) C-size) cost))

; Get statistics on a proposed synthesis solution
(define (get-statistics C-size sol)
  (let*-values
    ([(_ uniq-cost) (run-matrix-mul-sketch
                      sol
                      C-size
                      (make-shuffle-unique-cost))]
     [(_ regs-cost) (run-matrix-mul-sketch
                      sol
                      C-size
                      (make-register-cost 4))]
     [(_ class-uniq-cost) (run-matrix-mul-sketch
                            sol
                            C-size
                            (make-shuffle-unique-cost prefix-equiv))])
    (pretty-print sol)
    (pretty-print `(unique-idxs-cost: ,uniq-cost))
    (pretty-print `(class-based-unique-idxs-cost: ,class-uniq-cost))
    (pretty-print `(registers-touched-cost: ,regs-cost))
    (pretty-print '-------------------------------------------------------)))

; Run the synthesis query
(parameterize [(current-reg-size 4)]
  (define A-rows 2)
  (define A-cols-B-rows 3)
  (define B-cols 3)
  (define A (make-symbolic-matrix A-rows A-cols-B-rows))
  (define B (make-symbolic-matrix A-cols-B-rows B-cols))
  (define C-size (* A-rows B-cols))

  ; Generate sketch prog
  (define mmul (matrix-mul-shuffle-sketch A B 6))

  ; Define the cost function
  (define (cost-fn)
    (let ([cost-1 (make-shuffle-unique-cost prefix-equiv)]
          [cost-2 (make-register-cost 4)])
    (lambda (inst env)
      (+ (cost-1 inst env) (cost-2 inst env)))))

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
                #:max-cost 100
                #:min-cost 0))

  ; Keep minimizing solution in the synthesis procedure and generating new
  ; solutions.
  (for ([model (in-producer model-generator (void))])
    (if (sat? model)
      (get-statistics C-size (evaluate mmul model))
      (pretty-print (~a "failed to find solution: " model)))))
