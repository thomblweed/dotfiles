---
description: Approve, in your name, the GitHub PRs a Slack message links
argument-hint: <slack-message-url>
allowed-tools: Bash, ToolSearch, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_add_reaction
---

Approve on GitHub, as you, every PR linked in the Slack message at `$ARGUMENTS`, then tick the message.

## Steps

1. Parse the URL. It looks like `https://<workspace>.slack.com/archives/<channel_id>/p<digits>`, sometimes with `?thread_ts=<ts>&cid=<channel_id>` when the message is a thread reply.
   - `channel_id` is the path segment after `/archives/`.
   - The message `ts` is `<digits>` with a decimal point before the last six digits: `p1793103126210389` → `1793103126.210389`.
   - If `$ARGUMENTS` holds no Slack message URL, ask for one and stop.

2. Load the Slack tool schemas with ToolSearch: `select:mcp__claude_ai_Slack__slack_read_thread,mcp__claude_ai_Slack__slack_add_reaction`.

3. Read that one message:
   - No `thread_ts`, or `thread_ts` equals `ts`: call `slack_read_thread` with `channel_id`, `message_ts: ts` and `limit: 1`. The parent message is the one.
   - `thread_ts` differs from `ts` (a reply): call `slack_read_thread` with `channel_id` and `message_ts: thread_ts`, then take the message whose `Message TS` equals `ts`.
   - If the message can't be read, report the Slack error and stop.

4. Extract every match of `github\.com/([^/\s|>]+)/([^/\s|>]+)/pull/(\d+)` from the message text and canonicalize each to `https://github.com/<owner>/<repo>/pull/<number>`, deduplicated. This ignores Slack's `<url|text>` wrapping, trailing slashes, query strings and `/files` or `.diff` suffixes. If there are none, say the message links no PRs and stop.

5. Get your login with `gh api user -q .login`, then for each PR run:

   ```bash
   gh pr view <url> --json number,title,state,isDraft,author,latestReviews
   ```

   Skip the PR, with the reason, when:
   - its author is you (GitHub refuses a self-approval)
   - its `state` isn't `OPEN`
   - `isDraft` is true
   - your entry in `latestReviews` is already `APPROVED`

6. Approve each remaining PR with `gh pr review <url> --approve`, no body. If one fails, record the error and carry on with the rest.

7. Unless an approval failed, add the `white_check_mark` reaction to the message with `slack_add_reaction`, using `channel_id` and the message's own `ts` (not `thread_ts`). If any approval failed, leave the message unticked.

8. Report one line per PR: the repo and number as a link, its title, and `approved`, `skipped: <reason>` or `failed: <error>`. Then say whether the message was ticked.

## Notes

- Don't ask for confirmation before approving: running the command is the go-ahead.
- Only the PRs the linked message itself contains. Never the thread's other replies, never a search.
- Don't review the diff, comment or request changes. In Slack, the `white_check_mark` reaction is the only thing to add: no other reaction, no reply.
