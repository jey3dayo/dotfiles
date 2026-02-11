# Chrome デバッグ トラブルシューティング

## WSL2 / Chrome 接続

### Chrome が「データディレクトリにアクセスできない」

### 原因:

### 解決:

```bash
# 正しい
--user-data-dir="C:\\Users\\<USERNAME>\\AppData\\Local\\Temp\\chrome-mcp-debug"

# 不正
--user-data-dir="$HOME/.chrome-debug-profile"
```

### `wget http://localhost:9222` が接続できない

### 原因:

### 解決:

```bash
WIN_HOST_IP=$(ip route show default | grep -oP '(?<=via )\d+(\.\d+){3}')
wget -qO- "http://${WIN_HOST_IP}:9222/json/version"

# Windows 側でポート確認
powershell.exe -Command "Test-NetConnection -ComputerName localhost -Port 9222"
```

### MCP Chrome DevTools がタイムアウト

### 原因:

### 解決:

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

### 原因:

### 解決:

```bash
agent-browser wait --load networkidle
agent-browser wait 3000  # 追加の待機
agent-browser snapshot -i
```

### ref が無効(stale ref エラー)

### 原因:

### 解決:

### WSL2 で headed モードが表示されない

### 原因:

### 解決:

## 認証・セッション

### headless でのリダイレクトループ

### 症状:

### 確認:

```bash
agent-browser get url  # URL が変わり続けていないか
```

### 対処:

- 実ブラウザで問題がなければ、headless 固有の問題として無視可能
- agent-browser のセッション保存(`state save/load`)を活用してログイン状態を維持

### セッションが保持されない

### 原因:

### 対処:

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
