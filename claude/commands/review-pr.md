---
description: Review a GitHub PR using Vercel React best-practices, composition, re-render, and SOLID principles skills
argument-hint: "[github PR url]"
allowed-tools: Bash, Read, Grep, Glob, WebFetch, Skill, AskUserQuestion
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

## 4. Report findings

Produce a single consolidated review, grouped by the four skill areas above.
For each finding include:

- **File and line** (clickable `path:line`).
- **Severity** — blocker / should-fix / nit.
- **What** the issue is and **why** it matters (cite the relevant skill guidance).
- **Suggested fix** — concrete, minimal, matching the surrounding code style.

End with a short summary: overall assessment and the top 1–3 things to address
first. This is a read-only review — report findings only, do not modify code.
