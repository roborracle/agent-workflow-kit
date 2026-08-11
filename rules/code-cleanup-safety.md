# Code & Content Cleanup Safety

Covers both code and written content — prose, docs, plans, sections.

## Code

- One atomic change at a time. Test after each. Revert immediately on failure.
- Work on a safety branch: `refactor/<description>`.
- Never combine cleanup types in one commit. Formatting and logic do not travel together.
- Never remove code without verifying zero references across the entire codebase.
- Never modify business logic during a cleanup commit.
- Never use `@ts-ignore`, `eslint-disable`, `# noqa`, or `phpcs:ignore` to hide a new error.
  Suppressing a warning you just created is not cleanup.
- Every cleanup commit must be independently revertable.

## Written Content

- Only modify content related to the current task. Don't reformat, restructure, or "improve"
  sections nobody asked about.
- Match the existing voice and structure even if you'd write it differently. Consistency across
  a document beats local improvement in one paragraph.
- Before significantly altering content someone else wrote — rewriting sections, removing
  paragraphs, restructuring flow, changing tone — stop, describe exactly what you intend to
  change and why, then wait. This is confirmation gate 1 in `rules/decision-boundaries.md`.
- Minor edits — typos, formatting, a single-sentence clarification — don't need confirmation.
  The gate fires on *significant*.
- If you notice unrelated content worth improving, note it under "Follow-up needed" in the
  end-of-task summary. Don't touch it.

## The surgical principle

Every changed line should trace directly to the request. If you can't point at the sentence in
the ask that a given diff hunk serves, it doesn't belong in this commit.

See `skills/karpathy-guidelines/SKILL.md`.
