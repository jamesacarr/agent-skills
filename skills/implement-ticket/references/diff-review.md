# Diff Review

> Review of each MR's diff against plan.md before the MR opens - by a fresh context, never the agent that wrote the code. Two scoped reviewers in parallel, the plan critics' severity gate, and the session's own model.

## Why a separate step

The plan critics review intent. Most debt enters afterwards: the implementer meets a case the plan didn't anticipate and takes the shortcut - a second helper beside the one it should have extended, a TODO, a suppressed lint rule, a test weakened until it passes. Nothing in the plan review sees that, and a reviewer sharing the implementer's context inherits its justifications. So the review is a fresh invocation, and it runs before the MR exists rather than as MR comments the user has to triage.

The reviewers don't hunt correctness bugs. Where the harness has a code-review skill, run it as well; it doesn't replace this step, because it has no idea what the plan promised.

## Reviewers

Both read plan.md and the MR's diff (`git diff <base>...HEAD` on its branch, where base is the branch this MR depends on in the plan's MR stack, or the default branch for the first), then verify against the working tree rather than the diff alone - a shortcut can live in a file the diff never touched.

### Conformance - did the plan happen

- Every task assigned to this MR is implemented, and nothing outside the plan landed: no drive-by refactors, unrelated fixes, or scope creep.
- The tests the plan named per task exist and assert behaviour, not implementation detail.
- The plan's validation commands pass - re-run them; don't trust the implementer's summary.
- The MR's reviewer-facing size is within the plan's cap; if not, say what to split out.

**Out of scope:** whether the code is well shaped (architect).

### Architect - what the implementer decided alone

Owns the decisions the plan left open, judged with the same test as plan-ticket's architect critic: expensive to reverse is High, cheap to reverse is Medium at most.

- Pattern fidelity: does the code extend the prior art the plan cited, or add a second way of doing something the codebase already does one way?
- Shortcuts: TODOs, suppressed lint or type errors, skipped or weakened tests, hardcoded values, copied logic. Each is either in the plan or a finding.
- Placement and coupling: new code sits where its callers would look for it and depends on nothing it shouldn't.
- Deviations from the plan's design decisions are justified in a commit message, or they are a finding.

**Out of scope:** task completeness and command results (conformance).

## Severity and gate

The plan critics' severities are defined for a plan; these are the diff equivalents. Findings are `severity`, `file` (path, with a line where it helps), `finding`, `why` - a finding without a why is an opinion.

| Severity | Meaning |
|----------|---------|
| High | Merging the MR as written would miss a planned task or acceptance criterion, ship a shortcut that is expensive to reverse, or leave a validation command failing. Blocks the MR. |
| Medium | A material improvement with a clear fix - a cheap-to-reverse shortcut, a test that proves less than the plan asked. Applied or deferred with a reason. |
| Low | Polish. Never blocks. |

| Severity | Action |
|----------|--------|
| High | Fix the implementation - re-run the implementer with the finding, or edit directly when the fix is small - then re-run both reviewers on the new diff |
| Medium | Fix if the change is clear; otherwise record it in the MR description under a known-deferrals line with the reason |
| Low | Optional |

Highs still open after three rounds mean the plan was wrong, not the code. Stop and take the surviving findings to the user with the plan section they contradict.

## Running it

Same orchestration as plan-ticket's references/orchestration.md, with `file` in place of `section` in the findings schema and the diff command in the prompt: the Workflow tool in Claude Code, parallel read-only subagents elsewhere, sequential self-review (reported as such) when the harness has no subagents. No model override - the reviewers are a reasoning role and run on the session's model (plan-ticket's references/model-tiers.md). Run it per MR in the stack, once that MR's branch is complete and before opening it.
