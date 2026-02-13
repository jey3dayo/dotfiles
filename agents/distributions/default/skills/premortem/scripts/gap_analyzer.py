#!/usr/bin/env python3
"""
Gap Analyzer - Automatic Answer Inference and Gap Detection

Automatically analyzes project files to answer premortem questions
and identifies gaps between current project state and best practices.
"""

import argparse
import json
import re
from dataclasses import dataclass, asdict
from enum import Enum
from pathlib import Path
from typing import List, Dict, Optional, Tuple

try:
    import yaml
    YAML_AVAILABLE = True
except ImportError:
    YAML_AVAILABLE = False
    print("Warning: PyYAML not installed. Using JSON fallback.")


class GapStatus(Enum):
    """Gap analysis status"""
    COVERED = "covered"  # Already addressed in project
    NEEDS_CLARIFICATION = "needs_clarification"  # Partially addressed
    MISSING = "missing"  # Not addressed at all
    NOT_APPLICABLE = "not_applicable"  # Question doesn't apply


@dataclass
class AutoAnswer:
    """Automatically inferred answer from project files"""
    text: str
    confidence: float  # 0.0-1.0
    sources: List[str]  # File paths that contributed to the answer


@dataclass
class Gap:
    """Identified gap in project planning"""
    question_id: str
    question_text: str
    status: GapStatus
    auto_answer: Optional[AutoAnswer]
    coverage: float  # 0.0-1.0, how well the question is addressed
    recommendation: str
    priority: str  # "critical", "high", "medium", "low"


class ProjectFileAnalyzer:
    """Analyzes project files to extract relevant information"""

    def __init__(self):
        self.file_cache: Dict[Path, str] = {}

    def read_file_safe(self, file_path: Path, max_chars: int = 10000) -> Optional[str]:
        """Safely read file with caching"""
        if file_path in self.file_cache:
            return self.file_cache[file_path]

        if not file_path.exists():
            return None

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read(max_chars)
                self.file_cache[file_path] = content
                return content
        except Exception as e:
            print(f"Warning: Failed to read {file_path}: {e}")
            return None

    def find_relevant_files(self, question: Dict) -> List[Path]:
        """Find project files relevant to the question"""
        relevant_files = []

        # Always check these files
        priority_files = [
            Path("README.md"),
            Path("CLAUDE.md"),
            Path(".claude/CLAUDE.md"),
            Path("AGENTS.md"),
        ]

        for file_path in priority_files:
            if file_path.exists():
                relevant_files.append(file_path)

        # Check .kiro/steering/ files
        kiro_steering = Path(".kiro/steering")
        if kiro_steering.exists():
            for md_file in kiro_steering.glob("*.md"):
                relevant_files.append(md_file)

        # Check design files if question relates to architecture
        kiro_design = Path(".kiro/specs")
        if kiro_design.exists():
            for md_file in kiro_design.glob("**/design.md"):
                relevant_files.append(md_file)

        # Check package files for tech stack info
        package_files = [
            Path("package.json"),
            Path("requirements.txt"),
            Path("Cargo.toml"),
            Path("go.mod"),
        ]
        for file_path in package_files:
            if file_path.exists():
                relevant_files.append(file_path)

        return relevant_files

    def extract_relevant_content(
        self,
        file_path: Path,
        question: Dict
    ) -> Optional[Tuple[str, float]]:
        """
        Extract content relevant to the question

        Returns:
            (relevant_content, relevance_score) or None
        """
        content = self.read_file_safe(file_path)
        if not content:
            return None

        # Extract keywords from question
        question_text = question.get("text", "").lower()
        triggers = [t.lower() for t in question.get("triggers", [])]
        keywords = triggers + question_text.split()[:10]

        # Calculate relevance score
        content_lower = content.lower()
        matches = sum(1 for kw in keywords if kw in content_lower)
        relevance_score = min(matches / len(keywords), 1.0) if keywords else 0.0

        if relevance_score < 0.2:
            return None

        # Extract relevant paragraphs
        relevant_paragraphs = []
        paragraphs = content.split('\n\n')

        for para in paragraphs:
            para_lower = para.lower()
            if any(kw in para_lower for kw in keywords[:5]):  # Top 5 keywords
                relevant_paragraphs.append(para.strip())

        if relevant_paragraphs:
            return ('\n\n'.join(relevant_paragraphs[:5]), relevance_score)

        return None


class GapAnalyzer:
    """Main gap analysis engine"""

    def __init__(self):
        self.file_analyzer = ProjectFileAnalyzer()

    def infer_answer(
        self,
        question: Dict,
        project_files: List[Path]
    ) -> AutoAnswer:
        """
        Automatically infer answer from project files

        Args:
            question: Question dict with text, triggers, etc.
            project_files: List of relevant project files

        Returns:
            AutoAnswer with inferred text and confidence
        """
        answer_parts = []
        sources = []
        total_confidence = 0.0

        for file_path in project_files:
            result = self.file_analyzer.extract_relevant_content(file_path, question)
            if result:
                content, relevance = result
                answer_parts.append(f"From {file_path.name}:\n{content}")
                sources.append(str(file_path))
                total_confidence += relevance

        if not answer_parts:
            return AutoAnswer(
                text="No relevant information found in project files.",
                confidence=0.0,
                sources=[]
            )

        # Average confidence across sources
        avg_confidence = total_confidence / len(answer_parts) if answer_parts else 0.0

        answer_text = "\n\n---\n\n".join(answer_parts)

        return AutoAnswer(
            text=answer_text,
            confidence=min(avg_confidence, 1.0),
            sources=sources
        )

    def calculate_coverage(
        self,
        question: Dict,
        auto_answer: AutoAnswer
    ) -> float:
        """
        Calculate how well the question is covered (0.0-1.0)

        Factors:
        - Confidence of auto answer
        - Number of sources
        - Content length
        """
        if auto_answer.confidence == 0.0:
            return 0.0

        # Base coverage from confidence
        coverage = auto_answer.confidence * 0.6

        # Bonus for multiple sources
        source_bonus = min(len(auto_answer.sources) * 0.1, 0.2)
        coverage += source_bonus

        # Bonus for substantial content
        word_count = len(auto_answer.text.split())
        content_bonus = min(word_count / 500, 0.2)
        coverage += content_bonus

        return min(coverage, 1.0)

    def classify_gap(
        self,
        question: Dict,
        auto_answer: AutoAnswer,
        coverage: float
    ) -> GapStatus:
        """Classify gap based on coverage and confidence"""

        if coverage > 0.8 and auto_answer.confidence > 0.7:
            return GapStatus.COVERED
        elif coverage > 0.5:
            return GapStatus.NEEDS_CLARIFICATION
        elif coverage < 0.2:
            return GapStatus.MISSING
        else:
            # Check if question might not apply
            na_indicators = ["n/a", "not applicable", "doesn't apply"]
            answer_lower = auto_answer.text.lower()
            if any(ind in answer_lower for ind in na_indicators):
                return GapStatus.NOT_APPLICABLE
            return GapStatus.MISSING

    def generate_recommendation(
        self,
        question: Dict,
        gap_status: GapStatus,
        auto_answer: AutoAnswer
    ) -> str:
        """Generate actionable recommendation"""

        question_text = question.get("text", "")
        priority = question.get("priority", "medium")

        if gap_status == GapStatus.COVERED:
            return (
                f"✅ This aspect is well-documented. "
                f"Review {', '.join(auto_answer.sources)} to ensure alignment."
            )

        elif gap_status == GapStatus.NEEDS_CLARIFICATION:
            return (
                f"⚠️ Partial coverage found. Consider:\n"
                f"1. Review existing documentation: {', '.join(auto_answer.sources)}\n"
                f"2. Fill gaps in: {question_text}\n"
                f"3. Add to design document or steering files"
            )

        elif gap_status == GapStatus.MISSING:
            if priority == "critical":
                return (
                    f"🔴 CRITICAL: Address immediately before implementation:\n"
                    f"1. Research best practices for: {question_text}\n"
                    f"2. Document decisions in .kiro/steering/ or design files\n"
                    f"3. Consider creating a GitHub Issue to track"
                )
            else:
                return (
                    f"📝 TODO: Document this in planning phase:\n"
                    f"1. {question_text}\n"
                    f"2. Add to .kiro/steering/ or create Issue"
                )

        else:  # NOT_APPLICABLE
            return (
                f"ℹ️ This question may not apply to your project. "
                f"Verify and mark as not applicable if confirmed."
            )

    def analyze_gap(
        self,
        question: Dict,
        project_files: List[Path]
    ) -> Gap:
        """
        Perform complete gap analysis for a question

        Args:
            question: Question dict
            project_files: List of relevant project files

        Returns:
            Gap analysis result
        """
        # Step 1: Infer answer from project files
        auto_answer = self.infer_answer(question, project_files)

        # Step 2: Calculate coverage
        coverage = self.calculate_coverage(question, auto_answer)

        # Step 3: Classify gap
        gap_status = self.classify_gap(question, auto_answer, coverage)

        # Step 4: Generate recommendation
        recommendation = self.generate_recommendation(
            question, gap_status, auto_answer
        )

        return Gap(
            question_id=question.get("id", "UNKNOWN"),
            question_text=question.get("text", ""),
            status=gap_status,
            auto_answer=auto_answer if auto_answer.confidence > 0 else None,
            coverage=coverage,
            recommendation=recommendation,
            priority=question.get("priority", "medium")
        )

    def analyze_all_questions(
        self,
        questions: List[Dict],
        project_root: Path = Path(".")
    ) -> List[Gap]:
        """
        Analyze all questions and return gaps

        Args:
            questions: List of question dicts
            project_root: Root directory of project

        Returns:
            List of Gap objects
        """
        gaps = []

        for question in questions:
            # Find relevant files for this question
            relevant_files = self.file_analyzer.find_relevant_files(question)

            # Perform gap analysis
            gap = self.analyze_gap(question, relevant_files)
            gaps.append(gap)

        return gaps


def main():
    parser = argparse.ArgumentParser(
        description="Analyze gaps between project state and premortem questions"
    )
    parser.add_argument(
        "--questions",
        required=True,
        help="JSON file with selected questions"
    )
    parser.add_argument(
        "--output",
        help="Output file path (JSON)"
    )
    parser.add_argument(
        "--project-root",
        default=".",
        help="Project root directory"
    )

    args = parser.parse_args()

    # Load questions
    with open(args.questions) as f:
        data = json.load(f)
        questions = data.get("selected_questions", [])

    # Perform gap analysis
    analyzer = GapAnalyzer()
    gaps = analyzer.analyze_all_questions(
        questions,
        Path(args.project_root)
    )

    # Convert to dict for JSON serialization
    result = {
        "gaps": [
            {
                **asdict(gap),
                "status": gap.status.value,
                "auto_answer": asdict(gap.auto_answer) if gap.auto_answer else None
            }
            for gap in gaps
        ],
        "summary": {
            "total": len(gaps),
            "covered": sum(1 for g in gaps if g.status == GapStatus.COVERED),
            "needs_clarification": sum(
                1 for g in gaps if g.status == GapStatus.NEEDS_CLARIFICATION
            ),
            "missing": sum(1 for g in gaps if g.status == GapStatus.MISSING),
            "not_applicable": sum(
                1 for g in gaps if g.status == GapStatus.NOT_APPLICABLE
            ),
        }
    }

    # Output
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(result, f, indent=2, ensure_ascii=False)
    else:
        print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
