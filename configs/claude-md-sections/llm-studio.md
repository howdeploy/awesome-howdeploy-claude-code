
## LLM Studio

Оркестрация сторонних LLM моделей через OpenRouter API. 5 моделей доступны через slash-команды.

### Доступные модели

| Команда | Модель | Специализация |
|---------|--------|---------------|
| `/kimi` | Kimi K2.5 | Документы, код, контекст 262K |
| `/deepseek` | DeepSeek V3.2 | Универсальная, дешёвая |
| `/codex` | GPT-5.2 Codex | Код, программирование |
| `/minimax` | Minimax M2 Her | Диалоги, ролевые игры |
| `/mistral` | Mistral Small Creative | Креатив, маркетинг |

### Использование

```
/kimi Проанализируй этот документ
/codex Напиши функцию сортировки на Python
/deepseek Объясни как работает blockchain
/minimax Сыграй роль мудрого наставника
/mistral Придумай 5 слоганов для AI-стартапа
```

### С файлами (Kimi, DeepSeek, Codex)

```
/kimi Проанализируй договоры в contracts/
/codex Найди баги в src/utils.ts
```

### Требуется
```bash
export OPENROUTER_API_KEY='your-key'
```

