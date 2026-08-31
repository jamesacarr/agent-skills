---
name: merge-ticket
description: Merges a ticket's open MR/PR(s) once CI is green and every review comment is addressed, then cleans up the worktree and moves the ticket to its done status - in the current session or, given a ticket_id, in that ticket's Herdr agent. Use when asked to merge, land, or finish off a ticket or its MRs/PRs (e.g. "land the MRs for ABC-123"). Do NOT use to implement a ticket (use implement-ticket) or to create MRs/PRs (use use-glab or use-gh).
---

# merge-ticket

## Essential Principles

- Both modes run this same skill. Local mode executes the workflow in this session; remote mode sends `/merge-ticket` to the ticket's agent, which invokes the skill there in local mode - so the guardrails reach whichever session executes.
- The executing session needs context this skill doesn't carry: which MR(s), which worktree, which ticket. A ticket's implement-ticket agent has all three, which is why remote mode targets it by name. In local mode, discover them from the current branch and conversation, and ask rather than guess when ambiguous.
- Merging is irreversible and the workflow ends by closing the ticket, so "all issues fixed or answered" is a hard gate. Never merge past an unaddressed review comment.

## Parameters

| Param | Required | Notes |
|-------|----------|-------|
| `ticket_id` | no | Ticket ID; presence selects the mode (see Mode selection) |

## Process

### Mode selection

| Situation | Mode |
|-----------|------|
| No `ticket_id` | Local |
| `ticket_id` given, but the target agent's pane is this session's own `$HERDR_PANE_ID` | Local - don't prompt yourself |
| `ticket_id` given otherwise | Remote |

### Local mode

Load the forge skill for CI status, comments, and merging (use-glab for GitLab, use-gh for GitHub - "MR" below means either forge's merge/pull request), and the tracker's skill (e.g. use-jira) for the done transition. Poll CI rather than sleeping a fixed interval - durations vary by minutes.

If there are no open MRs, the reason decides the action: already merged means the loop is done - skip to cleanup; never created means the implementation isn't finished - stop and ask.

For each open MR, in stack order (earliest first):

1. Wait for CI to finish
2. If red, fix the issues, push, and return to step 1
3. If green, read all comments on the MR. If the project posts automated reviews, wait for that review to land rather than merging past one that arrives moments later
4. Fix, or comment your reasoning for not fixing, each issue that was raised
5. If fixes were made, push and return to step 1
6. When all raised issues are fixed or answered, merge the MR and retarget the next MR in the stack. A merge rejected for conflicts means the branch went stale - rebase, push, and return to step 1

Once all MR(s) have been merged: clean up the worktree, then move the ticket to its done status.

Stop and ask the user if anything needs clarification.

### Remote mode

1. Preflight: `test "${HERDR_ENV:-}" = 1`. Outside Herdr, stop - nothing can reach another session.
2. Slugify the ticket ID the way spawn-agent derives handles (lowercase, non-alphanumerics to `-`) and check `herdr agent list` for it. No live agent with that name means the implement agent has exited: stop, report it, and offer to run local mode from the ticket's repo instead - don't spawn a fresh agent that knows nothing about the MRs.
3. Check readiness: `herdr agent get "$handle"`. `working` is not rejected by `agent prompt` - the text queues and would fire the merge workflow the moment the current turn ends, likely before the MRs exist - so report the state and ask the user before sending. `blocked` means it's stopped at an approval or question dialog - read its pane and tell the user instead of sending anything.
4. Trigger the skill:

   ```bash
   herdr agent prompt "$handle" "/merge-ticket"
   ```

   The remote session receives no ticket_id, so it selects local mode - no recursion. No `--wait`: CI and review loops run long, and `--wait` would block this session until the ticket is done.
5. Verify delivery: `herdr agent read "$handle" --source recent-unwrapped --lines 30` should show the skill invocation. If the text landed as plain prose instead, send "Merge the open MR(s) using the merge-ticket skill".
6. Report the handle and that the agent will merge, clean up, and move the ticket to its done status.

## Success Criteria

- Local: MR(s) merged with CI green and every review comment fixed or answered, worktree removed, ticket in its done status.
- Remote: the skill was triggered in the correct, ready agent without blocking this session, and no new agents or tabs were created.
- Ambiguity - unknown MR(s) locally, missing or busy agent remotely - stopped the skill with a question instead of a guess.
