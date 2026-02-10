# Statusline

Custom status bar for Claude Code that shows context window usage, session cost, 5-hour rate limit utilization, and time until rate limit reset -- all in a compact, color-coded display.

## What It Shows

```
[Session] 45% $2 | [5H] 60% 2h30m
```

| Segment | Meaning |
|---------|---------|
| `[Session]` | Current session stats |
| `45%` | Context window usage (input tokens + cache tokens as % of context window size) |
| `$2` | Session cost in USD |
| `[5H]` | 5-hour rolling rate limit |
| `60%` | Rate limit utilization percentage |
| `2h30m` | Time until rate limit resets |

### Color Coding

All percentage and time values are color-coded:

| Color | Percentage | Time remaining |
|-------|-----------|----------------|
| Green | Below 50% | Under 1 hour |
| Yellow | 50% -- 70% | 1 hour -- 3.5 hours |
| Red | Above 70% | Over 3.5 hours |

## How It Works

The script receives session statistics as JSON from stdin (provided by Claude Code automatically). It extracts:

- `context_window_size` -- total context window capacity
- `input_tokens` -- tokens used by input
- `cache_creation_input_tokens` -- tokens used creating cache
- `cache_read_input_tokens` -- tokens read from cache
- `total_cost_usd` -- session cost

For the 5-hour rate limit, the script calls the Anthropic OAuth usage API:

```
GET https://api.anthropic.com/api/oauth/usage
Authorization: Bearer <oauth_token>
```

The API response is cached for 30 seconds at `/tmp/claude-usage-cache.json` to avoid excessive requests.

### Credential Discovery

The script finds OAuth credentials automatically:

- **macOS:** reads from Keychain (`security find-generic-password -s "Claude Code-credentials"`)
- **Linux:** reads from `~/.claude/.credentials.json`

No manual token configuration is needed.

## Installation

### 1. Copy the script

```bash
mkdir -p ~/.claude
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

### 2. Configure Claude Code

Add the following to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

If the file already exists, merge the `statusLine` key into the existing JSON.

### 3. Restart Claude Code

The status bar will appear at the bottom of the terminal on the next session.

## Cross-Platform Support

The script works on both macOS and Linux. Platform-specific differences are handled automatically:

| Feature | macOS | Linux |
|---------|-------|-------|
| File age check | `stat -f %m` | `stat -c %Y` |
| Date parsing | `date -j -f` | `date -u -d` |
| Credential storage | Keychain | `~/.claude/.credentials.json` |

## Dependencies

- `bash` (standard shell)
- `curl` (for API requests)
- `sed` (for JSON parsing -- no `jq` required)

The script intentionally avoids `jq` to work on systems without it installed.

## File Structure

```
statusline/
  statusline.sh                 # The status bar script (cross-platform)
```
