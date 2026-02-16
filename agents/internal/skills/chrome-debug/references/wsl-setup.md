# WSL2 Chrome リモートデバッグ セットアップ

## クイックスタート

```bash
# 1. Chrome をデバッグモードで起動
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
"/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" \
  --remote-debugging-port=9222 \
  --remote-debugging-address=0.0.0.0 \
  --user-data-dir="C:\\Users\\${WIN_USER}\\AppData\\Local\\Temp\\chrome-mcp-debug" \
  --disable-web-security \
  --disable-features=IsolateOrigins,site-per-process \
  <TARGET_URL>

# 2. 接続確認(Windows ホスト IP を使う)
WIN_HOST_IP=$(ip route show default | grep -oP '(?<=via )\d+(\.\d+){3}')
wget -qO- "http://${WIN_HOST_IP}:9222/json/version"
```

## WSL2 ネットワークの理解

WSL2 と Windows はネットワークが分離されている。Chrome は **Windows 側** で動作するため、
WSL2 から接続するには **Windows ホスト IP(デフォルトゲートウェイ)** を使う。

| IP                | 取得方法                                                     | 用途                                           |
| ----------------- | ------------------------------------------------------------ | ---------------------------------------------- |
| Windows ホスト IP | `ip route show default \| grep -oP '(?<=via )\d+(\.\d+){3}'` | **MCP 接続先(推奨)**                           |
| WSL2 自身の IP    | `ip addr show eth0 \| grep -oP '(?<=inet\s)\d+(\.\d+){3}'`   | WSL2 自身(Chrome はここにいない)               |
| `localhost`       | -                                                            | ポートフォワーディング経由(動作しない場合あり) |

```bash
# Windows ホスト IP の確認
WIN_HOST_IP=$(ip route show default | grep -oP '(?<=via )\d+(\.\d+){3}')
echo $WIN_HOST_IP
```

### よくある間違い

## `--user-data-dir` は Windows パスにする(必須)

WSL のパス(`/home/...`)を指定すると Chrome がデータディレクトリにアクセスできず起動に失敗する。

```bash
# 正しい
--user-data-dir="C:\\Users\\<USERNAME>\\AppData\\Local\\Temp\\chrome-mcp-debug"

# 不正(Chrome がアクセスできない)
--user-data-dir="$HOME/.chrome-debug-profile"
```

### 自動取得

```bash
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
USER_DATA_DIR="C:\\Users\\${WIN_USER}\\AppData\\Local\\Temp\\chrome-mcp-debug"
```

## Chrome 起動オプション一覧

| オプション                   | 目的                                      |
| ---------------------------- | ----------------------------------------- |
| `--remote-debugging-port`    | DevTools プロトコルのポート               |
| `--remote-debugging-address` | 外部からの接続を許可                      |
| `--user-data-dir`            | 通常の Chrome プロファイルと分離          |
| `--disable-web-security`     | CORS 制約を無効化(開発時のみ)             |
| `--disable-features=...`     | サイト分離を無効化(DevTools の安定性向上) |

## MCP Chrome DevTools の設定

```bash
# Windows ホスト IP を取得して MCP を設定
WIN_HOST_IP=$(ip route show default | grep -oP '(?<=via )\d+(\.\d+){3}')
claude mcp add --transport stdio chrome-devtools -- \
  npx -y chrome-devtools-mcp@latest --browserUrl "http://${WIN_HOST_IP}:9222"
```

設定後は Claude Code を再起動して MCP を有効化する。
