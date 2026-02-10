#!/bin/bash
# Скрипт восстановления регистрации агентов для orchestration плагина
# Запускать после обновления плагина: ~/.claude/scripts/restore-orchestration-agents.sh

set -e

PLUGIN_ROOT="$HOME/.claude/plugins/cache/orchestration-marketplace/orchestration"
AGENTS_DIR="$HOME/.claude/agents"
BACKUP_FILE="$HOME/.claude/external-agents-backup.json"

# Найти актуальную версию плагина
PLUGIN_VERSION=$(ls -1 "$PLUGIN_ROOT" 2>/dev/null | sort -V | tail -1)

if [ -z "$PLUGIN_VERSION" ]; then
    echo "❌ Плагин orchestration не найден"
    exit 1
fi

TARGET_DIR="$PLUGIN_ROOT/$PLUGIN_VERSION/skills/managing-agents"
TARGET_FILE="$TARGET_DIR/external-agents.json"

echo "🔄 Восстановление агентов для orchestration v$PLUGIN_VERSION"

# Создать директорию если не существует
mkdir -p "$TARGET_DIR"

# Генерируем JSON с агентами
AGENTS_JSON='{"externalAgents":{'
FIRST=true

for agent_file in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file" .md)

        # Извлекаем описание из файла (первая строка после # или description в frontmatter)
        description=$(grep -m1 "^description:" "$agent_file" 2>/dev/null | sed 's/description: *//' || \
                     grep -m1 "^# " "$agent_file" 2>/dev/null | sed 's/^# //' || \
                     echo "Custom agent")

        # Извлекаем модель
        model=$(grep -m1 "^model:" "$agent_file" 2>/dev/null | sed 's/model: *//' || echo "sonnet")

        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            AGENTS_JSON="$AGENTS_JSON,"
        fi

        AGENTS_JSON="$AGENTS_JSON
    \"$agent_name\": {
      \"path\": \"~/.claude/agents/$agent_name.md\",
      \"description\": \"$description\",
      \"model\": \"$model\",
      \"registered\": \"$(date +%Y-%m-%d)\",
      \"usageCount\": 0
    }"
    fi
done

AGENTS_JSON="$AGENTS_JSON
  },
  \"lastUpdated\": \"$(date -Iseconds)\"
}"

# Сохраняем
echo "$AGENTS_JSON" > "$TARGET_FILE"
echo "$AGENTS_JSON" > "$BACKUP_FILE"

echo "✅ Зарегистрированы агенты:"
for agent_file in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        echo "   - $(basename "$agent_file" .md)"
    fi
done

# Обновляем available-agents.md
AVAILABLE_FILE="$TARGET_DIR/available-agents.md"
cat > "$AVAILABLE_FILE" << 'MARKDOWN'
# Available Agents for Orchestration

## Built-in Claude Code Agents

- **Explore** - Fast codebase exploration and search
- **general-purpose** - Multi-step tasks and research
- **Plan** - Implementation planning
- **Bash** - Command execution

## Registered External Agents

Custom agents from `~/.claude/agents/`:

MARKDOWN

for agent_file in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file" .md)
        description=$(grep -m1 "^description:" "$agent_file" 2>/dev/null | sed 's/description: *//' || echo "Custom agent")
        model=$(grep -m1 "^model:" "$agent_file" 2>/dev/null | sed 's/model: *//' || echo "sonnet")

        cat >> "$AVAILABLE_FILE" << AGENT
### $agent_name
**Description:** $description
**Model:** $model
**Usage:** \`orchestration:$agent_name:"task"\`

AGENT
    fi
done

echo "✅ Обновлён available-agents.md"
echo ""
echo "🚀 Готово! Теперь можно использовать:"
echo "   /orchestration:template research-pipeline"
echo "   /orchestration:run orchestration:research-senior:\"тема\""
