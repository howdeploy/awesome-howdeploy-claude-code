#!/bin/bash

# Validate Pipeline
# Проверяет корректность созданного пайплайна
#
# Usage: validate-pipeline.sh <pipeline-name>

set -e

PIPELINE_NAME="$1"

if [ -z "$PIPELINE_NAME" ]; then
    echo "❌ Ошибка: укажите имя пайплайна"
    echo "Usage: validate-pipeline.sh <pipeline-name>"
    exit 1
fi

WORKFLOW_FILE="$HOME/.claude/workflows/${PIPELINE_NAME}.flow"
AGENTS_DIR="$HOME/.claude/agents"
REGISTRY_FILE="$HOME/.claude/plugins/cache/orchestration-marketplace/orchestration/1.0.0/skills/managing-agents/external-agents.json"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

echo "🔍 Валидация пайплайна: $PIPELINE_NAME"
echo "=================================="
echo ""

ERRORS=0
WARNINGS=0

# 1. Проверка workflow файла
echo "1️⃣ Проверка workflow файла..."
if [ -f "$WORKFLOW_FILE" ]; then
    echo "   ✅ $WORKFLOW_FILE существует"

    # Проверка frontmatter
    if grep -q "^---" "$WORKFLOW_FILE" && grep -q "^name:" "$WORKFLOW_FILE"; then
        echo "   ✅ Frontmatter корректен"
    else
        echo "   ❌ Frontmatter некорректен или отсутствует"
        ((ERRORS++))
    fi

    # Проверка наличия Workflow:
    if grep -q "^Workflow:" "$WORKFLOW_FILE"; then
        echo "   ✅ Секция Workflow найдена"
    else
        echo "   ❌ Секция 'Workflow:' не найдена"
        ((ERRORS++))
    fi
else
    echo "   ❌ Файл не существует: $WORKFLOW_FILE"
    ((ERRORS++))
fi
echo ""

# 2. Извлечение агентов из workflow
echo "2️⃣ Проверка агентов..."
if [ -f "$WORKFLOW_FILE" ]; then
    # Извлекаем имена агентов из workflow (формат: orchestration:agent-name:"task")
    AGENTS=$(grep -oP 'orchestration:\K[a-z0-9-]+(?=:)' "$WORKFLOW_FILE" 2>/dev/null | sort -u)

    if [ -z "$AGENTS" ]; then
        echo "   ⚠️ Агенты не найдены в workflow (возможно другой формат)"
        ((WARNINGS++))
    else
        for AGENT in $AGENTS; do
            AGENT_FILE="$AGENTS_DIR/${AGENT}.md"
            if [ -f "$AGENT_FILE" ]; then
                echo "   ✅ $AGENT -> $AGENT_FILE"

                # Проверка frontmatter агента
                if grep -q "^model:" "$AGENT_FILE"; then
                    MODEL=$(grep "^model:" "$AGENT_FILE" | head -1 | cut -d: -f2 | tr -d ' ')
                    if [[ "$MODEL" =~ ^(opus|sonnet|haiku)$ ]]; then
                        echo "      ✅ Модель: $MODEL"
                    else
                        echo "      ❌ Некорректная модель: $MODEL"
                        ((ERRORS++))
                    fi
                else
                    echo "      ⚠️ Модель не указана"
                    ((WARNINGS++))
                fi
            else
                echo "   ❌ Агент не найден: $AGENT_FILE"
                ((ERRORS++))
            fi
        done
    fi
fi
echo ""

# 3. Проверка реестра
echo "3️⃣ Проверка регистрации..."
if [ -f "$REGISTRY_FILE" ]; then
    echo "   ✅ Реестр существует"

    if [ -n "$AGENTS" ]; then
        for AGENT in $AGENTS; do
            if grep -q "\"$AGENT\"" "$REGISTRY_FILE"; then
                echo "   ✅ $AGENT зарегистрирован"
            else
                echo "   ❌ $AGENT НЕ зарегистрирован в external-agents.json"
                ((ERRORS++))
            fi
        done
    fi
else
    echo "   ❌ Реестр не найден: $REGISTRY_FILE"
    ((ERRORS++))
fi
echo ""

# 4. Проверка CLAUDE.md
echo "4️⃣ Проверка документации..."
if [ -f "$CLAUDE_MD" ]; then
    # Ищем секцию пайплайна (с учётом разных форматов названия)
    SEARCH_PATTERN=$(echo "$PIPELINE_NAME" | sed 's/-/ /g')
    if grep -qi "$SEARCH_PATTERN\|$PIPELINE_NAME" "$CLAUDE_MD"; then
        echo "   ✅ Секция найдена в CLAUDE.md"
    else
        echo "   ⚠️ Секция пайплайна не найдена в CLAUDE.md"
        ((WARNINGS++))
    fi
else
    echo "   ⚠️ CLAUDE.md не найден"
    ((WARNINGS++))
fi
echo ""

# 5. Итоги
echo "=================================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ Пайплайн $PIPELINE_NAME валиден!"
    echo ""
    echo "Запуск: /orchestration:template $PIPELINE_NAME"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️ Пайплайн $PIPELINE_NAME валиден с предупреждениями"
    echo "   Предупреждений: $WARNINGS"
    echo ""
    echo "Запуск: /orchestration:template $PIPELINE_NAME"
    exit 0
else
    echo "❌ Пайплайн $PIPELINE_NAME имеет ошибки!"
    echo "   Ошибок: $ERRORS"
    echo "   Предупреждений: $WARNINGS"
    echo ""
    echo "Исправьте ошибки перед запуском."
    exit 1
fi
