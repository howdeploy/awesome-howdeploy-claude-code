---
description: "Настройка tweakcc — кастомизация интерфейса Claude Code через удобный опрос на русском"
trigger_phrases:
  - "tweakcc"
  - "настрой tweakcc"
  - "настройка claude code"
  - "кастомизация claude code"
  - "поменяй тему"
  - "смени тему claude"
  - "настрой интерфейс"
  - "tweakcc настройки"
  - "конфигуратор tweakcc"
  - "tweakcc config"
---

# tweakcc Configurator

Интерактивный конфигуратор tweakcc на русском языке. Вместо сложного TUI — пошаговый опрос через AskUserQuestion.

## Как работать

### 1. Прочитать текущий конфиг

Всегда начинай с чтения текущего состояния:

```
Read ~/.tweakcc/config.json
```

### 2. Показать меню категорий

Используй AskUserQuestion чтобы спросить, что настроить. Всегда на русском.

```
AskUserQuestion:
  question: "Что хочешь настроить в Claude Code?"
  header: "Раздел"
  options:
    - label: "Стартовый экран"
      description: "Баннер, лого Clawd, подсказка ctrl-g"
    - label: "Цветовая тема"
      description: "Выбрать из готовых или создать свою палитру"
    - label: "Поведение и фичи"
      description: "Swarm mode, память, лимиты, MCP, таблицы"
    - label: "Оформление ввода"
      description: "Рамка, стиль сообщений, формат"
  multiSelect: false
```

### 3. Категория: Стартовый экран

```
AskUserQuestion:
  question: "Что показывать при запуске Claude Code?"
  header: "Startup"
  multiSelect: true
  options:
    - label: "Скрыть баннер"
      description: "Убирает текст с email, версией и release notes"
    - label: "Скрыть лого Clawd"
      description: "Убирает ASCII-арт логотип"
    - label: "Скрыть ctrl-g подсказку"
      description: "Убирает 'ctrl-g to edit prompt in editor'"
    - label: "Оставить всё"
      description: "Ничего не менять"
```

Маппинг ответов на конфиг (`settings.misc`):

| Ответ | Ключ | Значение |
|-------|------|----------|
| Скрыть баннер | `hideStartupBanner` | `true` |
| Скрыть лого Clawd | `hideStartupClawd` | `true` |
| Скрыть ctrl-g | `hideCtrlGToEdit` | `true` |

### 4. Категория: Цветовая тема

Сначала покажи список существующих тем из `settings.themes[].name`:

```
AskUserQuestion:
  question: "Какую тему выбрать? (тема применится через /theme в Claude Code)"
  header: "Тема"
  options:
    - (динамически из массива themes)
    - label: "Создать новую"
      description: "Расскажи какие цвета хочешь — соберу палитру"
```

Если "Создать новую" — спроси стиль:

```
AskUserQuestion:
  question: "Какой стиль палитры?"
  header: "Стиль"
  options:
    - label: "Catppuccin Mocha"
      description: "Тёплый тёмный, пастельные акценты"
    - label: "Dracula"
      description: "Пурпурный тёмный, яркие акценты"
    - label: "Nord"
      description: "Холодный синий, арктические тона"
    - label: "Свои цвета"
      description: "Опиши словами или дай hex-коды"
```

#### Структура темы

Каждая тема — объект в массиве `settings.themes[]` с полями:
- `name` — отображаемое имя
- `id` — уникальный slug
- `colors` — объект с ~50 ключами RGB-цветов

Ключевые цвета для темы (остальные — производные):

| Ключ | Где используется |
|------|-----------------|
| `text` | Основной текст |
| `inverseText` | Текст на цветном фоне |
| `claude` | Цвет ответов Claude |
| `claudeShimmer` | Мерцание при печати |
| `claudeBlue_FOR_SYSTEM_SPINNER` | Системный спиннер |
| `permission` | Запросы разрешений |
| `promptBorder` | Рамка поля ввода |
| `success` | Успешные операции |
| `error` | Ошибки |
| `warning` | Предупреждения |
| `bashBorder` | Рамка bash-команд |
| `planMode` | Plan mode |
| `suggestion` | Подсказки |
| `inactive` | Неактивные элементы |
| `subtle` | Приглушённые элементы |
| `background` | Фон акцентов |
| `diffAdded` / `diffRemoved` | Диффы — добавлено/удалено |
| `diffAddedWord` / `diffRemovedWord` | Слова в диффах |
| `userMessageBackground` | Фон сообщений юзера |
| `bashMessageBackgroundColor` | Фон bash-блоков |
| `memoryBackgroundColor` | Фон блоков памяти |
| `clawd_body` | Цвет тела лого Clawd |
| `clawd_background` | Фон лого Clawd |
| `rate_limit_fill` / `rate_limit_empty` | Полоса rate limit |
| `rainbow_*` | Радужные цвета для субагентов |
| `*_FOR_SUBAGENTS_ONLY` | Цвета субагентов |
| `professionalBlue` | Проф. синий |

Формат значений: `rgb(R,G,B)` или `ansi:colorName`.

#### Популярные палитры (референс)

**Catppuccin Mocha:**
- Base: `rgb(30,30,46)` | Surface0: `rgb(49,50,68)` | Surface1: `rgb(69,71,90)`
- Text: `rgb(205,214,244)` | Subtext: `rgb(186,194,222)`
- Red: `rgb(243,139,168)` | Green: `rgb(166,227,161)` | Blue: `rgb(137,180,250)`
- Yellow: `rgb(249,226,175)` | Peach: `rgb(250,179,135)` | Mauve: `rgb(203,166,247)`
- Pink: `rgb(245,194,231)` | Teal: `rgb(148,226,213)` | Sky: `rgb(137,220,235)`
- Lavender: `rgb(180,190,254)` | Sapphire: `rgb(116,199,236)`
- Flamingo: `rgb(242,205,205)` | Rosewater: `rgb(245,224,220)`

**Dracula:**
- Background: `rgb(40,42,54)` | Current Line: `rgb(68,71,90)`
- Text: `rgb(248,248,242)` | Comment: `rgb(98,114,164)`
- Cyan: `rgb(139,233,253)` | Green: `rgb(80,250,123)` | Orange: `rgb(255,184,108)`
- Pink: `rgb(255,121,198)` | Purple: `rgb(189,147,249)` | Red: `rgb(255,85,85)`
- Yellow: `rgb(241,250,140)`

**Nord:**
- Polar Night: `rgb(46,52,64)` `rgb(59,66,82)` `rgb(67,76,94)` `rgb(76,86,106)`
- Snow Storm: `rgb(216,222,233)` `rgb(229,233,240)` `rgb(236,239,244)`
- Frost: `rgb(143,188,187)` `rgb(136,192,208)` `rgb(129,161,193)` `rgb(94,129,172)`
- Aurora: `rgb(191,97,106)` `rgb(208,135,112)` `rgb(235,203,139)` `rgb(163,190,140)` `rgb(180,142,173)`

### 5. Категория: Поведение и фичи

```
AskUserQuestion:
  question: "Какие фичи включить/выключить?"
  header: "Фичи"
  multiSelect: true
  options:
    - label: "Swarm Mode"
      description: "Мульти-агентный режим (нативный)"
    - label: "Память сессии"
      description: "Автоизвлечение контекста + поиск по прошлым сессиям"
    - label: "/remember скилл"
      description: "Команда для сохранения заметок между сессиями"
    - label: "Быстрый MCP"
      description: "Неблокирующее подключение MCP серверов при старте"
```

Далее вторая группа:

```
AskUserQuestion:
  question: "Дополнительные настройки?"
  header: "Ещё"
  multiSelect: true
  options:
    - label: "Убрать номера строк"
      description: "Скрыть '1>' префиксы из Read output"
    - label: "Больше файлов в Read"
      description: "Увеличить лимит токенов для чтения файлов"
    - label: "Авто-принятие plan mode"
      description: "Автоматически принимать план без подтверждения"
    - label: "Скрыть /rate-limit-options"
      description: "Не показывать подсказки по rate limit"
```

Маппинг ответов на конфиг (`settings.misc`):

| Ответ | Ключ | Значение |
|-------|------|----------|
| Swarm Mode | `enableSwarmMode` | `true` |
| Память сессии | `enableSessionMemory` | `true` |
| /remember скилл | `enableRememberSkill` | `true` |
| Быстрый MCP | `mcpConnectionNonBlocking` | `true` |
| Убрать номера строк | `suppressLineNumbers` | `true` |
| Больше файлов в Read | `increaseFileReadLimit` | `true` |
| Авто-принятие plan mode | `autoAcceptPlanMode` | `true` |
| Скрыть /rate-limit-options | `suppressRateLimitOptions` | `true` |

### 6. Категория: Оформление ввода

```
AskUserQuestion:
  question: "Как оформить поле ввода и сообщения?"
  header: "Input"
  multiSelect: true
  options:
    - label: "Убрать рамку"
      description: "Удалить border вокруг поля ввода"
    - label: "Формат таблиц: ASCII"
      description: "Таблицы с ASCII-символами вместо Unicode"
    - label: "Формат таблиц: Clean"
      description: "Чистые таблицы без боковых границ"
    - label: "Оставить как есть"
      description: "Ничего не менять"
```

Маппинг:

| Ответ | Ключ | Значение |
|-------|------|----------|
| Убрать рамку | `settings.inputBox.removeBorder` | `true` |
| Формат таблиц: ASCII | `settings.misc.tableFormat` | `"ascii"` |
| Формат таблиц: Clean | `settings.misc.tableFormat` | `"clean"` |

### 7. Дополнительно: Модели субагентов

```
AskUserQuestion:
  question: "Хочешь переопределить модели для субагентов?"
  header: "Models"
  options:
    - label: "Нет"
      description: "Использовать модели по умолчанию"
    - label: "Да"
      description: "Выбрать модели для Plan, Explore, General-purpose агентов"
```

Если "Да" — для каждого типа спросить модель. Конфиг: `settings.subagentModels.{plan|explore|generalPurpose}`.

### 8. Дополнительно: Thinking verbs

```
AskUserQuestion:
  question: "Настроить слова-глаголы при обдумывании?"
  header: "Verbs"
  options:
    - label: "Оставить текущие"
      description: "~170 забавных глаголов (Brewing, Moonwalking, Clauding...)"
    - label: "Только серьёзные"
      description: "Thinking, Processing, Analyzing, Computing"
    - label: "Русские глаголы"
      description: "Думаю, Обдумываю, Анализирую, Вычисляю..."
    - label: "Свой список"
      description: "Расскажи какие хочешь — добавлю"
```

**Русские глаголы (пресет):**
```json
["Думаю", "Обдумываю", "Анализирую", "Вычисляю", "Размышляю", "Прикидываю", "Соображаю", "Мудрствую", "Прорабатываю", "Генерирую", "Исследую", "Решаю", "Копаюсь", "Ворочаю извилинами", "Шурупю", "Кумекаю", "Калькулирую", "Ищу", "Собираю", "Формирую"]
```

**Серьёзные глаголы:**
```json
["Thinking", "Processing", "Analyzing", "Computing", "Evaluating", "Generating", "Reasoning", "Synthesizing"]
```

### 9. Применение изменений

После всех правок:

1. **Редактируй** `~/.tweakcc/config.json` через инструмент Edit, меняя только нужные ключи
2. **Применяй** патчи командой:
   ```bash
   tweakcc --apply
   ```
3. **Сообщи** пользователю:
   - Какие изменения применены
   - Нужно перезапустить Claude Code
   - Для смены темы — команда `/theme` внутри Claude Code
   - Для отката — `tweakcc --restore`

### 10. Откат

Если пользователь хочет вернуть всё назад:

```bash
tweakcc --restore
```

## Важные правила

1. Всегда **читай конфиг перед редактированием** — чтобы не сломать другие настройки
2. **Редактируй только нужные ключи** через Edit, не перезаписывай весь файл
3. **Не трогай** `ccVersion`, `ccInstallationPath`, `lastModified`, `changesApplied` — tweakcc управляет ими сам
4. После Edit **всегда запускай** `tweakcc --apply`
5. Если пользователь говорит просто "tweakcc" без конкретной задачи — покажи главное меню категорий
6. Если пользователь сразу говорит что хочет ("убери баннер", "поменяй тему") — пропускай меню, переходи к нужной категории
