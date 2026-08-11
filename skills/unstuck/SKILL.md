---
name: unstuck
description: Break implementation loops by forcing architectural rethinking when stuck on a failing approach.
disable-model-invocation: true
argument-hint: [what-you're-stuck-on]
---

# Unstuck — Break Implementation Loops

**Stuck on:** $ARGUMENTS

---

## STOP ITERATING. THINK DIFFERENT ARCHITECTURE.

### Step 1: Autopsy the Current Approach
- What's actually failing? (Be specific — error message, behavior, symptom)
- Why can't the current approach work? (Root cause, not symptom)
- What architectural assumption is flawed?

### Step 2: Generate 5 Radically Different Strategies
Not variations of the same pattern — fundamentally different architectures.

For each:
1. **[Strategy Name]** — one-line description
   - Key change: what makes this fundamentally different
   - Complexity: Simple / Medium / Complex
   - Success likelihood: Low / Medium / High

### Step 3: Pick One
Select the simplest approach with highest success likelihood.
- Why this one
- What new problems it might introduce
- What to watch for

### Step 4: Execute
1. [Action 1]
2. [Action 2]
3. [Action 3]
4. [Validation — how to prove it works]

---

**Rules:**
- No more iterations on the old approach
- New architecture only
- If the new approach also fails after 2 attempts, run `/unstuck` again with updated context
