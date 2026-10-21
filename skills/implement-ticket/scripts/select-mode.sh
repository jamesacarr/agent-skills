#!/usr/bin/env bash
# Decide where implement-ticket runs, from the environment and the Herdr agent
# list only. Ticket size or content is never an input, and there is no flag:
# outside Herdr the only place the work can run is this session, and inside it
# the only session that should run locally is the ticket's own agent.
#
# Usage:
#   select-mode.sh TICKET_ID
#
# Prints one JSON object on stdout:
#   ticket  - the ID, uppercased
#   name    - the agent name to spawn: the ticket ID, or <repo>-<number> for a
#             bare issue number (Herdr names are unique per server, not per repo)
#   repo    - git top-level of the cwd
#   herdr   - true when this session runs inside Herdr (HERDR_ENV=1)
#   mode    - "local" | "spawn" | "stop"
#   reason  - why, when mode is "stop"
#   agent   - the ticket's live agent {name, pane_id, tab_id, agent_status, cwd}, or null
#
# Exit codes:
#   0  mode is local or spawn
#   1  mode is stop - relay the reason and agent details, don't proceed
#   2  usage error

set -eu

ticket=''
for arg in "$@"; do
  case "$arg" in
    -h|--help) sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2;;
    -*) printf 'select-mode: unknown option: %s\n' "$arg" >&2; exit 2;;
    *) [ -z "$ticket" ] || { printf 'select-mode: one ticket id only\n' >&2; exit 2; }; ticket="$arg";;
  esac
done
[ -n "$ticket" ] || { printf 'select-mode: TICKET_ID is required\n' >&2; exit 2; }
command -v jq >/dev/null || { printf 'select-mode: jq not found\n' >&2; exit 2; }

TICKET=$(printf '%s' "$ticket" | tr '[:lower:]' '[:upper:]')
herdr=false; [ "${HERDR_ENV:-}" != 1 ] || herdr=true
agent_json='null' name=''

# Agent handle for a ticket ID. Herdr names are unique per server and must match
# [a-z][a-z0-9_-]{0,31}. A bare issue number (42, #42) is only unique within its
# repo, so it gets the repo's name as a prefix (owner/repo#42 carries its own),
# truncated so the number survives - cutting it would give two tickets one handle.
# Other IDs (ABC-123) get spawn-agent's slugify unchanged. Prints nothing for a
# bare number outside a repo. Keep identical to the copy in merge-ticket/scripts/dispatch.sh.
slug() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'; }
is_issue_number() { case "${1##*#}" in ''|*[!0-9]*) return 1;; esac; }
ticket_handle() {
  local id=$1 num prefix='' common
  if ! is_issue_number "$id"; then
    slug "$id" | sed -E 's/^([^a-z])/a-\1/' | cut -c1-32 | sed -E 's/-+$//'; return
  fi
  num=${id##*#}
  case "$id" in *'#'*) prefix=${id%#*};; esac
  if [ -z "$prefix" ]; then
    common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 0
    case "$(basename "$common")" in
      .git) prefix=$(basename "$(dirname "$common")");;   # checkout or worktree
      *)    prefix=$(basename "$common" .git);;             # bare repo
    esac
  fi
  prefix=$(slug "$prefix"); case "$prefix" in [a-z]*) ;; *) prefix="a-$prefix";; esac
  prefix=$(printf '%s' "$prefix" | cut -c1-$((31 - ${#num})) | sed -E 's/-+$//')
  printf '%s-%s\n' "$prefix" "$num"
}

emit() { # mode reason
  jq -n --arg ticket "$TICKET" --arg name "$name" --arg repo "${repo:-}" --argjson herdr "$herdr" --arg mode "$1" --arg reason "$2" --argjson agent "$agent_json" \
    '{ticket: $ticket, name: (if $name == "" then null else $name end), repo: (if $repo == "" then null else $repo end), herdr: $herdr, mode: $mode,
      reason: (if $reason == "" then null else $reason end), agent: $agent}'
}
stop() { emit stop "$1"; exit 1; }

# Git common dir of a path: shared by a repo's checkout and all its worktrees.
repo_of() { (cd "$1" 2>/dev/null && git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || true; }

# The worktree is created relative to the ticket's repo, so cwd must be inside one.
repo=$(git rev-parse --show-toplevel 2>/dev/null) || stop "not inside a git repo - run from the ticket's repo"

# The handle spawn-agent derives from the name, so self-detection below matches.
handle=$(ticket_handle "$TICKET")
name=$TICKET; ! is_issue_number "$TICKET" || name=$handle

# Outside Herdr nothing can be spawned, so this session is the only place to run.
[ "$herdr" = true ] || { emit local ''; exit 0; }

if out=$(herdr agent get "$handle" 2>&1); then
  agent_json=$(printf '%s' "$out" | jq -c '.result.agent | {name, pane_id, tab_id, agent_status, cwd}')
  pane=$(printf '%s' "$agent_json" | jq -r '.pane_id')
  if [ "$pane" = "${HERDR_PANE_ID:-}" ]; then
    emit local ''; exit 0   # this session is the ticket's agent
  fi
  # Herdr names are unique per server, not per workspace, so the same ID in
  # another repo (GitHub issue #42 in two repos) lands on the same handle.
  # Either way this stops; an unreadable repo falls through to the generic reason.
  agent_cwd=$(printf '%s' "$agent_json" | jq -r '.cwd // empty')
  there=$(repo_of "${agent_cwd:-/nonexistent}")
  if [ -n "$there" ] && [ "$there" != "$(repo_of "$repo")" ]; then
    stop "the live agent named $handle works in another repo (${agent_cwd:-unknown cwd}) - the same ID there, not this ticket; it holds the name, so this ticket can't get its own agent until that one exits"
  fi
  stop "a live agent for $TICKET already exists - the ticket is probably being worked; ask the user whether to prompt it, run the skill from its tab, or restart"
fi
case "$out" in
  *agent_not_found*) emit spawn ''; exit 0;;
  *) printf 'select-mode: herdr agent get failed: %s\n' "$out" >&2; stop "could not query Herdr agents";;
esac
