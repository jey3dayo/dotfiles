# Design Document Template

---

## Document Length Guidelines (Max 1000 lines)

### Purpose

### Approach

- Include essential sections that directly inform implementation decisions
- Omit optional sections unless critical to preventing implementation errors
- Match detail level to feature complexity
- Use diagrams and tables over lengthy prose

## **Warning**: Approaching 1000 lines indicates excessive feature complexity that may require design simplification

## Overview

2-3 paragraphs max

### Purpose

### Users

### Impact

### Goals

- Primary objective 1
- Primary objective 2
- Success criteria

### Non-Goals

- Explicitly excluded functionality
- Future considerations outside current scope
- Integration points deferred

## Architecture

### Existing Architecture Analysis (if applicable)

When modifying existing systems:

- Current architecture patterns and constraints
- Existing domain boundaries to be respected
- Integration points that must be maintained
- Technical debt addressed or worked around

### High-Level Architecture

### RECOMMENDED

### Architecture Integration

- Existing patterns preserved: [list key patterns]
- New components rationale: [why each is needed]
- Technology alignment: [how it fits current stack]
- Steering compliance: [principles maintained]

### Technology Stack and Design Decisions

### Generation Instructions

Adapt content based on feature classification from Discovery & Analysis Phase:

### For New Features (greenfield)

Generate Technology Stack section with ONLY relevant layers:

- Include only applicable technology layers (e.g., skip Frontend for CLI tools, skip Infrastructure for libraries)
- For each technology choice, provide: selection, rationale, and alternatives considered
- Include Architecture Pattern Selection if making architectural decisions

### For Extensions/Additions to Existing Systems

Generate Technology Alignment section instead:

- Document how feature aligns with existing technology stack
- Note any new dependencies or libraries being introduced
- Justify deviations from established patterns if necessary

### Key Design Decisions

Generate 1-3 critical technical decisions that significantly impact the implementation.
Each decision should follow this format:

- **Decision**: [Specific technical choice made]
- **Context**: [Problem or requirement driving this decision]
- **Alternatives**: [2-3 other approaches considered]
- **Selected Approach**: [What was chosen and how it works]
- **Rationale**: [Why this is optimal for the specific context]

- **Trade-offs**: [What we gain vs. what we sacrifice]

Skip this entire section for simple CRUD operations or when following established patterns without deviation.

## System Flows

### Flow Design Generation Instructions

Generate appropriate flow diagrams ONLY when the feature requires flow visualization. Select from:

- **Sequence Diagrams**: For user interactions across multiple components
- **Process Flow Charts**: For complex algorithms, decision branches, or state machines
- **Data Flow Diagrams**: For data transformations, ETL processes, or data pipelines
- **State Diagrams**: For complex state transitions

- **Event Flow**: For async/event-driven architectures

Skip this section entirely for simple CRUD operations or features without complex flows.
When included, provide concise Mermaid diagrams specific to the actual feature requirements.

## Requirements Traceability

### Traceability Generation Instructions

Generate traceability mapping ONLY for complex features with multiple requirements or when explicitly needed for compliance/validation.

When included, create a mapping table showing how each EARS requirement is realized:

| Requirement | Requirement Summary | Components      | Interfaces  | Flows                  |
| ----------- | ------------------- | --------------- | ----------- | ---------------------- |
| 1.1         | Brief description   | Component names | API/Methods | Relevant flow diagrams |

Alternative format for simpler cases:

- **1.1**: Realized by [Component X] through [Interface Y]
- **1.2**: Implemented in [Component Z] with [Flow diagram reference]

Skip this section for simple features with straightforward 1:1 requirement-to-component mappings.

## Components and Interfaces

### Component Design Generation Instructions

Structure components by domain boundaries or architectural layers. Generate only relevant subsections based on component type.
Group related components under domain/layer headings for clarity.

### [Domain/Layer Name]

#### [Component Name]

##### Responsibility & Boundaries

- **Primary Responsibility**: Single, clear statement of what this component does
- **Domain Boundary**: Which domain/subdomain this belongs to
- **Data Ownership**: What data this component owns and manages
- **Transaction Boundary**: Scope of transactional consistency (if applicable)

##### Dependencies

- **Inbound**: Components/services that depend on this component
- **Outbound**: Components/services this component depends on
- **External**: Third-party services, libraries, or external systems

### External Dependencies Investigation

- Use WebSearch to locate official documentation, GitHub repos, and community resources
- Use WebFetch to retrieve and analyze documentation pages, API references, and usage examples
- Verify API signatures, authentication methods, and rate limits
- Check version compatibility, breaking changes, and migration guides
- Investigate common issues, best practices, and performance considerations
- Document any assumptions, unknowns, or risks for implementation phase
- If critical information is missing, clearly note "Requires investigation during implementation: [specific concern]"

##### Contract Definition

Select and generate ONLY the relevant contract types for each component:

### Service Interface

```typescript
interface [ComponentName]Service {
  // Method signatures with clear input/output types
  // Include error types in return signatures
  methodName(input: InputType): Result<OutputType, ErrorType>;
}
```

- **Preconditions**: What must be true before calling
- **Postconditions**: What is guaranteed after successful execution
- **Invariants**: What remains true throughout

### API Contract

| Method | Endpoint      | Request       | Response | Errors        |
| ------ | ------------- | ------------- | -------- | ------------- |
| POST   | /api/resource | CreateRequest | Resource | 400, 409, 500 |

With detailed schemas only for complex payloads

### Event Contract

- **Published Events**: Event name, schema, trigger conditions
- **Subscribed Events**: Event name, handling strategy, idempotency
- **Ordering**: Guaranteed order requirements
- **Delivery**: At-least-once, at-most-once, or exactly-once

### Batch/Job Contract

- **Trigger**: Schedule, event, or manual trigger conditions
- **Input**: Data source and validation rules
- **Output**: Results destination and format
- **Idempotency**: How repeat executions are handled
- **Recovery**: Failure handling and retry strategy

### State Management

- **State Model**: States and valid transitions
- **Persistence**: Storage strategy and consistency model
- **Concurrency**: Locking, optimistic/pessimistic control

### Integration Strategy

- **Modification Approach**: Extend, wrap, or refactor existing code
- **Backward Compatibility**: What must be maintained
- **Migration Path**: How to transition from current to target state

## Data Models

### Data Model Generation Instructions

Generate only relevant data model sections based on the system's data requirements and chosen architecture.
Progress from conceptual to physical as needed for implementation clarity.

### Domain Model

### When to include

### Core Concepts

- **Aggregates**: Define transactional consistency boundaries
- **Entities**: Business objects with unique identity and lifecycle
- **Value Objects**: Immutable descriptive aspects without identity
- **Domain Events**: Significant state changes in the domain

### Business Rules & Invariants

- Constraints that must always be true
- Validation rules and their enforcement points
- Cross-aggregate consistency strategies

Include conceptual diagram (Mermaid) only when relationships are complex enough to benefit from visualization

### Logical Data Model

### When to include

### Structure Definition

- Entity relationships and cardinality
- Attributes and their types
- Natural keys and identifiers
- Referential integrity rules

### Consistency & Integrity

- Transaction boundaries
- Cascading rules
- Temporal aspects (versioning, audit)

### Physical Data Model

### When to include

### For Relational Databases

- Table definitions with data types
- Primary/foreign keys and constraints
- Indexes and performance optimizations
- Partitioning strategy for scale

### For Document Stores

- Collection structures
- Embedding vs referencing decisions
- Sharding key design
- Index definitions

### For Event Stores

- Event schema definitions
- Stream aggregation strategies
- Snapshot policies
- Projection definitions

### For Key-Value/Wide-Column Stores

- Key design patterns
- Column families or value structures
- TTL and compaction strategies

### Data Contracts & Integration

### When to include

### API Data Transfer

- Request/response schemas
- Validation rules
- Serialization format (JSON, Protobuf, etc.)

### Event Schemas

- Published event structures
- Schema versioning strategy
- Backward/forward compatibility rules

### Cross-Service Data Management

- Distributed transaction patterns (Saga, 2PC)
- Data synchronization strategies
- Eventual consistency handling

Skip any section not directly relevant to the feature being designed.

Focus on aspects that influence implementation decisions.

## Error Handling

### Error Strategy

Concrete error handling patterns and recovery mechanisms for each error type.

### Error Categories and Responses

### User Errors

### System Errors

### Business Logic Errors

### Process Flow Visualization

Include Mermaid flowchart only for complex error scenarios with business workflows.

### Monitoring

Error tracking, logging, and health monitoring implementation.

## Testing Strategy

### Default sections (adapt names/sections to fit the domain)

- Unit Tests: 3–5 items from core functions/modules (e.g., auth methods, subscription logic)
- Integration Tests: 3–5 cross-component flows (e.g., webhook handling, notifications)
- E2E/UI Tests (if applicable): 3–5 critical user paths (e.g., forms, dashboards)
- Performance/Load (if applicable): 3–4 items (e.g., concurrency, high-volume ops)

## Optional Sections (include when relevant)

### Security Considerations

### Include when

- Threat modeling, security controls, compliance requirements
- Authentication and authorization patterns
- Data protection and privacy considerations

### Performance & Scalability

### Include when

- Target metrics and measurement strategies
- Scaling approaches (horizontal/vertical)
- Caching strategies and optimization techniques

### Migration Strategy

### REQUIRED

### Process


## REQUIRED

### Process
