#!/usr/bin/env python3
"""
Context Analysis and Question Generation Engine

Analyzes project context and generates relevant premortem questions.
"""

import argparse
import json
import re
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import List, Dict, Optional

try:
    import yaml

    YAML_AVAILABLE = True
except ImportError:
    YAML_AVAILABLE = False
    print("Warning: PyYAML not installed. Using JSON fallback.")


@dataclass
class ProjectContext:
    """Project context extracted from user input and files"""

    domain: str  # "web-development", "mobile-apps", etc.
    maturity: str  # "poc", "mvp", "production"
    tech_stack: List[str]  # ["React", "Node.js", "PostgreSQL"]
    scale: str  # "small", "medium", "large"
    description: str  # Project description


# Domain detection patterns
DOMAIN_PATTERNS = {
    "web-development": [
        r"\b(react|vue|angular|svelte)\b",
        r"\b(node\.?js|express|fastify|nest\.?js)\b",
        r"\b(django|flask|rails|spring)\b",
        r"\b(api|rest|graphql|http)\b",
        r"\b(web|frontend|backend|fullstack)\b",
    ],
    "mobile-apps": [
        r"\b(ios|swift|swiftui|uikit)\b",
        r"\b(android|kotlin|jetpack)\b",
        r"\b(react[-\s]native|flutter|xamarin)\b",
        r"\b(mobile|app)\b",
    ],
    "data-systems": [
        r"\b(spark|hadoop|flink|kafka)\b",
        r"\b(etl|pipeline|warehouse|lakehouse)\b",
        r"\b(bigquery|redshift|snowflake)\b",
        r"\b(data[-\s]engineering|analytics)\b",
    ],
    "infrastructure": [
        r"\b(kubernetes|k8s|docker|container)\b",
        r"\b(terraform|ansible|cloudformation)\b",
        r"\b(aws|gcp|azure|cloud)\b",
        r"\b(devops|infrastructure|deployment)\b",
    ],
    "security": [
        r"\b(security|encryption|authentication)\b",
        r"\b(oauth|jwt|iam|rbac)\b",
        r"\b(penetration|vulnerability|compliance)\b",
    ],
}

# Maturity detection patterns
MATURITY_PATTERNS = {
    "poc": [r"\b(poc|proof[-\s]of[-\s]concept|prototype|experiment)\b"],
    "mvp": [r"\b(mvp|minimum[-\s]viable|beta|alpha)\b"],
    "production": [r"\b(production|enterprise|scale|mission[-\s]critical)\b"],
}

# Scale detection patterns
SCALE_PATTERNS = {
    "small": [r"\b(\d+\s*users?)\b.*\b([1-9]\d{0,2}|1000)\b", r"\bsmall\b"],
    "medium": [r"\b(\d+k?\s*users?)\b.*\b(1k|10k|100k)\b", r"\bmedium\b"],
    "large": [r"\b(\d+k?\s*users?)\b.*\b([1-9]\d{2}k|million)\b", r"\blarge\b"],
}


def detect_domain(text: str) -> str:
    """Detect project domain from text"""
    text_lower = text.lower()
    scores = {}

    for domain, patterns in DOMAIN_PATTERNS.items():
        score = sum(
            1 for pattern in patterns if re.search(pattern, text_lower, re.IGNORECASE)
        )
        scores[domain] = score

    # Return domain with highest score, default to web-development
    if max(scores.values()) == 0:
        return "web-development"
    return max(scores, key=scores.get)


def detect_maturity(text: str) -> str:
    """Detect project maturity from text"""
    text_lower = text.lower()

    for maturity, patterns in MATURITY_PATTERNS.items():
        if any(re.search(pattern, text_lower, re.IGNORECASE) for pattern in patterns):
            return maturity

    # Default to mvp if no match
    return "mvp"


def detect_scale(text: str) -> str:
    """Detect project scale from text"""
    text_lower = text.lower()

    for scale, patterns in SCALE_PATTERNS.items():
        if any(re.search(pattern, text_lower, re.IGNORECASE) for pattern in patterns):
            return scale

    # Default to medium if no match
    return "medium"


def extract_tech_stack(text: str, files: List[Path]) -> List[str]:
    """Extract technology stack from text and files"""
    tech_stack = set()

    # Common technology patterns
    tech_patterns = {
        "React": r"\breact\b",
        "Vue": r"\bvue\b",
        "Angular": r"\bangular\b",
        "Svelte": r"\bsvelte\b",
        "Node.js": r"\bnode\.?js\b",
        "Express": r"\bexpress\b",
        "Next.js": r"\bnext\.?js\b",
        "Django": r"\bdjango\b",
        "Flask": r"\bflask\b",
        "PostgreSQL": r"\b(postgres|postgresql)\b",
        "MySQL": r"\bmysql\b",
        "MongoDB": r"\bmongo(db)?\b",
        "Redis": r"\bredis\b",
        "Docker": r"\bdocker\b",
        "Kubernetes": r"\b(kubernetes|k8s)\b",
    }

    text_lower = text.lower()
    for tech, pattern in tech_patterns.items():
        if re.search(pattern, text_lower, re.IGNORECASE):
            tech_stack.add(tech)

    # Parse package.json if available
    for file_path in files:
        if file_path.name == "package.json":
            try:
                with open(file_path) as f:
                    pkg = json.load(f)
                    deps = {
                        **pkg.get("dependencies", {}),
                        **pkg.get("devDependencies", {}),
                    }
                    for dep in deps:
                        if "react" in dep.lower():
                            tech_stack.add("React")
                        elif "next" in dep.lower():
                            tech_stack.add("Next.js")
                        elif "express" in dep.lower():
                            tech_stack.add("Express")
            except Exception:
                pass

    return sorted(list(tech_stack))


def infer_project_from_files() -> str:
    """
    Infer project description from common project files

    Searches for and reads (in priority order):
    - README.md
    - CLAUDE.md
    - AGENTS.md
    - .kiro/steering/*.md
    - package.json, requirements.txt, Cargo.toml

    Returns:
        Inferred project description
    """
    description_parts = []

    # Priority 1: README.md
    readme_paths = [Path("README.md"), Path("readme.md")]
    for readme_path in readme_paths:
        if readme_path.exists():
            try:
                with open(readme_path) as f:
                    content = f.read(5000)  # First 5000 chars
                    description_parts.append(f"README: {content}")
                    break
            except Exception:
                pass

    # Priority 2: CLAUDE.md
    claude_paths = [Path("CLAUDE.md"), Path(".claude/CLAUDE.md")]
    for claude_path in claude_paths:
        if claude_path.exists():
            try:
                with open(claude_path) as f:
                    content = f.read(3000)
                    description_parts.append(f"CLAUDE.md: {content}")
                    break
            except Exception:
                pass

    # Priority 3: AGENTS.md
    agents_path = Path("AGENTS.md")
    if agents_path.exists():
        try:
            with open(agents_path) as f:
                content = f.read(2000)
                description_parts.append(f"AGENTS.md: {content}")
        except Exception:
            pass

    # Priority 4: .kiro/steering/*.md
    kiro_steering = Path(".kiro/steering")
    if kiro_steering.exists():
        for md_file in kiro_steering.glob("*.md"):
            try:
                with open(md_file) as f:
                    content = f.read(1000)
                    description_parts.append(f"{md_file.name}: {content}")
            except Exception:
                pass

    if description_parts:
        return "\n\n".join(description_parts)
    else:
        return "General software project"


def analyze_context(
    description: str, files: Optional[List[str]] = None
) -> ProjectContext:
    """
    Analyze project context from description and files

    Args:
        description: Project description text (if empty, auto-infer from files)
        files: List of file paths to analyze (optional)

    Returns:
        ProjectContext object
    """
    # Auto-infer if description is empty
    if not description or description.strip() == "":
        description = infer_project_from_files()

    file_paths = [Path(f) for f in (files or [])] if files else []

    domain = detect_domain(description)
    maturity = detect_maturity(description)
    scale = detect_scale(description)
    tech_stack = extract_tech_stack(description, file_paths)

    return ProjectContext(
        domain=domain,
        maturity=maturity,
        tech_stack=tech_stack,
        scale=scale,
        description=description,
    )


def load_question_pool(domain: str, questions_dir: Path) -> List[Dict]:
    """Load generic + domain-specific question pool"""
    questions = []

    # Load generic questions
    generic_file = questions_dir / "generic.yaml"
    if generic_file.exists():
        if YAML_AVAILABLE:
            with open(generic_file) as f:
                data = yaml.safe_load(f)
                questions.extend(data.get("questions", []))
        else:
            print(f"Warning: Cannot load {generic_file} without PyYAML")

    # Load domain-specific questions
    domain_file = questions_dir / f"{domain}.yaml"
    if domain_file.exists():
        if YAML_AVAILABLE:
            with open(domain_file) as f:
                data = yaml.safe_load(f)
                questions.extend(data.get("questions", []))
        else:
            print(f"Warning: Cannot load {domain_file} without PyYAML")

    return questions


def score_question(question: Dict, context: ProjectContext) -> float:
    """
    Calculate relevance score for a question (0.0-1.0)

    Scoring factors:
    - Trigger keyword match: +0.3
    - Domain fit: +0.2
    - Maturity fit: +0.2
    - Tech stack match: +0.3
    """
    score = 0.0
    description_lower = context.description.lower()

    # Trigger keyword check
    triggers = question.get("triggers", [])
    if any(trigger.lower() in description_lower for trigger in triggers):
        score += 0.3

    # Domain fit
    relevance_boost = question.get("relevance_boost", {})
    if context.domain in relevance_boost.get("domains", []):
        score += 0.2

    # Maturity fit
    if context.maturity in relevance_boost.get("maturity", []):
        score += 0.2

    # Tech stack match
    question_text_lower = question.get("text", "").lower()
    if any(tech.lower() in question_text_lower for tech in context.tech_stack):
        score += 0.3

    return min(score, 1.0)


def select_top_questions(
    questions: List[Dict],
    context: ProjectContext,
    min_count: int = 3,
    max_count: int = 5,
    min_score: float = 0.5,
) -> List[Dict]:
    """
    Select top questions based on relevance score

    Args:
        questions: Pool of all questions
        context: Project context
        min_count: Minimum number of questions to select
        max_count: Maximum number of questions to select
        min_score: Minimum score threshold (0.0-1.0)

    Returns:
        List of selected questions with scores
    """
    # Calculate scores
    scored = [{**q, "score": score_question(q, context)} for q in questions]

    # Sort by score descending, then by priority
    priority_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
    sorted_questions = sorted(
        scored,
        key=lambda x: (-x["score"], priority_order.get(x.get("priority", "medium"), 2)),
    )

    # Filter by minimum score
    filtered = [q for q in sorted_questions if q["score"] >= min_score]

    # Select top questions
    if len(filtered) >= min_count:
        return filtered[:max_count]
    else:
        # If not enough high-score questions, include lower-scoring ones
        return sorted_questions[:min_count]


def main():
    parser = argparse.ArgumentParser(
        description="Analyze project context and generate questions"
    )
    parser.add_argument(
        "--input",
        default="",
        help="Project description (if empty, auto-infer from files)",
    )
    parser.add_argument("--files", help="Comma-separated list of files to analyze")
    parser.add_argument("--output", help="Output file path (JSON)")
    parser.add_argument(
        "--questions-dir", help="Directory containing question YAML files"
    )
    parser.add_argument(
        "--min-questions", type=int, default=3, help="Minimum questions"
    )
    parser.add_argument(
        "--max-questions", type=int, default=5, help="Maximum questions"
    )

    args = parser.parse_args()

    # Parse files
    files = args.files.split(",") if args.files else []

    # Analyze context
    context = analyze_context(args.input, files if files else None)

    # Load and select questions
    result = asdict(context)

    if args.questions_dir:
        questions_dir = Path(args.questions_dir)
        if questions_dir.exists():
            all_questions = load_question_pool(context.domain, questions_dir)
            selected = select_top_questions(
                all_questions,
                context,
                min_count=args.min_questions,
                max_count=args.max_questions,
            )
            result["selected_questions"] = selected

    # Output
    if args.output:
        with open(args.output, "w") as f:
            json.dump(result, f, indent=2, ensure_ascii=False)
    else:
        print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
