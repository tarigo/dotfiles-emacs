;;; init.el --- Точка входа; вся конфигурация в init.d/ -*- lexical-binding: t -*-

(push (expand-file-name "init.d" user-emacs-directory) load-path)

;; Бэкапы, авто-сохранения и история undo — в ~/.cache, а не рядом с файлами.
(dolist (dir '("~/.cache/emacs/backup" "~/.cache/emacs/undo" "~/.cache/emacs/auto-save"))
  (make-directory dir t))
(setq backup-directory-alist '(("." . "~/.cache/emacs/backup")))
(setq undo-tree-history-directory-alist '(("." . "~/.cache/emacs/undo")))
(setq auto-save-file-name-transforms '((".*" "~/.cache/emacs/auto-save/" t)))

(require 'basics/package-management)
(require 'basics/environment)
(require 'basics/appearance)
(require 'basics/phosphor-theme)
(require 'basics/editing)
(require 'basics/completion)
(require 'development/common)
(require 'development/github)
(require 'development/rust)
(require 'development/kotlin)
(require 'development/c-cpp)
(require 'development/zig)
(require 'development/kdl)
(require 'development/claude)
(require 'development/ai-complete)
(require 'productivity/init-org)
(require 'productivity/roam)
(require 'productivity/finance)

;; Локальные/рабочие настройки вне git: файл не в whitelist .gitignore.
;; Если его нет (свежий клон) — молча пропускаем.
(load (locate-user-emacs-file "private.el") 'noerror 'nomessage)

;; custom.el — только для авто-сохранённого мусора Custom (в git не входит,
;; как и private.el); осознанные настройки живут в init.d/.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;;; init.el ends here
