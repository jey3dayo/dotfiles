# agent-browser 診断パターン

## 基本ワークフロー

```bash
# 1. ページを開く
agent-browser open <TARGET_URL>

# 2. スナップショットで状態確認(インタラクティブ要素付き)
agent-browser snapshot -i

# 3. 要素を操作
agent-browser fill @e1 "text"
agent-browser click @e2

# 4. 操作後は再スナップショット(ref が無効化されるため)
agent-browser snapshot -i
```

### 重要:

## 診断パターン

### ページレンダリング問題の診断

```bash
# ページを開いて状態確認
agent-browser open <TARGET_URL>
agent-browser snapshot -i

# ページテキストを取得(「rendering...」「読み込み中」等が含まれるか)
agent-browser get text body

# スクリーンショットを保存
agent-browser screenshot <SCREENSHOT_DIR>/page.png
```

### ログインフローの自動化

```bash
# サインインページを開く
agent-browser open <SIGN_IN_URL>
agent-browser snapshot -i

# メールアドレスを入力
agent-browser fill @e<email-ref> "<EMAIL>"
agent-browser click @e<submit-ref>
agent-browser wait 2000
agent-browser snapshot -i

# パスワードを入力(表示された場合)
agent-browser fill @e<password-ref> "<PASSWORD>"
agent-browser click @e<submit-ref>
agent-browser wait --load networkidle

# OTP が必要な場合
agent-browser snapshot -i
agent-browser fill @e<otp-ref> "<OTP>"
agent-browser click @e<submit-ref>
agent-browser wait --url "**/<EXPECTED_PATH>"

# ログイン成功の確認
agent-browser snapshot -i
agent-browser screenshot <SCREENSHOT_DIR>/login-success.png
```

### セッション保存と再利用

```bash
# ログイン後にセッションを保存
agent-browser state save auth-session.json

# 次回以降はセッションをロードしてスキップ
agent-browser state load auth-session.json
agent-browser open <TARGET_URL>
```

### UI 操作の検証

```bash
# ページを開いて待機
agent-browser open <TARGET_URL>
agent-browser wait --load networkidle
agent-browser snapshot -i

# 操作対象をクリック
agent-browser click @e<N>  # snapshot で特定した ref
agent-browser wait 1000
agent-browser snapshot -i

# 結果テキストを確認
agent-browser get text @e<result-ref>
```

## 情報取得コマンド

agent-browser では JavaScript を直接実行できないが、以下で同等の情報を収集可能:

```bash
# ページテキスト
agent-browser get text body

# 現在の URL(リダイレクトループの検出)
agent-browser get url

# ページタイトル
agent-browser get title
```

ネットワーク状態は間接的に確認:

```bash
# ページロード完了を待つ
agent-browser wait --load networkidle

# タイムアウトした場合 → MCP Chrome DevTools の list_network_requests で詳細確認
```

## スクリーンショット保存ルール(WSL2)

WSL2 環境でユーザーにスクリーンショットを見せる場合:

```bash
# 保存先: ~/user_home/Downloads は Windows の Downloads フォルダへのシンボリックリンク
DEBUG_DIR=~/user_home/Downloads/debug/$(date +%Y%m%d%H%M)
mkdir -p "$DEBUG_DIR"

# 通常のスクリーンショット
agent-browser screenshot "$DEBUG_DIR/page.png"

# フルページスクリーンショット
agent-browser screenshot --full "$DEBUG_DIR/page-full.png"
```

### 重要:

## headed モード(ビジュアルデバッグ)

```bash
# ブラウザを表示して操作を確認
agent-browser --headed open <TARGET_URL>

# 特定の要素をハイライト
agent-browser highlight @e1

# 操作を録画
agent-browser record start debug-session.webm
# ... 操作 ...
agent-browser record stop
```

### 注意:
