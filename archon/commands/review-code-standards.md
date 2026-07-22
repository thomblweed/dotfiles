---
description: Review all changes on this branch for code smells and documented-standard violations using the code-review skill's Standards axis, and produce a suggestions-only report. No changes are applied.
---

# Review Code Standards

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

The **`code-review`** skill is preloaded for this node — its `SKILL.md` is already in
your context. Run **only its Standards axis**. Do **not** run the Spec axis, and ignore
the skill's spec / issue-tracker / `setup-matt-pocock-skills` steps — a separate node
already validated the ticket, and spec conformance is out of scope here.

This node is itself the parallel review unit in the workflow, so run the Standards
review **inline as a single agent** — do **not** spawn sub-agents.

Judge the diff against two Standards sources:

1. **Documented repo standards** — read `CLAUDE.md` (and `CONTRIBUTING.md` /
   `CODING_STANDARDS.md` if present) and flag every place the diff breaks a rule the
   repo documents. Cite the rule.
2. **The Fowler smell baseline** carried by the `code-review` skill — match each smell
   (Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession,
   Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality,
   Message Chains, Middle Man, Refused Bequest) against the diff.

Two rules bind the review:

- **The repo overrides.** A documented repo standard always wins; where `CLAUDE.md`
  endorses something the baseline would flag, suppress the smell.
- **Skip what tooling enforces.** Formatting, lint, and type errors are handled by the
  `lint-typecheck-format` nodes — do not report them here.

Documented-standard breaches can be **hard violations**; baseline smells are **always
judgement calls** — label each accordingly.

**This is review-only.** Do NOT edit, fix, or apply any change. The report is for a
human (and the downstream fix step) to act on afterwards.

---

## Required Output Format

Produce a single Markdown report. Order findings by severity. For every finding include
the file and line, the standard or smell it maps to, what's wrong, and the suggested
change.

```
# Code Standards Review Report

## Summary
<1-3 sentence overview: how many findings, standards vs smells, overall risk>

## Critical
- <file:line> — [<CLAUDE.md rule>]: <what's wrong> → <suggested change>

## Important
- <file:line> — [<smell name>]: <what's wrong> → <suggested change>

## Minor
- <file:line> — [<smell name>]: <what's wrong> → <suggested change>
```

- **Critical**: hard violations of a documented repo standard (a `CLAUDE.md` rule breach).
- **Important**: strong smells with a clear fix (Duplicated Code, Feature Envy, Shotgun
  Surgery, Primitive Obsession that hides a domain concept).
- **Minor**: lighter judgement-call smells where the fix is optional (Mysterious Name,
  Middle Man, Speculative Generality).

If a severity section has no findings, omit that section entirely. Do not write "None."
If the review surfaces nothing, state that explicitly in the Summary.
