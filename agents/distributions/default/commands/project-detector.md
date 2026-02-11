# Project Detector - 共通プロジェクト判定ユーティリティ

プロジェクトの技術スタックと構造を自動判定する共通ユーティリティです。

## 🎯 Core Functions

### detect_project_type()

```python
def detect_project_type():
    """プロジェクトタイプを総合的に判定"""

    # 技術スタック検出
    tech_stack = detect_technology_stack()

    # プロジェクト構造分析
    structure = analyze_project_structure()

    # 設定ファイル解析
    configs = parse_configuration_files()

    return {
        "type": determine_project_type(tech_stack, structure, configs),
        "stack": tech_stack,
        "structure": structure,
        "configs": configs,
        "conventions": detect_conventions()
    }
```

### detect_technology_stack()

```python
def detect_technology_stack():
    """技術スタックを検出"""
    stack = []

    # Node.js/TypeScript
    if exists("package.json"):
        package_json = read_json("package.json")
        if "typescript" in package_json.get("devDependencies", {}):
            stack.append("typescript")
        if "react" in package_json.get("dependencies", {}):
            stack.append("react")
        if "next" in package_json.get("dependencies", {}):
            stack.append("nextjs")
        if "vue" in package_json.get("dependencies", {}):
            stack.append("vue")
        stack.append("nodejs")

    # Go
    elif exists("go.mod"):
        stack.append("go")
        go_mod = read_file("go.mod")
        if "gin-gonic/gin" in go_mod:
            stack.append("gin")
        if "gorilla/mux" in go_mod:
            stack.append("gorilla")
        if "fiber" in go_mod:
            stack.append("fiber")

    # Python
    elif exists("pyproject.toml") or exists("requirements.txt"):
        stack.append("python")
        if exists("pyproject.toml"):
            pyproject = read_toml("pyproject.toml")
            deps = pyproject.get("tool", {}).get("poetry", {}).get("dependencies", {})
            if "django" in deps:
                stack.append("django")
            if "fastapi" in deps:
                stack.append("fastapi")
            if "flask" in deps:
                stack.append("flask")

    # Rust
    elif exists("Cargo.toml"):
        stack.append("rust")
        cargo = read_toml("Cargo.toml")
        deps = cargo.get("dependencies", {})
        if "actix-web" in deps:
            stack.append("actix")
        if "rocket" in deps:
            stack.append("rocket")

    return stack
```

### analyze_project_structure()

```python
def analyze_project_structure():
    """プロジェクト構造を分析"""
    structure = {
        "is_monorepo": exists("lerna.json") or exists("nx.json") or exists("pnpm-workspace.yaml"),
        "is_api_server": is_api_server_project(),
        "is_frontend": is_frontend_project(),
        "is_fullstack": False,
        "has_tests": has_test_directory(),
        "has_ci": exists(".github/workflows") or exists(".gitlab-ci.yml"),
        "has_docker": exists("Dockerfile") or exists("docker-compose.yml")
    }

    # フルスタック判定
    if structure["is_api_server"] and structure["is_frontend"]:
        structure["is_fullstack"] = True

    return structure
```

### detect_formatter()

```python
def detect_formatter():
    """利用可能なフォーマッターを検出"""
    formatters = []

    # Node.js系
    if exists("package.json"):
        package_json = read_json("package.json")
        scripts = package_json.get("scripts", {})

        if "prettier" in scripts or exists(".prettierrc"):
            formatters.append({
                "name": "prettier",
                "command": get_package_manager_command() + " exec prettier --write ."
            })

        if "eslint" in scripts or exists(".eslintrc.js"):
            formatters.append({
                "name": "eslint",
                "command": get_package_manager_command() + " run lint --fix"
            })

    # Go
    elif exists("go.mod"):
        if command_exists("gofumpt"):
            formatters.append({"name": "gofumpt", "command": "gofumpt -w ."})
        else:
            formatters.append({"name": "gofmt", "command": "go fmt ./..."})

    # Python
    elif exists("pyproject.toml") or exists("requirements.txt"):
        if command_exists("black"):
            formatters.append({"name": "black", "command": "black ."})
        elif command_exists("autopep8"):
            formatters.append({"name": "autopep8", "command": "autopep8 --in-place --recursive ."})

    # Rust
    elif exists("Cargo.toml"):
        formatters.append({"name": "rustfmt", "command": "cargo fmt"})

    return formatters
```

## 🔧 Helper Functions

### is_api_server_project()

```python
def is_api_server_project():
    """APIサーバープロジェクトかどうかを判定"""
    indicators = [
        "main.go",           # Go API
        "app.py",            # Python API
        "server.js",         # Node.js API
        "src/main.rs",       # Rust API
        "api/",              # APIディレクトリ
        "routes/",           # ルートディレクトリ
        "controllers/",      # コントローラー
    ]
    return any(exists(indicator) for indicator in indicators)
```

### is_frontend_project()

```python
def is_frontend_project():
    """フロントエンドプロジェクトかどうかを判定"""
    indicators = [
        "src/App.tsx",       # React
        "src/App.vue",       # Vue
        "pages/",            # Next.js/Nuxt
        "src/components/",   # コンポーネント
        "public/index.html", # SPA
    ]
    return any(exists(indicator) for indicator in indicators)
```

### get_package_manager_command()

```python
def get_package_manager_command():
    """使用されているパッケージマネージャーを検出"""
    if exists("pnpm-lock.yaml"):
        return "pnpm"
    elif exists("yarn.lock"):
        return "yarn"
    else:
        return "npm"
```

## 📊 使用例

```python
# プロジェクト情報の取得
project_info = detect_project_type()

# 技術スタックの確認
if "typescript" in project_info["stack"]:
    # TypeScript固有の処理

# フォーマッターの検出と実行
formatters = detect_formatter()
if formatters:
    primary_formatter = formatters[0]
    execute_command(primary_formatter["command"])
```

このユーティリティは全てのコマンドから利用可能で、プロジェクト判定ロジックの重複を排除します。
