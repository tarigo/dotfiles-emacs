;;; editing.el --- Редактирование и навигация -*- lexical-binding: t -*-

;; Перемещение между окнами на Shift-стрелках.
;; В org эти клавиши освобождает org-replace-disputed-keys (см. init-org.el).
(windmove-default-keybindings)

(use-package undo-tree
  :custom (undo-tree-visualizer-diff t)
  :config (global-undo-tree-mode))

(use-package company
  ;; :bind в company-active-map откладывает загрузку, а войти в эту карту
  ;; без запущенного company нельзя — грузим сразу.
  :demand t
  :custom (company-idle-delay 0.5)
  :bind (:map company-active-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)
              ("M-<" . company-select-first)
              ("M->" . company-select-last))
  :config (global-company-mode))

(provide 'basics/editing)
;;; editing.el ends here
