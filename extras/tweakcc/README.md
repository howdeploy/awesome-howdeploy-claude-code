# tweakcc Configurator

Interactive Claude Code interface customization via [tweakcc](https://github.com/nicekid1/tweakcc). Instead of a complex TUI, this skill provides a step-by-step questionnaire in Russian through `AskUserQuestion`.

## What it customizes

| Category | Settings |
|----------|----------|
| Startup screen | Hide banner, Clawd logo, ctrl-g hint |
| Color themes | 11 built-in themes (4 Catppuccin flavors, Dark, Light, ANSI, Colorblind, Monochrome) or custom |
| Features | Swarm mode, session memory, /remember, fast MCP, line numbers, file read limit |
| Input formatting | Border removal, table format (ASCII/Clean/default) |
| Thinking verbs | ~170 fun verbs, serious-only, Russian, or custom list |
| Subagent models | Override models for Plan, Explore, General-purpose agents |

## Files

| File | Description |
|------|-------------|
| `SKILL.md` | Skill prompt with the interactive configurator algorithm |
| `config.json.example` | Example tweakcc config with 11 themes and all settings |

## Installation

```bash
# Copy the skill
mkdir -p ~/.claude/skills/tweakcc-configurator
cp extras/tweakcc/SKILL.md ~/.claude/skills/tweakcc-configurator/

# Copy the config (optional, tweakcc creates its own on first run)
mkdir -p ~/.tweakcc
cp extras/tweakcc/config.json.example ~/.tweakcc/config.json
```

## Requirements

- Claude Code
- [tweakcc](https://github.com/nicekid1/tweakcc) installed and available in PATH

## Triggers

- "tweakcc" / "настрой tweakcc"
- "настройка claude code" / "кастомизация claude code"
- "поменяй тему" / "смени тему claude"
- "настрой интерфейс" / "tweakcc config"

## Included themes

1. **Catppuccin Mocha (Rosewater)** —darkest, warm rosewater accent, soft diffs
2. **Catppuccin Latte (Rosewater)** —light, warm pastel with rosewater accent
3. **Catppuccin Frappe (Rosewater)** —muted dark, subdued rosewater
4. **Catppuccin Macchiato (Rosewater)** —medium dark, gentle rosewater
5. **Dark mode** —standard dark with RGB colors
6. **Light mode** —standard light with RGB colors
7. **Light mode (ANSI)** —terminal-native ANSI colors
8. **Dark mode (ANSI)** —terminal-native ANSI colors
9. **Light mode (colorblind-friendly)** —high-contrast accessible palette
10. **Dark mode (colorblind-friendly)** —high-contrast accessible palette
11. **Monochrome** —grayscale only

## Commands

```bash
tweakcc --apply    # Apply config changes
tweakcc --restore  # Revert all changes
```
