# Chrome デバッグ トラブルシューティング

## WSL2 / Chrome 接続

### Chrome が「データディレクトリにアクセスできない」

**原因:** `--user-data-dir` に WSL パスを指定している

**解決:** Windows パス(`C:\...`)に変更

```bash
# 正しい
--user-data-dir="C:\\Users\\<USERNAME>\\AppData\\Local\\Temp\\chrome-mcp-debug"

# 不正
--user-data-dir="$HOME/.chrome-debug-profile"
```

### `wget http://localhost:9222` が接続できない

**原因:** WSL2 のポートフォワーディングが効いていない

**解決:** Windows ホスト IP(デフォルトゲートウェイ)を使う

```bash
WIN_HOST_IP=$(ip route show default | grep -oP '(?<=via )\d+(\.\d+){3}')
wget -qO- "http://${WIN_HOST_IP}:9222/json/version"

# Windows 側でポート確認
powershell.exe -Command "Test-NetConnection -ComputerName localhost -Port 9222"
```

### MCP Chrome DevTools がタイムアウト

**原因:** WSL2 自身の IP(`eth0`)を使っている。Chrome は Windows 側で動作している

**解決:** Windows ホスト IP で MCP を再登録し、Claude Code を再起動

```bash
WIN_HOST_IP=$(ip route show default | grep -oP '(?<=via )\d+(\.\d+){3}')
claude mcp add --transport stdio chrome-devtools -- \
  npx -y chrome-devtools-mcp@latest --browserUrl "http://${WIN_HOST_IP}:9222"
```

## agent-browser

### agent-browser がインストールされていない

```bash
npm install -g agent-browser
```

### snapshot で要素が見つからない

**原因:** ページがまだ読み込み中、または JavaScript が実行されていない

**解決:**

```bash
agent-browser wait --load networkidle
agent-browser wait 3000  # 追加の待機
agent-browser snapshot -i
```

### ref が無効(stale ref エラー)

**原因:** ページ遷移や DOM の変更後に古い ref を使用

**解決:** 操作後は必ず `agent-browser snapshot -i` で ref を更新

### WSL2 で headed モードが表示されない

**原因:** X Server が設定されていない

**解決:** headless モード(デフォルト)を使用し、snapshot とスクリーンショットで確認

## 認証・セッション

### headless でのリダイレクトループ

**症状:** headless ブラウザ(未ログイン/セッションなし)で認証が必要なページに直接アクセスすると、認証ハンドシェイクが失敗してループすることがある

**確認:**

```bash
agent-browser get url  # URL が変わり続けていないか
```

**対処:**

- 実ブラウザで問題がなければ、headless 固有の問題として無視可能
- agent-browser のセッション保存(`state save/load`)を活用してログイン状態を維持

### セッションが保持されない

**原因:** Cookie やローカルストレージが失われている

**対処:**

```bash
# セッション状態を保存してから再利用
agent-browser state save session.json
# 次回
agent-browser state load session.json
```

## MCP ツール選択の判断

| 症状                     | 推奨ツール          | 理由                             |
| ------------------------ | ------------------- | -------------------------------- |
| ページが表示されない     | agent-browser       | snapshot でDOMの有無を素早く確認 |
| JS エラーが疑われる      | MCP Chrome DevTools | console ログを直接取得可能       |
| リクエストが失敗している | MCP Chrome DevTools | network リクエスト一覧を取得可能 |
| Cookie/Storage の問題    | MCP Chrome DevTools | evaluate_script で直接確認可能   |
| 操作後の状態変化を確認   | agent-browser       | snapshot の差分で変化を検出      |
| 複合的な問題             | 両方を併用          | agent-browser で操作、MCP で診断 |
