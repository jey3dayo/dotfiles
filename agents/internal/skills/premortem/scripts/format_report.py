#!/usr/bin/env python3
"""
Report Formatter

Formats premortem analysis results into actionable reports.
"""

import argparse
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict

try:
    import yaml

    YAML_AVAILABLE = True
except ImportError:
    YAML_AVAILABLE = False


def format_report(session_data: Dict, output_format: str = "markdown") -> str:
    """
    Format premortem session into a report

    Args:
        session_data: Session data with context, questions, and responses
        output_format: Output format ("markdown" or "json")

    Returns:
        Formatted report string
    """
    if output_format == "json":
        return json.dumps(session_data, indent=2, ensure_ascii=False)

    # Markdown format
    report_lines = []

    # Header
    report_lines.append("# Premortem Analysis Report")
    report_lines.append("")
    report_lines.append(
        f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    )
    report_lines.append("")

    # Executive Summary (if gap analysis available)
    gap_summary = session_data.get("gap_summary", {})
    if gap_summary:
        report_lines.append("## Executive Summary")
        report_lines.append("")
        total = gap_summary.get("total", 0)
        covered = gap_summary.get("covered", 0)
        needs_clarification = gap_summary.get("needs_clarification", 0)
        missing = gap_summary.get("missing", 0)

        report_lines.append(f"**Total Questions Analyzed**: {total}")
        report_lines.append(f"- ✅ Already Covered: {covered}")
        report_lines.append(f"- ⚠️ Needs Clarification: {needs_clarification}")
        report_lines.append(f"- 🔴 Missing/Not Addressed: {missing}")
        report_lines.append("")

        # Coverage percentage
        if total > 0:
            coverage_pct = (covered / total) * 100
            report_lines.append(f"**Overall Coverage**: {coverage_pct:.1f}%")
            report_lines.append("")

    # Project Context
    context = session_data.get("context", {})
    report_lines.append("## Project Context")
    report_lines.append("")
    report_lines.append(f"- **Domain**: {context.get('domain', 'N/A')}")
    report_lines.append(f"- **Maturity**: {context.get('maturity', 'N/A')}")
    report_lines.append(f"- **Scale**: {context.get('scale', 'N/A')}")
    report_lines.append(f"- **Tech Stack**: {', '.join(context.get('tech_stack', []))}")
    report_lines.append("")
    report_lines.append(f"**Description**: {context.get('description', 'N/A')}")
    report_lines.append("")

    # Findings - support both old and new formats
    gaps = session_data.get("gaps", [])
    findings = session_data.get("findings", [])

    # Convert gaps to findings format if gaps exist
    if gaps and not findings:
        findings = convert_gaps_to_findings(gaps)

    critical = [f for f in findings if f.get("risk_level") == "critical"]
    medium = [f for f in findings if f.get("risk_level") == "medium"]
    low = [f for f in findings if f.get("risk_level") == "low"]
    covered = [f for f in findings if f.get("risk_level") == "covered"]

    # Critical Issues
    if critical:
        report_lines.append("## Critical Issues (🔴)")
        report_lines.append("")
        for i, finding in enumerate(critical, 1):
            report_lines.append(f"### {i}. {finding.get('title', 'Untitled')}")
            report_lines.append("")
            report_lines.append(finding.get("description", ""))
            report_lines.append("")
            if finding.get("recommendation"):
                report_lines.append(f"**推奨対応**: {finding['recommendation']}")
                report_lines.append("")

    # Medium Issues
    if medium:
        report_lines.append("## Medium Issues (🟡)")
        report_lines.append("")
        for i, finding in enumerate(medium, 1):
            report_lines.append(f"### {i}. {finding.get('title', 'Untitled')}")
            report_lines.append("")
            report_lines.append(finding.get("description", ""))
            report_lines.append("")
            if finding.get("recommendation"):
                report_lines.append(f"**推奨対応**: {finding['recommendation']}")
                report_lines.append("")

    # Low Issues
    if low:
        report_lines.append("## Low Priority Issues (🟢)")
        report_lines.append("")
        for i, finding in enumerate(low, 1):
            report_lines.append(f"### {i}. {finding.get('title', 'Untitled')}")
            report_lines.append("")
            report_lines.append(finding.get("description", ""))
            report_lines.append("")

    # Already Covered
    if covered:
        report_lines.append("## Already Covered (✅)")
        report_lines.append("")
        for item in covered:
            report_lines.append(f"- {item.get('title', 'Untitled')}")
        report_lines.append("")

    # Action Items
    action_items = session_data.get("action_items", [])
    if action_items:
        report_lines.append("## Recommended Actions")
        report_lines.append("")
        for i, action in enumerate(action_items, 1):
            report_lines.append(
                f"{i}. **{action.get('title', 'Untitled')}** ({action.get('priority', 'medium')} priority)"
            )
            report_lines.append(f"   - {action.get('description', '')}")
            if action.get("resources"):
                report_lines.append(f"   - Resources: {', '.join(action['resources'])}")
            report_lines.append("")

    # Next Steps
    report_lines.append("## Next Steps")
    report_lines.append("")
    report_lines.append(
        "1. 優先度の高いCritical/Medium Issuesから対応を開始してください"
    )
    report_lines.append("2. 設計ドキュメントに発見された盲点を反映してください")
    report_lines.append("3. 実装開始前に再度このレポートを確認してください")
    report_lines.append("")

    return "\n".join(report_lines)


def convert_gaps_to_findings(gaps: List[Dict]) -> List[Dict]:
    """
    Convert gap analysis results to findings format

    Args:
        gaps: List of gap dicts from gap_analyzer

    Returns:
        List of findings compatible with old format
    """
    findings = []

    for gap in gaps:
        status = gap.get("status", "missing")
        priority = gap.get("priority", "medium")

        # Map status to risk_level
        if status == "covered":
            risk_level = "covered"
        elif status == "needs_clarification":
            risk_level = "medium"
        elif status == "missing":
            risk_level = "critical" if priority == "critical" else "high"
        else:  # not_applicable
            continue  # Skip non-applicable questions

        auto_answer = gap.get("auto_answer", {})
        sources = auto_answer.get("sources", []) if auto_answer else []

        finding = {
            "title": gap.get("question_id", "Unknown"),
            "description": gap.get("question_text", ""),
            "risk_level": risk_level,
            "recommendation": gap.get("recommendation", ""),
            "coverage": gap.get("coverage", 0.0),
            "sources": sources,
        }

        # Add auto answer if available
        if auto_answer and auto_answer.get("text"):
            finding["auto_answer"] = auto_answer.get("text")
            finding["confidence"] = auto_answer.get("confidence", 0.0)

        findings.append(finding)

    return findings


def categorize_findings(questions_and_responses: List[Dict]) -> List[Dict]:
    """
    Categorize findings by risk level

    Args:
        questions_and_responses: List of questions with user responses

    Returns:
        List of findings with risk levels
    """
    findings = []

    for item in questions_and_responses:
        question = item.get("question", {})
        response = item.get("response", "")

        # Simple heuristic: if response is empty or contains "わからない", it's a risk
        is_unknown = (
            not response
            or "わからない" in response.lower()
            or "不明" in response.lower()
        )

        if is_unknown:
            risk_level = question.get("priority", "medium")
            if risk_level == "high":
                risk_level = "critical"

            findings.append(
                {
                    "title": question.get("id", "Unknown"),
                    "description": question.get("text", ""),
                    "risk_level": risk_level,
                    "recommendation": "この項目について検討が必要です",
                }
            )
        else:
            # Already covered
            findings.append(
                {"title": question.get("id", "Unknown"), "risk_level": "covered"}
            )

    return findings


def main():
    parser = argparse.ArgumentParser(description="Format premortem report")
    parser.add_argument("--session", required=True, help="Session file (YAML or JSON)")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--format", choices=["markdown", "json"], default="markdown")

    args = parser.parse_args()

    # Load session data
    session_path = Path(args.session)
    if not session_path.exists():
        print(f"Error: Session file not found: {args.session}")
        return

    with open(session_path) as f:
        if session_path.suffix == ".yaml" and YAML_AVAILABLE:
            session_data = yaml.safe_load(f)
        else:
            session_data = json.load(f)

    # Categorize findings if not already done
    if "findings" not in session_data and "questions_and_responses" in session_data:
        session_data["findings"] = categorize_findings(
            session_data["questions_and_responses"]
        )

    # Format report
    report = format_report(session_data, args.format)

    # Output
    if args.output:
        with open(args.output, "w") as f:
            f.write(report)
        print(f"Report written to: {args.output}")
    else:
        print(report)


if __name__ == "__main__":
    main()
