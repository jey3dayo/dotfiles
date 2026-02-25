---
name: markdown-docs
description: |
  [What] Specialized skill for reviewing and improving Markdown documentation (README, technical guides, documentation). Evaluates writing quality, document structure, technical accuracy, and reader experience. Provides 5-level quality assessment and actionable improvements
  [When] Use when: users mention "README", "documentation", "technical writing", "Markdown", work with .md files (README.md, CHANGELOG.md, CONTRIBUTING.md), request document review, or need help creating technical documentation
  [Keywords] README, documentation, technical writing, Markdown
---

# Markdown Docs - Documentation Review and Creation

## Overview

This skill provides comprehensive review and creation support for Markdown technical documentation. Evaluate documentation quality across writing clarity, structure, technical accuracy, and reader experience. Apply documentation best practices and provide actionable improvements for READMEs, technical guides, and other Markdown documents.

## Core Capabilities

### 1. Writing Quality Evaluation

Assess the clarity, consistency, and readability of documentation:

#### Clarity

- Concise language: Check for clear, straightforward explanations
- Technical term definitions: Verify jargon is properly explained
- Ambiguity elimination: Identify vague or unclear statements
- One concept per sentence: Ensure focused, digestible content

#### Consistency

- Terminology unification: Verify consistent use of terms
- Tone consistency: Check unified writing style (formal/informal)
- Notation consistency: Ensure unified format (e.g., katakana vs. English)
- Formatting consistency: Verify uniform structure and styling

#### Readability

- Appropriate paragraphing: Check logical content division
- Effective bullet lists: Review list usage for clarity
- Information emphasis: Verify important content stands out
- Visual hierarchy: Ensure clear structure through formatting

### 2. Document Structure

Evaluate the organization and architecture of information:

#### Information Architecture

- Logical flow: Check natural progression of information
- Appropriate heading hierarchy: Verify `#`, `##`, `###` usage
- Section relationships: Ensure logical connections between sections
- Table of contents: Assess need for and accuracy of TOC

#### Completeness

- Comprehensive coverage: Verify all necessary information included
- Prerequisites statement: Check clear specification of requirements
- Limitations documentation: Ensure constraints are documented
- Troubleshooting information: Review problem-solving guidance

#### Navigation

- Internal linking: Assess appropriate cross-references
- External references: Check links to related documentation
- Searchable keywords: Verify strategic keyword placement
- Clear section markers: Ensure easy navigation

### 3. Technical Accuracy

Verify the correctness and utility of technical content:

#### Content Accuracy

- Technical correctness: Validate accuracy of technical information
- Code example verification: Ensure examples work as documented
- Version information: Check clear version specifications
- Currency of information: Verify documentation is up-to-date

#### Practicality

- Executable procedures: Ensure step-by-step instructions work
- Concrete examples: Verify practical, working examples
- Edge case coverage: Check unusual scenario documentation
- Best practices: Ensure recommended approaches are included

### 4. Reader Experience

Assess documentation from the user's perspective:

#### Target Audience

- Audience level specification: Clear indication of intended readers
- Prerequisite knowledge: Explicit statement of required background
- Technical term glossary: Definitions for specialized vocabulary
- Learning curve consideration: Appropriate complexity progression

#### Usability

- Quick start guide: Presence of fast on-ramp for users
- FAQ section: Common questions and answers
- Code samples and configurations: Practical, copy-paste examples
- Visual aids: Effective use of diagrams and illustrations

### 5. Markdown Usage

Evaluate proper and effective Markdown syntax:

#### Syntax Correctness

- Heading levels: Appropriate use of `#` hierarchy
- Link formatting: Correct link syntax and functionality
- Code block language specification: Proper ` ```language ` usage
- Table structure: Well-formed table syntax

#### Advanced Features

- Diagram insertion: Appropriate visual element inclusion
- Alert/notice boxes: Effective use of callouts for important information
- Task lists: Proper checkbox syntax when applicable
- Collapsible sections: Use of `<details>` for optional content

## 5-Level Quality Assessment

Provide structured evaluation using this rating system:

### ⭐⭐⭐⭐⭐ (5/5) Excellent

- Exceptionally clear and understandable
- Perfect structure and information design
- Technically accurate and practical
- Fully meets reader needs

### ⭐⭐⭐⭐☆ (4/5) Good

- Clear and understandable
- Good structure
- Technically accurate
- Minor improvements only

### ⭐⭐⭐☆☆ (3/5) Standard

- Generally understandable
- Structure has improvement opportunities
- Mostly accurate
- Several improvements needed

### ⭐⭐☆☆☆ (2/5) Needs Improvement

- Requires effort to understand
- Structure needs revision
- Contains inaccuracies
- Significant improvements required

### ⭐☆☆☆☆ (1/5) Requires Rewrite

- Difficult to understand
- Broken structure
- Multiple inaccuracies
- Complete rewrite needed

## Common Issues and Solutions

### Writing Problems

### Issues

- Verbose, unclear explanations
- Missing subjects or objects
- Excessive jargon
- Inconsistent terminology

### Solutions

- Use active voice and concise language
- Complete sentences with clear subjects
- Define technical terms on first use
- Create and follow terminology glossary

### Structure Problems

### Issues

- Illogical information placement
- Heading-content mismatch
- Buried important information
- Missing navigation aids

### Solutions

- Reorganize by logical flow
- Align headings with content
- Place critical info prominently
- Add TOC and internal links

### Technical Problems

### Issues

- Outdated information
- Non-working code examples
- Incomplete procedures
- Missing environment details

### Solutions

- Regular documentation updates
- Test all code examples
- Complete step-by-step instructions
- Document dependencies and versions

### Reader Experience Problems

### Issues

- Unclear target audience
- Missing prerequisite explanation
- Lack of examples
- No troubleshooting guidance

### Solutions

- State target audience explicitly
- Document required background knowledge
- Add concrete, working examples
- Include common issues and solutions

## Best Practices for Documentation

### Structure Best Practices

- Start with overview: Begin with purpose and scope
- Progressive disclosure: Move from simple to complex
- Consistent sections: Use standard structure (Installation, Usage, API, etc.)
- Clear hierarchy: Maintain logical heading levels

### Writing Best Practices

- Active voice: Use direct, active constructions
- Present tense: Write in present tense for clarity
- Second person: Address reader directly ("you can...")
- Imperative mood: Use commands for instructions ("Run the command...")

### Technical Best Practices

- Tested examples: Verify all code examples work
- Version specification: Document tested versions
- Platform notes: Specify OS/environment requirements
- Copy-paste ready: Provide ready-to-use code snippets

### Maintenance Best Practices

- Update timestamps: Note last revision date
- Change logging: Track significant updates
- Link validation: Regularly check all links
- User feedback: Incorporate common questions

## Review Workflow

When reviewing Markdown documentation:

1. Assess target audience: Identify intended readers and their needs
2. Evaluate structure: Check organization and information flow
3. Review writing quality: Assess clarity, consistency, readability
4. Verify technical accuracy: Test examples and validate information
5. Check completeness: Ensure all necessary information present
6. Test navigation: Verify links and structure work well
7. Provide rating: Assign 5-level quality score per category
8. Suggest improvements: Offer specific, actionable recommendations
9. Prioritize changes: Identify critical vs. optional improvements

## Creation Workflow

When helping create new documentation:

1. Understand purpose: Clarify document goals and audience
2. Outline structure: Plan sections and information flow
3. Draft content: Write clear, concise documentation
4. Add examples: Include practical, tested code samples
5. Create navigation: Add TOC and internal links
6. Review and test: Verify accuracy and completeness
7. Refine based on feedback: Incorporate improvements
8. Finalize formatting: Apply consistent Markdown styling

## Documentation Types and Considerations

### README Files

- Essential sections: Description, Installation, Usage, Contributing, License
- Quick start: Immediate value for new users
- Badges: Build status, coverage, version information
- Visual appeal: Screenshots or demos when applicable

### API Documentation

- Endpoint documentation: Clear parameter and response descriptions
- Authentication: Security and credential information
- Examples: Request and response samples
- Error codes: Comprehensive error documentation

### Guides and Tutorials

- Learning objectives: Clear statement of what readers will learn
- Step-by-step: Detailed, sequential instructions
- Checkpoints: Verification steps along the way
- Troubleshooting: Common issues and solutions

### Technical Specifications

- Precision: Exact, unambiguous language
- Completeness: Comprehensive coverage of all details
- Examples: Clarifying illustrations of specs
- References: Links to related specifications

## 🤖 Agent Integration

This skill provides specialized knowledge to agents executing Markdown documentation creation and improvement tasks:

### Code-Reviewer Agent (when reviewing documentation)

- Provides: Markdown document quality evaluation, writing improvement suggestions
- Timing: When reviewing READMEs and technical documentation
- Context:
  - ⭐️ 5-level rating (structure, content quality, readability, technical accuracy)
  - Evaluation criteria by document type (README, API docs, Guides)
  - Improvement suggestions with prioritization

### Orchestrator Agent

- Provides: Documentation creation strategy, structural design
- Timing: When creating new documents or performing large-scale improvements
- Context: Document type selection, structure patterns, section design

### Docs-Manager Agent

- Provides: Ensuring Markdown file consistency, link management
- Timing: When optimizing documentation structure
- Context: Broken link detection, metadata management, file placement

### Auto-Load Conditions

- Mentions of "README", "documentation", "Markdown", or "technical writing"
- When working with .md files (README.md, CHANGELOG.md, CONTRIBUTING.md)
- When a document review is requested
- When creating technical documentation

### Integration Example

```
User: "I want to improve README.md to be clearer and more readable"
    ↓
TaskContext created
    ↓
Project detected: Markdown documentation
    ↓
Skills auto-loaded: markdown-docs, docs-manager
    ↓
Agent selected: code-reviewer (document mode)
    ↓ (skill context provided)
⭐️ 5-level rating + writing improvement patterns
    ↓
Execution complete (structure improved, readability enhanced, technical accuracy ensured)
```

## Integration with Related Skills

- slide-docs skill: For presenting documentation content as slides
- deckset skill: For creating documentation presentations
- docs-manager skill: For maintaining documentation file organization and link integrity

## Detailed Reference

- `references/index.md`
