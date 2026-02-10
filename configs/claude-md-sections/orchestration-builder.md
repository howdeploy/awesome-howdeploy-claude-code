
## Orchestration Builder

Интерактивный мастер для создания новых пайплайнов, агентов и их регистрации.

### Триггерные фразы
- "create pipeline" / "создай пайплайн"
- "новый пайплайн" / "new pipeline"
- "pipeline wizard" / "мастер пайплайна"
- "добавь пайплайн" / "build workflow"
- "orchestration builder" / "конструктор пайплайнов"

### Запуск
```
/orchestration-builder
```

### Что создаёт
1. **Workflow файл** — `~/.claude/workflows/{name}.flow`
2. **Агенты** — `~/.claude/agents/{agent}.md`
3. **Регистрация** — запись в `external-agents.json`
4. **Документация** — секция в `CLAUDE.md`

### Фазы мастера
1. **Концепт** — название, назначение, параметры
2. **Агенты** — роли, модели, инструменты
3. **Workflow** — структура потока, checkpoints
4. **Документация** — триггеры, где сохранять результаты
5. **Генерация** — создание всех файлов

### Валидация
```bash
~/.claude/skills/orchestration-builder/scripts/validate-pipeline.sh {name}
```

