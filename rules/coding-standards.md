---
description: Universal coding standards for file structure, naming, type safety.
globs: *
alwaysApply: true
---

# Coding Standards

## Structure
- 350 lines max per file. Single responsibility. Composition over inheritance.

## Naming
- Classes/Components: PascalCase. Constants: UPPER_SNAKE_CASE. Files: kebab-case.
- Functions/variables: follow framework convention (camelCase JS/TS, snake_case Python/PHP).

## Type Safety
- Type all function signatures — parameters and return values.
- No `any`/`object`/`mixed` escape hatches without explicit justification.
- Use framework data models (Pydantic, Zod) for structured data.

## Prohibited
- Commented-out code. Debug statements. Magic numbers/strings. Generic exception catching.

## Required
- Error handling on all external calls. Input validation at boundaries. Try/catch on I/O.
- KISS, YAGNI, DRY. Industry standard libraries first. No mocks, placeholders, or omitted code.
