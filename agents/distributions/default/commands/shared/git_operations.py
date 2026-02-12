"""
Git operations utilities.

Provides common Git operations used across commands:
- Status checking
- Commit creation
- Branch management
- Diff operations
"""

import subprocess
from typing import List, Optional, Tuple
from dataclasses import dataclass


@dataclass
class GitStatus:
    """Git repository status."""

    is_clean: bool
    staged_files: List[str]
    modified_files: List[str]
    untracked_files: List[str]
    current_branch: str


def is_git_repository() -> bool:
    """Check if current directory is a git repository."""
    result = subprocess.run(
        ["git", "rev-parse", "--is-inside-work-tree"], capture_output=True, text=True
    )
    return result.returncode == 0


def get_git_status() -> GitStatus:
    """
    Get current git repository status.

    Returns:
        GitStatus object with repository state
    """
    if not is_git_repository():
        return GitStatus(
            is_clean=True,
            staged_files=[],
            modified_files=[],
            untracked_files=[],
            current_branch="",
        )

    # Get current branch
    branch_result = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True
    )
    current_branch = (
        branch_result.stdout.strip() if branch_result.returncode == 0 else ""
    )

    # Get staged files
    staged_result = subprocess.run(
        ["git", "diff", "--cached", "--name-only"], capture_output=True, text=True
    )
    staged_files = (
        staged_result.stdout.strip().split("\n") if staged_result.stdout.strip() else []
    )

    # Get modified files
    modified_result = subprocess.run(
        ["git", "diff", "--name-only"], capture_output=True, text=True
    )
    modified_files = (
        modified_result.stdout.strip().split("\n")
        if modified_result.stdout.strip()
        else []
    )

    # Get untracked files
    untracked_result = subprocess.run(
        ["git", "ls-files", "--others", "--exclude-standard"],
        capture_output=True,
        text=True,
    )
    untracked_files = (
        untracked_result.stdout.strip().split("\n")
        if untracked_result.stdout.strip()
        else []
    )

    is_clean = not (staged_files or modified_files or untracked_files)

    return GitStatus(
        is_clean=is_clean,
        staged_files=staged_files,
        modified_files=modified_files,
        untracked_files=untracked_files,
        current_branch=current_branch,
    )


def create_commit(message: str, files: Optional[List[str]] = None) -> Tuple[bool, str]:
    """
    Create a git commit.

    Args:
        message: Commit message
        files: Specific files to commit (None = all staged files)

    Returns:
        Tuple of (success, error_message)
    """
    if not is_git_repository():
        return False, "Not a git repository"

    # Add files if specified
    if files:
        for file in files:
            result = subprocess.run(
                ["git", "add", file], capture_output=True, text=True
            )
            if result.returncode != 0:
                return False, f"Failed to add {file}: {result.stderr}"

    # Create commit
    result = subprocess.run(
        ["git", "commit", "-m", message], capture_output=True, text=True
    )

    if result.returncode != 0:
        return False, result.stderr

    return True, ""


def get_changed_files(base_branch: str = "main") -> List[str]:
    """
    Get files changed compared to base branch.

    Args:
        base_branch: Branch to compare against

    Returns:
        List of changed file paths
    """
    if not is_git_repository():
        return []

    # Try different base branches
    for branch in [base_branch, "origin/main", "origin/develop", "develop"]:
        result = subprocess.run(
            ["git", "diff", "--name-only", branch], capture_output=True, text=True
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip().split("\n")

    # Fallback to staged + modified files
    status = get_git_status()
    return list(set(status.staged_files + status.modified_files))


def get_recent_commit_files(count: int = 1) -> List[str]:
    """
    Get files changed in recent commits.

    Args:
        count: Number of commits to look back

    Returns:
        List of changed file paths
    """
    if not is_git_repository():
        return []

    result = subprocess.run(
        ["git", "diff", "--name-only", f"HEAD~{count}"], capture_output=True, text=True
    )

    if result.returncode != 0:
        return []

    return result.stdout.strip().split("\n") if result.stdout.strip() else []


def create_checkpoint(description: str) -> Tuple[bool, str]:
    """
    Create a checkpoint commit for safe rollback.

    Args:
        description: Checkpoint description

    Returns:
        Tuple of (success, commit_hash or error_message)
    """
    status = get_git_status()

    # Stage all changes
    if not status.is_clean:
        add_result = subprocess.run(
            ["git", "add", "-A"], capture_output=True, text=True
        )
        if add_result.returncode != 0:
            return False, add_result.stderr

        # Create commit
        commit_message = f"checkpoint: {description}"
        success, error = create_commit(commit_message)

        if not success:
            return False, error

        # Get commit hash
        hash_result = subprocess.run(
            ["git", "rev-parse", "HEAD"], capture_output=True, text=True
        )
        commit_hash = hash_result.stdout.strip() if hash_result.returncode == 0 else ""

        return True, commit_hash
    else:
        return True, "No changes to checkpoint"


def rollback_to_commit(commit_hash: str) -> Tuple[bool, str]:
    """
    Rollback to a specific commit.

    Args:
        commit_hash: Commit hash to rollback to

    Returns:
        Tuple of (success, error_message)
    """
    result = subprocess.run(
        ["git", "reset", "--hard", commit_hash], capture_output=True, text=True
    )

    if result.returncode != 0:
        return False, result.stderr

    return True, ""


def get_current_pr_number() -> Optional[int]:
    """
    Get PR number for current branch using gh CLI.

    Returns:
        PR number or None if not found
    """
    result = subprocess.run(
        ["gh", "pr", "view", "--json", "number", "--jq", ".number"],
        capture_output=True,
        text=True,
    )

    if result.returncode == 0 and result.stdout.strip():
        try:
            return int(result.stdout.strip())
        except ValueError:
            return None

    return None
