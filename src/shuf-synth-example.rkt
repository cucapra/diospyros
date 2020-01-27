#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "matrix-utils.rkt"
         "prog-sketch.rkt"
         "synth.rkt"
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

(define (continuous-vec? vec)
  (let ([i (vector-ref vec 0)])
    (for ([(el idx) (in-indexed vec)])
      (assert (pr (equal? el (+ i idx)))))))

; Generate program sketch for matrix multiply
(define (matrix-mul-shuffle-sketch mat-A mat-B iterations)
  (match-define (matrix A-rows A-cols _) mat-A)
  (match-define (matrix B-rows B-cols _) mat-B)
  ; Program preamble to define the "zero" vector.
  (define preamble
    (list
      (vec-extern-decl 'A (* A-rows A-cols))
      (vec-extern-decl 'B (* B-rows B-cols))
      (vec-extern-decl 'C (* A-cols B-rows))
      (vec-const 'Z (vector 0))))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated three shuffle vectors
    (match-define (list shuf-A shuf-B shuf-C) shufs)

    (list
      (vec-select 'reg-A shuf-A 'A 'Z)
      (vec-select 'reg-B shuf-B 'B 'Z)
      (vec-shuffle 'reg-C shuf-C 'C)
      ; Uncomment to force the output writes to be continuous.
      ;(vec-app 'out 'continuous-vec? (list shuf-C))
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


; Run a matrix multiply sketch with symbolic inputs.
(define (run-matrix-mul-sketch sketch cost-fn mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (define env (make-hash))
  (hash-set! env 'A A-elements)
  (hash-set! env 'B B-elements)
  (hash-set! env 'C (make-vector (* A-rows B-cols)
                                 0))

  (define cost
    (interp sketch
            env
            #:cost-fn cost-fn
            #:fn-map (hash 'vec-mac vector-mac
                           'continuous-vec? continuous-vec?)))

  (values (hash-ref env 'C) cost))


; Run the synthesis query
(parameterize [(current-reg-size 4)]
  (define A (make-symbolic-matrix 2 3))
  (define B (make-symbolic-matrix 3 3))

  ; Generate sketch prog
  (define mmul (matrix-mul-shuffle-sketch A B 5))
  (define (cost-fn)
    (let ([cost-1 (make-shuffle-unique-cost prefix-equiv)]
          [cost-2 (make-register-cost 4)])
    (lambda (inst env)
      (+ (cost-1 inst env) (cost-2 inst env)))))

  (define (sketch-func args)
    (apply (curry run-matrix-mul-sketch
                  mmul
                  (cost-fn))
           args))

  ; Functionalize spec for minimization prog
  (define (spec-func args)
    (apply matrix-multiply-spec args))

  (define model-generator
    (synth-prog spec-func
                sketch-func
                (list A B)
                #:get-inps (lambda (args) (flatten
                                            (map matrix-elements args)))
                #:max-cost 100
                #:min-cost 0))

  (for ([model (in-producer model-generator (void))])
    (if (sat? model)
      (let*-values
        ([(p) (evaluate mmul model)]
         [(_ uniq-cost) (run-matrix-mul-sketch p
                                               (make-shuffle-unique-cost)
                                               A B)]
         [(_ regs-cost) (run-matrix-mul-sketch p
                                               (make-register-cost 4)
                                               A B)]
         [(_ class-uniq-cost) (run-matrix-mul-sketch p
                                                     (make-shuffle-unique-cost prefix-equiv)
                                                     A B)])
        (pretty-print p)
        (pretty-print `(unique-idxs-cost: ,uniq-cost))
        (pretty-print `(class-based-unique-idxs-cost: ,class-uniq-cost))
        (pretty-print `(registers-touched-cost: ,regs-cost))
        (pretty-print '-------------------------------------------------------))
      (pretty-print model))))

