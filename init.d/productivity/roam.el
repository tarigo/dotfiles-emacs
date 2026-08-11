;;; roam.el --- База знаний: org-roam -*- lexical-binding: t -*-

;; Заметки живут в ~/org/roam — отдельно от agenda-файлов (tasks.org и др.),
;; чтобы org-roam индексировал только базу знаний.
(require 'productivity/init-org)  ; my/org-dir

(defvar my/org-roam-dir (expand-file-name "roam" my/org-dir)
  "Каталог базы знаний org-roam.")
(make-directory my/org-roam-dir t)

(use-package org-roam
  :custom
  (org-roam-directory my/org-roam-dir)
  ;; База данных — локальный кеш; при синхронизации ~/org между машинами
  ;; она не должна ездить вместе с заметками.
  (org-roam-db-location "~/.cache/emacs/org-roam.db")
  ;; Дополнять названия узлов по всему org-буферу (через company/capf).
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   '(("d" "Заметка" plain "%?"
      :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n")
      :unnarrowed t)
     ("w" "Работа" plain "%?"
      :target (file+head "work/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :work:\n")
      :unnarrowed t)
     ("s" "Учёба" plain "%?"
      :target (file+head "study/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :study:\n")
      :unnarrowed t)))
  ;; Ежедневные заметки — в roam/daily/.
  (org-roam-dailies-directory "daily/")
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "* %<%H:%M> %?"
      :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n l" . org-roam-buffer-toggle)
         ("C-c n g" . org-roam-graph)
         ("C-c n t" . org-roam-tag-add)
         ("C-c n a" . org-roam-alias-add)
         ("C-c n j" . org-roam-dailies-capture-today)
         ("C-c n d" . org-roam-dailies-goto-today))
  :config
  ;; Поддерживать базу в актуальном состоянии. org-roam грузится лениво
  ;; (при первой roam-команде), но включение autosync делает полный
  ;; db-sync — правки, сделанные до этого в файлах напрямую, догоняются.
  (org-roam-db-autosync-mode)
  ;; Буфер обратных ссылок — узкой колонкой справа.
  (add-to-list 'display-buffer-alist
               '("\\*org-roam\\*"
                 (display-buffer-in-side-window)
                 (side . right)
                 (window-width . 0.33))))

;; Интерактивный граф базы знаний в браузере (localhost:35901).
(use-package org-roam-ui
  :bind ("C-c n u" . org-roam-ui-mode)
  :custom
  ;; Тема графа следует теме Emacs, фокус — за текущим узлом.
  (org-roam-ui-sync-theme t)
  (org-roam-ui-follow t)
  (org-roam-ui-update-on-save t))

(provide 'productivity/roam)
;;; roam.el ends here
