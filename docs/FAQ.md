# Frequently Asked Questions

## General

### Is this official Anthropic software?

No. The Claude Code Starter Kit is a community project. It is not developed, maintained, or endorsed by Anthropic. It builds on top of Claude Code (which is Anthropic's official CLI tool) by adding configuration files, agent definitions, workflow templates, and utility scripts.

### Will this break my existing Claude Code setup?

The Starter Kit is a reference repository. It doesn't modify anything on its own — you (or Claude Code) choose which files to copy into `~/.claude/`. If you're adding files manually, consider backing up first:

```bash
cp -r ~/.claude/ ~/.claude-backup-$(date +%Y%m%d)/
```

### Can I use only some components?

Yes. The Starter Kit is modular. Open the repo in Claude Code and ask it to set up only what you need. If doing it manually, each component maps to specific files:

| Component | Files to copy |
|-----------|---------------|
| Research Pipeline | `pipelines/research-pipeline/agents/` → `~/.claude/agents/`, `workflows/` → `~/.claude/workflows/` |
| LLM Studio | `pipelines/llm-studio/scripts/` → `~/.claude/scripts/llm-studio/`, `commands/` → `~/.claude/commands/` |
| Orchestration Builder | `pipelines/orchestration-builder/` → `~/.claude/skills/orchestration-builder/` |
| Skills | `extras/skills/{name}/` → `~/.claude/skills/{name}/` |
| Statusline | `extras/statusline/statusline.sh` → `~/.claude/statusline.sh` + configure in `settings.json` |
| Hooks | Configure hook entries in `~/.claude/settings.json` using examples from `extras/hooks/examples/` |

Each component works independently. The only shared dependency is that pipeline-based components require the orchestration plugin.

### What Claude Code version is required?

Claude Code 2.x or later with plugin support. The orchestration plugin, Tavily plugin, and slash commands all rely on features introduced in the 2.x series. Run `claude --version` to check your version.

### Can I use this with VS Code or JetBrains?

Yes. Claude Code works as a CLI tool and integrates with VS Code (via the Claude Code extension) and JetBrains IDEs. The Starter Kit configures the `~/.claude/` directory, which is shared across all environments. Pipelines, slash commands, and agents will work regardless of whether you launch Claude Code from a terminal, VS Code, or a JetBrains IDE.

---

## Plugins

### Do I need all the plugins?

No. You only need the plugins that the components you use depend on:

| Plugin | Required for |
|--------|-------------|
| **Orchestration** | Research Pipeline, Prompt Forge, Redactory, LLM Studio orchestration, Orchestration Builder |
| **Tavily** | Research Pipeline (agent search tools), any agent with `tavily_search`/`tavily_extract` in its tools list |
| **Obsidian** | Research Pipeline (only if saving results to Obsidian vault) |

If you are only using LLM Studio slash commands (`/codex`, `/deepseek`, etc.), you do not need any plugins — those commands work with just the shell scripts and OpenRouter API.

### How do I check which plugins are installed?

Look in the plugin cache directory:

```bash
ls ~/.claude/plugins/cache/
```

Each installed plugin has a subdirectory here.

---

## LLM Studio

### What does it cost?

The Starter Kit itself is free. However, using it involves costs from two sources:

1. **Claude Code subscription** — Required to use Claude Code itself. See [Anthropic's pricing](https://www.anthropic.com/pricing) for current rates.
2. **OpenRouter credits** — Required only for LLM Studio slash commands (`/codex`, `/deepseek`, `/kimi`, `/minimax`, `/mistral`). You pay per token at the rates set by each model provider. Check [openrouter.ai/models](https://openrouter.ai/models) for current pricing.

Pipelines that use only Claude agents (Research Pipeline, Prompt Forge, Redactory) are covered by your Claude Code subscription and have no additional cost.

### Can I add my own models to LLM Studio?

Yes. Follow these steps:

1. **Add a model alias** in `~/.claude/scripts/llm-studio/openrouter-api.py`:
   ```python
   MODEL_ALIASES = {
       # ... existing aliases ...
       "my-model": "provider/model-id-on-openrouter",
   }
   ```

2. **Create a query script** (copy an existing one as a template):
   ```bash
   cp ~/.claude/scripts/llm-studio/deepseek-query.sh.example \
      ~/.claude/scripts/llm-studio/my-model-query.sh
   chmod +x ~/.claude/scripts/llm-studio/my-model-query.sh
   ```
   Edit the script to use your model alias: `--model my-model`

3. **Create a slash command** at `~/.claude/commands/my-model.md`:
   ```markdown
   ---
   description: "My Model - description of what it does"
   ---

   # /my-model

   Send a request to **My Model** via OpenRouter API.

   ## Arguments: {{ARGS}}

   ## Execution

   1. If `{{ARGS}}` is empty, ask the user for a prompt
   2. Run:
   ```bash
   ~/.claude/scripts/llm-studio/my-model-query.sh "{{ARGS}}"
   ```
   3. Return the result
   ```

4. Test it:
   ```
   /my-model Hello, are you working?
   ```

You can find the model ID for any model on [openrouter.ai/models](https://openrouter.ai/models).

---

## Pipelines

### How do pipelines differ from regular Claude Code usage?

In regular Claude Code usage, you interact with a single Claude instance that handles everything. With pipelines, the work is split across multiple specialized agents, each with its own model, tools, and instructions. An orchestration layer coordinates them, passing outputs between agents and managing the flow.

Benefits:
- **Specialization** — Each agent is focused on one task and has tailored instructions
- **Model selection** — Use opus for critical decisions, haiku for quick tasks
- **Tool scoping** — Each agent only has access to the tools it needs
- **Reproducibility** — The same pipeline produces consistent results across runs
- **Checkpoints** — Add review points where the user can approve or redirect

### Can I run a pipeline step manually?

Yes. You can invoke any registered agent directly:

```
/orchestration:run orchestration:research-senior:"Research the topic of MCP servers"
```

This runs a single agent without the full pipeline workflow.

### Can pipelines run in parallel?

Yes, using the `||` operator in workflow files. For example:

```
[orchestration:web-searcher:"Search the web" || orchestration:doc-searcher:"Search documentation"] ->
orchestration:aggregator:"Merge the results"
```

Both search agents run simultaneously, and the aggregator receives both outputs.

---

## Updates and Maintenance

### How do I update the Starter Kit?

Pull the latest changes:

```bash
cd /path/to/awesome-howdeploy-claude-code
git pull
```

Then compare the updated files with your `~/.claude/` directory and copy over any changes. Or open the repo in Claude Code and ask it to update your setup.

After updating, re-register agents:

```bash
~/.claude/scripts/restore-orchestration-agents.sh
```

### What happens when the orchestration plugin updates?

Plugin updates can reset the `external-agents.json` registry, which means your custom agents will no longer be discoverable. Run the restore script after any plugin update:

```bash
~/.claude/scripts/restore-orchestration-agents.sh
```

This script scans all `.md` files in `~/.claude/agents/` and rebuilds the registry.

### Do I need to update CLAUDE.md manually after changes?

If you add or remove pipelines, you should update the corresponding sections in `~/.claude/CLAUDE.md`. Claude reads this file to understand which trigger phrases should launch which pipelines. If the documentation is out of date, Claude may not recognize your commands.

The Orchestration Builder updates `CLAUDE.md` automatically when creating new pipelines.

---

## Contributing

### How do I contribute?

See `CONTRIBUTING.md` in the repository root for contribution guidelines. In general:

1. Fork the repository
2. Create a feature branch
3. Make your changes (new pipeline, bugfix, documentation improvement)
4. Test locally by copying files to `~/.claude/` and verifying they work
5. Submit a pull request with a description of what you changed and why

Contributions of new pipelines, agent templates, and documentation improvements are welcome.

### Can I share my custom pipeline with others?

Yes. Package your pipeline as a directory under `pipelines/` following the existing structure:

```
pipelines/my-pipeline/
  agents/
    my-agent-1.md
    my-agent-2.md
  workflows/
    my-pipeline.flow
  skills/
    SKILL.md        (optional, if it should be a skill)
  scripts/
    my-script.sh    (optional, if your pipeline needs scripts)
  commands/
    my-command.md   (optional, if your pipeline adds slash commands)
```

Include a `SKILL.md` or README with trigger phrases, agent descriptions, and usage examples so others know how to install and use it.
