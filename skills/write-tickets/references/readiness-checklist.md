# Readiness Checklist

> Criteria for deciding whether a ticket is ready for development, plus the format for reporting an audit. Use when creating a ticket (close gaps before presenting) or auditing an existing one (score and report).

## Structure Check

Confirm the type's sections are present and non-empty (see `writing-guide.md`):

- **All types**: User Statement (Objective for Spikes), Background, Technical Notes, Acceptance Criteria (Success Criteria for Spikes)
- **Bugs**: Reproduction Steps with expected vs actual
- **Stories & Bugs**: Potential Solutions, where a real choice exists
- **Spikes**: Spike Scope, Timebox, Output

## INVEST

| Criterion | Question | Red flag |
|-----------|----------|----------|
| **I**ndependent | Can it be delivered without waiting on other tickets? | "Blocked by..." with no resolution path |
| **N**egotiable | Is there room for the implementer to decide? | Over-prescriptive implementation detail |
| **V**aluable | Would a user or stakeholder care if it shipped? | No clear "so that..." benefit |
| **E**stimable | Can the team confidently size it? | Unclear scope, unknown technology |
| **S**mall | Can it be scoped to a single cohesive change? | Multiple unrelated changes or an unclear scope boundary - split it |
| **T**estable | Can we write acceptance tests for it? | Vague criteria like "works correctly" |

## General Criteria

Apply to all types:

- [ ] Value, expected outcome, and "why" are clear
- [ ] Belongs to an appropriate parent/project (where the tracker supports it)
- [ ] Dependencies identified and minimised; blockers linked
- [ ] Acceptance criteria (or reproduction steps for bugs) are well-defined and testable
- [ ] Test approach considered, including adding tests where applicable
- [ ] Rollout concerns noted where relevant (feature flag, migration, data)

## Per-Type Criteria

**Story**
- [ ] Clear title and description; user-focused User Statement
- [ ] Detailed ACs, preferably Given/When/Then for state-dependent behaviour
- [ ] Design links included where relevant
- [ ] Scenarios for different account types / roles where relevant

**Bug**
- [ ] Reproduction steps, expected vs actual behaviour
- [ ] Environment details (browser/OS/version)
- [ ] Links to logs or screenshots where applicable
- [ ] Regression test called out in the ACs

**Spike**
- [ ] Explicit timebox
- [ ] Defined output destination for learnings
- [ ] Success criteria framed as questions answered / decisions enabled, not feature delivery

## Readiness Verdict

Count each met criterion as 1; skip criteria that don't apply and reduce the denominator accordingly.

| Score (criteria met / applicable) | Verdict |
|------|---------|
| 100% | Ready for development |
| 80-99% | Nearly ready - minor gaps |
| 60-79% | Needs work - several gaps |
| <60% | Not ready - significant gaps |

## Audit Output Format

Report findings as:

```markdown
## Audit: {ticket title or ID}

### Passing
- [x] {criterion met}

### Issues Found
1. **{Most critical first}** - {what's wrong}
   → {concrete fix}
2. **Vague acceptance criteria** - "works correctly" is not testable
   → {rewritten, testable version}

### Corrected Description
{the full revised description, ready to apply}
```

Supply the rewritten content for vague sections, not just "make it specific". Flag gaps you can't resolve (missing parent, unknown timebox) rather than inventing values.
