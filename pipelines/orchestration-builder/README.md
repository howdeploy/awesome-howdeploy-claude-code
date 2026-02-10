# Orchestration Builder

Interactive wizard for creating new orchestration pipelines, agents, and registering them in Claude Code. Instead of manually writing workflow files, agent definitions, and registry entries, this skill walks you through a guided 5-phase process and generates everything automatically.

## What It Creates

| Artifact | Location | Description |
|----------|----------|-------------|
| Workflow file | `~/.claude/workflows/{name}.flow` | Pipeline definition with steps, operators, and checkpoints |
| Agent files | `~/.claude/agents/{agent-name}.md` | One file per agent with model, tools, instructions, and output format |
| Registry entry | `external-agents.json` | Registers each agent so orchestration can discover it |
| Documentation | `~/.claude/CLAUDE.md` | Adds a section with trigger phrases, agent table, and launch command |

## 5 Phases

### Phase 1: Concept

Define the pipeline basics:
- **Name** — kebab-case identifier (e.g., `code-review-pipeline`)
- **Purpose** — Research/Analysis, Development, Content, or Data Processing
- **Parameters** — what inputs the pipeline accepts (`topic`, `target`, `style`, `output_path`)

### Phase 2: Agents

Design each agent in the pipeline:
- **Role** — Analyzer, Processor, Reviewer, or Communicator
- **Model** — `opus` (complex tasks), `sonnet` (balanced, recommended), or `haiku` (fast and cheap)
- **Tools** — File operations, Bash, Web search, Tavily, Obsidian, or interactive prompts

### Phase 3: Workflow

Define how agents interact:
- **Sequential** — `A -> B -> C` (one after another)
- **Parallel** — `[A || B] -> C` (simultaneous execution, then merge)
- **Conditional** — `A ~> B / C` (branching by result)
- **Checkpoints** — `@review` points where the user approves before continuing

### Phase 4: Documentation

Configure how the pipeline integrates into your setup:
- **Trigger phrases** — natural language phrases that activate the pipeline
- **Output destination** — Obsidian vault, current directory, custom path, or console only

### Phase 5: Generation

The wizard creates all files, registers agents, updates CLAUDE.md, and runs validation:

```bash
~/.claude/skills/orchestration-builder/scripts/validate-pipeline.sh {name}
```

## Usage

### Via skill trigger

```
/orchestration-builder
```

### Via trigger phrases

Any of these will activate the wizard:
- "create pipeline" / "new pipeline"
- "pipeline wizard" / "build workflow"
- "orchestration builder"

The wizard will then ask you a series of questions using interactive prompts, guiding you through all 5 phases.

## Example

**User:** "Create a pipeline for code review"

**After completing the wizard, the builder generates:**

1. `~/.claude/workflows/code-review-pipeline.flow`
2. `~/.claude/agents/code-analyzer.md`
3. `~/.claude/agents/code-reviewer.md`
4. `~/.claude/agents/review-reporter.md`
5. Entries in `external-agents.json` for all three agents
6. A new section in `~/.claude/CLAUDE.md`

**Launch the new pipeline:**

```
/orchestration:template code-review-pipeline
```

## Reference Files

Detailed format specifications are included for building pipelines manually or understanding what the wizard generates:

| Reference | Description |
|-----------|-------------|
| `references/workflow-format.md` | Syntax for `.flow` files — operators (`->`, `||`, `~>`), checkpoints (`@review`, `@confirm`), variables (`{{param}}`), and examples |
| `references/agent-format.md` | Structure of agent `.md` files — frontmatter fields (`model`, `description`, `tools`), body sections, and available tools list |
| `references/registry-format.md` | Format of `external-agents.json` — required fields, add/remove/update operations, and validation rules |

## Templates

The wizard uses these Handlebars-style templates during generation:

| Template | Generates |
|----------|-----------|
| `templates/agent.tmpl` | Agent `.md` file with display name, model, tools, instructions, responsibilities, process steps, and output format |
| `templates/workflow.tmpl` | Workflow `.flow` file with frontmatter, parameters, and agent chain |
| `templates/claude-md-section.tmpl` | CLAUDE.md section with display name, description, trigger phrases, launch command, agent table, and output info |

## Validation

After generation, run the validation script to check that everything is in order:

```bash
~/.claude/skills/orchestration-builder/scripts/validate-pipeline.sh <pipeline-name>
```

The validator checks:
1. Workflow file exists and has correct frontmatter
2. All agents referenced in the workflow exist as `.md` files
3. Each agent has a valid model (`opus`, `sonnet`, or `haiku`)
4. All agents are registered in `external-agents.json`
5. A documentation section exists in `CLAUDE.md`

## File Structure

```
orchestration-builder/
  references/
    workflow-format.md          # .flow file syntax reference
    agent-format.md             # Agent file structure reference
    registry-format.md          # external-agents.json format reference
  scripts/
    validate-pipeline.sh        # Post-generation validation script
  skills/
    SKILL.md                    # Skill definition with 5-phase wizard logic
  templates/
    agent.tmpl                  # Handlebars template for agent files
    workflow.tmpl               # Handlebars template for workflow files
    claude-md-section.tmpl      # Handlebars template for CLAUDE.md entries
```
