---
description: Audit all changes on this branch for unnecessary React re-renders using the react-rerender-composition skill, and produce a suggestions-only report. No changes are applied.
---

# Check Performance

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

The **`react-rerender-composition`** skill is preloaded for this node — its
`SKILL.md` (decision tree, the five patterns, audit-mode steps, and the severity
scheme) is already in your context and is the **single source of truth**.

Run the skill's **audit mode** over the diff: scan systematically for the five
re-render patterns it defines (component-in-render, state-too-high, stateful wrappers
with heavy children, overloaded contexts).

The skill's worked examples are **not** preloaded — read the relevant detail file
before deciding a fix, so each suggestion matches the skill's prescribed
transformation:

- `references/patterns.md` — full before/after for all five patterns
- `references/composition-edge-cases.md` — stable callbacks via ref, context
  selectors, key stability, and when composition can't help
- `references/memo-patterns.md` — when (and only when) to fall back to
  `memo`/`useMemo`/`useCallback`

Prefer composition; suggest memoization only where the skill says composition can't
isolate the re-render, and say why.

**This is review-only.** Do NOT edit, fix, or apply any change. The report is for a
human (and the downstream fix step) to act on afterwards.

---

## Required Output Format

Produce a single Markdown report. Order findings by severity using the skill's
severity scheme. For every finding include the file and approximate line, which
pattern applies, what's wrong, and the suggested fix.

```
# Performance Review Report

## Summary
<1-3 sentence overview: how many findings, which patterns, overall re-render risk>

## 🔴 Remount (Pattern 1)
- <file:line> — [Pattern 1]: <what's wrong> → <suggested fix>

## 🟠 Unnecessary re-render (Patterns 2–4)
- <file:line> — [Pattern N]: <what's wrong> → <suggested fix>

## 🟡 Context over-broadcast (Pattern 5)
- <file:line> — [Pattern 5]: <what's wrong> → <suggested fix>
```

- **🔴 Remount (Pattern 1)**: highest impact — causes DOM teardown and state reset.
- **🟠 Unnecessary re-render (Patterns 2–4)**: wasted renders on every state change.
- **🟡 Context over-broadcast (Pattern 5)**: scales with the number of consumers.

If a severity section has no findings, omit that section entirely. Do not write
"None." If the skill surfaces nothing, state that explicitly in the Summary.
