#lang racket

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "matrix-utils.rkt")

; Determines registersd used and sorts ascending
(define (ordered-regs-used reg-size shufs)
  (sort (remove-duplicates (map (curry reg-of reg-size)
                                (vector->list shufs))) <))

; Truncates shuffles to reference only the accessed registers.
; reg-size 4,  [0, 1, 8, 9] -> [0, 1, 2, 3]
(define (truncate-shuf reg-size ordered-regs-used i)
  (let ([mod (modulo i reg-size)]
        [offset (* (index-of ordered-regs-used i) reg-size)])
    (+ mod offset)))

; Pad vector with 0's to given length
(define (vector-pad-to vec len)
  (unless (>= len (vector-length vec))
    (error 'vector-pad-to "failed because ~a is longer than ~a" vec len))
  (let ([fill (make-vector (- len (vector-length vec)) 0)])
    (vector-append vec fill)))

; Partition a vector into reg-size sections, with an abstract init function.
; Modifies env and produces a list of new vectors.
(define (partition-vector env id vec-len reg-size init-fn)
  ; Map the old id to a nested map of new-ids
  (let* ([id-map (make-hash)]
         [new-vecs
          (for/list ([i (in-range 0 vec-len reg-size)])
            (let* ([start i]
                   [end (min vec-len (+ i reg-size))]
                   [new-init (init-fn start end)]
                   [new-id (string->symbol
                            (format "~a_~a_~a" id start end))])
              ; Add the new vectors to the top level env
              (hash-set! env new-id new-init)
              (for ([j (in-range start end 1)])
                (hash-set! id-map j new-id))
              (vec-const new-id new-init)))])
    ; Add the old id as a map to the new ids, by index
    (hash-set! env id id-map)
    new-vecs)
  )

; Produces 1 or more instructions, modifies env
(define (alloc-const env reg-size id init)
  (unless (vector? init)
    (error 'alloc-const "failed because ~a is not a vector" init))
  (let ([len (vector-length init)])
    (cond
      ; Fill short vectors to register size
      [(<= len reg-size)
       (let ([new-init (vector-pad-to init reg-size)])
         (vector-pad-to init reg-size)
         (hash-set! env id new-init)
         (vec-const id new-init))]
      ; Allocate long vectors to multiple registers
      [else
       (define (copy-init start end)
         (let ([section (vector-copy init start end)])
           (vector-pad-to section reg-size)))
       (partition-vector env id len reg-size copy-init)])))

(define (alloc-extern-decl env reg-size id size)
  (define (load-init start end)
    (vec-load id start end))
  (partition-vector env id size reg-size load-init))

; Produces 1 or more instructions, modifies env
(define (alloc-inst env reg-size inst)
  (match inst
    [(vec-extern-decl id size) (alloc-extern-decl env reg-size id size)]
    [(vec-const id init) (alloc-const env reg-size id init)]
    [(vec-shuffle id idxs inp) inst]
    [(vec-select id idxs inp1 inp2) inst]
    [(vec-shuffle-set! out-vec idxs inp) inst]
    [(vec-app id f inps) inst]
    [(vec-print id) inst]
    [_ (error 'register-allocation "unknown instruction ~a" inst)]))

(define (register-allocation program env reg-size)
  (define instrs (flatten (map (curry alloc-inst env reg-size)
                               (prog-insts program))))
  (pretty-print env)
  (prog instrs))

; Test program copied from matmul
(define p (prog
 (list
  (vec-extern-decl 'A 6)
  (vec-extern-decl 'B 9)
  (vec-const 'X '#(0 1 2 3 4 5))
  (vec-const 'Z '#(0))
  (vec-const `shuf-fake '#(0 1 2 4))
  (vec-const 'shuf0-0 '#(3 1 3 3))
  (vec-const 'shuf1-0 '#(1 3 2 0))
  (vec-const 'shuf2-0 '#(4 0 5 3))
  (vec-select 'reg-A 'shuf0-0 'A 'Z)
  (vec-select 'reg-B 'shuf1-0 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-0 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-0 'out)
  (vec-const 'shuf0-1 '#(4 0 0 0))
  (vec-const 'shuf1-1 '#(3 2 1 0))
  (vec-const 'shuf2-1 '#(3 2 1 0))
  (vec-select 'reg-A 'shuf0-1 'A 'Z)
  (vec-select 'reg-B 'shuf1-1 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-1 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-1 'out)
  (vec-const 'shuf0-2 '#(5 4 6 5))
  (vec-const 'shuf1-2 '#(8 4 5 6))
  (vec-const 'shuf2-2 '#(5 4 0 3))
  (vec-select 'reg-A 'shuf0-2 'A 'Z)
  (vec-select 'reg-B 'shuf1-2 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-2 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-2 'out)
  (vec-const 'shuf0-3 '#(2 2 2 2))
  (vec-const 'shuf1-3 '#(6 9 7 8))
  (vec-const 'shuf2-3 '#(0 3 1 2))
  (vec-select 'reg-A 'shuf0-3 'A 'Z)
  (vec-select 'reg-B 'shuf1-3 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-3 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-3 'out)
  (vec-const 'shuf0-4 '#(4 5 1 1))
  (vec-const 'shuf1-4 '#(5 7 5 4))
  (vec-const 'shuf2-4 '#(5 4 2 1))
  (vec-select 'reg-A 'shuf0-4 'A 'Z)
  (vec-select 'reg-B 'shuf1-4 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-4 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-4 'out))))

(pretty-print (register-allocation p (make-hash) 4))

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
|#
