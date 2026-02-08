---
name: code-review
description: Comprehensive code quality evaluation and review skill. Provides two modes - detailed mode with ⭐️ 5-level assessment and project-specific criteria integration, and simple mode for quick practical analysis using sub-agents (security, performance, quality, architecture). Trigger when users request code review, quality assessment, or mention "review code", "check quality", "find issues". Automatically integrates technology stack-specific skills (typescript, react, golang, security, etc.). **Always responds in Japanese**.
---

# Code Review

## Overview

Provide comprehensive code review and quality evaluation framework with dual-mode operation. Automatically detect project type and integrate appropriate technology stack-specific skills to deliver contextual, actionable feedback.

## Review Modes

### 1. Detailed Mode (Default)

Comprehensive quality assessment with structured evaluation:

**Features**:

- ⭐️ 5-level evaluation system across multiple dimensions
- Project type auto-detection (Go API, React SPA, Next.js fullstack, etc.)
- Technology stack-specific skill integration (typescript, react, golang, security, clean-architecture, etc.)
- Criteria file combination and customization
- Detailed improvement proposals with action plans
- Impact analysis with Serena integration (optional)

**When to use**:

- Comprehensive quality gate reviews
- Pre-release quality assessment
- Architecture and design evaluation
- Learning and mentoring scenarios
- Establishing quality baselines

**Typical workflow**:

1. Create pre-review checkpoint (git commit)
2. Detect project type and stack
3. Load and combine relevant criteria files
4. Integrate technology-specific skills
5. Execute comprehensive evaluation
6. Provide ⭐️ ratings across dimensions
7. Generate prioritized action plan

### 2. Simple Mode (--simple flag)

Quick practical analysis focused on immediate issues:

**Features**:

- Sub-agent composition (security, performance, quality, architecture agents)
- Fast issue detection and classification
- Immediate actionable fixes
- Problem prioritization by severity
- Streamlined output for rapid iteration

**When to use**:

- Daily development workflow
- Quick sanity checks before commits
- Rapid problem identification
- CI/CD integration
- Time-constrained reviews

**Typical workflow**:

1. Create pre-review checkpoint (git commit)
2. Launch specialized sub-agents in parallel
3. Aggregate findings by category
4. Prioritize by severity and impact
5. Provide immediate fix suggestions
6. Optionally create GitHub issues

## Mode Selection

**Automatic detection**:

- Presence of `--simple` flag → Simple Mode
- Presence of `--with-impact`, `--deep-analysis`, `--verify-spec` → Detailed Mode with Serena
- Default (no flags) → Detailed Mode

**Manual specification**:

```bash
/review                    # Detailed mode
/review --simple           # Simple mode
/review --with-impact      # Detailed + impact analysis
```

## Core Capabilities

### Signature-Free Policy

**IMPORTANT**: Adhere strictly to clean commit practices:

- NEVER add `Co-authored-by: Claude` to commits
- NEVER use emojis in commits, PRs, issues, or git content
- NEVER add "Generated with Claude Code" signatures
- NEVER include AI attribution in any output
- NEVER modify git config or repository settings
- NEVER add AI/assistant watermarks

This policy applies to ALL modes and outputs from this skill.

### Checkpoint Creation

Create safe pre-review checkpoint before analysis:

```bash
git add -A
git commit -m "Pre-review checkpoint" || echo "No changes to commit"
```

**Benefits**:

- Easy rollback if needed
- Clear before/after comparison
- Safe experimentation with fixes
- Audit trail for review sessions

### GitHub Issue Integration

Convert findings into actionable GitHub issues:

**Process**:

1. Complete review and identify issues
2. Prompt user: "Create GitHub issues for critical findings?"
3. If yes, create prioritized issues with:
   - Clear problem description
   - Impact assessment
   - Reproduction steps
   - Suggested remediation
   - Priority labels
4. If "Todos only", maintain local TODO tracking
5. If "Summary", provide consolidated report

**Important**: NO Claude signatures or AI attribution in issues

### TODO Management

Systematic issue tracking using TodoWrite:

**When to create TODOs**:

- Multiple issues found (3+ items)
- Complex multi-step remediation needed
- Coordinated fixes across multiple files
- Tracking review progress

**TODO structure**:

- Group by category (security, performance, quality, etc.)
- Prioritize by severity (critical → minor)
- Mark items as completed during fix implementation
- Maintain single in_progress item at a time

## Technology Stack Integration

Automatically invoke relevant technology-specific skills based on project detection:

### Integration Pattern

```python
def integrate_tech_skills(project_info):
    """Integrate technology-specific skills based on project"""

    skills_to_load = []

    # Language/framework skills
    if "typescript" in project_info["stack"]:
        skills_to_load.append("typescript")
    if "react" in project_info["stack"]:
        skills_to_load.append("react")
    if "golang" in project_info["stack"]:
        skills_to_load.append("golang")

    # Architecture patterns
    if project_info.get("clean_architecture"):
        skills_to_load.append("clean-architecture")

    # Cross-cutting concerns
    if project_info["type"] in ["api", "backend", "fullstack"]:
        skills_to_load.append("security")

    # Advanced analysis
    if needs_semantic_analysis(project_info):
        skills_to_load.append("semantic-analysis")

    return skills_to_load
```

### Available Technology Skills

- **typescript**: Type safety, strict mode, type guards, Result pattern
- **react**: Component design, hooks usage, performance optimization
- **golang**: Idiomatic Go, error handling, concurrency patterns
- **security**: Input validation, authentication, authorization, encryption
- **clean-architecture**: Layer separation, dependency rules, domain modeling
- **semantic-analysis**: Symbol-level analysis, impact assessment, reference tracking

## Review Workflow

### Step 1: Initialization

```python
# Create checkpoint
create_checkpoint()

# Detect mode
mode = detect_mode(flags)  # detailed or simple

# Determine review targets
targets = determine_targets()  # staged > HEAD~1 > branch diff
```

### Step 2: Project Analysis (Detailed Mode)

```python
# Auto-detect project type
project_info = detect_project_type()

# Load technology skills
tech_skills = integrate_tech_skills(project_info)

# Combine criteria
criteria = merge_criteria_files([
    "default-criteria.md",
    *[f"{skill}.md" for skill in tech_skills],
    "project-specific.md" if exists else None
])
```

### Step 3: Review Execution

**Detailed Mode**:

```python
# Execute comprehensive review
result = execute_detailed_review(
    targets=targets,
    criteria=criteria,
    project_info=project_info,
    options=options
)

# Generate ⭐️ ratings
ratings = generate_ratings(result, criteria)

# Create action plan
action_plan = create_prioritized_actions(result)
```

**Simple Mode**:

```python
# Launch sub-agents in parallel
agents = {
    "security": analyze_security(targets),
    "performance": analyze_performance(targets),
    "quality": analyze_quality(targets),
    "architecture": analyze_architecture(targets)
}

# Aggregate findings
findings = aggregate_findings(agents)

# Prioritize and format
result = prioritize_and_format(findings)
```

### Step 4: Output and Follow-up

```python
# Display results (always in Japanese)
display_results(result, mode)

# Handle options
if options.get("fix"):
    apply_auto_fixes(result)

if options.get("create_issues"):
    create_github_issues(result)

if options.get("learn"):
    record_learning_data(result)
```

## References

This skill uses progressive disclosure through reference files loaded as needed:

### references/evaluation-framework.md

Complete ⭐️ 5-level evaluation system:

- Rating definitions for each level (1-5 stars)
- Dimension-specific criteria (security, performance, quality, etc.)
- Scoring methodology
- Action threshold guidelines

### references/default-criteria.md

Technology-agnostic review criteria:

- Code readability and maintainability
- Basic security considerations
- Performance fundamentals
- Test coverage
- Error handling patterns
- Common code smells
- General anti-patterns

### references/detailed-mode.md

Detailed mode execution guide:

- Project detection algorithms
- Criteria file merging logic
- Technology skill integration patterns
- ⭐️ Rating calculation methods
- Action plan generation
- Serena integration details

### references/simple-mode.md

Simple mode execution guide:

- Sub-agent responsibilities and scope
- Parallel execution patterns
- Finding aggregation logic
- Severity prioritization
- Quick fix suggestions
- Time-optimized workflows

### references/github-integration.md

GitHub issue integration guide:

- Issue creation patterns
- Priority labeling system
- Description templates
- Remediation step formatting
- NO signature policy enforcement
- Batch creation workflows

## Usage Examples

### Example 1: Detailed Review (Default)

```bash
/review
```

**Execution**:

1. Creates checkpoint: `git commit -m "Pre-review checkpoint"`
2. Detects: Next.js fullstack project
3. Loads skills: typescript, react, security
4. Combines criteria: default + typescript + react + security
5. Executes comprehensive evaluation
6. Outputs ⭐️ ratings across dimensions
7. Provides prioritized action plan (in Japanese)

### Example 2: Simple Quick Check

```bash
/review --simple
```

**Execution**:

1. Creates checkpoint
2. Launches 4 sub-agents in parallel
3. Finds: 3 security issues, 2 performance concerns, 5 quality improvements
4. Outputs prioritized list with immediate fixes (in Japanese)
5. Asks about GitHub issue creation

### Example 3: Detailed with Impact Analysis

```bash
/review --with-impact
```

**Execution**:

1. Standard detailed review process
2. Additionally uses Serena to analyze:
   - Changed API symbols
   - Reference tracking
   - Breaking change detection
   - Affected file identification
3. Outputs impact report alongside quality assessment

### Example 4: Simple with Auto-fix

```bash
/review --simple --fix
```

**Execution**:

1. Quick review via sub-agents
2. Identifies auto-fixable issues
3. Applies automatic fixes
4. Re-runs verification
5. Reports remaining manual fixes needed

## Integration with Commands

This skill is invoked by the `/review` command:

**Command structure**:

```bash
/review [options]

Options:
  --simple              # Use simple mode
  --fix                 # Auto-fix issues
  --with-impact         # Include impact analysis
  --deep-analysis       # Deep semantic analysis
  --verify-spec         # Verify against specifications
  --create-issues       # Create GitHub issues
  --staged              # Review staged changes only
  --branch <name>       # Compare against branch
```

**Command responsibilities**:

- Parse flags and options
- Invoke code-review skill with appropriate mode
- Handle result display and formatting
- Coordinate follow-up actions

**Skill responsibilities**:

- Execute review logic
- Integrate technology skills
- Apply evaluation criteria
- Generate findings and recommendations
- All output in Japanese

## Quality Standards

All reviews must:

- Respond in Japanese (日本語で回答)
- Provide specific file:line references
- Include concrete code examples
- Offer actionable remediation steps
- Prioritize by severity and impact
- Respect signature-free policy
- Create checkpoints before analysis
- Maintain consistent evaluation standards

---

**Goal**: Deliver comprehensive, contextual code reviews that combine the depth of detailed evaluation with the speed of quick analysis, automatically adapting to project needs while maintaining consistent quality standards.

## 📚 Related Documentation

### Implementation

- [Review Command](../commands/review.md) - Command-line interface for code reviews
- [Detailed Mode Reference](./references/detailed-mode.md) - 5-level evaluation framework
- [Simple Mode Reference](./references/simple-mode.md) - Quick parallel agent execution
