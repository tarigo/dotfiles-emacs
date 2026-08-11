;;; phosphor-theme.el --- Тема «зелёный фосфор» -*- lexical-binding: t -*-

;; Modus-vivendi, перекрашенная в «зелёный фосфор» рабочего стола — та же
;; палитра, что в waybar/fuzzel/mako/swaylock/ghostty: фон #050805,
;; текст #29cc29, поверхности #0a1f0a/#143214, тревоги #ffb000.
;; F5 переключает на светлую modus-operandi (стоковую) и обратно.

(use-package modus-themes
  :demand t
  :custom
  (modus-themes-to-toggle '(modus-vivendi modus-operandi))
  (modus-vivendi-palette-overrides
   '(;; Основа
     (bg-main "#050805") (bg-dim "#0a1f0a")
     (bg-active "#143214") (bg-inactive "#0a120a")
     (fg-main "#29cc29") (fg-dim "#157f15") (fg-alt "#21a321")
     (cursor "#29cc29") (border "#143214")
     ;; Базовые цвета сведены к зелёным и бирюзовым оттенкам фосфора;
     ;; красный и жёлтый — к янтарю, как тревоги на рабочем столе.
     (red "#ff9000") (red-warmer "#ff8000") (red-cooler "#ffa040")
     (red-faint "#cc7a33") (red-intense "#ff9000")
     (yellow "#ffb000") (yellow-warmer "#ffa000") (yellow-cooler "#ffc84d")
     (yellow-faint "#cc9033") (yellow-intense "#ffb000")
     (green "#29cc29") (green-warmer "#52cc52") (green-cooler "#21b83e")
     (green-faint "#21a321") (green-intense "#29cc29")
     (blue "#52cc52") (blue-warmer "#75d975") (blue-cooler "#41c388")
     (blue-faint "#21a321") (blue-intense "#52cc52")
     (magenta "#75d975") (magenta-warmer "#88d988") (magenta-cooler "#57d997")
     (magenta-faint "#51ad51") (magenta-intense "#75d975")
     (cyan "#36be88") (cyan-warmer "#57d9ad") (cyan-cooler "#2bad90")
     (cyan-faint "#24825f") (cyan-intense "#36d9a2")
     ;; Интерактивные фоны
     (bg-region "#143214") (bg-hl-line "#0a1f0a")
     (bg-completion "#143214") (bg-hover "#1f4a1f")
     (bg-paren-match "#1f5f1f")
     (bg-search-current "#5f4400") (bg-search-lazy "#143214")
     ;; Строка режима
     (bg-mode-line-active "#0a1f0a") (fg-mode-line-active "#29cc29")
     (border-mode-line-active "#21a321")
     (bg-mode-line-inactive "#050805") (fg-mode-line-inactive "#157f15")
     (border-mode-line-inactive "#143214")
     ;; Диффы: добавленное — зелёное, удалённое — янтарное
     (bg-added "#0a2f0a") (bg-added-faint "#0a1f0a")
     (bg-added-refine "#145f14") (fg-added "#29cc29")
     (bg-removed "#3f1c00") (bg-removed-faint "#2a1300")
     (bg-removed-refine "#6f3400") (fg-removed "#ffb000")
     (bg-changed "#2f2a00") (bg-changed-faint "#1f1c00")
     (bg-changed-refine "#5f5400") (fg-changed "#ffc84d")))
  :bind ("<f5>" . modus-themes-toggle)
  :config
  (load-theme 'modus-vivendi t)
  ;; Modus перекрашивает лица nerd-icons-* из палитры, и в фосфоре все
  ;; иконки (doom-modeline, dashboard, dired) становятся одинаково
  ;; зелёными. Возвращаем им родные цвета override-спеком: он сильнее
  ;; темы, а родной spec сам различает тёмный и светлый фон, так что
  ;; переключение по F5 ему не мешает.
  (with-eval-after-load 'nerd-icons
    (dolist (face (face-list))
      (when (string-prefix-p "nerd-icons-" (symbol-name face))
        (face-spec-set face (get face 'face-defface-spec)
                       'face-override-spec)))))

(provide 'basics/phosphor-theme)
;;; phosphor-theme.el ends here
