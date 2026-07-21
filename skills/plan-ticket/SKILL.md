---
name: plan-ticket
description: Authors and reviews an implementation plan for a ticket - codebase research, a persisted plan.md with an MR stack, and a scoped-critic review loop sized to the ticket's risk. Use when planning a ticket, spec'ing out a feature, fix, or chore before implementation, or whenever a reviewed plan is needed before creating an implementation workflow. Produces the plan only. Do NOT use for writing ticket content (use write-tickets) or for executing a finished plan.
---

# plan-ticket

## Essential Principles

- **The plan is a contract, not a scratchpad.** It is persisted to disk so the user can review it before implementation starts, it survives across sessions, and it becomes the sole input to the implementation run - which is why every step needs exact paths and commands an agent with no conversation context could follow.
- **Critics get exclusive scopes.** Same-model reviewers converge on the same obvious findings; giving each critic a scope and telling it what is out of scope forces coverage instead of triplicate feedback.

## When to Use

In a ticket flow, this skill sits after the ticket is validated and a branch or worktree exists, and before any implementation work is created. Its output (`plan.md`) is what the user reviews at their stop-and-clarify checkpoint, and what each implementation run is derived from.

Skip it when the user asks for a direct change with no ticket-shaped scope - planning ceremony on a one-line edit is waste.

## Steps

### Step 1: Intake and Classify

Require the ticket details (key, description, acceptance criteria). If they are not in the conversation, fetch them with the tracker's skill or ask the user - do not plan from a bare ticket key.

While reading the ticket, sanity-check it: is the problem still real, and is the stated information consistent with the codebase? Note doubts now; the strategist critic will probe them, but obvious staleness should stop the plan before research starts.

Classify the type and size the panel. Reviewer agents cost tokens - the goal is the right number for the ticket's risk, not the maximum:

| Type | Signal |
|------|--------|
| feature | New capability or behaviour change users will notice |
| fix | Existing behaviour is wrong; there is a symptom to reproduce |
| chore | Internal improvement with no user-visible behaviour change |

| Ticket risk | Panel | Why |
|-------------|-------|-----|
| One obvious, contained, easily reversed change | No critics | Review costs more than the change; write a minimal plan and record why the panel was skipped |
| Small and contained: most chores, simple fixes | 1 - pragmatist | Executability is the floor every plan must meet |
| Multi-file work with real design choices | 2 - pragmatist + strategist (feature/chore) or pragmatist + detective (fix) | Add the lens matching the dominant failure mode: wrong scope vs wrong cause |
| Hard to reverse, shared abstractions, data model or API changes, multi-component | 3 - all critics | The change is expensive to get wrong; full coverage pays for itself |

State the chosen panel and reasoning to the user before authoring.

### Step 2: Research

The plan is only as good as the codebase knowledge behind it:

1. Read the project's convention docs (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`) - plans that ignore local conventions get rejected in review.
2. Find prior art: existing code that does something similar. Cite the file paths in the plan so the implementer follows patterns instead of inventing them.
3. List the files the change touches and why.
4. Discover the repo's real validation commands (Makefile targets, package scripts) - the plan's Validation Commands section must name commands that exist.
5. **Fix tickets only:** reproduce the symptom - or, for production-only bugs, gather the observability evidence (logs, traces, error reports) - and build the evidence chain before designing anything (see debug-code). A fix designed before the cause is established is a guess.

### Step 3: Clarify

Before writing, surface to the user: ambiguous requirements, competing architectural approaches, potential breaking changes (API contracts, schemas), and UX decisions. Resolving these now is cheaper than a critic round bouncing the plan back - and far cheaper than an implementation built on the wrong assumption.

### Step 4: Author

Write the plan from the matching template to `.planning/<TICKET-KEY>/plan.md`, unless the project already has a plan location convention (`specs/`, `docs/plans/`) - then follow it.

Authoring rules the critics will enforce:

- Every step names exact file paths (relative to repo root) and exact commands.
- No code in the plan body - another agent writes the code, and code written now goes stale and anchors the implementer. Carry design decisions and prior-art file paths instead. Exception: a schema or data shape that *is* the design contract.
- Alternatives considered must include the smallest change that could correctly solve the problem - first designs skew toward adding surface, and the minimal option keeps that visible.
- The MR stack is designed here, deliberately - left to implementation time, the split degenerates into one oversized MR. Seam order: preparatory refactor (no behaviour change) → core change with its tests → trailing incidental fixes. Each MR merges cleanly and leaves the codebase working without the later ones. If no seam exists, one MR with the reason stated.
- Keep each MR's reviewer-facing size within the user's MR-size guidelines (default: ~300 production lines; tests, renames, lockfiles, and generated files excluded).

### Step 5: Review

Run the panel from Step 1 per references/orchestration.md, with critic briefs from references/critic-scopes.md. If the panel is "no critics", skip to Step 7.

### Step 6: Gate

| Severity | Action |
|----------|--------|
| High | Revise the plan, bump `revision` and `updated_at`, re-run the **full** panel - revisions can introduce new issues the other critics would catch |
| Medium | Apply if the improvement is clear; otherwise record it under Open Questions with the reason |
| Low | Optional; apply or ignore |

If critic feedback conflicts, ask the user rather than averaging the advice. If High findings persist after 3 re-review rounds, stop and escalate to the user with the surviving findings - persistent Highs usually mean a structural problem needing human judgement, not another rewrite.

### Step 7: Handoff

Report to the user:

- Path to `plan.md`
- The MR stack (number of MRs and one line each)
- Panel used and rounds run; any deferred Medium findings
- Open questions needing their decision

This is the user's review checkpoint. Implementation starts only after they respond, and each implementation run should target one MR from the stack, reading `plan.md` as its input.

## Related Skills

| Skill | Boundary |
|-------|----------|
| write-tickets | Authoring the ticket itself. plan-ticket consumes a ticket; it does not write one. |
| use-linear / use-jira / use-gh | Fetching ticket details and updating ticket status. |
| debug-code | For fix tickets, the evidence-gathering discipline behind the Evidence Chain section. |
| test-driven-development | The implementation process the plan's per-task test requirements feed into. |

## References

| Reference | Purpose |
|-----------|---------|
| references/critic-scopes.md | Severity definitions and the three critic briefs with scope exclusions. |
| references/orchestration.md | How to run the panel: generic pattern, Claude Code Workflow script, subagent fallback. |

## Templates

| Template | Purpose |
|----------|---------|
| templates/feature.md | Feature plan: problem, solution with alternatives, MR stack, tasks. |
| templates/fix.md | Fix plan: reproduction, evidence chain, root cause, regression test. |
| templates/chore.md | Chore plan: motivation, scope boundaries, tasks. |
