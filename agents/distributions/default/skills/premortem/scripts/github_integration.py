#!/usr/bin/env python3
"""
GitHub Issues Integration for Premortem Analysis

Automatically creates GitHub Issues from discovered gaps with proper labeling
and prioritization.
"""

import argparse
import json
import subprocess
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import List, Dict, Optional


class IssueCreationMode(Enum):
    """Mode for creating issues"""
    ALL = "all"  # Create issues for all gaps
    CRITICAL_HIGH = "critical_high"  # Only critical and high priority
    SELECTIVE = "selective"  # Let user select interactively
    NONE = "none"  # Don't create issues (report only)


@dataclass
class GitHubIssue:
    """GitHub Issue data"""
    title: str
    body: str
    labels: List[str]
    priority: str


class GitHubClient:
    """Client for GitHub CLI (gh) integration"""

    def __init__(self):
        self.available = self._check_gh_available()

    def _check_gh_available(self) -> bool:
        """Check if gh CLI is available and authenticated"""
        try:
            result = subprocess.run(
                ["gh", "auth", "status"],
                capture_output=True,
                text=True,
                timeout=5
            )
            return result.returncode == 0
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False

    def create_issue(self, issue: GitHubIssue) -> Optional[str]:
        """
        Create GitHub Issue using gh CLI

        Args:
            issue: GitHubIssue to create

        Returns:
            Issue URL if successful, None otherwise
        """
        if not self.available:
            print("Error: gh CLI not available or not authenticated")
            return None

        try:
            # Build gh issue create command
            cmd = [
                "gh", "issue", "create",
                "--title", issue.title,
                "--body", issue.body,
            ]

            # Add labels
            for label in issue.labels:
                cmd.extend(["--label", label])

            # Execute command
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                # gh returns the issue URL
                issue_url = result.stdout.strip()
                return issue_url
            else:
                print(f"Error creating issue: {result.stderr}")
                return None

        except subprocess.TimeoutExpired:
            print("Error: Issue creation timed out")
            return None
        except Exception as e:
            print(f"Error creating issue: {e}")
            return None

    def check_existing_issue(self, title: str) -> Optional[str]:
        """
        Check if an issue with similar title already exists

        Args:
            title: Issue title to search for

        Returns:
            Issue URL if found, None otherwise
        """
        if not self.available:
            return None

        try:
            result = subprocess.run(
                ["gh", "issue", "list", "--search", title, "--json", "url,title"],
                capture_output=True,
                text=True,
                timeout=10
            )

            if result.returncode == 0:
                issues = json.loads(result.stdout)
                if issues:
                    # Return first matching issue
                    return issues[0]["url"]

            return None

        except Exception:
            return None


class IssueGenerator:
    """Generates GitHub Issues from gap analysis results"""

    def __init__(self):
        self.gh_client = GitHubClient()

    def format_issue_title(self, gap: Dict) -> str:
        """
        Format issue title from gap

        Args:
            gap: Gap dict

        Returns:
            Formatted title
        """
        question_id = gap.get("question_id", "UNKNOWN")
        priority = gap.get("priority", "medium")
        status = gap.get("status", "missing")

        # Emoji prefix based on priority
        prefix = {
            "critical": "🔴",
            "high": "🟠",
            "medium": "🟡",
            "low": "🟢"
        }.get(priority, "📝")

        # Extract first line of question as short title
        question_text = gap.get("question_text", "")
        first_line = question_text.split('\n')[0][:80]

        return f"{prefix} [Premortem] {first_line}"

    def format_issue_body(self, gap: Dict) -> str:
        """
        Format issue body from gap

        Args:
            gap: Gap dict

        Returns:
            Formatted markdown body
        """
        lines = []

        # Header
        lines.append("# Premortem Analysis: Identified Gap")
        lines.append("")

        # Question
        lines.append("## Question")
        lines.append("")
        lines.append(gap.get("question_text", "N/A"))
        lines.append("")

        # Status and Coverage
        status = gap.get("status", "missing")
        coverage = gap.get("coverage", 0.0)
        lines.append("## Analysis")
        lines.append("")
        lines.append(f"- **Status**: {status}")
        lines.append(f"- **Coverage**: {coverage:.1%}")
        lines.append(f"- **Priority**: {gap.get('priority', 'medium')}")
        lines.append("")

        # Auto Answer (if available)
        auto_answer = gap.get("auto_answer")
        if auto_answer and auto_answer.get("text"):
            lines.append("## Current State (Auto-detected)")
            lines.append("")
            lines.append(auto_answer.get("text"))
            lines.append("")
            lines.append(f"*Confidence: {auto_answer.get('confidence', 0.0):.1%}*")
            lines.append("")

            sources = auto_answer.get("sources", [])
            if sources:
                lines.append("**Sources:**")
                for source in sources:
                    lines.append(f"- `{source}`")
                lines.append("")

        # Recommendation
        lines.append("## Recommended Actions")
        lines.append("")
        lines.append(gap.get("recommendation", "No specific recommendation"))
        lines.append("")

        # Footer
        lines.append("---")
        lines.append("")
        lines.append("*This issue was automatically generated by Premortem Analysis*")

        return "\n".join(lines)

    def determine_labels(self, gap: Dict) -> List[str]:
        """
        Determine GitHub labels for the gap

        Args:
            gap: Gap dict

        Returns:
            List of label names
        """
        labels = ["premortem", "planning"]

        # Priority label
        priority = gap.get("priority", "medium")
        labels.append(f"priority:{priority}")

        # Status label
        status = gap.get("status", "missing")
        if status == "missing":
            labels.append("needs-investigation")
        elif status == "needs_clarification":
            labels.append("needs-clarification")

        # Coverage label
        coverage = gap.get("coverage", 0.0)
        if coverage < 0.3:
            labels.append("high-risk")

        return labels

    def create_issue_from_gap(
        self,
        gap: Dict,
        check_existing: bool = True
    ) -> Optional[str]:
        """
        Create GitHub Issue from gap

        Args:
            gap: Gap dict
            check_existing: Check for existing issues before creating

        Returns:
            Issue URL if successful
        """
        title = self.format_issue_title(gap)

        # Check for existing issue
        if check_existing:
            existing_url = self.gh_client.check_existing_issue(title)
            if existing_url:
                print(f"Issue already exists: {existing_url}")
                return existing_url

        # Create new issue
        issue = GitHubIssue(
            title=title,
            body=self.format_issue_body(gap),
            labels=self.determine_labels(gap),
            priority=gap.get("priority", "medium")
        )

        return self.gh_client.create_issue(issue)

    def create_issues_from_gaps(
        self,
        gaps: List[Dict],
        mode: IssueCreationMode = IssueCreationMode.SELECTIVE
    ) -> Dict[str, List[str]]:
        """
        Create GitHub Issues from multiple gaps

        Args:
            gaps: List of gap dicts
            mode: Issue creation mode

        Returns:
            Dict with "created" and "skipped" lists of issue URLs
        """
        result = {
            "created": [],
            "skipped": [],
            "errors": []
        }

        # Filter gaps based on mode
        filtered_gaps = self._filter_gaps_by_mode(gaps, mode)

        for gap in filtered_gaps:
            try:
                issue_url = self.create_issue_from_gap(gap)
                if issue_url:
                    result["created"].append(issue_url)
                    print(f"✅ Created: {issue_url}")
                else:
                    result["errors"].append(gap.get("question_id", "UNKNOWN"))
            except Exception as e:
                print(f"❌ Error creating issue for {gap.get('question_id')}: {e}")
                result["errors"].append(gap.get("question_id", "UNKNOWN"))

        return result

    def _filter_gaps_by_mode(
        self,
        gaps: List[Dict],
        mode: IssueCreationMode
    ) -> List[Dict]:
        """Filter gaps based on creation mode"""

        if mode == IssueCreationMode.ALL:
            return [g for g in gaps if g.get("status") != "covered"]

        elif mode == IssueCreationMode.CRITICAL_HIGH:
            return [
                g for g in gaps
                if g.get("priority") in ["critical", "high"]
                and g.get("status") != "covered"
            ]

        elif mode == IssueCreationMode.SELECTIVE:
            # In selective mode, we'll prompt user for each gap
            # For now, return all and let caller handle selection
            return [g for g in gaps if g.get("status") != "covered"]

        else:  # NONE
            return []


def main():
    parser = argparse.ArgumentParser(
        description="Create GitHub Issues from premortem gap analysis"
    )
    parser.add_argument(
        "--gaps",
        required=True,
        help="JSON file with gap analysis results"
    )
    parser.add_argument(
        "--mode",
        choices=["all", "critical_high", "selective", "none"],
        default="selective",
        help="Issue creation mode"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print issues without creating them"
    )

    args = parser.parse_args()

    # Load gaps
    with open(args.gaps) as f:
        data = json.load(f)
        gaps = data.get("gaps", [])

    # Create issue generator
    generator = IssueGenerator()

    # Parse mode
    mode_map = {
        "all": IssueCreationMode.ALL,
        "critical_high": IssueCreationMode.CRITICAL_HIGH,
        "selective": IssueCreationMode.SELECTIVE,
        "none": IssueCreationMode.NONE,
    }
    mode = mode_map.get(args.mode, IssueCreationMode.SELECTIVE)

    if args.dry_run:
        # Just print what would be created
        print("=== DRY RUN: Issues that would be created ===\n")
        filtered = generator._filter_gaps_by_mode(gaps, mode)
        for i, gap in enumerate(filtered, 1):
            print(f"\n--- Issue {i} ---")
            print(f"Title: {generator.format_issue_title(gap)}")
            print(f"Labels: {', '.join(generator.determine_labels(gap))}")
            print(f"\nBody:\n{generator.format_issue_body(gap)}")
            print("-" * 80)
    else:
        # Create issues
        print(f"Creating issues in mode: {mode.value}\n")
        result = generator.create_issues_from_gaps(gaps, mode)

        print("\n=== Summary ===")
        print(f"Created: {len(result['created'])} issues")
        print(f"Errors: {len(result['errors'])}")

        if result["created"]:
            print("\n✅ Created Issues:")
            for url in result["created"]:
                print(f"  - {url}")

        if result["errors"]:
            print("\n❌ Failed Issues:")
            for qid in result["errors"]:
                print(f"  - {qid}")


if __name__ == "__main__":
    main()
