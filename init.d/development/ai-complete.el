;;; ai-complete.el --- Локальный «copilot»: ghost text от llama.cpp -*- lexical-binding: t -*-

;; Дополняет, а не заменяет LSP: company показывает быстрые точные
;; кандидаты списком, minuet — многострочную серую подсказку (ghost text)
;; от локальной FIM-модели. Бэкенд — llama-server на порту 8012,
;; два systemd-юнита с общим портом и взаимным Conflicts=
;; (обе модели разом в 4 ГБ VRAM не влезают):
;;   llama-fim-qwen   — Qwen2.5-Coder-3B base, Q5_K_M
;;   llama-fim-mellum — JetBrains Mellum-4b base, Q4_K_M
;; M-x ai-complete-switch-model переключает юнит и формат FIM-промпта
;; синхронно. Когда сервер не запущен, подсказок просто нет.

(defun ai-complete--company-active-p ()
  "Не показывать ghost text поверх открытого списка company."
  (bound-and-true-p company-candidates))

(defun ai-complete--qwen-fim-prompt (ctx)
  "FIM-промпт в формате Qwen2.5-Coder из контекста CTX."
  (format "<|fim_prefix|>%s\n%s<|fim_suffix|>%s<|fim_middle|>"
          (plist-get ctx :language-and-tab)
          (plist-get ctx :before-cursor)
          (plist-get ctx :after-cursor)))

(defun ai-complete--mellum-fim-prompt (ctx)
  "FIM-промпт в формате Mellum из контекста CTX.
Mellum обучен на suffix-first порядке и маркере <filename>
вместо комментария с языком."
  (format "<filename>%s\n<fim_suffix>%s<fim_prefix>%s<fim_middle>"
          (if buffer-file-name
              (file-name-nondirectory buffer-file-name)
            (buffer-name))
          (plist-get ctx :after-cursor)
          (plist-get ctx :before-cursor)))

(defvar ai-complete--models
  '((qwen . ai-complete--qwen-fim-prompt)
    (mellum . ai-complete--mellum-fim-prompt))
  "Модели для сравнения: имя → функция FIM-промпта.
Имя должно совпадать с суффиксом systemd-юнита llama-fim-<имя>.")

(defvar ai-complete-model 'qwen
  "Текущая модель локального дополнения (ключ из `ai-complete--models').
Должна совпадать с юнитом, включённым на автозапуск в systemd.")

(defun ai-complete-switch-model (model)
  "Переключить модель: запустить юнит llama-fim-MODEL и сменить промпт.
Юнит другой модели останавливается сам через Conflicts= в systemd."
  (interactive
   (list (intern (completing-read
                  "Модель: " (mapcar #'car ai-complete--models) nil t))))
  (require 'minuet)
  (minuet-set-optional-options minuet-openai-fim-compatible-options
                               :prompt (alist-get model ai-complete--models)
                               :template)
  (setq ai-complete-model model)
  (start-process "llama-fim-switch" nil "systemctl" "--user" "start"
                 (format "llama-fim-%s" model))
  (message "Локальный copilot: %s (модель загружается несколько секунд)" model))

(defun ai-complete-toggle ()
  "Глобально включить/выключить авто-подсказки локального copilot.
Действует до перезапуска Emacs (по умолчанию включено через hook).
Ручной запрос подсказки по M-i работает и в выключенном состоянии."
  (interactive)
  (require 'minuet)
  (if (memq #'minuet-auto-suggestion-mode prog-mode-hook)
      (progn
        (remove-hook 'prog-mode-hook #'minuet-auto-suggestion-mode)
        (dolist (buf (buffer-list))
          (with-current-buffer buf
            (when (bound-and-true-p minuet-auto-suggestion-mode)
              (minuet-auto-suggestion-mode -1))))
        (message "Локальный copilot: авто-подсказки выключены (M-i — вручную)"))
    (add-hook 'prog-mode-hook #'minuet-auto-suggestion-mode)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (derived-mode-p 'prog-mode)
          (minuet-auto-suggestion-mode 1))))
    (message "Локальный copilot: авто-подсказки включены")))

(defun ai-complete-toggle-buffer ()
  "Включить/выключить авто-подсказки только в текущем буфере.
Глобальный тумблер <f6> перекрывает буферный выбор: он проходит
по всем буферам и выставляет режим заново."
  (interactive)
  (require 'minuet)
  (if (bound-and-true-p minuet-auto-suggestion-mode)
      (progn
        (minuet-auto-suggestion-mode -1)
        (message "Локальный copilot: выключен в %s" (buffer-name)))
    (minuet-auto-suggestion-mode 1)
    (message "Локальный copilot: включён в %s" (buffer-name))))

(use-package minuet
  :hook (prog-mode . minuet-auto-suggestion-mode)
  :bind (("<f6>" . ai-complete-toggle)
         ("C-<f6>" . ai-complete-toggle-buffer)
         ("M-i" . minuet-show-suggestion)
         :map minuet-active-mode-map
         ;; Карта активна, только пока подсказка на экране, поэтому
         ;; TAB здесь не мешает company и yasnippet.
         ("TAB" . minuet-accept-suggestion)
         ("<tab>" . minuet-accept-suggestion)
         ("M-a" . minuet-accept-suggestion-line)
         ("M-n" . minuet-next-suggestion)
         ("M-p" . minuet-previous-suggestion)
         ("M-e" . minuet-dismiss-suggestion))
  :custom
  (minuet-provider 'openai-fim-compatible)
  ;; Два варианта: первый показывается сразу, второй доезжает следом —
  ;; по ним листают M-n/M-p. Больше не стоит: каждый вариант — отдельная
  ;; генерация на GPU при каждой авто-подсказке.
  (minuet-n-completions 2)
  (minuet-context-window 4096)
  (minuet-auto-suggestion-block-predicates
   '(minuet-evil-not-insert-state-p ai-complete--company-active-p))
  :config
  (plist-put minuet-openai-fim-compatible-options
             :end-point "http://127.0.0.1:8012/v1/completions")
  (plist-put minuet-openai-fim-compatible-options :name "llama.cpp")
  ;; Локальному серверу ключ не нужен, но проверка доступности провайдера
  ;; требует непустого значения.
  (plist-put minuet-openai-fim-compatible-options :api-key (lambda () "local"))
  ;; Модель фиксируется при старте llama-server, поле — формальность.
  (plist-put minuet-openai-fim-compatible-options :model "local-fim")
  ;; llama-server не принимает suffix отдельным полем — собираем полный
  ;; FIM-промпт с токенами модели сами, а suffix из шаблона убираем.
  (minuet-set-optional-options minuet-openai-fim-compatible-options
                               :prompt (alist-get ai-complete-model
                                                  ai-complete--models)
                               :template)
  (minuet-set-optional-options minuet-openai-fim-compatible-options
                               :suffix nil :template)
  ;; Короткая подсказка — примерно секунда генерации на 3050 Ti.
  (minuet-set-optional-options minuet-openai-fim-compatible-options
                               :max_tokens 64))

(provide 'development/ai-complete)
;;; ai-complete.el ends here
