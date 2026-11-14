---
name: solid-react
description: SOLID principles (SRP/OCP/LSP/ISP/DIP) for React. Use when designing or reviewing React component/hook/module architecture, splitting an over-large component, or auditing a diff for SOLID violations.
version: 2.1.0
user-invocable: true
references: references/solid-principles.md, references/single-responsibility.md, references/open-closed.md, references/liskov-substitution.md, references/interface-segregation.md, references/dependency-inversion.md, references/architecture-patterns.md, references/templates/component.md, references/templates/hook.md, references/templates/service.md, references/templates/store.md, references/templates/interface.md, references/templates/validator.md, references/templates/factory.md, references/templates/adapter.md, references/templates/error.md, references/templates/test.md
---

# SOLID React

The five principles are the whole skill. Judge every design and every diff against them by name — **SRP, OCP, LSP, ISP, DIP** — and open the matching reference when you need the worked pattern.

|       | Principle             | Design target                                       | Reads as a violation when                                                          |
| ----- | --------------------- | --------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **S** | Single Responsibility | one component / hook / module, one reason to change | a single unit fetches, derives, and renders at once                                |
| **O** | Open/Closed           | extend by composition, not modification             | adding a case means editing a growing `if`/`switch` ladder or another boolean prop |
| **L** | Liskov Substitution   | implementations honour their type's contract        | a caller can't swap one implementation or variant for another                      |
| **I** | Interface Segregation | focused props, hooks, and contexts                  | a consumer depends on fields it never uses                                         |
| **D** | Dependency Inversion  | depend on an injected abstraction                   | a unit is welded to a concrete client / transport it can't replace                 |

Detail — open the reference before deciding a fix: `references/single-responsibility.md`, `open-closed.md`, `liskov-substitution.md`, `interface-segregation.md`, `dependency-inversion.md`. Overview: `references/solid-principles.md`.

## Follow the host repo first

This skill governs **design**, not folder names. File layout, where types live, comment/JSDoc style, and which router / store / data-fetching library to use belong to the repo you are in — read its `CLAUDE.md` (or equivalent) and match its conventions. A documented repo convention **always wins** over any example here (the `modules/cores/` + TanStack-Router + Zustand layout in `architecture-patterns.md` is one sample architecture, not a requirement).

Line count and method count are **signals that prompt a look, never the verdict** — the verdict is always the principle itself. A 120-line column-definition file can be fine; a 40-line component that fetches, transforms, and renders is not. The signals are one table in `references/single-responsibility.md`, and where the host repo lints size, its limits win.

## Branch — designing or building

1. Read the surrounding code first and match its structure, naming, and patterns.
2. Reuse behaviour, not markup — reuse an existing hook, helper or behaviour-carrying component, extract repeated logic at its third copy, and compose a compound's parts at the call site rather than wrap them (the host repo's rule wins; in nbl-ui-observability, `.claude/rules/component-organisation.md`).
3. Name the principle you are serving, take the pattern from its reference, and keep each unit to a single responsibility.

Ready-to-adapt patterns live in `references/templates/` (component, hook, service, store, interface, validator, factory, adapter, error, test).

## Branch — reviewing a diff

Judge the diff against the five principles and produce suggestions for a human or a downstream fix step — do **not** edit.

- Every SOLID finding is a **judgement call**, not a hard rule. Report the principle, `file:line`, what's wrong, and the concrete refactor.
- If the caller (e.g. a workflow command) specifies an output format, use it; otherwise group findings by severity.
- Skip anything the repo's tooling already enforces (formatting, lint, types) and anything that only restates a repo convention.
- Drop a duplication (DRY or OCP) finding unless it names observed pain — drift, a bug, real editing friction — and never raise one above a nit.
