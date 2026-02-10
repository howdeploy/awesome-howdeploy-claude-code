# DeepWiki Lookup

Automatic GitHub repository analysis via [deepwiki.com](https://deepwiki.com). When you share a GitHub repository URL in conversation, Claude fetches the DeepWiki page for that repository and returns a structured breakdown of the project.

## How It Works

1. You share a GitHub URL (e.g., `https://github.com/owner/repo`, `github.com/owner/repo`, or just `owner/repo` in context)
2. Claude extracts the `owner/repo` identifier
3. Claude fetches `https://deepwiki.com/{owner}/{repo}` using `tavily_extract` with `extract_depth: advanced`
4. If the page exists, Claude returns a structured analysis
5. If the page is empty or missing, Claude reports that the repo is not indexed on DeepWiki

For deeper analysis, Claude can also follow subpage links from the DeepWiki table of contents (architecture details, API docs, etc.).

## Output Structure

When a repository is found on DeepWiki, the analysis covers:

| Section | Content |
|---------|---------|
| **What it is** | Brief project description and purpose |
| **Architecture** | Key components and how they connect |
| **Stack** | Languages, frameworks, and dependencies |
| **Key modules** | Main parts of the codebase and their responsibilities |
| **Quick start** | How to get started (if available in the DeepWiki page) |

## Setup

### 1. Add the DeepWiki Lookup section to your CLAUDE.md

Add the following to `~/.claude/CLAUDE.md`:

```markdown
## DeepWiki Lookup

When the user shares a GitHub repository URL:

1. Extract `owner/repo` from the link
2. Fetch `https://deepwiki.com/{owner}/{repo}` via `tavily_extract` (extract_depth: advanced)
3. If found -- return structured breakdown: What it is, Architecture, Stack, Key modules, Quick start
4. If not found -- report that the repo is not indexed on DeepWiki
5. For deep analysis -- fetch subpages from the table of contents
```

### 2. Ensure the Tavily plugin is installed

The lookup uses `tavily_extract` with advanced extraction. Make sure the Tavily tools plugin is available in your Claude Code setup.

## Limitations

- **Public repositories only** -- DeepWiki does not index private repos
- **Not all repos are indexed** -- popular and well-known repositories are almost always available; smaller or newer repos may not be
- **Data may lag** -- DeepWiki content may not reflect the very latest state of a repository
- **No authentication** -- no API key or login is required for DeepWiki itself

## Examples

**User:** "What is https://github.com/anthropics/claude-code?"

**Claude will:**
1. Extract `anthropics/claude-code`
2. Fetch `https://deepwiki.com/anthropics/claude-code`
3. Return a structured breakdown of the project

**User:** "Tell me about facebook/react"

**Claude will:**
1. Recognize `facebook/react` as a repo reference
2. Fetch `https://deepwiki.com/facebook/react`
3. Return architecture, stack, key modules, and quick start info
