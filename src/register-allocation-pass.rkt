#lang racket

(define (register-allocation prog reg-size)
  ; TODO: change the program
  prog)

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
