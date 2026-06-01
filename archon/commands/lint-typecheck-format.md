---
description: Run lint and typecheck then fix any issues found.
---

# Lint and Typecheck

**Workflow ID**: $WORKFLOW_ID

---

Run each check in sequence and fix any failures before moving to the next.

## Step 1: Lint

```bash
npm run lint
```

Fix all errors and warnings reported. Re-run until clean.

## Step 2: Typecheck

```bash
npm run typecheck
```

Fix all type errors reported. Re-run until clean.

---

## Report

```
lint:       passing
typecheck:  passing
```
