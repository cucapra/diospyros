#lang rosette

(require racket/generator
         threading
 ;        rosette/lib/value-browser
         "ast.rkt"
         "prog-sketch.rkt"
         "configuration.rkt"
         "interp.rkt"
         "compile-passes.rkt"
         "uninterp-fns.rkt"
         "utils.rkt")

(provide (all-defined-out))

; Generate string for keys that have different values.
(define (show-diff env1 env2 keys)
  (string-join
    (for/list ([key keys])
      (if (equal? (hash-ref env1 key)
                  (hash-ref env2 key))
        ""
        (~a key " differs:\n"
            (hash-ref env1 key)
            "\n\n"
            (hash-ref env2 key))))
    "\n"))

; For namespace hacking
(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define (symbol-append s1 s2)
  (string->symbol
    (string-append (symbol->string s1) "$" (number->string s2))))

(define (verify-spec-prog spec-str
                          prog
                          #:fn-map [fn-map (make-hash)])

  (define-values (prog-ins prog-outs)
    (get-inputs-and-outputs prog))

  ; Transform a list of vec-extern-decl to a set with (id size).
  (define (to-sizes lst)
    (define (get-id-size decl)
      (cons (vec-extern-decl-id decl)
            (vec-extern-decl-size decl)))
     (map get-id-size lst))

  ; Constrain inputs
  (define (assume-input-range i)
    (assert (and (< i 100)
                 (> i -100))))

  ; Generate symbolic inputs for prog
  (define init-env
    (append
      (~> prog-ins
          to-sizes
          (map (lambda (decl)
                 ; Namespace hacking for binding symbolic constants in the
                 ; spec as well
                 (let* ([name (car decl)]
                        [size (cdr decl)]
                        [val (make-symbolic-v-list size name)])
                  (parameterize ([current-namespace ns])
                    (for ([i (range size)])
                      (assume-input-range (v-list-get val i))
                      (eval `(define ,(symbol-append name i) ,(v-list-get val i)))))
                  (cons name val)))
               _))
      (~> prog-outs
          to-sizes
          (map (lambda (decl)
                 (cons (car decl)
                       (make-v-list-zeros (cdr decl))))
               _))))

  ; Add rosette uninterp function app to namespace
  (parameterize ([current-namespace ns])
      (eval `(define ,`app , (lambda vs (apply (first vs) (rest vs))))))

  (define (interp-and-env prog init-env)
    (define-values (env _)
      (interp prog
              init-env
              #:fn-map fn-map))
    env)

  ; Eval spec after namespace mucking
  (define spec (align-to-reg-size (eval spec-str ns)))

  (define prog-env (interp-and-env prog init-env))
  (define (get-and-align out)
    (align-to-reg-size (hash-ref prog-env (car out))))
  (define flatten-prog-outputs
    (flatten (map get-and-align (to-sizes (reverse prog-outs)))))

  (assert (equal? (length spec) (length flatten-prog-outputs)))

  (define model
    (verify
      #:assume (begin
                  (for ([a (uninterp-fn-assumptions)])
                    (assert a)))
      #:guarantee (assert (equal? spec
                                  flatten-prog-outputs))))

  (if (not (unsat? model))
    (pretty-display (format "Translation validation unsuccessful. Spec:\n ~a \nProg:\n ~a"
                        spec
                        flatten-prog-outputs))
    (pretty-display (format "~aTranslation validation successful! ~a elements equal~a\n"
                            "\x1B[32m"    ; Green in terminal
                            (length spec)
                            "\x1B[0m")))  ; Back to black
  model)

; Verify input-output behavior of programs.
(define (verify-prog spec
                     sketch
                     #:fn-map [fn-map (make-hash)])

  (define-values (spec-ins spec-outs)
    (get-inputs-and-outputs spec))

  (define-values (sketch-ins sketch-outs)
    (get-inputs-and-outputs sketch))

  ; Transform a list of vec-extern-decl to a set with (id size).
  (define (to-size-set lst)
    (define (get-id-size decl)
      (cons (vec-extern-decl-id decl)
            (vec-extern-decl-size decl)))
    (list->set (map get-id-size lst)))

  ; Check spec and sketch have the same set of inputs and outputs.
  (let ([ins-diff (set-symmetric-difference
                    (to-size-set spec-ins)
                    (to-size-set sketch-ins))]
        [outs-diff (set-symmetric-difference
                     (set-map (to-size-set spec-outs) car)
                     (set-map (to-size-set sketch-outs) car))])

    (assert (set-empty? ins-diff)
            (~a "VERIFY-PROG: Input mismatch. " ins-diff))
    (assert (set-empty? outs-diff)
            (~a "VERIFY-PROG: Output mismatch. " outs-diff)))

  ; Generate symbolic inputs for spec and sketch.
  (define init-env
    (append
      (~> spec-ins
          to-size-set
          set->list
          (map (lambda (decl)
                 (cons (car decl)
                       (make-symbolic-v-list (cdr decl))))
               _))
      (~> spec-outs
          to-size-set
          set->list
          (map (lambda (decl)
                 (cons (car decl)
                       (make-v-list-zeros (cdr decl))))
               _))))

  (define (interp-and-env prog init-env)
    (define-values (env _)
      (interp prog
              init-env
              #:fn-map fn-map))
    env)

  (define spec-env (interp-and-env spec init-env))
  (define sketch-env (interp-and-env sketch init-env))

  ; Outputs from sketch are allowed to be bigger than the spec. Only consider
  ; elements upto the size in the spec for each output.
  (define assertions
    (andmap (lambda (decl)
              (let ([id (car decl)]
                    [size (cdr decl)])
                (equal? (take (hash-ref spec-env id) size)
                        (take (hash-ref sketch-env id) size))))
            (set->list (to-size-set spec-outs))))

  (define model
    (verify
      ; Since get-outs extracts outputs in the same order for both, we can
      ; just check for list equality.
      (assert assertions)))

  (when (not (unsat? model))
    (pretty-display (~a "Verification unsuccessful. Environment differences:\n"
                      (show-diff
                        (interp-and-env spec (evaluate init-env model))
                        (interp-and-env sketch (evaluate init-env model))
                        (map vec-extern-decl-id spec-outs)))))

  model)

; Convinience function to turn a generator into a producer that can be
; iterated over.
(define (sol-producer model-generator)
  (define (is-done? model cost)
    (void? model))
  (in-producer model-generator is-done?))
