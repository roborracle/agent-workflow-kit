---
name: webapp-testing
description: Write comprehensive tests, run test suites, analyze failures, and fix tests while maintaining test integrity. Covers unit testing, integration testing, E2E testing with Playwright, and test-driven development. Use after code changes to ensure coverage or when creating new test suites.
argument-hint: [file-or-feature-to-test]
---

# Web Application Testing

Comprehensive test automation covering unit, integration, and E2E testing.

## Test Types
| Type | Scope | Speed | Use For |
|------|-------|-------|---------|
| Unit | Single function | <100ms | Logic, utilities |
| Integration | Component interaction | <1s | APIs, services |
| E2E | Full user journey | <30s | Critical paths |

## Best Practices
- Test behavior, not implementation
- One assertion per test for clarity
- AAA pattern: Arrange, Act, Assert
- Create test data factories
- Mock external dependencies appropriately

## Playwright E2E Testing

### Decision Tree
```
Static HTML? → Read HTML for selectors → Write script
Dynamic? → Server running? → No → Use with_server.py helper
                           → Yes → Navigate + wait networkidle → Screenshot → Identify selectors → Execute
```

### Using with_server.py
```bash
python scripts/with_server.py --server "npm run dev" --port 5173 -- python test.py
```

### Template
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('http://localhost:5173')
    page.wait_for_load_state('networkidle')  # CRITICAL
    # ... test logic
    browser.close()
```

## TDD Workflow
1. Identify affected test files after code changes
2. Run tests: `npm test` or `pytest`
3. On failure: Parse errors, distinguish legitimate failure vs outdated expectations vs environment
4. Fix: Preserve original intent, update expectations only for legitimate changes, never weaken tests to pass

## Common Pitfalls
- **Don't** inspect DOM before `networkidle` on dynamic apps
- **Don't** use flaky selectors that change
- **Do** use descriptive selectors: `text=`, `role=`, IDs
- **Do** wait for `page.wait_for_load_state('networkidle')`

## Quality Gates
- All tests passing before merge
- Coverage maintained or improved
- No skipped tests without justification
- E2E tests cover critical user journeys
- Tests run in <10 minutes total
