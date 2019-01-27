;;; quil-mode.el --- Emacs support for editing Quil code

;;; Commentary:

;; Major mode for editing Quil code.

;;; Installation:

;; Add this to your .emacs:

;; (add-to-list 'load-path "/folder/containing/file")
;; (require 'quil-mode)

;;; TODO:
;; * Better and complete syntax highlighting
;; * Support for communicating with quilc/qvm servers
;;     - might be cool to have elisp bindings for RPCQ
;; * License

;;; Code:


(defvar quil-mode-hook nil)

(defvar quil-mode-map
  (let ((map (make-keymap)))
    ;; (define-key map ...)
    map))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.quil\\'" . quil-mode))

(defvar quil-font-lock-keywords nil "Quil mode syntax highlighting")
(setf quil-font-lock-keywords
      `(;; Keywords
        ,(rx symbol-start
             (or "DEFGATE" "DEFCIRCUIT" "MEASURE" "RESET" "HALT" "JUMP" "JUMPWHEN"
                 "JUMPUNLESS" "WAIT" "DECLARE" "NEG" "NOT" "TRUE" "FALSE" "AND" "OR" "LABEL"
                 "IOR" "XOR" "ADD" "SUB" "MUL" "DIV" "MOVE" "EXCHANGE" "CONVERT" "LOAD"
                 "STORE" "EQ" "GT" "GE" "LT" "LE" "NOP" "INCLUDE" "PRAGMA" "PLUS" "MINUS"
                 "CONTROLLED" "DAGGER" "DECLARE" "HALT")
             symbol-end)
        (,(rx symbol-start (or "SIN" "COS" "SQRT" "EXP" "CIS" (+ (? "-") "pi") (+ (? "-") "i"))) . font-lock-builtin-face)
        (,(rx symbol-start (or "DEFGATE" "DEFCIRCUIT") (1+ space) (group (1+ (or word ?_))) (0+ (or space word ?_)))
         (1 font-lock-function-name-face))
        (,(rx (+ (? "-") ?%) (1+ (or word ?_))) . font-lock-variable-name-face)))

(defvar quil-mode-syntax-table nil "Quil mode syntax table")
(setf quil-mode-syntax-table
      (let ((st (make-syntax-table)))
        (modify-syntax-entry ?# "<" st)
        (modify-syntax-entry ?\n ">" st)
        st))

(defun quil-indent-line-function ()
  (let ((in-def* (save-excursion
                   (beginning-of-line)
                   (previous-line)
                   (re-search-forward (rx (or "DEFGATE" "DEFCIRCUIT") (1+ (or space ?\( ?\) ?# ?_ word)) ?:)
                                      (line-end-position) t))))
    (if (or in-def*
            (save-excursion
              (previous-line)
              (beginning-of-line-text)
              (/= 0 (current-column))))
        (indent-line-to 4))))

;;;###autoload
(define-derived-mode quil-mode prog-mode "Quil"
  "Major mode for editing Quil code

\\{quil-mode-map}"
  (set (make-local-variable 'tab-width) 4)
  (set (make-local-variable 'indent-tabs-mode) nil)

  (set (make-local-variable 'comment-start) "# ")
  (set (make-local-variable 'comment-start-skip) "#+\\s-*")

  (set-syntax-table quil-mode-syntax-table)

  (set (make-local-variable 'font-lock-defaults)
       '(quil-font-lock-keywords
         nil nil nil nil))

  (set (make-local-variable 'indent-line-function)
       #'quil-indent-line-function)

  (set (make-local-variable 'electric-indent-chars)
       (cons ?: electric-indent-chars)))

(provide 'quil-mode)
