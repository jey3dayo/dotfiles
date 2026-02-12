# Domain Detection Logic

## Overview

プロジェクトのドメイン（Web開発、モバイルアプリ、データシステム等）を自動判定するロジック。

## Detection Patterns

### Web Development

**キーワード**:

- フロントエンド: `react`, `vue`, `angular`, `svelte`
- バックエンド: `node.js`, `express`, `django`, `flask`, `rails`, `spring`
- API: `api`, `rest`, `graphql`, `http`
- 一般: `web`, `frontend`, `backend`, `fullstack`

**例**:

- "Next.js + PostgreSQLでブログプラットフォームを構築" → `web-development`
- "RESTful APIを使ったECサイト" → `web-development`

### Mobile Apps

**キーワード**:

- iOS: `ios`, `swift`, `swiftui`, `uikit`
- Android: `android`, `kotlin`, `jetpack`
- クロスプラットフォーム: `react-native`, `flutter`, `xamarin`
- 一般: `mobile`, `app`

**例**:

- "SwiftUIでiOSアプリを開発" → `mobile-apps`
- "FlutterでクロスプラットフォームアプリをQ開発" → `mobile-apps`

### Data Systems

**キーワード**:

- ビッグデータ: `spark`, `hadoop`, `flink`, `kafka`
- パイプライン: `etl`, `pipeline`, `warehouse`, `lakehouse`
- データプラットフォーム: `bigquery`, `redshift`, `snowflake`
- 一般: `data-engineering`, `analytics`

**例**:

- "Sparkを使ったETLパイプライン構築" → `data-systems`
- "BigQueryでデータウェアハウスを設計" → `data-systems`

### Infrastructure

**キーワード**:

- コンテナ: `kubernetes`, `k8s`, `docker`, `container`
- IaC: `terraform`, `ansible`, `cloudformation`
- クラウド: `aws`, `gcp`, `azure`, `cloud`
- 一般: `devops`, `infrastructure`, `deployment`

**例**:

- "TerraformでAWSインフラを構築" → `infrastructure`
- "Kubernetesクラスタの設計" → `infrastructure`

### Security

**キーワード**:

- セキュリティ: `security`, `encryption`, `authentication`
- 認証: `oauth`, `jwt`, `iam`, `rbac`
- 脆弱性: `penetration`, `vulnerability`, `compliance`

**例**:

- "OAuth2.0を使った認証基盤" → `security`
- "脆弱性診断システムの構築" → `security`

## Scoring Algorithm

各ドメインに対してパターンマッチングを実施し、スコアを計算：

```python
def detect_domain(text: str) -> str:
    text_lower = text.lower()
    scores = {}

    for domain, patterns in DOMAIN_PATTERNS.items():
        score = sum(1 for pattern in patterns if re.search(pattern, text_lower))
        scores[domain] = score

    # スコアが最も高いドメインを返す（同点の場合はweb-developmentを優先）
    if max(scores.values()) == 0:
        return "web-development"
    return max(scores, key=scores.get)
```

## Fallback Strategy

- **複数ドメインに該当**: スコアが最も高いドメインを選択
- **どのドメインにも該当しない**: デフォルトで`web-development`を返す
  - 理由: Web開発が最も一般的なユースケース

## Multi-Domain Projects

プロジェクトが複数のドメインにまたがる場合（例: Web + インフラ）、スコアの高い方を優先します。

**例**:

- "Next.jsアプリをKubernetesにデプロイ"
  - Web: 2ポイント（next.js、アプリ）
  - Infrastructure: 1ポイント（kubernetes）
  - → `web-development`

必要に応じて、ユーザーに複数ドメインの質問を提示することも可能（将来の拡張）。

## Extension

新しいドメインを追加する場合:

1. `DOMAIN_PATTERNS`に新しいドメインのパターンを追加
2. 対応する質問ファイル（`references/questions/{domain}.yaml`）を作成
3. テストケースを追加

```python
DOMAIN_PATTERNS = {
    # ...既存のドメイン
    "machine-learning": [
        r"\b(tensorflow|pytorch|scikit[-\s]learn)\b",
        r"\b(neural[-\s]network|deep[-\s]learning|ml)\b",
    ],
}
```
