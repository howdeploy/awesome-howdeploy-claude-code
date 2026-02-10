# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A starter kit of real, working Claude Code configurations — and a **learning resource**. This repo serves two purposes:

1. **Install and use** — ready-made pipelines, agents, skills, hooks, and commands that install into `~/.claude/`
2. **Learn and build your own** — every file is a reference example of how to extend Claude Code

When someone gives you this repo, study the examples below to understand all Claude Code extension mechanisms. Then you can help them create their own skills, agents, hooks, commands, and pipelines from scratch.

## Claude Code Extension Mechanisms — Complete Reference

Claude Code has 6 extension points. This repo contains working examples of each one. Study them to learn the formats.

---

### 1. Skills (prompt files that change Claude's behavior)

Skills are `.md` files that define how Claude should act in specific scenarios. They activate on trigger phrases and follow structured algorithms.

**Location:** `~/.claude/skills/{skill-name}/SKILL.md`

**Format:**
```markdown
---
name: my-skill
description: "Brief description"
trigger_phrases:
  - "phrase that activates this skill"
  - "another trigger"
---

# Skill Title

## When to use
[Conditions and trigger phrases]

## Algorithm
[Step-by-step instructions for Claude to follow]

## What NOT to do
[Explicit restrictions]

## Examples
[Sample dialogues showing expected behavior]
```

**Key principles:**
- Skills shape Claude's persona and workflow for a specific task
- They can include memory instructions (what to remember between sessions)
- They can define entry/exit triggers (when to activate and deactivate the mode)
- They can reference external files (e.g., `references/` folder for style samples)

**Examples in this repo:**
- `extras/skills/content-writer/SKILL.md` — content creation with web research and style matching from reference files
- `extras/skills/emotional-support/SKILL.md` — empathetic support mode with CBT techniques and memory
- `pipelines/research-pipeline/skills/SKILL.md` — pipeline launcher skill with trigger phrases
- `pipelines/orchestration-builder/skills/SKILL.md` — interactive wizard skill with multi-phase AskUserQuestion flow

---

### 2. Agents (specialized AI personas for pipelines)

Agents are `.md` files with YAML frontmatter that define a focused AI persona with specific model, tools, and instructions. They are invoked by the orchestration plugin as part of workflows.

**Location:** `~/.claude/agents/{agent-name}.md`

**Format:**
```markdown
# Agent Display Name

---
model: sonnet
description: One or two sentences about what this agent does.
tools:
  - Read
  - Grep
  - WebSearch
---

You are a [role]. Your task is [objective].

## Tasks
1. First responsibility
2. Second responsibility

## Process
### Step 1: ...
### Step 2: ...

## Output Format
[Template of expected output]

## Important
- What this agent should NOT do
- Boundaries and constraints
```

**Frontmatter fields:**
- `model` (required): `opus` (complex reasoning, expensive), `sonnet` (balanced, recommended default), `haiku` (fast/cheap, simple tasks)
- `description` (required): 1-2 sentences, shown in agent listings
- `tools` (optional): list of allowed tools. Only grant what's needed:
  - File: `Read`, `Write`, `Edit`, `Glob`, `Grep`
  - Shell: `Bash`
  - Web: `WebSearch`, `WebFetch`
  - Tavily: `mcp__plugin_tavily-tools_tavily__tavily_search`, `mcp__plugin_tavily-tools_tavily__tavily_extract`
  - Interactive: `AskUserQuestion`

**Best practices:**
- One agent = one job. Don't overload agents with unrelated tasks
- Include output format templates so the next agent in chain can parse results
- State limitations explicitly ("do NOT communicate directly with user")
- Use markers for information quality (confirmed/doubtful/not-found)

**Examples in this repo:**
- `pipelines/research-pipeline/agents/research-senior.md` — opus agent with Tavily tools, structured research process
- `pipelines/research-pipeline/agents/research-editor.md` — sonnet agent for verification
- `pipelines/research-pipeline/agents/research-communicator.md` — sonnet agent for user communication

---

### 3. Workflows (.flow files for multi-agent pipelines)

Workflow files define execution order of agents using a DSL with 4 operators.

**Location:** `~/.claude/workflows/{name}.flow`

**Format:**
```yaml
---
name: my-pipeline
description: What this pipeline does.
params:
  topic: The subject to process
---

Workflow:

orchestration:agent1:"Task description: {{topic}}" ->
orchestration:agent2:"Process the results" ->
@review:"Approve before continuing?" ->
orchestration:agent3:"Generate final output"
```

**Operators:**
- `->` sequential: `A -> B -> C` (run in order, output feeds forward)
- `||` parallel: `[A || B] -> C` (A and B run simultaneously, C gets both outputs)
- `~>` conditional: `A ~> B / C` (branch on A's result)
- `@review:"question"` checkpoint: pause and ask user for approval

**Variables:** `{{param}}` for pipeline parameters, `{output}` for previous step output

**Example in this repo:**
- `pipelines/research-pipeline/workflows/research-pipeline.flow` — 7-step research pipeline with review checkpoint

---

### 4. Slash Commands (custom `/command` shortcuts)

Slash commands are markdown files that define custom commands invoked with `/<name>` in Claude Code.

**Location:** `~/.claude/commands/{name}.md`

**Format:**
```markdown
---
description: "Brief description shown in command listing"
---

# /command-name

What this command does.

## Arguments: {{ARGS}}

## Execution

1. Analyze `{{ARGS}}`
2. Run the appropriate action:
```bash
~/.claude/scripts/my-script.sh "{{ARGS}}"
```
3. Return the result to the user

## Examples
```
/command-name Hello world
```
```

**Key elements:**
- `{{ARGS}}` placeholder gets replaced with everything after the command name
- Commands can invoke shell scripts, call APIs, read/write files
- Include step-by-step instructions and examples

**Examples in this repo:**
- `pipelines/llm-studio/commands/codex.md` — GPT-5.2 Codex via OpenRouter with file detection logic
- `pipelines/llm-studio/commands/kimi.md` — Kimi K2.5 for long context analysis
- `pipelines/llm-studio/commands/deepseek.md`, `minimax.md`, `mistral.md` — more LLM commands

---

### 5. Hooks (automated actions on events)

Hooks are shell commands that execute automatically when specific Claude Code events occur. Configured in `settings.json`.

**Location:** `~/.claude/settings.json` (under `"hooks"` key)

**Format:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "your-shell-command-here"
          }
        ]
      }
    ]
  }
}
```

**Hook events:**
- `PreToolUse` — before a tool is called. Exit code 2 = block the action. Use for: blocking secrets, validating inputs
- `PostToolUse` — after a tool completes. Use for: autoformatting, linting, running tests
- `Notification` — on system notifications. Use for: desktop alerts, context warnings
- `Stop` — when Claude finishes a response

**Matcher:** regex pattern matched against tool name (`"Bash"`, `"Write"`, `".*"` for all)

**Environment variables available in hooks:**
- `$CLAUDE_TOOL_INPUT` — the tool's input (JSON)
- `$CLAUDE_TOOL_OUTPUT` — the tool's output (PostToolUse only)

**Examples in this repo:**
- `extras/hooks/examples/block-secret-commits.json` — PreToolUse hook that blocks git commits containing API keys
- `extras/hooks/examples/autoformat-on-save.json` — PostToolUse hook for auto-formatting
- `extras/hooks/examples/notify-on-completion.json` — Notification hook for desktop alerts
- `extras/hooks/examples/lint-before-commit.json` — PostToolUse linting
- `extras/hooks/examples/auto-test-on-edit.json` — PostToolUse test runner
- `extras/hooks/examples/context-warning.json` — Notification hook for context limit warnings

---

### 6. CLAUDE.md (global instructions for Claude)

`~/.claude/CLAUDE.md` is the global instruction file that Claude reads in every session. It defines trigger phrases, pipeline documentation, behavioral rules, and custom workflows.

**Location:** `~/.claude/CLAUDE.md` (global) or `project-dir/CLAUDE.md` (per-project)

**Key uses:**
- Define trigger phrases that launch pipelines or activate behaviors
- Document available commands and their usage
- Set behavioral rules and preferences
- Configure tool-specific instructions (e.g., DeepWiki lookup algorithm)

**Idempotency pattern for installer-managed sections:**
```markdown
<!-- STARTER-KIT:section-name:START -->
## Section Title
Content here...
<!-- STARTER-KIT:section-name:END -->
```
The installer checks for markers before appending to prevent duplicates on re-install.

**Examples in this repo:**
- `configs/CLAUDE.md.example` — full example with pipeline triggers, LLM Studio commands, builder docs
- `configs/claude-md-sections/` — individual sections that get appended to CLAUDE.md by the installer

---

### Settings.json (statusline, permissions, plugins)

`~/.claude/settings.json` configures hooks, statusline, enabled plugins, and permissions.

**Example in this repo:** `configs/settings.json.example`

**Statusline configuration:**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

The statusline script (`extras/statusline/statusline.sh`) receives session JSON on stdin and outputs colored text showing context usage, cost, and rate limits.

---

## Full Bot Setup Example (Clawdbot)

`extras/clawdbot/README.md` contains a complete real-world example of a personal AI assistant built on Claude Code. It demonstrates how to combine all the extension mechanisms above into a cohesive bot with:

- **SOUL.md** — bot personality (character, style, modes)
- **USER.md** — owner profile (habits, goals, preferences)
- **AGENTS.md** — behavioral rules (context loading, security, group chat etiquette)
- **TOOLS.md** — tool configuration (voice via Whisper + ElevenLabs, cron, Telegram formatting)
- **MEMORY.md** — long-term memory system (events, relationship context, lessons)
- **HEARTBEAT.md** — proactive behavior (periodic checks, notifications)
- **skills/** — 11 specialized skills (voice search, crypto translate, reminders, etc.)

This is useful as a reference for building any Claude Code-based bot or assistant with a persistent personality and workspace.

---

## Validation & Testing

```bash
# Validate JSON files (hooks, configs)
python3 -c "import json; json.load(open('path/to/file.json'))"

# Check no API keys leaked into repo
grep -r "sk-or-v1-[a-zA-Z0-9]" .
```

## Repo Architecture

The repo is a reference collection. Users clone it, open in Claude Code, and ask Claude to set up specific extensions by studying the examples:

```
pipelines/
  research-pipeline/          → agents/, workflows/, skills/
  llm-studio/                 → commands/, scripts/
  orchestration-builder/      → skills/, references/, templates/
extras/
  clawdbot/                   → Full personal AI bot setup example
  skills/                     → content-writer/, emotional-support/
  hooks/examples/             → 6 JSON hook examples
  statusline/                 → statusline.sh
  deepwiki-lookup/            → CLAUDE.md snippet
configs/
  claude-md-sections/         → Sections appended to CLAUDE.md
  CLAUDE.md.example           → Full CLAUDE.md example
  settings.json.example       → Settings with statusline + plugins
  external-agents.json.example → Agent registry example
```

## Key Conventions

- **CLAUDE.md sections use idempotency markers**: `<!-- STARTER-KIT:xxx:START/END -->`. The installer checks before appending.
- **LLM Studio scripts use `.example` suffix** in the repo. The installer copies them without the suffix. Repo versions use `$OPENROUTER_API_KEY` env var instead of hardcoded keys.
- **Agent naming**: kebab-case (`research-senior`, not `ResearchSenior`). Filename = agent name.
- **Workflow naming**: kebab-case matching the pipeline directory name.

## Adding Components

**New pipeline**: create `pipelines/<name>/` with `agents/`, `workflows/`, `skills/SKILL.md`, `README.md`. Add a section file in `configs/claude-md-sections/<name>.md`.

**New skill**: create `extras/skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`, `trigger_phrases`).

**New LLM model**: add alias in `MODEL_ALIASES` in `openrouter-api.py`, create `.sh.example` script (no API keys!), create command `.md` in `commands/`.

**New hook**: create JSON in `extras/hooks/examples/`, document in `extras/hooks/README.md`.

## Bilingual README

`README.md` is bilingual (Russian + English) with anchor-based switching (`#русский` / `#english`). Both sections must stay in sync. Component details use collapsible `<details>` blocks.

## Detailed Documentation

- `docs/ARCHITECTURE.md` — system architecture, data flows, file layout after installation
- `docs/CREATING-YOUR-OWN-PIPELINE.md` — step-by-step pipeline creation guide with full example
- `docs/FAQ.md` — frequently asked questions about plugins, costs, updates
- `docs/TROUBLESHOOTING.md` — common issues and solutions
