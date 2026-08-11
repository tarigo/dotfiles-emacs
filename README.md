# Конфигурация Emacs

*English version: [README.en.md](README.en.md).*

Модульная конфигурация для Emacs 30+. Пакеты ставятся автоматически при
первом запуске (`use-package` + `:ensure`, архивы GNU/NonGNU ELPA и MELPA).

![Emacs: тема «зелёный фосфор», Treemacs, rustic + LSP, справа — сессия Claude Code](screenshots/overview.png)

*Тема «зелёный фосфор»: слева Treemacs, в центре Rust (rustic +
lsp-mode), справа — сессия Claude Code (claude-code-ide) в терминале
ghostel.*

## Установка на новой машине

```sh
git clone https://github.com/tarigo/dotfiles-emacs.git ~/.config/emacs
emacs   # пакеты доустановятся сами при первом старте
```

Локальный copilot (нужны llama.cpp и FIM-модели в `~/models`,
см. «Особенности»):

```sh
ln -s ~/.config/emacs/systemd/llama-fim-*.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now llama-fim-qwen
```

Внимание: `systemctl --user disable` удаляет и сам симлинк юнита —
перед повторным `enable` создайте его заново (`ln -s` выше).

Список выбранных пакетов (`package-selected-packages`) накапливается
при установке в локальном `custom.el` — файл в git не входит,
`M-x package-autoremove` безопасен на любой машине.

## Системные требования

### Система

- **Emacs 30+**, собранный с динамическими модулями и SQLite
  (стандартные пакеты Arch `emacs`/`emacs-wayland` подходят):
  модули нужны терминалу ghostel, SQLite — базе org-roam.
- **git** — magit и установка пакетов из git (`package-vc`:
  claude-code-ide).
- **systemd user session** — юниты локального copilot.
- **PATH login-шелла**: инструменты вне системного PATH
  (`~/.local/bin`, rustup) должны прописываться в `.zshenv`/`.zprofile` —
  демон Emacs получает PATH оттуда (exec-path-from-shell).
- **Интернет при первом запуске**: ELPA/MELPA, GitHub
  (claude-code-ide) и скачивание модуля ghostel.

### Шрифты

- **FiraCode Nerd Font** (`ttf-firacode-nerd`) — шрифт по умолчанию.
- Если иконки nerd-icons отображаются квадратами —
  `M-x nerd-icons-install-fonts` (доставит Symbols Nerd Font Mono).

### Пакеты

| Инструмент | Пакет (Arch) | Зачем |
|---|---|---|
| rust-analyzer | `rustup component add rust-analyzer` | LSP для Rust |
| clangd, clang-format | `clang` | LSP и форматирование C/C++ |
| zig, zls | `zig`, `zls` (версии должны совпадать) | LSP и zig fmt |
| kotlin-language-server | вручную в `~/.local/bin` | LSP для Kotlin |
| graphviz (`dot`) | `graphviz` | граф заметок org-roam |
| pandoc | `pandoc-cli` | экспорт из org (`ox-pandoc`) |
| bear | `bear` | `compile_commands.json` для Makefile-проектов |
| claude (CLI) | установщик Anthropic → `~/.local/bin` | claude-code-ide |
| llama.cpp (`llama-server`) | `llama.cpp-cuda` | локальный copilot |
| ledger | `ledger` | бухгалтерия (`ledger-mode`, отчёты) |
| Anki + AnkiConnect | опционально | пуш карточек из `study.org` |

### Локальный copilot — дополнительно

- GPU с ~4 ГБ VRAM — параметры юнитов подстроены под этот объём.
- Модели в `~/models` с точными именами из юнитов:
  `Qwen2.5-Coder-3B-Q5_K_M.gguf` и `Mellum-4b-base.Q4_K_M.gguf`.
- Юниты запускают `llama-server` по абсолютному пути `/usr/bin/llama-server`.

## Структура

```
early-init.el              — GC, read-process-output-max, отключение UI до первого фрейма
init.el                    — точка входа: пути, load-path, порядок модулей
init.d/
  basics/
    package-management.el  — архивы пакетов, use-package
    environment.el         — PATH из login-шелла для запуска демоном
    appearance.el          — modeline, шрифт, dashboard, запасные темы
    phosphor-theme.el      — тема «зелёный фосфор» (modus-vivendi + палитра)
    editing.el             — windmove, undo-tree, company
    completion.el          — vertico, consult, embark, orderless, marginalia
  development/
    common.el              — lsp-mode/lsp-ui, flycheck, magit, treemacs, yasnippet
    rust.el                — rustic + rust-analyzer, clippy, rustfmt on save
    kotlin.el              — kotlin-mode + lsp
    c-cpp.el               — clangd (clang-tidy), cmake-mode
    zig.el                 — zig-mode + zls, zig fmt on save
    kdl.el                 — kdl-mode: конфиги zellij и прочие *.kdl
    claude.el              — claude-code-ide: MCP-интеграция Claude Code
    ai-complete.el         — minuet: ghost text от локальной FIM-модели (llama.cpp)
  productivity/
    init-org.el            — org: agenda, capture, refile, babel, clocking
    roam.el                — org-roam + org-roam-ui: база знаний
    finance.el             — ledger-mode: бухгалтерия в текстовом файле
```

## Особенности

- **Shift-стрелки** переключают окна (windmove) — везде, включая org:
  org-команды с S-стрелок перенесены на альтернативы
  (`org-replace-disputed-keys`: `M-p`/`M-n`/`M--`/`M-+`).
- Бэкапы, авто-сохранения, история undo и БД org-roam — в `~/.cache/emacs/`.
- Org-файлы — в `~/org/` (создаются при первом запуске), заметки
  org-roam — в `~/org/roam/` отдельно от agenda-файлов.
- Форматирование при сохранении: Rust (rustfmt) и Zig (zig fmt) — да;
  C/C++ — намеренно нет (`M-x lsp-format-buffer` вручную, уважает
  `.clang-format` проекта).
- Блоки org-babel: emacs-lisp выполняется без подтверждения,
  shell/python — с подтверждением.
- Treemacs открывается только вручную (`C-c t`), но дальше сам следует
  за текущим файлом и проектом; `C-x o` в дерево не заходит.
- **Локальный copilot** (minuet): серые многострочные подсказки поверх
  обычного company/LSP; авто-подсказки не показываются, пока открыт
  список company. Бэкенд — `llama-server` на `localhost:8012`,
  два systemd-юнита в `systemd/` (в `~/.config/systemd/user/` — симлинки,
  см. «Установку»): `llama-fim-qwen` (Qwen2.5-Coder-3B base, автозапуск) и
  `llama-fim-mellum` (JetBrains Mellum-4b); взаимный `Conflicts=` —
  в 4 ГБ VRAM живёт только один. `M-x ai-complete-switch-model`
  переключает юнит и формат FIM-промпта вместе. На батарее:
  `systemctl --user stop llama-fim-qwen` — minuet просто молчит.

## Клавиши

### Общие

| Клавиша | Действие |
|---|---|
| `S-стрелки` | переключение окон |
| `F5` | тема: «фосфор» (modus-vivendi) ↔ светлая (modus-operandi) |
| `C-x g` | magit-status |
| `C-c t` | treemacs |
| `C-c C-'` | меню Claude Code |
| `C-c a` | org-agenda |
| `C-c c` | org-capture |
| `C-c o` | agenda-обзор «Overview» |

### Rust (rustic-mode, `C-c C-c …`)

| Клавиша | Действие |
|---|---|
| `M-j` | lsp-ui-imenu |
| `M-?` | найти ссылки |
| `C-c C-c l` | список ошибок flycheck |
| `C-c C-c a` | code action |
| `C-c C-c r` | переименовать |
| `C-c C-c q` / `Q` | перезапуск / остановка LSP |
| `C-c C-c s` | статус rust-analyzer |

### Локальный copilot (minuet)

| Клавиша | Действие |
|---|---|
| `F6` | вкл/выкл авто-подсказки (глобально; `M-i` работает всегда) |
| `M-i` | запросить подсказку вручную |
| `TAB` | принять подсказку целиком (пока она на экране) |
| `M-a` | принять только первую строку |
| `M-n` / `M-p` | другой вариант подсказки |
| `M-e` | скрыть подсказку |

### База знаний (org-roam, `C-c n …`)

| Клавиша | Действие |
|---|---|
| `C-c n f` | найти/создать заметку |
| `C-c n i` | вставить ссылку на узел |
| `C-c n c` | capture в заметку |
| `C-c n l` | обратные ссылки |
| `C-c n g` | граф (graphviz) |
| `C-c n t` / `a` | тег / алиас |
| `C-c n j` / `d` | дневник: новая запись / сегодня |
| `C-c n u` | org-roam-ui: граф в браузере (localhost:35901) |

### Capture-шаблоны org (`C-c c`)

`t` задача → inbox · `m` встреча · `w` тренировка ·
`s` покупки · `l` учебная карточка (study.org, формат anki-editor) ·
`e` / `i` расход / доход (ledger) · `j` журнал

## Замечания

- `.gitignore` работает по whitelist: новый файл конфигурации нужно
  явно добавить строкой `!/имя`.
- Локальные и рабочие настройки — в `private.el` в корне конфига:
  init.el загружает его, если он есть, а в git он не попадает (не входит
  в whitelist). Туда же — личные значения переменных finance.el
  (`my/ledger-expense-categories`, счета, валюта) и приватные
  capture-шаблоны.
- `custom.el` тоже живёт в корне локально и в git не входит: туда пишут
  только Custom и package.el (список выбранных пакетов).
- LSP: если проект не открывается, проверьте, не попал ли его корень
  (или `~/`!) в blocklist — `M-x lsp-workspace-blocklist-remove`.
