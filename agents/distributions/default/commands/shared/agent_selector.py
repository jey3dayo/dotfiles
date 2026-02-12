"""
Agent selection utilities.

Provides intelligent agent selection based on task type:
- researcher: Investigation and analysis
- orchestrator: Implementation and modification
- error-fixer: Error detection and fixes
- code-reviewer: Code quality review
- serena: Semantic code analysis
"""

from dataclasses import asdict, dataclass
from typing import Dict, List, Optional, Any, Iterable
from enum import Enum


class AgentType(Enum):
    """Available agent types."""

    RESEARCHER = "researcher"
    ORCHESTRATOR = "orchestrator"
    ERROR_FIXER = "error-fixer"
    CODE_REVIEWER = "code-reviewer"
    SERENA = "serena"
    EXPLORE = "Explore"


class TaskType(Enum):
    """Task classification."""

    INVESTIGATION = "investigation"
    IMPLEMENTATION = "implementation"
    ERROR_FIXING = "error_fixing"
    CI_DIAGNOSIS = "ci_diagnosis"
    CODE_REVIEW = "code_review"
    SEMANTIC_ANALYSIS = "semantic_analysis"
    EXPLORATION = "exploration"


@dataclass
class SkillSuggestion:
    """Recommended skill to launch before or with an agent."""

    name: str
    reason: str
    confidence: float
    triggers: List[str]


def detect_relevant_skills(
    task_description: str, context: Optional[Dict[str, Any]] = None
) -> List[SkillSuggestion]:
    """Detect skills that should be launched alongside the selected agent.

    Uses task intent keywords and optional project metadata to recommend
    Skills so agents can preload domain-specific playbooks before executing.
    """
    desc_lower = task_description.lower()
    project_meta = _extract_project_metadata(context)
    suggestions: List[SkillSuggestion] = []

    def add_skill(
        name: str, reason: str, confidence: float, triggers: List[str]
    ) -> None:
        existing = next((s for s in suggestions if s.name == name), None)
        if existing:
            if confidence > existing.confidence:
                existing.confidence = confidence
                existing.reason = reason
                existing.triggers = triggers
            return
        suggestions.append(SkillSuggestion(name, reason, confidence, triggers))

    language = (project_meta.get("language") or "").lower()
    frameworks = [fw.lower() for fw in project_meta.get("frameworks", [])]

    if (
        language == "typescript"
        or "typescript" in desc_lower
        or "tsconfig" in desc_lower
    ):
        add_skill(
            "typescript",
            "TypeScript 型安全性とリンティング指針を適用",
            0.86,
            ["typescript", "tsconfig", "ts"],
        )

    if "react" in frameworks or "nextjs" in frameworks or "react" in desc_lower:
        add_skill(
            "react",
            "React/Next.js のコンポーネント設計と最適化パターンを先読み",
            0.8,
            ["react", "nextjs", "hooks"],
        )

    if language == "go" or "golang" in desc_lower or " go " in desc_lower:
        add_skill(
            "golang",
            "Go のイディオム・エラーハンドリング・並行処理ガイドを適用",
            0.78,
            ["golang", "go", "goroutine"],
        )

    security_keywords = ["security", "auth", "jwt", "csrf", "xss", "認証", "認可"]
    if any(keyword in desc_lower for keyword in security_keywords):
        add_skill(
            "security",
            "認証/認可・入力検証などのセキュリティ強化を組み込む",
            0.74,
            security_keywords,
        )

    if any(
        keyword in desc_lower
        for keyword in ["clean architecture", "usecase", "use case", "domain", "境界"]
    ):
        add_skill(
            "clean-architecture",
            "レイヤリングと依存方向の制約をチェック",
            0.68,
            ["clean architecture", "usecase", "domain"],
        )

    if any(
        keyword in desc_lower
        for keyword in ["impact", "dependency", "refactor", "breaking", "影響", "依存"]
    ):
        add_skill(
            "semantic-analysis",
            "依存関係・影響範囲を解析して安全な変更計画を作成",
            0.7,
            ["impact", "dependency", "refactor", "breaking"],
        )

    if any(
        keyword in desc_lower
        for keyword in ["lint", "quality", "format", "readability", "可読性"]
    ):
        add_skill(
            "code-quality-improvement",
            "品質改善パターンと自動修正の指針を適用",
            0.62,
            ["lint", "quality", "format"],
        )

    ci_keywords = [
        "ci failure",
        "ci failed",
        "ci diagnostic",
        "ci diagnosis",
        "ci失敗",
        "ci診断",
        "github actions",
        "workflow failure",
        "workflow failed",
        "failing checks",
        "check failed",
    ]
    if any(keyword in desc_lower for keyword in ci_keywords):
        add_skill("ci-diagnostics", "CI失敗の診断と修正計画を作成", 0.72, ci_keywords)
        add_skill("gh-fix-ci", "gh CLIでCI失敗ログを収集・解析", 0.68, ci_keywords)

    if any(
        keyword in desc_lower
        for keyword in ["doc", "docs", "markdown", "documentation", "readme"]
    ):
        add_skill(
            "markdown-docs",
            "Markdown 構造・リンク・フォーマットの改善を下支え",
            0.58,
            ["docs", "markdown", "documentation"],
        )

    tools = [tool.lower() for tool in project_meta.get("tools", [])]
    if "eslint" in tools or "prettier" in tools:
        add_skill(
            "code-quality-improvement",
            "既存のLint/Format 設定に沿った修正を提案",
            0.64,
            ["eslint", "prettier"],
        )

    return sorted(suggestions, key=lambda s: s.confidence, reverse=True)


def _extract_project_metadata(context: Optional[Dict[str, Any]]) -> Dict[str, Any]:
    """Pull project metadata from various context shapes."""
    metadata: Dict[str, Any] = {"language": None, "frameworks": [], "tools": []}

    if not context:
        return metadata

    def _coerce_list(value: Any) -> List[str]:
        if not value:
            return []
        if isinstance(value, str):
            return [value]
        if isinstance(value, Iterable) and not isinstance(value, (str, bytes)):
            return [str(v) for v in value]
        return [str(value)]

    def _pull(source: Any, key: str) -> Any:
        if source is None:
            return None
        if isinstance(source, dict):
            return source.get(key)
        return getattr(source, key, None)

    possible_sources: List[Any] = []
    if isinstance(context, dict):
        possible_sources.extend(
            [
                context.get("project_info"),
                context.get("project"),
                context.get("projectInfo"),
            ]
        )
    else:
        for attr in ("project_info", "project", "projectInfo"):
            if hasattr(context, attr):
                possible_sources.append(getattr(context, attr))

    for source in possible_sources:
        if not source:
            continue

        language = (
            _pull(source, "language")
            or _pull(source, "lang")
            or _pull(source, "project_language")
        )
        if language and not metadata["language"]:
            metadata["language"] = language

        metadata["frameworks"].extend(
            _coerce_list(_pull(source, "frameworks") or _pull(source, "stack"))
        )
        metadata["tools"].extend(_coerce_list(_pull(source, "tools")))

    metadata["frameworks"] = list(dict.fromkeys(metadata["frameworks"]))
    metadata["tools"] = list(dict.fromkeys(metadata["tools"]))

    return metadata


def classify_task(
    description: str, context: Optional[Dict[str, Any]] = None
) -> TaskType:
    """
    Classify task type from description.

    Args:
        description: Task description
        context: Additional context

    Returns:
        TaskType enum value
    """
    desc_lower = description.lower()

    # Investigation keywords
    investigation_keywords = [
        "why",
        "analyze",
        "investigate",
        "understand",
        "explore",
        "research",
        "find out",
        "discover",
        "what is",
        "how does",
    ]

    # Implementation keywords
    implementation_keywords = [
        "implement",
        "create",
        "build",
        "add",
        "develop",
        "construct",
        "make",
        "write",
        "code",
        "feature",
    ]

    # Error fixing keywords
    error_keywords = [
        "fix",
        "error",
        "bug",
        "issue",
        "problem",
        "broken",
        "failing",
        "eslint",
        "typescript error",
        "type error",
    ]

    # Code review keywords
    review_keywords = [
        "review",
        "quality",
        "best practice",
        "check",
        "evaluate",
        "assess",
        "audit",
        "verify",
    ]

    # Semantic analysis keywords
    semantic_keywords = [
        "impact",
        "dependency",
        "reference",
        "symbol",
        "api change",
        "breaking change",
        "refactor",
    ]

    # Exploration keywords
    exploration_keywords = [
        "where",
        "structure",
        "codebase",
        "architecture",
        "find files",
        "search for",
        "locate",
        "pattern",
    ]

    # CI diagnostics keywords
    ci_keywords = [
        "ci failure",
        "ci failed",
        "ci diagnose",
        "ci diagnosis",
        "ci失敗",
        "ci診断",
        "github actions",
        "workflow failure",
        "workflow failed",
        "failing checks",
        "check failed",
        "build error",
        "test failure",
    ]

    # Check in priority order
    if any(keyword in desc_lower for keyword in ci_keywords):
        return TaskType.CI_DIAGNOSIS

    if any(keyword in desc_lower for keyword in error_keywords):
        return TaskType.ERROR_FIXING

    if any(keyword in desc_lower for keyword in review_keywords):
        return TaskType.CODE_REVIEW

    if any(keyword in desc_lower for keyword in semantic_keywords):
        return TaskType.SEMANTIC_ANALYSIS

    if any(keyword in desc_lower for keyword in exploration_keywords):
        return TaskType.EXPLORATION

    if any(keyword in desc_lower for keyword in investigation_keywords):
        return TaskType.INVESTIGATION

    if any(keyword in desc_lower for keyword in implementation_keywords):
        return TaskType.IMPLEMENTATION

    # Default to investigation
    return TaskType.INVESTIGATION


def select_agent(
    task_type: TaskType, context: Optional[Dict[str, Any]] = None
) -> AgentType:
    """
    Select optimal agent for task type.

    Args:
        task_type: Type of task
        context: Additional context

    Returns:
        AgentType enum value
    """
    agent_mapping = {
        TaskType.INVESTIGATION: AgentType.RESEARCHER,
        TaskType.IMPLEMENTATION: AgentType.ORCHESTRATOR,
        TaskType.ERROR_FIXING: AgentType.ERROR_FIXER,
        TaskType.CI_DIAGNOSIS: AgentType.ERROR_FIXER,
        TaskType.CODE_REVIEW: AgentType.CODE_REVIEWER,
        TaskType.SEMANTIC_ANALYSIS: AgentType.SERENA,
        TaskType.EXPLORATION: AgentType.EXPLORE,
    }

    agent = agent_mapping.get(task_type, AgentType.RESEARCHER)

    # Context-based overrides
    if context:
        # If semantic analysis is explicitly requested
        if context.get("use_serena"):
            return AgentType.SERENA

        # If quick exploration is needed
        if context.get("quick_explore"):
            return AgentType.EXPLORE

    return agent


def create_agent_prompt(
    task_description: str,
    agent_type: AgentType,
    context: Optional[Dict[str, Any]] = None,
    skills: Optional[List[SkillSuggestion]] = None,
) -> str:
    """
    Create optimized prompt for selected agent.

    Args:
        task_description: Task description
        agent_type: Selected agent
        context: Additional context

    Returns:
        Formatted prompt for agent
    """
    base_context = f"""
Task: {task_description}

{_format_context(context) if context else ""}
"""

    agent_specific = {
        AgentType.RESEARCHER: """
Approach:
1. Use MCP Serena for semantic code understanding
2. Perform targeted searches with Grep
3. Analyze patterns and relationships
4. Provide comprehensive insights

Focus on deep understanding and thorough analysis.
""",
        AgentType.ORCHESTRATOR: """
Approach:
1. Break down task into manageable steps
2. Create implementation plan
3. Execute systematically with validation
4. Track progress with TodoWrite

Ensure quality at each step with type-check, lint, and tests.
""",
        AgentType.ERROR_FIXER: """
Approach:
1. Identify all errors systematically
2. Prioritize by severity and impact
3. Apply fixes with validation
4. Verify no regressions

Run quality gates after each fix. Rollback if tests fail.
""",
        AgentType.CODE_REVIEWER: """
Approach:
1. Analyze code quality comprehensively
2. Check type safety, architecture, security
3. Provide specific, actionable feedback
4. Rate with ⭐️ scale

Focus on practical improvements and best practices.
""",
        AgentType.SERENA: """
Approach:
1. Use semantic analysis tools extensively
2. Trace symbol dependencies and references
3. Analyze impact of changes
4. Provide symbol-level insights

Leverage MCP Serena for deep code understanding.
""",
        AgentType.EXPLORE: """
Approach:
1. Use Glob for file pattern matching
2. Use Grep for content searches
3. Navigate codebase structure efficiently
4. Provide organized findings

Thoroughness level: {thoroughness}
""".format(thoroughness=context.get("thoroughness", "medium") if context else "medium"),
    }

    skills_section = ""
    if skills:
        skill_lines = [
            f"- {skill.name} (信頼度: {skill.confidence:.2f}) — {skill.reason}"
            for skill in skills
        ]
        skills_section = (
            "\nRecommended Skills to launch before/with this agent:\n"
            + "\n".join(skill_lines)
            + "\nLaunch via the Skills system so the agent can use bundled playbooks.\n"
        )

    return base_context + agent_specific.get(agent_type, "") + skills_section


def _format_context(context: Dict[str, Any]) -> str:
    """Format context dictionary for prompt."""
    lines = ["Context:"]

    if "project_type" in context:
        lines.append(f"- Project Type: {context['project_type']}")

    if "language" in context:
        lines.append(f"- Language: {context['language']}")

    if "frameworks" in context:
        lines.append(f"- Frameworks: {', '.join(context['frameworks'])}")

    if "focus_areas" in context:
        lines.append(f"- Focus Areas: {', '.join(context['focus_areas'])}")

    if "constraints" in context:
        lines.append(f"- Constraints: {context['constraints']}")

    return "\n".join(lines)


def select_optimal_agent(
    task_description: str, context: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """
    Select optimal agent and create prompt.

    Args:
        task_description: Task description
        context: Additional context

    Returns:
        Dictionary with agent_type, task_type, prompt, and skills
    """
    task_type = classify_task(task_description, context)
    agent_type = select_agent(task_type, context)
    skills = detect_relevant_skills(task_description, context)
    prompt = create_agent_prompt(task_description, agent_type, context, skills)

    return {
        "agent_type": agent_type.value,
        "task_type": task_type.value,
        "prompt": prompt,
        "skills": [asdict(skill) for skill in skills],
    }
