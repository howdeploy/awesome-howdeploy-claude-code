# Troubleshooting

Common issues and solutions when working with the Claude Code Starter Kit.

---

## Agent Not Found

**Symptom:** When running a pipeline, Claude reports that an agent like `orchestration:research-senior` cannot be found.

**Cause:** The agent is not registered in `external-agents.json`, or the registry was reset by a plugin update.

**Solution:**

1. Verify the agent file exists:
   ```bash
   ls ~/.claude/agents/
   ```

2. Run the restore script to re-register all agents:
   ```bash
   ~/.claude/scripts/restore-orchestration-agents.sh
   ```

3. If the restore script itself fails, check that the orchestration plugin is installed:
   ```bash
   ls ~/.claude/plugins/cache/orchestration-marketplace/orchestration/
   ```
   You should see a version directory (e.g., `1.0.0/`).

4. As a last resort, manually add the agent to the registry. The file is at:
   ```
   ~/.claude/plugins/cache/orchestration-marketplace/orchestration/<version>/
     skills/managing-agents/external-agents.json
   ```
   See [CREATING-YOUR-OWN-PIPELINE.md](./CREATING-YOUR-OWN-PIPELINE.md#step-4-register-agents) for the JSON format.

---

## Orchestration Plugin Not Installed

**Symptom:** `/orchestration:template` or `/orchestration:run` commands are not recognized.

**Cause:** The orchestration plugin is not installed or not enabled.

**Solution:**

1. Open Claude Code settings or the plugin marketplace
2. Search for "orchestration"
3. Install the plugin
4. Restart Claude Code
5. Verify installation:
   ```bash
   ls ~/.claude/plugins/cache/orchestration-marketplace/
   ```

If the plugin directory exists but commands still do not work, try removing and reinstalling the plugin.

---

## Tavily Search Fails

**Symptom:** Agents that use Tavily tools (`tavily_search`, `tavily_extract`, etc.) fail with errors about the tool not being available.

**Cause:** The Tavily plugin is not installed or not enabled in Claude Code.

**Solution:**

1. Check if the Tavily plugin is installed:
   - Open Claude Code plugin settings
   - Look for "tavily-tools" in the installed plugins list

2. If not installed, install it from the plugin marketplace (search for "tavily")

3. Make sure the tool is listed in the agent's `tools` frontmatter with the correct full name:
   ```yaml
   tools:
     - mcp__plugin_tavily-tools_tavily__tavily_search
     - mcp__plugin_tavily-tools_tavily__tavily_extract
   ```

4. Check that the tool is allowed in your project's permissions. In `.claude/settings.local.json`:
   ```json
   {
     "permissions": {
       "allow": [
         "mcp__plugin_tavily-tools_tavily__tavily_search"
       ]
     }
   }
   ```

---

## OpenRouter API Error

**Symptom:** Slash commands like `/codex`, `/deepseek`, `/minimax` fail with API errors.

**Cause:** Missing or invalid `OPENROUTER_API_KEY`, or the requested model is unavailable.

**Solution:**

1. Check that the API key is set:
   ```bash
   echo $OPENROUTER_API_KEY
   ```
   If empty, set it:
   ```bash
   export OPENROUTER_API_KEY='your-key-here'
   ```
   Add this to your shell profile (`~/.bashrc`, `~/.zshrc`) for persistence.

2. Test the API key directly:
   ```bash
   python3 ~/.claude/scripts/llm-studio/openrouter-api.py \
     --model deepseek \
     --prompt "Hello, world"
   ```

3. If you get a specific HTTP error:
   - **401 Unauthorized** — API key is invalid. Generate a new one at [openrouter.ai](https://openrouter.ai)
   - **402 Payment Required** — Insufficient credits. Add funds to your OpenRouter account
   - **404 Not Found** — Model ID is wrong. Check `MODEL_ALIASES` in `openrouter-api.py`
   - **429 Too Many Requests** — Rate limited. Wait and retry
   - **503 Service Unavailable** — The model is temporarily down. Try a different model

4. If a specific model is unavailable, check its status on [openrouter.ai/models](https://openrouter.ai/models) or try an alternative alias. Current aliases are defined in `openrouter-api.py`:

   | Alias | Model |
   |-------|-------|
   | `codex` | `openai/gpt-5.2-codex` |
   | `deepseek` | `deepseek/deepseek-v3.2` |
   | `kimi` | `moonshotai/kimi-k2.5` |
   | `minimax` | `minimax/minimax-m2-her` |
   | `mistral` | `mistralai/mistral-small-creative` |

---

## Statusline Not Showing

**Symptom:** The status bar at the bottom of Claude Code is blank or missing the session/rate-limit information.

**Cause:** The statusline script is not configured, not executable, or failing silently.

**Solution:**

1. Check that `settings.json` has the statusline configured:
   ```json
   {
     "statusLine": {
       "command": "~/.claude/scripts/statusline.sh"
     }
   }
   ```

2. Make sure the script exists and is executable:
   ```bash
   ls -la ~/.claude/scripts/statusline.sh
   chmod +x ~/.claude/scripts/statusline.sh
   ```

3. Test the script manually by piping sample JSON:
   ```bash
   echo '{"context_window_size":200000,"total_cost_usd":0.5,"input_tokens":50000}' | \
     ~/.claude/scripts/statusline.sh
   ```
   You should see colored output with percentages and costs.

4. If the 5-hour rate limit section shows `?`, the script cannot read your OAuth credentials. This is normal if:
   - You are not logged in to Claude Code via OAuth
   - The credentials file (`~/.claude/.credentials.json`) does not exist
   - The Anthropic API is temporarily unreachable

5. If you see `curl` errors, make sure `curl` is installed:
   ```bash
   which curl
   ```

---

## Hooks Not Firing

**Symptom:** Hooks configured in `settings.json` do not execute when the expected event occurs.

**Cause:** Misconfigured hook entry, wrong event name, or script permission issue.

**Solution:**

1. Check the hook configuration in `~/.claude/settings.json`. The structure should be:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash",
           "command": "/absolute/path/to/script.sh"
         }
       ]
     }
   }
   ```

2. Verify the event name is correct. Valid hook events:
   - `PreToolUse` — fires before a tool is called
   - `PostToolUse` — fires after a tool completes
   - `Notification` — fires on notifications
   - `Stop` — fires when Claude finishes

3. Check the `matcher` value. It is a regex pattern matched against the tool name. For example:
   - `"Bash"` matches any Bash tool use
   - `"Write"` matches file writes
   - `".*"` matches everything (use with caution)

4. Make sure the script is executable and uses an absolute path:
   ```bash
   chmod +x /path/to/your/hook-script.sh
   ```

5. Test the script independently:
   ```bash
   /path/to/your/hook-script.sh
   ```

---

## Pipeline Validation Fails

**Symptom:** Running `validate-pipeline.sh my-pipeline` reports errors.

**Common causes and fixes:**

### "Workflow file does not exist"
The file `~/.claude/workflows/my-pipeline.flow` is missing.
- Check the filename matches the pipeline name exactly (kebab-case)
- Make sure the file is in `~/.claude/workflows/`, not somewhere else

### "Frontmatter is incorrect or missing"
The `.flow` file must start with YAML frontmatter:
```yaml
---
name: my-pipeline
description: ...
params:
  topic: ...
---
```
- Check for a `name:` field
- Check that the file starts with `---` and has a closing `---`

### "Workflow section not found"
The `.flow` file must contain a line that says exactly `Workflow:` (with capital W).

### "Agent not found: [agent-file]"
An agent referenced in the workflow does not have a corresponding `.md` file:
- Check `~/.claude/agents/` for the file
- Make sure the agent name in the workflow matches the filename (without `.md`)

### "Invalid model: [model]"
The agent's frontmatter has an unrecognized model:
- Valid values: `opus`, `sonnet`, `haiku`
- Check for typos or extra whitespace in the `model:` line

### "Agent NOT registered in external-agents.json"
The agent file exists but is not in the registry:
- Run `~/.claude/scripts/restore-orchestration-agents.sh`

---

## CLAUDE.md Sections Duplicated

**Symptom:** `~/.claude/CLAUDE.md` has duplicate pipeline documentation sections.

**Cause:** A section was appended without checking if it already exists.

**Solution:**

1. Open `~/.claude/CLAUDE.md` in an editor
2. Search for duplicate `## Pipeline Name` sections
3. Remove the duplicates, keeping only one copy of each section

**Prevention:** When appending sections programmatically, check for existing content first:
```bash
if ! grep -q "## My Pipeline" ~/.claude/CLAUDE.md; then
  cat my-section.md >> ~/.claude/CLAUDE.md
fi
```

---

## Scripts Not Executable

**Symptom:** Running a pipeline or slash command fails with "Permission denied" errors.

**Cause:** Shell scripts do not have the execute permission bit set.

**Solution:**

Set execute permissions on all scripts:

```bash
# Restore script
chmod +x ~/.claude/scripts/restore-orchestration-agents.sh

# Statusline
chmod +x ~/.claude/scripts/statusline.sh

# LLM Studio scripts
chmod +x ~/.claude/scripts/llm-studio/*.sh

# Validation script
chmod +x ~/.claude/skills/orchestration-builder/scripts/validate-pipeline.sh
```

Or set them all at once:
```bash
find ~/.claude/scripts -name "*.sh" -exec chmod +x {} \;
find ~/.claude/skills -name "*.sh" -exec chmod +x {} \;
```

---

## How to Reset Everything

If your setup is in a broken state and you want to start fresh:

### Option 1: Selective Cleanup

Remove only the Starter Kit components, preserving your Claude Code base installation:

```bash
# Remove agents
rm -rf ~/.claude/agents/

# Remove workflows
rm -rf ~/.claude/workflows/

# Remove custom commands
rm -rf ~/.claude/commands/

# Remove scripts
rm -rf ~/.claude/scripts/

# Remove skills
rm -rf ~/.claude/skills/orchestration-builder/

# Reset the agent registry
rm -f ~/.claude/plugins/cache/orchestration-marketplace/orchestration/*/skills/managing-agents/external-agents.json
```

Then edit `~/.claude/CLAUDE.md` to remove the pipeline documentation sections.

### Option 2: Full Reset

Remove the entire Claude Code configuration (this will also remove your settings, conversation history, and credentials):

```bash
rm -rf ~/.claude/
```

Then restart Claude Code — it will recreate the base directory structure on first launch.

**Warning:** This removes ALL Claude Code configuration, not just the Starter Kit. Back up `~/.claude/settings.json` and `~/.claude/CLAUDE.md` first if you have custom settings you want to preserve.

---

## Getting Help

If none of the above solutions work:

1. Check the [ARCHITECTURE.md](./ARCHITECTURE.md) to understand how the components connect
2. Run the validation script with verbose output to identify the specific failure point
3. Check file permissions: `ls -la ~/.claude/agents/ ~/.claude/workflows/`
4. Check the orchestration plugin version: `ls ~/.claude/plugins/cache/orchestration-marketplace/orchestration/`
5. Open an issue on the repository with:
   - Your Claude Code version
   - Your OS
   - The exact error message
   - Output of `validate-pipeline.sh` if applicable
