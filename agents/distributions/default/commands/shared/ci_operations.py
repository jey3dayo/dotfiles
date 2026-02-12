"""
CI operations utilities.

Provides helpers to inspect GitHub Actions CI failures using gh CLI.
"""

from __future__ import annotations

import json
import re
import subprocess
from typing import Any, Dict, List, Optional, Tuple


DEFAULT_FIELDS = ["name", "state", "conclusion", "detailsUrl", "startedAt", "completedAt"]
FALLBACK_FIELDS = [
    "name",
    "state",
    "conclusion",
    "detailsUrl",
    "link",
    "bucket",
    "workflow",
    "startedAt",
    "completedAt",
]

FAILURE_CONCLUSIONS = {"failure", "cancelled", "timed_out", "action_required"}
FAILURE_STATES = {"failure", "error", "cancelled", "timed_out", "action_required"}
FAILURE_BUCKETS = {"fail"}


def _run_gh(args: List[str], repo: Optional[str] = None) -> Tuple[int, str, str]:
    result = subprocess.run(
        ["gh", *args],
        cwd=repo,
        capture_output=True,
        text=True,
    )
    return result.returncode, result.stdout, result.stderr


def _parse_available_fields(message: str) -> List[str]:
    if not message:
        return []

    inline_match = re.search(r"available fields:\s*([^\n]+)", message, re.IGNORECASE)
    if inline_match:
        return [field.strip().strip(",") for field in inline_match.group(1).split(",") if field.strip()]

    fields: List[str] = []
    collecting = False
    for line in message.splitlines():
        if "available fields:" in line.lower():
            collecting = True
            continue
        if not collecting:
            continue
        field = line.strip()
        if not field:
            continue
        fields.append(field)
    return fields


def get_pr_checks(pr_number: int, repo: Optional[str] = None) -> List[Dict[str, Any]]:
    """Get CI checks for a PR using gh CLI."""
    args = ["pr", "checks", str(pr_number), "--json", ",".join(DEFAULT_FIELDS)]
    code, stdout, stderr = _run_gh(args, repo)

    if code != 0:
        available = _parse_available_fields(stderr or stdout)
        if not available:
            return []
        selected = [field for field in FALLBACK_FIELDS if field in available]
        if not selected:
            selected = available
        args = ["pr", "checks", str(pr_number), "--json", ",".join(selected)]
        code, stdout, stderr = _run_gh(args, repo)
        if code != 0:
            return []

    try:
        data = json.loads(stdout or "[]")
    except json.JSONDecodeError:
        return []

    if isinstance(data, dict):
        for key in ("checks", "items", "nodes", "results"):
            if key in data and isinstance(data[key], list):
                data = data[key]
                break
        else:
            return []

    if not isinstance(data, list):
        return []

    normalized = []
    for check in data:
        if not isinstance(check, dict):
            continue
        if "detailsUrl" not in check and "link" in check:
            check["detailsUrl"] = check.get("link")
        normalized.append(check)

    return normalized


def is_check_failed(check: Dict[str, Any]) -> bool:
    """Check if a check has failed."""
    state = str(check.get("state", "")).strip().lower()
    conclusion = str(check.get("conclusion", "")).strip().lower()
    bucket = str(check.get("bucket", "")).strip().lower()

    return (
        state in FAILURE_STATES
        or conclusion in FAILURE_CONCLUSIONS
        or bucket in FAILURE_BUCKETS
    )


def get_failed_checks(pr_number: int, repo: Optional[str] = None) -> List[Dict[str, Any]]:
    """Get only failed checks."""
    checks = get_pr_checks(pr_number, repo)
    return [check for check in checks if is_check_failed(check)]


def get_check_logs(run_id: str, repo: Optional[str] = None) -> str:
    """Get logs for a workflow run."""
    if not run_id:
        return ""
    code, stdout, stderr = _run_gh(["run", "view", str(run_id), "--log"], repo)
    if code != 0:
        return ""
    return stdout


def parse_typescript_errors(log: str) -> List[Dict[str, Any]]:
    """Parse TypeScript errors from log."""
    patterns = [
        re.compile(
            r"^(?P<file>[^\s:]+\.tsx?)\((?P<line>\d+),(?P<col>\d+)\):\s*error\s*TS(?P<code>\d+):\s*(?P<message>.+)$"
        ),
        re.compile(
            r"^(?P<file>[^\s:]+\.tsx?):(?P<line>\d+):(?P<col>\d+)\s*-\s*error\s*TS(?P<code>\d+):\s*(?P<message>.+)$"
        ),
        re.compile(
            r"^(?P<file>[^\s:]+\.tsx?):(?P<line>\d+):(?P<col>\d+)\s*error\s*TS(?P<code>\d+):\s*(?P<message>.+)$"
        ),
    ]

    results: List[Dict[str, Any]] = []
    for line in log.splitlines():
        for pattern in patterns:
            match = pattern.match(line.strip())
            if not match:
                continue
            results.append(
                {
                    "file": match.group("file"),
                    "line": int(match.group("line")),
                    "column": int(match.group("col")),
                    "code": f"TS{match.group('code')}",
                    "message": match.group("message").strip(),
                }
            )
            break

    return results


def parse_eslint_errors(log: str) -> List[Dict[str, Any]]:
    """Parse ESLint errors from log."""
    pattern = re.compile(
        r"^(?P<file>[^\s:]+\.tsx?):(?P<line>\d+):(?P<col>\d+)\s+(?P<severity>error|warning)\s+(?P<message>.+?)\s+(?P<rule>[\w-\/]+)$",
        re.IGNORECASE,
    )

    results: List[Dict[str, Any]] = []
    for line in log.splitlines():
        match = pattern.match(line.strip())
        if not match:
            continue
        results.append(
            {
                "file": match.group("file"),
                "line": int(match.group("line")),
                "column": int(match.group("col")),
                "severity": match.group("severity").lower(),
                "rule": match.group("rule"),
                "message": match.group("message").strip(),
            }
        )

    return results


def extract_run_id(details_url: Optional[str]) -> Optional[str]:
    """Extract run ID from GitHub Actions URL."""
    match = re.search(r"/runs/(\d+)", details_url or "")
    return match.group(1) if match else None


def determine_priority(failure_type: str, error_count: int) -> str:
    """Determine priority based on failure type and count."""
    if failure_type in {"type_error", "test_failure"}:
        return "high"
    if error_count > 10:
        return "high"
    if failure_type == "lint_error":
        return "medium"
    return "low"


def _classify_failure_type(check_name: str, log_text: str) -> str:
    name_lower = (check_name or "").lower()
    log_lower = (log_text or "").lower()

    if any(keyword in name_lower for keyword in ["type", "tsc", "typescript", "typecheck"]):
        return "type_error"
    if "error ts" in log_lower or "typescript" in log_lower:
        return "type_error"
    if any(keyword in name_lower for keyword in ["lint", "eslint"]):
        return "lint_error"
    if "eslint" in log_lower:
        return "lint_error"
    if any(keyword in name_lower for keyword in ["test", "jest", "pytest", "vitest"]):
        return "test_failure"
    if "test" in log_lower or "assert" in log_lower:
        return "test_failure"
    if any(keyword in name_lower for keyword in ["build", "compile", "bundle"]):
        return "build_error"
    if "build" in log_lower or "webpack" in log_lower or "vite" in log_lower:
        return "build_error"

    return "unknown"


def _default_fix_strategy(failure_type: str) -> str:
    return {
        "type_error": "Add missing types, fix incompatible types, and update type definitions.",
        "lint_error": "Run eslint --fix where possible, then resolve remaining rule violations.",
        "test_failure": "Identify failing tests, fix test data/mocks, and align assertions.",
        "build_error": "Inspect build logs, verify configuration and dependencies, and fix compile errors.",
        "unknown": "Inspect logs and narrow down the failure cause before applying fixes.",
    }.get(failure_type, "Inspect logs and narrow down the failure cause before applying fixes.")


def analyze_ci_failures(pr_number: int, repo: Optional[str] = None) -> List[Dict[str, Any]]:
    """Comprehensive CI failure analysis."""
    failed_checks = get_failed_checks(pr_number, repo)
    results: List[Dict[str, Any]] = []

    for check in failed_checks:
        check_name = str(check.get("name") or "")
        details_url = check.get("detailsUrl") or check.get("link")
        run_id = extract_run_id(details_url)
        logs = get_check_logs(run_id, repo) if run_id else ""

        failure_type = _classify_failure_type(check_name, logs)
        if failure_type == "type_error":
            error_details = parse_typescript_errors(logs)
        elif failure_type == "lint_error":
            error_details = parse_eslint_errors(logs)
        else:
            error_details = []

        files_affected = sorted({entry.get("file", "") for entry in error_details if entry.get("file")})

        results.append(
            {
                "check_name": check_name,
                "failure_type": failure_type,
                "priority": determine_priority(failure_type, len(error_details)),
                "files_affected": files_affected,
                "error_details": error_details,
                "fix_strategy": _default_fix_strategy(failure_type),
                "details_url": details_url,
            }
        )

    return results
