---
name: dep-audit
description: "Audit project dependencies for security vulnerabilities, outdated packages, and license compliance (check dependencies, security audit, are packages outdated)."
disable-model-invocation: true
context: fork
agent: general-purpose
argument-hint: [security|outdated|licenses|all]
allowed-tools: Bash(npm *), Bash(composer *), Bash(pip *), Read, Grep, Glob
---

# Dependency Audit

## Pre-fetched State

### Package Manager Detection
!`ls package.json composer.json requirements.txt Pipfile pyproject.toml Cargo.toml go.mod 2>/dev/null || echo "No package manager files found"`

### Node Security Audit
!`npm audit --json 2>/dev/null | jq '{vulnerabilities: .metadata.vulnerabilities, total: .metadata.totalDependencies}' 2>/dev/null || echo "Not a Node project or npm not available"`

### Node Outdated
!`npm outdated --json 2>/dev/null | jq 'to_entries | map({name: .key, current: .value.current, wanted: .value.wanted, latest: .value.latest}) | .[:20]' 2>/dev/null || echo "Not a Node project"`

### PHP Security Audit
!`composer audit --format=json 2>/dev/null || echo "Not a PHP project"`

### PHP Outdated
!`composer outdated --direct --format=json 2>/dev/null || echo "Not a PHP project"`

---

## Your Task

Audit scope: $ARGUMENTS (blank = all)

### 1. Security Vulnerabilities
- Parse audit results from pre-fetched data
- Categorize by severity: critical, high, moderate, low
- For each critical/high vulnerability, provide:
  - Package name and affected version
  - Vulnerability description
  - Fix: `npm audit fix` or specific version update command

### 2. Outdated Dependencies
- Flag packages more than 2 major versions behind
- Flag packages with known EOL dates
- Prioritize updates by: security fixes > major features > minor updates

### 3. License Compliance
If audit scope includes "licenses":
```bash
npx license-checker --summary 2>/dev/null || echo "license-checker not available"
```
- Flag any GPL/AGPL in commercial projects
- Flag any unknown licenses

### 4. Generate Report

```
DEPENDENCY HEALTH: [HEALTHY | WARNING | CRITICAL]

Security:
  Critical: X vulnerabilities
  High: X vulnerabilities
  Moderate: X vulnerabilities

Outdated:
  Major updates available: X packages
  Minor/patch updates: X packages

Action Items:
1. [Most urgent — critical security fixes]
2. [High priority — security + major updates]
3. [Routine — minor updates]

Quick Fix:
[Exact commands to resolve critical issues]
```
