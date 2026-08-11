;;; package-management.el --- Архивы и use-package -*- lexical-binding: t -*-

;; Единственное место, где настраиваются архивы пакетов.
;; gnu и nongnu присутствуют в package-archives по умолчанию.
;; Установленные пакеты Emacs активирует сам ещё до init.el
;; (package-enable-at-startup) — явный package-initialize был бы
;; повторной активацией.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; use-package встроен в Emacs 29+. Каждый use-package сам ставит свой пакет;
;; для встроенных пакетов указываем :ensure nil.
(setq use-package-always-ensure t)

(provide 'basics/package-management)
;;; package-management.el ends here
