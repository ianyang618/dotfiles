;; fix exec-path
(setq exec-path (append exec-path '("/home/brian/local/bin")))

(mapcar (lambda (x) (add-to-list 'load-path (expand-file-name x)))
        '("~/.emacs.d"
          "~/.emacs.d/clojure-mode"
          "~/.emacs.d/haskell-mode"
          "~/.emacs.d/org/lisp"
          "~/.emacs.d/org/contrib/lisp"))

(defun require-all (packages)
    (mapcar #'require packages))

(setq inferior-lisp-program "java -cp clojure-1.3.0.jar clojure.main")

(require-all '(
               mwe-log-commands
               uniquify
               light-symbol
               linum 
               color-theme
               gentooish
               ido
               parenface
               point-undo
               bar-cursor
               browse-kill-ring
               smart-tab
               undo-tree
               clojure-mode
               ))

(defun code-mode (x)
  (mapcar (lambda (hook) (add-hook hook x))
          '(ruby-mode
            clojure-mode-hook
            lisp-mode-hook
            slime-repl-mode-hook
            emacs-lisp-mode-hook)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-mode
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(setq org-startup-indented t)

(setq org-directory "~/Dropbox/Org")
(setq org-mobile-directory "~/Dropbox/MobileOrg/")
(setq org-agenda-files '("~/Dropbox/Org/my.org"))
(setq org-mobile-inbox-for-pull "~/Dropbox/Org/inbox.org")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Haskell

(load "~/.emacs.d/haskell-mode/haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
;;(add-hook 'haskell-mode-hook (lambda () (smart-tab-mode nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GLOBAL
(color-theme-initialize)
(setq frame-title-format '(multiple-frames "%b" ("" invocation-name)))
(if (string= window-system "w32")
    (set-default-font "-outline-Consolas-normal-r-normal-normal-14-97-96-96-c-*-iso859-1")
    (set-default-font "Consolas-12" t))

(if window-system
    (color-theme-gentooish)
    (color-theme-dark-laptop))

;; from http://joost.zeekat.nl/2010/06/03/slime-hints-3-interactive-completions-and-smart-tabs/

(setq hippie-expand-try-functions-list
      (append hippie-expand-try-functions-list '(slime-complete-symbol)))
(setq smart-tab-completion-functions-alist
      '((emacs-lisp-mode . lisp-complete-symbol)
        (text-mode . dabbrev-completion)
        (slime-repl-mode . slime-complete-symbol)))

(global-undo-tree-mode 1)
(code-mode 'smart-tab-mode)

(global-set-key "\C-R" 'undo-tree-redo)
(add-hook 'undo-mode-visualizer-mode
          (define-key undo-tree-visualizer-map
            (kbd "<return>")
            'undo-tree-visualizer-quit))


(browse-kill-ring-default-keybindings)
(setq auto-save-list-file-prefix nil)
(fset 'yes-or-no-p 'y-or-n-p)

(defun my-backward-kill-word ()
  "Kill words backward my way."
  (interactive)
  (if (bolp)
      (backward-delete-char 1)
    (if (string-match "^\\s-+$" (buffer-substring (point-at-bol) (point)))
        (kill-region (point-at-bol) (point))
      (backward-kill-word 1))))

(global-set-key "\M-\d" 'my-backward-kill-word)

;; From http://stackoverflow.com/questions/848936/how-to-preserve-clipboard-content-in-emacs-on-windows
(defadvice kill-new (before kill-new-push-xselection-on-kill-ring activate)
  "Before putting new kill onto the kill-ring, add the clipboard/external selection to the kill ring"
  (let ((have-paste (and interprogram-paste-function
                         (funcall interprogram-paste-function))))
    (when have-paste (push have-paste kill-ring))))


(global-hi-lock-mode 1)
(global-set-key "\C-o" 'point-undo)
;;(global-set-key "\C-i" 'point-redo)

;; from http://stackoverflow.com/questions/589691/how-can-i-emulate-vims-search-in-gnu-emacs

(defun my-isearch-word-at-point ()
  (interactive)
  (call-interactively 'isearch-forward-regexp))

(defun my-isearch-yank-word-hook ()
  (when (equal this-command 'my-isearch-word-at-point)
    (let ((string (concat "\\<"
                          (buffer-substring-no-properties
                           (progn (skip-syntax-backward "w_") (point))
                           (progn (skip-syntax-forward "w_") (point)))
                          "\\>")))
      (if (and isearch-case-fold-search
               (eq 'not-yanks search-upper-case))
          (setq string (downcase string)))
      (setq isearch-string string
            isearch-message
            (concat isearch-message
                    (mapconcat 'isearch-text-char-description
                               string ""))
            isearch-yank-flag t)
      (isearch-search-and-update))))

(add-hook 'isearch-mode-hook 'my-isearch-yank-word-hook)
(global-set-key [M-kp-multiply] 'my-isearch-word-at-point)


(bar-cursor-mode 1)

;; Try to fix copy/paste
(setq-default mode-line-buffer-identification '(#("%2b" 0 2 (face mode-line-buffer-id))))
(setq transient-mark-mode t)
(setq mouse-drag-copy-region nil)
(setq x-select-enable-primary nil)
(setq x-select-enable-clipboard t)
(setq select-active-regions t)
(global-set-key [mouse-2] 'mouse-yank-primary)
(cua-mode t)

(delete-selection-mode t)
(tool-bar-mode 0)
(code-mode 'linum-on)
(setq linum-format "%3d ")
(setq-default indent-tabs-mode nil)
(setq indent-tabs-mode nil)
(winner-mode t)

(tooltip-mode nil)
(setq line-number-mode nil)
(setq column-number-mode nil)
(setq size-indication-mode nil)
(setq mode-line-position nil)
(ido-mode 1)

(global-set-key "\C-m" 'reindent-then-newline-and-indent)  ;No tabs
(global-set-key "\C-a" 'beginning-of-line-text)

(setq even-window-heights nil)
(setq split-width-threshold nil)
(setq window-min-height 2)
(defun maximize-window ()
  (interactive)
  (let* ((other-windows (cdr (window-list)))
         (other-heights (* (length other-windows) window-min-height))
         (my-height (- (frame-height) other-heights)))
    (setf (window-height) (- my-height 1))))

(add-hook 'term-setup-hook (lambda () (windmove-default-keybindings 'meta)))
;(defadvice windmove-up (after maximize activate) (maximize-window))
;(defadvice windmove-down (after maximize activate) (maximize-window))

(set-fringe-style (cons 0 1))

(setq vc-handled-backends nil)

(defun kill-all-buffers ()
  (interactive)
  (when (y-or-n-p "Kill all buffers?")
    (dolist (buf (buffer-list))
      (kill-buffer buf))
    (delete-other-windows)))
(global-set-key "\C-xK" 'kill-all-buffers)

(defun make-backup-file-name (file)
  (concat "~/.backups/" (file-name-nondirectory file) "~"))

(global-set-key [C-tab] 'indent-according-to-mode)

(setq isearch-search-fun-function 'wrapping-search-fun)

(defun wrapping-search-fun ()
  (lambda (&rest args)
    (let* ((isearch-search-fun-function nil)
           (fun (isearch-search-fun)))
      (or (apply fun args)
          (unless (cadr args)
            (goto-char (if isearch-forward (point-min) (point-max)))
            (apply fun args))))))

;; Prevent Emacs from stupidly auto-changing my working directory
(defun find-file-save-default-directory ()
    (interactive)
    (setq saved-default-directory default-directory)
    (ido-find-file)
    (setq default-directory saved-default-directory))
(global-set-key "\C-x\C-f" 'find-file-save-default-directory)

(defun replace-globally ()
  "Run replace-regexp across the whole file, rather than from
point to the end of the file."
  (interactive)
  (let ((before (point)))
    (goto-char (point-min))
    (call-interactively 'replace-regexp)
    (when (= (point) (point-min))
      (goto-char before))))

(require 'saveplace)
(setq save-place-file "~/.emacs.d/saveplace")
(setq save-place t)

;; adapted from http://www.emacswiki.org/emacs/.emacs-ChristianRovner.el
(defun expand-region-linewise ()
  (interactive)
  (let ((start (region-beginning))
        (end (region-end)))
   (goto-char start)
   (beginning-of-line)
   (set-mark (point))
   (goto-char end)
   (unless (bolp) (end-of-line))))

(defun markdown-copy ()
  (interactive)
  (save-excursion
    (expand-region-linewise)
    (indent-rigidly (region-beginning) (region-end) 4)
    (clipboard-kill-ring-save (region-beginning) (region-end))
    (indent-rigidly (region-beginning) (region-end) -4)))

(defun yank-with-newline ()
  "Yank, appending a newline if the yanked text doesn't end with one."
  (yank)
  (when (not (string-match "\n$" (current-kill 0)))
    (newline-and-indent)))

(defun yank-as-line-above ()
  "Yank text as a new line above the current line.

Also moves point to the beginning of the text you just yanked."
  (interactive)
  (let ((lnum (line-number-at-pos (point))))
    (beginning-of-line)
    (yank-with-newline)
    (goto-line lnum)))

(defun yank-as-line-below ()
  "Yank text as a new line below the current line.

Also moves point to the beginning of the text you just yanked."
  (interactive)
  (let* ((lnum (line-number-at-pos (point)))
         (lnum (if (eobp) lnum (1+ lnum))))
    (if (and (eobp) (not (bolp)))
        (newline-and-indent)
      (forward-line 1))
    (yank-with-newline)
    (goto-line lnum)))

(global-set-key "\M-P" 'yank-as-line-above)
(global-set-key "\M-p" 'yank-as-line-below)

;; from http://stackoverflow.com/questions/2173324/emacs-equivalents-of-vims-dd-o-o
(defun open-line-above ()
  (interactive)
  (unless (bolp)
    (beginning-of-line))
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(defun open-line-below ()
  (interactive)
  (unless (eolp)
    (end-of-line))
  (newline-and-indent))

(global-set-key "\M-O" 'open-line-above)
(global-set-key "\M-o" 'open-line-below)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Terminals
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Paredit

(require 'paredit)

(eval-after-load 'paredit
  '(progn
     ;; Some paredit keybindings conflict with windmove and SLIME
     (define-key paredit-mode-map (kbd "<M-up>") nil)
     (define-key paredit-mode-map (kbd "<M-down>") nil)
     (define-key paredit-mode-map "\M-r" nil)))

(code-mode 'enable-paredit-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ruby

;(require 'ruby-mode)

;(define-key ruby-mode-map "\C-m" 'reindent-then-newline-and-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CSS

(defun electric-brace (arg)
  (interactive "P")
    ;; insert a brace
  (self-insert-command 1)
  ;; maybe do electric behavior
  (css-indent-line))

(require 'css-mode)
(define-key css-mode-map "}" 'electric-brace)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generic Lisp / Emacs Lisp
;; from http://www.emacswiki.org/emacs/AutoIndentation

(defadvice yank (after indent-region activate)
  (if (member major-mode '(clojure-mode emacs-lisp-mode lisp-mode))
      (let ((mark-even-if-inactive t))
        (indent-region (region-beginning) (region-end) nil)))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clojure

(autoload 'clojure-test-mode "clojure-test-mode" "Clojure test mode" t)
(autoload 'clojure-test-maybe-enable "clojure-test-mode" "" t)
(add-hook 'clojure-mode-hook 'clojure-test-maybe-enable)

(setq swank-clojure-library-paths
      (if (string= window-system "w32")
          (list "native/windows/x86_64")
        (list "native/linux/x86_64")))
(setq swank-clojure-extra-vm-args (list "-Dfile.encoding=UTF8"))

(defun cljs ()
  (interactive)
  (setq inferior-lisp-program "cljs-browser-repl"))

(defun clojure () (interactive) (clojure-jack-in))
(defun restart-clojure () (interactive) (slime-quit-lisp) (kill-matching-buffers "slime-repl") (clojure-jack-in))
(defun playground () (interactive) (cd "~/code/playground") (clojure-jack-in))

(defun no-catch-slime-compile-error ()
  "Redefine compile-file-for-emacs NOT to catch Throwable, so that the debugger is initiated
   for compile errors.  This makes compiler-notes fail to work, but I don't use those anyways."
  (slime-eval-async `(swank:eval-and-grab-output "(in-ns 'swank.commands.basic)(defn- compile-file-for-emacs*
  \"MONKEY PATCH\"
  ([file-name]
   (let [start (System/nanoTime)]
     (try
      (let [ret (clojure.core/load-file file-name)
                delta (- (System/nanoTime) start)]
        `(:compilation-result nil ~(pr-str ret) ~(/ delta 1000000000.0)))))))
(defslimefn compile-file-for-emacs
  ([file-name load? & compile-options]
   (when load?
     (compile-file-for-emacs* file-name))))")))

(add-hook 'slime-connected-hook 'no-catch-slime-compile-error)

(defun switch-scratch-buffer-mode ()
  (save-excursion
    (window-configuration-to-register ?a)
    (switch-to-buffer (get-buffer-create "*scratch*"))
    (clojure-mode)
    (jump-to-register ?a)))

(add-hook 'slime-connected-hook 'switch-scratch-buffer-mode)

(eval-after-load "slime"
  '(progn
     (add-to-list 'slime-lisp-implementations '(sbcl ("/usr/bin/sbcl")))
     (add-hook 'slime-indentation-update-hooks 'swank-clojure-update-indentation)
     (add-hook 'slime-repl-mode-hook 'swank-clojure-slime-repl-modify-syntax t)
     (add-hook 'clojure-mode-hook 'swank-clojure-slime-mode-hook t)
     (setq slime-highlight-compiler-notes nil)))

(defvar slime-override-map (make-keymap))
(define-minor-mode slime-override-mode
  "Fix SLIME REPL keybindings"
  nil " SLIME-override" slime-override-map)
(define-key slime-override-map (kbd "<C-return>") 'paredit-newline)
(define-key slime-override-map (kbd "{") 'paredit-open-curly)
(define-key slime-override-map (kbd "}") 'paredit-close-curly)
(define-key slime-override-map [delete] 'paredit-forward-delete)
(define-key slime-override-map [backspace] 'paredit-backward-delete)
(define-key slime-override-map (kbd "<C-return>") 'paredit-newline)
(define-key slime-override-map "\C-j" 'slime-repl-newline-and-indent)

(add-hook 'slime-repl-mode-hook (lambda ()
                                  (slime-override-mode t)
                                  (modify-syntax-entry ?\[ "(]")
                                  (modify-syntax-entry ?\] ")[")
                                  (modify-syntax-entry ?\{ "(}")
                                  (modify-syntax-entry ?\} "){")))

(setq auto-mode-alist
      (cons '("\\.clj$" . clojure-mode)
            auto-mode-alist))

(set-language-environment "UTF-8")

(defmacro defclojureface (name color desc &optional others)
  `(defface ,name '((((class color)) (:foreground ,color ,@others))) ,desc :group 'faces))

(defclojureface clojure-parens       "DimGrey"   "Clojure parens")
(defclojureface clojure-braces       "#49b2c7"   "Clojure braces")
(defclojureface clojure-brackets     "SteelBlue" "Clojure brackets")
(defclojureface clojure-keyword      "khaki"     "Clojure keywords")
(defclojureface clojure-namespace    "#c476f1"   "Clojure namespace")
(defclojureface clojure-java-call    "#4bcf68"   "Clojure Java calls")
(defclojureface clojure-special      "#b8bb00"   "Clojure special")
(defclojureface clojure-double-quote "#b8bb00"   "Clojure special" (:background "unspecified"))

(defun tweak-clojure-syntax ()
  (mapcar (lambda (x) (font-lock-add-keywords nil x))
          '((("#?['`]*(\\|)"       . 'clojure-parens))
            (("#?\\^?{\\|}"        . 'clojure-brackets))
            (("\\[\\|\\]"          . 'clojure-braces))
            ((":\\w+"              . 'clojure-keyword))
            (("#?\""               0 'clojure-double-quote prepend))
            (("nil\\|true\\|false\\|%[1-9]?" . 'clojure-special))
            (("(\\(\\.[^ \n)]*\\|[^ \n)]+\\.\\|new\\)\\([ )\n]\\|$\\)" 1 'clojure-java-call))
            )))

;; from https://gist.github.com/337280
(defun clojure-font-lock-setup ()
  "Configures font-lock for editing Clojure code."
  (interactive)
  (set (make-local-variable 'font-lock-multiline) t)
  (add-to-list 'font-lock-extend-region-functions
               'clojure-font-lock-extend-region-def t)

  (when clojure-mode-font-lock-comment-sexp
    (add-to-list 'font-lock-extend-region-functions
                 'clojure-font-lock-extend-region-comment t)
    (make-local-variable 'clojure-font-lock-keywords)
    (add-to-list 'clojure-font-lock-keywords
                 'clojure-font-lock-mark-comment t)
    (set (make-local-variable 'open-paren-in-column-0-is-defun-start) nil))

  (setq font-lock-defaults
        '(clojure-font-lock-keywords    ; keywords
          nil nil
          (("+-*/.<>=!?$%_&~^:@" . "w")) ; syntax alist
          nil
          (font-lock-mark-block-function . mark-defun)
          (font-lock-syntactic-face-function
           . lisp-font-lock-syntactic-face-function))))

(defadvice slime-repl-emit (after sr-emit-ad activate)
  (with-current-buffer (slime-output-buffer)
    (add-text-properties slime-output-start slime-output-end
                         '(font-lock-face slime-repl-output-face
                                          rear-nonsticky (font-lock-face)))))

(defadvice slime-repl-insert-prompt (after sr-prompt-ad activate)
  (with-current-buffer (slime-output-buffer)
    (let ((inhibit-read-only t))
      (add-text-properties slime-repl-prompt-start-mark (point-max)
                           '(font-lock-face slime-repl-prompt-face
                                            rear-nonsticky
                                            (slime-repl-prompt
                                             read-only
                                             font-lock-face
                                             intangible))))))

(add-hook 'slime-repl-mode-hook
          (lambda ()
            (clojure-font-lock-setup)
            (tweak-clojure-syntax)
            (font-lock-mode t)))

(add-hook 'clojure-mode-hook 'tweak-clojure-syntax)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(case-fold-search t)
 '(clojure-mode-use-backtracking-indent t)
 '(comint-scroll-to-bottom-on-input t)
 '(fancy-splash-image "")
 '(ido-decorations (quote ("" "" " | " " | ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
 '(ido-everywhere t)
 '(inhibit-startup-screen t)
 '(lisp-loop-forms-indentation 6)
 '(lisp-loop-keyword-indentation 6)
 '(lisp-simple-loop-indentation 6)
 '(mode-line-format (quote ("%e--[" mode-line-buffer-identification "]" (vc-mode vc-mode) "  " mode-line-modes global-mode-string " %-")))
 '(mode-line-in-non-selected-windows t)
 '(mode-line-modes (quote ("%[" "(" (:propertize ("" mode-name)) ("" mode-line-process) (:propertize ("" minor-mode-alist)) "%n" ")" "%]")))
 '(mouse-wheel-progressive-speed nil)
 '(require-final-newline t)
 '(savehist-mode t nil (savehist))
 '(scroll-bar-mode nil)
 '(scroll-conservatively 100000)
 '(scroll-down-aggressively 0.0)
 '(scroll-margin 0)
 '(scroll-step 1)
 '(scroll-up-aggressively 0.0)
 '(show-paren-mode t nil (paren))
 '(slime-compilation-finished-hook nil)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify)))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(org-hide ((((background dark)) (:foreground "#171717"))))
 '(slime-highlight-edits-face ((((class color) (background dark)) (:background "#202020")))))
