---
name: tech-docs
description: Generate and maintain technical documentation. Covers READMEs, architecture decision records (ADRs), API docs, runbooks, and onboarding guides.
disable-model-invocation: true
argument-hint: [readme|adr|runbook|onboarding|api-docs]
allowed-tools: Read, Grep, Glob, Bash(tree *), Bash(wc *)
---

# Technical Documentation Writer

## Document Templates

Templates in `templates/` directory:
- [README template](templates/readme-template.md) — Standard project README structure
- [ADR template](templates/adr-template.md) — Architecture Decision Record
- [Runbook template](templates/runbook-template.md) — Operational procedure playbook
- [Onboarding template](templates/onboarding-template.md) — Developer onboarding checklist

## Documentation Quality Checks
- Every public function/endpoint has a brief description
- README can get a new developer from zero to running in < 15 minutes
- ADRs exist for every non-obvious architectural choice
- Runbooks exist for every operational procedure
- No documentation references removed code or outdated APIs
