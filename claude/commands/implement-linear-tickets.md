Ask the user: "Please provide one or more Linear ticket numbers or URLs (e.g. UI-51, NBL-12, or https://linear.app/...)"

Wait for the user's response, then for each ticket provided:

1. **Extract the ticket ID** from whatever format was given:
   - Plain ID: `UI-51` → `UI-51`
   - URL: `https://linear.app/netboxlabs/issue/UI-51/some-title` → `UI-51`

2. **Fetch ticket details** using `mcp__claude_ai_Linear__get_issue` with the extracted ID to get the Linear-generated branch name (the `gitBranchName` field) and the `attachments` array.

3. **Use the branch name exactly as Linear provides it** — do not modify or slugify it.
   - Example: `obs-3129-run-history-table-flashes-loading-spinner-on-every-poll`

4. **Pre-fetch plan/ADR attachment content and write a context file.** Archon's `fetch-and-validate-linear-ticket` step runs as a headless subprocess that cannot use the claude.ai Linear connector (it's interactively-authenticated and only available in a live chat session like this one) — it will fail with "Linear MCP tools unavailable in this session" if asked to fetch the ticket itself. Do the fetching here instead, where the connector works, and hand Archon the result as a file:
   - For each attachment whose title contains "plan" or "adr" (case-insensitive), fetch its content with `mcp__claude_ai_Linear__get_attachment`.
   - Write a JSON file to the scratchpad directory at `archon-context-<TICKET-ID>.json`:
     ```json
     {
       "id": "<TICKET-ID>",
       "title": "<title>",
       "description": "<description>",
       "status": "<status>",
       "gitBranchName": "<branch-name>",
       "attachments": [
         { "id": "<attachment-id>", "title": "<attachment-title>", "content": "<fetched content>" }
       ]
     }
     ```
   - Include only the plan/ADR attachments (with their fetched `content`) in this array — other attachment types aren't needed.

5. **Construct the archon command** for each ticket, passing the context file path (prefixed with `@`) instead of the bare ticket ID:
   ```
   archon workflow run implement-linear-ticket-review-only --branch <branch-name> --from develop "@<path-to-archon-context-TICKET-ID.json>"
   ```

Once you have all commands ready, print them out so the user can review them, then ask: "Ready to kick off [N] workflow(s). Shall I run them?"

If the user confirms:

0. Before launching any workflow, start a `caffeinate` process to keep the machine awake for the duration of the run(s) — background workflows can take a long time, and macOS sleep will suspend/kill them:
   ```bash
   caffeinate -dis &
   disown
   echo "caffeinate started with PID $!"
   ```
   Record the PID — it's needed to stop caffeinate once every workflow has finished.

For each ticket:

1. Set the ticket's Linear status to **"In Progress"** before starting the work, using `mcp__claude_ai_Linear__save_issue` with `id: <ticket-id>` and `state: "In Progress"`.

2. Remove any stale worktree for that branch (so Archon always starts fresh from current `develop`):
   ```bash
   WORKTREE_PATH=$(git worktree list --porcelain | awk '/^worktree /{path=$2} /^branch refs\/heads\/<branch-name>$/{print path}') && [ -n "$WORKTREE_PATH" ] && git worktree remove --force "$WORKTREE_PATH" || true
   ```

3. Then run the workflow using Bash with `run_in_background: true`.

Launch all tickets in a single message so they start in parallel. After launching, report back with the branch name for each ticket so the user knows what to watch, and mention that caffeinate is keeping the machine awake until the workflows finish.

Once every launched workflow has reported completion (via its background-task notification), kill the caffeinate process so the machine can sleep normally again:
```bash
kill <caffeinate-pid>
```
Do this even if some workflows fail or are stopped early — caffeinate should never be left running once there's nothing left to babysit.
