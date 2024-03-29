;;; orson-mode.el --- Major mode for Orson -*- lexical-binding: t; -*-
;;
;; Copyright © 2019 Jade Michael Thornton
;;
;; Version: 0.1.0
;; Keywords: Orson major mode
;; Author: Jade Michael Thornton
;; URL: https://gitlab.com/orsonlang/orson-mode
;;
;; This file is not part of GNU Emacs
;;
;; Permission to use, copy, modify, and/or distribute this software for any
;; purpose with or without fee is hereby granted, provided that the above
;; copyright notice and this permission notice appear in all copies.
;;
;; The software is provided "as is" and the author disclaims all warranties with
;; regard to this software including all implied warranties of merchantability
;; and fitness. In no event shall the author be liable for any special, direct,
;; indirect, or consequential damages or any damages whatsoever resulting from
;; loss of use, data or profits, whether in an action of contract, negligence or
;; other tortious action, arising out of or in connection with the use or
;; performance of this software.
;;
;;; Commentary:
;;
;; This is a major mode for the Orson language, providing syntax highlighting,
;; indentation, and a few cute commands.
;;
;; Orson is a general-purpose programming language which emphasizes efficiency,
;; expressiveness and extensibility. See https://gitlab.com/orsonlang/orson
;;
;;; Code:

(require 'lisp-mode) ; for indent function

(defvar font-lock-comment-face)
(defvar font-lock-doc-face)
(defvar font-lock-keywords-case-fold-search)
(defvar font-lock-string-face)

;;; Font-lock

;; TODO collapse some of these

(defconst orson--operators-keywords
  '(":−" ":-"
    "≠"

    ;; clause keywords
    "also"
    "alt"
    "alts"
    "and" "∧"
    "case"
    "catch"
    "do"
    "else"
    "for"
    "form"
    "gen"
    "if"
    "in"
    "load"
    "mod"
    "none"
    "not" "¬"
    "of"
    "or" "∨"
    "past"
    "proc"
    "prog"
    "ref"
    "row"
    "then"
    "tuple"
    "type"
    "var"
    "while"
    "with"
    )
  "Operators in Orson.")

(defconst orson--names
  '("⊑" ; counterpart of plain name isCotype
    "≼" ; counterpart of isSubsumed
    "⊆" ; counterpart of isSubtype
	  " []"
	  " {}"
	  "&"
	  "&="
	  "⁎" "×"
	  "⁎=" "×="
	  "+"
	  "+="
	  "-" "−"
	  "-=" "−="
	  "."
	  "/"
	  "/="
	  ":="
	  "<"
	  "< <"
	  "< <=" "< ≤"
	  "<<" "←"
	  "<<=" "←="
	  "<=" "≤"
	  "<= <" "≤ <"
	  "<= <=" "≤ ≤"
	  "<>" "≠"
	  "="
	  ">"
	  "> >"
	  "> >=" "> ≥"
	  ">>" "→"
	  ">>=" "→="
	  ">=" "≥"
	  ">= >" "≥ >"
	  ">= >=" "≥ ≥"
	  "@" "↓"
	  "[] "
	  "^" "↑"
	  "|"
	  "|="
	  "~"
	  "~="
    "abs"
    "align"
    "argc"
    "argv"
    "arity"
    "base"
    "car" "cdr" "cons"
    "comp" "conc" "count"
    "devar"
    "enum"
    "error" "exit"
    "flatten"
    "halt"
    "high"
    "isChar" "isCotype" "isEmpty" "isError"
    "isGoat" "isInt" "isJoked" "isNull"
    "isReal" "isSkolem" "isString"
    "isSubsumed" "isSubtype"
    "length" "low" "max" "min"
    "offset" "refs" "rethrow"
    "size" "slot" "sort"
    "throw" "thrown"
    "version")
  "Names in the Orson standard prelude")

(defconst orson--types
  '("bool" "false" "true"
    "char" "char0" "char1"
    "int" "int0" "int1" "int2"
    "list"
    "null" "nil"
    "real" "real0" "real1"
    "stream" "eos"
    "string" "ϵ"
    "void" "skip"

    ;; joker types
    "alj" "cha" "exe" "foj" "gej"
    "inj" "met" "mut" "nom" "num"
    "obj" "plj" "pro" "rej" "sca"
    "str" "tup")
  "Types in the Orson standard prelude")

(defconst orson-types
  `((,(regexp-opt
       orson--types
       'symbols)
     . font-lock-type-face))
  "All Orson builtins")

(defconst orson-builtins
  `((,(regexp-opt
       orson--operators-keywords
       'symbols)
     . font-lock-builtin-face))
  "All builtin Orson keywords")

(defconst orson-keywords
  `((,(regexp-opt
       orson--names
       'symbols)
     . font-lock-keyword-face))
  "All keywords provided by the Orson standard prelude")

(defun orson-mode--setup-font-lock ()
  "Set up `font-lock-defaults' for `orson-mode'."
  (setq font-lock-defaults
        `((,@orson-builtins ,@orson-keywords ,@orson-types)
          nil nil nil nil
          (font-lock-mark-block-function . mark-defun))))


;;; Syntax regexps

(defconst orson--string-rx
  ;; TODO strings may contain a lone quote, this will not allow it
  "\\(''[^']*''\\)")


;;; Generate syntax rules

(defconst orson-mode-syntax-table
  (let ((st (make-syntax-table)))

    ;; comments begin with ! and end with newline
    (modify-syntax-entry ?! "<" st)
    (modify-syntax-entry ?\n ">" st)
    st)
  "Syntax table used in `orson-mode'")

(defun orson-syntax-propertize-function (start end)
  "Implements the syntax highlighting beyond `font-lock-keywords'."
  (save-excursion
    (goto-char start)
    (while (re-search-forward orson--string-rx end 'noerror)
      (let ((a (match-beginning 1))
            (b (match-end 1))
            (string-fence (string-to-syntax "|")))
        (put-text-property a (1+ a) 'syntax-table string-fence)
        (put-text-property (1- b) b 'syntax-table string-fence)))

    (funcall
     (syntax-propertize-rules
      ;; TODO others
      )
     (point) end)))

(defun orson-mode--setup-syntax ()
  "Setup syntax and indentation"
  (set-syntax-table orson-mode-syntax-table)
  (setq-local syntax-propertize-function #'orson-syntax-propertize-function)

  ;; Orson does not allow tabs
  (setq-local indent-tabs-mode nil)
  (setq-local indent-line-function #'lisp-indent-line)
  ;; (setq-local lisp-indent-function #'orson-indent-function)
  )


;;; Define the major mode

(defcustom orson-mode-hook nil
  "hook run when entering Orson mode."
  :type 'hook
  :group 'orson-mode)

;;;###autoload
(define-derived-mode orson-mode prog-mode "Orson"
  (orson-mode--setup-font-lock)
  (orson-mode--setup-syntax)
  (font-lock-ensure))

(provide 'orson-mode)

;;; orson-mode.el ends here
