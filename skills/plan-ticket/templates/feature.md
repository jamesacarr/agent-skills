# Feature Plan Template

> Copy and fill. Timestamps in UTC via `date -u +"%Y-%m-%dT%H:%M:%SZ"`. Delete guidance in angle brackets.

```md
---
created_at: <UTC timestamp>
updated_at: <UTC timestamp - update on every revision>
ticket: <KEY-123>
type: feature
revision: 1
panel: <critics run, e.g. pragmatist, strategist - or "none" plus why>
---

# <KEY-123>: <title>

## Problem

<The specific problem or opportunity, in terms of user or business impact - not the solution restated.>

## Solution

<The chosen approach and why.>

### Alternatives Considered

<At least one meaningfully different option AND the smallest change that could correctly solve the problem. One line each on why it was rejected.>

## Relevant Files

<Each file the change touches, with why. New files under a **New files** subheading. Cite prior-art paths for patterns the implementer should follow.>

## MR Stack

| # | Branch | Contents | Depends on |
|---|--------|----------|------------|

<Seam order: preparatory refactor (no behaviour change) → core + tests → trailing fixes. Each MR merges cleanly and leaves the codebase working without the later ones. Single MR: one row, and state why no seam exists.>

## Tasks

### 1. <task name> (MR 1)

- <action with exact relative path or command>

**Tests:** <tests to write or run that prove this task>

## Acceptance Criteria

- [ ] <independently verifiable criterion - "works correctly" is not one>

## Validation Commands

<Commands that exist in this repo - Makefile targets, package scripts.>

## Open Questions

<Unresolved ambiguities and deferred Medium findings, each with why it was deferred. Delete the section if empty.>
```
