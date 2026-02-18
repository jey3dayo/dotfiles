---
paths: docs/performance.md, .github/workflows/**/*.yml, .github/PULL_REQUEST_TEMPLATE.md, .claude/commands/**/*.sh, .mise.toml, mise/config.toml, Brewfile, Brewfile.lock.json
---

# Workflows and Maintenance

Purpose: keep recurring operations and troubleshooting guardrails concise. Scope: maintenance cadences, Brewfile management, and where to log performance findings.
Sources: docs/performance.md (for performance tracking).

## Cadence

- Weekly: `brew update && brew upgrade` + `mise upgrade`; refresh plugins (`sheldon update`, `nvim --headless -c 'lua require("lazy").sync()' -c q`, tmux plugin updater).
- Monthly: run zsh benchmarks and review config for unused items; clean logs; record metrics in docs/performance.md; `mise prune` to remove unused versions; run `home-manager switch --flake ~/.config --impure` to apply any dotfiles updates; **Nix cleanup** (see [Nix Home Manager Maintenance](#nix-home-manager-maintenance)).
- Quarterly: full settings audit, dependency pruning, and backup verification.

## Code Quality Checks

### Lua Type Checking and Error Handling

#### Automated Type Checking

Lua設定ファイル（Neovim、WezTerm）の型チェックは複数レイヤーで自動実行されます:

#### エディタ内（リアルタイム）

- LuaLS: LSPによる型チェック（`.luarc.json`で設定）
- nvim-lint: 保存時・挿入モード終了時に自動実行（`luacheck`）

#### ローカル開発

```bash
mise run check         # format + lint（luacheckを含む）
mise run lint:lua      # luacheckのみ実行
mise run format:lua    # styluaでフォーマット
```

#### pre-commit（commit前）

```bash
pre-commit install     # 初回のみ
# 以降、git commit時に自動実行（stylua + luacheck）
```

#### CI/CD（GitHub Actions）

- `mise run ci`で自動実行（format検証 + luacheck + busted）

#### Tools Configuration

| ツール   | 設定ファイル  | 用途                                 |
| -------- | ------------- | ------------------------------------ |
| LuaLS    | `.luarc.json` | LSP型チェック、vim APIサポート       |
| luacheck | `.luacheckrc` | 静的解析、未使用変数検出             |
| StyLua   | `stylua.toml` | フォーマット（120文字幅、2スペース） |

#### Error Handling Patterns

実装済みのgraceful degradation:

1. **安全なモジュール読み込み** (`core/module_loader.lua:28-42`)
   - `pcall`による例外処理
   - 失敗キャッシュで重複エラー回避

2. **段階的フォールバック** (`core/bootstrap.lua`)
   - オプショナルモジュール → サイレント失敗
   - 必須モジュール → 警告表示（非ブロッキング）

3. 非ブロッキング通知
   - `vim.schedule`で起動をブロックしない

#### Pre-commit Setup

```bash
# 初回インストール（pipx経由で推奨）
mise use -g pipx:pre-commit

# フックを有効化
cd ~/.config
pre-commit install

# 動作確認（全ファイルに対してテスト実行）
pre-commit run --all-files
```

#### 使い方

```bash
# 通常のcommit（stagedファイルのみ自動チェック）
git commit -m "..."

# 手動で全ファイルチェック
pre-commit run --all-files

# 特定のフックのみ実行
pre-commit run stylua --all-files

# manual stageのフックを実行（markdown-link-check）
pre-commit run --hook-stage manual markdown-link-check --all-files
```

#### Dual Management Strategy

`.pre-commit-config.yaml`と`mise/tasks/*.toml`は**意図的に二重管理**しています：

#### 理由

- pre-commit: 変更ファイルのみ高速チェック（commit時自動実行）
- mise tasks: 全ファイル一括処理（手動/CI実行）

#### 統合済みツール一覧

| カテゴリ   | ツール                 | pre-commit | mise tasks | 備考             |
| ---------- | ---------------------- | ---------- | ---------- | ---------------- |
| Lua        | stylua, luacheck       | ✅         | ✅         | 完全統合         |
| Shell      | shfmt, shellcheck      | ✅         | ✅         | .sh files        |
| Zsh        | beautysh, zsh -n       | ✅         | ✅         | .zsh files       |
| YAML       | yamllint, prettier     | ✅         | ✅         | lint → format順  |
| Markdown   | markdownlint, prettier | ✅         | ✅         | lint → format順  |
| Python     | ruff (format/check)    | ✅         | ✅         | 完全統合         |
| TOML       | taplo                  | ✅         | ✅         | 完全統合         |
| JS/TS      | biome                  | ✅         | ✅         | 完全統合         |
| Dockerfile | hadolint               | ✅         | ✅         | 完全統合         |
| Links      | markdown-link-check    | ✅ manual  | ✅         | 重いため手動実行 |

#### メンテナンス時の注意

ツールの引数や設定を変更する際は**両方**を更新してください：

| 変更内容         | 更新が必要なファイル                                                        |
| ---------------- | --------------------------------------------------------------------------- |
| luacheckの引数   | `.pre-commit-config.yaml` + `mise/tasks/lint.toml`                          |
| styluaの引数     | `.pre-commit-config.yaml` + `mise/tasks/format.toml`                        |
| prettierの引数   | `.pre-commit-config.yaml` + `mise/tasks/format.toml`                        |
| beautyshの引数   | `.pre-commit-config.yaml` + `mise/tasks/format.toml`                        |
| hadolintの引数   | `.pre-commit-config.yaml` + `mise/tasks/lint.toml`                          |
| 除外パス         | `.pre-commit-config.yaml` (exclude) + `mise/tasks/env.toml` (TASK_EXCLUDES) |
| 新しいツール追加 | `.pre-commit-config.yaml` + 該当するmiseタスク                              |

**チェックリスト**（ツール設定変更時）:

```bash
# 1. 両方のファイルを更新

# 2. pre-commitで動作確認
pre-commit run --all-files

# 3. mise tasksで動作確認
mise run check

# 4. 結果が一致することを確認
```

#### Troubleshooting

```bash
# luacheckが見つからない場合
mise run ci:install    # luacheckとbustedをインストール

# エディタ内でlintが動作しない
:LintInfo              # nvim-lintの状態確認
:Lint                  # 手動lint実行

# pre-commitエラー
pre-commit run --all-files  # 全ファイルに対して実行
pre-commit autoupdate       # フックの更新

# pre-commitをスキップしてcommit（緊急時のみ）
git commit --no-verify -m "..."
```

## Troubleshooting routing

- Performance regressions: follow docs/performance.md troubleshooting; log measurements there.
- Zsh recovery: `rm -rf ~/.zcompdump*` then `exec zsh`; use `zsh -df` for minimal startup.
- LSP issues: `:LspInfo`, `:Mason`, check `~/.local/share/nvim/lsp.log`; reinstall servers if needed.
- Git auth: `ssh -T git@github.com`, confirm 1Password CLI and SSH agent status.

## Debug commands

- Env checks: `env | grep -E "(SHELL|TERM|PATH|CONFIG)"`, `which`, `type`.
- Logs: `tail -f ~/.local/share/nvim/lsp.log`, `tail -f ~/.config/zsh/performance.log`.
- Process watch: `top -pid $(pgrep zsh)`, `ps aux | grep -E "(zsh|nvim|tmux)"`.

## Automation and scripts

- Maintenance script pattern: log zsh startup time, update plugins, clear temporary files, back up key configs (see sample in docs/maintenance.md).
- Keep backups under ~/.config/zsh/backup with dated filenames.

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

- Node.js: Homebrew 版（システム依存関係用） + mise 版（開発用）
- Python: Homebrew 版（システムツール用） + mise 版（開発用）

#### 理由

Single Source of Truth、バージョン固定、プロジェクト別オーバーライド、再現性

### Brewfile management

### Structure

Brewfile は責務分離に基づいた厳選管理を行います:

- Home Manager: 設定配布のみ（ツールインストールなし）
- mise: クロスプラットフォーム CLI、言語ランタイム、開発ツール
- Homebrew: macOS 固有の依存関係、GUI アプリ、システムライブラリ

#### 厳選管理の原則

- ローカル環境の全インストール状態をそのまま反映しない
- 各セクション・特殊設定に理由を明記するコメント付き
- フォーマッター・Linter・CLI ツールは mise で管理（biome, prettier, stylua, shfmt, shellcheck, yamllint, taplo, hadolint, fd, jq, gh 等は Brewfile に追加しない）

### Special settings

| パッケージ | 設定                        | 理由                                                                |
| ---------- | --------------------------- | ------------------------------------------------------------------- |
| `mise`     | Homebrew formula            | 初回セットアップのブートストラップ用（実運用のツール管理は `mise`） |
| `mysql`    | `restart_service: :changed` | サービス自動再起動                                                  |
| `utf8proc` | `args: ["HEAD"]`            | Julia 依存のため HEAD が必要                                        |
| `node`     | `link: false`               | mise で管理（PATH 衝突回避）                                        |

### mise integration

Brewfile 関連操作は mise タスクから実行できます:

```bash
# 現在のインストール状況を保存
mise run brewfile:backup

# Brewfile からパッケージをインストール
mise run brewfile:restore

# 全依存関係を更新
mise run update
```

### New Mac setup

1. Homebrew インストール:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. dotfiles クローン後、Brewfile から一括インストール:

   ```bash
   brew bundle install
   ```

3. mise でランタイム・CLI を導入:

   ```bash
   mise install
   ```

4. 以降は `mise run` コマンドが使用可能

### Package addition workflow

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

### Monthly audit (recommended)

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

### Section structure

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

### Best practices

1. 定期的な更新: 月次で Brewfile と実際のインストール状況を同期
2. バージョン管理: Brewfile を Git 管理し、変更履歴を追跡
3. コメント追加: 特殊な設定や重要なパッケージにはコメントを付与
4. テスト: 変更後は必ず `brew bundle check` で検証
5. バックアップ: 大きな変更前にはバックアップを作成

### Duplicate check

定期的に mise で管理しているパッケージが他のパッケージマネージャーに残っていないか確認:

- `npm -g list --depth=0` - npm グローバルはローカルリンク（astro-my-profile, zx-scripts）のみであること
- `bun pm ls -g` または `ls ~/.bun/install/global/node_modules/.bin` - bun グローバルは空であること
- 重複検出スクリプトの実行（`.claude/rules/tools/tool-install-policy.md` 参照）

### mise management

- Primary config: `mise/config.toml` (6 カテゴリ構造: Runtimes, Package Managers, Formatters/Linters, NPM, Cargo, CLI Tools)
- Weekly updates: `mise upgrade` to update all tools
- Monthly cleanup: `mise prune` to remove unused versions
- Verification: `mise doctor` for health check, `mise ls` for installed tools
- 重複回避: 新しいツールを追加する前に `brew list` で Homebrew に同じツールがないか確認
- npm パッケージの完全移行完了: 全ての開発ツール・MCP サーバー・Language Server は mise で一元管理（npm/pnpm/bun グローバルには依存しない）

## Nix Home Manager Maintenance

### Monthly cleanup

#### 定期実行 (月次メンテナンス時)

```bash
# 1. 古いgenerationsを削除（90日または20世代を保持）
echo "=== Removing old Home Manager generations ==="
home-manager remove-generations 90d

# 2. 参照されていないstoreパスを削除
echo "=== Running garbage collection ==="
nix-collect-garbage -d

# 3. ディスク使用量を確認
echo "=== Disk usage after cleanup ==="
df -h /nix/store
```

**保持ポリシー**: 90日または20世代（いずれか先に到達した方）を保持

### Disk usage monitoring

定期的に `/nix/store` のディスク使用量を確認：

| 使用率 | 状態 | アクション                            |
| ------ | ---- | ------------------------------------- |
| < 50%  | 正常 | 定期メンテナンスのみ                  |
| 50-70% | 注意 | 早めにGC実行を検討                    |
| 70-85% | 警告 | 即座にGC実行、不要なgenerationsを削除 |
| > 85%  | 危険 | アグレッシブなクリーンアップ実施      |

### 詳細ドキュメント

- 運用ポリシー詳細: `.claude/rules/nix-maintenance.md`
- ディザスタリカバリ手順: `docs/disaster-recovery.md`

## Backups and recovery

- For Brewfile changes, keep dated backups before large edits.
- Emergency shell recovery: `zsh --no-rcs` to bypass config; reinstall dependencies via `brew bundle --force`, `mise install ...`, and `home-manager switch --flake ~/.config --impure` when required.
- Home Manager rollback: `home-manager generations` to list, `home-manager switch --generation <number>` to rollback; see `docs/disaster-recovery.md` for detailed recovery scenarios.
