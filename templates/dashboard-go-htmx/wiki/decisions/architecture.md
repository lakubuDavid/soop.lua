# Domain-Neutral Dashboard Architecture

**Status**: Accepted

## Context

The dashboard template must work for SaaS products, internal tools, blogs, tourism guides, platforms, and other web applications. The hotel reservation application provides useful patterns but its domain model must not leak into the template.

## Decision

Build a generic Go dashboard shell with optional domain modules. The core includes authentication, authorization, layout, reusable templ components, HTMX partials, Alpine interactions, TypeScript build support, UnoCSS, API boundaries, and database abstractions.

Domain concepts are added through modules such as `posts`, `tours`, `products`, `projects`, or `reservations`.

## Alternatives considered

- **Hotel-first template**: rejected because it limits reuse and embeds the wrong vocabulary.
- **UI-only starter**: rejected because authentication, data boundaries, testing, and database setup are recurring requirements.
- **Single monolithic domain package**: rejected because it makes optional modules difficult to remove.

## Consequences

### Positive

- One scaffold supports many application types.
- Hotel architecture can be reproduced without hotel-specific names.
- Shared shell and components stay consistent.
- Domain modules can be added or removed independently.

### Negative

- The initial documentation and interfaces are more abstract.
- Some projects need a small amount of generated module wiring.
- Generic authorization and repository interfaces require deliberate design.
