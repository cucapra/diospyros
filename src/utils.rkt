#lang rosette

(require "ast.rkt"
         "configuration.rkt"
         threading
         racket/trace
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
  (assert (and (not (bv-overflow? (index-fin) (bitvector->integer bv-val)))
               (bvsle (bv-index 0) bv-val))
          (~a "Invalid bitvector index" bv-val))
  (bitvector (index-fin)) bv-val)

(define (bv-index int-val)
  (assert (and (integer? int-val)
               (<= 0 int-val)
               (not (bv-overflow? (index-fin) int-val)))
          (~a "Invalid integer for creating bitvector index" int-val))
  (bv int-val (index-fin)))

; Element values should not overflow
(define (bv-value int-val)
  (assert (and (integer? int-val)
               (not (bv-overflow? (value-fin) int-val)))
          (~a "Invalid integer for creating bitvector value" int-val))
  (bv int-val (value-fin)))

; Cost values should not overflow and should be positive
(define (bv-cost int-val)
  (assert (and (integer? int-val)
               (<= 0 int-val)
               (not (bv-overflow? (cost-fin) int-val)))
          (~a "Invalid integer for creating bitvector cost" int-val))
  (bv int-val (cost-fin)))

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

(define (bv-list width xs)
  (define elements (map (curry bitvectorize-concrete width) xs))
  (map box elements))

(define (value-bv-list . xs)
  (bv-list (value-fin) xs))

(define (index-bv-list . xs)
  (bv-list (index-fin) xs))

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

  void

  ; (define copy-len (- src-end src-start))



  ; (define (rec-copy dest dest-start src src-start src-end)



)

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

; Returns number of vectors accessed by an index vector assuming each vector
; contains reg-size elements.
(define (reg-used idxs reg-size upper-bound)
  ; Check how many distinct registers these indices fall within.
  ; TODO(alexa): replace with a potentially faster implementation
  (length (remove-duplicates (map reg-of (map unbox idxs)))))

; Returns whether a vector of indices is continuous and aligned to the register
; size
(define (is-continuous-aligned-vec? reg-size vec)
  (and (equal? (bv-index 0)
               (bvsmod (bv-list-get vec (bv-index 0))
                       (integer->bitvector reg-size (bitvector (index-fin)))))
       (let ([i (bv-list-get vec 0)])
         (andmap identity
                 (for/list ([(el idx) (in-indexed vec)])
                   (equal? el (bvadd i
                                     (bv-index idx))))))))


(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "matrix utilities"
      (test-case
        "REG-USED: calculates correctly"
        (let ([idx-vec (vector 0 7 2 5 6 1)]
              [reg-size 2]
              [upper-bound 4])
          (check-equal? 4 (reg-used idx-vec reg-size upper-bound)))))))

