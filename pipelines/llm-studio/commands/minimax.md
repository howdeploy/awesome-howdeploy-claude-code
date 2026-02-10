---
description: "Minimax M2 Her - диалоги, ролевые игры, личности агентов"
---

# /minimax

Отправить запрос к **Minimax M2 Her** через OpenRouter API.

## Arguments: {{ARGS}}

## Execution

1. Если `{{ARGS}}` пусто — спросить промпт через AskUserQuestion
2. Выполнить скрипт:

```bash
~/.claude/scripts/llm-studio/minimax-query.sh "{{ARGS}}"
```

3. Вернуть результат в чат как есть

## Специализация

- Диалоги с выраженной личностью
- Ролевые игры и персонажи
- Поддержание характера агента

## Примеры

```
/minimax Play the role of a wise mentor
/minimax Continue the dialogue as a skeptical investor
/minimax Create a personality for a tech support AI assistant
```
