# Workflow Format (.flow)

Справочник по синтаксису workflow файлов.

## Структура файла

```yaml
---
name: имя-пайплайна
description: Описание пайплайна
params:
  param1: Описание параметра 1
  param2: Описание параметра 2
---

Workflow:

{workflow_syntax}
```

## Операторы

### Sequential: `->`

Последовательное выполнение. Следующий шаг начинается после завершения предыдущего.

```
agent1:"task1" -> agent2:"task2" -> agent3:"task3"
```

### Parallel: `||`

Параллельное выполнение. Шаги выполняются одновременно.

```
[agent1:"task1" || agent2:"task2"] -> agent3:"merge results"
```

### Conditional: `~>`

Условный переход по результату предыдущего шага.

```
agent1:"analyze" -> (if valid)~> agent2:"process" ~> (else)~> agent3:"handle error"
```

## Checkpoints

### @review

Точка ревью — пользователь должен одобрить продолжение.

```
agent1:"analyze" -> @review:"Одобрить анализ?" -> agent2:"process"
```

### @confirm

Подтверждение без блокировки — информирует пользователя.

```
agent1:"task" -> @confirm:"Этап 1 завершён" -> agent2:"task2"
```

## Переменные

### Параметры: `{{param}}`

Доступ к параметрам, указанным в frontmatter.

```
agent1:"Исследовать тему: {{topic}}"
```

### Output: `{output}`

Передача результата предыдущего шага.

```
agent1:"analyze" -> agent2:"process {output}"
```

### Context: `{context}`

Доступ к общему контексту пайплайна.

```
agent:"работать с {context.file}"
```

## Форматы агентов

### Namespace агент

```
orchestration:agent-name:"task description"
```

### Полный путь

```
~/.claude/agents/custom-agent.md:"task description"
```

## Примеры

### Простой sequential

```yaml
---
name: simple-pipeline
description: Простой последовательный пайплайн
params:
  topic: Тема для обработки
---

Workflow:

orchestration:analyzer:"Проанализировать {{topic}}" ->
orchestration:processor:"Обработать результаты" ->
orchestration:reporter:"Сформировать отчёт"
```

### С параллельными шагами

```yaml
---
name: parallel-research
description: Параллельный сбор информации
params:
  topic: Тема исследования
---

Workflow:

orchestration:classifier:"Классифицировать {{topic}}" ->
[
  orchestration:web-searcher:"Поиск в вебе" ||
  orchestration:doc-searcher:"Поиск в документации"
] ->
orchestration:aggregator:"Объединить результаты" ->
@review:"Проверить результаты?" ->
orchestration:writer:"Написать итоговый отчёт"
```

### С условием

```yaml
---
name: conditional-flow
description: Пайплайн с условным переходом
params:
  target: Файл для анализа
---

Workflow:

orchestration:analyzer:"Проверить {{target}}" ->
(if errors)~> orchestration:fixer:"Исправить ошибки" ~>
(else)~> orchestration:reporter:"Отчёт: всё ОК"
```

## Best Practices

1. **Один агент — одна задача.** Не перегружайте агентов.

2. **Используйте @review перед деструктивными действиями.** Дайте пользователю контроль.

3. **Параллельте независимые шаги.** Ускоряет выполнение.

4. **Описания задач на русском.** Для ясности пользователю.

5. **Не более 5-7 шагов.** Слишком длинные пайплайны сложно отлаживать.
