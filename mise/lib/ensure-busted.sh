#!/usr/bin/env sh
# Shared busted bootstrap for Lua-related mise tasks.

ensure_busted() {
  export PATH="${HOME}/.luarocks/bin:${PATH}"

  if command -v busted >/dev/null 2>&1 && busted --version >/dev/null 2>&1; then
    return 0
  fi

  echo "⚠️  busted is missing or broken. Installing via luarocks..."
  luarocks install --local busted

  if command -v busted >/dev/null 2>&1 && busted --version >/dev/null 2>&1; then
    return 0
  fi

  echo "❌ Failed to prepare busted. Please run: mise run ci:install"
  return 1
}
