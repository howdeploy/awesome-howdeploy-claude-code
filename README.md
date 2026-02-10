<div align="center">

# Claude Code Starter Kit

**A real Claude Code setup — skills, pipelines, hooks, commands, and orchestration. Clone, open in Claude Code, deploy for yourself.**

**Реальная настройка Claude Code — скиллы, пайплайны, хуки, команды и оркестрация. Клонируй, открой в Claude Code, разверни у себя.**

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-blueviolet)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

---

[**На русском**](#русский) | [**In English**](#english)

</div>

---

<a id="русский"></a>

## На русском

### Что это

Это моя реальная рабочая настройка [Claude Code](https://docs.anthropic.com/en/docs/claude-code), которую я выложил чтобы вы могли развернуть такое же у себя. Здесь не абстрактные примеры, а конфиги, которые я использую каждый день: исследовательский пайплайн, оркестрация внешних LLM, скиллы для написания текстов и поддержки, кастомный статус-бар, хуки и slash-команды.

**Как это работает:** клонируете репо, открываете в Claude Code — он читает `CLAUDE.md`, видит форматы и примеры всех расширений, и может настроить вам то же самое или создать что-то новое по аналогии. Не нужно разбираться в форматах самому — Claude Code сделает это за вас.

### Что внутри

| Компонент | Тип | Описание | Требования |
|-----------|-----|----------|------------|
| [Research Pipeline](#research-pipeline-ru) | Пайплайн | 3 агента для структурированного веб-исследования с верификацией | Claude Code, Tavily plugin, Orchestration plugin |
| [LLM Studio](#llm-studio-ru) | Пайплайн | 5 внешних LLM через OpenRouter с отдельными slash-командами | Claude Code, Python 3, `OPENROUTER_API_KEY` |
| [Orchestration Builder](#orchestration-builder-ru) | Пайплайн | Интерактивный мастер для создания новых пайплайнов | Claude Code, Orchestration plugin |
| [DeepWiki Lookup](#deepwiki-lookup-ru) | Расширение | Автоматический анализ GitHub-репозиториев через deepwiki.com | Claude Code, Tavily plugin |
| [Statusline](#statusline-ru) | Расширение | Кастомный статус-бар: контекст, стоимость, rate limit, таймер | Claude Code, curl |
| [Hook Examples](#hooks-ru) | Примеры | 6 примеров хуков: автоформат, блокировка секретов, lint и др. | Claude Code |
| [Skill Examples](#skills-ru) | Примеры | 2 готовых скилла: контент-райтер и эмоциональная поддержка | Claude Code |
| [Clawdbot Setup](#clawdbot-ru) | Пример | Полная настройка персонального AI-бота: личность, память, навыки, голос | Claude Code, Clawdbot Gateway |

### Быстрый старт

```bash
git clone https://github.com/howdeploy/awesome-howdeploy-claude-code.git
cd awesome-howdeploy-claude-code
claude
```

Откройте репозиторий в Claude Code и попросите настроить нужные компоненты:

- *"Настрой мне скилл контент-райтера как в примере"*
- *"Сделай мне пайплайн по аналогии с Research Pipeline"*
- *"Добавь хук для блокировки секретов из примеров"*
- *"Создай мне собственный скилл для код-ревью"*

Claude Code прочитает `CLAUDE.md` этого репозитория, изучит форматы всех расширений и поможет создать или адаптировать конфигурации под ваши задачи.

---

### Пайплайны

<a id="research-pipeline-ru"></a>

<details>
<summary><b>Research Pipeline (Ресерч-тян)</b> — структурированные веб-исследования</summary>

#### Обзор

Трёхагентный пайплайн для проведения глубоких исследований по любой теме. Ищет информацию через Tavily, верифицирует факты, структурирует результат и выдаёт готовый документ.

#### Агенты

| Агент | Модель | Роль |
|-------|--------|------|
| `research-senior` | Opus | Классификация темы, уточняющие вопросы, глубокий поиск через Tavily и Reddit |
| `research-editor` | Sonnet | Проверка на актуальность, противоречия, полноту данных |
| `research-communicator` | Sonnet | Общение с пользователем, структурирование финального документа |

#### Как это работает

1. **Senior** классифицирует тему и проводит многоуровневый поиск
2. На контрольных точках `@review` пользователь может скорректировать направление
3. **Editor** проверяет собранные данные на противоречия и пробелы
4. **Communicator** оформляет результат в структурированный документ

#### Запуск

```
/orchestration:template research-pipeline
```

Или скажите Claude: "исследуй тему X", "проведи ресерч по X", "запусти ресерч-тян".

#### Требования

- Claude Code
- [Tavily MCP plugin](https://github.com/tavily-ai/tavily-mcp) (для веб-поиска)
- [Orchestration plugin](https://github.com/anthropics/claude-code-orchestration) (для управления агентами)

</details>

<a id="llm-studio-ru"></a>

<details>
<summary><b>LLM Studio</b> — 5 внешних LLM через slash-команды</summary>

#### Обзор

Оркестрация сторонних LLM-моделей через OpenRouter API. Каждая модель доступна через свою slash-команду. Claude выступает оркестратором: анализирует задачу, вызывает нужную модель, интегрирует результат.

#### Модели и команды

| Slash-команда | Модель | Специализация |
|---------------|--------|---------------|
| `/kimi` | Kimi K2.5 | Длинный контекст, аналитика, суммаризация |
| `/deepseek` | DeepSeek V3.2 | Код, рефакторинг, технические задачи |
| `/codex` | GPT-5.2 Codex | Генерация и ревью кода |
| `/minimax` | Minimax M2 Her | Креативные тексты, копирайтинг, нейминг |
| `/mistral` | Mistral Small Creative | Лёгкий креатив, быстрые итерации |

#### Запуск

```
/orchestration:template llm-studio
```

Или используйте slash-команды напрямую: `/kimi "проанализируй этот код"`.

#### Настройка

```bash
export OPENROUTER_API_KEY='your-key-here'
```

Получите ключ на [openrouter.ai](https://openrouter.ai/).

#### Требования

- Claude Code
- Python 3
- Переменная окружения `OPENROUTER_API_KEY`

</details>

<a id="orchestration-builder-ru"></a>

<details>
<summary><b>Orchestration Builder</b> — конструктор пайплайнов</summary>

#### Обзор

Мета-инструмент для создания новых пайплайнов. Интерактивный мастер проведёт через 5 фаз: от концепта до полностью рабочего пайплайна с агентами, workflow-файлом и документацией.

#### 5 фаз мастера

1. **Концепт** — название, назначение, входные параметры
2. **Агенты** — роли, модели (opus/sonnet/haiku), инструменты каждого агента
3. **Workflow** — структура потока выполнения, контрольные точки
4. **Документация** — триггерные фразы, формат результатов, где сохранять
5. **Генерация** — создание всех файлов и регистрация в системе

#### Что создаёт

- Workflow-файл (`~/.claude/workflows/{name}.flow`)
- Файлы агентов (`~/.claude/agents/{agent}.md`)
- Регистрацию в `external-agents.json`
- Секцию документации в `CLAUDE.md`

#### Запуск

```
/orchestration-builder
```

Или скажите: "создай пайплайн", "новый пайплайн", "pipeline wizard".

#### Справочники формата

В составе идут справочники, которые мастер использует для валидации:

- `references/workflow-format.md` — формат workflow-файлов
- `references/agent-format.md` — формат файлов агентов
- `references/registry-format.md` — формат реестра агентов

#### Требования

- Claude Code
- [Orchestration plugin](https://github.com/anthropics/claude-code-orchestration)

</details>

---

### Дополнительно

<a id="deepwiki-lookup-ru"></a>

<details>
<summary><b>DeepWiki Lookup</b> — анализ GitHub-репозиториев</summary>

#### Обзор

Автоматический разбор любого публичного GitHub-репозитория через [deepwiki.com](https://deepwiki.com). Достаточно поделиться ссылкой на репозиторий — Claude сам запросит DeepWiki и выдаст структурированный анализ.

#### Что показывает

- **Что это** — краткое описание проекта
- **Архитектура** — ключевые компоненты и их связи
- **Стек** — языки, фреймворки, зависимости
- **Ключевые модули** — основные части кодовой базы
- **Как использовать** — быстрый старт

#### Как использовать

Просто отправьте ссылку на GitHub-репозиторий в чат:

```
https://github.com/anthropics/claude-code
```

Claude автоматически определит ссылку, запросит DeepWiki и выдаст анализ.

#### Требования

- Claude Code
- [Tavily MCP plugin](https://github.com/tavily-ai/tavily-mcp) (для извлечения данных с DeepWiki)

</details>

<a id="statusline-ru"></a>

<details>
<summary><b>Statusline</b> — кастомный статус-бар</summary>

#### Обзор

Кастомная строка состояния для Claude Code, которая показывает ключевые метрики прямо в интерфейсе.

#### Отображает

| Метрика | Описание |
|---------|----------|
| Context % | Процент использования контекстного окна |
| Session cost | Стоимость текущей сессии в долларах |
| 5h rate limit | Утилизация 5-часового лимита запросов |
| Reset timer | Таймер до сброса rate limit |

#### Установка

Скрипт `statusline.sh` настраивает кастомный статус-бар через API Claude Code.

#### Требования

- Claude Code
- curl

</details>

<a id="hooks-ru"></a>

<details>
<summary><b>Hook Examples</b> — 6 готовых примеров хуков</summary>

#### Обзор

Хуки — это скрипты, которые Claude Code вызывает автоматически на определённых этапах работы. В комплекте 6 практических примеров, покрывающих все основные типы хуков.

#### Примеры

| Хук | Тип | Что делает |
|-----|-----|-----------|
| Autoformat | `PostToolUse` | Автоматически форматирует код после каждого изменения файла |
| Block Secrets | `PreToolUse` | Блокирует коммиты и запись файлов, содержащих секреты/ключи |
| Notify | `Notification` | Отправляет уведомления при завершении длительных операций |
| Lint | `PostToolUse` | Запускает линтер после изменения файлов |
| Auto-test | `PostToolUse` | Автоматически запускает тесты после изменения кода |
| Context Warning | `Notification` | Предупреждает, когда контекст приближается к лимиту |

#### Типы хуков

- **`PreToolUse`** — выполняется перед вызовом инструмента (может заблокировать действие)
- **`PostToolUse`** — выполняется после вызова инструмента
- **`Notification`** — реагирует на системные уведомления

#### Требования

- Claude Code

</details>

<a id="skills-ru"></a>

<details>
<summary><b>Skill Examples</b> — 2 готовых скилла-промпта</summary>

#### Обзор

Скиллы — это промпт-файлы, которые определяют поведение Claude в конкретных сценариях. Активируются по триггерным фразам и следуют структурированному алгоритму. В комплекте 2 готовых примера.

#### Примеры

| Скилл | Что делает |
|-------|-----------|
| Content Writer | Создание постов и статей с исследованием темы через веб-поиск и адаптацией под стиль ваших референсов |
| Emotional Support | Режим эмоциональной поддержки: активное слушание, валидация чувств, CBT-рефрейминг |

#### Content Writer

- Анализирует референсы из папки `references/` для сохранения вашего стиля
- Проводит веб-поиск для актуальной информации
- Работает итеративно: черновик → правки → финальная версия
- Сохраняет результат в `AIText/YYYY-MM-DD-тема.md`

Триггеры: "написать текст", "создать пост", "накидать тему", "нужен черновой вариант"

#### Emotional Support

- Режим близкого друга-психолога с этичным подходом
- Активное слушание, отражение, валидация эмоций
- CBT-техники: выявление автоматических мыслей, рефрейминг
- Запись фундаментальных переживаний в память между сессиями

Триггеры: "хочу поговорить", "мне нужна поддержка", "мне плохо", "тяжело на душе"

#### Кастомизация

Используйте эти скиллы как шаблоны для создания своих. Ключевые элементы скилла:

1. YAML-фронтматтер с `name`, `description`, `trigger_phrases`
2. Пошаговый алгоритм работы
3. Примеры диалогов

#### Требования

- Claude Code

</details>

<a id="clawdbot-ru"></a>

<details>
<summary><b>Clawdbot Setup</b> — пример настройки персонального AI-бота</summary>

#### Обзор

Полный пример конфигурации персонального AI-ассистента (Clawdbot) — бот с собственной личностью, долгосрочной памятью, голосовым общением и специализированными навыками. Работает через Telegram на базе Claude Code.

Это не абстрактная инструкция, а документация реальной рабочей настройки.

#### Архитектура workspace

| Файл | Назначение |
|------|-----------|
| `SOUL.md` | Личность бота: характер, стиль общения, режимы работы |
| `USER.md` | Профиль владельца: привычки, цели, триггеры, предпочтения |
| `AGENTS.md` | Рабочие правила: загрузка контекста, безопасность, поведение в группах |
| `TOOLS.md` | Настройки инструментов: голос (Whisper + ElevenLabs), cron, Telegram |
| `MEMORY.md` | Долгосрочная память: события, уроки, контекст отношений |
| `HEARTBEAT.md` | Проактивность: периодические проверки, уведомления |

#### 11 навыков (skills)

- **audio-transcript-search** — сохранение и поиск по голосовым
- **concept-notes** — структурирование идей в заметки
- **crypto-translate** — перевод для крипто-контента (RU→EN)
- **emotional-support** — эмоциональная поддержка
- **gm-gn** — ритуалы утра/ночи с проверкой состояния
- **nano-banana / seedream** — генерация изображений
- **server-status** — мониторинг сервера
- **stream-timecodes** — таймкоды из VTT-файлов
- **task-reminder** — напоминания через cron
- **voice-summary** — суммаризация голосовых

#### Ключевые принципы

1. **Персонализация > Универсальность** — один хорошо настроенный ассистент лучше десяти универсальных
2. **Память критична** — без MEMORY.md теряется контекст отношений
3. **Skills делают магию** — специализированные навыки эффективнее универсальных промптов
4. **Heartbeat = проактивность** — не только ответы, но и инициатива

#### Подробности

Полная документация с примерами конфигов, описанием каждого компонента и lessons learned: [`extras/clawdbot/README.md`](extras/clawdbot/README.md)

#### Требования

- Claude Code
- [Clawdbot Gateway](https://github.com/nicekid1/Clawdbot) (для Telegram-интеграции)

</details>

---

### Структура проекта

```
claude-code-starter-kit/
├── configs/                          # Примеры конфигов
│   └── claude-md-sections/           #   Секции для CLAUDE.md
├── pipelines/
│   ├── research-pipeline/            # Ресерч-пайплайн
│   │   ├── agents/                   #   3 файла агентов
│   │   ├── workflows/                #   research-pipeline.flow
│   │   └── skills/                   #   SKILL.md
│   ├── llm-studio/                   # LLM Studio
│   │   ├── commands/                 #   5 slash-команд (.md)
│   │   └── scripts/                  #   API-скрипты + обёртки
│   └── orchestration-builder/        # Конструктор пайплайнов
│       ├── references/               #   Справочники формата
│       ├── scripts/                  #   Валидация
│       ├── skills/                   #   SKILL.md
│       └── templates/                #   Шаблоны генерации
├── extras/
│   ├── clawdbot/                     # Пример настройки AI-бота
│   │   └── README.md
│   ├── deepwiki-lookup/              # Анализ GitHub-репозиториев
│   ├── statusline/                   # Кастомный статус-бар
│   │   └── statusline.sh
│   ├── hooks/                        # Примеры хуков
│   │   └── examples/                 #   6 готовых примеров
│   └── skills/                       # Примеры скиллов
│       ├── content-writer/           #   Контент-райтер
│       │   └── SKILL.md
│       └── emotional-support/        #   Эмоциональная поддержка
│           └── SKILL.md
├── scripts/                          # Утилиты
│   └── restore-orchestration-agents.sh
├── docs/                             # Документация
├── CLAUDE.md                         # Справочник для Claude Code
├── LICENSE                           # MIT
└── README.md
```

### FAQ

<details>
<summary><b>Нужно ли использовать все компоненты?</b></summary>

Нет. Каждый компонент работает независимо. Выбирайте только то, что нужно, и попросите Claude Code настроить именно это.
</details>

<details>
<summary><b>Какие плагины Claude Code нужны?</b></summary>

Зависит от компонентов. Минимально — никаких. Для пайплайнов нужен Orchestration plugin, для поиска — Tavily MCP plugin. Подробности в таблице требований выше.
</details>

<details>
<summary><b>Как добавить свою LLM-модель в LLM Studio?</b></summary>

1. Добавьте alias модели в `openrouter-api.py` (словарь `MODEL_ALIASES`)
2. Создайте файл slash-команды в `commands/`
3. Создайте скрипт-обёртку в `scripts/`
4. При использовании с оркестрацией — зарегистрируйте агента в `external-agents.json`
</details>

<details>
<summary><b>Агенты не запускаются после обновления плагина</b></summary>

Запустите восстановление:

```bash
./scripts/restore-orchestration-agents.sh
```
</details>

<details>
<summary><b>Работает ли с Windows?</b></summary>

Claude Code работает на macOS и Linux. На Windows используйте WSL2.
</details>

---

<a id="english"></a>

## In English

### What is this

This is my actual working [Claude Code](https://docs.anthropic.com/en/docs/claude-code) setup, published so you can deploy the same thing for yourself. These aren't abstract examples — they're configs I use daily: a research pipeline, external LLM orchestration, content writing and support skills, a custom status bar, hooks, and slash commands.

**How it works:** clone the repo, open it in Claude Code — it reads `CLAUDE.md`, sees the formats and examples of every extension type, and can set up the same for you or build something new based on these patterns. You don't need to learn the formats yourself — Claude Code does it for you.

### What's inside

| Component | Type | Description | Requirements |
|-----------|------|-------------|--------------|
| [Research Pipeline](#research-pipeline-en) | Pipeline | 3 agents for structured web research with verification | Claude Code, Tavily plugin, Orchestration plugin |
| [LLM Studio](#llm-studio-en) | Pipeline | 5 external LLMs via OpenRouter with dedicated slash commands | Claude Code, Python 3, `OPENROUTER_API_KEY` |
| [Orchestration Builder](#orchestration-builder-en) | Pipeline | Interactive wizard for creating new pipelines | Claude Code, Orchestration plugin |
| [DeepWiki Lookup](#deepwiki-lookup-en) | Extension | Automatic GitHub repository analysis via deepwiki.com | Claude Code, Tavily plugin |
| [Statusline](#statusline-en) | Extension | Custom status bar: context, cost, rate limit, timer | Claude Code, curl |
| [Hook Examples](#hooks-en) | Examples | 6 hook examples: autoformat, block secrets, lint, and more | Claude Code |
| [Skill Examples](#skills-en) | Examples | 2 ready-made skills: content writer and emotional support | Claude Code |
| [Clawdbot Setup](#clawdbot-en) | Example | Full personal AI bot setup: personality, memory, skills, voice | Claude Code, Clawdbot Gateway |

### Quick start

```bash
git clone https://github.com/howdeploy/awesome-howdeploy-claude-code.git
cd awesome-howdeploy-claude-code
claude
```

Open the repo in Claude Code and ask it to set up the components you need:

- *"Set up the content writer skill from the examples"*
- *"Create a pipeline similar to Research Pipeline"*
- *"Add the secret-blocking hook from the examples"*
- *"Build me a custom skill for code review"*

Claude Code will read the `CLAUDE.md` in this repo, study all extension formats, and help you create or adapt configurations for your needs.

---

### Pipelines

<a id="research-pipeline-en"></a>

<details>
<summary><b>Research Pipeline</b> — structured web research</summary>

#### Overview

A three-agent pipeline for conducting deep research on any topic. Searches information via Tavily, verifies facts, structures the output, and delivers a ready-made document.

#### Agents

| Agent | Model | Role |
|-------|-------|------|
| `research-senior` | Opus | Topic classification, clarifying questions, deep search via Tavily and Reddit |
| `research-editor` | Sonnet | Verification for relevance, contradictions, and completeness |
| `research-communicator` | Sonnet | User communication, final document structuring |

#### How it works

1. **Senior** classifies the topic and performs multi-level search
2. At `@review` checkpoints, the user can adjust the research direction
3. **Editor** checks collected data for contradictions and gaps
4. **Communicator** formats the result into a structured document

#### Usage

```
/orchestration:template research-pipeline
```

Or tell Claude: "research topic X", "investigate X", "run research pipeline".

#### Requirements

- Claude Code
- [Tavily MCP plugin](https://github.com/tavily-ai/tavily-mcp) (for web search)
- [Orchestration plugin](https://github.com/anthropics/claude-code-orchestration) (for agent management)

</details>

<a id="llm-studio-en"></a>

<details>
<summary><b>LLM Studio</b> — 5 external LLMs via slash commands</summary>

#### Overview

Orchestration of third-party LLM models via the OpenRouter API. Each model is accessible through its own slash command. Claude acts as the orchestrator: analyzes the task, calls the appropriate model, and integrates the result.

#### Models and commands

| Slash command | Model | Specialization |
|---------------|-------|----------------|
| `/kimi` | Kimi K2.5 | Long context, analytics, summarization |
| `/deepseek` | DeepSeek V3.2 | Code, refactoring, technical tasks |
| `/codex` | GPT-5.2 Codex | Code generation and review |
| `/minimax` | Minimax M2 Her | Creative writing, copywriting, naming |
| `/mistral` | Mistral Small Creative | Light creative work, fast iterations |

#### Usage

```
/orchestration:template llm-studio
```

Or use slash commands directly: `/kimi "analyze this code"`.

#### Setup

```bash
export OPENROUTER_API_KEY='your-key-here'
```

Get your key at [openrouter.ai](https://openrouter.ai/).

#### Requirements

- Claude Code
- Python 3
- `OPENROUTER_API_KEY` environment variable

</details>

<a id="orchestration-builder-en"></a>

<details>
<summary><b>Orchestration Builder</b> — pipeline constructor</summary>

#### Overview

A meta-tool for creating new pipelines. An interactive wizard guides you through 5 phases: from concept to a fully working pipeline with agents, a workflow file, and documentation.

#### 5 wizard phases

1. **Concept** — name, purpose, input parameters
2. **Agents** — roles, models (opus/sonnet/haiku), tools for each agent
3. **Workflow** — execution flow structure, checkpoints
4. **Documentation** — trigger phrases, output format, storage locations
5. **Generation** — creating all files and registering in the system

#### What it creates

- Workflow file (`~/.claude/workflows/{name}.flow`)
- Agent files (`~/.claude/agents/{agent}.md`)
- Registration in `external-agents.json`
- Documentation section in `CLAUDE.md`

#### Usage

```
/orchestration-builder
```

Or say: "create pipeline", "new pipeline", "pipeline wizard".

#### Format references

Includes reference docs that the wizard uses for validation:

- `references/workflow-format.md` — workflow file format
- `references/agent-format.md` — agent file format
- `references/registry-format.md` — agent registry format

#### Requirements

- Claude Code
- [Orchestration plugin](https://github.com/anthropics/claude-code-orchestration)

</details>

---

### Extras

<a id="deepwiki-lookup-en"></a>

<details>
<summary><b>DeepWiki Lookup</b> — GitHub repository analysis</summary>

#### Overview

Automatic analysis of any public GitHub repository via [deepwiki.com](https://deepwiki.com). Just share a repository link — Claude will query DeepWiki and provide a structured analysis.

#### What it shows

- **What it is** — brief project description
- **Architecture** — key components and their relationships
- **Stack** — languages, frameworks, dependencies
- **Key modules** — main parts of the codebase
- **How to use** — quick start guide

#### How to use

Simply send a GitHub repository link in the chat:

```
https://github.com/anthropics/claude-code
```

Claude will automatically detect the link, query DeepWiki, and provide the analysis.

#### Requirements

- Claude Code
- [Tavily MCP plugin](https://github.com/tavily-ai/tavily-mcp) (for extracting data from DeepWiki)

</details>

<a id="statusline-en"></a>

<details>
<summary><b>Statusline</b> — custom status bar</summary>

#### Overview

A custom status bar for Claude Code that displays key metrics directly in the interface.

#### Displays

| Metric | Description |
|--------|-------------|
| Context % | Context window utilization percentage |
| Session cost | Current session cost in dollars |
| 5h rate limit | 5-hour request limit utilization |
| Reset timer | Countdown to rate limit reset |

#### Installation

The `statusline.sh` script configures a custom status bar via the Claude Code API.

#### Requirements

- Claude Code
- curl

</details>

<a id="hooks-en"></a>

<details>
<summary><b>Hook Examples</b> — 6 practical hook examples</summary>

#### Overview

Hooks are scripts that Claude Code calls automatically at specific stages of operation. Included are 6 practical examples covering all major hook types.

#### Examples

| Hook | Type | What it does |
|------|------|-------------|
| Autoformat | `PostToolUse` | Automatically formats code after each file change |
| Block Secrets | `PreToolUse` | Blocks commits and file writes containing secrets/keys |
| Notify | `Notification` | Sends notifications when long operations complete |
| Lint | `PostToolUse` | Runs linter after file changes |
| Auto-test | `PostToolUse` | Automatically runs tests after code changes |
| Context Warning | `Notification` | Warns when context approaches the limit |

#### Hook types

- **`PreToolUse`** — runs before a tool call (can block the action)
- **`PostToolUse`** — runs after a tool call
- **`Notification`** — reacts to system notifications

#### Requirements

- Claude Code

</details>

<a id="skills-en"></a>

<details>
<summary><b>Skill Examples</b> — 2 ready-made skill prompts</summary>

#### Overview

Skills are prompt files that define Claude's behavior in specific scenarios. They activate on trigger phrases and follow a structured algorithm. Included are 2 ready-made examples.

#### Examples

| Skill | What it does |
|-------|-------------|
| Content Writer | Creates blog posts and articles with web research and style matching from your reference files |
| Emotional Support | Empathetic support mode: active listening, emotion validation, CBT reframing techniques |

#### Content Writer

- Analyzes reference files from `references/` folder to match your writing style
- Performs web search for up-to-date information
- Works iteratively: draft → feedback → final version
- Saves results to `AIText/YYYY-MM-DD-topic.md`

Triggers: "write a post", "create content", "draft a text", "help me write"

#### Emotional Support

- Acts as a close friend with psychology skills, not a clinical therapist
- Active listening, reflection, emotion validation
- CBT techniques: identifying automatic thoughts, cognitive reframing
- Remembers key emotional patterns across sessions via memory

Triggers: "I need support", "I want to talk", "I feel bad", "I'm struggling"

#### Customization

Use these skills as templates for creating your own. Key elements of a skill:

1. YAML frontmatter with `name`, `description`, `trigger_phrases`
2. Step-by-step algorithm
3. Example dialogues

#### Requirements

- Claude Code

</details>

<a id="clawdbot-en"></a>

<details>
<summary><b>Clawdbot Setup</b> — personal AI bot configuration example</summary>

#### Overview

A complete configuration example for a personal AI assistant (Clawdbot) — a bot with its own personality, long-term memory, voice communication, and specialized skills. Runs via Telegram on top of Claude Code.

This is not an abstract guide — it's documentation of an actual working setup.

#### Workspace architecture

| File | Purpose |
|------|---------|
| `SOUL.md` | Bot personality: character traits, communication style, work modes |
| `USER.md` | Owner profile: habits, goals, triggers, preferences |
| `AGENTS.md` | Work rules: context loading, security, group chat behavior |
| `TOOLS.md` | Tool settings: voice (Whisper + ElevenLabs), cron, Telegram |
| `MEMORY.md` | Long-term memory: events, lessons, relationship context |
| `HEARTBEAT.md` | Proactivity: periodic checks, notifications |

#### 11 skills included

- **audio-transcript-search** — save and search voice messages
- **concept-notes** — structure ideas into notes
- **crypto-translate** — translate crypto content (RU→EN)
- **emotional-support** — emotional support mode
- **gm-gn** — morning/night rituals with wellness check
- **nano-banana / seedream** — image generation
- **server-status** — server monitoring
- **stream-timecodes** — timecodes from VTT files
- **task-reminder** — cron-based reminders
- **voice-summary** — voice message summarization

#### Key principles

1. **Personalization > Universality** — one well-tuned assistant beats ten generic ones
2. **Memory is critical** — without MEMORY.md, relationship context is lost
3. **Skills are magic** — specialized skills outperform universal prompts
4. **Heartbeat = proactivity** — not just responses, but initiative

#### Details

Full documentation with config examples, component descriptions, and lessons learned: [`extras/clawdbot/README.md`](extras/clawdbot/README.md)

#### Requirements

- Claude Code
- [Clawdbot Gateway](https://github.com/nicekid1/Clawdbot) (for Telegram integration)

</details>

---

### Project structure

```
claude-code-starter-kit/
├── configs/                          # Example configs
│   └── claude-md-sections/           #   Sections for CLAUDE.md
├── pipelines/
│   ├── research-pipeline/            # Research pipeline
│   │   ├── agents/                   #   3 agent files
│   │   ├── workflows/                #   research-pipeline.flow
│   │   └── skills/                   #   SKILL.md
│   ├── llm-studio/                   # LLM Studio
│   │   ├── commands/                 #   5 slash commands (.md)
│   │   └── scripts/                  #   API scripts + wrappers
│   └── orchestration-builder/        # Pipeline constructor
│       ├── references/               #   Format references
│       ├── scripts/                  #   Validation
│       ├── skills/                   #   SKILL.md
│       └── templates/                #   Generation templates
├── extras/
│   ├── clawdbot/                     # Personal AI bot setup example
│   │   └── README.md
│   ├── deepwiki-lookup/              # GitHub repo analysis
│   ├── statusline/                   # Custom status bar
│   │   └── statusline.sh
│   ├── hooks/                        # Hook examples
│   │   └── examples/                 #   6 ready-made examples
│   └── skills/                       # Skill examples
│       ├── content-writer/           #   Content writer
│       │   └── SKILL.md
│       └── emotional-support/        #   Emotional support
│           └── SKILL.md
├── scripts/                          # Utilities
│   └── restore-orchestration-agents.sh
├── docs/                             # Documentation
├── CLAUDE.md                         # Reference guide for Claude Code
├── LICENSE                           # MIT
└── README.md
```

### FAQ

<details>
<summary><b>Do I need to use all components?</b></summary>

No. Each component works independently. Pick what you need and ask Claude Code to set up just that.
</details>

<details>
<summary><b>Which Claude Code plugins are required?</b></summary>

Depends on the components. At minimum — none. Pipelines require the Orchestration plugin, search features require the Tavily MCP plugin. See the requirements table above for details.
</details>

<details>
<summary><b>How do I add a custom LLM model to LLM Studio?</b></summary>

1. Add a model alias in `openrouter-api.py` (the `MODEL_ALIASES` dictionary)
2. Create a slash command file in `commands/`
3. Create a wrapper script in `scripts/`
4. If using with orchestration — register the agent in `external-agents.json`
</details>

<details>
<summary><b>Agents don't start after a plugin update</b></summary>

Run the restore script:

```bash
./scripts/restore-orchestration-agents.sh
```
</details>

<details>
<summary><b>Does it work on Windows?</b></summary>

Claude Code runs on macOS and Linux. On Windows, use WSL2.
</details>

---

<div align="center">

MIT License &copy; 2026

Built for the Claude Code community

</div>
