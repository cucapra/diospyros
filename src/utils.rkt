#lang rosette

(require threading)

(provide (all-defined-out))

; Id to string
(define (id->string id)
  (cond
    [(string? id) id]
    [(symbol? id) (symbol->string id)]
    [else (error "Invalid identifier: ~e" id)]))

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
  (vector-ref elements (+ (* cols row) col)))

(define (matrix-set! mat row col val)
  (match-define (matrix rows cols elements) mat)
  (assert (and (< row rows) (>= row 0)) (~a "MATRIX-SET!: Invalid row " row))
  (assert (and (< col cols) (>= col 0)) (~a "MATRIX-SET!: Invalid col " col))
  (vector-set! elements (+ (* cols row) col) val))

; Returns 0-indexed register that this index resides in based on the
; current register size.
(define (reg-of reg-size idx)
  (quotient idx reg-size))

; Returns number of vectors accessed by an index vector assuming each vector
; contains reg-size elements.
(define (reg-used idx-vec reg-size upper-bound)
  ; Check how many distinct registers these indices fall within.
  (define reg-used (make-vector upper-bound #f))
  (for ([idx idx-vec])
    (vector-set! reg-used (reg-of reg-size idx) #t))
  (count identity (vector->list reg-used)))

; Returns whether a vector of indices is continuous and aligned to the register
; size
(define (is-continuous-aligned-vec? reg-size vec)
  (and (equal? 0 (modulo (vector-ref vec 0) reg-size))
       (let ([i (vector-ref vec 0)])
         (andmap identity (for/list ([(el idx) (in-indexed vec)])
                            (equal? el (+ i idx)))))))

(define (make-name-gen [out-app string->symbol])
  (define var-map (make-hash))
  (lambda (base)
    (define num
      (cond
        [(hash-has-key? var-map base) (add1 (hash-ref var-map base))]
        [else 0]))
    (hash-set! var-map base num)
    (out-app (format "~a_~a" base (number->string num)))))


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


