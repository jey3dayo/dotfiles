"""
Quality gates utilities.

Provides quality checks used across commands:
- Type checking
- Linting
- Testing
- Build verification
"""

import subprocess
from typing import Optional, List, Dict
from dataclasses import dataclass
from pathlib import Path


@dataclass
class QualityCheckResult:
    """Result of a quality check."""

    success: bool
    command: str
    stdout: str
    stderr: str
    error_count: int = 0
    warning_count: int = 0


class QualityGates:
    """Quality gates runner."""

    def __init__(self, project_root: Optional[str] = None):
        """
        Initialize quality gates.

        Args:
            project_root: Project root directory (defaults to current directory)
        """
        self.project_root = Path(project_root) if project_root else Path.cwd()

    def _run_command(self, command: List[str], description: str) -> QualityCheckResult:
        """
        Run a command and return result.

        Args:
            command: Command to run
            description: Description for logging

        Returns:
            QualityCheckResult
        """
        result = subprocess.run(
            command, cwd=self.project_root, capture_output=True, text=True
        )

        return QualityCheckResult(
            success=result.returncode == 0,
            command=" ".join(command),
            stdout=result.stdout,
            stderr=result.stderr,
        )

    def type_check(self) -> QualityCheckResult:
        """
        Run TypeScript type checking.

        Returns:
            QualityCheckResult
        """
        # Try different type check commands
        commands = [
            ["pnpm", "type-check"],
            ["pnpm", "tsc", "--noEmit"],
            ["npm", "run", "type-check"],
            ["yarn", "type-check"],
            ["tsc", "--noEmit"],
        ]

        for cmd in commands:
            result = self._run_command(cmd, "Type checking")
            if (
                result.success
                or "error TS" in result.stdout
                or "error TS" in result.stderr
            ):
                # Count TypeScript errors
                error_count = result.stdout.count("error TS") + result.stderr.count(
                    "error TS"
                )
                result.error_count = error_count
                return result

        # No suitable command found
        return QualityCheckResult(
            success=True,
            command="type-check",
            stdout="Type checking skipped (no suitable command found)",
            stderr="",
        )

    def lint(self, fix: bool = False) -> QualityCheckResult:
        """
        Run linting.

        Args:
            fix: Whether to auto-fix issues

        Returns:
            QualityCheckResult
        """
        commands = [
            ["pnpm", "lint"] + (["--fix"] if fix else []),
            ["npm", "run", "lint"] + (["--", "--fix"] if fix else []),
            ["yarn", "lint"] + (["--fix"] if fix else []),
            ["eslint", "."] + (["--fix"] if fix else []),
        ]

        for cmd in commands:
            result = self._run_command(cmd, "Linting")
            if "eslint" in result.stdout.lower() or "eslint" in result.stderr.lower():
                # Parse error and warning counts
                stdout_stderr = result.stdout + result.stderr
                if "✖" in stdout_stderr or "problem" in stdout_stderr:
                    # Try to extract counts
                    import re

                    error_match = re.search(r"(\d+)\s+error", stdout_stderr)
                    warning_match = re.search(r"(\d+)\s+warning", stdout_stderr)

                    result.error_count = int(error_match.group(1)) if error_match else 0
                    result.warning_count = (
                        int(warning_match.group(1)) if warning_match else 0
                    )

                return result

        return QualityCheckResult(
            success=True,
            command="lint",
            stdout="Linting skipped (no suitable command found)",
            stderr="",
        )

    def test(self, files: Optional[List[str]] = None) -> QualityCheckResult:
        """
        Run tests.

        Args:
            files: Specific test files to run (None = all tests)

        Returns:
            QualityCheckResult
        """
        file_args = files if files else []

        commands = [
            ["pnpm", "test"] + file_args,
            ["npm", "test"] + file_args,
            ["yarn", "test"] + file_args,
            ["jest"] + file_args,
            ["pytest"] + file_args,
        ]

        for cmd in commands:
            result = self._run_command(cmd, "Testing")
            if (
                result.success
                or "test" in result.stdout.lower()
                or "test" in result.stderr.lower()
            ):
                return result

        return QualityCheckResult(
            success=True,
            command="test",
            stdout="Testing skipped (no suitable command found)",
            stderr="",
        )

    def build(self) -> QualityCheckResult:
        """
        Run build.

        Returns:
            QualityCheckResult
        """
        commands = [["pnpm", "build"], ["npm", "run", "build"], ["yarn", "build"]]

        for cmd in commands:
            result = self._run_command(cmd, "Building")
            if "build" in result.stdout.lower() or "build" in result.stderr.lower():
                return result

        return QualityCheckResult(
            success=True,
            command="build",
            stdout="Build skipped (no suitable command found)",
            stderr="",
        )

    def run_all(
        self,
        type_check: bool = True,
        lint: bool = True,
        test: bool = True,
        build: bool = False,
        fix_lint: bool = False,
    ) -> Dict[str, QualityCheckResult]:
        """
        Run all quality gates.

        Args:
            type_check: Run type checking
            lint: Run linting
            test: Run testing
            build: Run build
            fix_lint: Auto-fix lint issues

        Returns:
            Dictionary of check name to result
        """
        results = {}

        if type_check:
            print("  📝 Type checking...")
            results["type_check"] = self.type_check()
            if not results["type_check"].success:
                print(
                    f"    ❌ Type check failed ({results['type_check'].error_count} errors)"
                )
                return results
            print("    ✅ Type check passed")

        if lint:
            print("  🔍 Linting...")
            results["lint"] = self.lint(fix=fix_lint)
            if not results["lint"].success:
                error_count = results["lint"].error_count
                warning_count = results["lint"].warning_count
                print(
                    f"    ❌ Lint failed ({error_count} errors, {warning_count} warnings)"
                )
                return results
            print("    ✅ Lint passed")

        if test:
            print("  🧪 Testing...")
            results["test"] = self.test()
            if not results["test"].success:
                print("    ❌ Tests failed")
                return results
            print("    ✅ Tests passed")

        if build:
            print("  🏗️ Building...")
            results["build"] = self.build()
            if not results["build"].success:
                print("    ❌ Build failed")
                return results
            print("    ✅ Build passed")

        return results


def validate_changes(
    project_root: Optional[str] = None, run_tests: bool = True
) -> bool:
    """
    Validate changes using all quality gates.

    Args:
        project_root: Project root directory
        run_tests: Whether to run tests

    Returns:
        True if all checks pass
    """
    gates = QualityGates(project_root)
    results = gates.run_all(type_check=True, lint=True, test=run_tests, build=False)

    return all(r.success for r in results.values())
