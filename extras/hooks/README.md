# Hook Examples

Comprehensive guide to Claude Code hooks with 6 ready-to-use examples. Hooks are shell commands that execute automatically in response to Claude Code events -- they let you enforce rules, run formatters, trigger tests, and send notifications without manual intervention.

## What Are Hooks

Hooks are shell commands tied to specific Claude Code lifecycle events. They run outside of Claude's AI context, meaning they execute deterministically and cannot be influenced by prompt content. This makes them ideal for enforcing security policies, maintaining code quality, and automating repetitive tasks.

## Hook Types

| Type | When it fires | Can block action | Use cases |
|------|--------------|-----------------|-----------|
| `PreToolUse` | Before a tool executes | Yes (exit code 2) | Block secret commits, validate file paths, require confirmation |
| `PostToolUse` | After a tool executes | No | Auto-format code, run linters, trigger tests |
| `Notification` | On Claude Code events | No | Desktop notifications, logging, alerts |

## Hook JSON Format

Each hook is a JSON object with these fields:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "echo 'A file was written or edited'",
        "timeout": 10000
      }
    ]
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `matcher` | string (regex) | Tool name pattern to match. Omit to match all tools. |
| `command` | string | Shell command to execute. Receives event data on stdin as JSON. |
| `timeout` | number | Max execution time in milliseconds (default: 60000). |

### Matcher Patterns

- `"Write"` -- matches only the Write tool
- `"Write|Edit"` -- matches Write or Edit
- `"git.*"` -- matches any tool starting with "git"
- Omit `matcher` entirely to match every tool invocation

### Exit Codes (PreToolUse only)

| Exit code | Behavior |
|-----------|----------|
| 0 | Allow the tool to proceed |
| 2 | Block the tool execution (Claude sees the rejection) |
| Other | Treated as an error, tool still proceeds |

### Stdin Data

The hook command receives JSON on stdin with details about the event:

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "content": "..."
  }
}
```

## Examples

### 1. autoformat-on-save.json

Runs Prettier on JS/TS files and Black on Python files after every Write or Edit operation.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "FILE=$(cat | sed -n 's/.*\"file_path\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p' | head -1); case \"$FILE\" in *.js|*.ts|*.jsx|*.tsx) npx prettier --write \"$FILE\" 2>/dev/null ;; *.py) black \"$FILE\" 2>/dev/null ;; esac; exit 0",
        "timeout": 15000
      }
    ]
  }
}
```

### 2. block-secret-commits.json

Blocks `git commit` if the staged diff contains potential secrets (API keys, tokens, passwords).

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "INPUT=$(cat); CMD=$(echo \"$INPUT\" | sed -n 's/.*\"command\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p' | head -1); case \"$CMD\" in *git\\ commit*|*git\\ push*) DIFF=$(git diff --cached 2>/dev/null); if echo \"$DIFF\" | grep -qiE '(api_key|api.key|secret|password|token|credential)\\s*[=:]\\s*[\"'\\'']{0,1}[A-Za-z0-9+/=_-]{16,}'; then echo 'BLOCKED: Potential secrets detected in staged changes. Review with: git diff --cached' >&2; exit 2; fi ;; esac; exit 0",
        "timeout": 10000
      }
    ]
  }
}
```

### 3. notify-on-completion.json

Sends a desktop notification when Claude finishes a task (works on both macOS and Linux).

```json
{
  "hooks": {
    "Notification": [
      {
        "command": "MSG=$(cat | sed -n 's/.*\"message\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p' | head -1); MSG=${MSG:-Task completed}; if [ \"$(uname)\" = 'Darwin' ]; then osascript -e \"display notification \\\"$MSG\\\" with title \\\"Claude Code\\\"\"; else notify-send 'Claude Code' \"$MSG\" 2>/dev/null; fi; exit 0",
        "timeout": 5000
      }
    ]
  }
}
```

### 4. lint-before-commit.json

Runs ESLint before allowing a git commit. Blocks the commit if linting fails.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "INPUT=$(cat); CMD=$(echo \"$INPUT\" | sed -n 's/.*\"command\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p' | head -1); case \"$CMD\" in *git\\ commit*) if command -v npx >/dev/null 2>&1 && [ -f .eslintrc* ] || [ -f eslint.config.* ]; then npx eslint . --quiet 2>/dev/null; if [ $? -ne 0 ]; then echo 'BLOCKED: ESLint errors found. Fix them before committing.' >&2; exit 2; fi; fi ;; esac; exit 0",
        "timeout": 30000
      }
    ]
  }
}
```

### 5. auto-test-on-edit.json

Runs the project's test suite after any file edit in `src/` directories.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "FILE=$(cat | sed -n 's/.*\"file_path\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p' | head -1); case \"$FILE\" in */src/*) if [ -f package.json ] && grep -q '\"test\"' package.json; then npm test --silent 2>/dev/null; elif [ -f pytest.ini ] || [ -f pyproject.toml ]; then python -m pytest --quiet 2>/dev/null; fi ;; esac; exit 0",
        "timeout": 60000
      }
    ]
  }
}
```

### 6. context-warning.json

Warns when context window usage exceeds 70% by checking the notification event data.

```json
{
  "hooks": {
    "Notification": [
      {
        "command": "INPUT=$(cat); PCT=$(echo \"$INPUT\" | sed -n 's/.*\"context_percent\"[[:space:]]*:[[:space:]]*\\([0-9]*\\).*/\\1/p' | head -1); if [ -n \"$PCT\" ] && [ \"$PCT\" -gt 70 ] 2>/dev/null; then echo \"WARNING: Context usage at ${PCT}%%. Consider starting a new session with /compact.\" >&2; if [ \"$(uname)\" = 'Darwin' ]; then osascript -e \"display notification \\\"Context at ${PCT}%%\\\" with title \\\"Claude Code Warning\\\"\"; else notify-send 'Claude Code' \"Context at ${PCT}%\" 2>/dev/null; fi; fi; exit 0",
        "timeout": 5000
      }
    ]
  }
}
```

## Where Hooks Live

Hooks can be configured in two places:

| Location | Scope | File |
|----------|-------|------|
| Project-level | Applies to one project | `.claude/settings.local.json` (in project root) |
| Global | Applies to all projects | `~/.claude/settings.json` |

Project-level hooks take precedence over global hooks when both define hooks for the same event type.

## How to Install

### Option 1: Add to global settings

Copy the hook JSON into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "command": "...", "timeout": 10000 }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit", "command": "...", "timeout": 15000 }
    ]
  }
}
```

### Option 2: Add to a specific project

Create or edit `.claude/settings.local.json` in your project root:

```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Write|Edit", "command": "...", "timeout": 15000 }
    ]
  }
}
```

### Option 3: Copy example files

Copy the JSON files from `examples/` into your settings:

```bash
# Read an example and merge it into your settings manually
cat examples/autoformat-on-save.json
```

## Tips

- **Keep hooks fast.** Long-running hooks delay Claude's workflow. Use appropriate `timeout` values.
- **Use exit code 2 sparingly.** Blocking tool execution interrupts the AI's plan. Reserve it for genuine safety checks.
- **Test hooks independently.** Run the command manually with sample JSON piped to stdin before adding it to settings.
- **Combine related hooks.** Multiple hooks of the same type run sequentially. Keep the list manageable.
- **Check stderr.** Hook error messages printed to stderr are visible to Claude and can influence its behavior.

## File Structure

```
hooks/
  examples/                     # Ready-to-use hook JSON files
    autoformat-on-save.json     # Auto-format after Write/Edit
    block-secret-commits.json   # Block commits with secrets
    notify-on-completion.json   # Desktop notification on task completion
    lint-before-commit.json     # ESLint check before git commit
    auto-test-on-edit.json      # Run tests after src/ file edits
    context-warning.json        # Warn when context > 70%
```
