---
description: Validate a Linear ticket is ready to implement (has exactly one plan file attached). Prefers a pre-fetched context file (see Phase 1) since the claude.ai Linear connector is interactively-authenticated and unavailable to this headless subprocess; falls back to fetching via MCP directly when no context file is given.
argument-hint: "@<path-to-context.json> | <ticket-id-or-url>"
allowed-tools: Bash, Read, Write, mcp__claude_ai_Linear__get_issue, mcp__claude_ai_Linear__get_attachment
---

# Step 1: Fetch and Validate Linear Ticket

**Workflow ID**: $WORKFLOW_ID

---

## Phase 1: PARSE INPUT

If `$ARGUMENTS` starts with `@`, it is a path to a pre-fetched context file, not a ticket ID:

- Strip the leading `@` to get the file path, then Read it as JSON with shape
  `{ id, title, description, status, gitBranchName, attachments: [{ id, title, content }] }`.
  `attachments[].content` holds the attachment body inline — already fetched by the orchestrator
  that had a live, interactively-authenticated Linear session.
- Skip Phase 2 (fetching) entirely — you already have everything Phase 2 would have fetched.
- In Phase 3/4, use the inline `content` field directly instead of calling `mcp__claude_ai_Linear__get_attachment`.
- Go straight to Phase 3.

Otherwise, parse `$ARGUMENTS` to extract the ticket ID for the MCP fallback path:

- If the input contains "linear.app", extract the ticket ID from the URL path
  (e.g. "OBS-123" from "https://linear.app/netboxlabs/issue/OBS-123/...").
- Otherwise use the input directly as the ticket ID.

---

## Phase 2: FETCH TICKET (MCP fallback only — skip if Phase 1 loaded a context file)

Use `mcp__claude_ai_Linear__get_issue` to fetch the ticket:

- Input: `{ "id": "<ticket-id>" }` where `<ticket-id>` is from Phase 1.
- Extract from the response: `id`, `title`, `description`, `status`, `gitBranchName`, and the full `attachments` array.

If the tool is unavailable or the ticket is not found, stop immediately and report the error clearly —
this MCP path only works in an interactive session with the claude.ai Linear connector authenticated;
a headless run should always be given a `@context.json` file instead (see Phase 1).

### PHASE_2_CHECKPOINT
- [ ] Ticket details fetched (id, title, description, status, gitBranchName, attachments)

---

## Phase 3: VALIDATE ATTACHMENTS

Inspect the `attachments` array from Phase 1 (context file) or Phase 2 (MCP fetch). Each attachment has
`id`, `title`, and either inline `content` (context-file path) or a `url` to fetch (MCP fallback path).

Classify each attachment by its title:

- **Plan file**: title contains "plan" (case-insensitive), e.g. `OBS-123-plan.md`
- **ADR file**: title contains "adr" (case-insensitive), e.g. `OBS-123-adr.md`

**If no plan files found**, your final response MUST be exactly this JSON (no prose, no fences):

```
{ "ready": "false", "error": "No plan file found on ticket <ticket-id>. Attach a plan file (filename must contain \"plan\") before running this workflow." }
```

Also write this JSON to `$ARTIFACTS_DIR/validate-status.json`. Then **stop — do not proceed to Phase 4 or beyond**.

**If more than one plan file found**, your final response MUST be exactly this JSON (no prose, no fences):

```
{ "ready": "false", "error": "Multiple plan files found on ticket <ticket-id>: <name1>, <name2>. Remove the extra attachments, leaving only the one to implement." }
```

Also write this JSON to `$ARTIFACTS_DIR/validate-status.json`. Then **stop — do not proceed to Phase 4 or beyond**.

### PHASE_3_CHECKPOINT
- [ ] Exactly one plan file confirmed present

---

## Phase 4: FETCH AND PERSIST ATTACHMENT CONTENT

```bash
mkdir -p "$ARTIFACTS_DIR"
```

- **Context-file path (Phase 1 loaded `@context.json`)**: the plan attachment's `content` field is already
  in hand — write it directly to `$ARTIFACTS_DIR/plan.md`. No tool call needed.
- **MCP fallback path**: use `mcp__claude_ai_Linear__get_attachment` with the plan attachment's `id` to
  retrieve its content, then write it to `$ARTIFACTS_DIR/plan.md`.

If an ADR file is present, persist it the same way (inline `content` or MCP fetch) to `$ARTIFACTS_DIR/adr.md`.

### PHASE_4_CHECKPOINT
- [ ] Plan file content written to `$ARTIFACTS_DIR/plan.md`
- [ ] ADR file content written to `$ARTIFACTS_DIR/adr.md` (if present)

---

## Phase 5: REPORT

Write the success status to `$ARTIFACTS_DIR/validate-status.json`:
```json
{ "ready": "true", "error": "" }
```

Then print a human-readable summary:

```
Ticket:      <id> — <title> (<status>)
Plan file:   <plan filename> → written to $ARTIFACTS_DIR/plan.md
ADR file:    <adr filename> → written to $ARTIFACTS_DIR/adr.md  (or "none")
Branch:      <branch name>

Ready to implement.
```

Your final output MUST be exactly this JSON (no prose, no fences) — the workflow reads this to decide whether to continue:

```
{ "ready": "true", "error": "" }
```
