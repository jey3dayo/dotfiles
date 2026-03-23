# CI Diagnosis Flow

`pr-feedback-orchestrator` の `--ci` モードで使用する CI 診断の詳細フローです。

## 概要

GitHub Actions の CI 失敗を診断し、分類に基づいた修正計画を作成します。`gh-fix-ci` スキルと連携して CI ログの取得・解析を行います。

## 実行フロー

### Step 1: PR 情報取得

```bash
# 現在のブランチから PR を検出
gh pr list --head $(git branch --show-current) --json number,title,url

# または PR 番号指定
gh pr view 123 --json number,title,url,checks
```

### Step 2: CI チェック状況の取得

```bash
# 失敗しているチェックを取得
gh pr checks <pr-number> --json name,status,conclusion

# 失敗チェックのログを取得
gh run view <run-id> --log-failed
```

### Step 3: 失敗分類

| 分類         | パターン                                | 優先度 |
| ------------ | --------------------------------------- | ------ |
| Type Error   | `TSxxxx`, `type error`, `cannot assign` | High   |
| Lint Error   | `eslint`, `golint`, `formatting`        | Medium |
| Test Failure | `FAIL`, `AssertionError`, `Expected`    | High   |
| Build Error  | `build failed`, `compile error`         | High   |
| Timeout      | `timeout`, `exceeded time limit`        | Medium |

### Step 4: 修正計画

失敗分類に基づいて修正の優先順位を決定:

1. **Build Error** — ビルドが通らないと他の確認不可
2. **Type Error** — 型エラーはテスト失敗の原因になりうる
3. **Test Failure** — テスト修正
4. **Lint Error** — フォーマット・リント修正

### Step 5: 修正実行

`--dry-run` でない場合:

1. 各失敗カテゴリに対して修正を適用
2. `mise run ci:quick` で検証
3. 結果を報告

## gh-fix-ci スキルとの連携

`gh-fix-ci` スキルに委譲する処理:

- CI ログの取得と解析
- GitHub Actions ワークフローの理解
- 具体的なエラー箇所の特定
- 修正パッチの作成

## 出力例

```markdown
# CI 診断結果

## PR 情報

- PR #123: feature/new-api
- 失敗チェック: 3/5

## 失敗分類

### Build Error (1件)

- `tsc --noEmit` — 型エラー 3 件

### Test Failure (1件)

- `jest` — 2 テスト失敗

### Lint Error (1件)

- `eslint` — 5 件の lint 違反

## 修正計画

1. 型エラー修正 (src/api/users.ts:45, src/types/user.ts:12)
2. テスト修正 (tests/api/users.test.ts)
3. lint 修正 (5 ファイル)

推定所要時間: 15-20 分
```
