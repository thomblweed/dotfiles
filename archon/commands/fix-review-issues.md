---
description: Fix Critical, Important, and Minor issues identified in a code review report.
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

Parse the review report above. Extract all **Critical**, **Important**, and **Minor** issues.

Minor issues should be fixed unless the fix would require introducing an abstraction solely to eliminate duplicated code — when the duplication is simple and the abstraction would add indirection without meaningful benefit, skip it and note it in the Skipped list.

If there are no Critical, Important, or Minor issues, print:

```
No actionable issues found. Nothing to fix.
```

Then stop.

### PHASE_1_CHECKPOINT
- [ ] All Critical issues listed
- [ ] All Important issues listed
- [ ] All Minor issues listed, with a note on each: fix or skip (with reason)

---

## Phase 2: FIX

Fix each Critical, Important, and actionable Minor issue in the order listed.

Rules:
- Fix exactly what the reviewer identified — do not introduce unrelated changes.
- Follow the existing patterns and conventions in the codebase.
- For Minor issues: apply the simplest fix that resolves the concern. Do not introduce a new abstraction or helper just to deduplicate a few lines — prefer the straightforward inline fix.

### PHASE_2_CHECKPOINT
- [ ] Every Critical issue fixed
- [ ] Every Important issue fixed
- [ ] Every actionable Minor issue fixed

---

## Phase 3: REPORT

Print a concise summary:

```
Fixed:
  <bullet list of issues fixed, with file:line and one-line description>

Skipped:
  <any issues skipped and why — e.g. "Minor: abstraction would add indirection for no gain">
```
