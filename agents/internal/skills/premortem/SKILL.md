---
name: premortem
description: |
  Proactively predicts project failure causes during planning/requirements/design phases.
  Uses the Premortem technique to dynamically generate 3-5 questions based on project characteristics,
  and uncovers overlooked industry standards, technical risks, and architectural flaws.
  Use when: "premortem", "what could go wrong", "what am I missing", "failure prediction",
  "planning review", "design validation" are requested. Supports integration with cc-sdd and task-router.
---

# Premortem Analysis

## Overview

Premortem Analysis is a skill based on the project management technique "Premortem" that predicts failure causes at the planning stage.

### Core Value

- Early discovery of blind spots at the planning stage (identify issues before implementation)
- Prevention of overlooked industry standard best practices
- Visualization of expert tacit knowledge in question form
- Prevention of downstream troubles (failures, cost overruns)

### Differentiation from Existing Skills

| Skill                   | Timing               | Focus                                         |
| ----------------------- | -------------------- | --------------------------------------------- |
| **predictive-analysis** | After implementation | Future risk prediction from code patterns     |
| **code-review-system**  | After implementation | PR workflow (CI diagnosis, comment handling)  |
| **cc-sdd validation**   | End of each phase    | Formal validity verification                  |
| **premortem**           | Planning phase       | Elicit "expert tacit knowledge" via questions |

## Quick Start

### Execution Modes

Premortem can be run in 3 modes:

#### Auto Mode (Recommended)

```bash
/premortem --mode=auto "project description"
# or simply
/premortem "project description"
```

### Behavior

1. Automatically analyzes project files (README.md, CLAUDE.md, .kiro/steering/\*.md, etc.)
2. Automatically answers questions (infers from project context)
3. Runs gap analysis (classifies into Covered/Needs Clarification/Missing)
4. Generates a comprehensive report
5. Only 1 confirmation: "Register to GitHub Issues?"

### Features

- Fastest (completes in 3-5 minutes)
- No interaction needed (only final confirmation)
- Automatic gap analysis
- Full utilization of project context

### Recommended When

- You are short on time
- Project documentation is well developed
- You want to quickly discover blind spots

#### Interactive Mode (Traditional)

```bash
/premortem --mode=interactive "project description"
```

### Behavior

1. Presents questions one by one
2. User answers each question
3. Follow-up questions (max 2 times)
4. Moves to next question
5. Generates report after all questions are answered

### Features

- Can discuss in detail
- Leverages human insights
- Carefully considers each question

### Recommended When

- Documentation is insufficient
- You want to discuss in detail within the team
- You want to dig deeply into each question

#### Batch Mode (Balanced)

```bash
/premortem --mode=batch "project description"
```

### Behavior

1. Presents all questions at once
2. User answers all at once
3. Follow-up questions if needed (1-2 times)
4. Generates report

### Features

- Balance between speed and interaction
- Grasp the full picture before answering
- Completes in 2-3 interactions

### Recommended When

- Between auto mode and interactive mode
- You want to see all questions before answering

### Basic Invocation

#### Auto Inference (No Project Description)

```bash
/premortem
# or
/premortem --mode=auto
```

### Behavior

- Automatically loads README.md, CLAUDE.md, AGENTS.md, etc.
- Infers project nature (domain, tech stack, maturity)
- Generates 3-5 relevant questions based on inferences
- Runs automatic analysis

#### Explicit Project Description

```bash
/premortem "Planning to build a blog platform with Next.js + PostgreSQL"
```

### Expected Behavior

1. Context analysis (domain: web-development, maturity: mvp)
2. 3-5 questions are generated (authentication architecture, DB design, API rate limiting, etc.)
3. Auto mode: Auto-answers from project files → gap analysis → report
4. Interactive mode: Interactively answer each question → report
5. Batch mode: All questions presented at once → answer → report

### Typical Usage Patterns

#### Pattern 1: Standalone (Planning Review)

```bash
/premortem "Building an EC site with microservices.
Planning to split into 3 services: orders, inventory, payments.
Tech stack: Node.js, MongoDB, RabbitMQ"
```

→ Questions about distributed transactions, inter-service communication, failure recovery strategy, etc. are presented

#### Pattern 2: Integration with cc-sdd (Design Validation)

```bash
/spec-design user-authentication
→ design.md generated
/premortem "Check for design blind spots"
```

→ Loads `.kiro/design/user-authentication.md` and asks questions about authentication flow vulnerabilities

#### Pattern 3: Integration with task-router (Complex Task Analysis)

```bash
/task "Implement real-time chat feature"
→ task-router analyzes requirements
→ premortem validates technology selection
→ Questions about WebSocket vs SSE, scaling strategy, etc.
```

## 3-Layer Question Generation Logic

### Layer 1: Context Analysis

Generates `ProjectContext` from user input and project files:

```python
@dataclass
class ProjectContext:
    domain: str              # "web-development", "mobile-apps", etc.
    maturity: str            # "poc", "mvp", "production"
    tech_stack: List[str]    # ["React", "Node.js", "PostgreSQL"]
    scale: str               # "small", "medium", "large"
    description: str         # project description
```

### Analysis Elements

1. Domain determination: Estimated from tech stack and keywords
   - "React", "API" → web-development
   - "Swift", "iOS" → mobile-apps
   - "Spark", "ETL" → data-systems
2. Maturity estimation: Determined from scope and timeline
   - "POC", "prototype" → poc
   - "MVP", "beta" → mvp
   - "production", "enterprise" → production
3. Scale determination: From user count and data volume estimates
   - ~1K users → small
   - 1K-100K users → medium
   - 100K+ users → large

Details: `references/frameworks/domain-detection.md`

### Layer 2: Question Selection

### Question Pool Composition

- `references/questions/generic.yaml` (35 questions) - Common across all domains
- `references/questions/web-development.yaml` (20 questions)
- `references/questions/mobile-apps.yaml` (18 questions)
- `references/questions/data-systems.yaml` (22 questions)
- `references/questions/infrastructure.yaml` (19 questions)
- `references/questions/security.yaml` (25 questions)

### Scoring Logic

```python
def score_question(question: Dict, context: ProjectContext) -> float:
    score = 0.0

    # Trigger keyword match: +0.3
    if any(t in context.description.lower() for t in question["triggers"]):
        score += 0.3

    # Domain relevance: +0.2
    if context.domain in question.get("relevance_boost", {}).get("domains", []):
        score += 0.2

    # Maturity relevance: +0.2
    if context.maturity in question.get("relevance_boost", {}).get("maturity", []):
        score += 0.2

    # Tech stack match: +0.3
    if any(tech.lower() in question["text"].lower() for tech in context.tech_stack):
        score += 0.3

    return min(score, 1.0)
```

### Selection Criteria

- Only questions with score >= 0.5 are selected
- Top 3-5 questions extracted (sorted by priority)
- Duplicate categories are excluded (max 2 from Architecture, etc.)

Details: `references/frameworks/analysis-flow.md`

### Layer 3: Interactive Review

Presents each question one by one and analyzes user answers:

### Question Format

```markdown
## Q1: Authentication/Authorization Architecture (Priority: Critical)

Is the authentication and authorization strategy for this system clear?

- OAuth2.0 / JWT / Session-based - which approach will you choose?
- What is the refresh token rotation strategy?
- Which password hashing algorithm (bcrypt, argon2) will be selected?
- What is the plan for multi-factor authentication (MFA)?

**Why it matters**: Authentication vulnerabilities are difficult to fix later and directly lead to security incidents.
```

### Answer Analysis

- Detection of missing concepts (e.g., "Using JWT" → follow-up "What about refresh tokens?")
- Max 2 follow-up questions (to prevent context overload)
- Transition to next question

## Workflow

The workflow varies depending on the selected mode.

### Auto Mode (--mode=auto, Default)

### Most Recommended Mode

#### Phase 1: Context Gathering

```markdown
1. Analyze user input
   - If project description is provided: use that description
   - If project description is not provided: auto-inference mode

2. Auto-inference mode (when description not provided)
   Load project documents in priority order:
   - README.md - project overview
   - CLAUDE.md - project policy and tech stack
   - AGENTS.md - agent configuration and development policy
   - .kiro/steering/\*.md - project knowledge base
   - package.json, requirements.txt, Cargo.toml - dependencies

3. Generate ProjectContext
   Run scripts/analyze_context.py
```

#### Phase 2: Question Generation & Auto-Analysis (Parallel Execution)

```markdown
1. Load & select question pool
   - Load from generic.yaml + {domain}.yaml
   - Select top 3-5 questions by scoring

2. For each question, run auto-analysis in parallel:
   a. Project file analysis
   - Extract relevant information from README.md, CLAUDE.md, steering/\*.md
   - Calculate confidence score

   b. Codebase search (optional)
   - Search related implementations using MCP Serena or fallback grep

   c. Gap analysis
   - Calculate coverage (0.0-1.0)
   - Classify status:
     ✅ Covered (>0.8)
     ⚠️ Needs Clarification (0.5-0.8)
     🔴 Missing (<0.5)

   d. Generate recommended actions
```

#### Phase 3: Report Generation

```markdown
1. Executive Summary
   - Total count and breakdown of blind spots found
   - Coverage statistics
   - Highlight of critical issues

2. Detailed Findings (per question)
   - Question text
   - Auto-inferred answer (with confidence)
   - Gap details
   - Recommended actions
   - Reference sources (file paths)

3. Prioritized Action Items
```

#### Phase 4: User Confirmation (Once Only)

```markdown
"Would you like to automatically register the found blind spots to GitHub Issues?

- [ ] Register all
- [ ] Register Critical/High only
- [ ] Select manually
- [ ] Do not register (report only)"
```

### Interactive Mode (--mode=interactive)

### Traditional Approach

#### Phase 1-2: Context & Questions

(Same as auto mode)

#### Phase 3: Interactive Review

```markdown
1. Present questions one by one (in markdown format)

2. Analyze user answers
   - Detect missing concepts from answer content
   - Follow-up questions if necessary (max 2 times)

3. Move to next question (repeat for all 5 questions)
```

#### Phase 4: Report Generation

```markdown
1. Classify found blind spots by risk level
   🔴 Critical / 🟡 Medium / 🟢 Low / ✅ Covered

2. Present recommended actions

3. Save session (optional)
```

### Batch Mode (--mode=batch)

### Balanced Approach

#### Phase 1-2: Context & Questions

(Same as auto mode)

#### Phase 3: Batch Review

```markdown
1. Present all questions at once

2. User answers all at once

3. Follow-up questions if necessary (1-2 times)
```

#### Phase 4: Report Generation

(Same as interactive mode)

## Domain Coverage

| Domain          | Questions | Focus Areas                                   |
| --------------- | --------- | --------------------------------------------- |
| Generic         | 35        | Architecture, Security, Reliability, Cost     |
| Web Development | 20        | API Design, Security, Performance, Data       |
| Mobile Apps     | 18        | Platform, Performance, Offline, Push          |
| Data Systems    | 22        | Schema, ETL, Scaling, Consistency             |
| Infrastructure  | 19        | Deployment, Monitoring, Disaster Recovery     |
| Security        | 25        | Authentication, Encryption, Compliance, OWASP |

See corresponding `references/questions/{domain}.yaml` for each domain's details.

## Integration Points

### Integration with cc-sdd

Automatically run premortem after design is complete:

```bash
# Design phase
/spec-design feature-name
→ .kiro/design/feature-name.md generated

# Auto trigger (can be enabled in cc-sdd settings)
→ premortem analyzes design content
→ Discovers blind spots
→ Results reflected in /validate-design
```

### Integration Benefits

- Check both formal validity (validate-design) and conceptual completeness (premortem) of the design
- Minimize design rework

### Integration with task-router

Automatically run blind spot analysis when receiving complex tasks:

```bash
/task "Complex request (e.g., implement authentication system)"

→ task-router analyzes requirements
→ premortem validates technology selection
→ Resolve blind spots before generating subtasks
```

### Integration Benefits

- Prevent overlooked items before task decomposition
- Reduce rework in the implementation phase

### Standalone Usage Scenario

Early validation at the project planning stage:

```bash
/premortem "New project planning overview"
```

### When to Use

- After creating a project plan
- Risk identification before technology selection
- Issue identification before estimation

## Scripts

### analyze_context.py

Analyzes project context and selects appropriate questions:

```bash
python3 scripts/analyze_context.py \
  --input "project description" \
  --files "package.json,README.md" \
  --output context.json \
  --questions-dir references/questions/
```

### Output Example

```json
{
  "domain": "web-development",
  "maturity": "mvp",
  "tech_stack": ["React", "Node.js", "PostgreSQL"],
  "scale": "medium",
  "selected_questions": [
    { "id": "WEB-001", "score": 0.92, "text": "..." },
    { "id": "GEN-003", "score": 0.88, "text": "..." }
  ]
}
```

### gap_analyzer.py (New)

Automatically infers answers from project files and analyzes gaps:

```bash
python3 scripts/gap_analyzer.py \
  --questions context.json \
  --output gaps.json \
  --project-root .
```

### Features

- Automatically infers answers from project files (README.md, CLAUDE.md, steering/\*.md)
- Calculates confidence score (0.0-1.0)
- Classifies gaps into 4 states:
  - ✅ Covered: Sufficiently covered (coverage > 0.8)
  - ⚠️ Needs Clarification: Partial (0.5-0.8)
  - 🔴 Missing: Not addressed (< 0.5)
  - ℹ️ Not Applicable: Does not apply

### Output Example

```json
{
  "gaps": [
    {
      "question_id": "WEB-001",
      "status": "needs_clarification",
      "coverage": 0.65,
      "auto_answer": {
        "text": "From README.md: Using JWT authentication...",
        "confidence": 0.7,
        "sources": ["README.md", ".kiro/steering/tech.md"]
      },
      "recommendation": "⚠️ Partial coverage found. Consider:..."
    }
  ],
  "summary": {
    "total": 5,
    "covered": 2,
    "needs_clarification": 2,
    "missing": 1
  }
}
```

### serena_integration.py (New)

Searches the codebase with MCP Serena integration (optional):

```bash
python3 scripts/serena_integration.py
```

### Features

- Semantic code analysis using MCP Serena
- Falls back to ripgrep when Serena is unavailable
- Automatically detects implementations relevant to questions

### format_report.py (Extended)

Generates a report integrating gap analysis results:

```bash
python3 scripts/format_report.py \
  --session gaps.json \
  --output report.md
```

### New Features

- Executive Summary (overall statistics, coverage rate)
- Display of auto-inferred answers (with confidence)
- Explicit reference sources (file paths)
- Prioritized action items

### Output Example

```markdown
# Premortem Analysis Report

## Executive Summary

**Total Questions Analyzed**: 5

- ✅ Already Covered: 2
- ⚠️ Needs Clarification: 2
- 🔴 Missing/Not Addressed: 1

**Overall Coverage**: 65.0%

## Critical Issues (🔴)

### 1. Undefined Authentication Architecture

**Auto Answer** (Confidence: 30%):
From README.md: "Planning to use JWT authentication"

**Recommendation**:
🔴 CRITICAL: Address immediately before implementation:

1. Research best practices for: OAuth2.0/JWT selection, refresh token strategy
2. Document decisions in .kiro/steering/ or design files

**Sources**: README.md
```

### github_integration.py (New)

Automatically creates GitHub Issues from discovered gaps:

```bash
# Dry-run (does not actually create)
python3 scripts/github_integration.py \
  --gaps gaps.json \
  --mode critical_high \
  --dry-run

# Actually create issues
python3 scripts/github_integration.py \
  --gaps gaps.json \
  --mode all
```

### Modes

- `all`: Create issues from all gaps
- `critical_high`: Critical/High priority only
- `selective`: Interactive selection (to be implemented)
- `none`: Do not create (dry-run only)

### Features

- Automatic appropriate label assignment (`premortem`, `priority:critical`, `needs-investigation`, etc.)
- Issue duplicate check (skip if an issue with the same name already exists)
- Rich issue body (question, auto answer, recommended actions, sources)

### Issue Example

```markdown
🔴 [Premortem] Detailed Design of Authentication Architecture

## Question

OAuth2.0 / JWT / Session-based - which approach will you choose?

## Analysis

- **Status**: missing
- **Coverage**: 30.0%
- **Priority**: critical

## Current State (Auto-detected)

From README.md: Planning to use JWT authentication

_Confidence: 30.0%_

**Sources:**

- `README.md`

## Recommended Actions

🔴 CRITICAL: Address immediately before implementation...

---

_This issue was automatically generated by Premortem Analysis_
```

## Examples

Real session examples:

- `references/examples/session-web-api.yaml` - Premortem for Web API design
- `references/examples/session-ml-pipeline.yaml` - Premortem for ML pipeline

Each example includes context, questions presented, user answers, and discovered blind spots.

## Best Practices

1. Run early: Execute immediately at the start of the design phase
2. Honest answers: "I don't know" is important information
3. Don't fear follow-up: Additional questions are opportunities to discover blind spots
4. Record results: Integrate session results into design documents
5. Re-run periodically: Re-run when project scope changes

## Limitations

- Question pool requires periodic updates (new technologies, new best practices)
- Coverage is limited for out-of-domain projects (embedded systems, game development, etc.)
- Question relevance is heuristic (not perfect)

## Progressive Disclosure Efficiency

- Initial load: metadata + SKILL.md = 15.5KB
- During question generation: + questions/\*.yaml = 13KB
- Full load: + scripts/ + frameworks/ = 49.5KB
- Reduction rate: 15.5KB / 49.5KB = **31.3%**

## References

- `references/frameworks/analysis-flow.md` - Question generation flow details
- `references/frameworks/domain-detection.md` - Domain detection logic details
- `references/questions/*.yaml` - Full question pool
- `references/examples/*.yaml` - Practical examples
