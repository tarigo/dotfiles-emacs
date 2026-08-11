;;; early-init.el --- Загружается до инициализации пакетов и UI -*- lexical-binding: t -*-

;; Поднимаем порог GC на время загрузки; после старта возвращаем разумный.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024))))

;; Читать больше данных за раз из подпроцессов — важно для LSP (rust-analyzer).
(setq read-process-output-max (* 4 1024 1024))

;; Отключаем элементы UI до создания первого фрейма — без мигания при старте.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq inhibit-startup-message t)

;;; early-init.el ends here
