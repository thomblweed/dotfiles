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
