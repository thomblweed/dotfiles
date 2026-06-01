---
description: Fix Critical and Important issues identified in a code review report.
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

Parse the review report above. Extract all **Critical** and **Important** issues.
Ignore Minor issues.

If there are no Critical or Important issues, print:

```
No Critical or Important issues found. Nothing to fix.
```

Then stop.

### PHASE_1_CHECKPOINT
- [ ] All Critical issues listed
- [ ] All Important issues listed

---

## Phase 2: FIX

Fix each Critical and Important issue in the order listed.

Rules:
- Fix exactly what the reviewer identified — do not introduce unrelated changes.
- Follow the existing patterns and conventions in the codebase.

### PHASE_2_CHECKPOINT
- [ ] Every Critical issue fixed
- [ ] Every Important issue fixed

---

## Phase 3: REPORT

Print a concise summary:

```
Fixed:
  <bullet list of issues fixed, with file:line and one-line description>

Skipped:
  <any issues skipped and why — should be empty>
```
