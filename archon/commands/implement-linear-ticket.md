---
description: Implement the plan attached to a Linear ticket. Reads plan and ADR content from artifacts written by the fetch-and-validate step.
argument-hint: <ticket-id-or-url>
---

# Implement Linear Ticket

**Workflow ID**: $WORKFLOW_ID

---

## Phase 1: LOAD PLAN AND ADR FROM ARTIFACTS

The validate step has already fetched and written the plan and ADR files to disk.

Read `$ARTIFACTS_DIR/plan.md`. If this file does not exist, stop immediately and report:
```
ERROR: $ARTIFACTS_DIR/plan.md not found.
The fetch-and-validate step must run before this step.
Do not ask clarifying questions. Do not use the ticket description as a substitute.
```

Check whether `$ARTIFACTS_DIR/adr.md` exists. If it does, read it too — it describes architectural decisions that constrain the implementation.

### PHASE_1_CHECKPOINT
- [ ] Plan content loaded from `$ARTIFACTS_DIR/plan.md`
- [ ] ADR content loaded from `$ARTIFACTS_DIR/adr.md` (or confirmed absent)

---

## Phase 2: IMPLEMENT

Implement exactly what the plan specifies. Follow the ADR decisions where they apply.

Rules:
- Do not write unit tests. Skip any test-related steps mentioned in the plan.
- Do not add features, refactor, or introduce abstractions beyond what the plan requires.
- Follow the existing patterns and conventions in the codebase.

### PHASE_2_CHECKPOINT
- [ ] All plan tasks implemented (excluding tests)
- [ ] ADR decisions respected

---

## Phase 3: REPORT

Print a concise summary:

```
Ticket:   <ticket_id> — <title>
Plan:     <plan filename>
ADR:      <adr filename>  (or "none")

Changes:
  <bullet list of files created or modified>

Skipped:
  <any plan items intentionally skipped, e.g. unit tests>
```
