# Workflows & Maintenance Reference

最終更新: 2026-06-29
対象: 開発者
タグ: `category/maintenance`, `layer/tool`, `environment/cross-platform`, `audience/developer`

Claude Rules: [.claude/rules/workflows-and-maintenance.md](../../.claude/rules/workflows-and-maintenance.md)

## Maintenance Cadence

| 頻度   | 作業                                                                                                       |
| ------ | ---------------------------------------------------------------------------------------------------------- |
| 週次   | `brew update && brew upgrade` + `mise upgrade`; プラグイン更新（sheldon, nvim lazy, tmux）                 |
| 月次   | zsh ベンチマーク; ログ整理; `docs/performance.md` に記録; `mise prune`; `home-manager switch`; Nix cleanup |
| 四半期 | 全設定監査、依存関係プルーニング、バックアップ検証                                                         |

## Code Quality Checks

### 主要コマンド

```bash
mise run ci           # 検証のみ（format + lint + test）
mise run ci:quick     # クイックチェック（format + lint）
mise run format       # 自動フォーマット適用
mise run check        # format + lint（luacheck 含む）
mise run lint:lua     # luacheck のみ
mise run format:lua   # stylua でフォーマット
```

### 変更タイプ別の追加確認

通常の最終確認は `mise run ci` を基準にします。以下の領域を触った場合は、対象固有の確認も追加します。

| 変更領域            | 追加確認                                                                                           | 理由                                        |
| ------------------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| zsh startup         | `zsh-benchmark --runs 8 --mode interactive` と必要に応じて `ZSH_PROFILE_STARTUP=1 zsh -ic 'zprof'` | 同期初期化の再発を数値で見る                |
| dotenvx / `.env`    | `scripts/setup-env.sh` の構文確認、key-set comparison、`mise run ci:gitleaks`                      | plaintext cache と secret scan を分けて見る |
| launchd / GUI env   | `launchctl getenv <KEY>` で allowlist された key だけを確認                                        | shell ではなく GUI runtime の状態を見る     |
| Home Manager / Nix  | `mise run hm:check` または `nix flake check`                                                       | 適用前に build 可能性を確認する             |
| APM / global skills | `cd ~/.apm && mise run validate:catalog && mise run doctor`                                        | `.config` ではなく APM workspace が正本     |

### Lua Type Checking and Error Handling

#### Automated Type Checking

Lua 設定ファイル（Neovim、WezTerm）の型チェックは複数レイヤーで自動実行されます:

#### エディタ内（リアルタイム）

- LuaLS: LSP による型チェック（`.luarc.json` で設定）
- nvim-lint: 保存時・挿入モード終了時に自動実行（`luacheck`）

#### ローカル開発

```bash
mise run check         # format + lint（luacheck を含む）
mise run lint:lua      # luacheck のみ実行
mise run format:lua    # stylua でフォーマット
```

#### Lefthook（commit 前）

```bash
lefthook install     # 初回のみ
# 以降、git commit 時に自動実行（staged file の format / fast lint）
```

#### CI/CD（GitHub Actions）

- `mise run ci` で自動実行（format 検証 + luacheck + busted）

### Tools Configuration

| ツール   | 設定ファイル  | 用途                                   |
| -------- | ------------- | -------------------------------------- |
| LuaLS    | `.luarc.json` | LSP 型チェック、vim API サポート       |
| luacheck | `.luacheckrc` | 静的解析、未使用変数検出               |
| StyLua   | `stylua.toml` | フォーマット（120 文字幅、2 スペース） |

### Error Handling Patterns

実装済みの graceful degradation:

1. 安全なモジュール読み込み (`core/module_loader.lua:28-42`)
   - `pcall` による例外処理
   - 失敗キャッシュで重複エラー回避

2. 段階的フォールバック (`core/bootstrap.lua`)
   - オプショナルモジュール → サイレント失敗
   - 必須モジュール → 警告表示（非ブロッキング）

3. 非ブロッキング通知
   - `vim.schedule` で起動をブロックしない

### Lefthook Setup

```bash
mise install
cd ~/.config
lefthook install
lefthook run pre-commit
```

日常使用:

```bash
git commit -m "..."                          # staged ファイルのみ自動チェック
git push                                      # mise run ci で push 前に CI 相当を検証
lefthook run pre-commit                      # staged ファイル向け hook を手動実行
mise run format                              # 手動・全ファイル format
mise run check                               # 手動・全ファイル check
mise run lint:links                          # 重い Markdown link check
```

### Hook Management Strategy（Lefthook + mise tasks）

`lefthook.yml` と `mise/local-tasks/*.toml` は役割を分けて管理します:

#### 理由

- Lefthook: Git hook の入口。commit は軽量、push は CI 相当の gate に分ける
- mise tasks: 全ファイル一括処理（手動/CI 実行）

#### pre-push の gate

`pre-push` hook は `mise run ci` を実行します。GitHub Actions の通常 CI と同じ `format / lint / test / gitleaks` を push 前に検証し、remote CI が基本的な品質 gate で止まる確率を下げます。

`mise run pre-push` は対象ファイルに応じて追加テストを絞る旧/手動用の軽量 gate として残しています。

- `bin/*`, `scripts/*`, `zsh/*`, `mise/lib/*`, `mise/local-tasks/*`, `.mise.toml`: `mise run test:ts`
- `*.lua`, `spec/*`, `nvim/spec/*`, `nvim/lua/*`: `mise run test:lua`

#### 統合済みツール一覧

| カテゴリ   | ツール                 | Lefthook commit | mise tasks | 備考             |
| ---------- | ---------------------- | --------------- | ---------- | ---------------- |
| Lua        | stylua, luacheck       | ✅              | ✅         | 完全統合         |
| Shell      | shfmt                  | ✅              | ✅         | .sh files        |
| Zsh        | beautysh, zsh -n       | ✅              | ✅         | .zsh files       |
| YAML       | yamllint, prettier     | ✅              | ✅         | lint → format 順 |
| Markdown   | markdownlint, prettier | ✅              | ✅         | lint → format 順 |
| Python     | ruff (format/check)    | ✅              | ✅         | 完全統合         |
| TOML       | taplo                  | ✅              | ✅         | 完全統合         |
| JS/TS      | biome                  | ✅              | ✅         | 完全統合         |
| Dockerfile | hadolint               | ✅              | ✅         | 完全統合         |
| Secrets    | gitleaks               | ✅              | ✅         | `ci:gitleaks`    |
| Links      | markdown-link-check    | 手動            | ✅         | 重いため手動実行 |

#### メンテナンス時の注意

ツールの引数や設定を変更する際は、入口・tool 定義・全体 gate の役割を確認してください:

| 変更内容         | 更新が必要なファイル                                         |
| ---------------- | ------------------------------------------------------------ |
| hook 対象の増減  | `lefthook.yml`                                               |
| luacheck の引数  | `lefthook.yml` + `mise/local-tasks/lint.toml`                |
| stylua の引数    | `lefthook.yml` + `mise/local-tasks/format.toml`              |
| prettier の引数  | `lefthook.yml` + `mise/local-tasks/format.toml`              |
| beautysh の引数  | `lefthook.yml` + `mise/local-tasks/format.toml`              |
| hadolint の引数  | `lefthook.yml` + `mise/local-tasks/lint.toml`                |
| 除外パス         | `lefthook.yml` + `mise/local-tasks/env.toml` (TASK_EXCLUDES) |
| 新しいツール追加 | `lefthook.yml` + 該当する mise タスク                        |

**チェックリスト**（ツール設定変更時）:

```bash
# 1. 関連ファイルを更新

# 2. Lefthook 定義を確認
lefthook validate
lefthook run pre-commit

# 3. mise tasks で動作確認
mise run check

# 4. 結果が一致することを確認
```

#### Troubleshooting

```bash
# luacheck が見つからない場合
mise run ci:install    # luacheck と busted をインストール

# エディタ内で lint が動作しない
:LintInfo              # nvim-lint の状態確認
:Lint                  # 手動 lint 実行

# Lefthook エラー
lefthook run pre-commit

# hooks をスキップして commit（緊急時のみ）
git commit --no-verify -m "..."
```

## Brewfile Management

### 責務分離

- Home Manager: 設定配布のみ（ツールインストールなし）
- mise: クロスプラットフォーム CLI、言語ランタイム、開発ツール
- Homebrew: macOS 固有の依存関係、GUI アプリ、システムライブラリ

厳選管理の原則: フォーマッター・Linter・CLI ツールは mise で管理（biome, prettier, stylua 等は Brewfile に追加しない）

### Special Settings

| パッケージ | 設定                        | 理由                                                                |
| ---------- | --------------------------- | ------------------------------------------------------------------- |
| `mise`     | Homebrew formula            | 初回セットアップのブートストラップ用（実運用のツール管理は `mise`） |
| `mysql`    | `restart_service: :changed` | サービス自動再起動                                                  |
| `utf8proc` | `args: ["HEAD"]`            | Julia 依存のため HEAD が必要                                        |
| `node`     | `link: false`               | mise で管理（PATH 衝突回避）                                        |

### Package Addition Workflow

1. 追加先を判定:
   - まず mise で管理できるか確認: `mise registry` で検索
   - 言語ランタイム・クロスプラットフォーム CLI → `mise/config.*.toml` に追加
   - GUI・macOS 固有依存・macOS サービス → `Brewfile` に追加

2. Brewfile 対象ならインストール:

   ```bash
   brew install <package>
   ```

3. Brewfile 更新（候補抽出）:

   ```bash
   # 現在の状態をダンプ
   brew bundle dump --force --file=/tmp/brewfile-new.txt

   # 差分確認（必要なものだけ手動で反映）
   diff Brewfile /tmp/brewfile-new.txt
   ```

4. 適切なセクションに追加:
   - 機能・用途に応じたセクションを選択
   - アルファベット順に挿入（セクション内）
   - 必要に応じてコメント追加

5. 動作確認:

   ```bash
   brew bundle check
   brew bundle install --no-upgrade
   ```

### Monthly Audit

```bash
# 1. バックアップ作成
cp Brewfile Brewfile.backup.$(date +%Y%m%d)

# 2. 現在の状態を完全ダンプ
brew bundle dump --force --file=/tmp/brewfile-complete.txt

# 3. 差分確認（追加候補を確認）
diff Brewfile /tmp/brewfile-complete.txt

# 4. 方針に合うものだけを手動で反映
# - ランタイム・汎用 CLI は mise へ
# - GUI・macOS 固有のみ Brewfile へ

# 5. 構文チェック
brew bundle check

# 6. テスト
brew bundle install --no-upgrade --verbose
```

### Section Structure

Brewfile は 20 セクションで構成されています:

| セクション | 説明                              | 例                                   |
| ---------- | --------------------------------- | ------------------------------------ |
| `tap`      | Homebrew 外部リポジトリ           | `aws/tap`, `hashicorp/tap`           |
| `brew`     | macOS 固有依存・macOS サービス用  | `mysql`, `docker`, `openssl`         |
| `cask`     | GUI アプリ                        | `wezterm@nightly`, `raycast`         |
| `mas`      | Mac App Store アプリ              | `Xcode`, `TestFlight`                |
| `vscode`   | VS Code 拡張                      | `github.copilot`, `ms-python.python` |
| `go`       | Homebrew 管理下で入れる Go ツール | `golangci-lint`, `wire`              |

### Troubleshooting

#### Package installation errors

```bash
# 依存関係の問題
brew doctor
brew update
brew upgrade

# 特定パッケージの再インストール
brew reinstall <package>

# Cask の問題
brew reinstall --cask <cask>
```

#### Brewfile syntax errors

```bash
# 構文チェック
brew bundle check

# Brewfile の検証
brew bundle install --no-upgrade --dry-run
```

#### Cleanup old tools

```bash
# Brewfile に含まれないパッケージをリスト
brew bundle cleanup --force

# 未使用の依存関係削除
brew autoremove

# キャッシュクリア
brew cleanup
```

### Best Practices

1. 定期的な更新: 月次で Brewfile と実際のインストール状況を同期
2. バージョン管理: Brewfile を Git 管理し、変更履歴を追跡
3. コメント追加: 特殊な設定や重要なパッケージにはコメントを付与
4. テスト: 変更後は必ず `brew bundle check` で検証
5. バックアップ: 大きな変更前にはバックアップを作成

### Duplicate Check

定期的に mise で管理しているパッケージが他のパッケージマネージャーに残っていないか確認:

- `npm -g list --depth=0` - npm グローバルはローカルリンク（astro-my-profile, zx-scripts）のみであること
- `bun pm ls -g` または `ls ~/.bun/install/global/node_modules/.bin` - bun グローバルは空であること
- 重複検出スクリプトの実行（`docs/tools/mise.md` のツール管理方針を参照）

## mise Management

- Primary config: `mise/config.toml`（6 カテゴリ構造: Runtimes, Package Managers, Formatters/Linters, NPM, Cargo, CLI Tools）
- Weekly updates: `mise upgrade` to update all tools
- Monthly cleanup: `mise prune` to remove unused versions
- Verification: `mise doctor` for health check, `mise ls` for installed tools
- 重複回避: 新しいツールを追加する前に `brew list` で Homebrew に同じツールがないか確認
- npm パッケージの完全移行完了: 全ての開発ツール・MCP サーバー・Language Server は mise で一元管理（npm/pnpm/bun グローバルには依存しない）

## Nix Home Manager Maintenance

### Monthly cleanup

#### 定期実行（月次メンテナンス時）

```bash
# 1. 古い generations を削除（90 日または 20 世代を保持）
echo "=== Removing old Home Manager generations ==="
home-manager remove-generations 90d

# 2. 参照されていない store パスを削除
echo "=== Running garbage collection ==="
nix-collect-garbage -d

# 3. ディスク使用量を確認
echo "=== Disk usage after cleanup ==="
df -h /nix/store
```

保持ポリシー: 90 日または 20 世代（いずれか先に到達した方）を保持

### Disk usage monitoring

定期的に `/nix/store` のディスク使用量を確認:

| 使用率 | 状態 | アクション                                |
| ------ | ---- | ----------------------------------------- |
| < 50%  | 正常 | 定期メンテナンスのみ                      |
| 50-70% | 注意 | 早めに GC 実行を検討                      |
| 70-85% | 警告 | 即座に GC 実行、不要な generations を削除 |
| > 85%  | 危険 | アグレッシブなクリーンアップ実施          |

詳細は [docs/tools/nix.md](nix.md) を参照。

## Tool Management Philosophy

### mise 優先原則

#### 原則

開発ツール・フォーマッター・Linter は mise で統一管理。Homebrew はシステム依存関係と GUI アプリのみ。

#### mise で管理

- 全ての開発ツール（フォーマッター、Linter、CLI ツール）
- 全ての npm/pipx パッケージ
- 開発用の言語ランタイム（Node.js, Python, Go）

#### Homebrew で管理

- Neovim とその依存関係（lua, luajit, luarocks, libuv 等）
- システムレベルのライブラリ
- GUI アプリケーション（cask）
- システムツール用の言語ランタイム（必要な場合のみ）

#### ハイブリッド運用

- Node.js: Homebrew 版（システム依存関係用）+ mise 版（開発用）
- Python: Homebrew 版（システムツール用）+ mise 版（開発用）

#### 理由

Single Source of Truth、バージョン固定、プロジェクト別オーバーライド、再現性

## Troubleshooting Routing

| 症状               | 対応先                                                        |
| ------------------ | ------------------------------------------------------------- |
| パフォーマンス低下 | `docs/performance.md`                                         |
| Zsh 起動トラブル   | `rm -rf ~/.zcompdump*` → `exec zsh`; `zsh -df` でミニマル起動 |
| LSP 問題           | `:LspInfo`, `:Mason`, `~/.local/share/nvim/lsp.log`           |
| Git 認証           | `ssh -T git@github.com`, 1Password CLI と SSH agent 確認      |

## Debug Commands

```bash
env | grep -E "(SHELL|TERM|PATH|CONFIG)"   # 環境変数確認
tail -f ~/.local/share/nvim/lsp.log        # LSP ログ
tail -f ~/.config/zsh/performance.log      # パフォーマンスログ
top -pid $(pgrep zsh)                      # プロセス監視
ps aux | grep -E "(zsh|nvim|tmux)"
```

## Backups and Recovery

- Brewfile 変更前: `cp Brewfile Brewfile.backup.$(date +%Y%m%d)`
- 緊急シェル復旧: `zsh --no-rcs` → `brew bundle --force` → `mise install ...` → `home-manager switch --flake ~/.config --impure`
- Home Manager ロールバック: `home-manager generations` → `home-manager switch --generation <number>`
- 詳細: `docs/disaster-recovery.md`
