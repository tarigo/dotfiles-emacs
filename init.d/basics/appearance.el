;;; appearance.el --- Внешний вид -*- lexical-binding: t -*-

(setq visible-bell t)

;; Шрифт через default-frame-alist — работает и при запуске демоном.
(add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font"))

;; Номера строк и prettify-symbols во всех программных буферах.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'prettify-symbols-mode)

;; Подсветка курсора при прыжках по буферу.
(use-package beacon
  :config (beacon-mode 1))

;; Подсказка привязок для начатой комбинации клавиш (встроен в Emacs 30).
(use-package which-key
  :ensure nil
  :config (which-key-mode))

(use-package nerd-icons)

(use-package doom-modeline
  :custom
  (doom-modeline-time t)
  (doom-modeline-battery t)
  :config
  (doom-modeline-mode 1)
  (display-time-mode 1)
  (ignore-errors (display-battery-mode 1)))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  ;; Показывать dashboard и во фреймах emacsclient при работе демоном.
  (setq initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name))))

;; Запасные наборы тем (M-x load-theme); основная — в phosphor-theme.el.
(use-package doom-themes)
(use-package ef-themes)

(provide 'basics/appearance)
;;; appearance.el ends here
