# リンク検証

ドキュメント内リンクの整合性チェックと自動修正手法。

### Note

## リンク検証ルール

### 内部リンクの検証

```python
def validate_internal_links(doc_path, content):
    """ドキュメント内の内部リンクを検証"""

    links = extract_markdown_links(content)
    issues = []

    for link in links:
        # 相対パスリンクのみ検証
        if not is_external_link(link['url']):
            target_path = resolve_link_path(doc_path, link['url'])

            # ファイルの存在確認
            if not file_exists(target_path):
                issues.append({
                    "type": "broken_link",
                    "link": link['url'],
                    "text": link['text'],
                    "line": link['line'],
                    "target": target_path
                })

            # アンカーリンクの検証
            elif '#' in link['url']:
                anchor = link['url'].split('#')[1]
                if not anchor_exists(target_path, anchor):
                    issues.append({
                        "type": "broken_anchor",
                        "link": link['url'],
                        "text": link['text'],
                        "line": link['line'],
                        "anchor": anchor
                    })

    return issues
```

### 外部リンクの検証

```python
def validate_external_links(content):
    """外部URLの有効性を検証（オプション）"""

    links = extract_markdown_links(content)
    external_links = [l for l in links if is_external_link(l['url'])]

    issues = []

    for link in external_links:
        # HTTPステータスチェック（レート制限考慮）
        status = check_url_status(link['url'])

        if status >= 400:
            issues.append({
                "type": "unreachable_url",
                "link": link['url'],
                "text": link['text'],
                "line": link['line'],
                "status": status
            })

    return issues
```

## 自動修正戦略

### リンクパス修正

```python
def fix_broken_links(doc_path, issues):
    """壊れたリンクを自動修正"""

    content = read_file(doc_path)
    fixes = []

    for issue in issues:
        if issue['type'] == 'broken_link':
            # 類似ファイルを検索
            similar_files = find_similar_files(issue['target'])

            if similar_files:
                # 最も類似度が高いファイルを選択
                best_match = similar_files[0]
                new_link = calculate_relative_path(doc_path, best_match)

                # リンクを置換
                old_link = f"[{issue['text']}]({issue['link']})"
                new_link_text = f"[{issue['text']}]({new_link})"

                content = content.replace(old_link, new_link_text)

                fixes.append({
                    "type": "link_updated",
                    "old": issue['link'],
                    "new": new_link
                })

    if fixes:
        write_file(doc_path, content)

    return fixes
```

### アンカー修正

```python
def fix_broken_anchors(doc_path, issues):
    """壊れたアンカーリンクを修正"""

    content = read_file(doc_path)
    fixes = []

    for issue in issues:
        if issue['type'] == 'broken_anchor':
            target_file = issue['link'].split('#')[0]
            target_content = read_file(target_file)

            # 類似見出しを検索
            headings = extract_headings(target_content)
            similar = find_similar_heading(issue['anchor'], headings)

            if similar:
                # アンカーを更新
                old_link = f"[{issue['text']}]({issue['link']})"
                new_anchor = heading_to_anchor(similar)
                new_link = f"[{issue['text']}]({target_file}#{new_anchor})"

                content = content.replace(old_link, new_link)

                fixes.append({
                    "type": "anchor_updated",
                    "old": issue['anchor'],
                    "new": new_anchor
                })

    if fixes:
        write_file(doc_path, content)

    return fixes
```

## ファイル移動時のリンク更新

### リンク影響分析

```python
def analyze_link_impact(old_path, new_path):
    """ファイル移動時のリンク影響を分析"""

    # このファイルを参照しているドキュメントを検索
    referencing_docs = find_documents_linking_to(old_path)

    impact = {
        "affected_docs": len(referencing_docs),
        "updates_needed": []
    }

    for doc in referencing_docs:
        old_link = calculate_relative_path(doc, old_path)
        new_link = calculate_relative_path(doc, new_path)

        impact["updates_needed"].append({
            "doc": doc,
            "old_link": old_link,
            "new_link": new_link
        })

    return impact
```

### 自動リンク更新

```python
def update_links_after_move(old_path, new_path):
    """ファイル移動後にすべてのリンクを更新"""

    impact = analyze_link_impact(old_path, new_path)

    for update in impact["updates_needed"]:
        content = read_file(update["doc"])

        # すべての参照を更新
        updated = content.replace(
            f"]({update['old_link']})",
            f"]({update['new_link']})"
        )

        write_file(update["doc"], updated)

    return {
        "updated_docs": len(impact["updates_needed"]),
        "details": impact["updates_needed"]
    }
```

## リンク形式の標準化

### 相対パス正規化

```python
def normalize_relative_links(doc_path):
    """相対リンクを標準形式に正規化"""

    content = read_file(doc_path)
    links = extract_markdown_links(content)

    for link in links:
        if not is_external_link(link['url']):
            # 冗長なパス要素を削除 (../foo/../bar -> ../bar)
            normalized = normalize_path(link['url'])

            if normalized != link['url']:
                old_link = f"[{link['text']}]({link['url']})"
                new_link = f"[{link['text']}]({normalized})"
                content = content.replace(old_link, new_link)

    write_file(doc_path, content)
```

### リンクテキスト改善

```python
def improve_link_text(content):
    """リンクテキストをより説明的にする"""

    links = extract_markdown_links(content)

    for link in links:
        # "here", "click here" などの非説明的テキストを検出
        if is_generic_link_text(link['text']):
            # リンク先から適切なテキストを推測
            better_text = infer_link_text(link['url'])

            if better_text:
                old = f"[{link['text']}]({link['url']})"
                new = f"[{better_text}]({link['url']})"
                content = content.replace(old, new)

    return content
```

## クロスリファレンス管理

### 双方向リンク

```python
def ensure_bidirectional_links(doc_a, doc_b):
    """2つのドキュメント間で双方向リンクを確保"""

    content_a = read_file(doc_a)
    content_b = read_file(doc_b)

    # A → B のリンクが存在するか
    link_a_to_b = has_link_to(content_a, doc_b)

    # B → A のリンクが存在するか
    link_b_to_a = has_link_to(content_b, doc_a)

    # 必要に応じてリンクを追加
    if link_a_to_b and not link_b_to_a:
        # Bに"See also"セクションを追加
        content_b = add_related_link(content_b, doc_a)
        write_file(doc_b, content_b)

    elif link_b_to_a and not link_a_to_b:
        # Aに"See also"セクションを追加
        content_a = add_related_link(content_a, doc_b)
        write_file(doc_a, content_a)
```

### 関連ドキュメントリンク

```python
def suggest_related_links(doc_path):
    """関連ドキュメントへのリンクを提案"""

    content = read_file(doc_path)

    # ドキュメントのトピックを抽出
    topics = extract_topics(content)

    # 類似トピックのドキュメントを検索
    related_docs = find_docs_by_topics(topics, exclude=[doc_path])

    suggestions = []

    for related in related_docs:
        # すでにリンクされているか確認
        if not has_link_to(content, related['path']):
            suggestions.append({
                "doc": related['path'],
                "title": related['title'],
                "relevance": related['similarity']
            })

    return sorted(suggestions, key=lambda x: x['relevance'], reverse=True)
```

## リンク検証レポート

### 包括的レポート生成

```python
def generate_link_validation_report(project_root):
    """プロジェクト全体のリンク検証レポート"""

    all_docs = find_all_markdown_files(project_root)

    report = {
        "total_docs": len(all_docs),
        "total_links": 0,
        "broken_links": [],
        "broken_anchors": [],
        "external_issues": [],
        "suggestions": []
    }

    for doc in all_docs:
        content = read_file(doc)

        # リンク数をカウント
        links = extract_markdown_links(content)
        report["total_links"] += len(links)

        # 内部リンク検証
        internal_issues = validate_internal_links(doc, content)
        report["broken_links"].extend([
            {**issue, "doc": doc}
            for issue in internal_issues
            if issue["type"] == "broken_link"
        ])
        report["broken_anchors"].extend([
            {**issue, "doc": doc}
            for issue in internal_issues
            if issue["type"] == "broken_anchor"
        ])

        # 関連リンク提案
        suggestions = suggest_related_links(doc)
        if suggestions:
            report["suggestions"].append({
                "doc": doc,
                "related": suggestions[:3]  # 上位3つ
            })

    return report
```

### レポート出力形式

```markdown
# Link Validation Report

## Summary

- Total documents: 45
- Total links: 328
- Broken links: 3
- Broken anchors: 1
- Unreachable URLs: 0

## Issues

### Broken Links (3)

1. **docs/api.md:45**
   - Link: `[Configuration](../config.md)`
   - Target: `../config.md` (not found)
   - Suggestion: Use `../configuration/options.md`

2. **README.md:12**
   - Link: `[Guide](docs/guide.md)`
   - Target: `docs/guide.md` (not found)
   - Suggestion: Use `docs/getting-started.md`

### Broken Anchors (1)

1. **docs/advanced.md:78**
   - Link: `[Setup](#installation)`
   - Anchor: `#installation` (not found in docs/setup.md)
   - Suggestion: Use `#getting-started`

## Suggestions

### docs/api.md

Consider adding links to:

- `docs/authentication.md` (90% relevance)
- `docs/error-handling.md` (85% relevance)
```

## 統合予定機能（fix-docs.md から）

以下の機能は将来のアップデートで統合予定:

### 高度なリンク修正

- **コンテキスト認識修正**: 文脈を理解してリンク先を推測
- **バッチ修正**: プロジェクト全体のリンクを一括修正
- **インタラクティブ修正**: ユーザーに確認を取りながら修正

### リンク品質チェック

- **リンク密度**: 適切なリンク数の推奨
- **リンク分布**: ドキュメント間のリンクバランス
- **デッドエンド検出**: 他からリンクされていないページ

### 自動メンテナンス

- **定期検証**: CI/CDパイプラインでのリンク検証
- **プレコミットフック**: コミット前の自動検証
- **継続的監視**: 外部リンクの定期チェック

## まとめ

リンク検証により:

- **整合性保証**: すべてのリンクが有効
- **ナビゲーション改善**: 適切なクロスリファレンス
- **メンテナンス容易性**: 自動修正で手間削減
- **ユーザー体験向上**: 壊れたリンクによるフラストレーション削減

fix-docs.md との統合により、さらに包括的なドキュメント修正システムが実現されます。
