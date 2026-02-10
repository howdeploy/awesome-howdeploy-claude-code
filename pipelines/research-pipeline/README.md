# Research Pipeline (Ресерч-тян)

Multi-agent research system for Claude Code. Performs deep search via Tavily and Reddit, verifies findings through an editorial review, and delivers structured results to the user -- all orchestrated automatically.

## Agents

| Agent | Model | Role |
|-------|-------|------|
| `research-senior` | opus | Classifies the topic, asks clarifying questions, runs deep search via Tavily and Reddit, produces a draft |
| `research-editor` | sonnet | Verifies the draft for accuracy, contradictions, and completeness; creates the final document |
| `research-communicator` | sonnet | The user-facing agent -- presents results, relays follow-up questions, keeps a concise conversational style |

## Workflow

```
Step 1  research-communicator   Receive and clarify the user's request
          |
          v
Step 2  research-senior         Classify the topic, ask 5 clarifying questions
          |
          v
Step 3  research-senior         Deep research via Tavily/Reddit, save draft
          |
          v
Step 4  research-editor         Verify draft: accuracy, contradictions, completeness
          |
          v
Step 5  @review                 User approves the draft for finalization
          |
          v
Step 6  research-editor         Create the final document
          |
          v
Step 7  research-communicator   Notify the user with results
```

## Requirements

- **Claude Code** with the orchestration plugin installed
- **Tavily plugin** (`tavily-tools`) for web search and extraction
- Optionally, **Obsidian plugin** for saving results directly to your vault

## Setup

Open this repo in Claude Code and ask it to set up the Research Pipeline, or copy files manually:

1. Copy agent files into `~/.claude/agents/`:

```bash
cp agents/research-senior.md     ~/.claude/agents/
cp agents/research-editor.md     ~/.claude/agents/
cp agents/research-communicator.md ~/.claude/agents/
```

2. Copy the workflow file:

```bash
cp workflows/research-pipeline.flow ~/.claude/workflows/
```

3. Register agents in `external-agents.json` (see the orchestration-builder reference for format details).

4. Add the pipeline section to `~/.claude/CLAUDE.md` (see the SKILL.md for the full template).

## Usage

```
/orchestration:template research-pipeline
```

When prompted, enter the topic you want to research. The pipeline will:
1. Ask you clarifying questions to narrow the scope
2. Run advanced Tavily searches with multiple query variations
3. Search Reddit for community experience
4. Produce a verified draft with source URLs
5. Wait for your approval
6. Generate a final structured document

### Direct workflow run (alternative)

```
/orchestration:run orchestration:research-communicator:"get request" -> orchestration:research-senior:"research topic X" -> orchestration:research-editor:"verify and finalize"
```

## Output Markers

The research output uses these markers to indicate information confidence:

| Marker | Meaning |
|--------|---------|
| Confirmed | Information verified across multiple sources |
| Uncertain | Data found but needs additional verification |
| Not found | The information was searched for but could not be located |

## Research Categories

The senior researcher classifies every topic into one of three categories:

| Category | Description | Focus |
|----------|-------------|-------|
| **AI/Tech** | Services, plugins, settings, repositories | Ready-made solutions, guides, active repos |
| **Everyday** | PC setup, errors, recipes | Concrete problem-solving |
| **Crypto/Web3** | Coins, market, investments | Analytics, comprehensive data |

## Customization

### Adding new research categories

Edit `agents/research-senior.md`, find the classification table in **Step 1**, and add a new row:

```markdown
| **Science** | Academic papers, experiments, theories | Peer-reviewed sources, methodology |
```

### Changing output format

Edit `agents/research-editor.md`, find the **Step 4: Finalization** section, and modify the document template to match your preferred structure.

### Adding Obsidian integration

To save research results directly to an Obsidian vault, add Obsidian tools to the editor agent. In `agents/research-editor.md`, update the frontmatter:

```yaml
---
model: sonnet
description: Verification and finalization of research
tools:
  - mcp__plugin_tavily-tools_tavily__tavily_search
  - mcp__plugin_tavily-tools_tavily__tavily_extract
  - WebFetch
  - mcp__obsidian__obsidian_append_content
  - mcp__obsidian__obsidian_patch_content
---
```

Then, in the finalization step of the same file, add instructions for saving:

```markdown
### Saving to Obsidian

- Draft: save to `Ресерч и исследования/[YYYY-MM-DD] [Topic].md`
- Final: save to `Гайды, разборы/[Topic] -- [Type].md`
```

## Troubleshooting

If agents stop working after an orchestration plugin update:

```bash
~/.claude/scripts/restore-orchestration-agents.sh
```

## File Structure

```
research-pipeline/
  agents/
    research-senior.md          # Deep research agent (opus)
    research-editor.md          # Verification and finalization (sonnet)
    research-communicator.md    # User-facing communicator (sonnet)
  skills/
    SKILL.md                    # Skill definition with trigger phrases
  workflows/
    research-pipeline.flow      # Workflow definition (7-step sequential)
```
