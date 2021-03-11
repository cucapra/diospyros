#lang rosette

(require "backend-utils.rkt"
         "../c-ast.rkt"
         "../ast.rkt"
         "../compile-passes.rkt"
         "../utils.rkt"
         racket/trace)

(provide tensilica-g3-compile)

(define element-bytes 4)

(define fresh-name (make-name-gen identity))

(define (make-prefix-id pre)
  (lambda (id)
    (c-id (string-append pre
                         (symbol->string id)))))

; Returns name for the register used to align loads to memory `id'.
(define align-reg-name (make-prefix-id "align_"))

; Returns a name for a mutable pointer to an input
(define (mut-name id) (format "~a_mut" id))

; Returns the name for an input
(define input-name (make-prefix-id ""))

; Map of constant values to string representations
(define (make-const-map)

  (define constants (make-hash))

  (define (const-set id str)
    (hash-set! constants id str))

  (define (const-ref id)
   (hash-ref constants id))

  (define (const? id)
    (hash-has-key? constants id))

  (const-set `pi "PI")

  (values const-ref const?))

; Converts an array element to a string representation
(define (element->string const-ref const? v)
  (cond
    [(number? v) (number->string v)]
    [(const? v) (const-ref v)]
    [else (error 'tensilica-g3-compile
                 "Element type not handled: ~a"
                 v)]))

(define (vector->string const-ref const? vec)
  (string-join (vector->list (vector-map (curry element->string
                                                const-ref
                                                const?)
                                         vec))
               ", "
               #:before-first "{"
               #:after-last "}"))

(define (c-type type)
 (cond
   [(equal? type int-type) "int"]
   [(equal? type float-type) "float"]))

(define (deref-type type)
  (when (not (string-suffix? type " *"))
    (error 'tensilica-g3-compile
           "Unable to deference type: ~a"
           type))
  (string-trim type " *"))

(define (ref-type type)
  (format "~a *" type))

; Track the tag associated with vec-extern-decl. Maintain order.
(define (make-arg-tag-tracker)
  (define map (make-hash))
  (define ordered-args (box (list)))
  (define (get-arg-tag arg)
    (hash-ref map arg))
  (define (set-arg-tag! arg tag)
    (hash-set! map arg tag)
    (set-box! ordered-args
              (cons arg (unbox ordered-args))))
  (define (all-args)
    (reverse (unbox ordered-args)))
  (values get-arg-tag
          set-arg-tag!
          all-args))

; Track aligning loads from external memories.
(define (make-load-tracker)
  ; Track the next location available to be read from a memory.
  ; For example, if we have (A -> 0, B -> 4) and we read
  ; 2 values from B and 4 values from A, we'll have (A -> 4, B -> 6).
  (define loads-done (make-hash))

  ; Do a read from a memory
  (define (do-read mem start end)
    (when (not (hash-has-key? loads-done mem))
      (hash-set! loads-done mem 0))
    (assert (equal? (hash-ref loads-done mem)
                    start)
            (format "Out of order read from ~a. Available load location: ~a, Requested: ~a"
                    mem
                    (hash-ref loads-done mem)
                    start))
    (hash-set! loads-done mem end))

  (define (get-location mem)
     (hash-ref loads-done mem))

  (values do-read get-location))

; Track the C type of each id
(define (make-type-tracker)

  (define types (make-hash))

  (define (type-set id ty)
    (hash-set! types (id->string id) ty))

  (define (type-ref id)
   (hash-ref types (id->string id)))

  (values type-set type-ref))

; Generate an aligning load from `src' to `dst'.
; PDX_LAV_MXF32_XP(dst, (load-reg src) (xb_vecMxf32 *)src, (end-start)*reg-size);
(define (gen-align-load dst src start end)
  (c-stmt
    (c-call (c-id "PDX_LAV_MXF32_XP")
            (list (c-id dst)
                  (align-reg-name src)
                  (c-cast "xb_vecMxf32 *"
                          (c-id  (mut-name src)))
                  (c-num (* element-bytes
                            (- end start)))))))

; Generate aligning store into dst from src.
; PDX_SAV_MXF32_XP(src, (align-reg dst) (xb_vecMxf32 *)dst, (end-start)*reg-size)
(define (gen-align-store dst src start end)
  (c-stmt
    (c-call (c-id "PDX_SAV_MXF32_XP")
          (list (c-id src)
                (align-reg-name dst)
                (c-cast "xb_vecMxf32 *"
                        (c-id dst))
                (c-num (* element-bytes
                          (- end start)))))))

(define (gen-shuffle type-set type-ref inst)
  (match-define (vec-shuffle id idxs inps) inst)
  (assert (< (length inps) 3)
          (format
            "Target doesn't support shuffles with more than two inputs. Invalid instruction: ~a"
            inst))

  ; Call PDX_MOV_MX32_FROM_MXF32 on the inputs
  (define args
    (map (lambda (inp)
           (match (type-ref inp)
            ["int *" (c-deref (c-cast "xb_vecMx32 *" (c-id inp)))]
            ["float *" (c-deref (c-cast "xb_vecMxf32 *" (c-id inp)))]
            ["xb_vecMx32" (c-id inp)]
            ["xb_vecMxf32"
              (c-call (c-id "PDX_MOV_MX32_FROM_MXF32")
                      (list (c-id inp)))]
            [_ (error 'tensilica-g3-compile
                      "Missing type for id: ~a"
                      inp)]))
         inps))

  (define func-name
    (case (length inps)
      [(1) "PDX_SHFL_MX32"]
      [(2) "PDX_SEL_MX32"]))

  (define shufl
    (c-deref (c-cast "xb_vecMx32 *" (c-id idxs))))

  ; Selects require a reverse in input argument order
  (define ordered-args
    (case (length inps)
      [(1) (append args (list shufl))]
      [(2) (append (reverse args) (list shufl))]))

  (type-set id "xb_vecMxf32")
  (list
    (c-decl "xb_vecMxf32" #f (c-id id) #f #f)
    (c-assign (c-id id)
              (c-call (c-id "PDX_MOV_MXF32_FROM_MX32")
                      (list
                       (c-call (c-id func-name)
                               ordered-args))))))

(define (to-vecMxf2 type-ref inp)
  (match (type-ref inp)
    ["xb_vecMxf32" (c-id inp)]
    ["float *" (c-deref (c-cast "xb_vecMxf32 *" (c-id inp)))]
    ["xb_vecMx32"
      (c-call (c-id "PDX_MOV_MXF32_FROM_MX32")
              (list (c-id inp)))]
    [_ (error 'tensilica-g3-compile
              "Unable to convert to vector float type for id: ~a"
              inp)]))

; Generate code for a vector MAC. Since the target defines VMAC as a mutating
; function, we have to turn:
; out = vmac(acc, i1, i2)
; into:
; declare out = acc;
; vmac(out, i1, i2)
(define (gen-vecmac type-set type-ref inst)
  (match-define (vec-app out 'vec-mac (list v-acc i1 i2)) inst)
  ; Declare out register.
  (type-set out "xb_vecMxf32")
  (define out-decl
    (c-decl "xb_vecMxf32"
            #f
            (c-id out)
            #f
            (c-id v-acc)))

  (define mac
    (c-stmt
      (c-call (c-id "PDX_MULA_MXF32")
            (list
              (c-id out)
              (to-vecMxf2 type-ref i1)
              (to-vecMxf2 type-ref i2)))))
  (list out-decl
        mac))

; xb_vecMxf32 out;
; out = name(input0, input1, ...);
(define (gen-vecMxf2-pure-app name type-set type-ref out inputs)
  ; Convert inputs to xb_vecMxf32 if needed
  (define vec-inputs (map (curry to-vecMxf2 type-ref) inputs))

  ; Declare out register.
  (type-set out "xb_vecMxf32")
  (define out-decl
    (c-decl "xb_vecMxf32"
            #f
            (c-id out)
            #f
            (c-call (c-id name) vec-inputs)))
  (list out-decl))

(define (gen-vecMxf2-void-app name type-ref inputs)
  ; Convert inputs to xb_vecMxf32 if needed
  (define vec-inputs (map (curry to-vecMxf2 type-ref) inputs))

  (list
    (c-stmt
      (c-call (c-id name) vec-inputs))))

(define (tensilica-g3-compile fn-name p)
  ; Hoist all the constants to the top of the program.
  (define-values (consts rprog) (reorder-prog p))

  ; Track aligned loads from external memories.
  (define-values (do-align-access get-align-loc) (make-load-tracker))

  ; Track inputs and outputs
  (define-values (get-arg-tag set-arg-tag! all-args)
    (make-arg-tag-tracker))
  (define (arg-type arg)
    (define tag (get-arg-tag arg))
    (cond
      [(equal? tag input-array-tag) "float *"]
      [(equal? tag input-scalar-tag) "float"]
      [(equal? tag output-tag) "float *"]))

  ; Track types for necessary casts
  (define-values (type-set type-ref) (make-type-tracker))

  ; Add the 'zero' constant vector
  (define all-consts
    (cons (vec-const 'Z (make-vector (current-reg-size) 0) int-type)
          consts))

  (define-values (const-ref const?) (make-const-map))

  (define decl-consts
    (c-seq
      (for/list ([inst all-consts])
        (match inst
          [(vec-const id init type)
           (define c-ty (c-type type))
           (type-set id (~a c-ty " *"))
           (c-decl c-ty
                   "__attribute__((section(\".dram0.data\")))"
                   (c-id id)
                   (current-reg-size)
                   (c-bare (vector->string const-ref const? init)))]
          [_ (error 'tensilica-g3-compile
                    "Expected vec-const. Received: ~a"
                    inst)]))))

  (define body-lst
    (for/list ([inst (prog-insts rprog)])
      (match inst

        [(let-bind id expr type)
         (define c-ty (c-type type))
         (type-set id c-ty)
         (c-decl c-ty #f (c-id id) #f (c-bare expr))]

        [(array-get id arr idx)
         (define ty (type-ref arr))
         (if (string-suffix? ty " *")
          (begin
            (define c-ty (deref-type ty))
            (type-set id c-ty)
            (c-decl c-ty #f (c-id id) #f (c-bare (format "~a[~a]" arr idx))))
          (begin
            (type-set id ty)
            (c-decl ty #f (c-id id) #f (c-bare (format "~a" arr)))))]

        [(scalar-binop id op lhs rhs)
         (define c-ty-l (type-ref lhs))
         (define c-ty-r (type-ref rhs))
         (when (not (equal? c-ty-l c-ty-r))
          (error 'tensilica-g3-compile
                "Types for LHS and RHS in scalar binop do not match ~a ~a"
                c-ty-l
                c-ty-r))
         (type-set id c-ty-l)
         (c-decl c-ty-l #f (c-id id) #f
                 (c-bare (format "~a ~a ~a" lhs op rhs)))]

        [(scalar-ternop id i t e)
         (define c-ty-i (type-ref i))
         (define c-ty-t (type-ref t))
         (define c-ty-e (type-ref e))
         (when (not (equal? c-ty-t c-ty-e))
          (error 'tensilica-g3-compile
                "Types for if and else in scalar ternop do not match ~a ~a"
                c-ty-t
                c-ty-e))
         (type-set id c-ty-t)
         (c-decl c-ty-t #f (c-id id) #f
                 (c-bare (format "~a ? ~a : ~a" i t e)))]

        [(scalar-unnop id op v)
         (define c-ty-v (type-ref v))
         (type-set id c-ty-v)
         (define bare
          (match op
            ['neg (format "(-(~a))" v)]
            ['sgn (format "((~a > 0) - (~a < 0))" v v)]
            [else (format "~a(~a)" op v)]))

         (c-decl c-ty-v #f (c-id id) #f
                 (c-bare bare))]

        [(vec-lit id elems type)
         (define c-ty (c-type type))
         (define tens-ty (match (ref-type c-ty)
           ["int *" "xb_vecMx32 *"]
           ["float *" "xb_vecMxf32 *"]))

         (define id-tmp (format "~a_tmp" id))
         (type-set id-tmp (ref-type c-ty))
         (type-set id (deref-type tens-ty))

         (list
          (c-decl c-ty #f (c-id id-tmp) (length elems)
                 (c-bare (format "{~a}"
                                 (string-join
                                   (map symbol->string elems) ", "))))
          (c-decl (deref-type tens-ty) #f (c-id id) #f
            (c-deref (c-cast tens-ty (c-id id-tmp)))))]

        [(vec-const _ _ _)
         (error 'tensilica-g3-compile
                "Constants should not be present in the body")]

        [(vec-decl id _)
         (type-set id "xb_vecMxf32")
         (c-decl "xb_vecMxf32" #f (c-id id) #f #f)]

        ; For each external declaration, we create a restricted pointer to the
        ; input for the function arguments of this kernel and an aligning
        ; register.
        [(vec-extern-decl id size tag)

         ; Aligning loads bump the pointer, so make a mutable copy
         (set-arg-tag! id tag)
         (define ty (arg-type id))
         (type-set id ty)
         (define inp-name (input-name id))
         (define restrict-decl
           (c-decl ty
                   "__restrict"
                   (c-id (mut-name id))
                   #f
                   inp-name))
         (define load-name (align-reg-name id))

         (cond
          [(equal? tag input-scalar-tag) (list)]
          [(equal? tag input-array-tag)
           ; If the extern is an input, we initialize the register for priming
           ; loads.
           (list
             restrict-decl
             (c-decl "valign" #f load-name #f #f)
             (c-assign load-name
                       (c-call (c-id "PDX_LA_MXF32_PP")
                               (list
                                  (c-cast "xb_vecMxf32 *" inp-name)))))]
          [(equal? tag output-tag)
           (list
             restrict-decl
             (c-decl "valign" #f load-name #f #f))])]

        ; Assume vec-load is only called for aligned loads out of external
        ; memories and generate aligning load instructions. If the memory
        ; is marked as an output, we generate a register with all zeros.
        [(vec-load dst src start end)
         (type-set dst "xb_vecMxf32")
         (list
           (c-decl "xb_vecMxf32" #f (c-id dst) #f #f)
           (if (equal? (get-arg-tag src) output-tag)
             (c-assign (c-id dst)
                       (c-deref (c-cast "xb_vecMxf32 *"
                                        (c-id 'Z))))
             (begin
               (do-align-access src start end)
               (gen-align-load dst src start end))))]

        [(vec-shuffle _ _ _)
         (gen-shuffle type-set type-ref inst)]

        [(vec-app _ 'vec-mac _) (gen-vecmac type-set type-ref inst)]

        [(vec-app out 'vec-mul inputs)
         (gen-vecMxf2-pure-app "PDX_MUL_MXF32" type-set type-ref out inputs)]

        [(vec-app out 'vec-add inputs)
         (gen-vecMxf2-pure-app "PDX_ADD_MXF32" type-set type-ref out inputs)]

        [(vec-app out 'vec-minus inputs)
         (gen-vecMxf2-pure-app "PDX_SUB_MXF32" type-set type-ref out inputs)]

        [(vec-app out 'vec-s-div inputs)
         (gen-vecMxf2-pure-app "PDX_DIV_MXF32" type-set type-ref out inputs)]

        [(vec-app out 'vec-cos inputs)
         (gen-vecMxf2-pure-app "cos_MXF32" type-set type-ref out inputs)]

        [(vec-app out 'vec-sin inputs)
         (gen-vecMxf2-pure-app "sin_MXF32" type-set type-ref out inputs)]

        [(vec-void-app 'vec-negate inputs)
         (gen-vecMxf2-pure-app "PDX_NEG_MXF32" type-set type-ref (first inputs) inputs)]

        [(vec-app out 'vec-neg inputs)
         (gen-vecMxf2-pure-app "PDX_NEG_MXF32" type-set type-ref out inputs)]

        [(vec-app out 'vec-sqrt inputs)
         (gen-vecMxf2-pure-app "PDX_SQRT_MXF32" type-set type-ref out inputs)]

        [(vec-app out 'vec-div inputs)
         (gen-vecMxf2-pure-app "PDX_DIV_MXF32" type-set type-ref out inputs)]

        [(vec-app out 'vec-mul-sgn inputs)
         (gen-vecMxf2-pure-app "PDX_MULSGN_32" type-set type-ref out inputs)]

        [(vec-app out 'vec-sgn inputs)
          ; Special case for vector sgn
          (define v (to-string (to-vecMxf2 type-ref (first inputs))))

          ; Declare out register.
          (type-set out "xb_vecMxf32")
          (define out-decl
            (c-decl "xb_vecMxf32"
                    #f
                    (c-id out)
                    #f
                    (c-bare (format "PDX_DIV_MXF32(~a, PDX_ABS_MXF32(~a));" v v))))
          (list out-decl)]

        [(or (vec-void-app _ _) (vec-app _ _ _))
          (error 'tensilica-g3-compile
                   "Cannot compile app instruction: ~a"
                   inst)]

        [(vec-write dst src)
         (c-assign (c-id dst) (c-id src))]

        [(vec-store dst src start end)
         (if (equal? output-tag (get-arg-tag dst))
           (if (equal? 1 (- end start))
             ; Special case: just write the pointer
            (c-bare (format "*~a = ~a;" dst src))
           (begin
             (do-align-access dst start end)
             (gen-align-store dst src start end)))
           (list))]

        [_  (error 'tensilica-g3-compile
                   "Cannot compile instruction: ~a"
                   inst)])))

  ; Flush output loads
  (define output-flushes
    (for/list ([a (all-args)]
      #:when (equal? output-tag (get-arg-tag a)))
      (c-stmt
        (c-call (c-id "PDX_SAPOS_MXF32_FP")
                (list (align-reg-name a)
                      (c-cast "xb_vecMxf32 *"
                              (c-id a)))))))

  (define body (c-seq (flatten (list body-lst output-flushes))))

  (c-ast
    (c-seq
      (list
        ; Include a comment with git info
        (if (not (suppress-git-info))
          (git-info-comment)
          (c-empty))
        decl-consts
        (c-func-decl "void"
                     fn-name
                     (map (lambda (arg) (cons (arg-type arg) (c-id-id (input-name arg))))
                          (all-args))
                     body)))))
