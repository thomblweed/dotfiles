---
description: Send a Slack message listing your open PRs ready for review
---

Send a Slack message to `#project-nbl-ui-platform` listing your open PRs ready for review.

## Steps

1. Run `gh search prs --owner netboxlabs --author @me --state open --draft=false --json number,title,url,repository` to get open, non-draft PRs across the whole `netboxlabs` org.

2. If there are no open PRs, tell the user and stop.

3. Drop any PRs that have already been posted to the channel. This step must be **deterministic** — do not rely on Slack search; read history directly and match on canonical PR paths.
   - Load tool schemas with ToolSearch: `select:mcp__claude_ai_Slack__slack_search_channels,mcp__claude_ai_Slack__slack_read_channel`
   - Resolve `#project-nbl-ui-platform` to a `channel_id` with `slack_search_channels` (skip if you already know the ID).
   - Call `slack_read_channel` with that `channel_id` and `limit: 100`. If the oldest returned message is newer than ~30 days ago, paginate with `cursor` until you've covered ~30 days (cap at 5 pages as a safety stop).
   - From every message's text, regex-extract all matches of `github\.com/[^/\s|>]+/[^/\s|>]+/pull/\d+` and canonicalize each to the captured `<owner>/<repo>/pull/<number>` triplet. This ignores `<url|text>` Slack link wrapping, trailing slashes, query strings, and `.diff`/`.patch` suffixes. Collect into a `postedSet`.
   - For each PR from step 1, compute the same `<owner>/<repo>/pull/<number>` triplet from its `url` and drop it if present in `postedSet`.
   - If the filtered list is empty, tell the user "All your open PRs have already been posted — nothing new to send" and stop.
   - Briefly log how many PRs were dropped and which ones, so the user can sanity-check the dedup before the Slack post.

4. Write the summary line yourself, without prompting the user. If the user supplied a summary in the command arguments, use that verbatim instead.
   - **One short sentence, 12 words at most.** Say what changes, not how or why.
   - Write it from the PR titles alone. Don't read the PR bodies or Linear tickets for it: that's where the excess detail comes from.
   - Leave out ticket IDs, file, component and flag names, follow-up work, rationale and caveats. Reviewers get those from the PR.
   - For several PRs, name what they have in common rather than listing each one, and never chain separate changes with "and".
   - Good: "Fix the assign discovery job button on the agent details page"
   - Good: "A New Policy button and empty New Policy page for Telemetry"
   - Too wordy: "Add a New Policy button to the Telemetry Policies page, opening a heading-only New Policy page that MON-555's create form will fill, and mark the Observability designs as prototypes only in the docs."

5. Format the message like this — plain text, no emoji header:

```
<one-line summary>

PR(nbl-ui-observability): <https://github.com/...|PR title>
PR(nbl-ui-observability): <https://github.com/...|Another PR title>
```

- One `PR(repo-name):` line per PR using Slack's `<url|text>` link syntax
- Use the repo short name from each PR's `repository.name` field (e.g. `nbl-ui-observability`, not the full `netboxlabs/nbl-ui-observability` path)

6. Load the Slack send tool schema with ToolSearch: `select:mcp__claude_ai_Slack__slack_send_message`

7. Use `mcp__claude_ai_Slack__slack_send_message` to post to channel `#project-nbl-ui-platform`.

8. Report back with the Slack message permalink.

## Notes

- Org: `netboxlabs` (scans all repos in the org)
- Channel: `#project-nbl-ui-platform`
- Drafts are excluded via `--draft=false`
- Keep the message short: the summary line and the PR links, nothing else. No PR body excerpts, labels, ticket IDs or extra sentences
