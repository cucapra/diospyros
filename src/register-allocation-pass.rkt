#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "matrix-utils.rkt")

(provide register-allocation)

(struct inst-result (insts final) #:transparent)

; Pad vector with 0's to given length
(define (vector-pad-to vec len)
  (unless (>= len (vector-length vec))
    (error 'vector-pad-to "failed because ~a is longer than ~a" vec len))
  (let ([fill (make-vector (- len (vector-length vec)) 0)])
    (vector-append vec fill)))

; Partition a vector into reg-size sections, with an abstract init function.
; Modifies env and produces a list of new vectors.
(define (partition-vector env id vec-len init-fn)
  (define len (* (current-reg-size) (exact-ceiling (/ vec-len (current-reg-size)))))
  ; Map the old id to a nested map of new-ids
  (let* ([id-map (make-hash)]
         [new-vecs
          (for/list ([i (in-range 0 len (current-reg-size))])
            (let* ([start i]
                   [end (min len (+ i (current-reg-size)))]
                   [new-id (string->symbol
                            (format "~a_~a_~a" id start end))]
                   [new-init (init-fn new-id start end)])
              ; Add the new vectors to the top level env
              (hash-set! env new-id new-init)
              (for ([j (in-range start end 1)])
                (hash-set! id-map j new-id))
              (inst-result
               new-init
               (vec-store id new-id start end))))])
    ; Add the old id as a map to the new ids, by index
    (hash-set! env id id-map)
    (inst-result
     (map inst-result-insts new-vecs)
     (map inst-result-final new-vecs))))

; Produces 1 or more instructions, modifies env
(define (alloc-const env id init)
  (unless (vector? init)
    (error 'alloc-const "failed because ~a is not a vector" init))
  (let ([len (vector-length init)])
    (cond
      ; Fill short vectors to register size
      [(<= len (current-reg-size))
       (let ([new-init (vector-pad-to init (current-reg-size))])
         (vector-pad-to init (current-reg-size))
         (hash-set! env id new-init)
         (inst-result (vec-const id new-init) `()))]
      ; Allocate long vectors to multiple registers
      [else
       (define (load-init dest-id start end)
         (vec-load dest-id id start end))
       (define results
         (partition-vector env id len load-init))
       (inst-result
        (cons (vec-const id init) (inst-result-insts results))
        (inst-result-final results))])))

(define (alloc-extern-decl env id size)
  (define (load-init dest-id start end)
    (vec-load dest-id id start end))
  (partition-vector env id size load-init))

; Produces 1 or more instructions, modifies env
(define (alloc-inst env inst)
  (define (check-defined ids)
    (for ([id ids])
      (unless (hash-has-key? env id) (error "undefined id ~a" id))))
  (define (define-id id)
    (hash-set! env id void))
  (match inst
    [(vec-extern-decl id size)
     (match-define (inst-result insts final)
       (alloc-extern-decl env id size))
     (inst-result (cons inst insts) final)]
    [(vec-const id init)
     (define-id id)
     (alloc-const env id init)]
    [(vec-shuffle id idxs inps)
     (define-id id)
     (check-defined (apply list idxs inps))
     (inst-result inst `())]
    [(vec-shuffle-set! out-vec idxs inp)
     (check-defined (list idxs inp))
     (inst-result inst `())]
    [(vec-app id f inps)
     (define-id id)
     (check-defined inps)
     (inst-result inst `())]
    [(vec-void-app f inps)
     (check-defined inps)
     (inst-result inst `())]
    [_ (error 'register-allocation "unknown instruction ~a" inst)]))

(define (register-allocation program env)
  (define results (map (curry alloc-inst env) (prog-insts program)))

  (define insts
    (flatten
     (list
      (map inst-result-insts results)
      (map inst-result-final results))))

  (prog insts))

; Testing

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "register allocation tests"

      (test-case
        "Pad small vectors"
        (define env (make-hash))
        (define/prog p
          ('x = vec-const (vector 0)))
        (define new-p (register-allocation p env))
        (define/prog gold
          ('x = vec-const (vector 0 0 0 0)))
        (check-equal? new-p gold)
        (check-equal? (hash-ref env 'x) (vector 0 0 0 0)))

      (test-case
        "External decl"
        (define env (make-hash))
        (hash-set! env `x (make-vector 1 1))
        (define/prog p
          (vec-extern-decl 'x 1))
        (define new-p (register-allocation p env))
        (define/prog gold
          (vec-extern-decl 'x 1)
          (vec-load 'x_0_4 'x 0 4)
          (vec-store 'x 'x_0_4 0 4))
        (check-equal? new-p gold))

      (test-case
        "Partition large vectors"
        (define env (make-hash))
        (define/prog p
          ('x = vec-const (vector 0 1 2 3 4 5 6)))
        (define new-p (register-allocation p env ))
        (define section-1-gold (vector 0 1 2 3))
        (define section-2-gold (vector 4 5 6 0))
        (define/prog gold
          ('x = vec-const '#(0 1 2 3 4 5 6))
          (vec-load 'x_0_4 'x 0 4)
          (vec-load 'x_4_8 'x 4 8)
          (vec-store 'x 'x_0_4 0 4)
          (vec-store 'x 'x_4_8 4 8))
        (check-equal? new-p gold)
        (check-equal? (hash-ref (hash-ref env 'x) 0) 'x_0_4)))))
