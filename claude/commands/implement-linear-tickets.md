Ask the user: "Please provide one or more Linear ticket numbers or URLs (e.g. UI-51, NBL-12, or https://linear.app/...)"

Wait for the user's response, then for each ticket provided:

1. **Extract the ticket ID** from whatever format was given:
   - Plain ID: `UI-51` → `UI-51`
   - URL: `https://linear.app/netboxlabs/issue/UI-51/some-title` → `UI-51`

2. **Fetch ticket details** using `mcp__linear-server__get_issue` with the extracted ID to get the Linear-generated branch name (the `branchName` field).

3. **Use the branch name exactly as Linear provides it** — do not modify or slugify it.
   - Example: `obs-3129-run-history-table-flashes-loading-spinner-on-every-poll`

4. **Construct the archon command** for each ticket:
   ```
   archon workflow run implement-linear-ticket --branch <branch-name> --from develop "<TICKET-ID>"
   ```

Once you have all commands ready, print them out so the user can review them, then ask: "Ready to kick off [N] workflow(s). Shall I run them?"

If the user confirms, for each ticket:

1. Remove any stale worktree for that branch (so Archon always starts fresh from current `develop`):
   ```bash
   WORKTREE_PATH=$(git worktree list --porcelain | awk '/^worktree /{path=$2} /^branch refs\/heads\/<branch-name>$/{print path}') && [ -n "$WORKTREE_PATH" ] && git worktree remove --force "$WORKTREE_PATH" || true
   ```

2. Then run the workflow using Bash with `run_in_background: true`.

Launch all tickets in a single message so they start in parallel. After launching, report back with the branch name for each ticket so the user knows what to watch.
