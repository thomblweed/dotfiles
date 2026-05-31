---
description: Write or extend unit tests for new and modified files on this branch. Follows the vitest-unit-tests skill conventions.
---

# Implement Unit Tests

**Workflow ID**: $WORKFLOW_ID

---

## Phase 1: IDENTIFY CHANGED FILES

Run the following to find files changed on this branch relative to its base:

```bash
git diff --name-only $(git merge-base HEAD origin/develop) HEAD
```

Filter to source files only (exclude test files, generated files, config files).
These are the files that need test coverage.

### PHASE_1_CHECKPOINT
- [ ] List of changed source files identified
- [ ] Existing test files for those sources noted (to extend) or confirmed absent (to create)

---

## Phase 2: WRITE TESTS

For each changed source file, write or extend its co-located test file (e.g. `Foo.tsx` → `Foo.test.tsx`).

Follow the vitest-unit-tests skill conventions precisely:

- Test behavior from the user's perspective — not implementation details.
- Default to zero `vi.mock` calls. Only mock when rendering actually fails and you've isolated the failure to a specific module.
- Use `userEvent` over `fireEvent`.
- Use BDD naming: flat `it()` for one outcome, `describe('when ...')` wrapping multiple `it()` for the same condition.
- Use `getByRole` first; fall back to `getByLabelText`, `getByText`, `getByTestId` in that order.
- Write all tests in TypeScript — no `any`.
- Co-locate test files next to the component they test.
- Wrap providers inline per test — do not extract a shared render helper.
- For routing, use `MemoryRouter` or `createMemoryRouter` — never mock `useNavigate` or other router hooks.
- DOM/render test files must be sequential — do not use `describe.concurrent` or `it.concurrent` if the file imports from `@testing-library/*`.

Only write tests for functionality introduced on this branch. Do not touch test files for unchanged code.

### PHASE_2_CHECKPOINT
- [ ] Tests written or extended for every changed source file
- [ ] All tests follow the skill conventions above

---

## Phase 3: VALIDATE

Run the test suite scoped to the changed files to confirm all tests pass:

```bash
npm test -- --run $(git diff --name-only $(git merge-base HEAD origin/develop) HEAD | grep -E '\.(tsx?|jsx?)$' | grep -v '\.test\.' | sed 's/\.[^.]*$/.test&/' | tr '\n' ' ')
```

If that fails, fall back to running the full suite:

```bash
npm test -- --run
```

Fix any failures before continuing.

Also run:
```bash
npm run typecheck
```

Fix any type errors introduced by the test files.

### PHASE_3_CHECKPOINT
- [ ] All new/modified tests pass
- [ ] `npm run typecheck` passes

---

## Phase 4: REPORT

Print a concise summary:

```
Tests:
  <bullet list of test files created or modified, with a one-line note per file>

Result:  all tests passing
```
