"""
Project type detection utilities.

Automatically detects project type and technology stack based on:
- Package files (package.json, go.mod, pyproject.toml, etc.)
- Framework-specific files (next.config.js, tsconfig.json, etc.)
- Directory structure
"""

import os
import json
from pathlib import Path
from typing import Dict, List, Optional


class ProjectInfo:
    """Project information container."""

    def __init__(
        self,
        project_type: str,
        language: str,
        frameworks: List[str],
        tools: List[str],
        root_dir: str,
    ):
        self.project_type = project_type
        self.language = language
        self.frameworks = frameworks
        self.tools = tools
        self.root_dir = root_dir

    def __repr__(self) -> str:
        return (
            f"ProjectInfo(type={self.project_type}, "
            f"language={self.language}, "
            f"frameworks={self.frameworks})"
        )


def detect_project_type(start_dir: Optional[str] = None) -> ProjectInfo:
    """
    Detect project type and technology stack.

    Args:
        start_dir: Starting directory (defaults to current directory)

    Returns:
        ProjectInfo object containing project metadata
    """
    if start_dir is None:
        start_dir = os.getcwd()

    root = Path(start_dir)

    # Initialize detection results
    project_type = "unknown"
    language = "unknown"
    frameworks = []
    tools = []

    # Check for Node.js/TypeScript projects
    package_json = root / "package.json"
    if package_json.exists():
        language = "typescript" if (root / "tsconfig.json").exists() else "javascript"

        try:
            with open(package_json) as f:
                pkg = json.load(f)
                deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}

                # Detect frameworks
                if "next" in deps:
                    frameworks.append("nextjs")
                    project_type = (
                        "nextjs-fullstack" if "prisma" in deps else "nextjs-frontend"
                    )
                elif "react" in deps:
                    frameworks.append("react")
                    project_type = "react-app"
                elif "@nestjs/core" in deps:
                    frameworks.append("nestjs")
                    project_type = "nestjs-api"

                # Detect tools
                if "prisma" in deps:
                    tools.append("prisma")
                if "zod" in deps:
                    tools.append("zod")
                if "neverthrow" in deps:
                    tools.append("neverthrow")
                if "eslint" in deps:
                    tools.append("eslint")
                if "prettier" in deps:
                    tools.append("prettier")
        except (json.JSONDecodeError, FileNotFoundError):
            pass

    # Check for Go projects
    go_mod = root / "go.mod"
    if go_mod.exists():
        language = "go"
        project_type = "go-application"
        frameworks.append("go")

        # Detect Go frameworks
        try:
            with open(go_mod) as f:
                content = f.read()
                if "gin-gonic/gin" in content:
                    frameworks.append("gin")
                if "gorilla/mux" in content:
                    frameworks.append("gorilla-mux")
                if "labstack/echo" in content:
                    frameworks.append("echo")
        except FileNotFoundError:
            pass

    # Check for Python projects
    pyproject_toml = root / "pyproject.toml"
    requirements_txt = root / "requirements.txt"
    if pyproject_toml.exists() or requirements_txt.exists():
        language = "python"
        project_type = "python-application"
        frameworks.append("python")

        # Detect Python frameworks
        if (root / "manage.py").exists():
            frameworks.append("django")
            project_type = "django-app"
        elif (root / "app.py").exists() or (root / "application.py").exists():
            frameworks.append("flask")
            project_type = "flask-app"

    return ProjectInfo(
        project_type=project_type,
        language=language,
        frameworks=frameworks,
        tools=tools,
        root_dir=str(root),
    )


def get_project_layer(file_path: str, project_info: ProjectInfo) -> str:
    """
    Determine the architectural layer of a file.

    Args:
        file_path: Path to the file
        project_info: Project information

    Returns:
        Layer name (service, action, component, etc.)
    """
    path = Path(file_path)
    parts = path.parts

    # Next.js specific layers
    if "nextjs" in project_info.frameworks:
        if "actions" in parts:
            return "action"
        elif "services" in parts:
            return "service"
        elif "app" in parts or "pages" in parts:
            # Check if Server Component
            if path.suffix in [".tsx", ".ts"]:
                with open(file_path) as f:
                    content = f.read()
                    if "'use client'" not in content and '"use client"' not in content:
                        return "server_component"
                    else:
                        return "client_component"
        elif "components" in parts:
            return "component"
        elif "lib" in parts or "utils" in parts:
            return "utility"

    # Generic layers
    if "test" in parts or "tests" in parts or "__tests__" in parts:
        return "test"
    if "api" in parts or "routes" in parts:
        return "api"
    if "models" in parts or "entities" in parts:
        return "model"
    if "repositories" in parts or "dao" in parts:
        return "repository"

    return "unknown"
