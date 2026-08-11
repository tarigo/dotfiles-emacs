;;; zig.el --- Zig: zig-mode + zls -*- lexical-binding: t -*-

(use-package zig-mode
  :hook (zig-mode . lsp)
  :custom
  ;; Форматирование при сохранении — zig fmt.
  (zig-format-on-save t))

(provide 'development/zig)
;;; zig.el ends here
