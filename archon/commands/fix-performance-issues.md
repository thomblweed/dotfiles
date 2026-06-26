---
description: Fix re-render performance issues identified in a performance review report, using composition over memoization.
---

# Fix Performance Issues

**Workflow ID**: $WORKFLOW_ID

---

## Performance Review Report

$check-performance.output

---

## Phase 0: VALIDATE INPUT

Check that the review report above is non-empty and contains actual content (not just whitespace or an unfilled variable placeholder).

If the report is empty or contains only the literal text `$check-performance.output`, stop immediately and print:

```
ERROR: No performance report available. The check-performance step must run and produce output before this step can execute.
```

Then stop — do not proceed to Phase 1.

---

## Phase 1: TRIAGE

Parse the review report above. Extract all 🔴 **Remount**, 🟠 **Unnecessary re-render**, and 🟡 **Context over-broadcast** findings.

If there are no findings, print:

```
No actionable performance issues found. Nothing to fix.
```

Then stop.

### PHASE_1_CHECKPOINT
- [ ] All 🔴 Remount (Pattern 1) findings listed
- [ ] All 🟠 Unnecessary re-render (Patterns 2–4) findings listed
- [ ] All 🟡 Context over-broadcast (Pattern 5) findings listed

---

## Phase 2: FIX

Fix each finding in severity order (🔴 → 🟠 → 🟡).

The **`react-rerender-composition`** skill is preloaded for this node — its
`SKILL.md` is already in your context and is the **single source of truth** for how
each pattern is fixed. Its worked before/after examples are **not** preloaded; for
each finding, read the relevant detail file before editing so your refactor matches
the skill's prescribed shape:

- `references/patterns.md` — the canonical transformation for Patterns 1–5
- `references/composition-edge-cases.md` — stable callbacks, context selectors, key
  stability, and cases where composition can't help
- `references/memo-patterns.md` — the only sanctioned memoization fallbacks

Rules:
- **Prefer composition over memoization** — apply the pattern the report cites (move
  the component to module scope, move state down, pass heavy children via
  `children`/named props, split the context). Use `memo`/`useMemo`/`useCallback` only
  where the report explicitly flagged it as the fallback and the skill agrees
  composition can't isolate the re-render.
- Fix exactly what the reviewer identified — do not introduce unrelated changes.
- Follow the existing patterns and conventions in the codebase.
- Preserve behavior — these are structural refactors, not feature changes.

### PHASE_2_CHECKPOINT
- [ ] Every 🔴 Remount finding fixed
- [ ] Every 🟠 Unnecessary re-render finding fixed
- [ ] Every 🟡 Context over-broadcast finding fixed

---

## Phase 3: REPORT

Print a concise summary:

```
Fixed:
  <bullet list of issues fixed, with file:line, the pattern applied, and one-line description>

Skipped:
  <any findings skipped and why — e.g. "Pattern 5: context is single-consumer, no over-broadcast in practice">
```
