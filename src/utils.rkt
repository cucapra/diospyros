#lang rosette

(require "ast.rkt"
         "configuration.rkt"
         threading
         racket/trace
         rosette/lib/match
         (prefix-in $ racket))

(provide (all-defined-out))

;;========================= GENERAL =========================

(define (pr v)
  (pretty-print v)
  v)

; Id to string
(define (id->string id)
  (cond
    [(string? id) id]
    [(symbol? id) (symbol->string id)]
    [else (error "Invalid identifier: ~e" id)]))

(define (make-name-gen [out-app string->symbol])
  (define var-map (make-hash))
  (lambda (base)
    (define num
      (cond
        [(hash-has-key? var-map base) (add1 (hash-ref var-map base))]
        [else 0]))
    (hash-set! var-map base num)
    (out-app (format "~a_~a" base (number->string num)))))

;;========================= BITVECTORS =========================

(define (bv-overflow? width val)
  (>= val (expt 2 width)))

(define (bitvectorize-concrete width conc)
  (when (not ($integer? conc))
    (error 'bitvectorize-concrete
           "Cannot transform value to bitvector: ~a"
           conc))
  (when (bv-overflow? width conc)
    (error 'bitvectorize-concrete
           "Value cannot be represented with ~a bits: ~a"
           width
           conc))
  (bv conc width))

; Index values should not overflow and should be positive
(define (bv-index? bv-val)
  (assert (and (bv? bv-val)
               (not (bv-overflow? (index-fin) (bitvector->integer bv-val)))
               (bvsle (bv-index 0) bv-val))
          (~a "Invalid bitvector index: " bv-val))
  (bitvector (index-fin)) bv-val)

(define (bv-index int-val)
  (define bv-val (bitvectorize-concrete (index-fin) int-val))
  (assert (<= 0 (bitvector->integer bv-val))
          (~a "Invalid integer for creating bitvector integer: " int-val))
  bv-val)

; Element values should not overflow
(define (bv-value int-val)
  (bitvectorize-concrete (value-fin) int-val))

; Cost values should not overflow and should be positive
(define (bv-cost int-val)
  (define bv-val (bitvectorize-concrete (cost-fin) int-val))
  (assert (<= 0 (bitvector->integer bv-val))
          (~a "Invalid integer for creating bitvector cost: " int-val))
  bv-val)

;;========================= BITVECTOR LISTS =========================

(define (make-symbolic-bv-list ty size)
  (for/list ([_ (in-range size)])
    (define-symbolic* v ty)
    (box v)))

(define (make-bv-list-empty size)
  (for/list ([_ (in-range size)])
    (box void)))

(define (make-symbolic-bv-list-values size)
  (make-symbolic-bv-list (bitvector (value-fin)) size))

(define (make-symbolic-bv-list-indices size)
  (make-symbolic-bv-list (bitvector (index-fin)) size))

(define (make-symbolic-matrix rows cols)
  (matrix rows cols (make-symbolic-bv-list-values (* rows cols))))

(define (make-bv-list-zeros size)
  (for/list ([_ (in-range size)])
    (box (bv-value 0))))

(define (bv-list to-bv xs)
  (define elements (map to-bv xs))
  (map box elements))

(define (value-bv-list . xs)
  (bv-list bv-value xs))

(define (index-bv-list . xs)
  (bv-list bv-index xs))

(define (bv-list-set! lst idx val)
  (assert (list? lst) (~a "Expected a list, got " lst))
  (match lst
    [(cons box tail)
      (if (bveq idx (bv-index 0))
          (set-box! box val)
          (bv-list-set! tail (bvsub idx (bv-index 1)) val))]
    [_ (error "List idx not found" idx lst)]))

(define (bv-list-get lst idx)
  (assert (list? lst) (~a "Expected a list, got " lst))
  (match lst
    [(cons box tail)
      (if (bveq idx (bv-index 0))
          (unbox box)
          (bv-list-get tail (bvsub idx (bv-index 1))))]
    [_ (error "List idx not found" idx lst)]))

(define (concretize-bv-list lst)
  (define (bv-unbox x) (bitvector->integer (unbox x)))
  (list->vector (map bv-unbox lst)))

; Mutates the destination list in place, setting box values to the values boxed
; in the given source elements
(define (bv-list-copy! dest
                       dest-start
                       src
                       [src-start (bv-index 0)]
                       [src-end (bv-index (length src))])

  (assert (list? dest) (~a "Expected a list, got " dest))
  (assert (list? src) (~a "Expected a list, got " src))
  (assert (bv-index? dest-start) (~a "Expected index vector, got" dest-start))
  (assert (bv-index? src-start) (~a "Expected index vector, got" src-start))
  (assert (bv-index? src-end) (~a "Expected index vector, got" src-end))
  (define copy-len (bvsub src-end src-start))
  (assert (bvslt (bv-index 0) copy-len) (~a "Copy length must be positive, got " copy-len))
  (assert (bvsle (bvadd dest-start copy-len) (bv-index (length dest))) (~a "Copy length overflows destination, " copy-len))
  (assert (bvsle src-end (bv-index (length src))) (~a "Copy end index overflows source " copy-len))

  ; TODO(alexa): we might be able to just replace this with a for-loop if the
  ; bounds are never symbolic
  ; Mutates destination's elements in place
  (define (copy-bv-list-elements dest src idx)
    (match (cons dest src)
      [(cons (cons dest-box dest-tail) (cons src-box src-tail))
        (set-box! dest-box (unbox src-box))
        (when (bvslt (bv-index 1) idx)
          (copy-bv-list-elements dest-tail src-tail (bvsub idx (bv-index 1))))]
      [_ (error "List idx not found" idx)]))

  (copy-bv-list-elements (drop dest (bitvector->integer dest-start))
                         (drop src (bitvector->integer src-start))
                         copy-len))

;;========================= MATRICES =========================

; Print a matrix
(define (pr-matrix mat)
  (match-define (matrix _ cols elements) mat)
  (let loop ([els (vector->list elements)] [acc (list)])
    (if (empty? els)
      acc
      (loop (drop els cols) (cons (take els cols) acc)))))

; Matrix implementation and helper methods.
(struct matrix (rows cols elements) #:transparent)

(define (matrix-ref mat row col)
  (match-define (matrix rows cols elements) mat)
  (assert (and (< row rows) (>= row 0)) (~a "MATRIX-REF: Invalid row " row))
  (assert (and (< col cols) (>= col 0)) (~a "MATRIX-REF: Invalid col " col))
  (bv-list-get elements (bitvectorize-concrete (index-fin) (+ (* cols row) col))))

(define (matrix-set! mat row col val)
  (match-define (matrix rows cols elements) mat)
  (assert (and (< row rows) (>= row 0)) (~a "MATRIX-SET!: Invalid row " row))
  (assert (and (< col cols) (>= col 0)) (~a "MATRIX-SET!: Invalid col " col))
  (bv-list-set! elements (bitvectorize-concrete (index-fin) (+ (* cols row) col)) val))

;;========================= REGISTER PROPERTIES =========================

; Returns 0-indexed register that this index resides in based on the
; current register size.
; TODO(alexa): replace with a table-based lookup up to 2^(index-fin)
(define (reg-of idx)
  (bvsdiv idx (bv (current-reg-size) (index-fin))))

; Finds the length as a bitvector
(define (bv-length lst)
  (match lst
    [(cons _ tail)
      (bvadd (bv-cost 1) (bv-length tail))]
    [null (bv-cost 0)]
    [v (error 'bv-length "Unexpected value: ~a" v)]))

; Returns number of vectors accessed by an index vector assuming each vector
; contains reg-size elements.
(define (reg-used idxs upper-bound)
  ; Check how many distinct registers these indices fall within.
  ; TODO(alexa): replace with a potentially faster implementation
  (bv-length (remove-duplicates (map reg-of (map unbox idxs)))))

; Returns whether a vector of indices is continuous and aligned to the register
; size
(define (is-continuous-aligned-vec? reg-size vec)
  (and (equal? 0 (modulo (vector-ref vec 0) reg-size))
       (let ([i (vector-ref vec 0)])
         (andmap identity (for/list ([(el idx) (in-indexed vec)])
                            (equal? el (+ i idx)))))))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "matrix utilities"
      (test-case
        "REG-USED: calculates correctly"
        (parameterize ([current-reg-size 2])
          (let ([idxs (index-bv-list 0 7 2 5 6 1)]
                [upper-bound 4])
            (check-equal? (bv-cost 4) (reg-used idxs upper-bound))))))))

