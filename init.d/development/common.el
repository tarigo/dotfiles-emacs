;;; common.el --- Общее для разработки: LSP, дополнение, git -*- lexical-binding: t -*-

(use-package lsp-mode
  :commands lsp
  ;; Префикс должен быть установлен до загрузки lsp-mode:
  ;; карта прибивается к нему в defvar lsp-mode-map.
  ;; C-c l = = — формат буфера, C-c l r r — rename, C-c l a a — code action.
  :init (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-idle-delay 0.6)
  (lsp-eldoc-render-all t)
  :config
  (add-hook 'lsp-mode-hook #'lsp-ui-mode))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-doc-enable nil)
  (lsp-ui-doc-position 'top)
  (lsp-ui-doc-alignment 'window)
  (lsp-ui-sideline-enable nil))

(use-package flycheck)

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package treemacs
  :bind (("C-c t" . treemacs)
         ;; Прыжок в окно дерева из любого окна.
         ("M-0" . treemacs-select-window))
  :custom
  ;; C-x o не заходит в дерево.
  (treemacs-is-never-other-window t)
  :config
  ;; Дерево открывается только вручную (C-c t), но следует
  ;; за текущим файлом и проектом само.
  (treemacs-follow-mode 1)
  (treemacs-project-follow-mode 1))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-nerd-icons
  :after treemacs
  :config (treemacs-load-theme "nerd-icons"))

(use-package lsp-treemacs
  :after (lsp-mode treemacs))

(use-package yasnippet
  :hook ((prog-mode text-mode) . yas-minor-mode)
  :config (yas-reload-all))

(provide 'development/common)
;;; common.el ends here
