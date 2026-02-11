# DevTools 診断チェックリスト

## MCP Chrome DevTools ワークフロー

接続確認後、以下の順で診断する:

### 1. DOM 状態の確認

```
take_snapshot
```

- ページが正しくレンダリングされているか
- 「loading...」「rendering...」等の中間状態で止まっていないか
- 期待する要素が存在するか

### 2. Console エラーの確認

```
list_console_messages
```

- JavaScript エラー(赤)がないか
- 未処理の Promise rejection がないか
- CORS エラーがないか

### 3. Network リクエストの確認

```
list_network_requests
```

- 失敗しているリクエスト(4xx, 5xx)がないか
- リクエストが無限ループしていないか
- レスポンスタイムが異常に長いリクエストがないか

### 4. JavaScript 実行による詳細診断

```
evaluate_script
```

#### Cookie 診断スクリプト

```javascript
(() => {
  const cookies = document.cookie;
  const cookieObj = {};
  cookies.split("; ").forEach((c) => {
    const [key, ...val] = c.split("=");
    cookieObj[key] = val.join("=");
  });
  return {
    allCookies: cookieObj,
    cookieCount: Object.keys(cookieObj).length,
    timestamp: new Date().toISOString(),
  };
})();
```

#### タイムゾーン診断スクリプト

```javascript
(() => {
  const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
  const cookies = document.cookie;
  const tzCookie = cookies
    .split("; ")
    .find((row) => row.startsWith("<COOKIE_NAME>="))
    ?.split("=")[1];
  return {
    browserTimeZone: tz,
    tzCookie: tzCookie || "NOT_SET",
    match: tz === tzCookie,
  };
})();
```

#### ローカルストレージ診断

```javascript
(() => {
  const keys = Object.keys(localStorage);
  const data = {};
  keys.forEach((k) => (data[k] = localStorage.getItem(k)?.substring(0, 100)));
  return { keys, count: keys.length, preview: data };
})();
```

### 5. スクリーンショット

```
take_screenshot
```

- 視覚的な問題がないか
- レイアウト崩れがないか

## 手動 DevTools(F12)チェックリスト

MCP が使えない場合のフォールバック:

### Console タブ

- [ ] JavaScript エラー(赤)を確認
- [ ] Warning(黄)を確認
- [ ] ネットワークエラーを確認

### Network タブ

- [ ] 失敗リクエスト(赤)をフィルタ
- [ ] リクエストの無限ループをチェック
- [ ] レスポンスサイズ・タイムを確認
- [ ] リダイレクトチェーン(301/302)を確認

### Application タブ

- [ ] Cookies: 必要な Cookie が設定されているか
- [ ] LocalStorage: セッション情報が保持されているか
- [ ] Service Workers: 古いキャッシュが残っていないか

### Performance タブ(必要に応じて)

- [ ] First Contentful Paint (FCP) のタイミング
- [ ] Largest Contentful Paint (LCP) のタイミング
- [ ] 長時間タスク(Long Tasks)の有無
