#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "emit-c.rkt"
         "interp.rkt"
         "matrix-utils.rkt"
         "prog-sketch.rkt"
         racket/trace
         rosette/solver/smt/z3
         rosette/solver/smt/boolector)

(current-solver (boolector))
(current-bitwidth 8)

(define reg-size 4)

;; Interface to the data movememnt synthesis code.
(struct spec (inputs outputs) #:transparent)

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

  (spec (flatten (map vector->list (list A-elements B-elements)))
        (matrix-elements C)))


; Generate program sketch for matrix multiply
(define (matrix-mul-shuffle-sketch mat-A mat-B iterations)
  (match-define (matrix A-rows A-cols _) mat-A)
  (match-define (matrix B-rows B-cols _) mat-B)
  ; Program preamble to load the initial vectors and define the "zero" vector.
  (define preamble
    (list
      (vec-const 'Z (vector 0))
      (vec-load 'A 0 (* A-rows A-cols))
      (vec-load 'B (* A-rows A-cols) (* B-rows B-cols))
      (vec-const 'C (make-vector (* A-rows B-cols) 0))))

  ; Compute description for the sketch
  (define (compute-gen iteration shufs)
    ; Assumes that shuffle-gen generated three shuffle vectors
    (match-define (list shuf-A shuf-B shuf-C) shufs)
    (list
      (vec-select 'reg-A shuf-A 'A 'Z)
      (vec-select 'reg-B shuf-B 'B 'Z)
      (vec-shuffle 'reg-C shuf-C 'C)
      (vec-app 'out 'vec-mac (list 'reg-C 'reg-A 'reg-B))
      (vec-shuffle-set! 'C shuf-C 'out)))

  ; Shuffle vectors for each iteration
  (define shuffle-gen
    (symbolic-shuffle-gen 3))

  ; Write final value of C to memory
  (define epilogue
    (list (vec-unload 'C
                      (+ (* A-rows A-cols)
                         (* B-rows B-cols)))))

  (prog
    (append preamble
            (sketch-compute-shuffle-interleave
              shuffle-gen
              compute-gen
              iterations)
            epilogue)))

(define (run-matrix-mul-sketch sketch mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (define memory
    (make-vector (+ (* A-rows A-cols)
                    (* B-rows B-cols)
                    (* A-rows B-cols))
                 0))
  (write-vec! memory 0 A-elements)
  (write-vec! memory (vector-length A-elements) B-elements)

  (interp sketch
          memory
          #:fn-map (hash 'vec-mac vector-mac))

  (read-vec memory
            (+ (* A-rows A-cols)
               (* B-rows B-cols))
            (* A-rows B-cols)))


(parameterize [(current-reg-size 4)]
  (define A (make-symbolic-matrix 2 3))
  (define B (make-symbolic-matrix 3 3))
  (define mmul (matrix-mul-shuffle-sketch A B 5))
  (define C-sketch (run-matrix-mul-sketch mmul A B))
  (match-define (spec inps C-spec) (matrix-multiply-spec A B))
  (define model
    (time
      (synthesize
        #:forall inps
        #:guarantee (assert (equal? C-spec C-sketch)))))
  (pretty-print (if (sat? model) (evaluate mmul model) model)))


#|
(define (matrix-mul-sketch mat-A mat-B)
  (match-define (matrix a-rows a-cols a-elements) mat-a)
  (match-define (matrix b-rows b-cols b-elements) mat-b)
  (define C-elements (make-vector (* A-rows B-cols) 0))
  (define shuffle-reg-count 2)

  ; For now, iterations are the total number of multiplies divided by the
  ; register size.
  (define iterations
    (exact-ceiling (/ (* A-rows A-cols B-cols) reg-size)))

  ; Symbolic shuffle matrices for each iteration.
  (define reg-upper-bound
    (exact-ceiling (/ (* A-cols (max A-rows B-cols)) reg-size)))

  (define (build-shufs shuffle-reg-count)
    (lambda (_)
        (build-list iterations
                    (lambda (_)
                      (make-symbolic-indices-restriced reg-size
                                                       shuffle-reg-count
                                                       reg-upper-bound)))))

  (match-define (list shufs-A shufs-B) (build-list 2 (build-shufs 2)))

  ; Option to use a distinct shuffle reg count for the output.
  (define shufs-C ((build-shufs 2) void))

  ; The "zero" register so vector registers can have empty values.
  (define zero (vector 0))

  (for ([shuf-C shufs-C]
        [shuf-A shufs-A]
        [shuf-B shufs-B])
    ; Fill each register using shuffles
    (define-values (reg-acc reg-A reg-B)
      (values (vector-shuffle C-elements shuf-C)
              (vector-select A-elements zero shuf-A)
              (vector-select B-elements zero shuf-B)))

    (define compute
      (vector-mac reg-acc reg-A reg-B))
    ;(pretty-print `(,reg-acc ,reg-A ,reg-B ,compute))
    ;(pretty-print '----------------------)

    (vector-shuffle-set! C-elements shuf-C compute))

  (values C-elements
          (list
            (list 'shufs-C shufs-C)
            (list 'shufs-A shufs-A)
            (list 'shufs-B shufs-B))))

(define A (make-symbolic-matrix 2 3))
(define B (make-symbolic-matrix 3 3))
(match-define (spec inps C-spec) (matrix-multiply-spec A B))
(define-values (C-sketch shufs) (matrix-mul-sketch A B))
;(pretty-print '------------------------)
(pretty-print A)
(pretty-print B)
(pretty-print C-spec)
;(pretty-print C-sketch)
(define model
  (time
    (synthesize
      #:forall inps
      #:guarantee (assert (equal? C-spec C-sketch)))))
;(pretty-print model)
(pretty-print (if (sat? model) (evaluate shufs model) model))


; Create an AST program for this completed sketch
(define (ast-prog)
  (match-define (matrix A-rows A-cols A-elements) A)
  (match-define (matrix B-rows B-cols B-elements) B)
  (define A-size (* A-rows A-cols))
  (define B-size (* B-rows B-cols))
  (define C-size (* A-rows B-cols))
  (define memory-size (+ A-size B-size C-size))

  (define (load-vectors name size offset)
    (for/vector ([i (in-range 0 size reg-size)])
      (define load-size (cond
                          [(< (+ i reg-size) size) reg-size]
                          [else (modulo size reg-size)]))
      (define id (format "load~a_~a" name i))
      (vec-load id (+ offset i) load-size)))

  (define (id-for-idx loads idx)
    (match-define (vec-load id _ _) (vector-ref loads idx)) id)
  (define A-loads (load-vectors "A" A-size 0))
  (define B-loads (load-vectors "B" B-size A-size))
  (define C-loads (load-vectors "C" C-size (+ A-size B-size)))

  (match-define (list (cons _ (list shufs-C))
                      (cons _ (list shufs-A))
                      (cons _ (list shufs-B))) (evaluate shufs model))

  (define move-compute
    (for/list ([shuf-A shufs-A]
               [shuf-B shufs-B]
               [shuf-C shufs-C])

      (define (shuffle-or-select id loads shufs size)
        (define shuffled-id (format "shuffled~a" id))
        (define shuf-id (format "shuf~a" id))
        (define ordered-reg-used
          (sort (remove-duplicates (map (curry reg-of reg-size)
                                        (vector->list shufs))) <))
        (define (truncate-shuf i)
          (define mod (modulo i reg-size)) ; Truncate down
          (cond
            [(= (reg-of reg-size i) (first ordered-reg-used)) mod] ; 1st register
            [else (+ mod reg-size)])) ; 2nd register, add reg-size
        (define truncated-shufs (vector-map truncate-shuf shufs))
        (define shuf-decl (vec-const shuf-id truncated-shufs))

        ; Determine if a select or shuffle
        (define cmd (match (length ordered-reg-used)
          [1
           (let ([source-id (id-for-idx loads (first ordered-reg-used))])
             (vec-shuffle shuffled-id shuf-id source-id))]
          [2
           (cond
             ; Check if this shuffle uses the designated "zero" register
             [(vector-memv size shufs)
              (let ([source-id (id-for-idx loads (first ordered-reg-used))])
              (vec-select shuffled-id shuf-id source-id "zero"))]
             ; Otherwise, it's a shuffle between two loads
             [else
              (define reg-ids (map (curry id-for-idx loads) ordered-reg-used))
              (apply vec-select shuffled-id shuf-id reg-ids)])]))
        (cons shuf-decl cmd))

      (flatten
       (list (shuffle-or-select "A" A-loads shuf-A A-size)
             (shuffle-or-select "B" B-loads shuf-B B-size)
             (shuffle-or-select "C" C-loads shuf-C C-size)
             (vec-app "mac" `vector-mac (list "shuffledC" "shuffledA" "shuffledB"))))))

  (define p (prog (flatten
                   (list (vec-const "zero" (make-vector reg-size 0))
                         (vector->list A-loads)
                         (vector->list B-loads)
                         (vector->list C-loads)
                         move-compute))))
  (cons p memory-size))


; Define function definition mapping for interp.
(define function-env (make-hash))
(define (declare-function f val)
  (hash-set! function-env f val))
(define (function-ref f)
  (hash-ref function-env f))


(declare-function `vector-mac vector-mac)

(when (sat? model)
  (match-define (cons p memory-size) (ast-prog))
  (pretty-print p)
  (define cost-fn (curry simple-shuffle-cost 3))
  (interp p (make-vector memory-size 0) cost-fn function-ref)
  (emit p memory-size))|#
