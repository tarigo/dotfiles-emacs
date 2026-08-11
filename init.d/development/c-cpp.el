;;; c-cpp.el --- C и C++: clangd -*- lexical-binding: t -*-

;; LSP-сервер — clangd. Чтобы он видел флаги компиляции, проекту нужен
;; compile_commands.json: для cmake — -DCMAKE_EXPORT_COMPILE_COMMANDS=ON,
;; для make — bear -- make.
(setq lsp-clients-clangd-args
      '("--header-insertion-decorators=0"
        "--header-insertion=never"
        "--clang-tidy"
        "--completion-style=detailed"))

;; Классические и tree-sitter варианты режимов.
(dolist (hook '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook))
  (add-hook hook #'lsp))

;; Форматирование намеренно не на сохранении: в чужих C/C++ проектах
;; авто-reformat даёт огромные диффы. Вручную — M-x lsp-format-buffer
;; (использует .clang-format проекта, если он есть).

;; Подсветка и отступы для CMakeLists.txt.
(use-package cmake-mode)

(provide 'development/c-cpp)
;;; c-cpp.el ends here
