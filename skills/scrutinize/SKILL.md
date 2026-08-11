---
name: scrutinize
description: "Evaluate a decision or approach with competing alternatives, tradeoff analysis, and multi-perspective review (evaluate, compare approaches, analyze tradeoffs)."
disable-model-invocation: true
argument-hint: [problem-description]
---

# Scrutinize — Multi-Paradigm Deep Evaluation

Rigorous evaluation of a problem, solution, or code with competing approaches and honest tradeoff analysis.

## Phase 0: Prior Art
Has this been solved before? What can we steal? What can we improve?

## Phase 1: Problem Decomposition
- State what you're REALLY solving (not what was asked)
- List assumptions, especially hidden ones
- Define success criteria BEFORE generating solutions

## Phase 2: Competing Solutions
Generate 2-3 fundamentally different approaches. For each:
- Core idea (1 sentence)
- Implementation (real code, not pseudocode)
- Big-O complexity
- Fatal flaw (there's always one)
- When it wins / when it loses

## Phase 3: Peer Review
Channel three perspectives:
- **The Skeptic**: "This breaks when..."
- **The User**: "This is annoying because..."
- **The Maintainer**: "In 6 months, I'll hate that..."

## Phase 4: Decision
Recommend with evidence, acknowledge uncertainty:
- "I choose X because [data]"
- "I'm unsure about [specific risk]"
- "Smarter approach might be [alternative]"

## Phase 5: Implementation
Implement on a branch: `scrutinize/[task]-[solution-chosen]`
Include decision log as comments. Add TODO for identified weaknesses.

## Escape Hatches
- If obvious solution exists: State it, explain why scrutiny adds no value
- If blocked: List what information would unblock
