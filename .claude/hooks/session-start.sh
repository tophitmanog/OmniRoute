#!/bin/bash
# SessionStart hook: provisions the CLI tools this repo's Claude Code setup expects
# (Graphify skill + OmniRoute CLI). Plugins (ponytail, agent-skills) are declared in
# .claude/settings.json and are fetched by Claude Code itself.
# Runs only in Claude Code on the web; never fails the session.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

export PATH="$HOME/.local/bin:$PATH"
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# Graphify — PyPI package is "graphifyy" (double y); `graphify install` registers /graphify
if ! command -v graphify >/dev/null 2>&1; then
  if command -v uv >/dev/null 2>&1; then
    uv tool install graphifyy >/dev/null 2>&1
  elif command -v pipx >/dev/null 2>&1; then
    pipx install graphifyy >/dev/null 2>&1
  else
    pip install -q --user graphifyy >/dev/null 2>&1 || pip install -q graphifyy >/dev/null 2>&1
  fi
fi
if command -v graphify >/dev/null 2>&1 && [ ! -d "$HOME/.claude/skills/graphify" ]; then
  graphify install >/dev/null 2>&1 || echo "graphify install failed" >&2
fi

# OmniRoute CLI (server on localhost:20128 — start manually with `omniroute`)
if ! command -v omniroute >/dev/null 2>&1; then
  npm i -g omniroute >/dev/null 2>&1 || echo "npm i -g omniroute failed" >&2
fi

exit 0
