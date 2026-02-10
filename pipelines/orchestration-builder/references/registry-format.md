# Registry Format (external-agents.json)

Справочник по формату реестра внешних агентов.

## Расположение

```
~/.claude/plugins/cache/orchestration-marketplace/orchestration/1.0.0/skills/managing-agents/external-agents.json
```

## Структура JSON

```json
{
  "externalAgents": {
    "agent-name": {
      "path": "~/.claude/agents/agent-name.md",
      "description": "Краткое описание агента",
      "model": "sonnet",
      "registered": "2026-02-02",
      "usageCount": 0
    }
  },
  "lastUpdated": "2026-02-02T12:00:00+03:00"
}
```

## Поля агента

### path (обязательное)

Путь к файлу агента. Всегда начинается с `~/.claude/agents/`.

```json
"path": "~/.claude/agents/my-custom-agent.md"
```

### description (обязательное)

Краткое описание для отображения в списках. 1-2 предложения.

```json
"description": "Анализирует код на качество и находит потенциальные проблемы"
```

### model (обязательное)

Модель для выполнения. Одно из: `opus`, `sonnet`, `haiku`.

```json
"model": "sonnet"
```

### registered (обязательное)

Дата регистрации в формате YYYY-MM-DD.

```json
"registered": "2026-02-02"
```

### usageCount (опционально)

Счётчик использований. Инкрементируется при каждом запуске.

```json
"usageCount": 42
```

## Операции

### Добавление агента

```javascript
// Читаем файл
const registry = JSON.parse(Read(REGISTRY_PATH));

// Добавляем агента
registry.externalAgents["new-agent"] = {
  path: "~/.claude/agents/new-agent.md",
  description: "Описание нового агента",
  model: "sonnet",
  registered: new Date().toISOString().split('T')[0],
  usageCount: 0
};

// Обновляем timestamp
registry.lastUpdated = new Date().toISOString();

// Записываем обратно
Write(REGISTRY_PATH, JSON.stringify(registry, null, 2));
```

### Удаление агента

```javascript
const registry = JSON.parse(Read(REGISTRY_PATH));

// Удаляем запись
delete registry.externalAgents["agent-to-remove"];

// Обновляем timestamp
registry.lastUpdated = new Date().toISOString();

Write(REGISTRY_PATH, JSON.stringify(registry, null, 2));
```

### Обновление агента

```javascript
const registry = JSON.parse(Read(REGISTRY_PATH));

// Обновляем поля
registry.externalAgents["existing-agent"].description = "Новое описание";
registry.externalAgents["existing-agent"].model = "opus";

registry.lastUpdated = new Date().toISOString();

Write(REGISTRY_PATH, JSON.stringify(registry, null, 2));
```

## Валидация

При добавлении агента проверяй:

1. **Файл существует:** `~/.claude/agents/{name}.md` должен существовать
2. **Уникальное имя:** Агент с таким именем не должен быть зарегистрирован
3. **Корректная модель:** Одно из `opus`, `sonnet`, `haiku`
4. **Формат даты:** YYYY-MM-DD

## Пример полного файла

```json
{
  "externalAgents": {
    "research-senior": {
      "path": "~/.claude/agents/research-senior.md",
      "description": "Глубокий сбор информации по теме. Классификация запросов, уточнение требований, поиск по источникам.",
      "model": "opus",
      "registered": "2026-02-02",
      "usageCount": 15
    },
    "research-editor": {
      "path": "~/.claude/agents/research-editor.md",
      "description": "Верификация, дополнение и финализация исследований.",
      "model": "sonnet",
      "registered": "2026-02-02",
      "usageCount": 12
    },
    "research-communicator": {
      "path": "~/.claude/agents/research-communicator.md",
      "description": "Общение с пользователем, финальный вывод результатов.",
      "model": "sonnet",
      "registered": "2026-02-02",
      "usageCount": 20
    }
  },
  "lastUpdated": "2026-02-02T15:30:00+03:00"
}
```

## Namespace в orchestration

После регистрации агент доступен по namespace:

```
orchestration:{agent-name}
```

Например:
- `orchestration:research-senior`
- `orchestration:code-analyzer`

Это используется в .flow файлах и при прямом вызове через Task tool.

## Синхронизация

Реестр синхронизируется между двумя расположениями:

1. `~/.claude/plugins/cache/...` — рабочая копия
2. `~/.claude/plugins/marketplaces/...` — копия из marketplace

При обновлении всегда меняй cache версию — она используется при выполнении.

## Troubleshooting

### Агент не виден в списке

1. Проверь, что файл существует: `ls ~/.claude/agents/`
2. Проверь запись в JSON: `cat external-agents.json | jq '.externalAgents["agent-name"]'`
3. Перезапусти Claude Code

### Агент не запускается

1. Проверь frontmatter агента (model, tools)
2. Проверь путь в реестре
3. Проверь права на файл

### Duplicate agent error

Агент с таким именем уже зарегистрирован. Удали старую запись или используй другое имя.
