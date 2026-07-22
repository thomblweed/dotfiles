---
description: Fix all issues from the code-review, performance, and code-standards reports in one coherent pass, reconciling overlapping findings. Prefers composition over memoization.
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

## Code Standards Review Report

$review-code-standards.output

---

## SOLID Principles Review Report

$review-solid-principles.output

---

## Phase 0: VALIDATE INPUT

All four reports above should be non-empty and contain real content (not whitespace or an unfilled variable placeholder). A report counts as missing if it is empty or contains only its literal placeholder text (`$request-code-review.output`, `$check-performance.output`, `$review-code-standards.output`, or `$review-solid-principles.output`).

- If **all four** reports are missing, stop immediately and print:

  ```
  ERROR: No review reports available. request-code-review, check-performance, review-code-standards, and review-solid-principles must run and produce output before this step can execute.
  ```

  Then stop — do not proceed to Phase 1.

- If some reports are present, proceed with those and note in the final report which were missing.

---

## Phase 1: TRIAGE & RECONCILE

Parse **all** reports and build a single combined work list.

The code review report, the code standards report, and the SOLID report all group findings at **Critical / Important / Minor**. The performance report uses **🔴 Remount / 🟠 Unnecessary re-render / 🟡 Context over-broadcast**. Map them onto one ordering:

1. **High** — Critical findings (any report) and 🔴 Remount
2. **Medium** — Important findings (any report) and 🟠 Unnecessary re-render
3. **Low** — Minor findings (any report) and 🟡 Context over-broadcast

**Reconcile overlaps.** The four reviews share scope, so the same underlying issue is often reported more than once under different names. Treat these as ONE finding with a single fix:

- "components defined in render" (performance Pattern 1) ≡ `rerender-no-inline-components` (vercel).
- state-placement findings — performance Pattern 2 ("move state down") and `state-lift-state`.
- composition findings — performance Patterns 3/4 (children/props as slots) and `architecture-compound-components` / `patterns-children-over-render-props`.
- code-smell findings from the standards report often restate one of the above — e.g. "Duplicated Code" ≡ a vercel DRY/extraction rule, "Speculative Generality" ≡ a vercel `architecture-*` rule, and a component-structure smell may restate a performance pattern. Merge any finding that describes the same underlying code into one fix.
- SOLID findings very often restate a finding from another report — **SRP** ≡ the "Divergent Change" / "Large Class" smell (standards) or a state/concern-separation rule (vercel); **OCP** ≡ composition patterns (performance Patterns 3/4, vercel `architecture-compound-components` / `patterns-children-over-render-props`) and boolean-prop / switch smells; **ISP** ≡ `architecture-avoid-boolean-props` / fat-props smells and performance Pattern 5 (context over-broadcast). Merge any SOLID finding that describes the same underlying code as another report into that one fix.

For each merged finding, choose the single change that satisfies every report that raised it. Never queue two competing edits against the same code. When the SOLID report and the standards report disagree, the repo's `CLAUDE.md` wins (the SOLID skill targets a different architecture) — never add JSDoc, relocate types to `src/interfaces/`, or restructure to `modules/cores/` on the strength of a SOLID finding alone.

Low findings should be fixed unless the fix would require introducing an abstraction solely to remove simple duplication — skip those and note them.

If there are no actionable findings across any report, print:

```
No actionable issues found. Nothing to fix.
```

Then stop.

### PHASE_1_CHECKPOINT
- [ ] All findings from all reports listed
- [ ] Overlapping findings merged into single entries
- [ ] Each finding assigned High / Medium / Low

---

## Phase 2: FIX

Fix each finding in priority order (High → Medium → Low).

Five skills are preloaded for this node — their `SKILL.md` files are already in your context and are the **single source of truth** for the correct fix. Their detailed definitions are **not** preloaded; read the relevant ones before applying:

- **`vercel-react-best-practices`** and **`vercel-composition-patterns`** — code-review rules. Each `SKILL.md` is only an index of rule names; the actual rule (with correct/incorrect examples) lives in `rules/<rule-name>.md`. Read the rule file before applying it.
- **`react-rerender-composition`** — performance patterns. The worked before/after examples live in `references/patterns.md`, `references/composition-edge-cases.md`, and `references/memo-patterns.md`. Read the relevant one before editing.
- **`code-review`** — the Standards axis behind the code standards report: the Fowler smell baseline and its binding rules. Apply the fix the smell prescribes, but a documented `CLAUDE.md` rule always wins, and skip anything tooling already enforces.
- **`solid-react`** — the five SOLID principles behind the SOLID report. Read the relevant `references/<principle>.md` before applying, and honour the skill's own "Follow the host repo first" rule: apply the composition/segregation/injection refactor the principle prescribes, keep this repo's layout (`features/<feature>/`, co-located `*.types.ts`) and no-comments style, and let a documented `CLAUDE.md` rule always win.

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
  <bullet list, with file:line, the rule/pattern applied, and a one-line description. Mark merged findings with the axes they came from, e.g. "(review + perf)", "(review + standards)", "(perf + standards)", "(solid + review)", "(solid + standards)">

Skipped:
  <any findings skipped and why>
```
