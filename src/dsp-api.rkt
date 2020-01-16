#lang racket

(provide (all-defined-out))

(define reg-size 4)
(define element-size 4)

(define element-ty "float")
(define vector-ty "xb_vecMxf32")
(define shuffle-idx-ty "xb_vecMx32")

(define (pointer-to ty) (format "(~a *)" ty))

(define (emit-memory id size)
    (format "~a ~a[~a]" element-ty id size))

; A pair: the align variable id and the command
(define (emit-align id)
  (define align-id (~a "align" id))
  (define cmd
    (format "valign ~a = PDX_LA_MXF32_PP(~a~a)"
            align-id (pointer-to vector-ty) id))
  (cons align-id cmd))

(define (emit-load dest id size align)
  (define cmd
    (format "PDX_LAV_MXF32_XP(~a, ~a, ~a~a, ~a)"
            dest align (pointer-to vector-ty) id size))
  cmd)

; Declare global array variable to initialize a vector
(define (emit-global-vector id init)
  (define idxs-string
    (string-join (map number->string (vector->list init)) ", "))
  (define shuffle-id (format "shuffleIdx~a" id))
  (format "int ~a[~a] _LOCAL_DRAM0_ = { ~a }"
          shuffle-id  (vector-length init) idxs-string))

; XXX(alexa): model these casts explicitly
; Shuffle (single input) 
(define (emit-shuffle id inp idxs)
  (format "~a = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(~a), *(~a~a)))"
          id inp (pointer-to shuffle-idx-ty) idxs))

; Select (two inputs)
(define (emit-select id inp1 inp2 idxs)
  (format "~a = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(PDX_MOV_MX32_FROM_MXF32(~a), PDX_MOV_MX32_FROM_MXF32(~a), *(~a~a)))"
          id inp2 inp1 (pointer-to shuffle-idx-ty) idxs))

; Intrinsics
(define (emit-app f inps)
  (apply (function-ref f) inps))

(define function-env (make-hash))
(define (declare-function f val)
  (hash-set! function-env f val))
(define (function-ref f)
  (hash-ref function-env f))

(define (emit-vector-mac out inp1 inp2)
  (format "PDX_MULA_MXF32(~a, ~a, ~a)" out inp1 inp2))
(declare-function `vector-mac emit-vector-mac)

; XXX(alexa): add tests