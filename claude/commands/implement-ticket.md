---
description: Branch from develop and implement a Linear ticket from its attached plan, leaving every change uncommitted for review
argument-hint: <ticket ID or Linear URL>
allowed-tools: Bash, Read, Write, Edit, Skill, Agent, mcp__claude_ai_Linear__get_issue, mcp__claude_ai_Linear__list_comments, mcp__claude_ai_Linear__get_attachment, mcp__claude_ai_Linear__list_issue_statuses, mcp__claude_ai_Linear__save_issue
---

# Implement ticket

Ticket: $ARGUMENTS

If no ticket was given above, ask the user: "Please provide a Linear ticket number or URL (e.g. ASUR-1179 or https://linear.app/...)" and wait for the answer before doing anything else.

**Never commit, stage or push.** The user reviews the diff first. Step 3's move to In Progress is the one change this command makes in Linear.

1. **Read the ticket.** Fetch it with `mcp__claude_ai_Linear__get_issue`, noting its team and `statusType`, and its comments with `mcp__claude_ai_Linear__list_comments`. Fetch the plan attachment (`<ID>-NNNN-plan-<slug>.md`) and any ADRs (`<ID>-adr-NNNN-<slug>.md`) with `mcp__claude_ai_Linear__get_attachment`. If there's no plan, ask whether to work from the description alone.
2. **Create the branch.** If `git status --porcelain` shows changes, stop and ask. Otherwise branch from develop with the ticket's `gitBranchName`, unchanged:

   ```bash
   git fetch origin develop
   git switch --no-track -c <gitBranchName> origin/develop
   ```

3. **Move the ticket to In Progress** if its `statusType` is `triage`, `backlog` or `unstarted`. Look up its team's states with `mcp__claude_ai_Linear__list_issue_statuses`, and call `mcp__claude_ai_Linear__save_issue` with the In Progress state's ID. Pass the ID, because the Monitoring team ignores a state passed by name. If the `status` Linear returns isn't In Progress, set it by ID once more. Any other `statusType` stays as it is: In Review and In QA are `started` too, and come after In Progress.
4. **Implement the plan** as written, following `AGENTS.md`, the rules that load and the relevant skills. Update any docs the plan names, and fix any tests the change breaks. Add each attached ADR to `internal-docs/adr/` as `NNNN-<slug>.md`: drop the `<ID>-adr-` prefix and take the next free number after the highest ADR already there, which may differ from the attachment's. Add a row for each to the table in `internal-docs/adr/README.md`. Skip an ADR that's already committed, and cite each by its new number. Where the code has moved on from the plan, keep its intent and note the deviation.
5. **Verify.** Run `npm run check:changed`: the related tests, typecheck, Prettier and ESLint on every file the branch changes, untracked ones included, with nothing staged. When the change touches `packages/`, also run `npm run typecheck` and `npm run test:changed`, because a package's own checks never reach the apps that import it. Fix every error. Then show every new test red: copy the source files you changed aside, restore them from `origin/develop` (`git show origin/develop:<path> > <path>`, and move a file the change adds aside), run the new tests, and copy yours back. A test that stays green is rewritten until it fails, or dropped.
6. **Report** the branch, the ticket's Linear status, what changed, the verification results, which new tests went red without the change and any deviations from the plan.
