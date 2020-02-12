#lang rosette

(require "../c-ast.rkt"
         "../ast.rkt"
         "../compile-passes.rkt"
         "../utils.rkt"
         racket/trace)

(provide tensilica-g3-compile)

(define fresh-name (make-name-gen identity))

(define (make-prefix-id pre)
  (lambda (id)
    (c-id (string-append pre
                         (symbol->string id)))))

; Returns name for the register used to align loads to memory `id'.
(define align-reg-name (make-prefix-id "align_"))

; Returns the name for an input
(define input-name (make-prefix-id "input_"))

(define (vector->string vec)
  (string-join (vector->list (vector-map number->string vec))
               ", "
               #:before-first "{"
               #:after-last "}"))

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

  do-read)


; Generate an aligning load from `src' to `dst'.
; PDX_LAV_MXF32_XP(dst, (load-reg src) (xb_vecMxf32*)src, (end-start)*reg-size);
(define (gen-align-load dst src start end)
  (c-stmt
    (c-call (c-id "PDX_LAV_MXF32_XP")
            (list (c-id dst)
                  (align-reg-name src)
                  (c-cast "xb_vecMxf32*"
                          (c-id src))
                  (c-num (* (current-reg-size)
                            (- end start)))))))

; Generate aligning store into dst from src.
; PDX_SAV_MXF32_XP(src, (align-reg dst) (xb_vecMxf32*)dst, (end-start)*reg-size)
(define (gen-align-store dst src start end)
  (c-stmt
    (c-call (c-id "PDX_SAV_MXF32_XP")
          (list (c-id src)
                (align-reg-name dst)
                (c-cast "xb_vecMxf32*"
                        (c-id dst))
                (c-num (* (current-reg-size)
                          (- end start)))))))

(define (gen-shuffle inst)
  (match-define (vec-shuffle id idxs inps) inst)
  (assert (< (length inps) 3)
          (format
            "Target doesn't support shuffles with more than two inputs. Invalid instruction: ~a"
            inst))

  ; Call PDX_MOV_MX32_FROM_MXF32 on the inputs
  (define args
    (map (lambda (inp)
           (c-call (c-id "PDX_MOV_MX32_FROM_MXF32")
                   (list (c-id inp))))
         inps))

  (define func-name
    (case (length inps)
      [(1) "PDX_SHFL_MX32"]
      [(2) "PDX_SEL_MX32"]))

  (define shufl
    (c-deref (c-cast "xb_vecMx32 *" (c-id idxs))))

  (list
    (c-decl "xb_vecMxf32" #f (c-id id) #f #f)
    (c-assign (c-id id)
              (c-call (c-id "PDX_MOV_MXF32_FROM_MX32")
                      (list
                        (c-call (c-id func-name)
                                (append args
                                        (list shufl))))))))

; Generate code for a vector MAC. Since the target defines VMAC as a mutating
; function, we have to turn:
; out = vmac(acc, i1, i2)
; into:
; declare out = acc;
; vmac(out, i1, i2)
(define (gen-vecmac inst)
  (match-define (vec-app out 'vec-mac (list v-acc i1 i2)) inst)
  ; Declare out register.
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
              (c-id i1)
              (c-id i2)))))
  (list out-decl
        mac))


(define (tensilica-g3-compile p inputs outputs)
  ; Hoist all the constants to the top of the program.
  (define-values (consts rprog) (reorder-prog p))

  ; Add the 'zero' constant vector
  (define all-consts
    (cons (vec-const 'Z (make-vector 0 (current-reg-size)))
          consts))

  ; Track aligned loads from external memories.
  (define do-align-access (make-load-tracker))

  (define body-lst
    (for/list ([inst (prog-insts rprog)])
      (match inst
        [(vec-const id init)
         (error 'tensilica-g3-compile
                "Constanst should not be present in the body")]

        ; For each external declaration, we create a restricted pointer to the
        ; input for the function arguments of this kernel and an aligning
        ; register.
        [(vec-extern-decl id _)
         (let* ([inp-name (input-name id)]
                [decl
                  (c-decl "float*"
                          "__restrict"
                          (c-id id)
                          #f
                          inp-name)]
                [load-name (align-reg-name id)])

           ; If the extern is an input, we initialize the register for priming loads.
           (list
             decl
             (c-decl "valign" #f load-name #f #f)
             (if (findf (lambda (arg) (equal? id arg)) inputs)
               (c-assign load-name
                         (c-call (c-id "PDX_LA_MXF32_PP")
                                 (list
                                   (c-cast
                                     "xb_vecMxf32*"
                                     inp-name))))
               (list))))]

        ; Assume vec-load is only called for aligned loads out of external
        ; memories and generate aligning load instructions. If the memory
        ; is marked as an output, we generate a register with all zeros.
        [(vec-load dst src start end)
         (list
           (c-decl "xb_vecMxf32" #f (c-id dst) #f #f)
           (if (findf (lambda (arg) (equal? src arg)) outputs)
             (c-assign (c-id dst)
                       (c-bare (vector->string
                                 (make-vector (current-reg-size) 0))))
             (begin
               (do-align-access src start end)
               (gen-align-load dst src start end))))]

        [(vec-shuffle _ _ _)
         (gen-shuffle inst)]

        [(vec-app _ 'vec-mac _) (gen-vecmac inst)]

        [(or (vec-void-app _ _) (vec-app _ _ _)) (list)]

        [(vec-write dst src)
         (c-assign (c-id dst) (c-id src))]

        [(vec-store dst src start end)
         (if (findf (lambda (arg) (equal? dst arg)) outputs)
           (begin
             (do-align-access dst start end)
             (gen-align-store dst src start end))
           (list))]

        [_  (error 'tensilica-g3-compile
                   "Cannot compile instruction: ~a"
                   inst)])))

  (define body (c-seq (flatten body-lst)))

  (define decl-consts
    (c-seq
      (for/list ([inst all-consts])
        (match inst
          [(vec-const id init)
           (c-decl "int"
                   "__attribute__((section(\".dram0.data\")))"
                   (c-id id)
                   (current-reg-size)
                   (c-bare (vector->string init)))]
          [_ (error 'tensilica-g3-compile
                    "Expected vec-const. Received: ~a"
                    inst)]))))

  (c-ast
    (c-seq
      (list
        decl-consts
        (c-func-decl "void"
                     "kernel"
                     (map (lambda (arg) (cons "float" (c-id-id (input-name arg))))
                          (append inputs outputs))
                     body)))))

