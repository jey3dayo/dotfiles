"""
Todo integration utilities.

Provides TodoWrite integration for commands:
- Todo creation from tasks
- Progress tracking
- Status updates
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass


@dataclass
class Todo:
    """Todo item."""

    content: str
    status: str  # "pending", "in_progress", "completed"
    activeForm: str

    def to_dict(self) -> Dict[str, str]:
        """Convert to dictionary for TodoWrite tool."""
        return {
            "content": self.content,
            "status": self.status,
            "activeForm": self.activeForm,
        }


class TodoManager:
    """Manage todos for commands."""

    def __init__(self):
        """Initialize todo manager."""
        self.todos: List[Todo] = []

    def add_todo(self, content: str, active_form: Optional[str] = None) -> None:
        """
        Add a new todo.

        Args:
            content: Todo description (imperative form)
            active_form: Active form description (optional, auto-generated if None)
        """
        if active_form is None:
            # Auto-generate active form by converting to present continuous
            active_form = self._convert_to_active_form(content)

        todo = Todo(content=content, status="pending", activeForm=active_form)
        self.todos.append(todo)

    def mark_in_progress(self, index: int) -> None:
        """
        Mark a todo as in progress.

        Args:
            index: Todo index
        """
        if 0 <= index < len(self.todos):
            self.todos[index].status = "in_progress"

    def mark_completed(self, index: int) -> None:
        """
        Mark a todo as completed.

        Args:
            index: Todo index
        """
        if 0 <= index < len(self.todos):
            self.todos[index].status = "completed"

    def mark_current_completed(self) -> None:
        """Mark the current in_progress todo as completed."""
        for i, todo in enumerate(self.todos):
            if todo.status == "in_progress":
                self.mark_completed(i)
                break

    def start_next(self) -> Optional[int]:
        """
        Start the next pending todo.

        Returns:
            Index of started todo, or None if no pending todos
        """
        for i, todo in enumerate(self.todos):
            if todo.status == "pending":
                self.mark_in_progress(i)
                return i
        return None

    def get_current(self) -> Optional[Todo]:
        """
        Get the current in_progress todo.

        Returns:
            Current todo or None
        """
        for todo in self.todos:
            if todo.status == "in_progress":
                return todo
        return None

    def to_tool_format(self) -> List[Dict[str, str]]:
        """
        Convert todos to TodoWrite tool format.

        Returns:
            List of todo dictionaries
        """
        return [todo.to_dict() for todo in self.todos]

    def _convert_to_active_form(self, content: str) -> str:
        """
        Convert imperative form to active form.

        Args:
            content: Imperative form (e.g., "Fix type errors")

        Returns:
            Active form (e.g., "Fixing type errors")
        """
        # Simple conversion: change verb to -ing form
        words = content.split()
        if not words:
            return content

        first_word = words[0].lower()

        # Common verb conversions
        conversions = {
            "fix": "Fixing",
            "create": "Creating",
            "update": "Updating",
            "delete": "Deleting",
            "remove": "Removing",
            "add": "Adding",
            "install": "Installing",
            "run": "Running",
            "test": "Testing",
            "build": "Building",
            "deploy": "Deploying",
            "implement": "Implementing",
            "refactor": "Refactoring",
            "analyze": "Analyzing",
            "optimize": "Optimizing",
            "validate": "Validating",
            "integrate": "Integrating",
            "migrate": "Migrating",
            "extract": "Extracting",
            "move": "Moving",
        }

        if first_word in conversions:
            return conversions[first_word] + " " + " ".join(words[1:])

        # Fallback: just add -ing
        if first_word.endswith("e"):
            active_verb = first_word[:-1] + "ing"
        else:
            active_verb = first_word + "ing"

        return active_verb.capitalize() + " " + " ".join(words[1:])


def create_todos_from_tasks(tasks: List[str]) -> List[Dict[str, str]]:
    """
    Create todos from a list of tasks.

    Args:
        tasks: List of task descriptions

    Returns:
        List of todo dictionaries for TodoWrite tool
    """
    manager = TodoManager()
    for task in tasks:
        manager.add_todo(task)

    # Mark first as in_progress
    if manager.todos:
        manager.mark_in_progress(0)

    return manager.to_tool_format()


def create_refactoring_todos(
    analysis_results: Dict[str, Any], proposals: List[Dict[str, Any]]
) -> List[Dict[str, str]]:
    """
    Create todos for refactoring tasks.

    Args:
        analysis_results: Code analysis results
        proposals: Improvement proposals

    Returns:
        List of todo dictionaries
    """
    manager = TodoManager()

    # Add analysis phase
    manager.add_todo(
        "Analyze code quality and identify improvement areas",
        "Analyzing code quality and identifying improvement areas",
    )

    # Add proposal generation
    manager.add_todo(
        "Generate improvement proposals with priorities",
        "Generating improvement proposals with priorities",
    )

    # Add implementation tasks based on proposals
    for i, proposal in enumerate(proposals, 1):
        priority_emoji = {10: "🔴", 9: "🔴", 8: "🟠", 7: "🟠", 6: "🟡", 5: "🟡"}.get(
            proposal.get("priority", 5), "🟢"
        )

        content = f"{priority_emoji} {proposal.get('type', 'Fix')}: {proposal.get('description', f'Proposal {i}')}"
        manager.add_todo(
            content,
            content.replace("Fix:", "Fixing:").replace("Refactor:", "Refactoring:"),
        )

    # Add validation phase
    manager.add_todo(
        "Run quality gates (type-check, lint, test)",
        "Running quality gates (type-check, lint, test)",
    )

    # Mark first as in_progress
    if manager.todos:
        manager.mark_in_progress(0)

    return manager.to_tool_format()


def create_review_todos(
    review_mode: str, issues: List[Dict[str, Any]]
) -> List[Dict[str, str]]:
    """
    Create todos for review tasks.

    Args:
        review_mode: "simple" or "detailed"
        issues: List of review issues

    Returns:
        List of todo dictionaries
    """
    manager = TodoManager()

    # Add review phase
    if review_mode == "simple":
        manager.add_todo(
            "Run quick code review with parallel agents",
            "Running quick code review with parallel agents",
        )
    else:
        manager.add_todo(
            "Run comprehensive code review with ⭐️ ratings",
            "Running comprehensive code review with ⭐️ ratings",
        )

    # Add issue-specific todos
    for issue in issues:
        priority = issue.get("priority", "medium")
        priority_emoji = {
            "critical": "🔴",
            "high": "🟠",
            "medium": "🟡",
            "low": "🟢",
        }.get(priority, "🟡")

        content = f"{priority_emoji} {issue.get('category', 'Issue')}: {issue.get('message', 'Fix issue')}"
        manager.add_todo(content)

    # Mark first as in_progress
    if manager.todos:
        manager.mark_in_progress(0)

    return manager.to_tool_format()
