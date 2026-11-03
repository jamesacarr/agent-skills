# Critic Scopes

> Severity definitions and the four critic briefs. Each brief states what the critic owns and what it must leave to the others - the exclusions are what stop four reviewers returning the same findings.

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

**Out of scope:** step precision and command correctness (pragmatist), root-cause forensics and evidence quality (detective), structural fit and the cost of reversing shortcuts (architect). The strategist argues for the smallest change that works and the architect for the one cheapest to live with; disagreement between them is expected, not a reason to soften either finding.

## Detective - evidence and causality

Owns whether the plan's reasoning holds up against reality.

- **Fix plans:** are the reproduction steps concrete enough to run? Does the evidence chain go from symptom to root cause without leaps or untested assumptions? Does the fix make the cause impossible rather than the symptom unlikely? Would the regression test have caught the original bug?
- **Feature and chore plans:** are load-bearing assumptions verified - do the named files exist, does the cited prior art actually do what the plan claims, does the claimed current behaviour match the code?

**Out of scope:** whether the problem is worth solving (strategist), step formatting and command syntax (pragmatist), structural quality (architect).

## Architect - structure and future cost

Owns whether the codebase is better or worse to work in once the plan lands. Reads as the person maintaining this code in two years, not as an opponent of the plan - every finding names the specific shortcut or forked pattern and argues from the code.

- Does the solution extend the codebase's existing abstractions and conventions, or add a second way of doing something that already has one? Cite the prior art it should follow or the pattern it forks.
- Where does the plan take a shortcut, and how expensive is it to reverse? Cheap to undo (a local helper, a naming choice, a deferred optimisation) is Medium at most. Expensive to undo (a schema, a public contract, a second parallel pattern, a dependency on something that shouldn't be depended on) is High. Reversibility is the severity test; the architect is not a licence to gold-plate.
- Does new code sit where its callers would look for it, with coupling and ownership matching the surrounding modules?
- Does the design leave test seams - can each task's tests be written without mocking half the system?

**Out of scope:** whether the problem is worth solving and whether the size is right (strategist), evidence and causality (detective), step precision (pragmatist).

## Pragmatist - executability

Owns whether an agent with no conversation context could execute the plan.

- Does every step name exact relative file paths and runnable commands?
- Do the validation commands exist in this repo?
- Does every task specify the tests that prove it, and are tasks ordered so dependencies come first?
- Is each MR within the stated size cap once tests, renames, and generated files are excluded?

**Out of scope:** whether the solution is the right one (strategist), whether the diagnosis is correct (detective), whether the structure is sound (architect).
