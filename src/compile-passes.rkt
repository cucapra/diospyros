#lang rosette

(require "ast.rkt")

(define (pr v)
  (pretty-print v)
  v)

; Conversion to static single assignment form
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

; Get the destination id for an instruction
(define (get-id i)
  (match i
    [(vec-const id _) id]
    [(vec-shuffle id _ _) id]
    [(vec-select id _ _ _) id]
    [(vec-shuffle-set! id _ _) id]
    ; TODO: functions might mutate/write to args
    [(vec-app id _ _) id]
    [_ void]))

; Get the cannonical value for an instruction
(define (cannonicalize id-to-num i)
  (match i
    [(vec-extern-decl id size)
     ; External declarations should not be deduplicated, so keep id
     '(`vec-extern-decl id)]
    [(vec-const id init)
     '(`vec-const init)]
    [(vec-shuffle id idxs inp)
     '(`vec-shuffle (id-to-num idxs) (id-to-num inp))]
    [(vec-select id idxs inp1 inp2)
     '(`vec-select (id-to-num idxs) (id-to-num inp1) (id-to-num inp2))]
    [(vec-shuffle-set! out-vec idxs inp)
     '(vec-shuffle-set! (id-to-num idxs) (id-to-num inp))]
    [(vec-app id f inps)
     '(vec-app f (id-to-num inps))]))

; Local value numbering
(define (lvn p)
  ; Process last writes in reverse order
  (define seen (mutable-set))
  (define (last-write? inst)
    (define (check-id id)
      (cond
        [(set-member? seen id) #f]
        [else (set-add! seen id) #t]))

    (let ([id (get-id inst)])
      (and (not (void? id)) (check-id id))))

  ; Create a list of pairs: last write boolean and the instruction
  (define (fold-proc i acc) (cons (cons (last-write? i) i) acc))
  (define last-write-pairs (foldr fold-proc '() (prog-insts p)))

  ; Track numbers
  (define id-to-num (make-hash))
  (define cur-num -1)
  (define (new-num)
    (set! cur-num (add1 cur-num))
    cur-num)

  ; Add a id with a fresh number, returns the number
  (define (add-to-numbering id)
    (define n (new-num))
    (hash-set! id-to-num id n)
    n)

  ; Auxiliary maps
  (define value-to-num (make-hash))
  (define (lookup-value val)
    (hash-ref value-to-num val))
  (define (mapped-value? val)
    (hash-has-key? value-to-num val))

  ; Canonical id
  (define num-to-id (make-hash))

  ; Write all external declarations
  (for ([i (prog-insts p)])
    (match i  
      [(vec-extern-decl id _)
       (define new-num (add-to-numbering id))
       (hash-set! num-to-id new-num id)]
      [_ void]))

  ; Iterate over instructions with their last-write booleans
  (define new-insts
    (for/list ([pair last-write-pairs])
      (match-define (cons last-write i) pair)
      (define id (get-id i))
      (define cannonical (cannonicalize (curry hash-ref id-to-num) i))
      (pretty-print cannonical)
    
      ; Writes to destination and it's already mapped
      (define already-mapped
        (and (not (void? id)) (mapped-value? cannonical)))

      (cond
        ; Already computed this value
        [already-mapped
         (define num (lookup-value cannonical))
         (hash-set! id-to-num id num)
         (list `identity (hash-ref num-to-id num))]
        ; New, unseen value
        [else
         (define new-num (add-to-numbering id))
         (define new-id
           (if last-write id ; Keep last write for output
               (string->symbol (format "lvn_~a" new-num))))
       
         ; Save this new value number
         (hash-set! num-to-id new-num new-id)
         (hash-set! value-to-num cannonical new-num)

         (define (replace-arg arg-id)
           (hash-ref num-to-id (hash-ref id-to-num arg-id)))
       
         (match i  
           [(vec-extern-decl _ size)
            (vec-extern-decl new-id size)]
           [(vec-const _ init)
            (vec-const new-id init)]
           [(vec-shuffle _ idxs inp)
            (vec-shuffle new-id (replace-arg idxs) (replace-arg inp))]
           [(vec-select _ idxs inp1 inp2)
            (vec-select new-id
                        (replace-arg idxs)
                        (replace-arg inp1)
                        (replace-arg inp2))]
           [(vec-shuffle-set! _ idxs inp)
            (vec-shuffle-set! new-id (replace-arg idxs) (replace-arg inp))]
           [(vec-app _ f inps)
            (vec-app new-id f (map replace-arg inps))])])))
  
  (prog new-insts))
 
  

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
        (check-equal? (length (prog-insts (pr (const-elim example)))) 36))

      (test-case
       "local value numbering"
       (check-equal? (length (prog-insts (pr (lvn example)))) 44)))))
