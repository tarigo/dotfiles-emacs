;;; github.el --- GitHub: forge в magit + consult-gh -*- lexical-binding: t -*-

;; Issues и PR прямо в magit-status: M-x forge-pull забирает данные
;; репозитория в локальную БД (SQLite), дальше просмотр работает офлайн.
;; Меню forge в magit — на «'».
(use-package forge
  :after magit)

;; Токен не хранится в ~/.authinfo: gh CLI уже авторизован (keyring),
;; ghub спрашивает токен у него. Ответ кэшируется: ghub запрашивает токен
;; на каждый API-вызов, а forge-pull делает их десятки — без кэша каждый
;; раз форкался бы процесс gh. nil от advice (не github.com или gh не
;; ответил) возвращает ghub к штатному поиску через auth-source.
;; Внимание: ghub--token — внутренняя функция, при крупных обновлениях
;; forge/ghub проверять, что advice ещё попадает.
(defvar my/ghub-token-cache nil
  "Токен gh CLI, полученный при первом успешном запросе.")
(defun my/ghub-token-from-gh (host &rest _)
  (when (string-prefix-p "api.github.com" host)
    (or my/ghub-token-cache
        (setq my/ghub-token-cache
              (car (ignore-errors
                     (process-lines "gh" "auth" "token" "--hostname" "github.com")))))))
(advice-add 'ghub--token :before-until #'my/ghub-token-from-gh)

;; Поиск по всему GitHub из минибуфера: репозитории, issues, PR, код.
;; Также consult-gh-repo-clone, consult-gh-dashboard, consult-gh-notifications.
(use-package consult-gh
  :after consult
  :bind ("M-s g" . consult-gh-search-repos)
  :custom
  (consult-gh-default-clone-directory "~/src")
  (consult-gh-show-preview t)
  ;; Предпросмотр по требованию, а не на каждом кандидате:
  ;; каждый показ — это запрос к API GitHub.
  (consult-gh-preview-key "M-o")
  :config
  ;; Посещённые организации и репозитории всплывают наверх между сессиями.
  (add-to-list 'savehist-additional-variables 'consult-gh--known-orgs-list)
  (add-to-list 'savehist-additional-variables 'consult-gh--known-repos-list))

;; Действия embark над кандидатами: клонировать, открыть в браузере и т.п.
(use-package consult-gh-embark
  :after (consult-gh embark)
  :config (consult-gh-embark-mode 1))

;; Выбранные issue/PR открываются в буферах forge, а не в просмотре gh.
(use-package consult-gh-forge
  :after (consult-gh forge)
  :config (consult-gh-forge-mode 1))

(provide 'development/github)
;;; github.el ends here
