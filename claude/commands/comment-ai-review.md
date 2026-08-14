---
description: Comment "/ai-review" on the PR for the current branch
---

Post the comment `/ai-review` on the GitHub PR open for the current branch.

## Steps

1. Check `git rev-parse --is-inside-work-tree`. If this fails, report "No PR to comment on in this context." and stop.
2. Get the branch with `git branch --show-current`. If it's empty (detached HEAD), or matches `main`, `master`, `develop`, or the repo's default branch (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`), report "No PR to comment on in this context." and stop.
3. Run `gh pr view --json number,url`. If it errors (no PR found for this branch), report "No PR to comment on in this context." and stop.
4. Run `gh pr comment --body "/ai-review"`.
5. Confirm to the user with the PR URL.

## Notes

- Don't ask for confirmation before posting — that's the whole point of this command.
- Don't fall back to searching other branches or repos — only the current branch's PR.
