# Document Size Guidelines Framework

Generic size management framework with thresholds and split strategies.

---

## Overview

**Purpose**: Maintain readable, maintainable documentation by monitoring size and suggesting splits when necessary.

**Core Principle**: **Single responsibility per document** - Each document should focus on one primary topic or workflow.

---

## Size Thresholds

### Recommended Size: ~500 lines

**Why**: Sweet spot for single-read comprehension and easy maintenance

**Characteristics**:

- Can be read in 10-15 minutes
- Easy to maintain and update
- Clear scope and purpose
- Good cognitive load balance

**Action**: Continue writing within this range

---

### Warning Size: 1000 lines

**Why**: Approaching readability limits, starting to become unwieldy

**Characteristics**:

- Requires 20-30 minutes to read fully
- Becoming harder to maintain
- May contain multiple topics
- Starting to lose focus

**Action**:

- Review document for natural split points
- Consider splitting if multiple distinct topics exist
- Plan future split if growth continues

---

### Hard Limit: 2000 lines

**Why**: Too large for effective use, must be split

**Characteristics**:

- Requires 40+ minutes to read
- Difficult to maintain
- Likely contains multiple topics
- Poor user experience

**Action**: **MUST split immediately**

- Apply decision tree to determine split strategy
- Create multiple focused documents
- Establish navigation between split docs

---

## Split Decision Tree

When a document exceeds warning threshold (1000 lines), apply this decision tree:

```
START: Document exceeds 1000 lines
│
Q1: Does it contain multiple unrelated topics?
├─ YES → STRATEGY 1: Topic-Based Split
└─ NO  → Q2

Q2: Does it target distinct audience groups?
├─ YES → STRATEGY 2: Role-Based Split
└─ NO  → Q3

Q3: Does it mix beginner and advanced content?
├─ YES → STRATEGY 3: Level-Based Split
└─ NO  → Q4

Q4: Does it cover distinct lifecycle phases?
├─ YES → STRATEGY 4: Phase-Based Split
└─ NO  → Consider keeping as comprehensive reference
           (But monitor size - may need topic split later)
```

---

## Split Strategy 1: Topic-Based Split

**When to use**: Document covers multiple unrelated or loosely related topics

**How to split**:

- Create one document per major topic
- Each document becomes self-contained
- Add navigation hub if needed

**Tag Strategy**:

- Each doc gets specific category tags for its topic
- Maintain common audience/environment tags if applicable

**Example** (generic):

```
Original: "System Operations Guide" (1500 lines)
  → Topic 1: "Database Operations" (500 lines)
  → Topic 2: "Deployment Procedures" (500 lines)
  → Topic 3: "Monitoring Setup" (500 lines)

Tags:
  - Database Operations: `category/database`, `category/operations`
  - Deployment Procedures: `category/deployment`, `category/operations`
  - Monitoring Setup: `category/monitoring`, `category/operations`
```

**Benefits**:

- Clear single responsibility per doc
- Easier to find relevant content
- Can update topics independently

---

## Split Strategy 2: Role-Based Split

**When to use**: Document serves multiple distinct audiences (developer/operations/security)

**How to split**:

- Create role-specific documents
- Extract shared content into common doc if needed
- Each doc focuses on one role's needs

**Tag Strategy**:

- Split by audience tags
- Maintain common category tags
- Keep environment tags if applicable

**Example** (generic):

```
Original: "Application Deployment Guide" (1200 lines)
  → For Developers: "Developer Deployment Guide" (400 lines)
  → For Operations: "Operations Deployment Runbook" (500 lines)
  → Shared: "Deployment Architecture Overview" (300 lines)

Tags:
  - Developer Guide: `category/deployment`, `audience/developer`
  - Operations Runbook: `category/deployment`, `audience/operations`
  - Architecture: `category/deployment`, `audience/all`
```

**Benefits**:

- Role-appropriate content and detail level
- Reduced cognitive load per role
- Can evolve independently per audience

---

## Split Strategy 3: Level-Based Split

**When to use**: Document mixes beginner/quick-start with advanced/comprehensive content

**How to split**:

- Create "Essential" or "Quick Start" doc (beginner)
- Create "Advanced" or "Complete Reference" doc
- Link between them

**Tag Strategy**:

- Same category and audience tags for both
- Differentiate by title/description
- Consider adding difficulty indicator in title

**Example** (generic):

```
Original: "API Integration Guide" (1400 lines)
  → Essentials: "API Integration Quick Start" (500 lines)
  → Advanced: "Complete API Reference" (900 lines)

Tags (both docs):
  - `category/reference`, `category/guide`, `audience/developer`
```

**Benefits**:

- Beginners get fast path to success
- Advanced users get comprehensive details
- Reduces intimidation factor

---

## Split Strategy 4: Phase-Based Split

**When to use**: Document covers entire lifecycle (setup → operations → troubleshooting)

**How to split**:

- Split by lifecycle phase
- Each doc covers one phase completely
- Create navigation hub linking all phases

**Tag Strategy**:

- Phase-specific category tags
- Add environment tags per phase if applicable
- Common audience tags

**Example** (generic):

```
Original: "Infrastructure Management" (1600 lines)
  → Phase 1: "Infrastructure Setup Guide" (500 lines)
  → Phase 2: "Infrastructure Operations" (500 lines)
  → Phase 3: "Infrastructure Troubleshooting" (400 lines)
  → Hub: "Infrastructure Guide Index" (200 lines)

Tags:
  - Setup: `category/infrastructure`, `category/guide`, `environment/all`
  - Operations: `category/infrastructure`, `category/operations`, `environment/production`
  - Troubleshooting: `category/infrastructure`, `category/operations`, `audience/operations`
```

**Benefits**:

- Users find phase-appropriate content
- Clear workflow progression
- Can maintain phases independently

---

## Post-Split Quality Checks

After splitting a document, validate:

### Self-Containment

- [ ] Each split document is self-contained
- [ ] No broken internal references
- [ ] All necessary context included
- [ ] Can be read independently

### Navigation

- [ ] Cross-references bidirectional
- [ ] Navigation hub created if needed (3+ split docs)
- [ ] Clear links between related docs
- [ ] "Related Documents" section in each doc

### Registry Updates

- [ ] All split docs added to project navigation
- [ ] Document mapping updated (if project uses one)
- [ ] Old document archived or redirected
- [ ] README/hub updated with new structure

### Content Quality

- [ ] No content duplication (or minimal/intentional)
- [ ] Consistent style across splits
- [ ] Metadata complete for all docs
- [ ] Tags appropriate for each doc

### User Experience

- [ ] Clear path from discovery to specific content
- [ ] No confusion about which doc to read
- [ ] Logical grouping and ordering
- [ ] Navigation makes sense

---

## Preventing Size Issues

### Best Practices

**Plan scope upfront**:

- Define single clear purpose
- Identify target size (aim for <500 lines)
- Consider split from start if topic is large

**Monitor during creation**:

- Check line count periodically
- Split proactively when approaching 500 lines
- Don't wait until 1000+ lines

**Use modular structure**:

- Separate sections could become docs
- Plan for future splits
- Create logical boundaries

---

## Special Cases

### Comprehensive References

Some docs legitimately need to be large (e.g., complete API reference, schema documentation):

**When large size is acceptable**:

- Single cohesive topic (e.g., API reference)
- Reference material (not narrative)
- Benefit from completeness
- Well-structured with clear navigation

**Mitigation strategies**:

- Excellent table of contents
- Clear section structure
- Search-friendly formatting
- Consider generated docs if very large (>2000 lines)

---

## Project Configuration

Projects configure size thresholds in `.claude/doc-standards/config.yaml`:

```yaml
size:
  recommended: 500 # Ideal target size
  warning: 1000 # Start considering split
  hard_limit: 2000 # Must split immediately

  examples_file: "references/size-guidelines-examples.md" # Project examples (optional)
```

**Customization**:

- Adjust thresholds based on project needs
- Some projects may prefer 400/800/1600
- Others may use 600/1200/2400
- Choose based on team preferences and document complexity

---

## Project-Specific Examples

Projects can provide real-world split examples in:

- `.claude/doc-standards/references/size-guidelines-examples.md`
- Or `.claude/skills/doc-standards/references/size-guidelines-examples.md`

**Example structure**:

```markdown
# Size Guidelines Examples

## Example 1: Topic-Based Split

**Original**: system-operations.md (1500 lines)
**Strategy**: Topic-based split
**Result**:

- database-operations.md (500 lines)
- deployment-operations.md (500 lines)
- monitoring-setup.md (500 lines)

**Rationale**: Three distinct topics with different maintenance cycles

## Example 2: Role-Based Split

**Original**: deployment-guide.md (1200 lines)
**Strategy**: Role-based split
**Result**:

- developer-deployment.md (400 lines)
- operations-deployment.md (500 lines)
- deployment-architecture.md (300 lines)

**Rationale**: Different roles needed different detail levels
```

---

## Integration with Other Frameworks

- **Metadata template**: Update metadata for each split document
- **Tag system**: Apply appropriate tags per split strategy
- **Quality checks**: Validate post-split quality

---

## Common Mistakes

### Mistake 1: Waiting Too Long

❌ **Wrong**: Let document grow to 1800 lines before considering split
✅ **Correct**: Plan split at 500-600 lines when scope expansion is clear

### Mistake 2: Arbitrary Splits

❌ **Wrong**: Split at 1000 lines exactly, mid-topic
✅ **Correct**: Split at natural topic/phase boundaries

### Mistake 3: Insufficient Navigation

❌ **Wrong**: Split into 5 docs with no hub/links
✅ **Correct**: Create navigation hub, bidirectional links

### Mistake 4: Duplicate Content

❌ **Wrong**: Copy shared content into each split doc
✅ **Correct**: Extract shared content into separate doc, link to it

### Mistake 5: Ignoring User Journey

❌ **Wrong**: Split by file structure/code organization
✅ **Correct**: Split by user needs and workflows

---

## Monitoring Document Size

### During Creation

Check size periodically:

```bash
wc -l docs/my-document.md
```

### Automated Checks

Projects can automate size validation:

```bash
# Example: Check all docs
find docs -name "*.md" -exec wc -l {} \; | awk '$1 > 1000 {print}'
```

### CI Integration

Add size checks to CI pipeline:

```yaml
# Example: GitHub Actions
- name: Check doc sizes
  run: |
    find docs -name "*.md" -exec wc -l {} \; | \
    awk '$1 > 1000 {print "⚠️ " $2 " exceeds 1000 lines (" $1 ")"; fail=1} END {exit fail}'
```

---

## Summary

**Remember**:

1. **Aim for ~500 lines** - Sweet spot for readability
2. **Plan split at 1000 lines** - Warning threshold
3. **Must split at 2000 lines** - Hard limit
4. **Use decision tree** - Choose appropriate strategy
5. **Validate post-split** - Ensure quality and navigation

**Goal**: Maintain focused, readable, maintainable documentation that serves users effectively.
