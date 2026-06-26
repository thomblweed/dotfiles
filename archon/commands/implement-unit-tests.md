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

The **`vitest-unit-tests`** skill is preloaded for this node — its `SKILL.md` is
already in your context and is the **single source of truth** for how these tests
must be written. Its reference files are **not** preloaded. Before writing anything:

1. Read `references/file-structure.md` (`renderWithProviders`, `defaultProps`, module-level provider setup, extending tests) and `references/api-mocking.md` (ConnectRPC transport setup, factory patterns, `renderHook` wrappers). These hold conventions that are NOT in the top-level skill and NOT repeated here.

Then follow the skill exactly. Do not rely on memory, on general testing habits, or on a summary — the skill's rules override all of those. The skill (not this command) is authoritative on every convention, including:

- BDD structure: no top-level `describe('<ComponentName>')`, and the `describe('when ...')` rules (minimum two `it()` per block; don't repeat the condition in `it` names).
- Query priority and using **plain strings** (not regex) for query args.
- `userEvent` over `fireEvent`, with `const user = userEvent.setup()` once at the top of the file.
- `vi.mock` policy (default zero) and the component-mocking criteria.
- Provider setup via a module-scoped `renderWithProviders` helper — do NOT inline providers per test.
- Routing: `MemoryRouter`/`createMemoryRouter` with sentinel routes; never mock router hooks and never assert on path strings.
- `beforeEach` vs `afterEach` split, TypeScript (no `any`), co-location, and parallel-execution rules (pure-node files use `describe.concurrent`/`it.concurrent`; DOM/`@testing-library/*` files stay sequential).

Only write tests for functionality introduced on this branch. Do not touch test files for unchanged code.

### PHASE_2_CHECKPOINT
- [ ] Both `vitest-unit-tests` reference files read (`file-structure.md`, `api-mocking.md`)
- [ ] Tests written or extended for every changed source file
- [ ] Each test spot-checked against the skill before finishing (provider helper, query strings, BDD structure, routing assertions)

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

### PHASE_3_CHECKPOINT
- [ ] All new/modified tests pass

---

## Phase 4: REPORT

Print a concise summary:

```
Tests:
  <bullet list of test files created or modified, with a one-line note per file>

Result:  all tests passing
```
