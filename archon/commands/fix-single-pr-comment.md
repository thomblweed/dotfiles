---
description: Fix a single critical or important PR review comment in isolation.
argument-hint: <self-contained description of the issue to fix>
---

# Fix Single PR Review Comment

**Workflow ID**: $WORKFLOW_ID

---

## Issue to Address

$ARGUMENTS

---

## Instructions

Fix exactly the issue described above. No more, no less.

Rules:
- Read the relevant files to understand context before making changes.
- Fix only what the issue describes — do not refactor surrounding code or fix unrelated issues.
- Follow existing patterns and conventions in the codebase.
- If the fix spans multiple files, make all necessary changes.
- Do not modify test files unless the issue explicitly requires it.

## CHECKPOINT
- [ ] Issue is fully addressed
- [ ] No unrelated changes introduced
- [ ] Existing patterns and conventions followed
