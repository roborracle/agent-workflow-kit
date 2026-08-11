---
name: state-machine-diagrams
description: "Create comprehensive finite state machine (FSM) diagrams for architecture documentation (state machine, FSM, state diagram, workflow diagram, state transitions, document states)."
disable-model-invocation: true
---

# State Machine Diagram Creator

Create authoritative, read-only FSM documentation for complex systems.

## Process Overview

```
  1. EXPLORE          2. IDENTIFY         3. DIAGRAM          4. PROTECT
  ───────────         ──────────          ────────            ────────
  Search codebase     Find all states     Create ASCII        chmod 444
  for state usage     and transitions     art diagrams        (read-only)
```

## Step 1: Explore the Codebase

### Search Patterns

```bash
# Find state/status enums
grep -r "enum.*Status" --include="*.ts" --include="*.prisma"
grep -r "enum.*State" --include="*.ts"

# Find state transitions
grep -r "status:" --include="*.ts" | grep -E "(PENDING|QUEUED|ACTIVE)"
grep -r "\.update\(" --include="*.ts" | grep status

# Find queue/job definitions
grep -r "Queue\|Worker\|Job" --include="*.ts"

# Find error codes
grep -r "errorCode" --include="*.ts"
```

### Key Files to Examine

| File Type | Look For |
|-----------|----------|
| `schema.prisma` | Enum definitions, model relationships |
| `*-worker.ts` | State transitions in job processing |
| `route.ts` | API-triggered state changes |
| `lib/*.ts` | Core business logic, token management |

## Step 2: Identify States and Transitions

### State Inventory Template

```markdown
| State | Description | Entry Conditions | Exit Conditions |
|-------|-------------|------------------|-----------------|
| PENDING | Initial state | Record created | Worker picks up |
| QUEUED | In queue | Worker processes | Job executes |
| ACTIVE | Processing | Job starts | Job completes |
| COMPLETED | Success | All steps done | (final) |
| FAILED | Error | Exception thrown | (final or retry) |
```

### Transition Matrix

```markdown
| From / To | PENDING | QUEUED | ACTIVE | COMPLETED | FAILED |
|-----------|---------|--------|--------|-----------|--------|
| PENDING   | -       | Y      | N      | N         | Y      |
| QUEUED    | N       | -      | Y      | N         | Y      |
| ACTIVE    | N       | N      | -      | Y         | Y      |
| COMPLETED | N       | N      | N      | -         | N      |
| FAILED    | Y*      | N      | N      | N         | -      |

* = Via recovery mechanism only
```

## Step 3: Create ASCII Diagrams

### Basic State Machine Template

```
                              +------------+
                              |   START    |
                              +-----+------+
                                    |
                                    | [trigger event]
                                    v
                             +-----------+
                     +-------| STATE A   |-------+
                     |       +-----+-----+       |
                     |             |              |
                     | [error]    | [success]    | [timeout]
                     |             v              |
                     |       +-----------+        |
                     |       | STATE B   |        |
                     |       +-----+-----+        |
                     |             |              |
                     |             v              |
                     |       +-----------+        |
                     +------>| STATE C   |<-------+
                             | (final)   |
                             +-----------+
```

### ASCII Art Reference

```
BOXES:
+---------+    +==========+
| Single  |    | Double   |
+---------+    +==========+

ARROWS:
-> <- (horizontal)    | (vertical)    v ^ (direction)

SPECIAL:
* o          Decision points
--- |        Lines
+ (corners and junctions)
```

### Polling/Retry Pattern

```
              +----------------+
              | INITIAL STATE  |
              | retryCount = 0 |
              +-------+--------+
                      |
                      | trigger
                      v
            +---------------------+
            |    CHECK STATE      |<-----------+
            |    retryCount++     |            |
            +----------+----------+            |
                       |                       |
           +-----------+-----------+           |
           |           |           |           |
           v           v           v           |
     +----------+ +----------+ +----------+    |
     | SUCCESS  | | PENDING  | | ERROR    |    |
     | (final)  | |          | |          |    |
     +----------+ +----+-----+ +----+-----+    |
                       |            |          |
                       | delay      | retry?   |
                       v            v          |
                 +----------+  +----------+    |
                 | count    |  | count    |    |
                 | < MAX?   |  | < MAX?   |    |
                 +----+-----+  +----+-----+    |
                      |             |          |
                  +---+---+    +---+---+       |
                  |       |    |       |       |
                  v       v    v       v       |
            +--------+ +--------+ +-----------++
            |Schedule| | FAILED | | Retry     |
            |next    |-+ (final)| |           |
            +--------+ +--------+ +-----------+
```

## Step 4: Document Supporting Information

### Time Constants Section

```markdown
| Constant | Value | Location |
|----------|-------|----------|
| RETRY_DELAY_INITIAL | 5 seconds | lib/queue/index.ts:44 |
| RETRY_DELAY_MAX | 24 hours | workers/processor.ts:15 |
| TOKEN_REFRESH_BUFFER | 5 minutes | lib/oauth/google.ts:189 |
```

### Error Codes Section

```markdown
| Code | Meaning | Recovery | Final State |
|------|---------|----------|-------------|
| queue_unavailable | Redis down | Automatic | PENDING |
| auth_failed | OAuth expired | User action | FAILED |
| rate_limited | API throttled | Auto-retry | QUEUED |
| invalid_input | Bad request | None | DROPPED |
```

### Invariants Section

```markdown
## System Invariants

These rules MUST NEVER be violated:

1. **Unique Constraint**: One status per entity per type
2. **Forward-Only Transitions**: States progress forward (never COMPLETED -> PENDING)
3. **Final States Are Immutable**: COMPLETED and DROPPED never transition out
```

## Step 5: Finalize Document

### Document Structure

```markdown
# [System Name] Architecture - Finite State Machines

> **AUTHORITATIVE DOCUMENT**: This file defines canonical state machines.
> All code changes MUST conform to these transitions.

---

## Table of Contents
1. Primary State Machine
2. Secondary Workflows
3. Error Recovery
4. Time Constants
5. Error Codes
6. Invariants

---

[... diagrams and content ...]

---

## Appendix: File Reference

| Component | File | Lines |
|-----------|------|-------|
| State enum | schema.prisma | 192-200 |
| Worker | workers/processor.ts | 50-150 |
| API | app/api/route.ts | 20-80 |
```

### Make Read-Only

```bash
chmod 444 docs/ARCHITECTURE_FSM.md
```

## Validation Checklist

- [ ] All states from enums are documented
- [ ] All valid transitions are shown with arrows
- [ ] All invalid transitions are noted
- [ ] Error states and recovery paths documented
- [ ] Time constants have file:line references
- [ ] Error codes have recovery actions
- [ ] Invariants are explicitly stated
- [ ] File is set to read-only (chmod 444)
- [ ] Document version and date are set
