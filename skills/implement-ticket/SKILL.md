---
name: implement-ticket
description: Implements a ticket end to end in the current session, or by spawning a dedicated agent session in a new Herdr tab and triggering the workflow there. Use when asked to implement, start, pick up, or work a ticket (e.g. "spin up an agent to implement ABC-123 on sonnet"). Do NOT use for planning only (use plan-ticket), drafting ticket content (use write-tickets), or merging MRs/PRs (use merge-ticket).
---

# implement-ticket

## Essential Principles

- Both modes run this same skill. Local mode executes the workflow in this session; spawn mode dispatches `/implement-ticket <TICKET>` to the new session, which recognises itself as the ticket's agent and self-selects local mode - so the guardrails reach whichever session executes.
- One agent per ticket. A live agent already named after the ticket almost certainly means the ticket is being worked - re-triggering would re-assign, re-plan, and collide with its worktree, so stop and ask. This rule is also the recursion backstop: if self-detection ever failed, the dispatched session halts here instead of prompting itself.
- The workflow must run from the ticket's repo - the worktree is created relative to it, and a spawned session inherits only cwd.

## Parameters

| Param | Required | Notes |
|-------|----------|-------|
| `ticket_id` | yes | Ticket ID, normalised to uppercase. Becomes the agent name and tab label in spawn mode |
| `model` | no | Spawn mode only; passed to spawn-agent verbatim - never guess a value the user didn't give. Given alongside `--here`, say it can't apply to an already-running session and continue locally |
| `--here` | no | Forces local mode (see Mode selection) |

Arguments are positional - `ticket_id` first, then `model` - with `--here` allowed anywhere: `/implement-ticket ABC-123 sonnet`, `/implement-ticket ABC-123 --here`.

## Process

### Preflight (both modes)

```bash
git rev-parse --show-toplevel
TICKET=$(printf '%s' "$ticket_id" | tr '[:lower:]' '[:upper:]')
```

Then verify the ticket exists with the tracker's CLI, key-only - for Jira: `jira issue list -q "key = $TICKET" --plain --columns key --no-headers`.

Not in a repo → stop and ask which repo to run from. The existence check prints only the key when the ticket exists; empty output or an error means a typo or dead ticket - show it and stop.

The check is deliberately key-only: never view the ticket before mode selection. Reading the description invites a scope judgement ("small enough to do here") that overrides the mode table. The executing session reads the ticket; this session only proves it exists.

### Mode selection

First match wins. The table's only inputs are the flag, the environment, and the agent list - ticket size or perceived complexity is NEVER an input, because the user chose where the work runs by how they invoked the skill:

| Situation | Mode |
|-----------|------|
| `--here` given | Local |
| `HERDR_ENV` is not `1` | Stop - can't spawn or dispatch outside Herdr; suggest `--here` to run in this session |
| This session is the ticket's agent (slugified `$TICKET` in `herdr agent list` with a pane matching `$HERDR_PANE_ID`) | Local |
| A live agent for the ticket exists elsewhere | Stop and ask - report the agent and its `herdr agent get` state; the user decides whether to prompt it, run `--here` from its tab, or restart |
| Otherwise | Spawn and dispatch |

Slugify the way spawn-agent derives handles: lowercase, non-alphanumerics to `-`.

### Local mode

Execute in this session, loading the tracker's skill (e.g. use-jira) for ticket operations and the forge skill (use-glab for GitLab, use-gh for GitHub) for MRs - "MR" below means either forge's merge/pull request:

1. Assign the ticket to the user and move it to In Progress - if it's already assigned to someone else, ask before taking it
2. Create a new worktree for the ticket, including dependency install and any env bootstrapping the project requires. A worktree for the ticket already existing means an earlier run - reuse it if clean, ask if it has uncommitted changes
3. If this is a bug, validate the issue described in the ticket before changing anything
4. Produce an implementation plan using /plan-ticket
5. Execute the reviewed plan: in Claude Code, create an implementation workflow from it and start it; in a harness without workflow orchestration, work through the plan directly in this session
6. When complete, commit, push, and open the MR(s) the plan calls for. Never commit the plan file - it's working state for this workflow, not part of the change, and it would land in the MR diff as reviewer noise
7. If the change is visual, drive the app as a logged-in user and capture screenshots/videos of the changes, attaching them to the MR(s). If a skill covers starting or signing into the app, use it rather than improvising the login
8. Summarise your changes, then stop and wait for the user's review

Stop and ask the user if anything needs clarification.

### Spawn and dispatch

1. Invoke the spawn-agent skill with `name: $TICKET`, `model` if provided, and `focus: no` - the user stays in this session while the ticket runs in the background. It owns tab creation, handle rules, and the busy-pane retry loop - don't reimplement any of it.
2. Dispatch the skill to the new session:

   ```bash
   herdr agent prompt "$handle" "/implement-ticket $TICKET"
   ```

   The new session is the ticket's agent, so it self-selects local mode. No `--wait`: the workflow runs for a long time and `--wait` would block this session until the ticket is done. An `agent_blocked` error means the fresh session stopped at a startup dialog (folder trust, MCP consent) - read its pane and resolve or report rather than retrying.
3. Verify delivery: `herdr agent read "$handle" --source recent-unwrapped --lines 30` should show the skill invocation. If the text landed as plain prose instead, send "Implement ticket $TICKET using the implement-ticket skill".
4. Report the tab label, handle, and model (when one was requested), and that the agent will summarise its changes and stop for review once the MR(s) are open.

## Success Criteria

- Local: ticket assigned and In Progress, worktree created, plan produced and executed, MR(s) open, summary delivered - then stopped for review, nothing merged.
- Spawn: one new background (unfocused) tab labelled with the ticket ID, cwd matching the invoking repo, the skill triggered there without blocking this session - no orphans, no duplicate agent for a ticket already in flight.
- Invalid input (no repo, bad ticket ID, outside Herdr without `--here`) stopped the skill before any tab was created.
