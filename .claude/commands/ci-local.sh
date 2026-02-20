#!/usr/bin/env bash

# CI Local Execution Command
# CI (.github/workflows/ci.yml) をローカルで可能な限り再現するためのコマンド

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

ローカルでGitHub Actions CI (.github/workflows/ci.yml) のチェック内容を実行

COMMANDS:
    check       workflow 相当の CI チェックを実行 (default)
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
    GitHub Actions 固有ステップ（apt-get など）はローカルでは省略されますが、
    チェック本体は mise タスクを通して workflow に合わせて実行します。
EOF
}

setup_ci_env() {
  # Force CI-optimized mise config for parity with GitHub Actions.
  local ci_config="$PROJECT_ROOT/mise/config.ci.toml"
  local previous_config="${MISE_CONFIG_FILE:-}"

  export MISE_CONFIG_FILE="$ci_config"

  if [[ -n "$previous_config" && "$previous_config" != "$ci_config" ]]; then
    log_info "MISE_CONFIG_FILE を CI 用に上書き: $previous_config -> $MISE_CONFIG_FILE"
  else
    log_info "MISE_CONFIG_FILE を設定: $MISE_CONFIG_FILE"
  fi
}

verify_deployment() {
  # Mirror "Verify dotfiles deployment" step in .github/workflows/ci.yml.
  local file
  local files=(.bashrc .bash_profile .zshenv .zshrc .gitconfig .tmux.conf)

  for file in "${files[@]}"; do
    if [ -L "$HOME/$file" ]; then
      log_success "$file は正常にデプロイされました"
    else
      log_error "$file のデプロイに失敗しました"
      return 1
    fi
  done

  local link_count
  link_count=$(find "$HOME/.config" -maxdepth 1 -type l | wc -l)
  log_info "$HOME/.config/ 内のシンボリックリンク数: $link_count"

  if [ "$link_count" -ge 46 ]; then
    log_success "期待されるファイル数（46個以上）が配置されました"
  else
    log_warning "配置されたファイル数が期待値より少ない（期待: 46個以上、実際: $link_count個）"
  fi
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

  # CI workflow parity: deploy step (best effort in local environment)
  if command -v nix >/dev/null 2>&1; then
    log_info "実行中: Deploy dotfiles with Home Manager"
    if mise run ci:deploy; then
      log_success "Home Manager deploy - PASSED"
    else
      log_error "Home Manager deploy - FAILED"
      return 1
    fi

    log_info "実行中: Verify dotfiles deployment"
    if verify_deployment; then
      log_success "dotfiles deployment verify - PASSED"
    else
      log_error "dotfiles deployment verify - FAILED"
      return 1
    fi
  else
    log_warning "nix が見つからないため、ci:deploy と deployment verify はスキップします"
  fi

  # CI workflow parity: Run all CI checks via aggregate task.
  log_info "実行中: mise run ci"
  if mise run ci; then
    log_success "mise run ci - PASSED"
    log_info "GitHub Actions CI のチェック内容と整合しています ✨"
    return 0
  fi

  log_error "mise run ci - FAILED"
  log_warning "GitHub Actions CI でも失敗する可能性があります"
  return 1
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
  setup_ci_env

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
