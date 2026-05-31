---
description: Fetch a Linear ticket via MCP and validate it is ready to implement (has exactly one plan file attached).
argument-hint: <ticket-id-or-url>
---

# Step 1: Fetch and Validate Linear Ticket

**Workflow ID**: $WORKFLOW_ID

---

## Phase 1: PARSE INPUT

Parse `$ARGUMENTS` to extract the ticket ID:

- If the input contains "linear.app", extract the ticket ID from the URL path
  (e.g. "OBS-123" from "https://linear.app/netboxlabs/issue/OBS-123/...").
- Otherwise use the input directly as the ticket ID.

---

## Phase 2: FETCH TICKET

Use the Linear MCP tools to:

1. Fetch the full ticket: id, title, description, status.
2. List all attachments on the ticket (name and URL for each).

If the Linear MCP tools are unavailable or the ticket cannot be found,
stop immediately and report the error clearly.

### PHASE_2_CHECKPOINT
- [ ] Ticket details fetched (id, title, description, status)
- [ ] All attachments listed with name + URL

---

## Phase 3: VALIDATE ATTACHMENTS

Classify each attachment:

- **Plan file**: filename contains "plan" (case-insensitive), e.g. `OBS-123-plan.md`
- **ADR file**: filename contains "adr" (case-insensitive), e.g. `OBS-123-adr.md`

**If no plan files found**, stop and output:
```
ERROR: No plan file found on ticket <ticket-id>.
Attach a plan file (filename must contain "plan") before running this workflow.
```

**If more than one plan file found**, stop and output:
```
ERROR: Multiple plan files found on ticket <ticket-id>.
Remove the extra plan attachments from the ticket, leaving only the one to implement.

Available plans:
  - <name1>
  - <name2>
  ...
```

### PHASE_3_CHECKPOINT
- [ ] Exactly one plan file confirmed present

---

## Phase 4: REPORT

Print a summary:

```
Ticket:      <id> — <title> (<status>)
Plan file:   <plan filename>
ADR file:    <adr filename>  (or "none")

Ready to implement.
```

If any ADR files are present, list them (they will be picked up by the implement step).
