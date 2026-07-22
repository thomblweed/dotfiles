---
description: Review all changes on this branch against the five SOLID principles using the solid-react skill, and produce a suggestions-only report. No changes are applied.
---

# Review SOLID Principles

**Workflow ID**: $WORKFLOW_ID

---

Get the git range for all changes on this branch:

```bash
git merge-base HEAD origin/develop
git rev-parse HEAD
```

Use the merge-base output as `BASE_SHA` and HEAD as `HEAD_SHA`, then collect the diff:

```bash
git diff BASE_SHA..HEAD_SHA
```

---

## How to Review

The **`solid-react`** skill is preloaded for this node — its `SKILL.md` is already in
your context. Review the diff against the **five SOLID principles** it documents:

1. **SRP** — Single Responsibility: a component, hook, or module with more than one
   reason to change (mixing data-fetching, business logic, and presentation; a hook
   that both fetches and formats; a component doing orchestration and rendering).
2. **OCP** — Open/Closed: code extended by modification rather than composition
   (growing `if`/`switch` ladders on a type field, boolean-prop proliferation) where a
   render-prop, slot, strategy map, or compound component would let it extend cleanly.
3. **LSP** — Liskov Substitution: implementations or prop variants that don't honour
   the contract their type/interface promises, so a caller can't swap one for another.
4. **ISP** — Interface Segregation: fat props objects, fat interfaces, or overloaded
   contexts that force consumers to depend on fields they don't use — split into
   focused roles.
5. **DIP** — Dependency Inversion: a component or hook wired to a concrete
   implementation (a specific client/transport/service) where it should depend on an
   abstraction passed in (props, context, injected factory).

The per-principle detail files are **not** preloaded — read the relevant one before
deciding a finding, so each suggestion matches the principle the skill prescribes:

- `references/single-responsibility.md`
- `references/open-closed.md`
- `references/liskov-substitution.md`
- `references/interface-segregation.md`
- `references/dependency-inversion.md`

Do not flag a principle from memory; confirm against its reference file.

This node is itself the parallel review unit in the workflow, so run the SOLID review
**inline as a single agent** — do **not** spawn sub-agents.

The skill's "Follow the host repo first" rule binds this review: this repo's `CLAUDE.md`
is the source of truth for structure and style, so judge SRP/ISP against **this repo's**
layout (`features/<feature>/`, co-located `*.types.ts`) and never report a finding that
would fight a repo convention — in particular, do **not** suggest adding JSDoc/comments
(the repo prefers declarative code over comments) or relocating types. Skip anything
lint/typecheck already enforces.

Report only genuine SOLID *design* issues in the diff, each labelled with the principle
it maps to. Every finding is a **judgement call** — none is a hard violation.

**This is review-only.** Do NOT edit, fix, or apply any change. The report is for a
human (and the downstream fix step) to act on afterwards.

---

## Required Output Format

Produce a single Markdown report. Order findings by severity. For every finding include
the file and line, the SOLID principle it maps to, what's wrong, and the suggested change.

```
# SOLID Principles Review Report

## Summary
<1-3 sentence overview: how many findings, which principles, overall design risk>

## Critical
- <file:line> — [<SRP|OCP|LSP|ISP|DIP>]: <what's wrong> → <suggested change>

## Important
- <file:line> — [<SRP|OCP|LSP|ISP|DIP>]: <what's wrong> → <suggested change>

## Minor
- <file:line> — [<SRP|OCP|LSP|ISP|DIP>]: <what's wrong> → <suggested change>
```

- **Critical**: a responsibility or dependency tangle that will cause bugs or block
  change — e.g. a component owning fetching + logic + rendering that must be split, or a
  concrete dependency that makes a unit untestable.
- **Important**: a clear SOLID improvement with a concrete refactor — split a fat
  props/context (ISP), replace a modification ladder with a composition seam (OCP),
  extract a mixed concern (SRP).
- **Minor**: lighter judgement-call improvements where the fix is optional.

If a severity section has no findings, omit that section entirely. Do not write "None."
If the review surfaces nothing, state that explicitly in the Summary.
