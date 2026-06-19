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

Review the changed code against **both** of these skills and gather their recommendations:

1. **`vercel-react-best-practices`** — React/Next.js performance rules (eliminating
   waterfalls, bundle size, server-side performance, client-side data fetching,
   re-renders, rendering, JS micro-optimizations, advanced patterns).
2. **`vercel-composition-patterns`** — React composition rules (avoiding boolean
   prop proliferation, compound components, lifting state, context interfaces,
   children over render props, explicit variants, React 19 APIs).

Load each skill, scan the diff for violations of their rules, and record every
recommendation. Cite the specific rule each suggestion comes from.

**This is review-only.** Do NOT edit, fix, or apply any change. The report is for a
human to review and act on afterwards.

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
