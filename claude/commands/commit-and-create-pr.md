---
description: Commit changes with conventional commits and create PR
allowed-tools: Bash, Read, Glob, Grep, mcp__claude_ai_Linear__get_issue
---

# UI Commit and Create PR

This command will:

1. Analyze your git changes and divide them into logical conventional commits
2. Handle pre-commit hook validation (linting, build)
3. Fix any eslint or typescript issues (no ignoring allowed)
4. Create a PR into the develop branch with detailed description

## Workflow

### Step 1: Get Current Branch and Linear Ticket

First, get the current branch name to extract the Linear ticket ID:

```bash
git branch --show-current
```

Extract the Linear ticket ID from the branch name (e.g., `ui-51/molecule-loadingscreen-new-component` → `UI-51`).

Then fetch the Linear ticket details for context using `mcp__claude_ai_Linear__get_issue`.

### Step 2: Analyze Git Changes

Run `git status --porcelain` to get a list of changed files.

Analyze the changes and group them into logical conventional commits following https://www.conventionalcommits.org/en/v1.0.0/:

**Conventional Commit Types:**

- `feat:` - New features or component additions
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Test additions or modifications
- `style:` - Code formatting (no functional changes)
- `refactor:` - Code refactoring
- `chore:` - Build, dependencies, or tooling changes
- `perf:` - Performance improvements

**Grouping Strategy:**

- Component implementation files together (index.tsx, types, stories, tests)
- Documentation changes separately
- Test updates separately if not part of new feature
- Configuration/tooling changes separately

**Commit Message Format:**

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Example: `feat(loading-screen): add LoadingScreen molecule component`

### Step 3: Create Commits

For each commit group:

1. **Stage files:**

   ```bash
   git add <file1> <file2> ...
   ```

2. **Create commit:**

   ```bash
   git commit -m "<type>(<scope>): <description>"
   ```

3. **Handle pre-commit hook failures:**
   - If commit fails due to linting errors:
     - Read the error output carefully
     - Use `Grep` or `Read` to examine the files with errors
     - Look at similar patterns in the codebase using `Glob` and `Read`
     - **DEEP THINK**: Analyze the error, understand the pattern, and fix properly
     - **DO NOT** add eslint-disable comments or typescript @ts-ignore
     - Fix the actual issue
     - Retry the commit

   - If commit fails due to build errors:
     - Read build output
     - Identify typescript errors or import issues
     - Fix the issues
     - Retry the commit

4. **Iterate until commit succeeds:**
   - Keep fixing issues until pre-commit hook passes
   - Each commit must be clean with no warnings or errors

### Step 4: Push Branch and Create Pull Request

After all commits are successful:

1. **Extract Linear ID from branch:**
   - Branch: `ui-51/molecule-loadingscreen-new-component`
   - Linear ID: `UI-51`

2. **Push branch to remote:**
   **IMPORTANT:** You must push the branch before creating the PR.

   ```bash
   git push -u origin <current-branch-name>
   ```

   **Handle push errors:**

   If the push command fails, check for common issues:

   ```
   ❌ Push failed. Common causes:

   1. **Permission denied (publickey)**
      - Your SSH key is not configured or has expired
      - Solution: Check GitHub SSH keys: https://github.com/settings/keys
      - Or use HTTPS: git remote set-url origin https://github.com/[org]/[repo].git

   2. **Network error / Connection timeout**
      - Check your internet connection
      - Try again in a moment
      - Check GitHub status: https://www.githubstatus.com/

   3. **rejected (non-fast-forward)**
      - Branch already exists on remote with different commits
      - Solution: Pull first: git pull origin <branch-name> --rebase
      - Or force push (CAUTION): git push -f origin <branch-name>

   4. **Repository access denied**
      - You don't have write permissions to this repository
      - Solution: Request access from repository admin

   Check the error message above for specific details.
   ```

   Do not proceed to PR creation until push succeeds.

3. **Create PR title:**
   - **MUST follow conventional commits format:** `<type>(<scope>): <description>`
   - The type and scope should match the primary commit(s) on the branch
   - The Linear ticket ID goes in the PR body, NOT the title
   - Example: `feat(loading-screen): add LoadingScreen molecule component`
   - **INVALID formats** (will fail CI lint): `UI-51: Add LoadingScreen`, `Add LoadingScreen molecule`

4. **Create PR using gh CLI:**

   **CRITICAL:** Always use `develop` as the base branch, NOT any other branch.

   Use the GitHub CLI (`gh`) via Bash to create the PR:

   ```bash
   gh pr create --base develop --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
   ## Linear Ticket

   [<LINEAR-ID>: <ticket-title>](https://linear.app/netboxlabs/issue/<LINEAR-ID>)

   ## Summary

   <Brief description of what was implemented/changed>

   ## Changes

   <List of key changes made>
   - Change 1
   - Change 2
   - ...

   ## Commits

   <List all commits with their messages>
   - <commit-hash>: <commit-message>
   - ...

   ## Visual Changes

   <If applicable, note any visual changes or link to Storybook stories>

   ## Additional Notes

   <Any additional context or notes>
   EOF
   )"
   ```

5. **Output PR URL:**
   The `gh pr create` command will output the PR URL. Display it to the user.

## Important Guidelines

### Error Handling

- **NEVER** ignore eslint errors with disable comments
- **NEVER** use typescript `@ts-ignore` or `@ts-expect-error`
- **ALWAYS** fix the root cause of errors
- If struggling, look at similar code in the codebase for patterns
- Use DEEP THINKING to understand and solve problems properly

### Commit Quality

- Each commit should be atomic and focused
- Commit messages should be clear and descriptive
- All commits must pass pre-commit hooks before moving to next commit
- Use conventional commit format consistently

### PR Quality

- PR title should be clear and match Linear ticket
- PR description should be comprehensive
- Include all relevant information for reviewers
- Link back to Linear ticket

## Example Execution

For branch `ui-51/molecule-loadingscreen-new-component`:

**Commits:**

1. `feat(loading-screen): add LoadingScreen molecule component`
   - Files: index.tsx, loading-screen.types.ts

2. `docs(loading-screen): add Storybook stories`
   - Files: loading-screen.stories.tsx

**Push Branch:**

```bash
git push -u origin ui-51/molecule-loadingscreen-new-component
```

**Create PR:**

```bash
gh pr create --base develop --title "feat(loading-screen): add LoadingScreen molecule component" --body "$(cat <<'EOF'
## Linear Ticket

[UI-51: Add LoadingScreen molecule component](https://linear.app/netboxlabs/issue/UI-51)

## Summary

Implements a new LoadingScreen molecule component for displaying full-screen loading states in NetBox Labs applications.

## Changes

- Created LoadingScreen molecule component with full-screen centered layout
- Added TypeScript types with comprehensive JSDoc
- Implemented 7 Storybook story variants
- Used NetBox Labs brand color (#00F2D4) for loading spinner
- Ensured WCAG 2.1 AA accessibility compliance

## Commits

- abc123: feat(loading-screen): add LoadingScreen molecule component
- ghi789: docs(loading-screen): add Storybook stories

## Visual Changes

View Storybook stories for LoadingScreen at NetBox Labs/Molecules/LoadingScreen

## Additional Notes

Component uses LoadingSpinner atom and follows atomic design principles. Fully documented with JSDoc for IntelliSense support.
EOF
)"
```

---

**Now execute this workflow step by step, handling any errors that arise and fixing them properly.**
