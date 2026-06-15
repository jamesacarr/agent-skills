---
name: write-tickets
description: Writes consistently structured, ready-for-development tickets - Stories, Bugs, and Spikes - with clear descriptions, testable acceptance criteria, and pre-identified solution options. Use when creating, drafting, writing up, or auditing a ticket, issue, card, story, bug, or spike for any tracker (Jira, Linear, GitHub Issues, Trello, Asana, etc.), even when the user just says "write a ticket for X" or "file a bug". Produces ticket content and field values. Do NOT use for submitting to a tracker or other CLI operations (use use-jira / use-gh / use-glab or the tracker's own tool).
---

# write-tickets

## Essential Principles

- **Consistent structure.** Predictable tickets are faster to read, estimate, and pick up - so every ticket follows the template for its type: same sections, same order, every time.
- **Complete before quick.** Tickets filed fast with sections missing bounce back with questions, so fill every relevant section - fill what you can from context, ask for the rest, and never silently drop one.
- **Clear, testable acceptance criteria.** Each criterion is independently verifiable. "Works correctly" is not a criterion.
- **Pre-identify solutions where the path isn't obvious.** Offer 1-3 real options with different tradeoffs so reviewers can decide direction before work starts. Skip the section when there's only one sensible approach - don't pad with "fix the bug".
- **Tracker-agnostic content.** Produce the ticket body plus generic field values (Title, Type, Parent/Project, Labels). Submission belongs to the tracker's own tool - see Related Skills.

## Intake

What would you like to do?

1. **Write a Story** - new feature or capability
2. **Write a Bug** - a defect with reproduction steps
3. **Write a Spike** - a timeboxed investigation with a documented output
4. **Audit a ticket** - check an existing ticket against the readiness checklist and improve it

Wait for the response before proceeding. If the user already named a type or pasted a ticket, skip the menu and route directly.

## Routing

| Response | Workflow |
|----------|----------|
| 1, 2, 3, "story", "bug", "spike", "write", "create", "draft" | workflows/create-ticket.md |
| 4, "audit", "review", "check", "improve" | workflows/audit-ticket.md |

After reading the workflow, follow it exactly - each step gates the next, so skipping ahead risks presenting a ticket before it's been checked for readiness.

## Field Mapping

Tickets carry the same content across trackers under different field names. Map generically:

| Generic field | Jira | Linear | GitHub Issues | Trello |
|---------------|------|--------|---------------|--------|
| Title | Summary | Title | Title | Card name |
| Type | Issue type | Label | Label | Label / list |
| Parent | Epic | Project / parent | Milestone | Board / list |
| Labels | Labels | Labels | Labels | Labels |
| Description | Description | Description | Body | Description |

Templates are written in Markdown. Most trackers accept Markdown; Jira needs its own markup or ADF - convert on submission.

## Related Skills

This skill writes content; these skills move it into the tracker.

| Skill | Boundary |
|-------|----------|
| use-jira | Submitting or editing the drafted ticket in Jira. |
| use-gh | Submitting issues to GitHub. |
| use-glab | GitLab issue and MR operations. |

## References

| Reference | Purpose |
|-----------|---------|
| writing-guide.md | Section-by-section guidance: how to write each part well, acceptance-criteria format, solution options, gathering codebase context. |
| readiness-checklist.md | INVEST and per-type readiness criteria, plus the audit output format. |

## Templates

| Template | Purpose |
|----------|---------|
| templates/story.md | Story skeleton - copy and fill placeholders. |
| templates/bug.md | Bug skeleton with reproduction steps. |
| templates/spike.md | Spike skeleton with scope, timebox, and output. |
