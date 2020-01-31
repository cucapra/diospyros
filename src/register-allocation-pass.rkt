#lang racket

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "matrix-utils.rkt")

(provide (all-defined-out))

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
  (define (check-defined ids)
    (for ([id ids])
      (unless (hash-has-key? env id) (error "undefined id ~a" id))))
  (define (define-id id)
    (hash-set! env id void))
  (match inst
    [(vec-extern-decl id size)
     (alloc-extern-decl env reg-size id size)]
    [(vec-const id init)
     (define-id id)
     (alloc-const env reg-size id init)]
    [(vec-shuffle id idxs inps)
     (define-id id)
     (check-defined (apply list idxs inps))
     inst]
    [(vec-shuffle-set! out-vec idxs inp)
     (check-defined (list idxs inp))
     inst]
    [(vec-app id f inps)
     (define-id id)
     (check-defined inps)
     inst]
    [_ (error 'register-allocation "unknown instruction ~a" inst)]))

(define (register-allocation program env reg-size)
  (define instrs (flatten (map (curry alloc-inst env reg-size)
                               (prog-insts program))))
  (prog instrs))

; Testing

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "interp tests"

      (test-case
        "Pad small vectors"
        (define env (make-hash))
        (define reg-size 4)
        (define/prog p
          ('x = vec-const (vector 0)))
        (define new-p (register-allocation p env reg-size))
        (define/prog gold
          ('x = vec-const (vector 0 0 0 0)))
        (check-equal? new-p gold)
        (check-equal? (hash-ref env 'x) (vector 0 0 0 0)))

      (test-case
        "Partition large vectors"
        (define env (make-hash))
        (define reg-size 4)
        (define/prog p
          ('x = vec-const (vector 0 1 2 3 4 5 6)))
        (define new-p (register-allocation p env reg-size))
        (define section-1-gold (vector 0 1 2 3))
        (define section-2-gold (vector 4 5 6 0))
        (define/prog gold
          ('x_0_4 = vec-const section-1-gold)
          ('x_4_7 = vec-const section-2-gold))
        (check-equal? new-p gold)
        (check-equal? (hash-ref (hash-ref env 'x) 0) 'x_0_4)))))
