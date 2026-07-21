# Critic Scopes

> Severity definitions and the three critic briefs. Each brief states what the critic owns and what it must leave to the others - the exclusions are what stop three reviewers returning the same findings.

## Severity

| Severity | Meaning |
|----------|---------|
| High | Implementing the plan as written would fail, fix the wrong thing, or create an outsized hazard (data loss, breaking contract). Blocks the plan. |
| Medium | A material improvement with a clear fix. Applied or explicitly deferred. |
| Low | Polish. Never blocks. |

Critics report findings as structured items: `severity`, `section` (plan heading), `finding` (what is wrong), `why` (the reasoning or evidence). A finding without a why is an opinion.

## Strategist - problem and value

Owns whether the plan solves the right problem at the right size.

- Is the ticket still valid? The problem may have been fixed, superseded, or misdescribed - verify its claims against the current codebase.
- Does the solution match the problem's size - neither gold-plated nor under-delivering the acceptance criteria?
- Were meaningfully different alternatives considered, including the smallest change that could work?
- Is the MR stack split at real seams, each MR independently mergeable and reviewable?

**Out of scope:** step precision and command correctness (pragmatist), root-cause forensics and evidence quality (detective).

## Detective - evidence and causality

Owns whether the plan's reasoning holds up against reality.

- **Fix plans:** are the reproduction steps concrete enough to run? Does the evidence chain go from symptom to root cause without leaps or untested assumptions? Does the fix make the cause impossible rather than the symptom unlikely? Would the regression test have caught the original bug?
- **Feature and chore plans:** are load-bearing assumptions verified - do the named files exist, does the cited prior art actually do what the plan claims, does the claimed current behaviour match the code?

**Out of scope:** whether the problem is worth solving (strategist), step formatting and command syntax (pragmatist).

## Pragmatist - executability

Owns whether an agent with no conversation context could execute the plan.

- Does every step name exact relative file paths and runnable commands?
- Do the validation commands exist in this repo?
- Does every task specify the tests that prove it, and are tasks ordered so dependencies come first?
- Is each MR within the stated size cap once tests, renames, and generated files are excluded?

**Out of scope:** whether the solution is the right one (strategist), whether the diagnosis is correct (detective).
