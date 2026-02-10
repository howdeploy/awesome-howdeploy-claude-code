---
name: orchestration-builder
description: This skill should be used when user says "create pipeline", "новый пайплайн", "создай пайплайн", "pipeline wizard", "добавь пайплайн", "build workflow", "orchestration builder", "конструктор пайплайнов", "мастер создания пайплайна", "new pipeline", "создать воркфлоу".
---

# Orchestration Builder — Мастер создания пайплайнов

Интерактивный мастер для создания orchestration пайплайнов, агентов и их регистрации в Claude Code.

## Что создаёт этот скилл

1. **Workflow файл** — `~/.claude/workflows/{name}.flow`
2. **Агенты** — `~/.claude/agents/{agent-name}.md` для каждого агента
3. **Регистрация** — добавление агентов в `external-agents.json`
4. **Документация** — секция в `~/.claude/CLAUDE.md`

## Процесс создания

Пройди через 5 фаз интерактивного мастера, используя AskUserQuestion для каждого этапа.

---

## Фаза 1: Концепт пайплайна

### Вопрос 1.1: Название

Запроси название пайплайна в kebab-case формате.

```
AskUserQuestion:
- question: "Как назвать пайплайн? (kebab-case, например: code-review-pipeline)"
- header: "Название"
- options:
  - label: "Ввести вручную"
    description: "Напишите название в формате kebab-case"
```

### Вопрос 1.2: Назначение

```
AskUserQuestion:
- question: "Какое назначение пайплайна?"
- header: "Тип"
- options:
  - label: "Research/Analysis"
    description: "Сбор и анализ информации, исследования"
  - label: "Development"
    description: "Разработка, тестирование, код-ревью"
  - label: "Content"
    description: "Создание контента, тексты, промпты"
  - label: "Data Processing"
    description: "Обработка и трансформация данных"
```

### Вопрос 1.3: Параметры

```
AskUserQuestion:
- question: "Какие параметры нужны пайплайну?"
- header: "Params"
- multiSelect: true
- options:
  - label: "topic"
    description: "Тема для обработки"
  - label: "target"
    description: "Файл или директория"
  - label: "style"
    description: "Стиль или режим работы"
  - label: "output_path"
    description: "Путь для сохранения результата"
```

---

## Фаза 2: Дизайн агентов

### Вопрос 2.1: Количество агентов

```
AskUserQuestion:
- question: "Сколько агентов в пайплайне?"
- header: "Агенты"
- options:
  - label: "2 агента"
    description: "Простой пайплайн: анализ + обработка"
  - label: "3 агента (Рекомендуется)"
    description: "Стандартный: анализ + обработка + проверка"
  - label: "4+ агентов"
    description: "Сложный пайплайн с несколькими этапами"
```

### Для каждого агента задай вопросы:

**Вопрос 2.N.1: Роль**

```
AskUserQuestion:
- question: "Какая роль у агента #{N}?"
- header: "Роль"
- options:
  - label: "Analyzer"
    description: "Анализ входных данных, классификация"
  - label: "Processor"
    description: "Основная обработка, выполнение задачи"
  - label: "Reviewer"
    description: "Проверка качества, валидация результатов"
  - label: "Communicator"
    description: "Взаимодействие с пользователем, итоговый вывод"
```

**Вопрос 2.N.2: Модель**

```
AskUserQuestion:
- question: "Какую модель использовать для {role}?"
- header: "Модель"
- options:
  - label: "sonnet (Рекомендуется)"
    description: "Баланс качества и стоимости"
  - label: "opus"
    description: "Максимальное качество, сложные задачи (дорого)"
  - label: "haiku"
    description: "Быстро и дёшево, простые задачи"
```

**Вопрос 2.N.3: Инструменты**

```
AskUserQuestion:
- question: "Какие инструменты нужны {role}?"
- header: "Tools"
- multiSelect: true
- options:
  - label: "Файловые (Read, Write, Glob, Grep)"
    description: "Чтение, запись, поиск файлов"
  - label: "Bash"
    description: "Выполнение shell команд"
  - label: "Web (WebSearch, WebFetch)"
    description: "Поиск и получение веб-контента"
  - label: "Tavily"
    description: "Продвинутый поиск и исследования"
```

---

## Фаза 3: Структура workflow

### Вопрос 3.1: Тип потока

```
AskUserQuestion:
- question: "Как агенты взаимодействуют?"
- header: "Flow"
- options:
  - label: "Sequential: A -> B -> C"
    description: "Последовательное выполнение"
  - label: "Parallel: [A || B] -> C"
    description: "Параллельные этапы, затем объединение"
  - label: "Conditional: A ~> B / C"
    description: "Условное ветвление по результату"
  - label: "With checkpoints"
    description: "С точками ревью пользователем"
```

### Вопрос 3.2: Точки ревью

```
AskUserQuestion:
- question: "Где добавить точки ревью (@review)?"
- header: "Review"
- multiSelect: true
- options:
  - label: "Перед финальным шагом"
    description: "Одобрение перед завершением"
  - label: "После анализа"
    description: "Проверка результатов анализа"
  - label: "Между каждым этапом"
    description: "Полный контроль (медленнее)"
  - label: "Без ревью"
    description: "Полностью автоматический пайплайн"
```

---

## Фаза 4: Документация

### Вопрос 4.1: Триггерные фразы

```
AskUserQuestion:
- question: "Какие фразы будут запускать пайплайн?"
- header: "Triggers"
- multiSelect: true
- options:
  - label: "По названию"
    description: '"{name}" / "{name} pipeline" / "запусти {name}"'
  - label: "Action-based"
    description: '"run {name}" / "execute {name}"'
  - label: "Goal-based"
    description: "По назначению: 'проанализируй', 'создай контент'"
  - label: "Custom"
    description: "Ввести свои триггерные фразы"
```

### Вопрос 4.2: Сохранение результатов

```
AskUserQuestion:
- question: "Куда сохранять результаты работы?"
- header: "Output"
- options:
  - label: "Obsidian vault"
    description: "В папку заметок Obsidian"
  - label: "Текущая директория"
    description: "В рабочую директорию пользователя"
  - label: "Custom путь"
    description: "Указать конкретный путь"
  - label: "Не сохранять"
    description: "Только вывод в консоль"
```

---

## Фаза 5: Генерация

После сбора всей информации выполни:

### 5.1 Создай workflow файл

**Путь:** `~/.claude/workflows/{name}.flow`

Используй шаблон из `templates/workflow.tmpl`:

```yaml
---
name: {name}
description: {description}
params:
  {param}: {param_description}
---

Workflow:

{agent1}:"{task1}" ->
{agent2}:"{task2}" ->
@review:"Одобрить результат?" ->
{agent3}:"{task3}"
```

### 5.2 Создай агентов

**Путь:** `~/.claude/agents/{agent-name}.md`

Используй шаблон из `templates/agent.tmpl`:

```markdown
# {Display Name}

---
model: {model}
description: {description}
tools:
  - {tool1}
  - {tool2}
---

{instructions}

## Задачи
{responsibilities}

## Процесс
{process_steps}

## Формат вывода
{output_format}
```

### 5.3 Обнови external-agents.json

**Путь:** `~/.claude/plugins/cache/orchestration-marketplace/orchestration/1.0.0/skills/managing-agents/external-agents.json`

Для каждого агента добавь запись:

```json
"{agent-name}": {
  "path": "~/.claude/agents/{agent-name}.md",
  "description": "{description}",
  "model": "{model}",
  "registered": "{YYYY-MM-DD}",
  "usageCount": 0
}
```

### 5.4 Обнови CLAUDE.md

**Путь:** `~/.claude/CLAUDE.md`

Добавь секцию в конец файла, используя шаблон `templates/claude-md-section.tmpl`:

```markdown
---

## {Display Name} Pipeline

{description}

### Триггерные фразы
{trigger_phrases}

### Запуск
\`\`\`
/orchestration:template {name}
\`\`\`

### Агенты

| Агент | Модель | Роль |
|-------|--------|------|
| {agent1} | {model1} | {role1} |
| {agent2} | {model2} | {role2} |

### Результаты
{output_section}
```

### 5.5 Валидация

Запусти проверку:

```bash
~/.claude/skills/orchestration-builder/scripts/validate-pipeline.sh {name}
```

---

## Справочники

Подробная документация по форматам:

- `references/workflow-format.md` — синтаксис .flow файлов
- `references/agent-format.md` — структура агентов
- `references/registry-format.md` — формат external-agents.json

---

## Пример использования

**Пользователь:** "Создай пайплайн для код-ревью"

**Результат после прохождения мастера:**

1. `~/.claude/workflows/code-review-pipeline.flow`
2. `~/.claude/agents/code-analyzer.md`
3. `~/.claude/agents/code-reviewer.md`
4. `~/.claude/agents/review-reporter.md`
5. Записи в external-agents.json
6. Секция в CLAUDE.md

**Запуск:** `/orchestration:template code-review-pipeline`
