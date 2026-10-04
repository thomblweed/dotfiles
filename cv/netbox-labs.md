# Senior Frontend Engineer, NetBox Labs

_May 2026 – present_

Sole senior frontend engineer and frontend tech lead for the team, setting how frontend work is designed, built and delivered. The team's app is a React and TypeScript micro-frontend (Module Federation) within NetBox Labs' unified platform UI, covering network assurance and fleet management.

## Tech

- **Core:** TypeScript, React, React Router, Tailwind CSS, Vite
- **Architecture:** Module Federation (micro-frontends), npm workspaces monorepo, ConnectRPC with Protocol Buffers
- **Data and state:** TanStack Query, TanStack Table, TanStack Form, Zod, Zustand
- **Testing and quality:** Vitest, Testing Library, Playwright, ESLint, Prettier
- **Delivery:** GitHub Actions, Docker, semantic-release, Renovate, Sentry
- **AI and workflow:** Claude Code, Archon, Linear, Figma

## Responsibilities

- Lead the team's frontend direction: architecture, patterns, coding standards and tooling choices.
- Build the team's product features end to end, from Figma designs to production UI, and contribute to the shared component library they use.
- Own frontend quality and delivery: testing (Vitest, Playwright), CI, releases and dependency upkeep.
- Work with the platform team to integrate with the host application and keep shared dependencies aligned.
- Turn product requirements into well-scoped, testable vertical-slice stories.

## Achievements

- Delivered major product features, including network assurance workflows, secure credential management and a redesigned job-creation flow, rolled out behind feature flags.
- Restructured the codebase into feature-based modules and an npm workspaces monorepo with shared packages for generated API types and tooling config.
- Standardised the data and UI layer on TanStack Query, Form (with Zod) and Table, including the v8 to v9 Table upgrade.
- Improved performance by cutting unnecessary re-renders, lazy-loading routes and shrinking bundles.
- Introduced AI-assisted development to the codebase, with agent documentation, Claude Code skills and an end-to-end delivery workflow that has helped sustain around 50 delivered tickets a month (about 12 a week):
  - **Planning (grill to Linear):** an AI-guided session settles every open decision on a feature, then files a vertical-slice story with Gherkin acceptance criteria, the agreed plan and decision records.
  - **Delivery (Archon harness):** each planned ticket is built in its own git worktree, so several run at once. Parallel AI reviews (React best practices, performance and SOLID design) feed a single fix step, with linting, type checks and tests after every stage and a model sized to each step to control cost.
