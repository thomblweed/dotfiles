# Composition Edge Cases

## Stable callbacks without useCallback

When passing a callback down that would otherwise cause a memo'd child to re-render, use a ref to keep it stable without `useCallback`:

```tsx
function Parent() {
  const [count, setCount] = useState(0)
  const onClickRef = useRef(() => console.log(count))
  // update the ref on every render so the callback always sees current state
  onClickRef.current = () => console.log(count)

  // stable identity — doesn't cause MemoChild to re-render
  const stableOnClick = useCallback(() => onClickRef.current(), [])
  return <MemoChild onClick={stableOnClick} />
}
```

Use this sparingly — prefer moving state down so the callback doesn't need to cross component boundaries at all.

## Context with selector pattern

When splitting context isn't practical (third-party context, shared library), use a selector wrapper to subscribe only to the slice you need:

```tsx
function useCountSelector<T>(selector: (state: State) => T): T {
  const state = useContext(StateContext)
  return useMemo(() => selector(state), [state, selector])
}

// Only re-renders when count changes, not on unrelated state keys
function Counter() {
  const count = useCountSelector((s) => s.count)
  return <span>{count}</span>
}
```

## Lists: key stability matters

Re-ordering a list without stable keys triggers full unmount/remount for each item. Always use a stable, unique ID from the data — never array index for mutable lists.

```tsx
// ❌ index key causes full remount on sort/filter
items.map((item, i) => <Row key={i} {...item} />)

// ✅ stable identity key
items.map((item) => <Row key={item.id} {...item} />)
```

**Never use random keys** — `key={Math.random()}` remounts every item on every render, destroying state and causing severe performance issues.

## Portals and state hoisting

`ReactDOM.createPortal` renders a subtree in a different DOM node but it still lives in the React tree at its declaration point. State for the portal content should still be moved down / children-as-props — portal doesn't change the re-render rules.

## When composition genuinely can't help

Composition can't isolate re-renders when:

- The component **must** consume context that changes frequently and no split is possible
- A component renders a derived value from props that change (memoize the value, not the component)
- An animation loop drives state at 60fps — `useRef` + direct DOM mutation is the right tool, not composition

In these cases, reach for `React.memo` on the leaf + `useMemo`/`useCallback` on the values passed to it. See `memo-patterns.md` for the full memo API guidance.
