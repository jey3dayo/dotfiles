# ドキュメント修正パターン集

よくあるドキュメント問題の修正パターン。

### Note

## リンク修正パターン

### パターン1: 壊れた相対リンク

### 問題

```markdown
[Configuration](../config.md)
```

`../config.md` が存在しない

### 修正

```markdown
[Configuration](../configuration/options.md)
```

### パターン2: 壊れたアンカーリンク

### 問題

```markdown
[Setup](#installation)
```

`#installation` が存在しない

### 修正

```markdown
[Setup](#getting-started)
```

## 構造修正パターン

### パターン3: 不一致な見出しレベル

### 問題

```markdown
# Title

### Skipped H2
```

### 修正

```markdown
# Title

## Proper H2

### Now H3
```

### パターン4: 重複セクション

### 問題

```markdown
## Installation

...

## Installation (重複)
```

### 修正

## コンテンツ修正パターン

### パターン5: 古い情報

### 問題

### 検出

### 修正

### パターン6: 不完全な例

### 問題

```markdown
\`\`\`javascript
const client = new Client();
\`\`\`
```

### 修正

```markdown
\`\`\`javascript
import { Client } from './client';

const client = new Client({
apiKey: process.env.API_KEY
});
\`\`\`
```

## フォーマット修正パターン

### パターン7: 不統一なコードブロック言語

### 問題

````markdown
```
npm install
```
````

### 修正

````markdown
```bash
npm install
```
````

### パターン8: テーブルフォーマット

### 問題

### 修正

## 一貫性修正パターン

### パターン9: 用語の不統一

### 問題

### 修正

### パターン10: トーンの不一致

### 問題

### 修正

詳細な技術仕様は [references/link-validation.md](../references/link-validation.md) を参照。
