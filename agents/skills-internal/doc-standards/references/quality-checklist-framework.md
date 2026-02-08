# Quality Checklist Framework

Generic documentation quality validation framework.

---

## Overview

**Purpose**: Ensure documentation meets quality standards before commit and during periodic reviews.

**When to use**:

- Final validation before committing new documentation
- Reviewing existing documentation
- Conducting periodic quality audits
- Onboarding review process

---

## Quality Dimensions

### 1. Metadata Quality

Completeness and correctness of metadata fields

### 2. Content Quality

Structure, clarity, and accuracy of content

### 3. Technical Quality

Code examples, commands, and technical accuracy

### 4. Navigation Quality

Links, references, and discoverability

### 5. Maintenance Quality

Freshness, update frequency, and sustainability

---

## Metadata Quality Checks

### Required Fields

- [ ] **Icon present** in H1 title (if required by project)
- [ ] **Last Updated** field present with valid date format
- [ ] **Audience** field present and matches target readers
- [ ] **Tags** field present with proper formatting

### Format Validation

- [ ] Date format valid (default: YYYY-MM-DD, or project-configured)
- [ ] All tags use canonical format (`prefix/value`)
- [ ] Tags wrapped properly (default: backticks, or project-configured)
- [ ] Tags comma-separated (or project-configured separator)

### Tag Validation

- [ ] At least one `category/` tag present (or project-required tiers)
- [ ] At least one `audience/` tag present (or project-required tiers)
- [ ] All tags exist in project tag taxonomy
- [ ] Tag count within project limits (default: ≤5 tags)
- [ ] `environment/` tags used only for env-specific docs

### Consistency

- [ ] Audience field matches audience tags
- [ ] Tags align with document content
- [ ] Icon appropriate for document type
- [ ] Date is current (updated on last edit)

---

## Content Quality Checks

### Document Structure

- [ ] Clear H1 title (one only)
- [ ] Logical heading hierarchy (H1 → H2 → H3, no skips)
- [ ] Overview/Introduction section present
- [ ] Sections have clear purpose
- [ ] Consistent section structure throughout

### Writing Quality

- [ ] Clear, concise language
- [ ] Active voice used where appropriate
- [ ] Technical terms defined or linked
- [ ] Appropriate detail level for target audience
- [ ] No typos or grammar issues

### Content Completeness

- [ ] Document achieves stated purpose
- [ ] All necessary context provided
- [ ] Prerequisites clearly stated
- [ ] Expected outcomes defined
- [ ] Edge cases/limitations addressed

### Clarity and Usability

- [ ] Step-by-step procedures are clear
- [ ] Complex concepts explained adequately
- [ ] Visual aids used where helpful (diagrams, tables)
- [ ] Formatting enhances readability
- [ ] No ambiguous instructions

---

## Technical Quality Checks

### Code Examples

- [ ] Code examples are correct and tested
- [ ] Syntax highlighting used appropriately
- [ ] Code examples are complete (no missing context)
- [ ] Comments explain non-obvious parts
- [ ] Examples follow project coding standards

### Commands and Procedures

- [ ] Commands are accurate and current
- [ ] File paths and names are correct
- [ ] Environment-specific info clearly marked
- [ ] Dangerous operations have warnings
- [ ] Alternatives provided where applicable

### Technical Accuracy

- [ ] Technical information is correct
- [ ] APIs/endpoints are current
- [ ] Version-specific info is labeled
- [ ] Dependencies are documented
- [ ] Configuration examples are valid

### Security Considerations

- [ ] No exposed credentials or secrets
- [ ] Security warnings present where needed
- [ ] Secure practices recommended
- [ ] Dangerous patterns flagged
- [ ] Access control info correct

---

## Navigation Quality Checks

### Internal Links

- [ ] All internal links work (no broken links)
- [ ] Links use correct relative/absolute paths
- [ ] Anchor links target existing sections
- [ ] Cross-references are bidirectional where appropriate

### External Links

- [ ] External URLs are accessible
- [ ] Links point to stable resources (not temporary)
- [ ] External dependency versions documented
- [ ] Broken external links identified and fixed/removed

### Document Discovery

- [ ] Document listed in project navigation (README/hub)
- [ ] Document registered in mapping table (if project uses one)
- [ ] Related documents linked in "Related" section
- [ ] Search keywords present for discoverability

### Navigation Structure

- [ ] Table of contents present (if doc >500 lines)
- [ ] "Related Documents" section present
- [ ] Navigation to parent/hub clear
- [ ] Logical flow between sections

---

## Size and Scope Checks

### Size Validation

- [ ] Document under recommended size (default: 500 lines)
- [ ] If 500-1000 lines: Review for potential split
- [ ] If 1000-2000 lines: Plan split using decision tree
- [ ] If over 2000 lines: Must split immediately

### Scope Validation

- [ ] Single clear purpose/topic
- [ ] No unrelated topics mixed in
- [ ] Appropriate depth for target audience
- [ ] Complements (doesn't duplicate) other docs

---

## Maintenance Quality Checks

### Freshness

- [ ] Last Updated date is recent (or appropriate for doc type)
- [ ] Content reflects current state of system
- [ ] No references to deprecated features/APIs
- [ ] Version-specific info is current
- [ ] Warnings added for outdated sections (if not yet updated)

### Update Frequency

Check based on doc type:

- **Operations docs**: Review every 3 months
- **Reference docs**: Review every 6 months
- **Architecture docs**: Review every 12 months
- **Historical docs**: Archive if >12 months old

### Sustainability

- [ ] Document maintenance owner identified (if applicable)
- [ ] Update triggers documented (what events require updates)
- [ ] Dependencies on external docs noted
- [ ] Auto-generation possible for repetitive content

---

## Commit Readiness Checklist

Before committing new or updated documentation:

### Pre-Commit

- [ ] All quality checks above passed
- [ ] Document file created/updated
- [ ] Metadata complete and valid
- [ ] Content proofread

### Registration

- [ ] Added to project navigation (README/hub)
- [ ] Registered in document mapping (if used)
- [ ] Related docs updated with cross-references
- [ ] Hub/index updated with new structure

### Validation

- [ ] Links validated (no broken links)
- [ ] Code examples tested
- [ ] Viewed in rendered format (not just markdown)
- [ ] Reviewed by at least one other person (if project requires)

### Commit

- [ ] Descriptive commit message
- [ ] Follows project commit conventions
- [ ] Tagged appropriately (if project uses tagging)
- [ ] CI checks pass (if applicable)

---

## Periodic Review Checklist

For regular documentation audits:

### Quarterly Review

- [ ] Check all docs for freshness (>90 days old)
- [ ] Validate all external links
- [ ] Review navigation structure
- [ ] Update stale content

### Biannual Review

- [ ] Review all operations docs
- [ ] Validate all code examples
- [ ] Check for consistency across docs
- [ ] Update tag taxonomy if needed

### Annual Review

- [ ] Review all documentation
- [ ] Archive obsolete docs
- [ ] Restructure as needed
- [ ] Update documentation standards

---

## Quality Indicators

### High Quality Documentation

✅ **Characteristics**:

- Complete, accurate metadata
- Clear structure and writing
- All links work
- Code examples tested
- Updated within freshness window
- Appropriate size and scope
- Discoverable via navigation

✅ **Maturity**: Production-ready, reliable

---

### Medium Quality Documentation

⚠️ **Characteristics**:

- Mostly complete metadata
- Generally clear content
- Most links work
- Examples mostly correct
- Slightly outdated (but still usable)
- Could be better organized

⚠️ **Maturity**: Usable, needs improvement

**Action**: Schedule improvement during next update cycle

---

### Low Quality Documentation

❌ **Characteristics**:

- Missing/incomplete metadata
- Unclear or confusing content
- Broken links
- Incorrect examples
- Significantly outdated
- Poor structure

❌ **Maturity**: Unreliable, needs major revision

**Action**: Prioritize immediate improvement or archive

---

## Project Configuration

Projects can configure quality standards in `.claude/doc-standards/config.yaml`:

```yaml
quality:
  checklist_file: "references/quality-checklist-examples.md" # Project examples (optional)

  mapping:
    enabled: true # Use document mapping
    file: "references/document-mapping.md" # Path to mapping file

  links:
    validate: true # Validate links
    update_readme: true # Auto-update README
    readme_path: "docs/README.md" # Path to navigation hub

  freshness:
    operations_docs: 90 # Review operations docs every 90 days
    reference_docs: 180 # Review reference docs every 180 days
    architecture_docs: 365 # Review architecture docs every 365 days
```

---

## Project-Specific Examples

Projects can provide real-world validation examples in:

- `.claude/doc-standards/references/quality-checklist-examples.md`
- Or `.claude/skills/doc-standards/references/quality-checklist-examples.md`

**Example structure**:

```markdown
# Quality Checklist Examples

## Example 1: High Quality Doc

**Document**: deployment-guide.md
**Quality Score**: High ✅

**Strengths**:

- Complete metadata with all required fields
- Clear step-by-step procedures
- All code examples tested and working
- Excellent navigation with related docs
- Updated within last 30 days

**Areas for Improvement**: None

---

## Example 2: Medium Quality Doc

**Document**: api-reference.md
**Quality Score**: Medium ⚠️

**Strengths**:

- Good technical accuracy
- Complete metadata

**Issues**:

- Last updated 6 months ago
- Some external links broken
- Missing examples for new endpoints

**Action**: Schedule update in next sprint

---

## Example 3: Low Quality Doc

**Document**: legacy-system-guide.md
**Quality Score**: Low ❌

**Issues**:

- Missing metadata fields
- References deprecated APIs
- No code examples
- Last updated 2 years ago
- Poor structure

**Action**: Archive or completely rewrite
```

---

## Integration with Other Frameworks

- **Metadata template**: Validate against project metadata format
- **Tag system**: Check tags against project taxonomy
- **Size guidelines**: Validate size and suggest splits if needed

---

## Automation Opportunities

### Automated Checks

Projects can automate some quality checks:

```bash
# Check metadata completeness
grep -L "Last Updated" docs/*.md

# Find large documents
find docs -name "*.md" -exec wc -l {} \; | awk '$1 > 1000'

# Validate links (using markdown-link-check)
find docs -name "*.md" -exec markdown-link-check {} \;

# Check stale docs
find docs -name "*.md" -mtime +180  # >180 days old
```

### CI Integration

```yaml
# Example: GitHub Actions quality checks
- name: Documentation Quality
  run: |
    # Check metadata
    ./scripts/check-doc-metadata.sh
    # Validate links
    npm run check-links
    # Size validation
    ./scripts/check-doc-sizes.sh
```

---

## Summary

**Remember**:

1. **Validate metadata** - Complete, correct, consistent
2. **Check content quality** - Clear, accurate, appropriate
3. **Validate technical** - Examples work, commands correct
4. **Verify navigation** - Links work, discoverable
5. **Maintain freshness** - Update regularly, archive obsolete

**Goal**: Maintain reliable, usable documentation that serves users effectively.
