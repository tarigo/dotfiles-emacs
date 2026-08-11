;;; finance.el --- Бухгалтерия: ledger-mode -*- lexical-binding: t -*-

;; Двойная запись в текстовом файле (plain text accounting).
;; Нужен CLI `ledger` (pacman -S ledger). Файл живёт в ~/org,
;; чтобы синхронизироваться вместе с остальными заметками.
(require 'productivity/init-org)  ; my/org-dir

(defvar my/ledger-file (expand-file-name "finance.ledger" my/org-dir)
  "Главный файл бухгалтерии.")
(unless (file-exists-p my/ledger-file)
  (with-temp-file my/ledger-file
    (insert ";; -*- mode: ledger -*-\n\n")))

;; Категории, счета и валюта для capture-шаблонов ниже.
;; Реальная структура бюджета — личное: переопределяется в private.el.
(defvar my/ledger-expense-categories '("Food" "Home" "Transport" "Health" "Fun" "Misc")
  "Категории Expenses:* в шаблоне расхода.")
(defvar my/ledger-income-categories '("Salary" "Misc")
  "Категории Income:* в шаблоне дохода.")
(defvar my/ledger-accounts '("Checking" "Cash")
  "Счета Assets:* в шаблонах расхода и дохода.")
(defvar my/ledger-currency "EUR"
  "Валюта сумм в шаблонах.")

(use-package ledger-mode
  :mode "\\.ledger\\'"
  :custom
  ;; ISO-даты: 2026-08-05, а не 2026/08/05.
  (ledger-default-date-format "%Y-%m-%d")
  ;; В reconcile-режиме помечать транзакцию целиком, а не отдельные строки.
  (ledger-clear-whole-transactions t)
  (ledger-reports
   '(("bal" "%(binary) -f %(ledger-file) bal")
     ("месяц: расходы" "%(binary) -f %(ledger-file) bal Expenses --period 'this month'")
     ("месяц: cashflow" "%(binary) -f %(ledger-file) bal Income Expenses --period 'this month' --invert")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)"))))

;; Несбалансированные транзакции подсвечиваются прямо в буфере.
(use-package flycheck-ledger
  :after (flycheck ledger-mode))

;; Capture: расход и доход из любого места (C-c c e / C-c c i).
;; Шаблоны собираются при первом org-capture — private.el к этому моменту
;; уже загружен и переопределил категории выше.
(with-eval-after-load 'org-capture
  (let ((expenses (mapconcat #'identity my/ledger-expense-categories "|"))
        (income   (mapconcat #'identity my/ledger-income-categories "|"))
        (accounts (mapconcat #'identity my/ledger-accounts "|")))
    (add-to-list 'org-capture-templates
                 `("e" "Expense (ledger)" plain (file ,my/ledger-file)
                   ,(concat "%(format-time-string \"%Y-%m-%d\") * %^{Кому платили}\n"
                            "    Expenses:%^{Категория|" expenses "}"
                            "  %^{Сумма} " my/ledger-currency "\n"
                            "    Assets:%^{Откуда|" accounts "}")
                   :empty-lines 1)
                 t)
    (add-to-list 'org-capture-templates
                 `("i" "Income (ledger)" plain (file ,my/ledger-file)
                   ,(concat "%(format-time-string \"%Y-%m-%d\") * %^{Источник}\n"
                            "    Assets:%^{Куда|" accounts "}"
                            "  %^{Сумма} " my/ledger-currency "\n"
                            "    Income:%^{Категория|" income "}")
                   :empty-lines 1)
                 t)))

(provide 'productivity/finance)
;;; finance.el ends here
