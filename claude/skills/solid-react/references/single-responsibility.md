---
name: single-responsibility
applies-to: '**/*.tsx, **/*.jsx'
description: SRP Guide - When and how to split files, size signals, modular paths for React
when-to-use: file too long, component doing too much, refactoring, code organization
keywords: single responsibility, SRP, splitting, lines, refactoring, modular
priority: high
related: architecture-patterns.md, templates/service.md, templates/hook.md
---

# Single Responsibility Principle (SRP)

**One file = One reason to change**

---

## When to Apply SRP?

The verdict is always **more than one reason to change** — size and import counts are signals that prompt a look, never the finding on their own.

### Symptoms of Violation

1. **Cannot describe the file in one sentence** → too many responsibilities
2. **Mixes types, business logic, and UI** in one unit → split the concerns
3. **A long file, or many imports/exports** → a signal to check the two above (thresholds vary by repo)

### Size signals (not hard limits)

These are the skill's only size numbers: the templates and `architecture-patterns.md` defer to this table. Treat each as "take a second look", never as the finding. Where the host repo lints size, its lint limits win over these.

| Unit                           | Worth a look past |
| ------------------------------ | ----------------- |
| Component                      | ~100 lines        |
| Hook                           | ~60 lines         |
| Service, store or other module | ~80 lines         |
| File                           | ~200 lines        |

Don't split to hit a number. Split to isolate a responsibility or a piece of state, and leave a long unit with one reason to change as it is: every extra component is another function call and fiber on each render, and every extra file is another place to look.

---

## How to Split? — Separate the concerns

Split a unit that does too much into one unit per concern: **types**, **business logic**, **state/effects (hooks)**, **validation**, and **UI**. _Where_ each piece lands is the host repo's call — follow its documented layout.

### Split Example

Before (one file doing everything):

```
UserDashboard.tsx → Types, API calls, State, Validation, UI
```

After (one concern per file — folder names shown are illustrative; use the host repo's):

```
user.types.ts        → Types
user.service.ts      → API calls
useUser.ts           → State
user.schema.ts       → Validation
UserDashboard.tsx    → UI only
```

> The `modules/[feature]/src/interfaces|services|hooks|...` layout is one sample structure — see `architecture-patterns.md`. In an existing repo, place each concern where that repo already keeps it.

---

## Decision Criteria

### Should This File Be Split?

1. **Can you describe its responsibility in 5 words?**
   - No → Split it

2. **Does it mix types, logic, and UI?**
   - Yes → separate each concern into its own unit

3. **Is business logic in a component?**
   - Yes → extract it to a hook or a service

4. **Are types defined inline in a service or component?**
   - Yes → move them to where the repo keeps types

---

## React Specific Rules

### A component should:

- Render UI and handle events
- Delegate logic to hooks
- Delegate data fetching to the repo's data layer (query hooks / loaders, not raw `fetch` in the component)
- Keep its types where the repo keeps types

---

## Where to Find Code Templates?

→ `templates/component.md` - Component
→ `templates/service.md` - Service
→ `templates/hook.md` - Hook
→ `templates/store.md` - Store
→ `templates/interface.md` - Interface definitions

---

## SRP Checklist

- [ ] Each unit's responsibility fits in one sentence
- [ ] Types, logic, and UI live in separate units
- [ ] Business logic sits in hooks/services, not components
- [ ] Each concern is placed where the host repo keeps it
- [ ] Components only render UI and handle events
