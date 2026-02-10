
## Research Pipeline (Ресерч-тян)

Когда пользователь говорит что-то вроде:
- "загрузи мой ресерч пайплайн"
- "запусти ресерч-тян"
- "исследуй тему X" / "найди информацию про X"
- "ресерч пайплайн"
- "проведи исследование по X"
- "изучи тему X"

**Запусти через orchestration плагин:**

```
/orchestration:template research-pipeline
```

Введи тему исследования когда будет запрошен параметр `topic`.

### Агенты пайплайна

| Агент | Модель | Роль |
|-------|--------|------|
| orchestration:research-senior | opus | Классификация, уточнение, глубокий поиск через Tavily/Reddit |
| orchestration:research-editor | sonnet | Проверка на актуальность, противоречия, полноту |
| orchestration:research-communicator | sonnet | Общение с пользователем, финальный вывод |

### Если агенты не работают после обновления плагина
```bash
~/.claude/scripts/restore-orchestration-agents.sh
```

