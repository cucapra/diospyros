#lang rosette

(require "./ast.rkt"
         "./utils.rkt"
         "./configuration.rkt")

(define N 4)

(define (fft real_in img_in real_twid_in img_twid_in real_out img_out)
   (begin
     (define even 0)
     (define odd 0)
     (define log 0)
     (define rootindex 0)
     (define span ((lambda (x y) (arithmetic-shift x (- y))) 4 1))
     (define temp 0)
     (for
      ((i (in-range 0 4 1)))
      (begin
        (v-list-set! real_out i (v-list-get real_in i))
        (v-list-set! img_out i (v-list-get img_in i))))
     (begin
       (define (while18)
         (if ((lambda (x y) (not (equal? x y))) span 0)
           (begin
             (begin
               (set! odd span)
               (begin
                 (define (while20)
                   (if (< odd 4)
                     (begin
                       (begin
                         (set! odd (bitwise-ior odd span))
                         (set! even (bitwise-xor odd span))
                         (set! temp
                           (+
                            (v-list-get real_out even)
                            (v-list-get real_out odd)))
                         (v-list-set!
                          real_out
                          odd
                          (-
                           (v-list-get real_out even)
                           (v-list-get real_out odd)))
                         (v-list-set! real_out even temp)
                         (set! temp
                           (+
                            (v-list-get img_out even)
                            (v-list-get img_out odd)))
                         (v-list-set!
                          img_out
                          odd
                          (-
                           (v-list-get img_out even)
                           (v-list-get img_out odd)))
                         (v-list-set! img_out even temp)
                         (set! rootindex
                           (bitwise-and (arithmetic-shift even log) (- 4 1)))
                         (when (> rootindex 0)
                           (begin
                             (set! temp
                               (-
                                (*
                                 (v-list-get real_twid_in rootindex)
                                 (v-list-get real_out odd))
                                (*
                                 (v-list-get img_twid_in rootindex)
                                 (v-list-get img_out odd))))
                             (v-list-set!
                              img_out
                              odd
                              (+
                               (*
                                (v-list-get real_twid_in rootindex)
                                (v-list-get img_out odd))
                               (*
                                (v-list-get img_twid_in rootindex)
                                (v-list-get real_out odd))))
                             (v-list-set! real_out odd temp)))
                         (set! odd (+ odd 1)))
                       (while20))
                     '()))
                 (while20))
               (set! span (arithmetic-shift span (- 1)))
               (set! log (+ log 1)))
             (while18))
           '()))
       (while18))))

(define real_twd
  (map box (for/list ([n (in-range 0 (arithmetic-shift N -1))])
   (define partial (/ (* pi 2 n) N))
   (cos partial))))

(define img_twd
  (map box (for/list ([n (in-range 0 (arithmetic-shift N -1))])
    (define partial (/ (* pi 2 n) N))
    (- (sin partial)))))

(define real-in (v-list 0 1 2 3))
(define img-in (v-list 0 1 2 3))
(define real-out (make-v-list-zeros N))
(define img-out (make-v-list-zeros N))


(fft real-in img-in real_twd img_twd real-out img-out)
(pretty-print real-out)
(pretty-print img-out)

(when false (pretty-print "hello"))


