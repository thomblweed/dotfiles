---
description: Review all changes on this branch against the Vercel React skills and produce a suggestions-only report. No changes are applied.
---

# Request Code Review

**Workflow ID**: $WORKFLOW_ID

---

Get the git range for all changes on this branch:

```bash
git merge-base HEAD origin/develop
git rev-parse HEAD
```

Use the merge-base output as `BASE_SHA` and HEAD as `HEAD_SHA`, then collect the diff:

```bash
git diff BASE_SHA..HEAD_SHA
```

---

## How to Review

Two skills are preloaded for this node — their `SKILL.md` files are already in your
context and are the **single source of truth** for what counts as a finding:

1. **`vercel-react-best-practices`** — React/Next.js performance rules.
2. **`vercel-composition-patterns`** — React composition rules.

Each `SKILL.md` is only an **index** — it lists rule names by category (e.g.
`async-parallel`, `rerender-no-inline-components`, `architecture-avoid-boolean-props`).
The actual rule definitions, with correct/incorrect examples, live in per-rule files
that are **not** preloaded. Workflow:

1. Scan the diff and shortlist the rule names whose category could plausibly apply.
2. **Read** each shortlisted rule file before judging it — `rules/<rule-name>.md` in
   the relevant skill (e.g. `rules/async-parallel.md`). Do not flag a rule from its
   name alone; confirm against the rule file.
3. Record every violation, citing the exact rule name it maps to.

Do not rely on memory or a summary of these skills — judge only against the rule
files you have read.

**This is review-only.** Do NOT edit, fix, or apply any change. The report is for a
human (and the downstream fix step) to act on afterwards.

---

## Required Output Format

Produce a single Markdown report. Group findings by skill, and within each skill
order by severity (Critical → Important → Minor). For every finding include the
file and line, the rule it maps to, what's wrong, and the suggested change.

```
# Code Review Report

## Summary
<1-3 sentence overview: how many suggestions, from which skills, overall risk>

## vercel-react-best-practices

### Critical
- <file:line> — [<rule-name>]: <what's wrong> → <suggested change>

### Important
- <file:line> — [<rule-name>]: <what's wrong> → <suggested change>

### Minor
- <file:line> — [<rule-name>]: <what's wrong> → <suggested change>

## vercel-composition-patterns

### Critical
- <file:line> — [<rule-name>]: <what's wrong> → <suggested change>

### Important
- <file:line> — [<rule-name>]: <what's wrong> → <suggested change>

### Minor
- <file:line> — [<rule-name>]: <what's wrong> → <suggested change>
```

- **Critical**: correctness/performance issues with clear, measurable impact (e.g. request waterfalls, large bundle regressions, broken composition that leaks state).
- **Important**: significant convention violations or risky patterns the skills flag as high-impact.
- **Minor**: style, naming, optional improvements.

If a skill or severity section has no findings, omit that section entirely. Do not
write "None." If neither skill surfaces anything, state that explicitly in the Summary.
