#lang rosette

(require test-engine/racket-tests)
(require threading)
(require "../utils.rkt")
(require "../ast.rkt")
(require "../interp.rkt")
(require "../dsp-insts.rkt")

(define/prog desviacion-estandar-p
  ('x = vec-extern-decl 4 int-type)
  ('y = vec-extern-decl 4 int-type)
  ('add-result = vec-app 'vec-add (list 'x 'y))
  ('how-many = vec-app 'vec-amount? (list 'add-result))
  ('sum-result = vec-app 'vec-sum (list 'add-result))
  ('average = vec-app 'vec-average (list 'sum-result 'how-many)))
  ;('standard-deviation = vec-app 'vec-standard-deviation (list 'add-result 'average 'how-many)))

(define action (make-hash))
(hash-set! action 'x (value-bv-list 1 2 3 6))
(hash-set! action 'y (value-bv-list 1 2 3 6))


(define function-map (hash 'vec-add vector-add
                           'vec-sum vector-reduce-sum
                           'vec-amount? vector-amount
                           'vec-average vector-average
                           'ved-standard-deviation vector-standard-deviation))

(interp desviacion-estandar-p action #:fn-map function-map)

(define sum-results (hash-ref action 'sum-result))
(define average-results (hash-ref action 'average))

(define (average s t)
  (cond
    [(empty? (rest t)) (first t)]
    [else (/ (+ (first t) (average s (rest t))) (* 2 s))]))
    

(define (count p)
  (cond
    [(empty? p) 0]
    [else (average (+ 1 (count (rest p))) p)]))

(map bitvector->integer (map unbox sum-results))
(map bitvector->integer (map unbox average-results))




