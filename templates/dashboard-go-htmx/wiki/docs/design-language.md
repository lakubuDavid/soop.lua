# Dashboard Design Language

## Purpose

The dashboard template is a domain-neutral Go application shell. It may be used for SaaS administration, internal tools, CMS and blogs, tourism guides, marketplaces, customer portals, or other authenticated web platforms.

The hotel reservation application is the reference implementation for interaction patterns, not the template's domain model. The template must not assume hotels, rooms, guests, reservations, or rate plans.

## Design principles

1. **Useful density** — Show operational information clearly without making every page feel like a spreadsheet.
2. **One primary action** — Every page and dialog has an obvious next action.
3. **Progressive disclosure** — Keep the first view simple; expose advanced filters and secondary actions when needed.
4. **Server-owned truth** — Go and the API own durable state. Alpine owns only local interaction state.
5. **Fast feedback** — Use HTMX indicators, optimistic visual states only when safe, and clear success/error feedback.
6. **Consistent language** — UI labels describe the user's domain, while the shell remains generic.
7. **Accessible defaults** — Keyboard navigation, visible focus, semantic headings, labels, and usable contrast are required.

## Visual system

Use UnoCSS shortcuts and CSS variables rather than repeating long utility strings throughout templates.

Required semantic tokens:

- `--color-primary`
- `--color-primary-light`
- `--color-accent`
- `--color-background`
- `--color-surface`
- `--color-text`
- `--color-muted`
- `--color-success`
- `--color-warning`
- `--color-danger`

The starter palette must be neutral and replaceable through project configuration. Do not bake hotel branding into shared components.

## Page anatomy

A standard authenticated page contains:

```text
Dashboard shell
├── Sidebar
├── Header
└── Main content
    ├── Breadcrumbs
    ├── Page title and description
    ├── Primary action area
    ├── Filters/search (when needed)
    ├── Main content or table
    └── Empty/loading/error state
```

Direct navigation renders the complete shell. HTMX navigation renders only the content region.

## Interaction split

### HTMX owns

- Server navigation
- Form submissions
- Table refreshes
- Pagination
- Search requests
- Server validation results
- Notifications triggered by server events
- Partial replacement

### Alpine.js owns

- Dropdown open/close state
- Dialog visibility
- Tabs
- Local filter controls
- Disclosure panels
- Client-only confirmation state
- Small keyboard and focus interactions

### TypeScript owns

- Complex reusable browser behavior
- Date/range controls
- Rich table behavior
- Event streams
- Components requiring typed client contracts

Do not use Alpine or TypeScript to duplicate server business logic.

## Component rules

Shared components should be:

- Data-oriented rather than domain-specific
- Configurable through typed props
- Composable inside full pages and partials
- Safe to render more than once after HTMX swaps
- Independently testable

Prefer `Table`, `Dialog`, `FormField`, `Pagination`, and `EmptyState` over repeated page-specific markup.

## States

Every data-driven view should define:

- Loading state
- Empty state
- Error state
- Normal state
- Permission-denied state when applicable

Mutations should provide a visible result through a toast, inline alert, redirect, or updated partial.

## Responsive behavior

- Desktop: persistent sidebar and full content area
- Tablet: compressed sidebar and responsive tables
- Mobile: collapsible navigation and stacked content
- Tables: prefer horizontal scrolling or a deliberate card representation; do not silently hide critical columns

## Naming

The shell uses generic terms such as `workspace`, `member`, `resource`, `record`, and `activity`. Domain modules supply labels such as `post`, `tour`, `product`, or `reservation`.
