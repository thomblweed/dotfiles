---
description: Review a GitHub PR using Vercel React best-practices, composition, re-render, and SOLID principles skills
argument-hint: "[github PR url]"
allowed-tools: Bash, Read, Write, Grep, Glob, WebFetch, Skill, AskUserQuestion
---

# Review PR

Review a GitHub pull request for React/Next.js quality, focusing on performance,
composition, unnecessary re-renders, and SOLID architecture.

## 1. Get the PR URL

The PR URL passed as an argument (may be empty): `$ARGUMENTS`

- If a GitHub PR URL was provided in the argument, use it.
- If the argument is empty, use `AskUserQuestion` to prompt the user for the
  GitHub PR URL before doing anything else. Do not proceed until you have a URL.

## 2. Fetch the PR diff

Use the `gh` CLI to pull the PR metadata and full diff:

```
gh pr view <url> --json title,body,author,files,additions,deletions,baseRefName,headRefName
gh pr diff <url>
```

If `gh` fails (e.g. not authenticated or the repo isn't checked out locally),
fall back to `WebFetch` on the PR URL to read what you can, and tell the user
what was unavailable.

## 3. Run the review skills

Load and apply all four skills against the changed code, in this order:

1. `Skill(vercel-react-best-practices)` — React/Next.js performance patterns.
2. `Skill(vercel-composition-patterns)` — composition, compound components,
   prop/API design, React 19 changes.
3. `Skill(react-rerender-composition)` — components defined in render, state
   that should move down, heavy siblings, context value re-renders.
4. `Skill(solid-react)` — SOLID architecture (SRP/OCP/LSP/ISP/DIP): a unit that
   fetches, derives, and renders at once; growing `if`/`switch` ladders and
   boolean-prop sprawl; components welded to a concrete client or transport.

Evaluate the diff through each skill's lens. Only report issues that are
actually present in the changed code — do not invent findings to fill sections.

## 4. Report findings in the terminal

Produce a single consolidated review, grouped by the four skill areas above.
For each finding include:

- **File and line** (clickable `path:line`).
- **Severity** — blocker / should-fix / nit.
- **What** the issue is and **why** it matters (cite the relevant skill guidance).
- **Suggested fix** — concrete, minimal, matching the surrounding code style.

End with a short summary: overall assessment and the top 1–3 things to address
first. Never modify the code under review — this command reviews and comments,
it does not fix.

This terminal report is for the user and can carry full reasoning. Anything
posted to GitHub is held to the much tighter limit in step 6.

## 5. Offer to post the findings to the PR

Only if the review produced at least one finding, use `AskUserQuestion` to ask
whether to post them as inline comments on the PR. Skip the question entirely
when there are no findings — just report the clean result.

One question, three options:

1. **Post should-fix + blockers** (recommended) — inline threads for the real
   issues, nits collected in the review body.
2. **Post everything** — an inline thread per finding, nits included.
3. **Don't post** — terminal only.

Do not post anything until the user picks. If they pick option 3, stop.

## 6. Post the review

### Attribution — every posted comment must self-identify as Claude's

`gh api` posts under **your own** GitHub account — there is no separate bot
identity — so a comment that doesn't self-label reads to the PR author as a
manual note from you personally. Every piece of posted text must open with an
explicit AI-authored tag, no exceptions:

- **Review body**: first line is `_🤖 Automated review — posted by Claude
  Code, not manually written._`, then a blank line, then the summary.
- **Each inline comment**: the bold issue line itself carries the tag —
  `**🤖 Claude — <issue name>** (severity)` — so attribution survives even if
  someone reads just that one comment in isolation, out of review-body context.

### Comment style — short and plain

The posted comments must be far shorter than the terminal report. Target
**under 6 lines of prose** per comment, and never more than ~100 words
excluding code. Structure:

1. **One bold line** tagged and naming the issue, with the severity in parens:
   `**🤖 Claude — <issue name>** (severity)`.
2. **One or two sentences** on the concrete failure — what breaks, for whom.
3. **The fix** — a ```suggestion block when it cleanly replaces the anchored
   lines, otherwise one sentence.

Worked example of the right length:

> **🤖 Claude — a11y: labelled variant hides its own text from screen readers** (should-fix)
>
> `role="separator"` has presentational children in ARIA 1.2, so a rich `label`
> is pruned and left unnamed — the "0 Replies • Oldest first" case disappears
> for AT users.
>
> Drop the role from the row and let the leading rule carry it:
>
> ```suggestion
> <div {...rest} className={clsx('flex w-full items-center', className)}>
>   <hr className={clsx('flex-1', RULE_CLASS)} />
>   <span className={LABEL_CLASS}>{label}</span>
>   <hr aria-hidden='true' className={clsx('flex-1', RULE_CLASS)} />
> </div>
> ```
>
> `ariaLabel` can then go (L46, `divider.types.ts:23-32`).

Cut, every time: restatements of skill-doc rationale, alternative approaches the
author didn't ask for, trade-off essays, spec citations beyond a short clause,
and lists of supporting evidence. One clause of provenance is plenty ("7 call
sites in nbl-ui-observability"). If a finding genuinely needs more, put the
detail in the terminal report and keep the comment to the ask.

Nits belong in the review body as one-line bullets (`L15 — …`), never as their
own inline threads.

### Mechanics

Anchor every comment to the line the issue lives on:

- `line` is the line number in the **new** file, with `side: "RIGHT"`. For a
  range, add `start_line` + `start_side: "RIGHT"`.
- Verify anchors against the head version of the file before posting — read it
  with line numbers, don't trust diff arithmetic.
- A finding about a file **outside the diff** still gets an inline comment:
  anchor it to the closest related line that is in the diff (e.g. the JSDoc line
  claiming a component replaces an older one) and name the real file in the body.

Post as a **single review**, so the author gets one notification. Comment bodies
contain backticks and newlines, so build the payload as JSON with `Write` and a
short script rather than inline shell quoting:

```
gh api repos/<owner>/<repo>/pulls/<n>/reviews --input review.json
```

with `{ commit_id: <head.sha>, body: <attribution line + summary + nits>, event: "COMMENT", comments: [...] }`.

Use `event: "COMMENT"`. Never `REQUEST_CHANGES` or `APPROVE` unless the user
explicitly asks for it.

After posting, verify placement and report back the review URL plus a one-line
table of where each comment landed:

```
gh api repos/<owner>/<repo>/pulls/<n>/comments --jq '.[] | select(.pull_request_review_id==<id>) | {line, body: (.body | split("\n")[0])}'
```

Mention that the comments are editable or deletable if the user wants anything
reworded.
