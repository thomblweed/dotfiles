---
name: dependency-inversion
applies-to: '**/*.tsx, **/*.jsx'
description: DIP Guide - Depend on abstractions, inject dependencies, keep units mockable
when-to-use: tight coupling, service architecture, testing, mocking
keywords: dependency inversion, DIP, injection, abstraction, decoupling, factory
priority: high
related: open-closed.md, templates/factory.md, templates/service.md
---

# Dependency Inversion Principle (DIP)

**Depend on abstractions, not concrete implementations**

---

## When to Apply DIP?

### Symptoms of Violation

1. **Doing direct `fetch()` or `axios` in services**
   - Tight coupling to HTTP implementation
   - Cannot swap or mock easily

2. **Importing concrete implementations directly**
   - Provider change = modification everywhere
   - Testing becomes difficult

3. **Changing provider requires modifying 10+ files**
   - Too tight coupling
   - Cascading changes

---

## Why It Matters?

### Without DIP

```
Component → userService → fetch() → API
```

Problems:

- Switch HTTP client = rewrite service + all usages
- Cannot mock for tests
- Cascading coupling

### With DIP

```
Component → userService ← HttpClient interface
                        ← fetchClient (production)
                        ← mockClient (tests)
```

Advantages:

- Switch client = create new implementation, nothing else
- Easy testing with mock client
- Component doesn't know which implementation

---

## How to Apply DIP?

### Step 1: Define the abstraction

Declare the contract the consumer depends on (place it where the host repo keeps shared types):

```typescript
export interface HttpClient {
  get<T>(url: string): Promise<T>
  post<T>(url: string, data: unknown): Promise<T>
}
```

### Step 2: Create Implementation

Implement the contract as a concrete client:

→ See `templates/factory.md` for complete implementation

### Step 3: Create Service with DI

Create service factory that accepts interface:

→ See `templates/service.md` for complete implementation

### Step 4: Use Context for DI

Provide services via React Context:

→ See `templates/factory.md` for ServicesProvider pattern

---

## Anti-Patterns to Avoid

### Concrete dependency hardcoded inside the unit

**Bad — welded to `fetch`, can't be swapped or mocked:**

```typescript
export const userService = {
  getUser: (id: string) => fetch(`/api/users/${id}`),
}
```

**Good — the client is injected:**

```typescript
export function createUserService(client: HttpClient) {
  return {
    getUser: (id: string) => client.get(`/users/${id}`),
  }
}
```

---

## Decision Criteria

### Should I Apply DIP Here?

1. **Is it an external dependency (HTTP, storage)?**
   - Yes → Interface + factory

2. **Could implementation change?**
   - Yes → Use interface

3. **Do I need to test this?**
   - Yes → Inject dependencies for easy mocking

---

## Where to Find Code Templates?

→ `templates/factory.md` - Factory with DI patterns
→ `templates/service.md` - Service with injected dependencies
→ `templates/interface.md` - Interface definitions

---

## DIP Checklist

- [ ] Units depend on an abstraction (interface), not a concrete client
- [ ] Dependencies are injected (factory / props / context), not imported inside the unit
- [ ] No raw `fetch`/`axios` welded into a service — the transport is passed in
- [ ] Tests can substitute a mock implementation
- [ ] Swapping the implementation touches only 1–2 files
