---
description: Implement the plan attached to a Linear ticket. Fetches all ticket data fresh via MCP.
argument-hint: <ticket-id-or-url>
---

# Implement Linear Ticket

**Workflow ID**: $WORKFLOW_ID

---

## Phase 1: PARSE INPUT

Parse `$ARGUMENTS` to extract the ticket ID:

- If the input contains "linear.app", extract the ticket ID from the URL path
  (e.g. "OBS-123" from "https://linear.app/netboxlabs/issue/OBS-123/...").
- Otherwise use the input directly as the ticket ID.

---

## Phase 2: FETCH TICKET AND ATTACHMENTS

Use the Linear MCP tools to:

1. Fetch the full ticket: id, title, description, status.
2. List all attachments on the ticket (name and URL for each).

If the Linear MCP tools are unavailable or the ticket cannot be found, stop and report the error.

Classify attachments:

- **Plan file**: filename contains "plan" (case-insensitive)
- **ADR file**: filename contains "adr" (case-insensitive) and shares the same ticket-ID prefix as the plan file (e.g. `OBS-123-adr.md` is paired when `OBS-123-plan.md` also exists)

If no plan file is found, stop and report:
```
ERROR: No plan file found on ticket <ticket-id>.
Attach a plan file (filename must contain "plan") before running this workflow.
```

### PHASE_2_CHECKPOINT
- [ ] Ticket details fetched
- [ ] Plan file identified
- [ ] ADR file identified (or confirmed absent)

---

## Phase 3: FETCH PLAN AND ADR CONTENT

Fetch the plan file content from its attachment URL using WebFetch.

If a paired ADR file is present, fetch its content from its attachment URL using WebFetch.

### PHASE_3_CHECKPOINT
- [ ] Plan file content fetched and read
- [ ] ADR file content fetched and read (if present)

---

## Phase 4: IMPLEMENT

Read the plan file thoroughly. If an ADR was fetched, read it too — it describes architectural decisions that constrain the implementation.

Implement exactly what the plan specifies. Follow the ADR decisions where they apply.

Rules:
- Do not write unit tests. Skip any test-related steps mentioned in the plan.
- Do not add features, refactor, or introduce abstractions beyond what the plan requires.
- Follow the existing patterns and conventions in the codebase.
### PHASE_4_CHECKPOINT
- [ ] All plan tasks implemented (excluding tests)
- [ ] ADR decisions respected

---

## Phase 5: REPORT

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
