# Creating Your Own Pipeline

This guide walks you through building a custom orchestration pipeline from scratch. By the end, you will have a working multi-agent workflow registered in Claude Code.

## Prerequisites

Before you begin, make sure you have:

1. **Claude Code 2.x+** installed and working
2. **Orchestration plugin** installed from the Claude Code marketplace
3. A basic understanding of how agents and workflows interact (see [ARCHITECTURE.md](./ARCHITECTURE.md))

## Overview

Creating a pipeline involves six steps:

1. Design the pipeline (agents, flow, parameters)
2. Create agent files (`.md` with frontmatter)
3. Create the workflow file (`.flow` with DSL syntax)
4. Register agents in `external-agents.json`
5. Document the pipeline in `CLAUDE.md`
6. Validate everything works

Alternatively, you can use the **Orchestration Builder** skill, which automates all of these steps through an interactive wizard. See the section at the end of this guide.

---

## Step 1: Design the Pipeline

Before writing any files, plan your pipeline on paper:

### Choose Your Agents

Each agent should have a single, clear responsibility. A typical pipeline has 2-4 agents:

| Role | Purpose | Recommended Model |
|------|---------|-------------------|
| Analyzer | Classify input, gather information | `opus` (complex) or `sonnet` (standard) |
| Processor | Do the main work | `sonnet` |
| Reviewer | Verify quality, check for errors | `sonnet` |
| Communicator | Present results to the user | `sonnet` or `haiku` |

### Define the Flow

Decide how agents interact:

- **Sequential** (`->`) — most common, each agent feeds into the next
- **Parallel** (`||`) — independent tasks that can run simultaneously
- **Conditional** (`~>`) — branch based on a previous agent's output
- **With checkpoints** (`@review`) — pause for user approval at critical points

### Choose Parameters

What input does your pipeline need? Common parameters:

- `topic` — a subject to research or analyze
- `target` — a file or directory to process
- `style` — a mode or style of output
- `output_path` — where to save results

---

## Step 2: Create Agent Files

Agent files live in `~/.claude/agents/` and use this format.

### Template

The repository provides a template at `pipelines/orchestration-builder/templates/agent.tmpl`. Here is the structure:

```markdown
# Agent Display Name

---
model: sonnet
description: One or two sentences describing what this agent does.
tools:
  - Read
  - Grep
  - Bash
---

You are a [role description]. Your task is to [primary objective].

## Tasks

1. First responsibility
2. Second responsibility
3. Third responsibility

## Process

### Step 1: Gather Information
Read the relevant files and understand the context...

### Step 2: Analyze
Check for issues, classify results...

### Step 3: Output
Format the results as described below...

## Output Format

[Describe the expected output structure, ideally with a markdown template]
```

### Frontmatter Fields

**model** (required) — The Claude model to use:
- `opus` — highest quality, best for complex reasoning and critical decisions (most expensive)
- `sonnet` — balanced quality and cost, suitable for most tasks (recommended default)
- `haiku` — fast and cheap, good for simple classification or quick lookups

**description** (required) — A 1-2 sentence summary. This appears in agent listings and logs.

**tools** (optional) — A list of tools the agent can use. Only grant what is needed:

| Category | Tools |
|----------|-------|
| File operations | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| Shell | `Bash` |
| Web | `WebSearch`, `WebFetch` |
| Tavily (advanced search) | `mcp__plugin_tavily-tools_tavily__tavily_search`, `mcp__plugin_tavily-tools_tavily__tavily_extract`, `mcp__plugin_tavily-tools_tavily__tavily_crawl`, `mcp__plugin_tavily-tools_tavily__tavily_research` |
| Obsidian | `mcp__obsidian__obsidian_get_file_contents`, `mcp__obsidian__obsidian_append_content`, `mcp__obsidian__obsidian_simple_search` |
| Interactive | `AskUserQuestion` |

### Best Practices for Agent Files

- **One agent, one job.** Do not overload an agent with unrelated responsibilities.
- **Minimal tools.** Only grant tools the agent actually needs.
- **Structured output.** Include a template of the expected output so the next agent in the chain can parse it.
- **Include examples.** Show what good and bad output looks like.
- **State limitations.** Explicitly say what the agent should NOT do.

---

## Step 3: Create the Workflow File

Workflow files live in `~/.claude/workflows/` and use the `.flow` extension.

### Template

The repository provides a template at `pipelines/orchestration-builder/templates/workflow.tmpl`. Here is the structure:

```yaml
---
name: my-pipeline
description: What this pipeline does in one sentence.
params:
  topic: The subject to process
---

Workflow:

orchestration:my-analyzer:"Analyze the topic: {{topic}}" ->
orchestration:my-processor:"Process the analysis results" ->
@review:"Approve the processed results?" ->
orchestration:my-reporter:"Generate the final report"
```

### Operators

**Sequential (`->`)** — Run steps one after another. The output of each step is available to the next.

```
agent1:"task" -> agent2:"task" -> agent3:"task"
```

**Parallel (`||`)** — Run independent steps at the same time. Wrap parallel steps in square brackets.

```
[agent1:"search web" || agent2:"search docs"] -> agent3:"merge results"
```

**Conditional (`~>`)** — Branch based on the result of the previous step.

```
agent1:"validate input" ->
(if valid)~> agent2:"process" ~>
(else)~> agent3:"handle error"
```

**Checkpoint (`@review`)** — Pause execution and ask the user for approval before continuing.

```
agent1:"analyze" -> @review:"Does this look correct?" -> agent2:"finalize"
```

**Confirm (`@confirm`)** — Notify the user without blocking execution.

```
agent1:"task" -> @confirm:"Step 1 complete" -> agent2:"task"
```

### Variables

- `{{param_name}}` — Access parameters defined in the frontmatter
- `{output}` — The output of the previous step
- `{context}` — Shared pipeline context

### Best Practices for Workflows

1. Keep pipelines to 5-7 steps maximum. Longer pipelines are hard to debug.
2. Add `@review` before destructive or irreversible actions.
3. Use parallel steps for independent work to save time.
4. Write task descriptions clearly — they are the prompts given to each agent.

---

## Step 4: Register Agents

The orchestration plugin needs to know about your agents. There are two ways to register them.

### Option A: Run the Restore Script

The simplest approach — run `restore-orchestration-agents.sh`, which scans `~/.claude/agents/` and registers every `.md` file it finds:

```bash
~/.claude/scripts/restore-orchestration-agents.sh
```

This script:
1. Finds the current orchestration plugin version
2. Reads each agent file's frontmatter (model, description)
3. Writes a fresh `external-agents.json`
4. Updates `available-agents.md`

### Option B: Edit external-agents.json Manually

The registry file is at:
```
~/.claude/plugins/cache/orchestration-marketplace/orchestration/<version>/
  skills/managing-agents/external-agents.json
```

Add an entry for each agent:

```json
{
  "externalAgents": {
    "my-analyzer": {
      "path": "~/.claude/agents/my-analyzer.md",
      "description": "Analyzes input and classifies it",
      "model": "sonnet",
      "registered": "2026-02-10",
      "usageCount": 0
    },
    "my-processor": {
      "path": "~/.claude/agents/my-processor.md",
      "description": "Processes classified data",
      "model": "sonnet",
      "registered": "2026-02-10",
      "usageCount": 0
    }
  },
  "lastUpdated": "2026-02-10T12:00:00+03:00"
}
```

**Important:** Always edit the `cache` version of the file, not the `marketplaces` version. The cache version is what the plugin reads at runtime.

---

## Step 5: Document in CLAUDE.md

Add a section to `~/.claude/CLAUDE.md` so Claude knows when and how to launch your pipeline. Use the template at `pipelines/orchestration-builder/templates/claude-md-section.tmpl`:

```markdown
---

## My Pipeline

Description of what this pipeline does.

### Trigger Phrases
- "run my pipeline"
- "my pipeline"
- "launch my pipeline"

### Launch
```
/orchestration:template my-pipeline
```

### Agents

| Agent | Model | Role |
|-------|-------|------|
| orchestration:my-analyzer | sonnet | Analyzes input |
| orchestration:my-processor | sonnet | Processes data |
| orchestration:my-reporter | sonnet | Generates report |

### Results
- Output saved to `./reports/`
```

This section serves two purposes:
1. Claude reads it as context (via `claudeMd`) and can recognize trigger phrases
2. It acts as documentation for other users of the pipeline

---

## Step 6: Validate

Run the validation script to check that everything is wired up correctly:

```bash
~/.claude/skills/orchestration-builder/scripts/validate-pipeline.sh my-pipeline
```

The script checks:
1. The workflow file exists and has valid frontmatter
2. All agents referenced in the workflow exist as `.md` files
3. Each agent has a valid model specified
4. Agents are registered in `external-agents.json`
5. A documentation section exists in `CLAUDE.md`

If validation passes, test the pipeline:

```
/orchestration:template my-pipeline
```

---

## Example: Building a Code Review Pipeline

Let us walk through creating a `code-review-pipeline` from scratch.

### Design

Three agents:
- **code-analyzer** (sonnet) — Scans the codebase, identifies files, classifies issues
- **code-reviewer** (opus) — Deep review of each issue, suggests fixes
- **review-reporter** (sonnet) — Formats the final report

Flow: sequential with a review checkpoint before the final report.

Parameter: `target` — the directory or file to review.

### Agent 1: code-analyzer

Create `~/.claude/agents/code-analyzer.md`:

```markdown
# Code Analyzer

---
model: sonnet
description: Scans codebase for potential issues, classifies by severity.
tools:
  - Read
  - Glob
  - Grep
---

You are a code analysis expert. Your task is to scan a codebase and identify potential issues.

## Tasks

1. Find all relevant source files in the target directory
2. Scan each file for common problems (bugs, security issues, style violations)
3. Classify each issue by severity (critical, warning, info)
4. Output a structured list of findings

## Process

### Step 1: Discovery
Use Glob to find source files matching common patterns (*.ts, *.js, *.py, etc.)

### Step 2: Analysis
For each file, use Read to examine the contents. Look for:
- Unhandled errors
- Security vulnerabilities (hardcoded secrets, SQL injection, etc.)
- Performance issues
- Dead code

### Step 3: Classification
Categorize findings as:
- CRITICAL — Must fix, potential security or data loss risk
- WARNING — Should fix, potential bugs or bad practices
- INFO — Nice to fix, style or readability improvements

## Output Format

For each finding, output:

- File: [path]
- Line: [number]
- Severity: [CRITICAL/WARNING/INFO]
- Issue: [description]
- Suggestion: [how to fix]
```

### Agent 2: code-reviewer

Create `~/.claude/agents/code-reviewer.md`:

```markdown
# Code Reviewer

---
model: opus
description: Deep code review with fix suggestions for identified issues.
tools:
  - Read
  - Grep
---

You are a senior code reviewer. Your task is to deeply analyze each issue found by the code analyzer and provide actionable fix suggestions.

## Tasks

1. Review each finding from the analyzer
2. Verify the issue is real (not a false positive)
3. Provide a concrete fix for each confirmed issue
4. Prioritize the fixes

## Output Format

For each confirmed issue:

- Status: CONFIRMED / FALSE POSITIVE
- Original finding: [summary]
- Analysis: [why this is a problem]
- Suggested fix: [code snippet or description]
- Priority: [1-5, where 1 is most urgent]
```

### Agent 3: review-reporter

Create `~/.claude/agents/review-reporter.md`:

```markdown
# Review Reporter

---
model: sonnet
description: Formats code review results into a clear, actionable report.
tools: []
---

You are a technical writer. Your task is to take the raw code review findings and produce a clean, readable report.

## Output Format

# Code Review Report

**Target:** [directory/file reviewed]
**Date:** [today]
**Issues found:** [count]

## Critical Issues
[List with file, line, description, and fix]

## Warnings
[List with file, line, description, and fix]

## Recommendations
[Prioritized list of next steps]
```

### Workflow

Create `~/.claude/workflows/code-review-pipeline.flow`:

```yaml
---
name: code-review-pipeline
description: Automated code review with issue detection, deep analysis, and report generation.
params:
  target: Directory or file to review
---

Workflow:

orchestration:code-analyzer:"Scan {{target}} for code issues, classify by severity" ->
orchestration:code-reviewer:"Review each finding, verify issues, suggest fixes" ->
@review:"Review the findings before generating the final report?" ->
orchestration:review-reporter:"Generate a formatted code review report"
```

### Register and Validate

```bash
# Register all agents
~/.claude/scripts/restore-orchestration-agents.sh

# Validate the pipeline
~/.claude/skills/orchestration-builder/scripts/validate-pipeline.sh code-review-pipeline
```

### Add to CLAUDE.md

Append to `~/.claude/CLAUDE.md`:

```markdown
---

## Code Review Pipeline

Automated code review with issue detection, deep analysis, and report generation.

### Trigger Phrases
- "code review"
- "review my code"
- "check code quality"

### Launch
```
/orchestration:template code-review-pipeline
```

### Agents

| Agent | Model | Role |
|-------|-------|------|
| orchestration:code-analyzer | sonnet | Scan codebase, classify issues |
| orchestration:code-reviewer | opus | Deep review, suggest fixes |
| orchestration:review-reporter | sonnet | Format final report |
```

### Test

```
/orchestration:template code-review-pipeline
```

Enter `./src` when prompted for the `target` parameter.

---

## The Easy Way: Orchestration Builder

If you prefer not to create files manually, the **Orchestration Builder** skill automates the entire process through an interactive wizard.

### How to Launch

Say any of these in Claude Code:
- "create pipeline"
- "new pipeline"
- "pipeline wizard"
- "orchestration builder"

Or invoke directly:
```
/orchestration-builder
```

### What It Does

The wizard walks you through five phases:

1. **Concept** — Pipeline name (kebab-case), purpose, parameters
2. **Agent Design** — Number of agents, roles, models, tools for each
3. **Workflow Structure** — Flow type (sequential/parallel/conditional), review points
4. **Documentation** — Trigger phrases, where to save results
5. **Generation** — Creates all files, registers agents, updates CLAUDE.md, runs validation

### What It Creates

After completing the wizard, you will have:

| File | Location |
|------|----------|
| Workflow | `~/.claude/workflows/{name}.flow` |
| Agents | `~/.claude/agents/{agent}.md` (one per agent) |
| Registry | Updated `external-agents.json` |
| Documentation | New section in `~/.claude/CLAUDE.md` |

The pipeline is immediately ready to use via `/orchestration:template {name}`.

### References

The builder uses these reference documents for formatting:
- `references/workflow-format.md` — Complete .flow syntax documentation
- `references/agent-format.md` — Agent file structure and available tools
- `references/registry-format.md` — external-agents.json schema

These are available in the repository at `pipelines/orchestration-builder/references/`.
