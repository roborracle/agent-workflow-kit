---
name: state-management
description: Design frontend state architecture. Covers state categorization (server vs client vs URL), library selection, cache invalidation, optimistic updates, and state machine patterns.
user-invocable: false
---

# State Management Architect

## State Categorization

Before choosing a library, classify every piece of state:

| Category | Source of Truth | Persistence | Examples |
|----------|----------------|-------------|---------|
| **Server state** | Database/API | Survives refresh | User profile, orders, products |
| **Client state** | Browser memory | Lost on refresh | Modal open/closed, selected tab, sidebar collapsed |
| **URL state** | URL bar | Shareable/bookmarkable | Current page, filters, search query, sort order |
| **Form state** | Input elements | Until submit | Field values, validation errors, dirty tracking |

### Rule: Use the right tool for each category

| Category | Recommended Tool | Anti-Pattern |
|----------|-----------------|--------------|
| Server state | TanStack Query / SWR | Redux store with manual fetch |
| Client state | useState / Zustand / Jotai | Context for frequently changing values |
| URL state | URL search params / router | Redux or useState for page/filter state |
| Form state | React Hook Form / native | Global store for form values |

## Server State (TanStack Query Pattern)

```typescript
// Fetch with automatic caching, refetching, and loading states
const { data, isLoading, error } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => api.getUser(userId),
  staleTime: 5 * 60 * 1000, // Consider fresh for 5 minutes
});

// Mutation with optimistic update
const mutation = useMutation({
  mutationFn: api.updateUser,
  onMutate: async (newData) => {
    await queryClient.cancelQueries({ queryKey: ['users', userId] });
    const previous = queryClient.getQueryData(['users', userId]);
    queryClient.setQueryData(['users', userId], newData);
    return { previous };
  },
  onError: (err, vars, ctx) => queryClient.setQueryData(['users', userId], ctx.previous),
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['users', userId] }),
});
```

## Client State (Zustand Pattern)

```typescript
const useUIStore = create<UIState>((set) => ({
  sidebarOpen: false,
  theme: 'light',
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  setTheme: (theme) => set({ theme }),
}));
// Usage: subscribe to slices — const open = useUIStore((s) => s.sidebarOpen);
```

## URL State Pattern

```typescript
// Filters and pagination belong in the URL, not in state
const [searchParams, setSearchParams] = useSearchParams();
const page = parseInt(searchParams.get('page') || '1', 10);
const sort = searchParams.get('sort') || 'newest';
const filter = searchParams.get('filter') || 'all';
```

## Cache Invalidation Strategy

| Event | Invalidate |
|-------|-----------|
| Create item | List queries for that resource |
| Update item | Item query + list queries |
| Delete item | List queries (remove from cache directly) |
| Bulk operation | All queries for that resource type |
| Background (polling) | Stale queries on window focus |

## State Machine Pattern (Complex Flows)

For multi-step workflows (checkout, onboarding, file upload):

```typescript
type UploadState =
  | { status: 'idle' }
  | { status: 'selecting' }
  | { status: 'uploading'; progress: number }
  | { status: 'processing' }
  | { status: 'complete'; url: string }
  | { status: 'error'; message: string };
```

Use discriminated unions to make invalid states unrepresentable.

## Anti-Patterns
- Global state for everything (makes components impossible to test in isolation)
- Duplicating server data in client store (stale by definition)
- Prop drilling through 5+ levels (use composition or context for stable values)
- Context for frequently changing values (re-renders entire tree)
- Derived state stored separately (compute it from source, don't sync it)
- `useEffect` to sync state between two `useState` calls (combine into one state or use derived value)
