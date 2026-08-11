---
description: How to report verification results honestly — distinguish inspected vs sampled and verified vs appears; required Method/Coverage/Result/Evidence schema for load-bearing claims; surface coverage gaps; name background processes in plain language.
globs: *
alwaysApply: true
---

# Reporting Discipline

When reporting results of investigations, scans, or verification steps, distinguish precisely:

- **inspected** (each hit individually read) vs **sampled** (a subset read).
- **verified** (tested/confirmed) vs **appears** (inference from partial evidence).

When a claim is load-bearing for a non-reversible action (push, merge, delete, remote creation, history rewrite), state the exact verification method and its coverage. No summary claims standing in for evidence.

## Required format for load-bearing reports

- **Method**: the exact command or procedure used
- **Coverage**: what set of files/commits/objects was inspected, and what was not
- **Result**: precisely what was found, distinguishing verified from inferred
- **Evidence**: raw output excerpt or reference to it

## Coverage gaps

Surface gaps rather than hide them. A report that says "sampled 7 of 69, 62 un-inspected, here is the list" is correct. A report that says "spot-checked all 562 hits, clean" when only 7 files were read is a violation.

## When a check fails silently

If a command's output doesn't match expectation (e.g., a grep returns zero hits but you directly saw a match elsewhere), do not accept the zero result. Verify the command itself. Regex portability, shell escaping, and BSD vs GNU tool differences are common silent-failure modes. Re-run with a simpler method to confirm.

## In-flight process transparency

Background processes (CI watchers, deploy waiters, long-running shells, polled jobs) must be surfaced in human-readable terms whenever they're referenced in agent output. Internal handles, PIDs, or generated identifiers are NEVER the primary reference.

Required fields when announcing or referencing a background process:
- What it is in plain language (e.g., "post-merge CI watcher on main")
- The target it's observing (run ID, commit SHA, URL — whichever applies)
- Expected duration based on prior runs of the same operation, or "unknown" if no prior data
- An independently-verifiable URL or command the user can run to observe the same data without waiting on the agent

Internal handles MAY appear as a secondary reference for the agent's own task tracking, but never as the only reference.

Failure mode this prevents: "waiting on poll br5h2qdd1" with no way for the user to see what's actually happening.

## Background shell lifecycle

Every background shell spawned by an agent must:
1. Declare its termination condition at spawn time, in plain language ("exits when CI run 25239969494 reports a conclusion").
2. Be explicitly released or killed when its reason for existing is satisfied. Do not let watchers persist past their target's completion.
3. Appear in any session status output with current state: running / awaiting-condition / orphaned. Orphaned shells must be flagged for cleanup, not silently retained.

Cumulative shell leakage across unrelated tasks is a defect, not a quirk.
