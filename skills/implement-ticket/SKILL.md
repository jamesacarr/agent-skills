---
name: implement-ticket
description: Implements a ticket end to end in the current session, or by spawning a dedicated agent session in a new Herdr tab and triggering the workflow there. Use when asked to implement, start, pick up, or work a ticket (e.g. "spin up an agent to implement ABC-123 on sonnet"). Do NOT use for planning only (use plan-ticket), drafting ticket content (use write-tickets), or merging MRs/PRs (use merge-ticket).
---

# implement-ticket

## Essential Principles

- Both modes run this same skill. Local mode executes the workflow in this session; spawn mode hands the new session a prompt naming this skill, and that session recognises itself as the ticket's agent and self-selects local mode - so the guardrails reach whichever session executes.
- One agent per ticket. A live agent already named after the ticket almost certainly means the ticket is being worked - re-triggering would re-assign, re-plan, and collide with its worktree, so the mode script stops instead. This is also the recursion backstop: if self-detection ever failed, the dispatched session halts here instead of prompting itself.
- The workflow must run from the ticket's repo - the worktree is created relative to it, and a spawned session inherits only cwd.

## Parameters

| Param | Required | Notes |
|-------|----------|-------|
| `ticket_id` | yes | Ticket ID; the script uppercases it. Becomes the agent name and tab label in spawn mode. In the tracker's own form (`ABC-123`, `#42`) - Step 2 works out which tracker |
| `model` | no | Spawn mode only; passed to spawn-agent verbatim - never guess a value the user didn't give. When the mode comes back `local`, say it can't apply to an already-running session and continue locally |

Arguments are positional - `ticket_id` first, then `model`: `/implement-ticket ABC-123 sonnet`. There is no flag for choosing the mode; the script decides it from where it runs.

## Process

### Step 1: Select the Mode

Run by its absolute path under this skill's directory, from the ticket's repo:

```bash
<skill-dir>/scripts/select-mode.sh "$ticket_id"
```

Its only inputs are the environment and Herdr's agent list - ticket size or content is never one, and it takes no options. Outside Herdr nothing can be spawned, so this session is the only place the work can run and the mode is always `local`. Inside Herdr the mode is `spawn` unless this session is already the ticket's agent. It prints JSON with `ticket` (uppercased - `$TICKET` below), `repo`, `herdr`, `mode`, `reason`, and `agent`.

| Exit | `mode` | Do |
|------|--------|----|
| 0 | `local` | Continue to Step 2, then Local mode. If `herdr` is false and the user asked to spin up an agent or gave a `model`, tell them spawning isn't possible outside Herdr and the work runs here instead |
| 0 | `spawn` | Continue to Step 2, then Spawn mode |
| 1 | `stop` | Relay `reason` and, when present, `agent` (name, pane, status) - the user decides whether to prompt that agent, run the skill from its tab, or restart. Don't proceed |
| 2 | - | Usage error (any option, more than one ticket, `jq` missing); nothing was created. Fix the invocation, or tell the user if it's the environment |

### Step 2: Identify the Tracker and Verify the Ticket

The ID alone doesn't name the tracker - `ABC-123` fits Jira, Linear, and YouTrack, and `#42` fits both GitHub and GitLab issues. Resolve it from, in order: the project's instructions (CLAUDE.md, AGENTS.md), the repo's forge from its origin remote (a bare number on a GitLab remote is a GitLab issue), the tracker skills and CLIs available, then the ID's shape. If they still leave more than one candidate, ask.

Then verify key-only with the tracker's CLI, for example:

- Jira: `jira issue list -q "key = $TICKET" --plain --columns key --no-headers` - prints only the key when the ticket exists
- GitHub: `gh issue view <NUMBER> --json number,state`

Empty output or an error means a typo, wrong tracker, or dead ticket - show it and stop. A ticket already closed or done means there's nothing to implement - say so and stop.

Key-only because in spawn mode this session isn't the one doing the work: the executing session reads the ticket, this one only proves it exists.

### Local mode

Execute in this session, loading the tracker's skill (e.g. use-jira, use-gh) for ticket operations and the forge skill (use-glab for GitLab, use-gh for GitHub) for MRs - "MR" below means either forge's merge/pull request. Starting, linking, and finishing a ticket mean different things per tracker - some have no In Progress status - so follow the tracker's skill where it defines them.

1. Start the ticket: assign it to the user and, where the tracker has one, move it to In Progress - if it's already assigned to someone else, ask before taking it
2. Create a new worktree for the ticket, including dependency install and any env bootstrapping the project requires. A worktree for the ticket already existing means an earlier run - reuse it if clean, ask if it has uncommitted changes
3. If this is a bug (by the tracker's issue type or labels), validate the issue described in the ticket before changing anything
4. Produce an implementation plan using /plan-ticket
5. Execute the reviewed plan: in Claude Code, create an implementation workflow from it and start it; in a harness without workflow orchestration, work through the plan directly in this session
6. When complete, commit, push, and open the MR(s) the plan calls for, each linked to the ticket as the tracker's skill describes. Where the tracker closes tickets from merge keywords (GitHub, GitLab, Linear), only the MR that completes the ticket uses a closing reference - earlier ones in a stack reference it without closing, or merging the first would close the ticket early. Never commit the plan file - it's working state for this workflow, not part of the change, and it would land in the MR diff as reviewer noise
7. If the change is visual, drive the app as a logged-in user and capture screenshots/videos of the changes, attaching them to the MR(s). If a skill covers starting or signing into the app, use it rather than improvising the login
8. Summarise your changes, then stop and wait for the user's review

Stop and ask the user if anything needs clarification.

### Spawn mode

Invoke the spawn-agent skill with `name: $TICKET`, `model` if provided, and this `task`:

```text
Implement $TRACKER ticket $TICKET using the implement-ticket skill.
```

`$TRACKER` is the tracker from Step 2 (e.g. `Jira`, `GitHub`). The new session has the same repo but not this session's reasoning, so naming the tracker saves it re-resolving - or misresolving - a bare ID.

Prose, not a slash command: the new session's harness may differ from this one and each has its own invocation syntax, so the sentence names the skill and lets the description trigger fire. The new session is the ticket's agent, so its own Step 1 selects local mode. spawn-agent leaves the tab unfocused when a task is set, and its exit codes cover startup dialogs and failed prompts - act on them as that skill says.

Report the tab label, handle, and model (when one was requested), and that the agent will summarise its changes and stop for review once the MR(s) are open.

## Success Criteria

- Local: ticket started (assigned, and In Progress where the tracker has it), worktree created, plan produced and executed, MR(s) open, summary delivered - then stopped for review, nothing merged.
- Spawn: one new background (unfocused) tab labelled with the ticket ID, cwd matching the invoking repo, the task delivered there without blocking this session - no orphans, no duplicate agent for a ticket already in flight.
- Invalid input (no repo, bad ticket ID) stopped the skill before any tab was created.
