;;; kotlin.el --- Kotlin: kotlin-mode + kotlin-lsp -*- lexical-binding: t -*-

(use-package kotlin-mode
  :hook (kotlin-mode . lsp))

(with-eval-after-load 'lsp-mode
  ;; Штатный клиент kotlin-ls — общественный kotlin-language-server,
  ;; который не понимает Android Gradle Plugin: AAR-зависимости (Compose)
  ;; и генерируемый класс R не резолвятся.
  (add-to-list 'lsp-disabled-clients 'kotlin-ls)
  ;; Официальный сервер JetBrains (пакет kotlin-lsp-bin) с экспериментальной
  ;; поддержкой AGP. Первый запуск на большом проекте молчит минуты —
  ;; идёт Gradle-sync и индексация, прогресс виден в *lsp-log*.
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("kotlin-lsp" "--stdio"))
    :major-modes '(kotlin-mode kotlin-ts-mode)
    :priority 1
    :server-id 'jetbrains-kotlin-lsp)))

(provide 'development/kotlin)
;;; kotlin.el ends here
