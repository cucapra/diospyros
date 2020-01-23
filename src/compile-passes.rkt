#lang rosette

(require "ast.rkt")

(define (pr v)
  (pretty-print v)
  v)

(define (ssa p)
  (define name-map (make-hash))

  (define cur-var-num -1)
  (define (new-var)
    (set! cur-var-num (add1 cur-var-num))
    (string->symbol (string-append "%"
                                   (number->string cur-var-num))))

  (define (rename-binding id)
    ; If `id` was previously defined, map it to a fresh var.
    (let ([new-name (new-var)])
      (hash-set! name-map id new-name)
      new-name))

  (define (rename-use id)
    (hash-ref name-map id))

  (define new-insts
    (for/list ([inst (prog-insts p)])
      (match inst
        [(vec-extern-decl id _)
         (hash-set! name-map id id)
         inst]
        [(vec-const id init)
         (vec-const (rename-binding id) init)]
        [(vec-shuffle id idxs inp)
         (vec-shuffle (rename-binding id)
                      (rename-use idxs)
                      (rename-use inp))]
        [(vec-select id idxs inp1 inp2)
         (vec-select (rename-binding id)
                     (rename-use idxs)
                     (rename-use inp1)
                     (rename-use inp2))]
        [(vec-shuffle-set! out-vec idxs inp)
         (vec-shuffle-set! (rename-use out-vec)
                           (rename-use idxs)
                           (rename-use inp))]
        [(vec-app id f args)
         (vec-app (rename-binding id)
                  f
                  (map rename-use args))]
        [_ (error 'ssa (~a "NYI " inst))])))

  (prog new-insts))


; Eliminate variables mapping to the same constants.
(define (const-elim p)
  ; Map vector const to canonical name.
  (define const-map (make-hash))
  ; Map renamed variable id to canonical variable id.
  (define name-map (make-hash))
  (define (rename id)
    (hash-ref name-map id))

  (define new-insts
    (for/list ([inst (prog-insts p)])
      (match inst
        [(vec-const id init)
         ; Remove the declaration if it's already been defined and add mapping
         ; to name-map.
         (if (hash-has-key? const-map init)
           (begin
             (hash-set! name-map id (hash-ref const-map init))
             (list))
           (begin
             (hash-set! name-map id id)
             (hash-set! const-map init id)
             (list inst)))]
        [(vec-extern-decl id _)
         (hash-set! name-map id id)
         (list inst)]
        [(vec-shuffle id idxs inp)
         (hash-set! name-map id id)
         (list (vec-shuffle id (rename idxs) (rename inp)))]
        [(vec-select id idxs inp1 inp2)
         (hash-set! name-map id id)
         (list (vec-select id (rename idxs) (rename inp1) (rename inp2)))]
        [(vec-shuffle-set! out-vec idxs inp)
         (list (vec-shuffle-set! (rename out-vec) (rename idxs) (rename inp)))]
        [(vec-app id f args)
         (hash-set! name-map id id)
         (list (vec-app id f (map rename args)))]
        [inst (list inst)])))

  (prog (flatten new-insts)))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (define example
    (prog
      (list
        (vec-extern-decl 'A 6)
        (vec-extern-decl 'B 9)
        (vec-extern-decl 'C 6)
        (vec-const 'Z '#(0))
        (vec-const 'shuf0-0 '#(3 5 1 2))
        (vec-const 'shuf1-0 '#(0 8 4 8))
        (vec-const 'shuf2-0 '#(3 5 1 2))
        (vec-select 'reg-A 'shuf0-0 'A 'Z)
        (vec-select 'reg-B 'shuf1-0 'B 'Z)
        (vec-shuffle 'reg-C 'shuf2-0 'C)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-0 'out)
        (vec-const 'shuf0-1 '#(4 3 2 0))
        (vec-const 'shuf1-1 '#(3 2 7 2))
        (vec-const 'shuf2-1 '#(3 5 1 2))
        (vec-select 'reg-A 'shuf0-1 'A 'Z)
        (vec-select 'reg-B 'shuf1-1 'B 'Z)
        (vec-shuffle 'reg-C 'shuf2-1 'C)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-1 'out)
        (vec-const 'shuf0-2 '#(3 5 1 2))
        (vec-const 'shuf1-2 '#(1 6 5 6))
        (vec-const 'shuf2-2 '#(4 3 2 0))
        (vec-select 'reg-A 'shuf0-2 'A 'Z)
        (vec-select 'reg-B 'shuf1-2 'B 'Z)
        (vec-shuffle 'reg-C 'shuf2-2 'C)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-2 'out)
        (vec-const 'shuf0-3 '#(1 6 5 6))
        (vec-const 'shuf1-3 '#(3 2 7 2))
        (vec-const 'shuf2-3 '#(0 1 4 5))
        (vec-select 'reg-A 'shuf0-3 'A 'Z)
        (vec-select 'reg-B 'shuf1-3 'B 'Z)
        (vec-shuffle 'reg-C 'shuf2-3 'C)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-3 'out)
        (vec-const 'shuf0-4 '#(0 0 4 4))
        (vec-const 'shuf1-4 '#(0 1 4 5))
        (vec-const 'shuf2-4 '#(0 1 4 5))
        (vec-select 'reg-A 'shuf0-4 'A 'Z)
        (vec-select 'reg-B 'shuf1-4 'B 'Z)
        (vec-shuffle 'reg-C 'shuf2-4 'C)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-4 'out))))
  (run-tests
    (test-suite
      "compiler passes"
      (test-case
        "const-elim remove instructions"
        (check-equal? (length (prog-insts (pr (const-elim example)))) 36)))))
