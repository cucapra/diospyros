#lang rosette

(require "../c-ast.rkt")

(provide supress-git-info
         git-info-comment)

; Supress the git information header
(define supress-git-info (make-parameter #f))

; Return the non-error string output of a system command
(define (get-command-output cmd)
  (with-output-to-string (lambda () (system cmd))))

; Get the current git revision
(define (get-git-revision)
  (get-command-output "git rev-parse --short HEAD"))

; Check the current git status
(define (get-git-status)
  (define stat (get-command-output "git diff --stat"))
  (define clean? (equal? stat ""))
  (if (not clean?)
      (let ([warning (format "Warning: dirty git status:\n~a" stat)])
        (display warning)
        warning)
      "Git status clean"))

; Produce git info (revision and status) as a C-style block comment
(define (git-info-comment)
  (define rev (get-git-revision))
  (define status (get-git-status))
  (c-comment (format "Git revision: ~a\n~a" rev status)))
