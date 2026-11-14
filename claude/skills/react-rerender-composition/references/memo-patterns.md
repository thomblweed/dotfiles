# Memoization Patterns

## Memoize context provider value

If a Provider component can itself be re-rendered by an ancestor (i.e. it's not at the true root), memoize the value object so consumers don't re-render unnecessarily:

```tsx
function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState('light')
  // ✅ stable reference — consumers don't re-render when ThemeProvider's parent re-renders
  const value = useMemo(() => ({ theme, setTheme }), [theme])
  return <ThemeContext value={value}>{children}</ThemeContext>
}
```

## React.memo patterns

`React.memo` wraps a component so it skips re-renders when its props haven't changed:

```tsx
const HeavyRow = React.memo(function HeavyRow({ item }: { item: Item }) {
  return <tr>...</tr>
})
```

**Non-primitive props must also be memoized.** If you pass an object/array/function inline, it's recreated on every parent render and `memo` achieves nothing:

```tsx
// ❌ new object reference on every render → memo is useless
;<MemoRow style={{ color: 'red' }} onClick={() => handleClick(id)} />

// ✅ memoize non-primitive props
const style = useMemo(() => ({ color: 'red' }), [])
const onClick = useCallback(() => handleClick(id), [id])
;<MemoRow style={style} onClick={onClick} />
```

**Apply memo at the component's definition, not the parent.** When using the children/components-as-props patterns, memo the heavy component itself — memoizing the wrapper that passes it won't help:

```tsx
// ✅ memo on the heavy leaf, not on the wrapper
const HeavyPanel = React.memo(function HeavyPanel() { ... });
function Layout() {
  return <SidebarWrapper panel={<HeavyPanel />} />;
}
```

## useMemo / useCallback: necessary vs wasteful

**Necessary:**

- Non-primitive deps in `useEffect`, `useMemo`, or `useCallback` hooks
- Props passed to `React.memo`-wrapped components (see above)
- Genuinely expensive calculations (large list transformations, complex math)

**Wasteful / anti-patterns:**

- Memoizing props passed to a non-`memo`-wrapped child — the child re-renders from parent re-render regardless
- Memoizing primitive values (strings, numbers, booleans) — they're already compared by value
- Wrapping every callback in `useCallback` by default — it costs memory and has its own comparison overhead

Note: pure JS operations (sort, filter, map) are typically cheaper than a component mount/update, so don't memoize them reflexively.
