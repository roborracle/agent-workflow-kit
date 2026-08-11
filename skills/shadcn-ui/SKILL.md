---
name: shadcn-ui
description: Complete shadcn/ui expertise covering component selection, implementation, customization, and composition. Includes requirements analysis, component research, and implementation patterns. Use when building with shadcn/ui components or need guidance on component selection.
user-invocable: false
---

# shadcn/ui Expert

Complete mastery of shadcn/ui from component selection to production implementation.

## Quick Start
```bash
npx shadcn@latest init
npx shadcn@latest add button card dialog input
```

## Component Selection Guide
| Need | Components |
|------|------------|
| Forms | Input, Select, Checkbox, Radio, Switch, Textarea, Form |
| Navigation | NavigationMenu, Tabs, Breadcrumb, Pagination |
| Feedback | Alert, Toast, Progress, Skeleton |
| Overlays | Dialog, Sheet, Popover, Tooltip, DropdownMenu |
| Data Display | Table, Card, Badge, Avatar, Separator |

## Key Patterns

### Form with Validation (react-hook-form + zod)
```tsx
const schema = z.object({ email: z.string().email(), name: z.string().min(2) })
const form = useForm({ resolver: zodResolver(schema) })
```

### Custom Component Extension
```tsx
interface LoadingButtonProps extends React.ComponentProps<typeof Button> {
  loading?: boolean
}
export function LoadingButton({ loading, children, disabled, ...props }: LoadingButtonProps) {
  return (
    <Button disabled={loading || disabled} {...props}>
      {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
      {children}
    </Button>
  )
}
```

## Component Dependencies
| Component | Requires |
|-----------|----------|
| Form | react-hook-form, @hookform/resolvers, zod |
| DataTable | @tanstack/react-table |
| DatePicker | date-fns, react-day-picker |
| Toast | sonner |
| Charts | recharts |

## Best Practices
- Use semantic color variables (primary, secondary, destructive)
- Compose components for complex UI
- Use `asChild` for custom trigger elements
- Leverage TypeScript for prop types
- Follow built-in accessibility patterns
