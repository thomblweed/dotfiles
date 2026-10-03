---
description: Run a grilling + domain-modeling session to stress-test a plan, then create a Linear ticket with all session docs attached.
allowed-tools: Bash, Read, Write, Edit, Skill, Agent, mcp__claude_ai_Linear__save_issue, mcp__claude_ai_Linear__prepare_attachment_upload, mcp__claude_ai_Linear__create_attachment_from_upload, mcp__claude_ai_Linear__get_issue, mcp__claude_ai_Linear__get_attachment, mcp__claude_ai_Linear__delete_attachment, mcp__claude_ai_Linear__list_projects, mcp__claude_ai_Linear__list_issue_labels, mcp__claude_ai_Linear__list_users
---

# Grill to Linear

Runs a `grilling` + `domain-modeling` session (the same behavior `/grill-with-docs` describes) to stress-test a plan, then attaches all session docs to a Linear ticket (existing or new).

## Step 1: Grill session

Ask the user to describe the plan or idea they want to grill. **Check whether they reference an existing Linear ticket** (e.g. "grill on NBL-123" or "for ticket NBL-456"). If so, note that ticket ID — it determines the flow from Step 4 onward.

**Then ask which kind of ticket description to write:**

```
What kind of ticket are we creating?
  T — Task / horizontal: technical description (Context + Key decisions)
  G — User Gherkin: user-facing acceptance criteria as Gherkin
      (Feature / Scenario / Given–When–Then)
  P — Placeholder: Gherkin-only, implementation deliberately deferred —
      no grill session, no plan, stays in Backlog
```

Note the choice — it selects the description template in **Step 5B** and nothing else. The grill session, plan file, ADRs, and attachments are identical for T and G. If the session referenced an **existing** ticket (Step 5A), the description is not modified, so this question can be skipped.

**If P (placeholder):** skip the grill session and **Steps 2, 3, and 6** entirely — a placeholder gets no plan file and no attachments. Go straight to **Step 4** (a placeholder is always a new ticket, so it always lands on **Step 5B**), write only the Gherkin description from what the user has given you, and in **Step 8** leave the ticket in **Backlog** instead of Planned.

**Otherwise (T or G):** invoke the `grilling` skill, using the `domain-modeling` skill, with the user's description, and run the session to completion — until a fully agreed approach with no unresolved decisions is reached. (`grill-with-docs` is reserved for direct user invocation and errors if a skill or command tries to invoke it itself — invoking `grilling` + `domain-modeling` directly gets the same effect: the interview, with `CONTEXT.md`/ADRs captured inline via `domain-modeling`.)

## Step 2: Write session files

The grill session will have already updated `CONTEXT.md` and created any ADRs (`docs/adr/NNNN-<slug>.md`) inline during the session. Once the approach is agreed, write one additional file:

**`docs/plans/0001-plan-<slug>.md`** — the agreed plan, where `<slug>` is a short kebab-case description of the plan. Number it `0001` for this ticket regardless of any stray files already sitting in `docs/plans/` or `docs/adr/` — those directories are ephemeral (emptied every session, per Step 7), so anything already there belongs to a different, already-attached ticket and must not be extended. If the session created ADRs, number them independently, sequentially starting at `0001` within this session (`docs/adr/0001-<slug>.md`, `0002-<slug>.md`, …). Plan file structure:

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
- **title**: for a **task/horizontal** ticket, action-oriented starting with a verb (Add / Implement / Migrate / Refactor); for a **user Gherkin** ticket, outcome-oriented describing the user-facing result (e.g. "Build the Credential sets landing page content (empty state)")
- **project**: resolved project ID
- **labels**: resolved label IDs (omit if none)
- **priority**: medium (value: 3 — Linear's scale is 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low). After creating, check the returned `priority.name` is `"Medium"` and correct with a follow-up `save_issue` if not.
- **description**: markdown derived from the plan file, using the template for the ticket type chosen in Step 1:

**Task / horizontal:**

```markdown
## Context
<2–3 sentence summary of the problem and motivation>

## Key decisions
<bullet list of the most important decisions from the grill session>
```

**User Gherkin** — before writing the Gherkin, **Read `~/dotfiles/claude/references/gherkin-guidelines.md`** (vendored from [AutomationPanda/gherkin-guidelines-for-ai](https://github.com/AutomationPanda/gherkin-guidelines-for-ai)) and follow its authoring rules. The block below is an inline ` ```gherkin ` snippet in the ticket description, not a `.feature` file — so apply the guideline's scenario/step rules (one behaviour per scenario, declarative domain-level steps, strict Given→When→Then, observable `Then` outcomes, realistic example data, step data tables over long `And`-chains) and ignore the file-level rules (kebab-case `.feature` filenames, directory layout).

Translate the agreed user-facing behaviour into one `Feature` with one `Scenario` per distinct behaviour. Keep implementation detail out of the description (it lives in the attached plan); the scenarios describe observable behaviour only:

````markdown
## Acceptance criteria (Gherkin)

```gherkin
Feature: <feature name>

  Scenario: <observable behaviour>
    Given <precondition>
    When <action>
    Then <expected outcome>
    And <additional outcome>

  Scenario: <another observable behaviour>
    Given <precondition>
    When <action>
    Then <expected outcome>
```

See the attached plan for full implementation detail.
````

Note the returned issue ID — used to name the attachments. Proceed to **Step 6**.

---

## Step 6: Attach all session files

If the user chose **Replace** in Step 5A, call `mcp__claude_ai_Linear__delete_attachment` for each old attachment ID before uploading.

For each session file (plan file from Step 2 first, then any ADRs created during the grill session in order):

1. Read the file content from its repo path
2. Derive the attachment title from the Linear issue ID and the file type:
   - plan file → `<issue-id>-<plan-filename>`  (e.g. `NBL-123-0001-plan-use-tanstack-query.md`)
   - ADR file  → `<issue-id>-adr-<adr-filename>`  (e.g. `NBL-123-adr-0001-use-tanstack-query.md`)
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

## Step 8: Mark the ticket Planned (and assign new tickets)

A grilled plan is a **planned** ticket — so both newly created and existing tickets should end the session in the **Planned** status. The difference is only whether the assignee is set. The one exception is a **placeholder** ticket (Step 1), which never got a plan, and stays in Backlog.

**Placeholder tickets (Step 1, option P):** assign to the session owner, same as new tickets below, but do **not** change the status — leave it at **Backlog**. A placeholder is deliberately not grilled to completion, so Planned would overstate its readiness.

**New tickets (Step 5B, T or G):** assign to the session owner **and** move to Planned.

1. Resolve the user's Linear account via `mcp__claude_ai_Linear__list_users`, matching by email (`tnewman@netboxlabs.com`).
2. Call `mcp__claude_ai_Linear__save_issue` once with the issue ID, the resolved assignee, and `state: "Planned"`.

**Existing tickets (Step 5A):** move to Planned too, with two guards:

- **Do not change the assignee** — an existing ticket may belong to someone else; leave it as-is.
- **Only advance the status if the ticket has not started.** Using the `statusType` already returned by `get_issue` in Step 5A: if it is `backlog` or `triage`, call `mcp__claude_ai_Linear__save_issue` with the issue ID and `state: "Planned"` only. If it is already `unstarted` (e.g. already Planned/Todo), `started`, `completed`, or `canceled`, **leave the status untouched** — the grill must never regress in-flight or finished work.

## Step 9: Report

Output:
- The Linear issue URL and title
- For a placeholder ticket (Step 1, option P): confirmation it was assigned to the session owner and deliberately left in Backlog (no plan file, no attachments)
- Otherwise: confirmation that all files were attached, and that session docs were deleted
- Confirmation that the ticket was moved to Planned (and, for new tickets, assigned to the session owner) — or, for an existing ticket already started/completed/canceled, that its status was deliberately left untouched
