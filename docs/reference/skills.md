# Skill catalog

43 skills. You don't need to memorize this — the assistant matches skills to the task on its
own. This page is for when you want to invoke one deliberately, or want to check whether
something already exists before you write it.

Invoke any of them by name: `/code-reviewer`, `/release-manager`, and so on.

Categories are for human navigation only. On disk every skill is a flat
`skills/<name>/SKILL.md`, because that is the only depth the plugin loader discovers.

## Core

| Skill | What it does |
|---|---|
| `/code-cleanup-guardian` | Safely refactor and clean up code without breaking existing functionality. |
| `/dep-audit` | Audit project dependencies for security vulnerabilities, outdated packages, and license compliance |
| `/git-issue-sync` | Audit git history against GitHub Issues to find untracked work and ensure compliance |
| `/github-issues-manager` | Automatically create GitHub issues for every quantifiable task during planning and development. |
| `/handoff` | Use when ending, pausing, or wrapping up a working session, or when asked to write or update hand-off, continuity, or … |
| `/init-project` | Initialize a new project with Claude Code .claude/ directory, CLAUDE.md, framework-specific rules, and standard configuration |
| `/karpathy-guidelines` | Behavioral lens for code work — surface uncertainty, write minimal code, change only what's asked, define success criteria … |
| `/resume` | Generate a project briefing showing where you left off with recommended next steps |
| `/scrutinize` | Evaluate a decision or approach with competing alternatives, tradeoff analysis, and multi-perspective review |
| `/skill-builder` | Guide the creation, optimization, or auditing of Claude Code skills following official best practices |
| `/survey` | Run a project health diagnostic covering git hygiene, dependency security, test health, and stale issues |
| `/unstuck` | Break implementation loops by forcing architectural rethinking when stuck on a failing approach. |

## Development

| Skill | What it does |
|---|---|
| `/ai-engineer` | Build AI-powered applications with LLMs, embeddings, RAG systems, and AI agents. |
| `/api-client` | Integrate with third-party APIs and webhooks. |
| `/code-reviewer` | Comprehensive code review from senior engineering perspective following OWASP standards and industry best practices. |
| `/contract-test` | Detect breaking API changes before merge. |
| `/db-migrate` | Design and execute safe database migrations. |
| `/env-config` | Design and manage application configuration across environments. |
| `/error-observability` | Implement structured error handling, logging, metrics, and observability. |
| `/git-commit-helper` | Create properly formatted, detailed commit messages following Conventional Commits specification. |
| `/git-protocol` | Audit git workflow compliance including branch architecture, commit standards, issue linkage, and production readiness |
| `/parallel-agent-git-isolation` | Use when planning to dispatch 2+ sub-agents that will each perform git operations (add/commit/branch). |
| `/pr-workflow` | Create a pull request with auto-generated title, body, and linked issues from commit history |
| `/rapid-builder` | Quickly prototype and build functional applications across web and mobile platforms. |
| `/release-manager` | Execute end-to-end release workflow. |
| `/shadcn-ui` | Complete shadcn/ui expertise covering component selection, implementation, customization, and composition. |
| `/state-management` | Design frontend state architecture. |
| `/web-dev-fundamentals` | Web development standards for HTML structure, CSS organization, JavaScript loading, fonts, performance, images, and SEO basics. |

## Design

| Skill | What it does |
|---|---|
| `/frontend-design` | Create distinctive, production-grade frontend interfaces with high design quality. |
| `/ux-design-system` | Comprehensive UX/UI design system covering premium design patterns, brand consistency, visual storytelling, design reviews, and … |

## Testing

| Skill | What it does |
|---|---|
| `/a11y-audit` | Audit frontend code for WCAG 2.1 AA accessibility compliance including semantic HTML, ARIA, keyboard navigation, and color … |
| `/webapp-testing` | Write comprehensive tests, run test suites, analyze failures, and fix tests while maintaining test integrity. |

## Architecture

| Skill | What it does |
|---|---|
| `/state-machine-diagrams` | Create comprehensive finite state machine (FSM) diagrams for architecture documentation |
| `/system-architect` | Design scalable backend systems, APIs, databases, and infrastructure. |

## DevOps

| Skill | What it does |
|---|---|
| `/devops-automator` | Set up CI/CD pipelines, configure cloud infrastructure, implement monitoring systems, and automate deployment processes. |
| `/incident-response` | Handle production incidents with structured triage, communication, and blameless postmortems. |

## Documentation

| Skill | What it does |
|---|---|
| `/changelog-enforcer` | Ensure mandatory changelog updates accompany every code change. |
| `/tech-docs` | Generate and maintain technical documentation. |

## Project management

| Skill | What it does |
|---|---|
| `/product-strategist` | Strategic product development covering roadmap planning, sprint prioritization, feature scoping, and shipping decisions. |
| `/sprint-planner` | Break down a project into sprints with atomic, testable tasks as GitHub Issues |
| `/workflow-optimizer` | Analyze and optimize development workflows, identify bottlenecks, automate repetitive tasks, and improve team efficiency. |

## Research

| Skill | What it does |
|---|---|
| `/market-researcher` | Conduct market research, analyze trends, synthesize user feedback, and identify opportunities. |
| `/ux-research` | Conduct user research, analyze behavior patterns, create personas, map user journeys, and synthesize insights into actionable … |

---

## Adding one

`skills/<name>/SKILL.md`, one level deep, with `name` and `description` in the frontmatter and
`name` matching the directory. Run `./scripts/validate.sh` before opening the pull request — a
malformed skill fails silently, which means the person who needed it never gets it and never
finds out why.

See [`CONTRIBUTING.md`](../../CONTRIBUTING.md).
