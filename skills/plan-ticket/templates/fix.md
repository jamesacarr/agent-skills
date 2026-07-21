# Fix Plan Template

> Copy and fill. Timestamps in UTC via `date -u +"%Y-%m-%dT%H:%M:%SZ"`. Delete guidance in angle brackets. The Evidence Chain must be complete before the Fix section is written - a fix designed first is a guess.

```md
---
created_at: <UTC timestamp>
updated_at: <UTC timestamp - update on every revision>
ticket: <KEY-123>
type: fix
revision: 1
panel: <critics run, e.g. pragmatist, detective - or "none" plus why>
---

# <KEY-123>: <title>

## Symptom

<Observed wrong behaviour, and the expected behaviour.>

## Reproduction

<Numbered steps with exact commands, inputs, and the observation at each step. Someone else must be able to run these.>

## Evidence Chain

<Symptom → root cause, one link at a time, each backed by an observation (log line, test output, code path). Name the alternative explanations ruled out and how.>

## Root Cause

<Why the behaviour happens - not a restatement of what happens.>

## Fix

<The change, and why it makes the root cause impossible rather than the symptom unlikely.>

## Regression Test

<The test that would have caught this bug, mirroring the reproduction steps. Where it lives.>

## Relevant Files

<Each file the change touches, with why.>

## MR Stack

| # | Branch | Contents | Depends on |
|---|--------|----------|------------|

<Fixes are usually one MR; add rows only when a preparatory refactor is a real seam.>

## Tasks

### 1. <task name> (MR 1)

- <action with exact relative path or command>

**Tests:** <tests to write or run that prove this task>

## Validation Commands

<Commands that exist in this repo, plus rerunning the Reproduction steps to show correct behaviour - the validation path must be the reproduction path.>

## Open Questions

<Unresolved ambiguities and deferred Medium findings. Delete the section if empty.>
```
