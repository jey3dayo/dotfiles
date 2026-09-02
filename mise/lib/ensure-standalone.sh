#!/usr/bin/env sh
# 自己更新機能を持つ CLI(claude / codex)は mise [tools] に置くと更新経路が二重になる
# (例: codex はバックグラウンド更新デーモンが install method を無視して standalone
# installer を直接走らせる openai/codex#24035 がある)ため、mise は導入保証のみを担い、
# 更新は各ツール自身の `claude update` / `codex update` に任せる。
set -eu

export PATH="${HOME}/.local/bin:${PATH}"

ensure_installed() {
  name="$1"
  installer="$2"

  if command -v "${name}" >/dev/null 2>&1; then
    return 0
  fi

  echo "⚠️  ${name} is missing. Installing via official installer..."
  sh -c "${installer}"

  if command -v "${name}" >/dev/null 2>&1; then
    return 0
  fi

  echo "❌ Failed to install ${name}."
  return 1
}

ensure_installed claude "curl -fsSL https://claude.ai/install.sh | bash"
ensure_installed codex "curl -fsSL https://chatgpt.com/codex/install.sh | sh"
