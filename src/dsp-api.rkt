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

; A pair: the shuffle variable id and the command
(define (emit-shuffle-idxs id idxs)
  (define shuffle-id (format "shuffleIdx~a" id))
  (define idxs-string
    (string-join (map number->string (vector->list idxs)) ", "))
  (define cmd
    (format "int ~a[~a] _LOCAL_DRAM0_ = { ~a }"
            shuffle-id  (vector-length idxs) idxs-string))
  (cons shuffle-id cmd))

; XXX(alexa): model these casts explicitly
; A list: the shuffle index command and the shuffle itself 
(define (emit-shuffle id inp idxs)
  (match-define (cons shuffle-id shuffle-idxs) (emit-shuffle-idxs id idxs))
  (define cmd
    (format "~a = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(~a), *(~a~a)))"
            id inp (pointer-to shuffle-idx-ty) shuffle-id))
  (cons shuffle-idxs cmd))

; A list: the shuffle index command and the select itself 
(define (emit-select id inp1 inp2 idxs)
  (match-define (cons shuffle-id shuffle-idxs) (emit-shuffle-idxs id idxs))
  (define cmd
    (format "~a = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(PDX_MOV_MX32_FROM_MXF32(~a), PDX_MOV_MX32_FROM_MXF32(~a), *(~a~a)))"
            id inp2 inp1 (pointer-to shuffle-idx-ty) shuffle-id))
  (cons shuffle-idxs cmd))

; XXX(alexa): add tests