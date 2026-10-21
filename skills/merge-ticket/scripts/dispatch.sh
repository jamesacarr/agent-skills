#!/usr/bin/env bash
# Decide where merge-ticket runs and, for remote, send the prompt. Without a
# ticket it's this session. With one, it's the ticket's live implement agent -
# the only session that knows the MRs, worktree, and ticket - and only when that
# agent is ready to take a prompt.
#
# Usage:
#   dispatch.sh [TICKET_ID]
#
# Prints one JSON object on stdout:
#   ticket       - the ID, uppercased, or null
#   handle       - the agent handle derived from the ticket, or null
#   mode         - "local" | "remote" | "stop"
#   reason       - why, when mode is "stop" or the prompt failed
#   agent        - the ticket's live agent {name, pane_id, tab_id, agent_status, cwd}, or null
#   prompt_sent  - true only when the remote agent received the merge prompt
#
# Exit codes:
#   0  local - run the workflow here; or remote - the prompt was sent, report it
#   1  stop - relay the reason and agent details, don't proceed
#   2  usage error
#   3  remote agent became blocked before the prompt landed - read its pane, tell the user
#   4  prompt failed for another reason - read its pane

set -eu

ticket=''
for arg in "$@"; do
  case "$arg" in
    -h|--help) sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2;;
    -*) printf 'dispatch: unknown option: %s\n' "$arg" >&2; exit 2;;
    *) [ -z "$ticket" ] || { printf 'dispatch: one ticket id only\n' >&2; exit 2; }; ticket="$arg";;
  esac
done
command -v jq >/dev/null || { printf 'dispatch: jq not found\n' >&2; exit 2; }

TICKET=$(printf '%s' "$ticket" | tr '[:lower:]' '[:upper:]')
handle='' agent_json='null'

emit() { # mode reason [prompt_sent]
  jq -n --arg ticket "$TICKET" --arg handle "$handle" --arg mode "$1" --arg reason "$2" --argjson agent "$agent_json" \
    --argjson sent "${3:-false}" \
    '{ticket: (if $ticket == "" then null else $ticket end), handle: (if $handle == "" then null else $handle end),
      mode: $mode, reason: (if $reason == "" then null else $reason end), agent: $agent, prompt_sent: $sent}'
}
stop() { emit stop "$1"; exit 1; }

# Git common dir of a path: shared by a repo's checkout and all its worktrees.
repo_of() { (cd "$1" 2>/dev/null && git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || true; }

[ -n "$TICKET" ] || { emit local ''; exit 0; }
[ "${HERDR_ENV:-}" = 1 ] || stop "outside Herdr - nothing can reach another session; run without a ticket id from the ticket's repo instead"

# Same slugify as spawn-agent, so the handle matches what implement-ticket created.
handle=$(printf '%s' "$TICKET" | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/^([^a-z])/a-\1/' | cut -c1-32 | sed -E 's/-+$//')

if ! out=$(herdr agent get "$handle" 2>&1); then
  case "$out" in
    *agent_not_found*) stop "no live agent for $TICKET - its implement agent has exited; offer to run local mode from the ticket's repo rather than spawning a fresh agent that knows nothing about the MRs";;
    *) printf 'dispatch: herdr agent get failed: %s\n' "$out" >&2; stop "could not query Herdr agents";;
  esac
fi
agent_json=$(printf '%s' "$out" | jq -c '.result.agent | {name, pane_id, tab_id, agent_status, cwd}')
pane=$(printf '%s' "$agent_json" | jq -r '.pane_id')
state=$(printf '%s' "$agent_json" | jq -r '.agent_status // "unknown"')

[ "$pane" != "${HERDR_PANE_ID:-}" ] || { emit local ''; exit 0; }   # don't prompt yourself

# Herdr names are unique per server, not per workspace, so the same ID in another
# repo (GitHub issue #42 in two repos) lands on the same handle - and prompting
# that agent would merge the wrong ticket's MRs. Run from a repo, the agent must
# work in it; an agent whose repo can't be read doesn't count as proof.
here=$(repo_of "$PWD")
if [ -n "$here" ]; then
  agent_cwd=$(printf '%s' "$agent_json" | jq -r '.cwd // empty')
  there=$(repo_of "${agent_cwd:-/nonexistent}")
  [ -n "$there" ] || stop "can't tell which repo the agent named $handle works in (cwd ${agent_cwd:-unknown}) - read its pane and ask the user before sending a merge"
  [ "$there" = "$here" ] || stop "the agent named $handle works in another repo ($agent_cwd) - the same ID there, not this ticket; nothing was sent. Run local mode from this ticket's worktree instead"
fi

# A prompt to a working agent isn't rejected - it queues and fires the merge the
# moment the current turn ends, likely before the MRs exist.
case "$state" in
  idle|done) ;;
  working)   stop "the $TICKET agent is working - a prompt would queue and start the merge when its turn ends, likely before the MRs exist; re-run once it's idle, or run local mode from its tab";;
  blocked)   stop "the $TICKET agent is blocked at an approval or question dialog - read its pane and tell the user; don't send anything";;
  *)         stop "the $TICKET agent's state is '$state', which doesn't prove it's ready; read its pane and ask the user";;
esac

# Prose rather than a slash command: the agent's harness may differ from ours and
# each has its own invocation syntax. No --wait: CI and review loops run long and
# it would block the caller until the ticket is done.
prompt="Merge the open MR(s) for $TICKET using the merge-ticket skill."
if ! out=$(herdr agent prompt "$handle" "$prompt" 2>&1); then
  code=4; case "$out" in *agent_blocked*) code=3;; esac
  printf 'dispatch: prompt not delivered:\n%s\n--- pane %s ---\n' "$out" "$pane" >&2
  herdr pane read "$pane" --source recent-unwrapped --lines 40 2>&1 | sed 's/^/  | /' >&2
  emit remote "prompt not delivered: $(printf '%s' "$out" | jq -r '.error.code // .' 2>/dev/null || printf '%s' "$out")" false
  exit "$code"
fi
emit remote '' true
