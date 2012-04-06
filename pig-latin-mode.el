;;; pig-latin-mode.el --- major mode for Pig codes

;; The MIT License
;;
;; Copyright (c) 2012 Takeshi Arabiki
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

;; USAGE
;;
;;  Put this file in your Emacs lisp path (e.g. site-lisp)
;;  and add to the following lines to your .emacs file:
;;
;;    (add-to-list 'auto-mode-alist '("\\.pig$" . pig-latin-mode))
;;    (autoload 'pig-latin-mode "pig-latin-mode" "Pig-Latin mode" t)


(defconst pig-latin-mode-version "0.0.1"
  "Pig-Latin mode Version.")


(require 'align)
(add-to-list 'auto-mode-alist '("\\.pig\\'" . pig-latin-mode))
(add-to-list 'align-rules-list
             '(pig-latin-schema-definition
               (regexp . "\\(\\s-*\\):")
               (modes . '(pig-latin-mode))))
(add-to-list 'align-rules-list
             '(pig-latin-foreach-schema-definition
               (regexp . "\\(\\s-*\\)\\s-+as")
               (modes . '(pig-latin-mode))))

(defvar pig-latin-indent 4)

;; (defvar pig-eval-functions
;;   '("ARITY" "AVG" "BagSize" "CONCAT" "ConstantSize" "COUNT" "COUNT_STAR" "DIFF"
;;     "IsEmpty" "MapSize" "MAX" "MIN" "SUM" "SIZE" "TOKENIZE" "TupleSize"))

;; (defvar pig-load-store-functions
;;   '("BinStorage" "PigDump" "PigStorage" "TextLoader"))

;; (defvar pig-math-functions
;;   '("ABS" "ACOS" "ASIN" "ATAN" "CBRT" "CEIL" "COS" "COSH" "EXP" "FLOOR"
;;     "LOG" "LOG10" "RANDOM" "ROUND" "SIN" "SINH" "SQRT" "TAN" "TANH"))

;; (defvar pig-string-functions
;;   '("INDEXOF" "LAST_INDEX_OF" "LCFIRST" "LOWER" "REGEX_EXTRACT"
;;     "REGEX_EXTRACT_ALL" "REPLACE" "STRSPLIT" "SUBSTRING" "TRIM"
;;     "UCFIRST" "UPPER"))

;; (defvar pig-bag-and-tuple-functions
;;   '("TOBAG" "TOP" "TOTUPLE"))

;; (defvar pig-functions
;;   `(,@pig-eval-functions
;;     ,@pig-load-store-functions
;;     ,@pig-math-functions
;;     ,@pig-string-functions
;;     ,@pig-bag-and-tuple-functions))

;; (defvar pig-expressions-like-functions
;;   '("FLATTEN"))

(defvar pig-latin-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") 'newline-and-indent)
    map))

(defvar pig-latin-data-types
  '("bag" "bytearray" "chararray" "double" "float" "int" "long" "map"
    "tupple"))

(defvar pig-latin-preprocessor-statements
  '("%default" "%declare"))

(defvar pig-latin-register-re
  (concat
   "\\<\\(REGISTER\\)"
   "\\s-+"                 ; must contain whitespace
   "\\(?:/\\*.*?\\*/\\)?"  ; C-style comment
   "\\([^ \t\n;]+\\)\\(?:\\s-\\|$\\)"))

(defvar pig-latin-quoted-re
  (concat
   "\"[^\"\\]*\\(?:\\\\.[^\"\\]*\\)*\""  ; single quote
   "\\|"
   "'[^'\\]*\\(?:\\\\.[^'\\]*\\)*'"      ; double quote
   "\\|"
   "`[^`\\]*\\(?:\\\\.[^`\\]*\\)*`"))    ; back quote

(defvar pig-latin-preprocessor-statements-re
  (concat
   (regexp-opt pig-latin-preprocessor-statements t)
   "\\s-*\\(?:/\\*.*?\\*/\\)?\\s-*"  ; C-style comment
   "\\([_A-Za-z][_0-9A-Za-z]*\\)"    ; variable name
   "\\s-*\\(?:/\\*.*?\\*/\\)?\\s-*"  ; C-style comment
   "\\("
   pig-latin-quoted-re               ; quoted value
   "\\|"
   "\\<[^ \t\n;]+\\(?:\\s-\\|$\\)"   ; non-quoted value
   "\\)"))

(defvar pig-latin-statements
  '("ALL" "AND" "ANY" "ARRANGE" "AS" "ASC" "BY"
    "COGROUP" "CROSS" "DEFINE" "DESC" "DISTINCT" "DUMP" "EVAL"
    "FILTER" "FOREACH" "FULL" "GENERATE" "GROUP"
    "IF" "ILLUSTRATE" "IMPORT" "INNER""INTO" "IS" "JOIN" "LEFT" "LOAD"
    "MATCHES" "NOT" "NULL" "OR" "ORDER" "OUTER" "PARALLEL" "PARTITION"
    "RETURNS" "RIGHT" "SAMPLE" "SHIP" "SPLIT" "STORE" "STREAM" "THROUGH"
    "UNION" "USING"))

(defvar pig-latin-font-lock-keywords
  `(;; statements
    (,(regexp-opt pig-latin-statements 'words)
     (1 font-lock-keyword-face))
    ;; REGISTER statement
    (,pig-latin-register-re
     (1 font-lock-keyword-face)
     (2 font-lock-string-face))
    ;; preprocessor statments
    (,pig-latin-preprocessor-statements-re
     (1 font-lock-preprocessor-face t)
     (2 font-lock-variable-name-face)
     (3 font-lock-string-face))
    ;; functions and expressions like functions (not overwrite)
    ("\\<\\([_0-9A-Za-z]+\\)\\>\\s-*("
     (1 font-lock-function-name-face))
    ;; constants
    (,(concat
       "\\<\\("
       ;; begin with dot
       "\\.[0-9]+\\(?:E[-+]?[0-9]+\\)?F?"
       "\\|"
       ;; begin with numbers
       "[0-9]+\\(?:\\(?:\\.[0-9]+\\)?\\(?:E[-+]?[0-9]+\\)?F?\\|L?\\)"
       "\\)\\>")
     (1 font-lock-constant-face))
    ;; variables
    ("\\<$\\(?:[0-9]+\\|[_A-Za-z][_0-9A-Za-z]*\\)\\>" . font-lock-variable-name-face)
    ;; data types
    (,(concat
       "[ \t\n]*"
       (regexp-opt pig-latin-data-types 'words))
     (1 font-lock-type-face))))

(defvar pig-latin-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_  "w" st)
    ;; C-style comments /**/
    (modify-syntax-entry ?/  ". 14" st)
    (modify-syntax-entry ?*  ". 23" st)
    ;; double-dash starts comments and newline end comments
    ;; set comment sequence style to b in order not to affect C-style comments
    ;; but '-*' and '/-' are recognized as the begining of comment
    ;; (bug of Emacs?)
    (modify-syntax-entry ?-  ". 12b" st)
    (modify-syntax-entry ?\n "> b" st)
    ;; string quotes
    (modify-syntax-entry ?\' "\"" st)
    (modify-syntax-entry ?\` "\"" st)
    st))

;; (defun pig-latin-in-string-or-comment-p (&optional pos)
;;   "TODO: document"
;;   (save-excursion
;;     (let ((ppss syntax-ppss))
;;       (or (nth 3ppss) (nth 4 ppss)))))

(defun pig-latin-in-string-or-comment-p (&optional pos)
  "TODO: document"
  (nth 8 (syntax-ppss pos)))

(defun pig-latin-in-brace-p (&optional pos)
  "TODO: document"
  (let ((current-pos (point)) bob eob)
    (save-excursion
      (forward-char)
      (while (and (search-backward "{" nil t)
                  (pig-latin-in-string-or-comment-p)))
      (setq bob (point))
      (forward-sexp)
      (backward-char)
      (setq eob (point)))
    (and (>= current-pos bob)
         (<= current-pos eob))))

(defun pig-latin-in-statement-p (&optional pos)
  "TODO: document"
  (save-excursion
    (let ((current-pos (point)))
      (pig-latin-beginning-of-statement)
      (not (equal current-pos (point))))))

(defun pig-latin-in-substatement-p (&optional pos)
  "TODO: document"
  (save-excursion
    (let ((current-pos (point)))
      (pig-latin-beginning-of-substatement)
      (not (equal current-pos (point))))))

(defun pig-latin-statement-depth (&optional pos)
  "TODO: document"
  (nth 0 (syntax-ppss pos)))

(defun pig-latin-after-generate-p (&optional pos)
  "TODO: document"
  (save-excursion
    (let ((current-pos (point)))
      (forward-char)
      (while (and (search-backward "{" nil t)
                  (pig-latin-in-string-or-comment-p)))
      (re-search-forward "\\<generate\\>" nil t)
      (>= current-pos (point)))))

(defun pig-latin-beginning-of-statement ()
  "TODO: document"
  (let ((current-pos (point)) bos)
    (save-excursion
      (while (and (search-backward-regexp
                   (concat "[};]\\|" pig-latin-register-re "\\|"
                           pig-latin-preprocessor-statements-re)
                   nil t)
                  (forward-char)
                  (or (pig-latin-in-string-or-comment-p)
                      (> (pig-latin-statement-depth) 0))))
      (goto-char (match-end 0))
      (forward-word)
      (while (pig-latin-in-string-or-comment-p)
        (forward-word))
      (backward-word)
      (setq bos (point)))
    (if (> current-pos bos)
        (goto-char bos))))

(defun pig-latin-end-of-statement ()
  "TODO: document"
  (let ((current-pos (point)) bos point-char)
    (save-excursion
      (pig-latin-beginning-of-statement)
      (while (and (search-forward-regexp
                   (concat "[};]\\|" pig-latin-register-re "\\|"
                           pig-latin-preprocessor-statements-re)
                   nil t)
                  (or (pig-latin-in-string-or-comment-p)
                      (> (pig-latin-statement-depth) 0))))
      (setq point-char (format "%c" (char-after)))
      (if (and (not (equal point-char ";"))
               (not (equal point-char "}")))
          (backward-char))
      (setq bos (point)))
    (if (< current-pos bos)
        (goto-char bos))))

(defun pig-latin-beginning-of-substatement ()
  "TODO: document"
  (let ((current-pos (point)) bos)
    (save-excursion
      (while (and (search-backward-regexp "[{;]" nil t)
                  (pig-latin-in-string-or-comment-p)))
      (forward-word)
      (while (pig-latin-in-string-or-comment-p)
        (forward-word))
      (backward-word)
      (setq bos (point)))
    (if (> current-pos bos)
        (goto-char bos))))

(defun pig-latin-calculate-in-brace-indent (depth)
  (if (or (pig-latin-in-substatement-p)
          (pig-latin-after-generate-p))
      (* pig-latin-indent (1+ depth))
    (* pig-latin-indent depth)))

(defun pig-latin-calculate-indent (&optional parse-start)
  "TODO: document"
  (save-excursion
    (if parse-start
        (goto-char parse-start)
      (beginning-of-line))
    (let ((depth (pig-latin-statement-depth)))
      (cond
       ((bobp) 0)
       ((pig-latin-in-string-or-comment-p) nil)
       ((looking-at "[ \t]*\\(?:;\\|)[ \t]*;\\|}\\)") 0)
       ((pig-latin-in-brace-p) (pig-latin-calculate-in-brace-indent depth))
       ((pig-latin-in-statement-p) (* pig-latin-indent (1+ depth)))
       (t 0)))))

(defun pig-latin-indent-line ()
  "TODO: document"
  (interactive)
  (let ((indent-length (pig-latin-calculate-indent)))
    (if (not indent-length)
        (setq indent-length (current-indentation)))
    (indent-line-to indent-length)))


(define-derived-mode pig-latin-mode fundamental-mode "Pig-Latin"
  "TODO: document"
  :syntax-table pig-latin-mode-syntax-table
  (set (make-local-variable 'font-lock-defaults)
       '(pig-latin-font-lock-keywords nil t))
  (set (make-local-variable 'indent-line-function) 'pig-latin-indent-line)
  (set (make-local-variable 'comment-start) "-- ")
  (set (make-local-variable 'comment-end) ""))

(provide 'pig-latin-mode)
;;; pig-latin-mode.el ends here
