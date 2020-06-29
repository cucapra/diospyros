;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Dot-product.v2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;A val is a structure
;(make-val list list)
;interpretation two vector lists

(define-struct val[vec1 vec2])

;Calculates the multiplication of the lists

(define (action v1)
  (cond
    [(empty? v1) 0]
    [else (+ (first v1) (action (rest v1)))]))


;Calculates the Dot product of two vector lists
  
(define (mult p)
  (cond
    [(or (empty? (val-vec1 p)) (empty? (val-vec2 p))) 0]
    [else (action (map * (val-vec1 p) (val-vec2 p)))]))
               


  
;Tests

(check-expect (mult (make-val '(1) '(1))) 1)
(check-expect (mult (make-val '(1 2 3) '(1 2 3))) 14)
(check-expect (mult (make-val '(1 2 3) '(4 5 6))) 32)
(check-expect (mult (make-val '(5 6 7) '(6 9 10))) 154)
(check-expect (mult (make-val '(1 2 3 4 5) '(1 2 3 4 5))) 55)
(check-expect
 (mult (make-val '(1 2 3 4 5 6 7 8 9 10) '(1 2 3 4 5 6 7 8 9 10)))
 385)
(check-expect
 (mult (make-val '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
                 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)))
 2870)
(check-expect
 (mult (make-val '(20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1)
                 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)))
 1540)