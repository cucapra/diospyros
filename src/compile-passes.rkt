#lang rosette

(require "ast.rkt")

(provide ssa
         const-elim
         reorder-prog
         get-inputs-and-outputs
         lvn)

(define (pr v)
  (pretty-print v)
  v)

; Force program to have the order:
; 1. Externs.
; 2. Aligned loads.
; 3. Constant declarations.
; 4. Remaining computation.
(define (reorder-prog p)
  ; Externs
  (define externs (list))
  (define (add-extern c)
    (set! externs (cons c externs)))
  ; Loads
  (define loads (list))
  (define (add-load c)
    (set! loads (cons c loads)))
  ; Constants
  (define consts (list))
  (define (add-const c)
    (set! consts (cons c consts)))

  ; Walk over instructions and remove constants.
  (define new-insts
    (for/list ([inst (prog-insts p)])
      (match inst
        [(vec-const _ _ _)
         (add-const inst)
         (list)]
        [(vec-load _ _ _ _)
         (add-load inst)
         (list)]
        [(vec-extern-decl _ _ _)
         (add-extern inst)
         (list)]
        [inst (list inst)])))

  (values
    (reverse consts)
    (prog
      (append
        (reverse externs)
        (reverse loads)
        (flatten new-insts)))))


; Returns two values:
; 1. List all vec-extern-decl tagged with input-tag.
; 2. List all vec-extern-decl tagged with output-tag.
(define (get-inputs-and-outputs prog)
  (define ins (list))
  (define outs (list))

  (for ([inst (prog-insts prog)])
    (match inst
      [(vec-extern-decl id size tag)
       (cond
         [(equal? tag input-tag)
          (set! ins (cons inst ins))]
         [(equal? tag output-tag)
          (set! outs (cons inst outs))]
         [else (error 'get-inputs-and-outputs
                      "Unknown tag: ~a"
                      tag)])]
      [_ (void)]))

  (values ins outs))

; Conversion to static single assignment form
(define (ssa p)
  (define name-map (make-hash))

  (define cur-var-num -1)
  (define (new-var)
    (set! cur-var-num (add1 cur-var-num))
    (string->symbol (string-append "v_"
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
        [(or (vec-decl id _) (vec-extern-decl id _ _))
         (hash-set! name-map id id)
         inst]
        [(vec-const id init type)
         (vec-const (rename-binding id) init type)]
        [(vec-shuffle id idxs inps)
         (vec-shuffle (rename-binding id)
                      (rename-use idxs)
                      (map rename-use inps))]
        [(vec-shuffle-set! out-vec idxs inp)
         (vec-shuffle-set! (rename-use out-vec)
                           (rename-use idxs)
                           (rename-use inp))]
        [(vec-app id f args)
         (vec-app (rename-binding id)
                  f
                  (map rename-use args))]
        [(vec-void-app f args)
         (vec-void-app f (map rename-use args))]
        [(vec-load dest-id src-id start end)
         (vec-load (rename-binding dest-id)
                   (rename-use src-id)
                   start
                   end)]
        [(vec-store dest-id src-id start end)
         (vec-store (rename-use dest-id)
                    (rename-use src-id)
                    start
                    end)]
        [(vec-write dst src)
         (vec-write (rename-use dst)
                    (rename-use src))]
        [(let-bind id expr type)
         (let-bind (rename-binding id) expr type)]

        [(array-get id arr-id idx)
         (array-get (rename-binding id) (rename-use arr-id) idx)]

        [(vec-lit id elems type)
         (vec-lit (rename-binding id) (map rename-use elems) type)]

        [(scalar-binop id op l r)
         (scalar-binop (rename-binding id)
                       op
                       (rename-use l)
                       (rename-use r))]
        [(scalar-unnop id op v)
         (scalar-unnop (rename-binding id)
                       op
                       (rename-use v))]

        [_ (error 'ssa (~a "not yet implemented" inst))])))

  (prog new-insts))


; Eliminate variables mapping to the same constants.
(define (const-elim p)
  ; Map vector const to canonical name.
  (define const-map (make-hash))
  ; Map renamed variable id to canonical variable id.
  (define name-map (make-hash))
  (define (add-binding! id)
    (hash-set! name-map id id)
    id)
  (define (rename id)
    (hash-ref name-map id))

  (define new-insts
    (for/list ([inst (prog-insts p)])
      (match inst
        [(vec-const id init type)
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
        [(or (vec-decl id _) (vec-extern-decl id _ _))
         (hash-set! name-map id id)
         (list inst)]
        [(vec-lit id elems type)
         (add-binding! id)
         (list inst)]
        [(array-get id arr-id idx)
         (add-binding! id)
         (list inst)]
        [(let-bind id expr type)
         (add-binding! id)
         (list inst)]
        [(vec-shuffle id idxs inps)
         (hash-set! name-map id id)
         (list (vec-shuffle id (rename idxs) (map rename inps)))]
        [(vec-shuffle-set! out-vec idxs inp)
         (list (vec-shuffle-set! (rename out-vec) (rename idxs) (rename inp)))]
        [(vec-app id f args)
         (hash-set! name-map id id)
         (list (vec-app id f (map rename args)))]
        [(vec-void-app f args)
        (list (vec-void-app f (map rename args)))]
        [inst (list inst)])))

  (prog (flatten new-insts)))

; Get the destination id for an instruction
(define (get-id i)
  (match i
    [(vec-const id _ _) id]
    [(vec-shuffle id _ _) id]
    [(vec-shuffle-set! id _ _) id]
    ; TODO: functions might mutate/write to args
    [(vec-app id _ _) id]
    [(let-bind id expr type)
     id]
    [(array-get id arr-id idx)
     id]
    [(vec-lit id elems type)
     id]
    [(scalar-binop id op l r)
     id]
    [(scalar-unnop id op v)
     id]
    [_ void]))

; Get the cannonical value for an instruction
(define (cannonicalize id-to-num i)
  (match i
    [(or (vec-decl id size) (vec-extern-decl id size _))
     ; Declarations should not be deduplicated, so keep id
     (list `vec-decl id)]
    [(vec-const id init type)
     (list `vec-const init type)]
    [(vec-shuffle id idxs inps)
     (list `vec-shuffle (id-to-num idxs) (map id-to-num inps))]
    [(vec-shuffle-set! out-vec idxs inp)
     (list `vec-shuffle-set! (id-to-num idxs) (id-to-num inp))]
    [(vec-app id f inps)
     (list `vec-app f (map id-to-num inps))]
    [(vec-void-app f inps)
     (list `vec-void-app f (map id-to-num inps))]
    [(vec-load dest-id src-id start end)
     (list `vec-load (id-to-num dest-id) (id-to-num src-id) start end)]
    [(vec-store dest-id src-id start end)
     (list `vec-store (id-to-num dest-id) (id-to-num src-id) start end)]
    [(vec-write dst src)
     (list `vec-write (id-to-num dst) (id-to-num src))]
    [(let-bind id expr type)
     (list `let-bind expr type)]
    [(array-get id arr-id idx)
     (list `array-get
           (id-to-num arr-id)
           idx)]
    [(vec-lit id elems type)
     (list `vec-lit
           (map id-to-num elems)
           type)]
    [(scalar-binop id op l r)
     (list `scalar-binop
           op
           (id-to-num l)
           (id-to-num r))]
    [(scalar-unnop id op v)
     (list `scalar-unnop
            op
            (id-to-num v))]))

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

  ; Write all declarations
  (for ([i (prog-insts p)])
    (match i
      [(or (vec-decl id _) (vec-extern-decl id _ _))
       (define new-num (add-to-numbering id))
       (hash-set! num-to-id new-num id)]
      [_ void]))

  ; Iterate over instructions with their last-write booleans
  (define new-insts
    (for/list ([pair last-write-pairs])
      (match-define (cons last-write i) pair)
      (define id (get-id i))
      (define cannonical (cannonicalize (curry hash-ref id-to-num) i))

      ; Writes to destination and it's already mapped
      (define already-mapped
        (and (not (void? id)) (mapped-value? cannonical)))

      (cond
        ; Already computed this value
        [already-mapped
         (define num (lookup-value cannonical))
         (hash-set! id-to-num id num)
         (list)]
        ; New, unseen value
        [else
         (define new-num (add-to-numbering id))
         (define new-id
           (if (or last-write (vec-extern-decl? i))
               id ; Keep last write for extern decl or output
               (string->symbol (format "lvn_~a" new-num))))

         ; Save this new value number
         (hash-set! num-to-id new-num new-id)
         (hash-set! value-to-num cannonical new-num)

         (define (replace-arg arg-id)
           (hash-ref num-to-id (hash-ref id-to-num arg-id)))

         (match i
           [(vec-decl _ size)
            (vec-decl new-id size)]
           [(vec-extern-decl id size tag)
            (vec-extern-decl id size tag)]
           [(vec-const _ init type)
            (vec-const new-id init type)]
           [(vec-shuffle _ idxs inps)
            (vec-shuffle new-id (replace-arg idxs) (map replace-arg inps))]
           [(vec-shuffle-set! _ idxs inp)
            (vec-shuffle-set! new-id (replace-arg idxs) (replace-arg inp))]
           [(vec-app _ f inps)
            (vec-app new-id f (map replace-arg inps))]
           [(vec-void-app f inps)
            (vec-void-app f (map replace-arg inps))]
           [(vec-load dest-id src-id start end)
            (vec-load (replace-arg dest-id)
                      (replace-arg src-id)
                      start
                      end)]
           [(vec-store dest-id src-id start end)
            (vec-store (replace-arg dest-id)
                       (replace-arg src-id)
                       start
                       end)]
           [(vec-write dst src)
            (vec-write (replace-arg dst)
                       (replace-arg src))]
           [(let-bind _ expr type)
            (let-bind new-id expr type)]
           [(array-get _ arr-id idx)
            (array-get new-id (replace-arg arr-id) idx)]
           [(vec-lit _ elems type)
            (vec-lit new-id (map replace-arg elems) type)]
           [(scalar-binop id op l r)
            (scalar-binop new-id op (replace-arg l) (replace-arg r))]
           [(scalar-unnop _ op v)
            (scalar-unnop new-id op (replace-arg v))])])))

  (prog (flatten new-insts)))


(module+ test
  (require rackunit
           rackunit/text-ui)
  (define example
    (prog
      (list
        (vec-extern-decl 'A 6 input-tag)
        (vec-extern-decl 'B 9 input-tag)
        (vec-extern-decl 'C 6 output-tag)
        (vec-const 'Z '#(0) float-type)
        (vec-const 'shuf0-0 '#(3 5 1 2) int-type)
        (vec-const 'shuf1-0 '#(0 8 4 8) int-type)
        (vec-const 'shuf2-0 '#(3 5 1 2) int-type)
        (vec-shuffle 'reg-A 'shuf0-0 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-0 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-0 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-0 'out)
        (vec-const 'shuf0-1 '#(4 3 2 0) int-type)
        (vec-const 'shuf1-1 '#(3 2 7 2) int-type)
        (vec-const 'shuf2-1 '#(3 5 1 2) int-type)
        (vec-shuffle 'reg-A 'shuf0-1 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-1 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-1 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-1 'out)
        (vec-const 'shuf0-2 '#(3 5 1 2) int-type)
        (vec-const 'shuf1-2 '#(1 6 5 6) int-type)
        (vec-const 'shuf2-2 '#(4 3 2 0) int-type)
        (vec-shuffle 'reg-A 'shuf0-2 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-2 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-2 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-2 'out)
        (vec-const 'shuf0-3 '#(1 6 5 6) int-type)
        (vec-const 'shuf1-3 '#(3 2 7 2) int-type)
        (vec-const 'shuf2-3 '#(0 1 4 5) int-type)
        (vec-shuffle 'reg-A 'shuf0-3 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-3 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-3 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-3 'out)
        (vec-const 'shuf0-4 '#(0 0 4 4) int-type)
        (vec-const 'shuf1-4 '#(0 1 4 5) int-type)
        (vec-const 'shuf2-4 '#(0 1 4 5) int-type)
        (vec-shuffle 'reg-A 'shuf0-4 (list 'A 'Z))
        (vec-shuffle 'reg-B 'shuf1-4 (list 'B 'Z))
        (vec-shuffle 'reg-C 'shuf2-4 (list 'C))
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-shuffle-set! 'C 'shuf2-4 'out))))
  (run-tests
    (test-suite
      "compiler passes"

      (test-case
        "const-elim remove instructions"
        (check-equal? (length (prog-insts (const-elim example))) 36))

      (test-case
       "local value numbering"
       (check-equal? (length (prog-insts (lvn example))) 44)))))
