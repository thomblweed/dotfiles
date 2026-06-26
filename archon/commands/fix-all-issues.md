---
description: Fix all issues from the code-review and performance reports in one coherent pass, reconciling overlapping findings. Prefers composition over memoization.
---

# Fix All Issues

**Workflow ID**: $WORKFLOW_ID

---

## Code Review Report

$request-code-review.output

---

## Performance Review Report

$check-performance.output

---

## Phase 0: VALIDATE INPUT

Both reports above should be non-empty and contain real content (not whitespace or an unfilled variable placeholder).

- If the code review report is empty or contains only the literal text `$request-code-review.output` **and** the performance report is empty or contains only `$check-performance.output`, stop immediately and print:

  ```
  ERROR: No review reports available. request-code-review and check-performance must run and produce output before this step can execute.
  ```

  Then stop — do not proceed to Phase 1.

- If exactly one report is present, proceed with that one and note in the final report that the other was missing.

---

## Phase 1: TRIAGE & RECONCILE

Parse **both** reports and build a single combined work list.

The code review report groups findings by skill at **Critical / Important / Minor**. The performance report uses **🔴 Remount / 🟠 Unnecessary re-render / 🟡 Context over-broadcast**. Map them onto one ordering:

1. **High** — Critical findings and 🔴 Remount
2. **Medium** — Important findings and 🟠 Unnecessary re-render
3. **Low** — Minor findings and 🟡 Context over-broadcast

**Reconcile overlaps.** The two reviews share scope, so the same underlying issue is often reported twice under different names. Treat these as ONE finding with a single fix:

- "components defined in render" (performance Pattern 1) ≡ `rerender-no-inline-components` (vercel).
- state-placement findings — performance Pattern 2 ("move state down") and `state-lift-state`.
- composition findings — performance Patterns 3/4 (children/props as slots) and `architecture-compound-components` / `patterns-children-over-render-props`.

For each merged finding, choose the single change that satisfies every report that raised it. Never queue two competing edits against the same code.

Low findings should be fixed unless the fix would require introducing an abstraction solely to remove simple duplication — skip those and note them.

If there are no actionable findings across either report, print:

```
No actionable issues found. Nothing to fix.
```

Then stop.

### PHASE_1_CHECKPOINT
- [ ] All findings from both reports listed
- [ ] Overlapping findings merged into single entries
- [ ] Each finding assigned High / Medium / Low

---

## Phase 2: FIX

Fix each finding in priority order (High → Medium → Low).

Three skills are preloaded for this node — their `SKILL.md` files are already in your context and are the **single source of truth** for the correct fix. Their detailed definitions are **not** preloaded; read the relevant ones before applying:

- **`vercel-react-best-practices`** and **`vercel-composition-patterns`** — code-review rules. Each `SKILL.md` is only an index of rule names; the actual rule (with correct/incorrect examples) lives in `rules/<rule-name>.md`. Read the rule file before applying it.
- **`react-rerender-composition`** — performance patterns. The worked before/after examples live in `references/patterns.md`, `references/composition-edge-cases.md`, and `references/memo-patterns.md`. Read the relevant one before editing.

Rules:
- **Prefer composition over memoization** — apply the pattern the report cites (move the component to module scope, move state down, pass heavy children via `children`/named props, split the context). Use `memo`/`useMemo`/`useCallback` only where a report explicitly flagged it as the fallback and the skill agrees composition can't isolate the re-render.
- Apply ONE coherent edit per merged finding — do not let a code-review fix and a performance fix fight over the same lines.
- Fix exactly what the reports identified — no unrelated changes.
- Follow the existing codebase conventions and preserve behavior (these are structural refactors, not feature changes).

### PHASE_2_CHECKPOINT
- [ ] Every High finding fixed
- [ ] Every Medium finding fixed
- [ ] Every actionable Low finding fixed
- [ ] No file left inconsistent by competing edits

---

## Phase 3: REPORT

Print a concise summary:

```
Fixed:
  <bullet list, with file:line, the rule/pattern applied, and a one-line description. Mark merged findings as "(review + perf)">

Skipped:
  <any findings skipped and why>
```
