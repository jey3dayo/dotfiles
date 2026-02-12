# Commit Message Generation - AI駆動メッセージ生成

コミットメッセージの自動生成ロジックの詳細仕様です。

## 生成戦略

AI駆動でConventional Commits準拠のメッセージを生成します。

### Conventional Commits形式

```
<type>([scope]): <subject>

[body]

[footer]
```

### 構成要素

### Type

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `style`: フォーマット・スタイル変更
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `chore`: その他（依存関係更新、ビルド設定等）
- `perf`: パフォーマンス改善

### Scope

- 影響を受けるコンポーネント・モジュール名
- 例: `auth`, `api`, `ui`, `db`

### Subject

- 変更の簡潔な説明（50文字以内推奨）
- 現在形・命令形（"add" not "added"）
- 先頭小文字、末尾ピリオドなし

### Body

- 変更の理由・詳細説明
- "why"を重視（"what"はdiffで分かる）

### Footer

- Breaking Changes
- Issue参照（Closes #123）

## 分析プロセス

### 1. 変更ファイル分析

```python
def analyze_changed_files():
    """変更ファイルを分析"""
    result = subprocess.run(
        ["git", "diff", "--cached", "--name-status"],
        capture_output=True,
        text=True
    )

    files = []
    for line in result.stdout.strip().split('\n'):
        if not line:
            continue

        parts = line.split('\t')
        status = parts[0]  # M=Modified, A=Added, D=Deleted
        filepath = parts[1]

        files.append({
            'status': status,
            'path': filepath,
            'basename': os.path.basename(filepath),
            'dirname': os.path.dirname(filepath),
            'extension': os.path.splitext(filepath)[1]
        })

    return files
```

### 2. Diff内容解析

```python
def analyze_diff_content():
    """Diff内容を解析"""
    result = subprocess.run(
        ["git", "diff", "--cached"],
        capture_output=True,
        text=True
    )

    diff_content = result.stdout

    # 変更量
    stats = {
        'additions': diff_content.count('\n+'),
        'deletions': diff_content.count('\n-'),
        'total_lines': len(diff_content.split('\n'))
    }

    # パターンマッチング
    patterns = {
        'new_function': r'^\+\s*(function|def|func|fn)\s+\w+',
        'new_class': r'^\+\s*(class|struct|interface)\s+\w+',
        'new_test': r'^\+\s*(test|it|describe)\(',
        'import_changes': r'^\+\s*(import|from|require)',
        'config_changes': r'\.(json|yaml|yml|toml|ini)$',
        'bug_fix_indicators': r'(fix|bug|issue|error|crash)',
        'refactoring_indicators': r'(refactor|rename|move|extract)'
    }

    matches = {}
    for name, pattern in patterns.items():
        matches[name] = bool(re.search(pattern, diff_content, re.MULTILINE))

    return {
        'stats': stats,
        'patterns': matches,
        'diff': diff_content
    }
```

### 3. コミット履歴確認

プロジェクトのコミット規約を検出：

```python
def analyze_commit_history():
    """最近のコミット履歴を確認"""
    result = subprocess.run(
        ["git", "log", "--pretty=format:%s", "-20"],
        capture_output=True,
        text=True
    )

    commits = result.stdout.strip().split('\n')

    # Conventional Commits使用率
    conventional_pattern = r'^(feat|fix|docs|style|refactor|test|chore|perf)(\(.+\))?:'
    conventional_count = sum(1 for c in commits if re.match(conventional_pattern, c))
    conventional_ratio = conventional_count / len(commits) if commits else 0

    # スコープ使用パターン
    scope_pattern = r'^[a-z]+\(([^)]+)\):'
    scopes = []
    for commit in commits:
        match = re.match(scope_pattern, commit)
        if match:
            scopes.append(match.group(1))

    return {
        'uses_conventional': conventional_ratio > 0.5,
        'common_scopes': list(set(scopes)),
        'recent_commits': commits[:5]
    }
```

### 4. メッセージ生成

```python
def generate_commit_message(files, diff_analysis, history):
    """コミットメッセージを生成"""

    # Type判定
    commit_type = determine_commit_type(files, diff_analysis)

    # Scope判定
    commit_scope = determine_commit_scope(files, history)

    # Subject生成
    commit_subject = generate_subject(files, diff_analysis, commit_type)

    # Message組み立て
    if commit_scope and history['uses_conventional']:
        message = f"{commit_type}({commit_scope}): {commit_subject}"
    else:
        message = f"{commit_type}: {commit_subject}"

    # Body生成（必要な場合）
    if diff_analysis['stats']['total_lines'] > 100:
        body = generate_body(files, diff_analysis)
        message = f"{message}\n\n{body}"

    return message
```

## Type判定ロジック

```python
def determine_commit_type(files, diff_analysis):
    """コミットタイプを判定"""

    patterns = diff_analysis['patterns']
    stats = diff_analysis['stats']

    # ファイルパスベースの判定
    file_paths = [f['path'] for f in files]

    # Test
    if any('test' in path or 'spec' in path for path in file_paths):
        return 'test'

    # Docs
    if any(path.endswith('.md') or 'docs/' in path for path in file_paths):
        return 'docs'

    # Config
    if patterns['config_changes']:
        return 'chore'

    # Diff内容ベースの判定
    if patterns['bug_fix_indicators']:
        return 'fix'

    if patterns['refactoring_indicators']:
        return 'refactor'

    if patterns['new_function'] or patterns['new_class']:
        return 'feat'

    # デフォルト: 変更量で判断
    if stats['additions'] > stats['deletions'] * 2:
        return 'feat'  # 大量追加 → 新機能
    elif stats['deletions'] > stats['additions'] * 2:
        return 'refactor'  # 大量削除 → リファクタリング
    else:
        return 'chore'  # その他
```

## Scope判定ロジック

```python
def determine_commit_scope(files, history):
    """スコープを判定"""

    if not history['uses_conventional']:
        # プロジェクトがConventional Commitsを使っていない
        return None

    # 変更ファイルのディレクトリから推定
    directories = set()
    for f in files:
        dirname = f['dirname']
        if dirname:
            # 最上位ディレクトリを取得
            top_dir = dirname.split('/')[0]
            directories.add(top_dir)

    # 単一ディレクトリの場合
    if len(directories) == 1:
        scope = list(directories)[0]

        # よく使われるスコープにマッピング
        scope_mapping = {
            'src': None,  # 汎用すぎるのでスコープなし
            'lib': None,
            'components': 'ui',
            'pages': 'ui',
            'api': 'api',
            'auth': 'auth',
            'db': 'db',
            'database': 'db',
            'utils': None,
            'helpers': None,
            'tests': 'test',
            'docs': 'docs'
        }

        return scope_mapping.get(scope, scope)

    # 複数ディレクトリ → スコープなし
    return None
```

## Subject生成ロジック

```python
def generate_subject(files, diff_analysis, commit_type):
    """Subject（件名）を生成"""

    patterns = diff_analysis['patterns']

    # Type別のテンプレート
    templates = {
        'feat': [
            "add {feature}",
            "implement {feature}",
            "introduce {feature}"
        ],
        'fix': [
            "resolve {issue}",
            "fix {issue}",
            "correct {issue}"
        ],
        'refactor': [
            "improve {component}",
            "refactor {component}",
            "restructure {component}"
        ],
        'docs': [
            "update documentation",
            "add {doc_type} documentation"
        ],
        'style': [
            "apply code formatting",
            "fix code style"
        ],
        'test': [
            "add tests for {feature}",
            "update test cases"
        ],
        'chore': [
            "update dependencies",
            "update {config}"
        ]
    }

    # ファイル名から特徴を抽出
    feature_name = extract_feature_name(files)

    # テンプレート選択と埋め込み
    template = templates[commit_type][0]
    subject = template.format(
        feature=feature_name,
        issue=feature_name,
        component=feature_name,
        doc_type="API",
        config="configuration"
    )

    return subject

def extract_feature_name(files):
    """ファイル名から機能名を抽出"""
    if len(files) == 1:
        # 単一ファイル → ファイル名ベース
        basename = files[0]['basename']
        name = os.path.splitext(basename)[0]
        # キャメルケース → スペース区切り
        name = re.sub(r'([a-z])([A-Z])', r'\1 \2', name)
        return name.lower()

    # 複数ファイル → 共通ディレクトリ名
    directories = [f['dirname'] for f in files]
    common_prefix = os.path.commonprefix(directories)
    if common_prefix:
        return os.path.basename(common_prefix)

    return "multiple components"
```

## Body生成ロジック

```python
def generate_body(files, diff_analysis):
    """Body（本文）を生成"""

    stats = diff_analysis['stats']

    body_parts = []

    # 変更サマリー
    if len(files) > 5:
        body_parts.append(f"Changes across {len(files)} files")

    # 変更量
    if stats['additions'] > 50 or stats['deletions'] > 50:
        body_parts.append(
            f"+{stats['additions']} -{stats['deletions']} lines"
        )

    # 主要な変更内容
    if diff_analysis['patterns']['new_function']:
        body_parts.append("- Add new functions")
    if diff_analysis['patterns']['new_class']:
        body_parts.append("- Add new classes")
    if diff_analysis['patterns']['new_test']:
        body_parts.append("- Add test coverage")

    return '\n'.join(body_parts) if body_parts else None
```

## プロジェクト規約への適応

```python
def adapt_to_project_convention(message, history):
    """プロジェクト規約に適応"""

    if not history['uses_conventional']:
        # Conventional Commitsを使わないプロジェクト
        # → 簡潔なメッセージに変換
        match = re.match(r'^[a-z]+(\([^)]+\))?: (.+)', message)
        if match:
            return match.group(2).capitalize()

    return message
```

## 実行例

### シンプルな変更

```bash
# 変更: src/auth/login.ts (機能追加)
# 生成メッセージ:
feat(auth): add login functionality
```

### バグ修正

```bash
# 変更: src/api/users.ts (エラー修正)
# 生成メッセージ:
fix(api): resolve user query timeout issue
```

### リファクタリング

```bash
# 変更: 複数ファイル（構造改善）
# 生成メッセージ:
refactor: improve code structure

Changes across 12 files
+234 -189 lines
- Extract common utilities
- Simplify component hierarchy
```

### ドキュメント

```bash
# 変更: README.md, docs/api.md
# 生成メッセージ:
docs: update API documentation
```

## エラーハンドリング

```python
def safe_generate_message():
    """安全にメッセージ生成（フォールバック付き）"""

    try:
        files = analyze_changed_files()
        diff = analyze_diff_content()
        history = analyze_commit_history()

        message = generate_commit_message(files, diff, history)
        return adapt_to_project_convention(message, history)

    except Exception as e:
        print(f"⚠️  自動生成に失敗: {e}")
        print("💡 シンプルなメッセージを使用します")

        # フォールバック: 変更ファイル名ベース
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True,
            text=True
        )
        files = result.stdout.strip().split('\n')

        if len(files) == 1:
            return f"Update {os.path.basename(files[0])}"
        else:
            return f"Update {len(files)} files"
```

## ユーザー指定メッセージとの統合

```python
def finalize_commit_message(user_message=None):
    """最終的なコミットメッセージを決定"""

    if user_message:
        # ユーザー指定がある場合はそれを使用
        print(f"📝 ユーザー指定メッセージを使用: {user_message}")
        return user_message

    # AI生成
    print("🤖 コミットメッセージを自動生成中...")
    message = safe_generate_message()
    print(f"📝 生成メッセージ: {message}")

    return message
```

## 署名なしポリシーの適用

```python
def create_commit(message):
    """署名なしでコミット作成"""

    # HEREDOC形式でメッセージを渡す
    commit_command = f"""git commit -m "$(cat <<'EOF'
{message}
EOF
)""""

    result = subprocess.run(
        commit_command,
        shell=True,
        capture_output=True,
        text=True
    )

    if result.returncode == 0:
        print("✅ コミット作成成功")
    else:
        print(f"❌ コミット作成失敗: {result.stderr}")
        raise Exception("Commit failed")
```

### 重要

- "Co-authored-by: Claude" 追加
- "Generated with Claude Code" 追加
- その他のAI/Assistant署名追加
- Git設定の変更

## ベストプラクティス

### メッセージの品質向上

1. **明確な命令形**: "add", "fix", "update"
2. **現在形**: "adds" ではなく "add"
3. **簡潔**: 50文字以内推奨
4. **小文字開始**: "Add" ではなく "add"
5. **ピリオドなし**: 末尾にピリオド不要

### プロジェクト規約の尊重

```python
# プロジェクトがEmoji Commitを使用している場合
if project_uses_emoji_commits():
    message = f"✨ {message}"

# Angular規約の場合
if project_uses_angular_convention():
    message = adapt_to_angular(message)
```

ただし、ユーザー指定のCLAUDE.mdで絵文字禁止が設定されている場合は尊重します。
