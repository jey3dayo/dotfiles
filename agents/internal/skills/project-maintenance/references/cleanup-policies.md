# クリーンアップポリシー - 削除ポリシーとバックアップ戦略

プロジェクトクリーンアップにおける削除判定基準とバックアップ戦略の詳細。

## 削除ポリシー

### 基本原則

1. **保守的アプローチ**: 疑わしい場合は削除しない
2. **段階的削除**: 小規模から開始し、徐々に拡大
3. **可逆性確保**: 全ての削除は復元可能に
4. **影響分析**: 削除前に必ず影響範囲を確認

### 削除優先度レベル

#### Level 1: 安全（自動削除可）

明らかに不要で、削除しても問題ないファイル:

```python
SAFE_PATTERNS = [
    # 一時ファイル
    "**/*.log",
    "**/*.tmp",
    "**/*~",
    "**/*.swp",
    "**/*.bak",

    # システムファイル
    "**/.DS_Store",
    "**/Thumbs.db",
    "**/desktop.ini",

    # コンパイル生成物
    "**/*.pyc",
    "**/__pycache__",
    "**/*.class",
    "**/*.o",
    "**/*.obj",

    # キャッシュ
    ".eslintcache",
    ".pytest_cache",
    "node_modules/.cache"
]
```

### 判定基準

- プロジェクトの動作に影響しない
- 再生成可能
- Gitで追跡されていない
- アクティブプロセスで使用されていない

#### Level 2: 要確認（手動確認推奨）

削除の影響を確認すべきファイル:

```python
NEEDS_REVIEW_PATTERNS = [
    # 古い実装
    "**/*.old",
    "**/*.backup",
    "**/*.deprecated",

    # コメントアウトされたコード
    # （パターンマッチング困難、手動確認）

    # 大きなログファイル（>10MB）
    # （サイズチェック必要）

    # 古いドキュメント
    "**/*_old.md",
    "**/*_backup.md"
]
```

### 判定基準

- 削除しても問題ない可能性が高い
- ただし、重要な情報が含まれる可能性
- 手動確認またはプレビュー必須

#### Level 3: 保護（削除禁止）

削除してはいけないファイル:

```python
PROTECTED_PATTERNS = [
    # 設定ディレクトリ
    ".claude/**",
    ".git/**",
    ".github/**",

    # 依存関係
    "node_modules/**",
    "vendor/**",
    ".venv/**",
    "venv/**",

    # 環境変数・設定
    ".env",
    ".env.*",
    "config/**",
    "secrets/**",

    # ドキュメント
    "README.md",
    "CHANGELOG.md",
    "LICENSE",

    # ビルド設定
    "package.json",
    "tsconfig.json",
    "pyproject.toml",
    "Cargo.toml"
]
```

### 判定基準

- プロジェクトの動作に不可欠
- 設定や環境情報を含む
- バージョン管理で追跡されている重要ファイル
- 復元困難または不可能

### コードベースの削除ポリシー

#### 未使用シンボル

```python
def should_remove_symbol(symbol_info, references):
    """シンボル削除可否を判定"""

    # Level 1: 安全（削除可）
    if (references["total_count"] == 1 and  # 定義のみ
        not symbol_info["is_exported"] and
        not symbol_info["has_documentation"] and
        not symbol_info["is_public_api"]):
        return {
            "should_remove": True,
            "level": 1,
            "reason": "未使用プライベートシンボル"
        }

    # Level 2: 要確認
    if (references["total_count"] <= 2 and  # 定義＋1参照
        not symbol_info["is_public_api"]):
        return {
            "should_remove": False,
            "level": 2,
            "reason": "参照が少ないが、使用されている可能性",
            "action": "手動確認推奨"
        }

    # Level 3: 保護（削除不可）
    if (symbol_info["is_exported"] or
        symbol_info["is_public_api"] or
        references["total_count"] > 2):
        return {
            "should_remove": False,
            "level": 3,
            "reason": "パブリックAPIまたは使用中",
            "action": "削除不可"
        }

    return {
        "should_remove": False,
        "level": 2,
        "reason": "判定困難",
        "action": "手動確認必須"
    }
```

#### デバッグコード

```python
def should_remove_debug_code(match_info):
    """デバッグコード削除可否を判定"""

    # Level 1: 安全（削除可）
    safe_patterns = [
        r"console\.log\(['\"]debug:",  # 明示的なデバッグログ
        r"print\(['\"]DEBUG:",         # 明示的なデバッグプリント
        r"# DEBUG:",                   # デバッグコメント
        r"// DEBUG:",
    ]

    for pattern in safe_patterns:
        if re.search(pattern, match_info["line"]):
            return {
                "should_remove": True,
                "level": 1,
                "reason": "明示的なデバッグコード"
            }

    # Level 2: 要確認
    if match_info["in_test_file"]:
        return {
            "should_remove": False,
            "level": 2,
            "reason": "テストファイル内",
            "action": "保持推奨"
        }

    if match_info["has_side_effects"]:
        return {
            "should_remove": False,
            "level": 2,
            "reason": "副作用の可能性",
            "action": "手動確認必須"
        }

    # デフォルト: 要確認
    return {
        "should_remove": False,
        "level": 2,
        "reason": "影響不明",
        "action": "手動確認推奨"
    }
```

### ドキュメントの削除ポリシー

#### 重複ドキュメント

```python
def should_consolidate_docs(primary_doc, duplicate_docs):
    """ドキュメント統合可否を判定"""

    # 重複度を計算
    similarity_scores = []
    for dup in duplicate_docs:
        score = calculate_similarity(primary_doc, dup)
        similarity_scores.append({
            "doc": dup,
            "score": score
        })

    # 高重複度（>80%）
    high_similarity = [s for s in similarity_scores if s["score"] > 0.8]
    if high_similarity:
        return {
            "should_consolidate": True,
            "level": 1,
            "action": "統合推奨",
            "duplicates": high_similarity
        }

    # 中重複度（50-80%）
    medium_similarity = [s for s in similarity_scores if 0.5 < s["score"] <= 0.8]
    if medium_similarity:
        return {
            "should_consolidate": False,
            "level": 2,
            "action": "手動確認推奨",
            "reason": "部分的な重複",
            "duplicates": medium_similarity
        }

    # 低重複度（<50%）
    return {
        "should_consolidate": False,
        "level": 3,
        "action": "統合不要",
        "reason": "重複度が低い"
    }
```

## バックアップ戦略

### 3層バックアップシステム

#### Layer 1: Gitチェックポイント（必須）

```python
def create_git_checkpoint():
    """Gitチェックポイントを作成"""

    timestamp = datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
    checkpoint_message = f"Pre-cleanup checkpoint: {timestamp}"

    # 未コミット変更をステージング
    subprocess.run(["git", "add", "-A"])

    # コミット作成
    result = subprocess.run(
        ["git", "commit", "-m", checkpoint_message],
        capture_output=True,
        text=True
    )

    # チェックポイントハッシュを取得
    if result.returncode == 0:
        checkpoint_hash = subprocess.check_output(
            ["git", "rev-parse", "HEAD"]
        ).decode().strip()

        # メタデータを保存
        checkpoint_info = {
            "hash": checkpoint_hash,
            "timestamp": timestamp,
            "message": checkpoint_message,
            "branch": subprocess.check_output(
                ["git", "branch", "--show-current"]
            ).decode().strip()
        }

        with open(".cleanup_checkpoint.json", "w") as f:
            json.dump(checkpoint_info, f, indent=2)

        return checkpoint_info
    else:
        print("No changes to commit")
        return None
```

### 特徴

- 即座にロールバック可能
- コミット履歴として残る
- Gitの強力な差分・復元機能を活用

#### Layer 2: ファイルアーカイブ（推奨）

```python
def create_file_archive(files_to_clean):
    """削除対象ファイルをアーカイブ"""

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    archive_name = f".cleanup_archive_{timestamp}.tar.gz"

    # アーカイブ作成
    import tarfile

    with tarfile.open(archive_name, "w:gz") as tar:
        for file_path in files_to_clean:
            if os.path.exists(file_path):
                tar.add(file_path)

    # アーカイブ情報を保存
    archive_info = {
        "archive": archive_name,
        "timestamp": timestamp,
        "file_count": len(files_to_clean),
        "files": files_to_clean,
        "size": os.path.getsize(archive_name)
    }

    with open(f".cleanup_archive_{timestamp}.json", "w") as f:
        json.dump(archive_info, f, indent=2)

    return archive_info
```

### 特徴

- 削除ファイルを圧縮保存
- 個別ファイルの復元が可能
- ディスク容量を節約

#### Layer 3: スナップショット（オプション）

```python
def create_full_snapshot():
    """プロジェクト全体のスナップショット"""

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    snapshot_dir = f".cleanup_snapshot_{timestamp}"

    # スナップショットディレクトリ作成
    os.makedirs(snapshot_dir, exist_ok=True)

    # プロジェクト状態を記録
    snapshot_info = {
        "timestamp": timestamp,
        "git_hash": subprocess.check_output(
            ["git", "rev-parse", "HEAD"]
        ).decode().strip(),
        "files": {},
        "metadata": {}
    }

    # 重要ファイルのハッシュを記録
    important_patterns = [
        "**/*.py",
        "**/*.js",
        "**/*.ts",
        "**/*.md",
        "package.json",
        "tsconfig.json"
    ]

    for pattern in important_patterns:
        for file_path in glob.glob(pattern, recursive=True):
            if os.path.isfile(file_path):
                with open(file_path, "rb") as f:
                    file_hash = hashlib.sha256(f.read()).hexdigest()
                    snapshot_info["files"][file_path] = {
                        "hash": file_hash,
                        "size": os.path.getsize(file_path),
                        "mtime": os.path.getmtime(file_path)
                    }

    # スナップショット情報を保存
    with open(f"{snapshot_dir}/snapshot.json", "w") as f:
        json.dump(snapshot_info, f, indent=2)

    return snapshot_info
```

### 特徴

- プロジェクト全体の状態を記録
- 整合性検証が可能
- 大規模変更時の保険

### バックアップ保持期間

```python
BACKUP_RETENTION = {
    "git_checkpoints": {
        "retention_days": 30,
        "cleanup_policy": "手動削除（git reset等）"
    },
    "file_archives": {
        "retention_days": 7,
        "cleanup_policy": "自動削除（古いアーカイブ）"
    },
    "snapshots": {
        "retention_days": 3,
        "cleanup_policy": "自動削除（最新3つのみ保持）"
    }
}

def cleanup_old_backups():
    """古いバックアップを削除"""

    current_time = time.time()

    # 古いアーカイブを削除
    archives = glob.glob(".cleanup_archive_*.tar.gz")
    for archive in archives:
        mtime = os.path.getmtime(archive)
        age_days = (current_time - mtime) / (24 * 3600)

        if age_days > BACKUP_RETENTION["file_archives"]["retention_days"]:
            os.remove(archive)
            # メタデータも削除
            meta_file = archive.replace(".tar.gz", ".json")
            if os.path.exists(meta_file):
                os.remove(meta_file)

    # 古いスナップショットを削除
    snapshots = sorted(glob.glob(".cleanup_snapshot_*"), reverse=True)
    for snapshot in snapshots[3:]:  # 最新3つ以外
        shutil.rmtree(snapshot)
```

## 復元手順

### Gitチェックポイントからの復元

```bash
# 最新のチェックポイントを確認
cat .cleanup_checkpoint.json

# チェックポイントに戻る
git reset --hard <checkpoint_hash>

# 未追跡ファイルも削除（オプション）
git clean -fd
```

### ファイルアーカイブからの復元

```bash
# アーカイブ一覧
ls -lh .cleanup_archive_*.tar.gz

# アーカイブ内容を確認
tar -tzf .cleanup_archive_<timestamp>.tar.gz

# 特定ファイルを復元
tar -xzf .cleanup_archive_<timestamp>.tar.gz path/to/file

# 全ファイルを復元
tar -xzf .cleanup_archive_<timestamp>.tar.gz
```

### 部分復元

```python
def restore_specific_files(archive_path, files_to_restore):
    """アーカイブから特定ファイルのみ復元"""

    import tarfile

    with tarfile.open(archive_path, "r:gz") as tar:
        for file_path in files_to_restore:
            try:
                tar.extract(file_path)
                print(f"✓ Restored: {file_path}")
            except KeyError:
                print(f"✗ Not found in archive: {file_path}")
```

## .cleanupignore ファイル仕様

### 構文

```gitignore
# コメント（#で始まる行）

# パターン（Gitignore形式）
*.backup
temp/**
logs/debug/*.log

# 否定パターン（!で始まる）
!important.backup

# ディレクトリ指定（/で終わる）
cache/

# ルートディレクトリ指定（/で始まる）
/root_only.tmp
```

### デフォルト.cleanupignore

```gitignore
# Claude Code
.claude/
.kiro/

# Version Control
.git/
.svn/
.hg/

# Dependencies
node_modules/
vendor/
.venv/
venv/

# Environment
.env
.env.*
!.env.example

# Configuration
config/secrets/
secrets/

# Build Output
dist/
build/
out/

# Documentation
README.md
CHANGELOG.md
LICENSE
CONTRIBUTING.md
```

### カスタム除外パターン

プロジェクト固有の除外パターンを追加:

```gitignore
# Project-specific temporary files
.cache/important/
logs/audit/

# Development files to keep
*.dev.js
*.development.ts

# Generated files to preserve
generated/types/
codegen/
```

## ポリシー適用例

### 安全なクリーンアップフロー

```python
def safe_cleanup_flow(cleanup_targets):
    """ポリシーに従った安全なクリーンアップ"""

    # Layer 1: Gitチェックポイント作成
    checkpoint = create_git_checkpoint()
    if not checkpoint:
        print("⚠️  Warning: No git checkpoint created")

    # Layer 2: ファイルアーカイブ作成
    archive = create_file_archive(cleanup_targets)
    print(f"✓ Archive created: {archive['archive']}")

    # ポリシー適用
    level1_targets = []  # 自動削除可
    level2_targets = []  # 要確認
    level3_targets = []  # 削除不可

    for target in cleanup_targets:
        policy = apply_deletion_policy(target)

        if policy["level"] == 1:
            level1_targets.append(target)
        elif policy["level"] == 2:
            level2_targets.append(target)
        else:
            level3_targets.append(target)

    # Level 1: 自動削除
    print(f"\nLevel 1 (Safe): {len(level1_targets)} targets")
    for target in level1_targets:
        safe_remove(target)

    # Level 2: 手動確認
    if level2_targets:
        print(f"\nLevel 2 (Review): {len(level2_targets)} targets")
        for target in level2_targets:
            print(f"  - {target['path']}: {target['reason']}")

        confirm = input("\nProceed with Level 2 deletions? (y/n): ")
        if confirm.lower() == 'y':
            for target in level2_targets:
                safe_remove(target)

    # Level 3: 保護（削除不可）
    if level3_targets:
        print(f"\n⚠️  Level 3 (Protected): {len(level3_targets)} targets skipped")
        for target in level3_targets:
            print(f"  - {target['path']}: {target['reason']}")

    # 古いバックアップを削除
    cleanup_old_backups()

    return {
        "deleted": len(level1_targets) + (len(level2_targets) if confirm.lower() == 'y' else 0),
        "skipped": len(level3_targets),
        "checkpoint": checkpoint,
        "archive": archive
    }
```

## ベストプラクティス

1. **常に3層バックアップ**: Gitチェックポイント + アーカイブ + スナップショット（大規模変更時）
2. **ポリシー遵守**: 削除レベルに応じた適切な処理
3. **段階的実行**: Level 1から順に実行
4. **定期的な確認**: バックアップの健全性を定期確認
5. **ドキュメント化**: .cleanupignoreで明示的に除外ルールを定義
