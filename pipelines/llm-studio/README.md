# LLM Studio

Route tasks to external LLM models via the OpenRouter API, directly from Claude Code. Each model is exposed as a slash command — type `/kimi`, `/deepseek`, `/codex`, `/minimax`, or `/mistral` and Claude orchestrates the request, reads files if needed, and returns the result.

## Models

| Command | Model | Specialization | Context | Can edit files |
|---------|-------|---------------|---------|----------------|
| `/kimi` | Kimi K2.5 | Document analysis, code, large-context tasks | 262K | Yes (via Claude) |
| `/deepseek` | DeepSeek V3.2 | Universal, cheap, explanations | 164K | Yes (via Claude) |
| `/codex` | GPT-5.2 Codex | Code generation, refactoring, debugging | - | Yes (via Claude) |
| `/minimax` | Minimax M2 Her | Roleplay, dialogues, character personas | - | No (chat only) |
| `/mistral` | Mistral Small Creative | Marketing copy, creative writing, ideation | - | No (chat only) |

## Architecture

```
User types /kimi "Analyze this PDF"
        |
        v
  Claude reads the slash command definition (commands/kimi.md)
        |
        v
  Claude finds relevant files (ls, Glob)
        |
        v
  Shell script (kimi-query.sh) reads file contents,
  pipes everything to openrouter-api.py
        |
        v
  openrouter-api.py resolves model alias, sends request to OpenRouter API
        |
        v
  Response returned to Claude, which presents it to user
  (and optionally writes changes to files via Edit/Write)
```

## Setup

1. **Get an API key** from [openrouter.ai](https://openrouter.ai)

2. **Export the key** in your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export OPENROUTER_API_KEY='sk-or-v1-...'
```

3. **Copy the example scripts** and make them executable:

```bash
cd scripts/
for f in *.sh.example; do
  cp "$f" "${f%.example}"
  chmod +x "${f%.example}"
done
```

4. **Copy command definitions** to `~/.claude/commands/`:

```bash
cp commands/*.md ~/.claude/commands/
```

5. **Copy scripts** to `~/.claude/scripts/llm-studio/`:

```bash
mkdir -p ~/.claude/scripts/llm-studio
cp scripts/openrouter-api.py ~/.claude/scripts/llm-studio/
cp scripts/*.sh ~/.claude/scripts/llm-studio/
```

## Usage Examples

### Kimi K2.5 — document and code analysis

```
/kimi What is an MCP server?
/kimi Analyze the contracts in contracts/
/kimi Check src/index.ts for bugs
/kimi --files docs/spec.pdf -- Summarize this specification
```

Kimi supports reading these file formats:
- **PDF** — via `pdftotext` or `pypdf`
- **DOCX** — via `python-docx`
- **XLSX** — via `pandas`
- **Code and text files** — read as-is

### DeepSeek V3.2 — universal tasks

```
/deepseek Explain how blockchain works
/deepseek Explain what src/main.py does
```

### GPT-5.2 Codex — programming tasks

```
/codex Write a sorting function in Python
/codex Find bugs in src/utils.ts
```

After receiving the response, Claude can apply code changes to your files automatically using Edit/Write tools.

### Minimax M2 Her — roleplay and personalities

```
/minimax Play the role of a wise mentor
/minimax Continue the dialogue as a skeptical investor
/minimax Create a personality for a tech support AI assistant
```

### Mistral Small Creative — marketing and creative writing

```
/mistral Come up with 5 slogans for an AI startup
/mistral Write a LinkedIn post about automation
/mistral Play the role of an experienced marketer
```

## File Support

| Model | PDF | DOCX | XLSX | Code/Text |
|-------|-----|------|------|-----------|
| Kimi K2.5 | Yes | Yes | Yes | Yes |
| DeepSeek V3.2 | — | — | — | Yes |
| GPT-5.2 Codex | — | — | — | Yes |
| Minimax M2 Her | — | — | — | — |
| Mistral Small Creative | — | — | — | — |

For DeepSeek and Codex, Claude reads the file contents and passes them as part of the prompt text. For Kimi, the shell script handles file reading natively with format-specific extractors.

## Adding a New Model

1. **Add a model alias** in `scripts/openrouter-api.py`:

```python
MODEL_ALIASES = {
    # ... existing aliases ...
    "newmodel": "provider/model-id",
    "newmodel-alt": "provider/model-id",
}
```

2. **Create a query script** from an existing example:

```bash
cp scripts/kimi-query.sh.example scripts/newmodel-query.sh.example
# Edit the script: change model name, system prompt, and specialization
```

3. **Create a command definition**:

```bash
cp commands/kimi.md commands/newmodel.md
# Edit: update the model name, description, specialization, and script path
```

4. **Deploy**:

```bash
cp commands/newmodel.md ~/.claude/commands/
cp scripts/newmodel-query.sh ~/.claude/scripts/llm-studio/
chmod +x ~/.claude/scripts/llm-studio/newmodel-query.sh
```

## File Structure

```
llm-studio/
  commands/
    kimi.md                     # /kimi slash command definition
    deepseek.md                 # /deepseek slash command definition
    codex.md                    # /codex slash command definition
    minimax.md                  # /minimax slash command definition
    mistral.md                  # /mistral slash command definition
  scripts/
    openrouter-api.py           # Universal OpenRouter API wrapper
    kimi-query.sh.example       # Kimi shell script (with file support)
    deepseek-query.sh.example   # DeepSeek shell script
    codex-query.sh.example      # Codex shell script
    minimax-query.sh.example    # Minimax shell script
    mistral-query.sh.example    # Mistral shell script
```
