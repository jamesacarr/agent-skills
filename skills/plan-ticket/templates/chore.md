# Chore Plan Template

> Copy and fill. Timestamps in UTC via `date -u +"%Y-%m-%dT%H:%M:%SZ"`. Delete guidance in angle brackets. Chores drift - the Scope section is the fence.

```md
---
created_at: <UTC timestamp>
updated_at: <UTC timestamp - update on every revision>
ticket: <KEY-123>
type: chore
revision: 1
panel: <critics run, e.g. pragmatist - or "none" plus why>
---

# <KEY-123>: <title>

## Motivation

<Why this is worth doing now - what it unblocks, removes, or de-risks.>

## Scope

**In:** <what changes>

**Out:** <adjacent work explicitly not done, so the implementer doesn't expand the chore>

## Approach

<How, briefly, with prior-art paths where a pattern already exists.>

## Relevant Files

<Each file the change touches, with why.>

## MR Stack

| # | Branch | Contents | Depends on |
|---|--------|----------|------------|

<Usually one MR. Mechanical bulk (renames, moves) and behaviour-adjacent edits belong in separate MRs so reviewers can skim the former and scrutinise the latter.>

## Tasks

### 1. <task name> (MR 1)

- <action with exact relative path or command>

**Tests:** <tests to run proving no behaviour change, or the new coverage this chore adds>

## Validation Commands

<Commands that exist in this repo.>

## Open Questions

<Unresolved ambiguities and deferred Medium findings. Delete the section if empty.>
```
