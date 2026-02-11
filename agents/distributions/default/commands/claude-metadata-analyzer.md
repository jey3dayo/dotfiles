# Claude Metadata Analyzer - メタデータ分析エンジン

`/maintain-claude`コマンドで使用する共有ライブラリです。~/.claude/配下のファイルをスキャンし、メタデータを抽出・分析します。

## 🎯 主要機能

### 1. ファイルスキャン

agents, skills, commandsの全ファイルをスキャンします。

### 2. メタデータ抽出

YAMLフロントマターとドキュメント構造を解析します。

### 3. 関連性グラフ構築

Agent-Skill-Command間の参照関係を可視化します。

### 4. 問題検出

孤立ファイル、重複、メタデータエラーを検出します。

## 📋 使用方法

```typescript
import { analyzeClaudeDirectory } from "./shared/claude-metadata-analyzer";

const analysis = await analyzeClaudeDirectory({
  agentsOnly: false,
  skillsOnly: false,
  metadataOnly: false,
});

console.log(analysis.summary);
console.log(analysis.issues);
console.log(analysis.proposedChanges);
```

## 🔧 実装詳細

### Phase 1: ファイルスキャン

**目的**: agents, skills, commandsの全ファイルを収集

```python
def scan_claude_directory():
    """~/.claude/配下のファイルをスキャン"""

    # 1. Agentsスキャン
    agents_files = glob("~/.claude/agents/*.md")
    print(f"✓ Agents: {len(agents_files)}個のファイルを検出")

    # 2. Skillsスキャン
    skills_dirs = glob("~/.claude/skills/*/")
    skills_files = [
        f"{skill_dir}/SKILL.md"
        for skill_dir in skills_dirs
        if os.path.exists(f"{skill_dir}/SKILL.md")
    ]
    print(f"✓ Skills: {len(skills_files)}個のファイルを検出")

    # 3. Commandsスキャン
    commands_files = glob("~/.claude/commands/*.md")
    # shared/ディレクトリは除外
    commands_files = [
        f for f in commands_files
        if "/shared/" not in f
    ]
    print(f"✓ Commands: {len(commands_files)}個のファイルを検出")

    return {
        "agents": agents_files,
        "skills": skills_files,
        "commands": commands_files,
    }
```

**実装ガイド**:

- Globツールを使用してファイルを検索
- shared/ディレクトリは除外
- 存在しないファイルは無視

### Phase 2: メタデータ抽出

**目的**: YAMLフロントマターとドキュメント構造を解析

```python
def extract_agent_metadata(agent_file):
    """Agentファイルからメタデータを抽出"""

    content = read_file(agent_file)

    # YAMLフロントマター抽出
    frontmatter = extract_yaml_frontmatter(content)

    # システムプロンプト抽出（YAMLブロック後のコンテンツ）
    system_prompt = extract_system_prompt(content)

    # メタデータ構造化
    metadata = {
        "path": agent_file,
        "name": frontmatter.get("name", extract_name_from_path(agent_file)),
        "description": frontmatter.get("description", ""),
        "tools": frontmatter.get("tools", ""),
        "skills": frontmatter.get("skills", "").split(",") if frontmatter.get("skills") else [],
        "color": frontmatter.get("color", ""),
        "systemPrompt": system_prompt,
        "systemPromptLength": len(system_prompt),
        "lastModified": get_file_mtime(agent_file),
    }

    # 検証
    errors = validate_agent_metadata(metadata)
    if errors:
        metadata["errors"] = errors

    return metadata


def extract_skill_metadata(skill_file):
    """SkillファイルからメタデータTを抽出"""

    content = read_file(skill_file)
    frontmatter = extract_yaml_frontmatter(content)

    skill_dir = os.path.dirname(skill_file)

    metadata = {
        "path": skill_file,
        "directory": skill_dir,
        "name": frontmatter.get("name", os.path.basename(skill_dir)),
        "description": frontmatter.get("description", ""),
        "location": frontmatter.get("location", "user"),
        "hasREADME": os.path.exists(f"{skill_dir}/README.md"),
        "lastModified": get_file_mtime(skill_file),
    }

    # 検証
    errors = validate_skill_metadata(metadata)
    if errors:
        metadata["errors"] = errors

    return metadata


def extract_command_metadata(command_file):
    """Commandファイルからメタデータを抽出"""

    content = read_file(command_file)
    frontmatter = extract_yaml_frontmatter(content)

    metadata = {
        "path": command_file,
        "name": extract_name_from_path(command_file),
        "description": frontmatter.get("description", ""),
        "argumentHint": frontmatter.get("argument-hint", ""),
        "lastModified": get_file_mtime(command_file),
    }

    # 検証
    errors = validate_command_metadata(metadata)
    if errors:
        metadata["errors"] = errors

    return metadata


def extract_yaml_frontmatter(content):
    """YAMLフロントマターを抽出"""

    # ---で囲まれた部分を抽出
    match = re.search(r'^---\n(.*?)\n---', content, re.DOTALL | re.MULTILINE)
    if not match:
        return {}

    yaml_content = match.group(1)

    # YAMLパース（エラーハンドリング付き）
    try:
        return yaml.safe_load(yaml_content) or {}
    except yaml.YAMLError as e:
        print(f"⚠️  YAML parse error: {e}")
        return {}


def extract_system_prompt(content):
    """システムプロンプトを抽出（YAMLブロック後）"""

    # YAMLブロック後のコンテンツを取得
    parts = content.split('---', 2)
    if len(parts) >= 3:
        return parts[2].strip()
    return ""
```

**実装ガイド**:

- Readツールでファイル内容を取得
- 正規表現でYAMLフロントマターを抽出
- システムプロンプトはYAMLブロック後のコンテンツ
- エラーハンドリングを適切に実装

### Phase 3: 関連性グラフ構築

**目的**: Agent-Skill-Command間の参照関係を分析

```python
def build_relationship_graph(metadata):
    """関連性グラフを構築"""

    graph = {
        "nodes": {
            "agents": [],
            "skills": [],
            "commands": [],
        },
        "edges": {
            "agent_to_skills": {},    # { agent_name: [skill_names] }
            "skill_to_agents": {},    # { skill_name: [agent_names] }
            "command_to_skills": {},  # { command_name: [skill_names] }
        },
    }

    # 1. ノード追加
    for agent in metadata["agents"]:
        graph["nodes"]["agents"].append(agent["name"])

    for skill in metadata["skills"]:
        graph["nodes"]["skills"].append(skill["name"])

    for command in metadata["commands"]:
        graph["nodes"]["commands"].append(command["name"])

    # 2. Agent→Skillエッジ構築
    for agent in metadata["agents"]:
        agent_name = agent["name"]
        skills = agent.get("skills", [])

        if skills:
            graph["edges"]["agent_to_skills"][agent_name] = skills

            # 逆方向のエッジも構築
            for skill in skills:
                if skill not in graph["edges"]["skill_to_agents"]:
                    graph["edges"]["skill_to_agents"][skill] = []
                graph["edges"]["skill_to_agents"][skill].append(agent_name)

    # 3. Command→Skillエッジ構築（descriptionから推測）
    for command in metadata["commands"]:
        command_name = command["name"]
        description = command["description"].lower()

        # Descriptionにskill名が含まれているか確認
        mentioned_skills = [
            skill["name"]
            for skill in metadata["skills"]
            if skill["name"].lower() in description
        ]

        if mentioned_skills:
            graph["edges"]["command_to_skills"][command_name] = mentioned_skills

    return graph


def analyze_connectivity(graph):
    """接続性を分析"""

    # 孤立ノードの検出
    orphaned_agents = [
        agent
        for agent in graph["nodes"]["agents"]
        if agent not in graph["edges"]["agent_to_skills"]
    ]

    orphaned_skills = [
        skill
        for skill in graph["nodes"]["skills"]
        if skill not in graph["edges"]["skill_to_agents"]
    ]

    # 接続統計
    connectivity_stats = {
        "total_agents": len(graph["nodes"]["agents"]),
        "agents_with_skills": len(graph["edges"]["agent_to_skills"]),
        "agents_without_skills": len(orphaned_agents),
        "total_skills": len(graph["nodes"]["skills"]),
        "referenced_skills": len(graph["edges"]["skill_to_agents"]),
        "unreferenced_skills": len(orphaned_skills),
        "orphaned_agents": orphaned_agents,
        "orphaned_skills": orphaned_skills,
    }

    return connectivity_stats
```

**実装ガイド**:

- Agent→Skillの直接参照を最優先
- Command→Skillはdescription内の言及から推測
- 双方向エッジを構築（逆引きを容易に）
- 孤立ノードを特定

### Phase 4: 問題検出

**目的**: メタデータエラー、孤立ファイル、重複を検出

```python
def detect_issues(metadata, graph):
    """問題を検出"""

    issues = {
        "missing_skills": detect_missing_skills(metadata["agents"], graph),
        "orphaned_files": detect_orphaned_files(metadata, graph),
        "metadata_errors": collect_metadata_errors(metadata),
        "duplicates": detect_duplicates(metadata),
    }

    return issues


def detect_missing_skills(agents, graph):
    """skillsフィールドが未定義のAgentを検出"""

    missing = []

    for agent in agents:
        if not agent.get("skills") or len(agent["skills"]) == 0:
            missing.append({
                "agent": agent["name"],
                "path": agent["path"],
                "reason": "skillsフィールドが未定義または空",
            })

    return missing


def detect_orphaned_files(metadata, graph):
    """孤立ファイルを検出"""

    orphaned = []

    # 孤立Agent（skillsなし + 短いプロンプト + 6ヶ月未更新）
    six_months_ago = datetime.now() - timedelta(days=180)

    for agent in metadata["agents"]:
        is_orphaned = (
            len(agent.get("skills", [])) == 0 and
            agent["systemPromptLength"] < 100 and
            agent["lastModified"] < six_months_ago
        )

        if is_orphaned:
            orphaned.append({
                "type": "agent",
                "name": agent["name"],
                "path": agent["path"],
                "priority": "HIGH",
                "reason": "孤立+空プロンプト+6ヶ月未使用",
                "lastModified": agent["lastModified"].strftime("%Y-%m-%d"),
            })

    # 孤立Skill（どのAgentからも参照されていない）
    connectivity = analyze_connectivity(graph)

    for skill_name in connectivity["orphaned_skills"]:
        skill = next(
            (s for s in metadata["skills"] if s["name"] == skill_name),
            None
        )

        if skill and skill["lastModified"] < six_months_ago:
            orphaned.append({
                "type": "skill",
                "name": skill["name"],
                "path": skill["path"],
                "priority": "MEDIUM",
                "reason": "どのAgentからも参照されていない",
                "lastModified": skill["lastModified"].strftime("%Y-%m-%d"),
            })

    return orphaned


def collect_metadata_errors(metadata):
    """メタデータエラーを収集"""

    all_errors = []

    for agent in metadata["agents"]:
        if "errors" in agent:
            for error in agent["errors"]:
                all_errors.append({
                    "type": "agent",
                    "file": agent["path"],
                    "error": error,
                })

    for skill in metadata["skills"]:
        if "errors" in skill:
            for error in skill["errors"]:
                all_errors.append({
                    "type": "skill",
                    "file": skill["path"],
                    "error": error,
                })

    for command in metadata["commands"]:
        if "errors" in command:
            for error in command["errors"]:
                all_errors.append({
                    "type": "command",
                    "file": command["path"],
                    "error": error,
                })

    return all_errors


def detect_duplicates(metadata):
    """重複ファイルを検出"""

    duplicates = []

    # Agent名の類似度チェック
    agents = metadata["agents"]
    for i, agent1 in enumerate(agents):
        for agent2 in agents[i + 1 :]:
            similarity = calculate_similarity(
                agent1["name"],
                agent2["name"]
            )

            if similarity > 0.8:  # 80%以上の類似度
                duplicates.append({
                    "type": "agent",
                    "file1": agent1["path"],
                    "file2": agent2["path"],
                    "similarity": similarity,
                    "reason": f"名前の類似度: {similarity * 100:.0f}%",
                })

    # Skill名の類似度チェック（同様）
    # ...

    return duplicates


def calculate_similarity(str1, str2):
    """文字列の類似度を計算（Levenshtein距離ベース）"""

    # 簡易実装: 共通部分文字列の割合
    common = set(str1.lower()) & set(str2.lower())
    total = set(str1.lower()) | set(str2.lower())

    if len(total) == 0:
        return 0.0

    return len(common) / len(total)
```

**実装ガイド**:

- 孤立ファイル: 複数条件の組み合わせで判定
- メタデータエラー: 各Phase 2で検出したエラーを収集
- 重複: 名前の類似度と説明文の類似度を計算
- 優先度: HIGH/MEDIUM/LOWで分類

### Phase 5: 検証ルール

**目的**: メタデータの妥当性を検証

```python
def validate_agent_metadata(metadata):
    """Agentメタデータを検証"""

    errors = []

    # 必須フィールド
    if not metadata["name"]:
        errors.append("nameが未定義")
    elif not re.match(r'^[a-z0-9-]+$', metadata["name"]):
        errors.append("nameがkebab-case形式ではない")

    if not metadata["description"]:
        errors.append("descriptionが未定義")
    elif len(metadata["description"]) < 20:
        errors.append(f"descriptionが短すぎる（{len(metadata['description'])}文字）")

    if metadata["systemPromptLength"] < 100:
        errors.append(f"systemPromptが短すぎる（{metadata['systemPromptLength']}文字）")

    # オプションフィールド
    if metadata.get("skills"):
        # 参照先Skillの存在確認は後で実施
        pass

    return errors


def validate_skill_metadata(metadata):
    """Skillメタデータを検証"""

    errors = []

    if not metadata["name"]:
        errors.append("nameが未定義")

    if not metadata["description"]:
        errors.append("descriptionが未定義")
    elif len(metadata["description"]) < 50:
        errors.append(f"descriptionが短すぎる（{len(metadata['description'])}文字）")

    if metadata["location"] not in ["user", "project"]:
        errors.append(f"locationが不正な値: {metadata['location']}")

    if not metadata.get("hasREADME"):
        # 警告レベル
        pass

    return errors


def validate_command_metadata(metadata):
    """Commandメタデータを検証"""

    errors = []

    if not metadata["description"]:
        errors.append("descriptionが未定義")
    elif len(metadata["description"]) < 30:
        errors.append(f"descriptionが短すぎる（{len(metadata['description'])}文字）")

    return errors


def validate_references(metadata, graph):
    """参照整合性を検証"""

    broken_references = []

    available_skills = [skill["name"] for skill in metadata["skills"]]

    for agent in metadata["agents"]:
        for skill in agent.get("skills", []):
            if skill not in available_skills:
                broken_references.append({
                    "agent": agent["name"],
                    "broken_skill_reference": skill,
                    "error": f"Skill '{skill}' が存在しない",
                })

    return broken_references
```

**実装ガイド**:

- 必須フィールドの存在確認
- 文字数制限のチェック
- 命名規則の検証（kebab-case）
- 参照整合性の確認

## 📊 出力形式

```typescript
interface AnalysisResult {
  summary: {
    agents: number;
    skills: number;
    commands: number;
    agentsWithSkills: number;
    agentsWithoutSkills: number;
  };

  issues: {
    missingSkills: Array<{
      agent: string;
      path: string;
      reason: string;
    }>;

    orphanedFiles: Array<{
      type: "agent" | "skill" | "command";
      name: string;
      path: string;
      priority: "HIGH" | "MEDIUM" | "LOW";
      reason: string;
      lastModified: string;
    }>;

    metadataErrors: Array<{
      type: "agent" | "skill" | "command";
      file: string;
      error: string;
    }>;

    duplicates: Array<{
      type: "agent" | "skill" | "command";
      file1: string;
      file2: string;
      similarity: number;
      reason: string;
    }>;
  };

  metadata: {
    agents: AgentMetadata[];
    skills: SkillMetadata[];
    commands: CommandMetadata[];
  };

  graph: RelationshipGraph;
}
```

## 🛠️ 実装Tips

### Globツールの使用

```bash
# Agentsスキャン
glob "~/.claude/agents/*.md"

# Skillsスキャン（SKILL.mdのみ）
glob "~/.claude/skills/*/SKILL.md"

# Commandsスキャン（sharedを除外）
glob "~/.claude/commands/*.md" | grep -v "/shared/"
```

### Grepツールの使用

```bash
# skillsフィールドを持つAgentを検索
grep "^skills:" ~/.claude/agents/*.md

# deprecatedマークがあるファイルを検索
grep -i "deprecated" ~/.claude/**/*.md
```

### 並列処理

```typescript
// 並列でメタデータ抽出
const [agentMetadata, skillMetadata, commandMetadata] = await Promise.all([
  extractAllAgents(agentsFiles),
  extractAllSkills(skillsFiles),
  extractAllCommands(commandsFiles),
]);
```

## 参考実装

- `/fix-docs` - ファイルスキャンと検証パターン
- `/skill-up` - メタデータ抽出と分類ロジック
- `docs-manager` skill - メタデータ検証ルール
