;;; rust.el --- Rust: rustic + rust-analyzer -*- lexical-binding: t -*-

(use-package rustic
  :custom
  ;; clippy вместо cargo check при проверке on-save
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  ;; inlay hints
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints t)
  (lsp-rust-analyzer-display-reborrow-hints t)
  ;; Форматирование при сохранении делает rustic (rustfmt) — один раз.
  ;; Именно rustic-format-trigger: старая rustic-format-on-save — defvar,
  ;; и :custom для неё молча не применяется.
  (rustic-format-trigger 'on-save)
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  (add-hook 'rustic-mode-hook #'my/rustic-mode-setup)
  (advice-add 'rustic-cargo-run-test :filter-args #'my/rustic-test-nocapture))

(defun my/rustic-test-nocapture (args)
  "Добавляет `-- --nocapture' к rustic-cargo-current-test,
чтобы stdout/stderr теста попадали в буфер *cargo-test*."
  (list (append (ensure-list (car args)) '("--" "--nocapture"))))

(defun my/rustic-mode-setup ()
  ;; Чтобы rustic-cargo-run и т.п. сохраняли буфер без вопросов,
  ;; но не трогали rust-буферы без файла (см. rustic#253).
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

(provide 'development/rust)
;;; rust.el ends here
