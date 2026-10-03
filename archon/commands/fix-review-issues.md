---
description: Fix Critical and Important issues identified in a code review report. Minor issues (nits) are not auto-fixed — they're reported at the end for manual review.
---

# Fix Review Issues

**Workflow ID**: $WORKFLOW_ID

---

## Code Review Report

$request-code-review.output

---

## Phase 0: VALIDATE INPUT

Check that the review report above is non-empty and contains actual content (not just whitespace or an unfilled variable placeholder).

If the report is empty or contains only the literal text `$request-code-review.output`, stop immediately and print:

```
ERROR: No review report available. The request-code-review step must run and produce output before this step can execute.
```

Then stop — do not proceed to Phase 1.

---

## Phase 1: TRIAGE

Parse the review report above. Extract all **Critical** and **Important** issues — these will be fixed.

Extract all **Minor** issues separately as **Nits** — these will NOT be fixed. They are reported at the end for manual review.

If there are no Critical, Important, or Minor issues, print:

```
No actionable issues found. Nothing to fix.
```

Then stop.

### PHASE_1_CHECKPOINT
- [ ] All Critical issues listed
- [ ] All Important issues listed
- [ ] All Minor issues listed under Nits (not to be fixed)

---

## Phase 2: FIX

Fix each Critical and Important issue in the order listed. Do not fix Minor issues — leave them untouched for the Nits report.

Rules:
- Fix exactly what the reviewer identified — do not introduce unrelated changes.
- Follow the existing patterns and conventions in the codebase.

### PHASE_2_CHECKPOINT
- [ ] Every Critical issue fixed
- [ ] Every Important issue fixed
- [ ] No Minor issues touched

---

## Phase 3: REPORT

Print a concise summary:

```
Fixed:
  <bullet list of Critical/Important issues fixed, with file:line and one-line description>

Nits (not fixed — for manual review):
  <bullet list of Minor issues, with file:line and one-line description>
```
