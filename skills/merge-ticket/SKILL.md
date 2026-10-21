---
name: merge-ticket
description: Merges a ticket's open MR/PR(s) once CI is green and every review comment is addressed, then cleans up the worktree and moves the ticket to its done status - in the current session or, given a ticket_id, in that ticket's Herdr agent. Use when asked to merge, land, or finish off a ticket or its MRs/PRs (e.g. "land the MRs for ABC-123"). Do NOT use to implement a ticket (use implement-ticket) or to create MRs/PRs (use use-glab or use-gh).
---

# merge-ticket

## Essential Principles

- Both modes run this same skill. Local mode executes the workflow in this session; remote mode hands the ticket's agent a prompt naming this skill, and that session recognises itself as the ticket's agent and self-selects local mode - so the guardrails reach whichever session executes.
- The executing session needs context this skill doesn't carry: which MR(s), which worktree, which ticket. A ticket's implement-ticket agent has all three, which is why remote mode targets it by name and never spawns a replacement. In local mode, discover them from the current branch and conversation, and ask rather than guess when ambiguous.
- Merging is irreversible and the workflow ends by closing the ticket, so "all issues fixed or answered" is a hard gate. Never merge past an unaddressed review comment. Every push (fixes or a rebase) stales all earlier reads of CI and comments - "return to step 1" means re-reading both, not resuming from memory.

## Parameters

| Param | Required | Notes |
|-------|----------|-------|
| `ticket_id` | no | Ticket ID; presence selects remote mode, subject to the agent's state |

## Process

### Step 1: Dispatch

Run by its absolute path under this skill's directory:

```bash
<skill-dir>/scripts/dispatch.sh [ticket_id]
```

It decides the mode and, for remote, sends the prompt itself. With a ticket it looks the agent up in Herdr and checks its state: prompting a `working` agent isn't rejected - the text queues and fires the merge when the current turn ends, likely before the MRs exist - so readiness is part of the decision, not a judgement left to you. Run from a repo, it also checks the agent works in that repo: Herdr names are unique per server, so the same ID in another repo (GitHub issue #42 in two repos) maps to the same agent name, and prompting it would merge the wrong ticket. It prints JSON with `ticket`, `handle`, `mode`, `reason`, `agent`, and `prompt_sent`.

| Exit | `mode` | Do |
|------|--------|----|
| 0 | `local` | Local mode |
| 0 | `remote` | Prompt sent (`prompt_sent` true) - Remote mode |
| 1 | `stop` | Relay `reason` - it names the action to offer - and, when present, `agent` (name, pane, status). Stop |
| 2 | - | Usage error (bad option, more than one ticket, `jq` missing); nothing was sent. Fix the invocation, or tell the user if it's the environment |
| 3 | `remote` | Nothing was sent: the agent became blocked before the prompt landed. Read its pane and tell the user the merge hasn't started and what the dialog is asking; don't re-run |
| 4 | `remote` | Nothing was sent: the prompt failed. Read its pane and tell the user the merge hasn't started, with the error; don't re-run |

### Local mode

Load the forge skill for CI status, comments, and merging (use-glab for GitLab, use-gh for GitHub - "MR" below means either forge's merge/pull request), and the tracker's skill (e.g. use-jira, use-gh) for the done transition. Poll CI rather than sleeping a fixed interval - durations vary by minutes.

If there are no open MRs, the reason decides the action: already merged means the loop is done - skip to cleanup; never created means the implementation isn't finished - stop and ask.

For each open MR, in stack order (earliest first):

1. Wait for CI to finish
2. If red, fix the issues, push, and return to step 1
3. If green, read all comments on the MR as of the latest push. If the project posts automated reviews, they re-run on each push and may edit their earlier comment in place - wait for the current one to land rather than merging past it
4. Fix, or comment your reasoning for not fixing, each issue that was raised
5. If fixes were made, push and return to step 1
6. When all raised issues are fixed or answered, merge the MR and retarget the next MR in the stack. A merge rejected for conflicts means the branch went stale - rebase, push, and return to step 1

Once all MR(s) have been merged: clean up the worktree, then move the ticket to its done status as the tracker's skill defines it. Where the tracker closes tickets from merge keywords, that's a check rather than a transition: keywords may not fire for an MR that targeted another branch in the stack, so if the ticket is still open, close it with a comment naming the merged MRs. Never close it while any MR in the stack is unmerged.

Stop and ask the user if anything needs clarification.

### Remote mode

Only after exit 0 with `prompt_sent` true - exits 3 and 4 also say `remote` but nothing reached the agent. Report the handle and that the agent will merge, clean up, and move the ticket to its done status.

## Success Criteria

- Local: MR(s) merged with CI green and every review comment fixed or answered, worktree removed, ticket in its done status.
- Remote: the prompt reached the correct, ready agent without blocking this session, and no new agents or tabs were created.
- Ambiguity - unknown MR(s) locally, missing or busy agent remotely - stopped the skill with a question instead of a guess.
