#!/usr/bin/env sh
# python のライブラリ(CLI ではなく import されるもの)は mise [tools] で表現できない。
# `pipx:` は隔離 venv に CLI を生やす仕組みなので、既定の python3 からは import できない。
# よって pip で python 本体へ入れ、その導入保証だけをここで宣言する。
#
# mise の python は installs/python/3.14 -> ./3.14.7 の symlink で、patch が上がると
# 実体が切り替わり site-packages が参照から外れる。このフックがそのとき入れ直す。
#
# playwright: diagram-design の PNG export が `from playwright.sync_api import sync_playwright`
# として使う(skills/diagram-design/references/export.md, scripts/lint-render.py)。
set -eu

run_python() {
  mise exec python -- python3 "$@"
}

ensure_python_lib() {
  module="$1"
  package="$2"

  if run_python -c "import ${module}" >/dev/null 2>&1; then
    return 0
  fi

  echo "⚠️  python module ${module} is missing. Installing ${package}..."
  run_python -m pip install "${package}"

  if run_python -c "import ${module}" >/dev/null 2>&1; then
    return 0
  fi

  echo "❌ Failed to install ${package}."
  return 1
}

ensure_python_lib playwright playwright

# ブラウザ本体は ~/Library/Caches/ms-playwright を Node 版(npm:@playwright/mcp)と共有する。
# 要求 revision が既にあれば取得はスキップされる。
run_python -m playwright install chromium
