;;; init-org.el --- Org: задачи, agenda, capture -*- lexical-binding: t -*-

;; ─────────────────────────────────────────────────────────────────────────────
;; Пути и файлы
;; ─────────────────────────────────────────────────────────────────────────────
(defvar my/org-dir (expand-file-name "~/org") "Главная папка Org.")
(setq org-directory my/org-dir)
(dolist (f '("inbox.org" "tasks.org" "calendar.org" "notes.org"
             "journal.org" "health.org" "shopping.org" "study.org"))
  (let ((path (expand-file-name f my/org-dir)))
    (unless (file-exists-p path)
      (make-directory (file-name-directory path) t)
      (with-temp-file path (insert (format "#+title: %s\n" f))))))
(setq org-default-notes-file (expand-file-name "inbox.org" my/org-dir))

;; Освобождаем S-стрелки в org для windmove; org-shiftup и т.п.
;; переезжают на альтернативы (см. org-disputed-keys).
;; Должно быть установлено до загрузки org.
(setq org-replace-disputed-keys t)

;; ─────────────────────────────────────────────────────────────────────────────
;; Org core + визуальные улучшения
;; ─────────────────────────────────────────────────────────────────────────────
(use-package org
  :ensure nil
  :hook ((org-mode . org-indent-mode)
         (org-mode . variable-pitch-mode)
         (org-mode . visual-line-mode))
  :custom
  (org-startup-folded 'content)
  (org-hide-emphasis-markers t)
  (org-ellipsis " …")
  (org-pretty-entities t)
  (org-tags-column 0)
  (org-log-done 'time)
  (org-log-repeat 'time)
  (org-use-fast-todo-selection t)
  (org-M-RET-may-split-line nil)
  (org-return-follows-link t)
  (org-agenda-files (mapcar (lambda (n) (expand-file-name n my/org-dir))
                            '("inbox.org" "tasks.org" "calendar.org"
                              "health.org" "shopping.org" "study.org")))
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "HOLD(h)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-todo-keyword-faces '(("NEXT" . (:inherit warning :weight bold))
                            ("WAIT" . (:inherit font-lock-doc-face))
                            ("HOLD" . (:slant italic))))
  (org-priority-faces '((?A . error) (?B . warning) (?C . success)))
  (org-enforce-todo-dependencies t)
  (org-enforce-todo-checkbox-dependencies t)
  :config
  ;; Восстановление часов clock между сессиями.
  (setq org-clock-idle-time 15
        org-clock-persist t)
  (org-clock-persistence-insinuate)
  ;; Код в заметках.
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (python . t)
     (emacs-lisp . t)))
  (setq org-babel-python-command "python3")
  ;; Подтверждение выполнения блоков: не спрашивать только для emacs-lisp;
  ;; shell/python в чужом файле могут сделать что угодно.
  (setq org-confirm-babel-evaluate
        (lambda (lang _body) (not (string= lang "emacs-lisp")))))

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :custom (org-modern-block-fringe 1))

(use-package org-appear
  :hook (org-mode . org-appear-mode))

;; ─────────────────────────────────────────────────────────────────────────────
;; Архив и refile
;; ─────────────────────────────────────────────────────────────────────────────
(setq org-archive-location (expand-file-name "archive/%s::" my/org-dir))
(setq org-refile-targets
      `(((,(expand-file-name "tasks.org" my/org-dir)) :maxlevel . 3)
        ((,(expand-file-name "notes.org" my/org-dir)) :maxlevel . 2)
        ((,(expand-file-name "calendar.org" my/org-dir)) :maxlevel . 2)
        ((,(expand-file-name "health.org" my/org-dir)) :maxlevel . 2)
        ((,(expand-file-name "study.org" my/org-dir)) :maxlevel . 2)))
(setq org-outline-path-complete-in-steps nil
      org-refile-use-outline-path t)

;; ─────────────────────────────────────────────────────────────────────────────
;; Быстрые клавиши
;; ─────────────────────────────────────────────────────────────────────────────
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c o") (lambda () (interactive) (org-agenda nil "o")))

;; ─────────────────────────────────────────────────────────────────────────────
;; Capture templates
;; ─────────────────────────────────────────────────────────────────────────────
(setq org-capture-templates
      `(;; Базовая задача (рабочая/личная)
        ("t" "Task" entry (file ,(expand-file-name "inbox.org" my/org-dir))
         "* TODO %? :task:\nCREATED: %U\n:PROPERTIES:\n:SOURCE: %a\n:EFFORT: %^{Effort|0:15|0:30|1:00|2:00|4:00}\n:END:\n")
        ;; Meeting (работа/школа/спорт)
        ("m" "Meeting" entry (file+headline ,(expand-file-name "calendar.org" my/org-dir) "Meetings")
         "* %^{Subject} :meeting:\nSCHEDULED: %^T\nAttendees: %^{Attendees}\nAgenda:\n- %?\n")
        ;; Health / Workout лог
        ("w" "Workout" entry (file+datetree ,(expand-file-name "health.org" my/org-dir))
         "* %U :health:workout:\nType: %^{Type|Gym|Swim|Run|Pilates|Mobility}\nDuration: %^{min|20|30|45|60}m  RPE: %^{1..10|6}\n- [ ] Warmup\n- [ ] Main\n- [ ] Cooldown\nNotes: %?\n")
        ;; Shopping (чек-лист)
        ("s" "Shopping" entry (file+headline ,(expand-file-name "shopping.org" my/org-dir) "To buy")
         "* %^{List title|Groceries} :shopping:\n- [ ] %?\n")
        ;; Учёба: универсальная карточка (любая тема — язык, tech, что угодно).
        ;; Front/Back — формат anki-editor: при желании пушится в Anki,
        ;; без Anki остаётся обычной org-заметкой.
        ("l" "Learn (карточка)" entry (file+headline ,(expand-file-name "study.org" my/org-dir) "Cards")
         "* %^{Вопрос/термин} :study:\n:PROPERTIES:\n:ANKI_DECK: %^{Deck|Default}\n:ANKI_NOTE_TYPE: Basic\n:END:\n** Front\n%\\1\n** Back\n%?\n")
        ;; Daily journal
        ("j" "Journal" entry (file+datetree ,(expand-file-name "journal.org" my/org-dir))
         "* %U :journal:\nMood: %^{mood|🙂|😐|😖|😎}\nFocus: %^{focus}\nNotes:\n%?\n")))

;; ─────────────────────────────────────────────────────────────────────────────
;; Agenda
;; ─────────────────────────────────────────────────────────────────────────────
(setq org-agenda-start-on-weekday 1
      org-agenda-span 7
      org-agenda-time-grid '((daily today require-timed) (800 1000 1200 1400 1600 1800) "......" "----------------")
      org-agenda-current-time-string "⇽ now"
      org-agenda-prefix-format '((agenda . " %?-12t %s ") (todo . " %i ") (tags . " %i ") (search . " %i ")))

(use-package org-super-agenda
  :hook (org-agenda-mode . org-super-agenda-mode)
  :custom
  (org-super-agenda-groups
   '((:name "🔥 Срочно" :priority "A")
     (:name "▶ NEXT" :todo "NEXT")
     (:name "⏳ WAIT" :todo "WAIT")
     (:name "Сегодня" :scheduled today)
     (:name "На неделе" :scheduled future)
     (:name "Здоровье" :tag "health")
     (:name "Учёба" :tag "study")
     (:name "Покупки" :tag "shopping"))))

(setq org-agenda-custom-commands
      '(("o" "Overview"
         ((agenda "" ((org-agenda-span 7)))
          (todo "NEXT" ((org-agenda-overriding-header "Next actions")))
          (tags "+PRIORITY={A}" ((org-agenda-overriding-header "A-priority")))
          (todo "WAIT" ((org-agenda-overriding-header "Waiting")))))
        ("st" "Study / Learning"
         ((tags "+study")))
        ("hl" "Health / Training"
         ((tags "+health") (search "workout")))))

;; Effort estimates
(setq org-global-properties '(("Effort_ALL" . "0:10 0:15 0:30 1:00 2:00 4:00 8:00")))

;; ─────────────────────────────────────────────────────────────────────────────
;; Anki: опциональный пуш карточек из study.org
;; ─────────────────────────────────────────────────────────────────────────────
;; Нужен запущенный Anki с аддоном AnkiConnect (код 2055492159).
;; M-x anki-editor-push-note-at-point — карточка под курсором,
;; M-x anki-editor-push-notes — все в буфере. Org-теги уезжают тегами Anki.
(use-package anki-editor
  :commands (anki-editor-mode
             anki-editor-push-note-at-point
             anki-editor-push-notes))

;; ─────────────────────────────────────────────────────────────────────────────
;; Экспорт: Pandoc (C-c C-e, далее меню)
;; ─────────────────────────────────────────────────────────────────────────────
(use-package ox-pandoc :after org)

(provide 'productivity/init-org)
;;; init-org.el ends here
