#lang rosette

(require "dsp-insts.rkt"
         "matrix-utils.rkt"
         racket/trace)

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

;(pretty-print (matrix-multiply-spec 2 3 3 3))

(define (matrix-mul-sketch mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (define C-elements (make-vector (* A-rows B-cols) 0))
  (define reg-size 4)
  (define iterations 3)

  (match-define (list shufs-C shufs-A shufs-B shuf-stores-C)
    (build-list
      4
      (lambda (_)
        (build-list iterations
                    (lambda (_) (make-symbolic-vector reg-size))))))

  (for ([shuf-C shufs-C]
        [shuf-A shufs-A]
        [shuf-B shufs-B]
        [shuf-store-C shuf-stores-C])
    ; Fill each register using shuffles
    (define-values (reg-acc reg-A reg-B)
      (values (vector-shuffle C-elements shuf-C)
              (vector-shuffle A-elements shuf-A)
              (vector-shuffle B-elements shuf-B)))

    (define compute
      (vector-mac reg-acc reg-A reg-B))

    ; XXX(rachit): The shuffled store and set into C seems too flexible.
    ; We can probably constraint the load and store to be the same.
    (vector-shuffle-set! C-elements shuf-store-C compute))

  (values C-elements
          (list
            (list 'shufs-C shufs-C)
            (list 'shufs-A shufs-A)
            (list 'shufs-B shufs-B)
            (list 'stores-C shuf-stores-C))))

(define A (make-symbolic-matrix 2 3))
(define B (make-symbolic-matrix 3 3))
(match-define (spec inps C-spec) (matrix-multiply-spec A B))
(define-values (C-sketch shufs) (matrix-mul-sketch A B))
(pretty-print C-spec)
(time
  (pretty-print
    (evaluate shufs (solve (assert (equal? C-spec C-sketch))))))

'done
