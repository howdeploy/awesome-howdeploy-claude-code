#!/usr/bin/env python3
"""
OpenRouter API wrapper for LLM Studio pipeline.
Универсальный скрипт для отправки запросов к разным моделям через OpenRouter.

Usage:
    python openrouter-api.py --model <model_id> --prompt <prompt> [--system <system_prompt>]

    echo "prompt" | python openrouter-api.py --model <model_id>

Environment:
    OPENROUTER_API_KEY - API ключ OpenRouter (обязательно)

Models:
    - thudm/glm-4-9b-chat (GLM 4.7)
    - minimax/minimax-01 (Minimax m2.1)
"""

import os
import sys
import json
import argparse
import urllib.request
import urllib.error

OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions"

# Маппинг коротких имён на полные ID моделей
MODEL_ALIASES = {
    # Mistral - креатив, маркетинг, ролевое общение
    "mistral": "mistralai/mistral-small-creative",
    "mistral-creative": "mistralai/mistral-small-creative",

    # Minimax - диалоги, ролевые игры, личности
    "minimax": "minimax/minimax-m2-her",
    "minimax-her": "minimax/minimax-m2-her",

    # DeepSeek - универсальная, дешёвая
    "deepseek": "deepseek/deepseek-v3.2",
    "deepseek-chat": "deepseek/deepseek-v3.2",

    # GPT-5.2 Codex - код, программирование
    "codex": "openai/gpt-5.2-codex",
    "gpt-codex": "openai/gpt-5.2-codex",

    # Kimi K2.5 - документы, код, большой контекст
    "kimi": "moonshotai/kimi-k2.5",
    "kimi-k2.5": "moonshotai/kimi-k2.5",
}


def get_api_key():
    key = os.environ.get("OPENROUTER_API_KEY")
    if not key:
        print("ERROR: OPENROUTER_API_KEY not set", file=sys.stderr)
        print("Set it with: export OPENROUTER_API_KEY='your-key'", file=sys.stderr)
        sys.exit(1)
    return key


def resolve_model(model_name: str) -> str:
    """Resolve model alias to full model ID."""
    return MODEL_ALIASES.get(model_name.lower(), model_name)


def call_openrouter(model: str, prompt: str, system_prompt: str = None) -> str:
    """Send request to OpenRouter API and return response."""
    api_key = get_api_key()
    model_id = resolve_model(model)

    messages = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
    messages.append({"role": "user", "content": prompt})

    payload = {
        "model": model_id,
        "messages": messages,
    }

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://github.com/claude-code",
        "X-Title": "LLM Studio Pipeline",
    }

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(OPENROUTER_API_URL, data=data, headers=headers, method="POST")

    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            result = json.loads(response.read().decode("utf-8"))
            return result["choices"][0]["message"]["content"]
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8")
        print(f"API Error {e.code}: {error_body}", file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"Network Error: {e.reason}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="OpenRouter API wrapper")
    parser.add_argument("--model", "-m", required=True, help="Model ID or alias (glm, minimax)")
    parser.add_argument("--prompt", "-p", help="Prompt text (or read from stdin)")
    parser.add_argument("--system", "-s", help="System prompt")
    parser.add_argument("--file", "-f", help="Read prompt from file")

    args = parser.parse_args()

    # Get prompt from args, file, or stdin
    if args.prompt:
        prompt = args.prompt
    elif args.file:
        with open(args.file, "r") as f:
            prompt = f.read()
    elif not sys.stdin.isatty():
        prompt = sys.stdin.read()
    else:
        print("ERROR: No prompt provided. Use --prompt, --file, or pipe to stdin", file=sys.stderr)
        sys.exit(1)

    result = call_openrouter(args.model, prompt.strip(), args.system)
    print(result)


if __name__ == "__main__":
    main()
