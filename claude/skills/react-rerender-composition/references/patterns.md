# The Five Composition Patterns

## 1. Never define components inside render

Defining a component inside another's render body causes React to unmount+remount it on every parent re-render (DOM teardown, state reset, effects re-fire).

```tsx
// ❌ Header is recreated on every App render
function App() {
  const Header = () => <h1>Title</h1>
  return <Header />
}

// ✅ defined at module scope
const Header = () => <h1>Title</h1>
function App() {
  return <Header />
}
```

## 2. Move state down

When state is only used by a small subtree, extract that subtree + the state into a child. Heavy siblings never re-render.

```tsx
// ❌ entire Page re-renders on every dialog open/close
function Page() {
  const [open, setOpen] = useState(false)
  return (
    <>
      <HeavyComponent />
      <button onClick={() => setOpen(true)}>Open</button>
      {open && <Dialog onClose={() => setOpen(false)} />}
    </>
  )
}

// ✅ move state and the elements it controls into a child
function DialogButton() {
  const [open, setOpen] = useState(false)
  return (
    <>
      <button onClick={() => setOpen(true)}>Open</button>
      {open && <Dialog onClose={() => setOpen(false)} />}
    </>
  )
}
function Page() {
  return (
    <>
      <HeavyComponent />
      <DialogButton />
    </>
  )
}
```

## 3. Children as props

When state must live on a wrapper element (e.g. `onScroll`), pass heavy content in as `children`. Children are props — they aren't re-created when the wrapper's state changes.

```tsx
// ❌ HeavyComponent re-renders on every scroll
function ScrollContainer() {
  const [pos, setPos] = useState(0)
  return (
    <div onScroll={(e) => setPos(e.currentTarget.scrollTop)}>
      <HeavyComponent />
    </div>
  )
}

// ✅ pass heavy content as children
function ScrollTracker({ children }: { children: ReactNode }) {
  const [pos, setPos] = useState(0)
  return <div onScroll={(e) => setPos(e.currentTarget.scrollTop)}>{children}</div>
}
function Page() {
  return (
    <ScrollTracker>
      <HeavyComponent />
    </ScrollTracker>
  )
}
```

## 4. Components as props

When heavy components can't be grouped as `children`, pass them as named props. Props don't change when the wrapper's state changes.

```tsx
// ❌ both panels re-render on sidebar toggle
function Layout() {
  const [collapsed, setCollapsed] = useState(false)
  return (
    <div>
      <Sidebar collapsed={collapsed} onToggle={() => setCollapsed((c) => !c)} />
      <HeavyPanel />
      <HeavyChart />
    </div>
  )
}

// ✅ pass independent components as props
function SidebarWrapper({ panel, chart }: { panel: ReactNode; chart: ReactNode }) {
  const [collapsed, setCollapsed] = useState(false)
  return (
    <div>
      <Sidebar collapsed={collapsed} onToggle={() => setCollapsed((c) => !c)} />
      {panel}
      {chart}
    </div>
  )
}
function Layout() {
  return <SidebarWrapper panel={<HeavyPanel />} chart={<HeavyChart />} />
}
```

## 5. Split context by update frequency

When a context holds both stable values (dispatch, setters) and frequently-changing values (derived state), all consumers re-render on every change. Split into separate contexts.

```tsx
// ❌ every consumer re-renders when count changes
const StoreContext = createContext({ count: 0, dispatch: () => {} })

// ✅ split stable and volatile parts
const DispatchContext = createContext<Dispatch>(() => {})
const StateContext = createContext({ count: 0 })

function StoreProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, initialState)
  return (
    <DispatchContext value={dispatch}>
      <StateContext value={state}>{children}</StateContext>
    </DispatchContext>
  )
}
// Components that only dispatch don't re-render on state changes
```
