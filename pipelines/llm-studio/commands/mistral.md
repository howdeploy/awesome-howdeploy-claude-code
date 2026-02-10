---
description: "Mistral Small Creative - креатив, маркетинг, ролевое общение"
---

# /mistral

Отправить запрос к **Mistral Small Creative** через OpenRouter API.

## Arguments: {{ARGS}}

## Execution

1. Если `{{ARGS}}` пусто — спросить промпт через AskUserQuestion
2. Выполнить скрипт:

```bash
~/.claude/scripts/llm-studio/mistral-query.sh "{{ARGS}}"
```

3. Вернуть результат в чат как есть

## Специализация

- Креативный контент для маркетинга
- Ролевое общение и персонажи
- Генерация идей и текстов

## Примеры

```
/mistral Come up with 5 slogans for an AI startup
/mistral Write a LinkedIn post about automation
/mistral Play the role of an experienced marketer
```
