# Contributing

Thanks for your interest in contributing to Claude Code Starter Kit!

## Ways to Contribute

- **New pipelines** — Create and share your own orchestration pipelines
- **New hooks** — Share useful hook examples
- **New models** — Add models to LLM Studio
- **Bug fixes** — Fix issues in existing components
- **Documentation** — Improve guides, translations, examples
## Guidelines

### Before submitting

1. **No secrets** — Run `grep -r "sk-or-v1" .` to ensure no API keys are committed
2. **Follow existing patterns** — Look at how existing pipelines/hooks/skills are structured
3. **Test with Claude Code** — Open the repo in Claude Code and verify your examples work

### Adding a new pipeline

1. Create directory under `pipelines/your-pipeline/`
2. Include: `README.md`, agents in `agents/`, workflow in `workflows/`
3. Add a CLAUDE.md section in `configs/claude-md-sections/`
4. Update main README with your pipeline

### Adding a new skill

1. Create `extras/skills/your-skill/SKILL.md` with YAML frontmatter
2. Include trigger phrases, algorithm, and examples
3. Update main README with your skill

### Adding a hook example

1. Create JSON file in `extras/hooks/examples/`
2. Follow the Claude Code hook schema (PreToolUse, PostToolUse, or Notification)
3. Add description to `extras/hooks/README.md`
4. Test the hook in a real Claude Code session

### Adding a model to LLM Studio

1. Add alias to `MODEL_ALIASES` in `pipelines/llm-studio/scripts/openrouter-api.py`
2. Create `scripts/your-model-query.sh.example` (no API keys!)
3. Create `commands/your-model.md`
4. Document in `pipelines/llm-studio/README.md`

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-pipeline`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request with a clear description

## Code of Conduct

Be respectful, constructive, and helpful. We're all here to make Claude Code better.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
