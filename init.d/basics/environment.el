;;; environment.el --- Переменные окружения из shell -*- lexical-binding: t -*-

;; Демон systemd и Emacs, запущенный из десктоп-лаунчера, получают урезанный
;; PATH (/usr/local/bin:/usr/bin): оба стартуют раньше, чем zsh импортирует
;; окружение в systemd --user. Из-за этого lsp не находит rust-analyzer и
;; прочие инструменты из ~/.local/bin.
;; exec-path-from-shell берёт PATH из login-шелла ($SHELL -l), читающего
;; .zshenv/.zprofile. Запуск из терминала (emacs -nw) наследует PATH шелла
;; и так — в этом случае пакет даже не загружается (:if).
(use-package exec-path-from-shell
  :if (or (daemonp) (display-graphic-p))
  :demand t
  :config (exec-path-from-shell-initialize))

(provide 'basics/environment)
;;; environment.el ends here
