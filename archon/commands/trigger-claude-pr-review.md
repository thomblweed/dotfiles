---
description: Post @claude-code-action review comment on the open PR to trigger an automated agent review.
allowed-tools: Bash
---

# Trigger Claude PR Review

**Workflow ID**: $WORKFLOW_ID

---

Run these bash commands now, in order:

1. Get the PR number:
```bash
gh pr view --json number --jq '.number'
```

2. Post the trigger comment (substitute the PR number from step 1):
```bash
gh pr comment <PR_NUMBER> --body "@claude-code-action review"
```

3. Record the trigger timestamp:
```bash
mkdir -p "$ARTIFACTS_DIR" && date -u +"%Y-%m-%dT%H:%M:%SZ" > "$ARTIFACTS_DIR/review-trigger-time.txt"
```

Output the PR URL and confirm the comment was posted.
