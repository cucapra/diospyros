#lang rosette

(require "ast.rkt"
         "configuration.rkt"
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

; Align vectors by padding to a multiple of current-reg-size
(define (align-to-reg-size vec)
  (define len (length vec))
  (define align-len
    (* (current-reg-size) (exact-ceiling (/ len (current-reg-size)))))
  (let ([fill (make-list (- align-len len) (box 0))])
    (append vec fill)))

;;========================= LIST MANIPULATION =========================

;;========================= BITVECTOR LISTS =========================

(define (make-symbolic-with-prefix name type)
  (constant (list name ((current-oracle) name)) type))

(define (make-symbolic-v-list size [prefix 'v])
  (for/list ([_ (in-range size)])
    (define v (make-symbolic-with-prefix prefix real?))
    (box v)))

(define (make-symbolic-matrix rows cols [prefix 'v])
  (matrix rows cols (make-symbolic-v-list (* rows cols) prefix)))

(define (make-v-list-zeros size)
  (for/list ([_ (in-range size)])
    (box 0)))

(define (make-v-list size val)
  (assert (real? val) (~a "Expected a real, got " val))
  (for/list ([_ (in-range size)])
    (box val)))

(define (v-list . xs)
  (map (lambda (x) (assert (real? x) (~a "Expected a real, got " x))) xs)
  (map box xs))

(define (v-list-set! lst idx val)
  (assert (list? lst) (~a "Expected a list, got " lst))
  (assert (real? idx) (~a "Expected a real, got " idx))
  (set-box! (list-ref lst idx) val))

(define (v-list-get lst idx)
  (assert (list? lst) (~a "Expected a list, got " lst))
  (assert (real? idx) (~a "Expected a real, got " idx))
  (unbox (list-ref lst idx)))

; TODO: replace?
(define (concretize-v-list lst)
  (define (box-to-val x)
    (define v (unbox x))
    (cond
      [(real? v) v]
      [(symbol? v) v]
      [else (error (~a "Expected real or symbol, got " v))]))

  (list->vector (map box-to-val lst)))

; Mutates the destination list in place, setting box values to the values boxed
; in the given source elements
(define (v-list-copy! dest
                      dest-start
                      src
                      [src-start 0]
                      [src-end (length src)])

  (assert (list? dest) (~a "Expected a list, got " dest))
  (assert (list? src) (~a "Expected a list, got " src))
  (assert (real? dest-start) (~a "Expected index real, got" dest-start))
  (assert (real? src-start) (~a "Expected index real, got" src-start))
  (assert (real? src-end) (~a "Expected index real, got" src-end))
  (define copy-len (- src-end src-start))
  (assert (< 0 copy-len) (~a "Copy length must be positive, got " copy-len))
  (assert (<= (+ dest-start copy-len) (length dest)) (~a "Copy length overflows destination, " copy-len))
  (assert (<= src-end (length src)) (~a "Copy end index overflows source " copy-len))

  ; TODO(alexa): we might be able to just replace this with a for-loop if the
  ; bounds are never symbolic
  ; Mutates destination's elements in place
  (define (copy-v-list-elements dest src idx)
    (match (cons dest src)
      [(cons (cons dest-box dest-tail) (cons src-box src-tail))
        (set-box! dest-box (unbox src-box))
        (when (< 1 idx)
          (copy-v-list-elements dest-tail src-tail (sub1 idx)))]
      [_ (error "List idx not found" idx)]))

  (copy-v-list-elements (drop dest dest-start)
                        (drop src src-start)
                        copy-len))

; Convert lists of boxed bitvectors to vectors of integers
(define (concretize-prog p)
  (define (concretize inst)
    (match inst
      [(vec-const id init type)
        (vec-const id (concretize-v-list init) type)]
      [(vec-load dest-id src-id start end)
       (vec-load dest-id
                 src-id
                 (bitvector->integer start)
                 (bitvector->integer end))]
      [(vec-store dest-id src-id start end)
       (vec-store dest-id
                  src-id
                  (bitvector->integer start)
                  (bitvector->integer end))]
      [_ inst]))

  (prog (map concretize (prog-insts p))))

(define (to-v-list-prog p)
  (define (to-vs inst)
    (match inst
      [(vec-const id init type)
        (vec-const id (map box (vector->list init)) type)]
      [(vec-load dest-id src-id start end)
       (vec-load dest-id
                 src-id
                 start
                 end)]
      [(vec-store dest-id src-id start end)
       (vec-store dest-id
                  src-id
                  start
                  end)]
      [(array-get id a i)
       (array-get id a i)]
      [(let-bind id expr type)
       (let-bind id (string->number expr) type)]
      [_ inst]))

  (prog (map to-vs (prog-insts p))))

;;========================= MATRICES =========================

; Print a matrix
(define (pr-matrix mat)
  (match-define (matrix _ cols elements) mat)
  (let loop ([els (vector->list elements)] [acc (list)])
    (if (empty? els)
      acc
      (loop (drop els cols) (cons (take els cols) acc)))))

; Matrix implementation and helper methods.
(struct matrix (rows cols elements) #:transparent #:mutable)

(define (matrix-ref mat row col)
  (match-define (matrix rows cols elements) mat)
  (assert (and (< row rows) (>= row 0)) (~a "MATRIX-REF: Invalid row " row))
  (assert (and (< col cols) (>= col 0)) (~a "MATRIX-REF: Invalid col " col))
  (v-list-get elements (+ (* cols row) col)))

(define (matrix-set! mat row col val)
  (match-define (matrix rows cols elements) mat)
  (assert (and (< row rows) (>= row 0)) (~a "MATRIX-SET!: Invalid row " row))
  (assert (and (< col cols) (>= col 0)) (~a "MATRIX-SET!: Invalid col " col))
  (v-list-set! elements (+ (* cols row) col) val))

;;========================= REGISTER PROPERTIES =========================

; The 0-indexed register that this index resides in based on the current
; register size.
(define (reg-of-idx idx)
  (floor (/ idx (current-reg-size))))

; Build an uninterpreted function to act as a table mapping indices to the
; register they fall within (quotient is expensive and the number of indices
; is bound by 2^(index-fin - 1)). Produces a thunk with asserts that define the
; function's behavior and an application function to get the register of an
; index.
(define (build-register-of-map)
  (define-symbolic* register-of
    (let* ([index-ty (bitvector (index-fin))]
           [cost-ty (bitvector (cost-fin))])
      (~> index-ty cost-ty)))

  (define fn-defn
    (for/list ([idx (in-range (expt 2 (sub1 (index-fin))))])
      (define reg (reg-of-idx idx))
      (eq? reg (register-of idx))))

  ; Look up pre-computed register-of
  (define (pre-reg-of idx)
    (register-of idx))

  (values fn-defn pre-reg-of))

; Returns number of vectors accessed by an index vector assuming each vector
; contains reg-size elements. Passed a specific implementation of register-of
; to use.
(define (reg-used idxs reg-of)
  ; Check how many distinct registers these indices fall within.
  (length (remove-duplicates (map reg-of (map unbox idxs)))))

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
          (let ([idxs (v-list 0 7 2 5 6 1)])
            (check-equal? 4 (reg-used idxs reg-of-idx))))))))

