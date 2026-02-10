# Architecture Overview

This document describes the architecture of the Claude Code Starter Kit — how the components fit together, how data flows between them, and where everything lives on disk.

## High-Level Diagram

```
                          User (CLI / VS Code / JetBrains)
                                     |
                                     v
                              +--------------+
                              |  Claude Code  |
                              |   (Runtime)   |
                              +------+-------+
                                     |
                    +----------------+----------------+
                    |                |                 |
                    v                v                 v
           +---------------+  +-----------+   +---------------+
           | Orchestration |  |  Slash     |   |   Hooks &     |
           |    Plugin     |  | Commands   |   |  Statusline   |
           +-------+-------+  +-----+-----+   +-------+-------+
                   |                |                   |
          +--------+--------+      |             settings.json
          |        |        |      |          (event -> shell cmd)
          v        v        v      v
     +--------+ +-------+ +-------+------+
     | Agents | | .flow  | | Shell        |
     |  (.md) | | files  | | Scripts      |
     +---+----+ +---+----+ +------+------+
         |          |              |
         |    workflow operators   |
         |    (-> || ~> @review)   |
         |          |              |
         v          v              v
   +----------+ +----------+ +------------+
   |  Tools   | |  Tools   | |  External  |
   |  (Tavily,| | (Read,   | |  APIs      |
   |  WebFetch| |  Write,  | | (OpenRouter|
   |  Obsidian| |  Bash)   | |  Anthropic)|
   +----------+ +----------+ +------------+
```

## Core Components

### Claude Code Runtime

Claude Code is Anthropic's official CLI tool. It reads configuration from `~/.claude/`, executes prompts, invokes tools, and manages conversation context. The Starter Kit extends its capabilities through three mechanisms:

1. **Orchestration Plugin** — multi-agent pipelines
2. **Slash Commands** — custom commands defined in markdown files
3. **Skills** — prompt files that define Claude's behavior in specific scenarios
4. **Settings Configuration** — hooks, statusline, permissions

### Orchestration Plugin

The Orchestration plugin is a Claude Code marketplace plugin that enables multi-agent workflows. It provides:

- **Agent discovery** — finds agents registered in `external-agents.json`
- **Workflow execution** — parses `.flow` files and runs agents in sequence, parallel, or conditionally
- **Template system** — `/orchestration:template <name>` launches a named pipeline
- **Direct execution** — `/orchestration:run <agent>:"<task>"` runs a single agent step

The plugin reads from:
```
~/.claude/plugins/cache/orchestration-marketplace/orchestration/<version>/
```

### Agent System

Agents are markdown files with YAML frontmatter that define a specialized AI persona. Each agent specifies:

- **model** — which Claude model to use (`opus`, `sonnet`, or `haiku`)
- **description** — what the agent does (shown in listings)
- **tools** — which tools the agent is allowed to use
- **instructions** — the system prompt body (markdown below the frontmatter)

Example agent frontmatter:
```yaml
---
model: sonnet
description: Verifies and edits research documents
tools:
  - mcp__plugin_tavily-tools_tavily__tavily_search
  - mcp__plugin_tavily-tools_tavily__tavily_extract
  - WebFetch
---
```

Agents do not execute independently. They are invoked by the orchestration plugin, which sets up the model, injects the tools, and passes the task description from the workflow.

### Workflow Files (.flow)

Workflow files define the execution order of agents within a pipeline. They use a custom DSL with four operators:

| Operator | Syntax | Meaning |
|----------|--------|---------|
| Sequential | `A -> B -> C` | Run A, then B, then C |
| Parallel | `[A \|\| B] -> C` | Run A and B simultaneously, then C |
| Conditional | `A ~> B / C` | Branch based on A's result |
| Checkpoint | `@review:"Question?"` | Pause and ask the user to approve |

Workflows also have YAML frontmatter with `name`, `description`, and `params` (input variables accessed via `{{param}}`).

### External Agent Registry (external-agents.json)

The orchestration plugin discovers custom agents through a JSON registry file:

```
~/.claude/plugins/cache/orchestration-marketplace/orchestration/<version>/
  skills/managing-agents/external-agents.json
```

Structure:
```json
{
  "externalAgents": {
    "agent-name": {
      "path": "~/.claude/agents/agent-name.md",
      "description": "What this agent does",
      "model": "sonnet",
      "registered": "2026-02-02",
      "usageCount": 0
    }
  },
  "lastUpdated": "2026-02-02T15:30:00+03:00"
}
```

When the orchestration plugin encounters `orchestration:agent-name`, it looks up the agent in this registry, reads the `.md` file from the `path`, and uses the frontmatter to configure the execution.

The registry is volatile — plugin updates can reset it. The `restore-orchestration-agents.sh` script regenerates the registry by scanning all `.md` files in `~/.claude/agents/`.

### Slash Commands

Slash commands are markdown files placed in `~/.claude/commands/`. Each file defines a command that users invoke with `/<filename>` in the Claude Code CLI.

Command files contain:
- YAML frontmatter with `description`
- A markdown body with execution instructions
- `{{ARGS}}` placeholder for user-provided arguments

For example, `/codex Write a sorting function` invokes the `codex.md` command, which instructs Claude to run the `codex-query.sh` shell script with the provided prompt.

The LLM Studio pipeline provides five slash commands (`/codex`, `/deepseek`, `/kimi`, `/minimax`, `/mistral`), each wrapping an OpenRouter API call to a specific model.

### Skills

Skills are prompt files placed in `~/.claude/skills/{skill-name}/SKILL.md`. They define how Claude should behave in specific scenarios — changing its persona, communication style, and workflow.

Unlike agents (which are invoked by the orchestration plugin), skills are loaded directly by Claude Code when it detects matching trigger phrases. A skill file contains:

- **YAML frontmatter** with `name`, `description`, and `trigger_phrases`
- **Algorithm** — step-by-step instructions for Claude to follow
- **Restrictions** — what Claude should NOT do in this mode
- **Examples** — sample dialogues demonstrating expected behavior

Skills can also define entry/exit triggers (e.g., "I need support" enters the mode, "topic closed" exits it), reference external files (e.g., writing style samples in a `references/` folder), and include memory instructions for persisting information across sessions.

The Starter Kit includes two standalone skill examples:
- `content-writer` — content creation with web research and style adaptation
- `emotional-support` — empathetic support mode with CBT techniques

And two pipeline-bound skills:
- `research-pipeline` — skill that triggers the research pipeline
- `orchestration-builder` — interactive wizard for creating new pipelines

### Statusline

The statusline is a shell script (`extras/statusline/statusline.sh`) that provides real-time session information in the Claude Code interface. It works as follows:

1. Claude Code pipes a JSON blob to stdin containing session stats (tokens, cost, context window size)
2. The script parses this JSON using `sed` (no `jq` dependency)
3. It calls the Anthropic OAuth API to fetch 5-hour rate limit utilization
4. It formats and outputs colored text showing:
   - **Session context usage** — percentage of context window consumed
   - **Session cost** — dollars spent in current session
   - **5-hour rate limit** — percentage of rate limit consumed
   - **Reset timer** — time until the rate limit resets

Configuration in `settings.json`:
```json
{
  "statusLine": {
    "command": "~/.claude/scripts/statusline.sh"
  }
}
```

### Hooks

Hooks let you run shell commands when specific Claude Code events occur (e.g., before a message is sent, after a tool is used). They are configured in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "/path/to/script.sh"
      }
    ]
  }
}
```

Hook events include:
- `PreToolUse` / `PostToolUse` — before/after a tool is invoked
- `Notification` — when Claude sends a notification
- `Stop` — when Claude finishes a response

Each hook entry has a `matcher` (regex pattern for when to fire) and a `command` (shell command to execute).

## File Layout

Here is where everything lives after setup:

```
~/.claude/
  CLAUDE.md                          # Global instructions (pipeline triggers, docs)
  settings.json                      # Hooks, statusline, permissions
  .credentials.json                  # OAuth tokens (auto-managed)

  agents/                            # Agent definitions
    research-senior.md
    research-editor.md
    research-communicator.md
    ...

  workflows/                         # Pipeline workflow files
    research-pipeline.flow
    llm-studio.flow
    ...

  commands/                          # Slash commands
    codex.md
    deepseek.md
    kimi.md
    minimax.md
    mistral.md

  scripts/                           # Shell scripts
    restore-orchestration-agents.sh
    statusline.sh
    llm-studio/
      openrouter-api.py
      codex-query.sh
      deepseek-query.sh
      kimi-query.sh
      minimax-query.sh
      mistral-query.sh

  skills/                            # Skill definitions
    orchestration-builder/
      SKILL.md
      references/
      templates/
      scripts/
    content-writer/
      SKILL.md
    emotional-support/
      SKILL.md

  plugins/                           # Plugin cache (managed by Claude Code)
    cache/
      orchestration-marketplace/
        orchestration/<version>/
          skills/
            managing-agents/
              external-agents.json
              available-agents.md
```

The **repository** mirrors this structure and provides source files that get copied into `~/.claude/`:

```
awesome-howdeploy-claude-code/
  pipelines/
    research-pipeline/       # Research pipeline source files
      agents/
      workflows/
      skills/
    llm-studio/              # LLM Studio source files
      scripts/
      commands/
    orchestration-builder/   # Pipeline builder source files
      skills/
      references/
      templates/
      scripts/
  scripts/                   # Utility scripts
    restore-orchestration-agents.sh
  extras/                    # Optional components
    skills/
      content-writer/
      emotional-support/
    statusline/
      statusline.sh
    hooks/
      examples/
    deepwiki-lookup/
  configs/                   # Configuration fragments
    claude-md-sections/
  docs/                      # Documentation (this directory)
```

## Data Flow: Pipeline Execution

When a user says "research topic X", the following happens:

1. Claude Code reads `CLAUDE.md` and matches the trigger phrase
2. Claude invokes `/orchestration:template research-pipeline` with `topic="X"`
3. The orchestration plugin reads `~/.claude/workflows/research-pipeline.flow`
4. It parses the workflow and begins sequential execution:
   - Looks up `research-communicator` in `external-agents.json`
   - Reads `~/.claude/agents/research-communicator.md`
   - Spawns a sonnet instance with the agent's instructions and tools
   - Passes the task: "Get and clarify the request: X"
5. The output from each step feeds into the next via `->` operator
6. At `@review`, execution pauses and asks the user to approve
7. After all steps complete, the final agent (research-communicator) delivers results

## Data Flow: Slash Command Execution

When a user types `/codex Write a sorting function`:

1. Claude Code finds `~/.claude/commands/codex.md`
2. It replaces `{{ARGS}}` with "Write a sorting function"
3. Claude follows the command's instructions:
   - Determines no files are needed
   - Runs `~/.claude/scripts/llm-studio/codex-query.sh "Write a sorting function"`
4. The shell script calls `openrouter-api.py --model codex --prompt "..."`
5. The Python script resolves `codex` to `openai/gpt-5.2-codex` via `MODEL_ALIASES`
6. It sends the request to OpenRouter API using `OPENROUTER_API_KEY`
7. The response flows back through the script, and Claude presents it to the user

## Security Model

- **Permissions** are controlled in `settings.json` and `.claude/settings.local.json` (per-project)
- **API keys** (`OPENROUTER_API_KEY`) are environment variables, never stored in config files
- **Credentials** (`.credentials.json`) are in `.gitignore` and never committed
- **Tool access** is restricted per-agent via the `tools` frontmatter field
- **Hooks** run arbitrary shell commands — review them before enabling
