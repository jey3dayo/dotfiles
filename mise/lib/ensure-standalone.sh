#!/usr/bin/env sh
# 自己更新機能を持つ CLI は mise [tools] に置くと更新経路が二重になる
# (例: codex はバックグラウンド更新デーモンが install method を無視して standalone
# installer を直接走らせる openai/codex#24035 がある)ため、ここは未導入時の導入保証のみを担い、
# 更新は `mise run update:standalone`(各ツール自身の update コマンド)に任せる。
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
ensure_installed herdr "curl -fsSL https://herdr.dev/install.sh | sh"
# installer は ~/.opencode/bin へ置き zshrc に PATH を追記するため、追記を止めて ~/.local/bin へ link する
ensure_installed opencode "curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path && ln -sf \"\${HOME}/.opencode/bin/opencode\" \"\${HOME}/.local/bin/opencode\""
