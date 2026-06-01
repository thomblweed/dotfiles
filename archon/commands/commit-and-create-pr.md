---
description: Commit changes with conventional commits and create a PR into develop.
allowed-tools: Bash, Read, Glob, Grep, mcp__linear-server__linear_search_issues_by_identifier
---

# Commit and Create PR

**Workflow ID**: $WORKFLOW_ID

---

This command will:

1. Analyze your git changes and divide them into logical conventional commits
2. Create a PR into the develop branch with detailed description

## Step 1: Get Current Branch and Linear Ticket

First, get the current branch name to extract the Linear ticket ID:

```bash
git branch --show-current
```

Extract the Linear ticket ID from the branch name (e.g., `ui-51/molecule-loadingscreen-new-component` → `UI-51`).

Then fetch the Linear ticket details for context using `mcp__linear-server__linear_search_issues_by_identifier` with input `{ "identifier": "<TICKET-ID>" }`.

## Step 2: Analyze Git Changes

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

## Step 3: Create Commits

For each commit group:

1. **Stage files:**

   ```bash
   git add <file1> <file2> ...
   ```

2. **Create commit:**

   ```bash
   git commit -m "<type>(<scope>): <description>"
   ```

## Step 4: Push Branch and Create Pull Request

1. **Extract Linear ID from branch:**
   - Branch: `ui-51/molecule-loadingscreen-new-component`
   - Linear ID: `UI-51`

2. **Push branch to remote:**

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

   ## Testing

   - ✅ Linting and type-checking clean
   - ✅ Unit tests passing

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

### Commit Quality

- Each commit should be atomic and focused
- Commit messages should be clear and descriptive
- Use conventional commit format consistently

### PR Quality

- PR title should be clear and match Linear ticket
- PR description should be comprehensive
- Include all relevant information for reviewers
- Link back to Linear ticket

---

**Now execute this workflow step by step, handling any errors that arise.**
