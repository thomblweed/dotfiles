---
description: Post @claude-code-action review comment on the open PR to trigger an automated agent review.
allowed-tools: Bash
---

# Trigger Claude PR Review

**Workflow ID**: $WORKFLOW_ID

---

Post a comment on the current branch's open PR to trigger the Claude Code Action review agent.

## Step 1: Get the PR number for the current branch

```bash
gh pr view --json number --jq '.number'
```

## Step 2: Post the trigger comment

```bash
gh pr comment <PR_NUMBER> --body "@claude-code-action review"
```

## Step 3: Record the trigger timestamp

Immediately after posting the comment, capture the current UTC time and write it to the artifacts directory so the next workflow node can identify only the review triggered by this run:

```bash
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$ARTIFACTS_DIR/review-trigger-time.txt"
```

Output the PR URL and confirm the comment was posted.
