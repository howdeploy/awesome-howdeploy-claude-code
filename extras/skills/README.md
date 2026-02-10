# Skill Examples

Ready-made skill prompts for Claude Code. Skills are markdown files that define Claude's behavior in specific scenarios — they activate on trigger phrases and follow a structured algorithm.

## What's included

| Skill | Description | Trigger phrases |
|-------|-------------|-----------------|
| [Content Writer](content-writer/SKILL.md) | Blog posts, articles, reviews with style matching from reference files | "написать текст", "создать пост", "накидать тему" |
| [Emotional Support](emotional-support/SKILL.md) | Empathetic support mode with active listening and CBT reframing | "мне нужна поддержка", "хочу поговорить", "мне плохо" |

## How skills work

Skills are `.md` files placed in `~/.claude/skills/{skill-name}/SKILL.md`. They contain:

1. **YAML frontmatter** — `name`, `description`, `trigger_phrases`
2. **Instructions** — detailed algorithm for Claude to follow
3. **Examples** — sample dialogues showing expected behavior

When Claude detects a matching trigger phrase, it loads the skill and follows its instructions.

## How to use

Open this repo in Claude Code and ask it to set up a skill for you, or manually copy the skill file:

```bash
mkdir -p ~/.claude/skills/content-writer
cp extras/skills/content-writer/SKILL.md ~/.claude/skills/content-writer/
```

## Creating your own skills

Use these examples as templates. Key elements:

```markdown
---
name: my-skill
description: "Brief description of what the skill does"
trigger_phrases:
  - "phrase that activates this skill"
  - "another trigger phrase"
---

# Skill Title

## When to use
[Trigger conditions]

## Algorithm
[Step-by-step instructions]

## Examples
[Sample dialogues]
```

## Customization

- **Content Writer**: Add your own writing samples to `references/` folder
- **Emotional Support**: Adjust the tone and approach in the instructions
