# Senior Frontend Engineer, NetBox Labs

_May 2026 – present_

Main engineer on the Observability micro-frontend in NetBox Labs' unified UI. It's a React 19 and TypeScript app that loads into the platform shell through Module Federation and covers network assurance, fleet management and integrations.

## Responsibilities

- Build product features end to end, from Figma designs to production UI on the shared component library.
- Own the app's architecture and frontend standards, including data fetching, state, forms, tables and typed ConnectRPC service clients.
- Own code quality and delivery: linting, unit and end-to-end testing (Vitest, Playwright), CI, releases, dependency updates and container security patches.
- Work with the platform team to keep shared dependencies in step with the shell, and add new routes and navigation to it.
- Turn product requirements into well-scoped, testable vertical-slice stories.

## Achievements

- Delivered the Deviations assurance workflow (filtering, bulk actions, detail views, wired to the Diode backend), credential management with HashiCorp Vault storage, and a redesigned discovery-job wizard released behind feature flags.
- Reorganised the codebase into feature-based modules, then turned the repo into an npm workspaces monorepo with shared packages for the generated ConnectRPC types, TypeScript config and ESLint config.
- Moved every form to TanStack Form with Zod validation and every table to TanStack Table, then upgraded TanStack Table from v8 to v9.
- Improved performance by cutting unnecessary React re-renders, lazy-loading routes, shrinking bundles and using targeted cache updates instead of broad refetches.
- Introduced AI-assisted development: wrote the repo's agent documentation and Claude Code skills and commands for code review, rules checks and dependency updates.
- Built a "grill to Linear" planning process: an AI-guided session questions a feature idea until every open decision is settled, then files a Linear ticket for a vertical-slice story. Each ticket has Gherkin (Given/When/Then) acceptance criteria and comes with the agreed plan and architecture decision records. Problems are found before any code is written, each story ships testable user value on its own, and the reasoning behind each decision stays with the ticket.
