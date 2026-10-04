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
- Built an end-to-end AI-assisted delivery workflow in two stages, planning and delivery:
  - **Planning (grill to Linear):** an AI-guided session questions a feature idea until every open decision is settled, then files a Linear ticket for a vertical-slice story. Each ticket has Gherkin (Given/When/Then) acceptance criteria and comes with the agreed plan and architecture decision records. Problems are found before any code is written, each story ships testable user value on its own, and the reasoning behind each decision stays with the ticket.
  - **Delivery (Archon harness):** an Archon workflow picks up the planned ticket and takes it to tested, reviewed code. It won't start unless the ticket has a plan from the planning stage, so every build begins from agreed requirements. Each ticket runs in its own git worktree, so several tickets can be built at once without interfering with each other. Within each run, three AI reviews (React best practices, re-render performance and SOLID design) run in parallel, and a single step then combines and fixes their findings. Linting, type checks, formatting and unit tests run after every stage. Each step starts with a clean context and uses a model sized to the job, which keeps quality consistent and costs down. A typical run takes about 20 minutes.
  - Together, the two stages have helped sustain an average of around 50 delivered tickets a month (about 12 a week) since joining.
