#!/usr/bin/env bash

# CI Local Execution Command
# CI (.github/workflows/ci.yml) をローカルで実行するためのコマンド

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
  echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}❌${NC} $1"
}

log_section() {
  echo -e "${CYAN}━━━ $1 ━━━${NC}"
}

usage() {
  cat <<EOF
Usage: ci-local [OPTIONS] [COMMAND]

ローカルでGitHub Actions CI (.github/workflows/ci.yml) と同等のチェックを実行

COMMANDS:
    check       すべてのCI チェックを実行 (default)
    install     必要なツールをインストール
    setup       環境のセットアップ (mise + ツールインストール)

OPTIONS:
    -h, --help  このヘルプを表示
    --no-color  カラー出力を無効化
    --verbose   詳細な出力

EXAMPLES:
    ci-local                 # 全てのCIチェックを実行
    ci-local setup           # 環境をセットアップ
    ci-local install         # 必要なツールのみインストール

NOTE:
    これはGitHub Actionsの .github/workflows/ci.yml と完全に同等の処理を
    ローカル環境で実行します。miseを使用して必要なツールを管理します。
EOF
}

check_mise_installation() {
  if ! command -v mise &>/dev/null; then
    log_error "mise が見つかりません"
    log_info "mise をインストールしてください: https://mise.jdx.dev/getting-started.html"
    exit 1
  fi
  log_success "mise が利用可能です"
}

setup_environment() {
  log_section "環境のセットアップ"

  cd "$PROJECT_ROOT"

  # mise install でツールをインストール
  log_info "mise を使用して開発ツールをインストール中..."
  mise install

  # 必要な追加ツールをインストール
  install_tools

  log_success "環境のセットアップが完了しました"
}

install_tools() {
  log_section "追加ツールのインストール"

  cd "$PROJECT_ROOT"

  # mise run ci:install を実行して必要なツールをインストール
  log_info "必要なツールをインストール中..."
  if mise run ci:install; then
    log_success "ツールのインストールが完了しました"
  else
    log_warning "一部のツールのインストールに失敗しましたが、継続します"
  fi

  # PATH に LuaRocks bin を追加
  if [[ -d "$HOME/.luarocks/bin" ]]; then
    export PATH="$HOME/.luarocks/bin:$PATH"
    log_info "LuaRocks bin を PATH に追加しました"
  fi
}

run_ci_checks() {
  log_section "CI チェックの実行"

  cd "$PROJECT_ROOT"

  local failed=0

  # 各チェックを順番に実行し、結果を記録
  local checks=(
    "format:biome:check|Biome チェック (JS/TS/JSON)"
    "format:markdown:check|Markdown フォーマット"
    "format:yaml:check|YAML フォーマット"
    "lint:lua|Lua lint (luacheck)"
    "format:lua:check|Lua フォーマット (stylua)"
    "format:shell:check|Shell フォーマット (shfmt)"
  )

  for check in "${checks[@]}"; do
    local task="${check%|*}"
    local name="${check#*|}"

    log_info "実行中: $name"
    if mise run "$task"; then
      log_success "$name - PASSED"
    else
      log_error "$name - FAILED"
      ((failed++))
    fi
    echo
  done

  # 結果のサマリー
  log_section "チェック結果"
  local total=${#checks[@]}
  local passed=$((total - failed))

  if [[ $failed -eq 0 ]]; then
    log_success "すべてのチェックが成功しました! ($passed/$total)"
    log_info "GitHub Actions CI も成功するはずです ✨"
    return 0
  else
    log_error "$failed/$total のチェックが失敗しました"
    log_warning "GitHub Actions CI でも失敗する可能性があります"
    return 1
  fi
}

main() {
  local command="check"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      --no-color)
        # Disable colors
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        CYAN=''
        NC=''
        shift
        ;;
      --verbose)
        set -x
        shift
        ;;
      check | install | setup)
        command="$1"
        shift
        ;;
      *)
        log_error "不明なオプション: $1"
        usage
        exit 1
        ;;
    esac
  done

  check_mise_installation

  case $command in
    setup)
      setup_environment
      ;;
    install)
      install_tools
      ;;
    check)
      run_ci_checks
      ;;
    *)
      log_error "不明なコマンド: $command"
      usage
      exit 1
      ;;
  esac
}

# スクリプトが直接実行された場合のみ main を呼び出す
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
