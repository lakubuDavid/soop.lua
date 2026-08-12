# Reusable Component Catalog

Components are the stable visual API of the dashboard template. Domain modules should compose them instead of copying markup.

## Layout

- `Layout` — document shell, metadata, shared scripts
- `DashboardLayout` — sidebar, header, and HTMX content target
- `Sidebar` — navigation groups and active item state
- `Header` — page context, user menu, notifications
- `Breadcrumbs` — hierarchical location
- `PageTitle` — title, description, and actions

## Content

- `Card`
- `StatCard`
- `Table`
- `TableToolbar`
- `Pagination`
- `Timeline`
- `ActivityItem`
- `EmptyState`
- `LoadingSkeleton`
- `ErrorState`

## Forms and overlays

- `FormField`
- `Select`
- `Combobox`
- `Dialog`
- `ConfirmDialog`
- `Toast`
- `Alert`
- `Tabs`
- `Dropdown`

## Component contract

Each component should document:

- Its typed props
- Whether it is safe inside an HTMX partial
- Its Alpine state, if any
- Its HTMX events and targets
- Its accessibility requirements
- Its UnoCSS shortcuts

Generated templ files are build artifacts and must not be edited manually.
