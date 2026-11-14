---
name: solid-principles
applies-to: '**/*.tsx, **/*.jsx'
description: SOLID overview - Quick reference for all 5 principles with React application
when-to-use: architecture decisions, code review, refactoring, learning SOLID
keywords: SOLID, principles, overview, architecture, react patterns
priority: high
related: single-responsibility.md, open-closed.md, liskov-substitution.md, interface-segregation.md, dependency-inversion.md
---

# SOLID Principles Overview for React 19

## Quick Reference

| Principle                 | React Application                    | Key Symptom of Violation                     |
| ------------------------- | ------------------------------------ | -------------------------------------------- |
| **S**ingle Responsibility | 1 component = 1 UI, 1 hook = 1 logic | one unit fetches, derives, and renders       |
| **O**pen/Closed           | Extend via props/composition         | Adding feature = modify existing             |
| **L**iskov Substitution   | Implementations respect contracts    | Mock fails, real works                       |
| **I**nterface Segregation | Small, focused interfaces            | a consumer depends on members it doesn't use |
| **D**ependency Inversion  | Depend on abstractions               | Direct `fetch()` in services                 |

---

## S - Single Responsibility

**Definition:** One file = One reason to change

**React Application:**

- 1 component = 1 UI concern (rendering only)
- 1 hook = 1 logic concern (data fetching OR state management)
- 1 service = 1 domain (users OR auth OR payments)

**Size is a signal, not the verdict** — a unit growing large is a prompt to check whether it has more than one reason to change. Thresholds follow the host repo's conventions.

→ See `single-responsibility.md` for detailed guide
→ See `templates/` for code examples

---

## O - Open/Closed

**Definition:** Open for extension, closed for modification

**React Application:**

- Extend via variant props (`variant="primary"`)
- Use composition (slots: `header`, `footer`)
- Render props for custom rendering
- Strategy pattern for swappable behavior

→ See `open-closed.md` for detailed guide
→ See `templates/component.md` for extensible components

---

## L - Liskov Substitution

**Definition:** Subtypes must be substitutable for base types

**React Application:**

- All implementations respect interface contracts
- Mock and real services behave identically
- Consistent error handling across implementations
- Tests verify substitutability

→ See `liskov-substitution.md` for detailed guide
→ See `templates/interface.md` for contract definitions

---

## I - Interface Segregation

**Definition:** Many small interfaces beat one fat interface

**React Application:**

- No consumer depends on interface members it doesn't use
- Props are composable (`TypeA & TypeB`)
- Hooks return focused data
- Contexts split by concern (state vs actions)

→ See `interface-segregation.md` for detailed guide
→ See `templates/interface.md` for segregated interfaces

---

## D - Dependency Inversion

**Definition:** Depend on abstractions, not implementations

**React Application:**

- Services receive dependencies via factory
- No direct `fetch()` or `axios` in services
- Context provides services for DI
- Easy to mock for testing

→ See `dependency-inversion.md` for detailed guide
→ See `templates/factory.md` for DI patterns

---

## Decision Flow

```
Unit has more than one reason to change?
└─ Yes → Apply SRP (separate the concerns)

Need to add a feature?
└─ Will it modify existing code?
   └─ Yes → Apply OCP (composition)

Creating an interface implementation?
└─ Apply LSP (respect the contract)

A consumer depends on members it doesn't use?
└─ Yes → Apply ISP (split)

Unit welded to a concrete dependency?
└─ Yes → Apply DIP (inject an abstraction)
```

---

## Where things live

Folder layout is the **host repo's** call — follow its `CLAUDE.md`/conventions. The `modules/[feature]/src/...` + `modules/cores/` layout in `architecture-patterns.md` is one sample structure, not a requirement.

---

## Where to Find Code Templates?

All templates in `references/templates/`:

| Template       | Purpose               |
| -------------- | --------------------- |
| `component.md` | Component patterns    |
| `hook.md`      | Hook patterns         |
| `service.md`   | Service with DI       |
| `store.md`     | Zustand stores        |
| `interface.md` | Interface definitions |
| `validator.md` | Zod schemas           |
| `factory.md`   | Factory/DI patterns   |
| `adapter.md`   | Adapter patterns      |
| `error.md`     | Error classes         |
| `test.md`      | Test patterns         |
