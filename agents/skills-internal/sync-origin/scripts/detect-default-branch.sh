#!/usr/bin/env bash
#
# detect-default-branch.sh
# デフォルトブランチを自動検出するスクリプト
#
# Usage:
#   detect-default-branch.sh [--remote <remote-name>]
#
# Returns:
#   - デフォルトブランチ名（例: main, master, develop）
#   - 検出できない場合はエラー終了（exit 1）
#

set -euo pipefail

REMOTE="${1:-origin}"

# リモートが存在するか確認
if ! git remote get-url "$REMOTE" &>/dev/null; then
    echo "Error: Remote '$REMOTE' does not exist" >&2
    exit 1
fi

# 方法1: symbolic-ref を使用（最も確実）
DEFAULT_BRANCH=""
if git symbolic-ref "refs/remotes/$REMOTE/HEAD" &>/dev/null; then
    DEFAULT_BRANCH=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" | sed "s|refs/remotes/$REMOTE/||")
fi

# 方法2: symbolic-ref が失敗した場合は remote show を使用
if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH=$(git remote show "$REMOTE" | grep "HEAD branch" | sed 's/.*: //')
fi

# 方法3: 一般的なブランチ名をチェック
if [ -z "$DEFAULT_BRANCH" ]; then
    for branch in main master develop; do
        if git ls-remote --heads "$REMOTE" "$branch" | grep -q "$branch"; then
            DEFAULT_BRANCH="$branch"
            break
        fi
    done
fi

# 検出できなかった場合はエラー
if [ -z "$DEFAULT_BRANCH" ]; then
    echo "Error: Could not detect default branch for remote '$REMOTE'" >&2
    exit 1
fi

echo "$DEFAULT_BRANCH"
