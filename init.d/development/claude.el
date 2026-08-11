;;; claude.el --- Claude Code: IDE-интеграция -*- lexical-binding: t -*-

;; Терминал на движке libghostty (Ghostty); также доступен как M-x ghostel.
(use-package ghostel
  :custom
  ;; Модуль вне дерева пакетов — обновления пакета его не затирают.
  (ghostel-module-directory "~/.config/emacs/ghostel/")
  ;; Если модуль отсутствует — качать без вопросов.
  (ghostel-module-auto-install 'download))

;; https://github.com/manzaltu/claude-code-ide.el
;; MCP-мост между Claude Code CLI и Emacs: Claude видит выделение и
;; LSP-диагностику, показывает правки через ediff. Пакета нет на MELPA —
;; ставится из git (package-vc).
(use-package claude-code-ide
  ;; Ревизия запинена: пакет ставится из git и получает MCP-доступ к
  ;; редактору — «плавающий» master здесь ни к чему. Обновление осознанное:
  ;; M-x package-vc-upgrade, затем вписать новый SHA сюда.
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el"
       :rev "1de17bbadc650962a05fd68463fdff71697ec649")
  :bind ("C-c C-'" . claude-code-ide-menu)
  :custom
  (claude-code-ide-terminal-backend 'ghostel)
  :config
  ;; MCP-инструменты Emacs: xref, imenu, project — Claude навигирует
  ;; по коду средствами редактора.
  (claude-code-ide-emacs-tools-setup))

(provide 'development/claude)
;;; claude.el ends here
