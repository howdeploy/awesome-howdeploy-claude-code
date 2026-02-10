---
description: "Kimi K2.5 - чтение документов и кода, контекст 262K"
---

# /kimi

Отправить запрос к **Kimi K2.5** через OpenRouter API.

## Arguments: {{ARGS}}

## Execution

### Шаг 1: Определить нужны ли файлы

Проанализируй `{{ARGS}}`:
- Упоминаются ли файлы, папки, документы?
- Есть ли слова: "проанализируй", "прочитай", "проверь", "файл", "документ", "код", "папка"?

### Шаг 2: Если нужны файлы — найти их

**ВАЖНО: Не читай содержимое файлов! Только список имён.**

Выполни `ls` для поиска файлов:
```bash
ls -la <путь>           # Список файлов в папке
ls <путь>/*.pdf         # PDF файлы
ls <путь>/*.{ts,js}     # Код
```

### Шаг 3: Сформировать команду

**Без файлов:**
```bash
~/.claude/scripts/llm-studio/kimi-query.sh "{{ARGS}}"
```

**С файлами:**
```bash
~/.claude/scripts/llm-studio/kimi-query.sh --files file1.pdf file2.pdf -- "{{ARGS}}"
```

**С glob-паттерном:**
```bash
~/.claude/scripts/llm-studio/kimi-query.sh --files "папка/*.pdf" -- "{{ARGS}}"
```

### Шаг 4: Выполнить и вернуть результат

Скрипт сам:
1. Прочитает файлы (PDF, DOCX, XLSX, код, текст)
2. Отправит в Kimi K2.5
3. Вернёт ответ

## Поддерживаемые форматы

| Формат | Как читается |
|--------|--------------|
| `.pdf` | pdftotext или pypdf |
| `.docx` | python-docx |
| `.xlsx` | pandas |
| `.ts`, `.js`, `.py`, `.md`, etc. | Как текст |

## Примеры

**Простой вопрос:**
```
/kimi What is an MCP server?
```

**Анализ файлов в папке:**
```
/kimi Analyze the contracts in contracts/
```

**Конкретный файл:**
```
/kimi Check src/index.ts for bugs
```
