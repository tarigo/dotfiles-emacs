;;; completion.el --- Минибуфер: vertico + consult + embark -*- lexical-binding: t -*-

;; Стек в духе Telescope из Neovim, но поверх штатного completing-read,
;; поэтому нечёткий поиск получают все команды: org-roam, magit, lsp и т.д.

;; Вертикальный список кандидатов в минибуфере.
(use-package vertico
  :custom (vertico-cycle t)
  :config (vertico-mode))

;; История минибуфера между сессиями — vertico поднимает частые выборы наверх.
(use-package savehist
  :ensure nil
  :config (savehist-mode))

;; Недавние файлы — источник для consult-buffer и consult-recent-file.
(use-package recentf
  :ensure nil
  :custom (recentf-max-saved-items 200)
  :config (recentf-mode))

;; Нечёткое сопоставление: слова через пробел в любом порядке.
;; Для файлов оставляем basic/partial-completion, чтобы работали /u/s/l-пути.
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Аннотации к кандидатам: описания команд, права файлов и т.п.
(use-package marginalia
  :config (marginalia-mode))

;; «Пикеры»: буферы, grep, строки, imenu — с живым предпросмотром.
(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("C-x C-r" . consult-recent-file)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-g f" . consult-flycheck)
         ("M-s l" . consult-line)
         ("M-s r" . consult-ripgrep)
         ("M-s d" . consult-fd))
  :init
  ;; Списки xref (lsp-find-references и т.п.) тоже через минибуфер с предпросмотром.
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

;; Действия над кандидатом прямо из минибуфера (аналог actions в Telescope).
(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim))
  :init
  ;; C-h после префикса показывает продолжения через минибуфер вместо *Help*.
  (setq prefix-help-command #'embark-prefix-help-command))

;; embark-export для результатов consult: grep-буфер из consult-ripgrep и т.п.
(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Символы по всему проекту через lsp (аналог lsp_workspace_symbols).
(use-package consult-lsp
  :after lsp-mode
  :bind (:map lsp-mode-map ("M-s s" . consult-lsp-symbols)))

;; Диагностика flycheck списком с предпросмотром (привязана к M-g f выше).
(use-package consult-flycheck)

(provide 'basics/completion)
;;; completion.el ends here
