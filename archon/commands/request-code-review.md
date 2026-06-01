---
description: Review all changes on this branch against the plan and produce a structured issue report.
---

# Request Code Review

**Workflow ID**: $WORKFLOW_ID

---

Get the git range for all changes on this branch:

```bash
git merge-base HEAD origin/develop
git rev-parse HEAD
```

Use the merge-base output as `BASE_SHA` and HEAD as `HEAD_SHA`.

Then follow the requesting-code-review skill to dispatch the review.

---

## Required Output Format

Your output MUST use exactly these severity labels — the downstream `fix-review-issues` step parses for them by name:

```
## Critical
- <file:line>: <description>

## Important
- <file:line>: <description>

## Minor
- <file:line>: <description>
```

- **Critical**: bugs, correctness errors, security issues, broken behaviour
- **Important**: missing tests for changed code, significant convention violations, risky patterns
- **Minor**: style, naming, optional improvements — these will NOT be auto-fixed

If a category has no findings, omit that section entirely. Do not write "None."
