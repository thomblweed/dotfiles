---
description: Run a grill-with-docs session to stress-test a plan, then create a Linear ticket with all session docs attached.
allowed-tools: Bash, Read, Write, Edit, mcp__claude_ai_Linear__save_issue, mcp__claude_ai_Linear__prepare_attachment_upload, mcp__claude_ai_Linear__create_attachment_from_upload, mcp__claude_ai_Linear__get_issue, mcp__claude_ai_Linear__get_attachment, mcp__claude_ai_Linear__delete_attachment, mcp__claude_ai_Linear__list_projects, mcp__claude_ai_Linear__list_issue_labels
---

# Grill to Linear

Runs a `/grill-with-docs` session to stress-test a plan, then attaches all session docs to a Linear ticket (existing or new).

## Step 1: Grill session

Ask the user to describe the plan or idea they want to grill. **Check whether they reference an existing Linear ticket** (e.g. "grill on NBL-123" or "for ticket NBL-456"). If so, note that ticket ID — it determines the flow from Step 4 onward.

Invoke the `grill-with-docs` skill with the user's description and run the session to completion — until a fully agreed approach with no unresolved decisions is reached.

## Step 2: Write session files

The grill session will have already updated `CONTEXT.md` and created any ADRs (`docs/adr/NNNN-<slug>.md`) inline during the session. Once the approach is agreed, write one additional file:

**`docs/plans/NNNN-plan-<slug>.md`** — the agreed plan, where `NNNN` is the next sequential number and `<slug>` is a short kebab-case description of the plan. Determine the next number by taking the highest existing `NNNN` across both `docs/plans/` and `docs/adr/`:
```bash
{ ls docs/plans/ 2>/dev/null; ls docs/adr/ 2>/dev/null; } | grep -oE '^[0-9]{4}' | sort | tail -1
```
If the command returns nothing (both directories empty or missing), use `0001`. Otherwise increment by 1 and zero-pad to 4 digits (e.g. `0003` → `0004`). Use this single `NNNN` for both the plan file and any ADR files created during the session. Structure:

```markdown
# <Plan title>

## Problem
<What problem this solves and why>

## Approach
<The agreed solution, written precisely using the resolved terminology>

## Key decisions
<Bullet list of the most important decisions made during the grill session>

## Out of scope
<Anything explicitly ruled out>
```

Note which ADR files (if any) were created during the session — they will be attached to the Linear ticket alongside the plan file.

## Step 3: Read session files

Read the plan file written in Step 2 and any ADR files created during the grill session to confirm they are correct before continuing.

## Step 4: Branch — existing ticket or new ticket?

**If the grill session referenced an existing ticket** (ticket ID noted in Step 1), go to **Step 5A**.

**Otherwise**, go to **Step 5B**.

---

## Step 5A: Existing ticket — check for prior attachments

Look up the existing ticket via `mcp__claude_ai_Linear__get_issue` to confirm it exists and note its title.

The `get_issue` response includes the issue's attachments. If the `get_issue` response does not include an `attachments` field, or the field is absent/null, treat it as no prior attachments and proceed directly to Step 6. Otherwise, check whether any attachments that look like plan or ADR files are already attached (titles matching `*-plan-*.md` or `*-adr-*.md`). If such attachments exist, list them and ask the user:

```
The following files are already attached to <ticket-id>:
  - <attachment title 1>
  - <attachment title 2>

Replace them with the new files, or attach additionally?
  R — Replace (existing attachments will be deleted first)
  A — Attach additionally (keep existing, add new ones)
```

Wait for the user's response. If replacing, note the attachment IDs — they will be deleted via `mcp__claude_ai_Linear__delete_attachment` in Step 6 before uploading. If no prior attachments match, proceed directly to Step 6.

Skip to **Step 6** with the existing ticket ID as the target.

---

## Step 5B: New ticket — collect metadata

Ask the user:

```
Before creating the Linear ticket, provide either:

Option A — copy metadata from an existing ticket:
  Copy from: <ticket ID, e.g. NBL-123>

Option B — specify manually:
  Project: <project name>
  Labels: <label1, label2>  (or "none")
```

Wait for their response before continuing.

**Resolve project and labels:**

- **Option A:** Look up the ticket via `mcp__claude_ai_Linear__get_issue`; copy its project and labels.
- **Option B:** Use `mcp__claude_ai_Linear__list_projects` to find the project ID; use `mcp__claude_ai_Linear__list_issue_labels` to find label IDs. If labels is "none" or empty, omit them.

**Create the Linear issue** via `mcp__claude_ai_Linear__save_issue` with:
- **title**: action-oriented, starts with a verb (Add / Implement / Migrate / Refactor)
- **project**: resolved project ID
- **labels**: resolved label IDs (omit if none)
- **priority**: medium (value: 2)
- **description**: markdown derived from the plan file:

```markdown
## Context
<2–3 sentence summary of the problem and motivation>

## Key decisions
<bullet list of the most important decisions from the grill session>
```

Note the returned issue ID — used to name the attachments. Proceed to **Step 6**.

---

## Step 6: Attach all session files

If the user chose **Replace** in Step 5A, call `mcp__claude_ai_Linear__delete_attachment` for each old attachment ID before uploading.

For each session file (plan file from Step 2 first, then any ADRs created during the grill session in order):

1. Read the file content from its repo path
2. Derive the attachment title by prefixing the Linear issue ID to the filename:
   - plan file → `<issue-id>-<plan-filename>`  (e.g. `NBL-123-0001-plan-use-tanstack-query.md`)
   - ADR file  → `<issue-id>-<adr-filename>`  (e.g. `NBL-123-0001-use-tanstack-query.md`)
3. Call `mcp__claude_ai_Linear__prepare_attachment_upload` with the title and MIME type `text/markdown`
4. Upload the file content to the returned presigned URL:
   ```bash
   curl -X PUT "<presignedUrl>" \
     -H "Content-Type: text/markdown" \
     --data-binary @"<file-path>"
   ```
5. Call `mcp__claude_ai_Linear__create_attachment_from_upload` to link it to the issue

Complete each file fully before starting the next. Do not proceed to Step 7 until every session file is attached.

## Step 7: Delete session docs

Delete the plan file written in Step 2 and any ADR files created during the grill session:
```bash
rm <file1> <file2> ...
```

After deleting, remove any directories that are now empty (e.g. `docs/plans/` if empty, `docs/adr/` if empty, then `docs/` if also empty). Do **not** delete `CONTEXT.md`.

## Step 8: Report

Output:
- The Linear issue URL and title
- Confirmation that all files were attached
- Confirmation that session docs were deleted
