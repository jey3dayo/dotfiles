# Git Layer - Version Control & Repository Management

このレイヤーでは、Git設定、ワークフロー最適化、他ツールとの統合に関する知見を体系化します。

## 🎯 責任範囲

- **Git設定**: core設定、alias、hooks、認証
- **ワークフロー**: ブランチ戦略、コミット規約、レビュープロセス
- **ツール統合**: ghq、fzf、1Password、GitHub CLI
- **セキュリティ**: SSH key管理、GPG署名、認証設定

## 📊 実装パターン

### Git設定の階層管理

```gitconfig
# ~/.gitconfig (global)
[include]
    path = ~/.config/git/work
    path = ~/.config/git/personal

# 条件付き設定
[includeIf "gitdir:~/work/"]
    path = ~/.config/git/work-config

[includeIf "gitdir:~/personal/"]
    path = ~/.config/git/personal-config
```

### エイリアス最適化パターン

```zsh
# 略語展開 (abbreviations)
abbr g="git"
abbr ga="git add"
abbr gc="git commit"
abbr gco="git checkout"
abbr gp="git push"
abbr gl="git pull"
abbr gs="git status"
abbr gd="git diff"
abbr gb="git branch"

# インタラクティブな選択
abbr gcb="git checkout \$(git branch | fzf)"
abbr gco="git checkout \$(git branch -a | fzf | sed 's/remotes\/origin\///')"
```

### FZF統合パターン

```zsh
# Git widget integration
bindkey '^g^g' git-status-widget
bindkey '^g^s' git-add-widget
bindkey '^g^a' git-branch-widget
bindkey '^g^b' git-checkout-widget

git-status-widget() {
    local result=$(git status --porcelain | fzf --preview 'git diff --color=always {2}')
    if [[ -n $result ]]; then
        LBUFFER+="git add ${result:3}"
    fi
    zle reset-prompt
}
```

## 🔧 認証・セキュリティ

### SSH設定パターン

#### 階層的Include構造
```
~/.ssh/config
├── ~/.config/ssh/ssh_config         # dotfiles管理基本設定
├── ~/.config/ssh/ssh_config.d/*     # dotfiles管理モジュール設定
├── ~/.ssh/ssh_config.d/*            # ローカル個別設定（Git管理外）
├── ~/.orbstack/ssh/config           # OrbStack自動生成
└── ~/.colima/ssh_config             # Colima設定（無効化）
```

#### 基本設定
```ssh
# ~/.ssh/config（Include指定のみ）
Include ~/.config/ssh/ssh_config
Include ~/.config/ssh/ssh_config.d
Include ~/.ssh/ssh_config.d/*

# GitHub設定
Host github.com
    HostName github.com
    User git
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    IdentitiesOnly yes

Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### 1Password統合

```zsh
# 1Password CLI integration
export SSH_AUTH_SOCK="~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# GPG signing with 1Password
git config --global user.signingkey "key-id"
git config --global commit.gpgsign true
```

## 📈 ワークフロー最適化

### 高速Git操作

```zsh
# 複合操作の自動化
gacp() {
    git add .
    git commit -m "$1"
    git push
}

# ブランチ作成とチェックアウト
gcb() {
    git checkout -b "$1"
    git push -u origin "$1"
}

# プルリクエスト作成
gpr() {
    git push -u origin $(git branch --show-current)
    gh pr create --fill
}
```

### Repository管理 (ghq)

```zsh
# Repository cloning pattern
clone() {
    ghq get "$1"
    cd "$(ghq root)/$(ghq list | grep "$1" | head -1)"
}

# FZF repository selector
bindkey '^]' ghq-fzf-widget

ghq-fzf-widget() {
    local selected=$(ghq list | fzf --preview 'ls -la $(ghq root)/{}')
    if [[ -n $selected ]]; then
        cd "$(ghq root)/$selected"
        zle reset-prompt
    fi
}
```

## 🔍 デバッグ・診断

### Git状態診断

```zsh
# Git健康チェック
git-health() {
    echo "=== Repository Status ==="
    git status --porcelain
    
    echo -e "\n=== Branch Information ==="
    git branch -vv
    
    echo -e "\n=== Remote Information ==="
    git remote -v
    
    echo -e "\n=== Recent Commits ==="
    git log --oneline -10
}

# 設定確認
git-config-check() {
    echo "=== User Configuration ==="
    git config user.name
    git config user.email
    git config user.signingkey
    
    echo -e "\n=== SSH Configuration ==="
    ssh -T git@github.com
}
```

## 🚧 最適化課題

### 高優先度
- [ ] Git操作のレスポンス時間向上
- [ ] 大規模リポジトリでのパフォーマンス最適化
- [ ] コミットメッセージテンプレートの改善

### 中優先度
- [ ] Git hooks の自動化拡張
- [ ] ブランチ保護設定の標準化
- [ ] CI/CD統合の改善

## 💡 知見・教訓

### 成功パターン
- **略語展開**: タイピング量50%削減、ワークフロー高速化
- **FZF統合**: ブランチ・ファイル選択の直感的操作
- **1Password統合**: セキュアな認証の自動化

### 失敗パターン
- **過度のエイリアス**: Git標準コマンドの記憶曖昧化
- **複雑なhooks**: 実行時間増加とエラー頻発
- **認証設定の複雑化**: トラブルシューティングの困難化

### セキュリティ教訓
- **SSH key管理**: 1Passwordによる一元管理で紛失リスク軽減
- **GPG署名**: コミット検証の重要性と設定の複雑さ
- **権限管理**: 最小権限の原則と利便性のバランス

### GitHub CLI統合知見
- **ワークフロー自動化**: PR作成・マージ操作の50%高速化
- **Issue-PR連携**: 一連のワークフローの自動化実現
- **認証統合**: 1Password + gh authで seamless authentication

### 運用実績
- **操作効率向上**: Zsh統合で50%時間短縮
- **視認性改善**: Delta導入で差分確認効率化
- **ワークフロー標準化**: GitHub Flow + 規約でチーム効率向上

## 🔗 関連層との連携

- **Shell Layer**: Zsh統合、widget定義
- **Tools Layer**: GitHub CLI、ghq、fzf統合
- **Security Layer**: SSH、GPG、認証管理

---

*最終更新: 2025-06-20*
*セキュリティ状態: 1Password統合完了*
*パフォーマンス状態: FZF統合最適化済み*