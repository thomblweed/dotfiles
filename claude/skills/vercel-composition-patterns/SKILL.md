---
name: vercel-composition-patterns
description: React composition patterns that scale. Use when refactoring components with
  boolean prop proliferation, building flexible component libraries, designing
  reusable APIs, or auditing a codebase for prop bloat and compound-component
  opportunities. Triggers on tasks involving compound components, render props,
  context providers, or component architecture. Includes React 19 API changes.
license: MIT
metadata:
  author: vercel
  version: '1.1.0'
---

# React Composition Patterns

Composition patterns for building flexible, maintainable React components. Avoid
boolean prop proliferation by using compound components, lifting state, and
composing internals. These patterns make codebases easier for both humans and AI
agents to work with as they scale.

## When to Apply

Reference these guidelines when:

- Refactoring components with many boolean props
- Building reusable component libraries
- Designing flexible component APIs
- Reviewing component architecture
- Working with compound components or context providers
- Auditing or scanning a codebase for prop-heavy components and compound opportunities

## Rule Categories by Priority

| Priority | Category                | Impact | Prefix          |
| -------- | ----------------------- | ------ | --------------- |
| 1        | Component Architecture  | HIGH   | `architecture-` |
| 2        | State Management        | MEDIUM | `state-`        |
| 3        | Implementation Patterns | MEDIUM | `patterns-`     |
| 4        | React 19 APIs           | MEDIUM | `react19-`      |

## Quick Reference

### 1. Component Architecture (HIGH)

- `architecture-avoid-boolean-props` - Don't add boolean props to customize
  behavior; use composition
- `architecture-compound-components` - Structure complex components with shared
  context

### 2. State Management (MEDIUM)

- `state-decouple-implementation` - Provider is the only place that knows how
  state is managed
- `state-context-interface` - Define generic interface with state, actions, meta
  for dependency injection
- `state-lift-state` - Move state into provider components for sibling access

### 3. Implementation Patterns (MEDIUM)

- `patterns-explicit-variants` - Create explicit variant components instead of
  boolean modes
- `patterns-children-over-render-props` - Use children for composition instead
  of renderX props

### 4. React 19 APIs (MEDIUM)

> **⚠️ React 19+ only.** Skip this section if using React 18 or earlier.

- `react19-no-forwardref` - Don't use `forwardRef`; use `use()` instead of `useContext()`

## Audit mode (scan a codebase for composition opportunities)

When asked to audit components, scan for compound opportunities, or check for
prop bloat, sweep the component APIs first. Four smells each map to the rule
that fixes them — read that rule for the refactor, don't restate it here:

| Smell                      | What to look for                                                                                                                 | Fix rule                                                                  |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Prop bloat                 | a props type with ≥7 members, especially clustering into distinct visual sub-regions                                             | `architecture-compound-components`                                        |
| Boolean prop proliferation | ≥2 boolean flags toggling the presence or variant of sub-parts (`showX`, `hasY`, `withHeader`)                                   | `architecture-avoid-boolean-props`, `patterns-explicit-variants`          |
| Structural node prop       | a prop typed `ReactNode` or `renderX: (…) => ReactNode` holding a _region_ (header/footer/actions/toolbar/row), not leaf content | `patterns-children-over-render-props`, `architecture-compound-components` |
| Config-array API           | `items`/`tabs`/`actions={[{…}]}` whose entries carry callbacks or sub-regions                                                    | `architecture-compound-components`                                        |

A prop surface is **idiomatic — leave it —** when:

- The props are leaf content (`label`, `title`, `description`, `content`, a single `children`).
- It is a form-library field whose props bridge the form (`label`/validation/`options`/`renderOption`) — prop-driven is the point.
- A config array feeds an already-compound primitive (TanStack `columns` → a `DataTable`) or its entries are homogeneous leaf data (steps, breadcrumbs).
- It is a correctly-parameterized generic consumed by thin wrappers — cohesive config, no structural sub-region to slot.

**Report** every finding ordered by severity — account for each flagged
component against the idiomatic list above so false positives are ruled out
explicitly. Per finding: `file:line` + component, the smell(s), one line on why
the API is awkward _today_ (a real call site passing divergent flags outranks a
hypothetical), a 3–6 line sketch of the compound API, and priority
HIGH/MEDIUM/LOW. Weight severity by how actively awkward the call sites are, not
prop count alone.

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/architecture-avoid-boolean-props.md
rules/state-context-interface.md
```

Each rule file contains:

- Brief explanation of why it matters
- Incorrect code example with explanation
- Correct code example with explanation
- Additional context and references

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
