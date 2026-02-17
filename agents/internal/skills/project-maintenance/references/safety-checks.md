# セーフティチェック - 事前検証と参照確認

プロジェクトクリーンアップにおける安全性確保のための包括的なチェック機構。

## 概要

クリーンアップ操作の前後で実行されるセーフティチェックにより、誤削除を防止し、プロジェクトの整合性を保証します。Gitチェックポイント、参照追跡、テスト実行の3層構造で安全性を確保します。

## チェック層

### 第1層: 事前検証

クリーンアップ実行前の状態確認と準備。

#### Gitステータス確認

```bash
# Gitステータスを確認
git status

# 未コミット変更の検出
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: Uncommitted changes detected"
    git status --short
    echo ""
    read -p "Create checkpoint anyway? (y/n) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ブランチ確認
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo "⚠️  Warning: You are on $CURRENT_BRANCH branch"
    read -p "Continue cleanup on main branch? (y/n) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
```

### チェック項目

1. 未コミット変更の有無
2. 現在のブランチ（mainブランチは警告）
3. マージコンフリクトの有無
4. Gitリポジトリの健全性

#### チェックポイント作成

```bash
# 安全なチェックポイント作成
git add -A
git commit -m "Pre-cleanup checkpoint: $(date +%Y-%m-%d_%H:%M:%S)" || {
    echo "ℹ️  No changes to commit"
}

# チェックポイントのハッシュを記録
CHECKPOINT_HASH=$(git rev-parse HEAD)
echo "Checkpoint created: $CHECKPOINT_HASH"
```

### 重要性

- ロールバック可能性の確保
- 変更履歴の記録
- 問題発生時の復旧ポイント

#### プロジェクト状態スナップショット

```python
def create_project_snapshot():
    """プロジェクトの現在の状態を記録"""

    snapshot = {
        "timestamp": datetime.now().isoformat(),
        "git_hash": subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip(),
        "branch": subprocess.check_output(["git", "branch", "--show-current"]).decode().strip(),
        "file_count": len(list(Path(".").rglob("*"))),
        "line_count": count_total_lines(),
        "disk_usage": get_directory_size(".")
    }

    with open(".cleanup_snapshot.json", "w") as f:
        json.dump(snapshot, f, indent=2)

    return snapshot
```

### 第2層: 参照確認

削除対象の参照を徹底的に追跡。

#### Serena依存関係追跡

```python
def check_symbol_references(symbol_path, file_path):
    """シンボルの参照を完全に追跡"""

    # 直接参照を検索
    direct_refs = mcp__serena__find_referencing_symbols(
        symbol_path,
        file_path
    )

    # 間接参照を検索（型、継承等）
    indirect_refs = []

    # クラスの場合、継承しているクラスを検索
    if is_class_symbol(symbol_path):
        indirect_refs.extend(find_subclasses(symbol_path, file_path))

    # 関数の場合、デコレータ使用を検索
    if is_function_symbol(symbol_path):
        indirect_refs.extend(find_decorator_usage(symbol_path, file_path))

    # インターフェース実装を検索
    if is_interface_symbol(symbol_path):
        indirect_refs.extend(find_implementations(symbol_path, file_path))

    total_refs = direct_refs + indirect_refs

    return {
        "direct": direct_refs,
        "indirect": indirect_refs,
        "total_count": len(total_refs),
        "safe_to_remove": len(total_refs) <= 1  # 定義のみ
    }
```

### 追跡対象

1. **直接参照**: 明示的な呼び出し・使用
2. **間接参照**: 継承、実装、デコレータ
3. **型参照**: 型アノテーション、ジェネリクス
4. **動的参照**: リフレクション、文字列参照（検出困難）

#### パブリックAPI保護

```python
def is_public_api(symbol_path, file_path):
    """パブリックAPIかどうか判定"""

    # エクスポート確認
    if is_exported(symbol_path, file_path):
        return True

    # パブリックディレクトリ確認
    if is_in_public_directory(file_path):
        return True

    # ドキュメント化されているか確認
    if has_documentation(symbol_path, file_path):
        return True

    # @publicデコレータ確認
    if has_public_decorator(symbol_path, file_path):
        return True

    return False

def is_exported(symbol_path, file_path):
    """エクスポートされているか確認"""

    # JavaScript/TypeScript
    export_patterns = [
        r"export\s+.*\s+" + symbol_path,
        r"export\s*{.*" + symbol_path,
        r"module\.exports.*" + symbol_path
    ]

    # Python
    if "__all__" in read_file(file_path):
        all_list = extract_all_list(file_path)
        if symbol_path in all_list:
            return True

    # その他のエクスポートパターンをチェック
    for pattern in export_patterns:
        if mcp__serena__search_for_pattern(pattern, file_path):
            return True

    return False
```

#### テストコード参照

```python
def check_test_references(symbol_path, file_path):
    """テストコードでの参照を確認"""

    test_dirs = ["tests/", "test/", "__tests__/", "spec/"]
    test_files = []

    for test_dir in test_dirs:
        if os.path.exists(test_dir):
            test_files.extend(
                mcp__serena__search_for_pattern(
                    substring_pattern=extract_symbol_name(symbol_path),
                    relative_path=test_dir,
                    restrict_search_to_code_files=True
                )
            )

    return {
        "has_test_references": len(test_files) > 0,
        "test_files": test_files,
        "test_count": len(test_files)
    }
```

### 第3層: 事後検証

クリーンアップ後の整合性確認。

#### 自動テスト実行

```python
def run_project_tests():
    """プロジェクトのテストを実行"""

    # プロジェクトタイプを検出
    project_type = detect_project_type()

    test_commands = {
        "npm": ["npm", "test"],
        "python": ["pytest"],
        "go": ["go", "test", "./..."],
        "rust": ["cargo", "test"],
        "ruby": ["bundle", "exec", "rspec"]
    }

    if project_type not in test_commands:
        print(f"⚠️  No test command configured for {project_type}")
        return None

    # テスト実行
    cmd = test_commands[project_type]
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True
    )

    return {
        "success": result.returncode == 0,
        "stdout": result.stdout,
        "stderr": result.stderr,
        "command": " ".join(cmd)
    }
```

#### リント/タイプチェック

```python
def run_quality_checks():
    """品質チェックを実行"""

    checks = []

    # TypeScript
    if os.path.exists("tsconfig.json"):
        checks.append({
            "name": "TypeScript",
            "command": ["npx", "tsc", "--noEmit"]
        })

    # ESLint
    if os.path.exists(".eslintrc.js") or os.path.exists(".eslintrc.json"):
        checks.append({
            "name": "ESLint",
            "command": ["npx", "eslint", "."]
        })

    # Python type checking
    if os.path.exists("mypy.ini") or os.path.exists("pyproject.toml"):
        checks.append({
            "name": "MyPy",
            "command": ["mypy", "."]
        })

    # Python linting
    if os.path.exists(".flake8") or os.path.exists("setup.cfg"):
        checks.append({
            "name": "Flake8",
            "command": ["flake8", "."]
        })

    results = []
    for check in checks:
        result = subprocess.run(
            check["command"],
            capture_output=True,
            text=True
        )
        results.append({
            "name": check["name"],
            "success": result.returncode == 0,
            "output": result.stdout + result.stderr
        })

    return results
```

#### ビルド検証

```python
def verify_build():
    """ビルドが成功するか確認"""

    project_type = detect_project_type()

    build_commands = {
        "npm": ["npm", "run", "build"],
        "python": ["python", "setup.py", "build"],
        "go": ["go", "build", "./..."],
        "rust": ["cargo", "build"],
        "java": ["mvn", "compile"]
    }

    if project_type not in build_commands:
        return None

    cmd = build_commands[project_type]
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True
    )

    return {
        "success": result.returncode == 0,
        "output": result.stdout,
        "errors": result.stderr
    }
```

## セーフティチェック実行フロー

### 完全なフロー

```python
def execute_safe_cleanup(cleanup_targets):
    """セーフティチェック付きクリーンアップ実行"""

    # Phase 1: 事前検証
    print("Phase 1: Pre-validation")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    # Gitステータス確認
    if not check_git_status():
        return False

    # チェックポイント作成
    checkpoint = create_checkpoint()
    print(f"✓ Checkpoint created: {checkpoint}")

    # スナップショット作成
    snapshot = create_project_snapshot()
    print(f"✓ Snapshot created: {snapshot['file_count']} files")

    # Phase 2: 参照確認
    print("\nPhase 2: Reference checking")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    safe_targets = []
    unsafe_targets = []

    for target in cleanup_targets:
        refs = check_all_references(target)

        if refs["safe_to_remove"]:
            safe_targets.append(target)
            print(f"✓ Safe: {target['path']}")
        else:
            unsafe_targets.append({
                "target": target,
                "references": refs
            })
            print(f"⚠️  Unsafe: {target['path']} ({refs['total_count']} references)")

    # 安全でないターゲットを報告
    if unsafe_targets:
        print(f"\n⚠️  {len(unsafe_targets)} targets have references:")
        for item in unsafe_targets:
            print(f"  - {item['target']['path']}")
            print(f"    Direct refs: {len(item['references']['direct'])}")
            print(f"    Indirect refs: {len(item['references']['indirect'])}")

        confirm = input("\nContinue with safe targets only? (y/n): ")
        if confirm.lower() != 'y':
            return False

    # Phase 3: クリーンアップ実行
    print("\nPhase 3: Cleanup execution")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    for target in safe_targets:
        execute_cleanup(target)
        print(f"✓ Cleaned: {target['path']}")

    # Phase 4: 事後検証
    print("\nPhase 4: Post-validation")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    # テスト実行
    test_result = run_project_tests()
    if test_result and not test_result["success"]:
        print("❌ Tests failed!")
        print(test_result["stderr"])
        rollback_to_checkpoint(checkpoint)
        return False

    print("✓ Tests passed")

    # 品質チェック
    quality_results = run_quality_checks()
    failed_checks = [r for r in quality_results if not r["success"]]

    if failed_checks:
        print(f"⚠️  {len(failed_checks)} quality checks failed:")
        for check in failed_checks:
            print(f"  - {check['name']}")

        confirm = input("Continue anyway? (y/n): ")
        if confirm.lower() != 'y':
            rollback_to_checkpoint(checkpoint)
            return False

    print("✓ Quality checks passed")

    # ビルド検証
    build_result = verify_build()
    if build_result and not build_result["success"]:
        print("❌ Build failed!")
        print(build_result["errors"])
        rollback_to_checkpoint(checkpoint)
        return False

    print("✓ Build successful")

    # 完了
    print("\n✅ Cleanup completed successfully")
    return True
```

## ロールバック機構

### 自動ロールバック

```python
def rollback_to_checkpoint(checkpoint_hash):
    """チェックポイントにロールバック"""

    print(f"\n🔄 Rolling back to checkpoint: {checkpoint_hash}")

    # 未コミット変更を破棄
    subprocess.run(["git", "reset", "--hard", checkpoint_hash])

    # 未追跡ファイルを削除
    subprocess.run(["git", "clean", "-fd"])

    print("✓ Rollback completed")

def create_rollback_script(checkpoint_hash):
    """手動ロールバック用スクリプト作成"""

    script = f"""#!/bin/bash
# Rollback script generated at {datetime.now().isoformat()}
# Checkpoint: {checkpoint_hash}

echo "Rolling back to checkpoint: {checkpoint_hash}"
git reset --hard {checkpoint_hash}
git clean -fd
echo "Rollback completed"
"""

    with open("rollback.sh", "w") as f:
        f.write(script)

    os.chmod("rollback.sh", 0o755)
    print("✓ Rollback script created: ./rollback.sh")
```

## 保護メカニズム

### @preserve コメント

```python
def check_preserve_comment(symbol_path, file_path):
    """@preserveコメントをチェック"""

    # シンボル定義の前のコメントを取得
    symbol_info = mcp__serena__find_symbol(
        symbol_path,
        file_path,
        include_info=True
    )

    if not symbol_info:
        return False

    # 定義の前のコメントを確認
    lines = read_file(file_path).split("\n")
    symbol_line = symbol_info["range"]["start"]["line"]

    # 前3行をチェック
    for i in range(max(0, symbol_line - 3), symbol_line):
        if "@preserve" in lines[i]:
            return True

    return False

# 使用例
"""
# @preserve: Used via reflection
def dynamic_handler():
    pass

# @preserve: Required by external plugin
class PluginInterface:
    pass
"""
```

### .cleanupignore ファイル

```python
def load_cleanup_ignore():
    """`.cleanupignore` を読み込み"""

    ignore_file = ".cleanupignore"
    if not os.path.exists(ignore_file):
        return []

    with open(ignore_file, 'r') as f:
        patterns = []
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                patterns.append(line)

    return patterns

def is_ignored(file_path, ignore_patterns):
    """除外パターンに一致するかチェック"""
    return any(fnmatch.fnmatch(file_path, pattern) for pattern in ignore_patterns)
```

## エラーハンドリング

### エラー時の対応

```python
def handle_cleanup_error(error, context):
    """クリーンアップエラーのハンドリング"""

    error_log = {
        "timestamp": datetime.now().isoformat(),
        "error": str(error),
        "context": context,
        "checkpoint": context.get("checkpoint_hash"),
        "targets": context.get("cleanup_targets", [])
    }

    # エラーログを保存
    with open(".cleanup_error.json", "w") as f:
        json.dump(error_log, f, indent=2)

    # チェックポイントに自動ロールバック
    if "checkpoint_hash" in context:
        rollback_to_checkpoint(context["checkpoint_hash"])

    # エラーレポート
    print("\n❌ Cleanup failed!")
    print(f"Error: {error}")
    print(f"Error log saved: .cleanup_error.json")
    print(f"Rolled back to checkpoint: {context['checkpoint_hash']}")
```

## ベストプラクティス

1. **常にチェックポイント作成**: クリーンアップ前に必ずGitチェックポイントを作成
2. **段階的実行**: 小規模から開始し、徐々に範囲を拡大
3. **dry-run優先**: 本番実行前に必ずプレビュー
4. **テスト実行**: クリーンアップ後は必ずテスト実行
5. **チーム通知**: 大規模変更はチームに事前通知
