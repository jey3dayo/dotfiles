# Commit Patterns - インテリジェントコミット分割

Phase 3: 変更内容を解析し、意味的なまとまりごとにコミットを作成する完全な仕様。

## Table of Contents

- [概要](#概要)
- [変更タイプ分類](#変更タイプ分類)
- [コミット分割アルゴリズム](#コミット分割アルゴリズム)
- [コミットメッセージ生成](#コミットメッセージ生成)
- [Co-Author Attribution](#co-author-attribution)
- [単一コミットモード](#単一コミットモード)

## 概要

インテリジェントコミット分割は、変更内容を意味的なまとまりごとに分類し、適切な粒度でコミットを作成します。

**目的**:

- 変更の意図を明確にする
- レビューしやすいコミット履歴を作成
- Conventional Commits準拠のメッセージ生成
- 自動ロールバックを容易にする

**実行タイミング**: Phase 3（フォーマット実行後）

## 変更タイプ分類

変更は以下の8つのタイプに分類されます:

### 1. format - フォーマットのみの変更

**判定条件**:

- インデント・空白・改行のみの変更
- コードの構造や動作に影響しない
- セミコロン・カンマの追加/削除

**例**:

```diff
- function foo(){
+ function foo() {
```

### 2. refactor - リファクタリング

**判定条件**:

- 関数/変数名の変更
- コードの構造変更（機能は同じ）
- 複雑度の削減

**例**:

```diff
- const getData = () => {...}
+ const fetchUserData = () => {...}
```

### 3. feature - 機能追加

**判定条件**:

- 新しい関数/クラスの追加
- 新しい機能の実装
- APIエンドポイントの追加

**例**:

```diff
+ export function authenticateUser(credentials) {
+   // 新機能
+ }
```

### 4. fix - バグ修正

**判定条件**:

- `fix:`, `bug:`, `issue:` などのキーワード
- 条件分岐の修正
- エラーハンドリングの追加

**例**:

```diff
- if (user.age > 18) {
+ if (user.age >= 18) {
```

### 5. test - テスト

**判定条件**:

- ファイルパスに `test`, `spec`, `__tests__` を含む
- `*.test.ts`, `*.spec.js` などの拡張子

**例**:

```typescript
// tests/auth/login.test.ts
describe('login', () => {
  it('should authenticate user', () => {...})
})
```

### 6. docs - ドキュメント

**判定条件**:

- `.md`, `.txt`, `.rst` などの拡張子
- `README`, `CHANGELOG`, `LICENSE` などのファイル名
- コメントのみの変更

**例**:

```diff
+ ## Installation
+
+ Run `npm install` to install dependencies.
```

### 7. config - 設定ファイル

**判定条件**:

- `.` で始まるファイル (`.eslintrc`, `.prettierrc`)
- `config` をパスに含む
- `tsconfig.json`, `webpack.config.js` など

**例**:

```json
// .eslintrc.json
{
  "rules": {
    "indent": ["error", 2]
  }
}
```

### 8. deps - 依存関係

**判定条件**:

- `package.json`, `package-lock.json`
- `go.mod`, `go.sum`
- `requirements.txt`, `Pipfile`
- `Cargo.toml`, `Cargo.lock`

**例**:

```diff
// package.json
"dependencies": {
-  "react": "^17.0.0",
+  "react": "^18.0.0"
}
```

## コミット分割アルゴリズム

### ステップ1: 変更ファイルの取得

```python
def analyze_changes():
    """変更ファイルとdiffを取得"""

    # git diff で変更内容を取得
    result = subprocess.run(
        ["git", "diff", "--cached", "--name-only"],
        capture_output=True,
        text=True
    )

    files = result.stdout.strip().split('\n')
    changes = {}

    for file in files:
        # 各ファイルのdiffを取得
        diff_result = subprocess.run(
            ["git", "diff", "--cached", file],
            capture_output=True,
            text=True
        )
        changes[file] = diff_result.stdout

    return changes
```

### ステップ2: 変更の分類

```python
def create_intelligent_commits(options):
    """変更を適切な粒度でコミット"""

    if options.get('single_commit'):
        # 単一コミットモード
        return create_single_commit()

    # 1. 変更ファイルの分類
    changes = analyze_changes()

    # 2. 変更タイプごとにグループ化
    groups = {
        'format': [],      # フォーマットのみの変更
        'refactor': [],    # リファクタリング
        'feature': [],     # 機能追加
        'fix': [],         # バグ修正
        'test': [],        # テスト
        'docs': [],        # ドキュメント
        'config': [],      # 設定ファイル
        'deps': []         # 依存関係
    }

    for file, diff in changes.items():
        change_type = classify_change(file, diff)
        groups[change_type].append(file)

    # 3. グループごとにコミット作成
    commit_groups = []
    for change_type, files in groups.items():
        if not files:
            continue

        # コミットメッセージ生成
        message = generate_commit_message(change_type, files)

        # ファイルをステージング
        for file in files:
            subprocess.run(["git", "add", file])

        # コミット作成
        commit_with_co_author(message)
        commit_groups.append({
            'type': change_type,
            'files': files,
            'message': message
        })

    return commit_groups
```

### ステップ3: diff内容ベースの分類

```python
def classify_change(filepath, diff_content):
    """変更内容から変更タイプを分類"""

    # ファイルパスベースの分類
    if "test" in filepath or "spec" in filepath:
        return 'test'
    elif filepath.endswith(('.md', '.txt', '.rst')):
        return 'docs'
    elif filepath in ['package.json', 'go.mod', 'requirements.txt', 'Cargo.toml']:
        return 'deps'
    elif filepath.startswith('.') or 'config' in filepath:
        return 'config'

    # diff内容ベースの分類
    if is_formatting_only_change(diff_content):
        return 'format'
    elif has_bug_fix_indicators(diff_content):
        return 'fix'
    elif has_refactoring_indicators(diff_content):
        return 'refactor'
    else:
        return 'feature'

def is_formatting_only_change(diff_content):
    """フォーマットのみの変更かを判定"""

    # 空白・インデント・改行のみの変更
    lines = diff_content.split('\n')

    for line in lines:
        if line.startswith('+') or line.startswith('-'):
            # 実質的なコード変更があるか
            stripped = line[1:].strip()
            if stripped and not is_whitespace_only(stripped):
                # 意味のある変更がある場合はフォーマットのみではない
                return False

    return True

def has_bug_fix_indicators(diff_content):
    """バグ修正の指標を含むか判定"""

    keywords = [
        'fix:', 'bug:', 'issue:', 'resolve:',
        'bugfix', 'hotfix', 'patch'
    ]

    for keyword in keywords:
        if keyword in diff_content.lower():
            return True

    # 条件分岐の修正パターン
    if re.search(r'[<>=!]=', diff_content):
        return True

    return False

def has_refactoring_indicators(diff_content):
    """リファクタリングの指標を含むか判定"""

    keywords = [
        'refactor:', 'rename:', 'extract:', 'inline:',
        'simplify', 'cleanup', 'improve'
    ]

    for keyword in keywords:
        if keyword in diff_content.lower():
            return True

    # 関数名・変数名の変更パターン
    if re.search(r'[-+]\s*(?:const|let|var|function)\s+\w+', diff_content):
        return True

    return False
```

## コミットメッセージ生成

### Conventional Commits準拠

すべてのコミットメッセージは以下のフォーマットに従います:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### テンプレート

```python
def generate_commit_message(change_type, files):
    """変更タイプとファイルからコミットメッセージを生成"""

    templates = {
        'format': "style: apply code formatting",
        'refactor': "refactor: improve code structure",
        'feature': "feat: add new functionality",
        'fix': "fix: resolve issues",
        'test': "test: update test cases",
        'docs': "docs: update documentation",
        'config': "chore: update configuration",
        'deps': "chore: update dependencies"
    }

    base_message = templates.get(change_type, "chore: update files")

    # ファイル情報を追加
    if len(files) == 1:
        scope = extract_scope(files[0])
        return f"{change_type}({scope}): {extract_action(files[0])}"
    elif len(files) <= 3:
        return f"{base_message} in {', '.join(files)}"
    else:
        return f"{base_message} ({len(files)} files)"

def extract_scope(filepath):
    """ファイルパスからスコープを抽出"""

    # 例: src/auth/login.ts -> auth
    parts = filepath.split('/')

    if len(parts) >= 2:
        return parts[-2]  # ディレクトリ名
    else:
        return parts[0].split('.')[0]  # ファイル名（拡張子なし）

def extract_action(filepath):
    """ファイルパスから動作を推測"""

    filename = os.path.basename(filepath)

    # 特定のパターンから推測
    if 'login' in filename:
        return "add login functionality"
    elif 'auth' in filename:
        return "add authentication"
    elif 'test' in filename:
        return "add test coverage"
    else:
        return f"update {filename}"
```

### メッセージ例

**format**:

```
style: apply code formatting
```

**feature (単一ファイル)**:

```
feat(auth): add login functionality
```

**feature (複数ファイル)**:

```
feat: add new functionality in src/auth/login.ts, src/auth/session.ts, src/utils/token.ts
```

**feature (多数ファイル)**:

```
feat: add new functionality (12 files)
```

**fix**:

```
fix(validation): resolve input validation issues
```

**test**:

```
test(auth): update test cases
```

**deps**:

```
chore: update dependencies
```

## Co-Author Attribution

すべてのコミットにClaude Code署名を追加します。

### 実装

```python
def commit_with_co_author(message):
    """Co-Author情報付きでコミット"""

    full_message = f"""$(cat <<'EOF'
{message}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"""

    subprocess.run(["git", "commit", "-m", full_message])
```

### 出力例

```
feat(auth): add login functionality

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## 単一コミットモード

`--single-commit` オプション使用時は、すべての変更を1つのコミットにまとめます。

### 実装

```python
def create_single_commit():
    """すべての変更を単一コミットで作成"""

    # すべての変更をステージング
    subprocess.run(["git", "add", "-A"])

    # コミットメッセージ生成
    message = "chore: apply code formatting and updates"

    # Co-Author付きでコミット
    commit_with_co_author(message)

    return [{
        'type': 'chore',
        'files': get_all_changed_files(),
        'message': message
    }]
```

### 使用例

```bash
/create-pr --single-commit

# 実行結果:
# ✅ コミット作成完了: chore: apply code formatting and updates
```

---

**参照**: このドキュメントはPhase 3の詳細仕様です。実行フローの概要は [SKILL.md](../SKILL.md) を参照してください。
