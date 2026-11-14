---
name: react-rerender-composition
description: Guides implementation of React composition patterns that prevent unnecessary re-renders without memoization. Use when writing or editing React components, auditing for performance issues, or after a code review — checks for components defined in render, state that could be moved down, heavy siblings that could be passed as children or props, and context values that re-render all consumers.
---

# Preventing Re-renders with Composition

Eliminate unnecessary re-renders by restructuring the component tree — not by adding `memo`/`useMemo`/`useCallback`. Reach for memoization only when composition genuinely can't help.

## What triggers re-renders

1. **State change** — the component called `setState` (or a hook did)
2. **Parent re-render** — every child re-renders when its parent re-renders, regardless of props
3. **Context change** — any consumer re-renders when the context value changes
4. **Hook state/context** — state or context inside a custom hook re-renders the host component

**Props myth:** changing props alone does NOT cause re-renders in un-memoized components. Props can only change when the parent re-renders, which already triggers the child. Prop values only matter once you add `React.memo`.

Re-renders flow **downward only** — a child re-rendering never triggers its parent.

## Decision tree

```
Re-rendering more than needed?
│
├─ Child component defined inside render? → Pattern 1: move to module scope
├─ Triggering state only used by part of the JSX? → Pattern 2: move state down
├─ Stateful wrapper whose children don't use its state?
│   ├─ One logical slot → Pattern 3: children as props
│   └─ Multiple independent slots → Pattern 4: components as props
└─ Context consumers re-rendering on unrelated state? → Pattern 5: split context
```

A polled query counts as triggering state for Patterns 2 to 4. Moving one down below an early return needs a prefetch at the parent: the `tanstack-query` skill's "Subscribe where the data renders" section has it.

See **[`references/patterns.md`](references/patterns.md)** for full examples of each pattern.

## When writing or editing a component

Before implementing or making changes, answer these questions:

1. **Where does state live?** — If state only affects a subtree of JSX, it should start lower (Pattern 2).
2. **Does this wrap heavy siblings?** — If the component owns state _and_ renders heavy children that don't use that state, accept those children via `children` or named props (Patterns 3/4).
3. **Am I defining sub-components?** — Any `const Foo = () =>` helpers belong at module scope, not inside this component's body (Pattern 1).
4. **Does this context hold mixed update frequencies?** — Keep setters/dispatch separate from frequently-changing state values (Pattern 5).

**When editing specifically:** also check whether your change introduces new state near existing heavy siblings, or alters a context's shape. If you spot an existing violation while making your edit, flag it in your response even if it's out of scope to fix right now.

## Audit mode (post-review / ad-hoc scan)

When asked to audit, check for bad patterns, or review after a code review, scan the codebase systematically before applying fixes:

1. **Pattern 1 — components in render:** scan for component definitions (capitalized `const Foo = ...` helpers) inside other components' render bodies, not at module scope.

2. **Pattern 2 — state too high:** look for `useState`, or a `useQuery` with a `refetchInterval`, in components that also render clearly heavy siblings (data tables, feature components, charts). Ask: does the state only affect a subset of the JSX?

3. **Pattern 3/4 — stateful wrappers with heavy children:** find event wrappers (`onScroll`, `onWheel`, `onChange` on a container `div`) that inline heavy children directly rather than accepting them as `children` or named props.

4. **Pattern 5 — overloaded contexts:** find `createContext` / `value={{` objects that mix setter functions with frequently-changing derived state in the same value.

**Report format:** produce a prioritized list of findings ordered by severity:

- 🔴 **Remount (Pattern 1)** — highest impact, causes DOM teardown + state reset
- 🟠 **Unnecessary re-render (Patterns 2–4)** — wasted renders on every state change
- 🟡 **Context over-broadcast (Pattern 5)** — scales with number of consumers

For each finding include: file + approximate line, which pattern applies, one-line description of the issue, and the suggested fix.

## When to use memoization instead

Reach for `React.memo`/`useMemo`/`useCallback` only when composition can't isolate the re-render. See **[`references/memo-patterns.md`](references/memo-patterns.md)** for the full memo API guidance.

## Reference files

- **[`references/patterns.md`](references/patterns.md)** — full code examples for all five patterns
- **[`references/composition-edge-cases.md`](references/composition-edge-cases.md)** — stable callbacks via ref, context selectors, key stability, portals, when composition can't help
- **[`references/memo-patterns.md`](references/memo-patterns.md)** — React.memo, useMemo/useCallback patterns, memoizing context provider values
