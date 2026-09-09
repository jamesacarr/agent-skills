#!/usr/bin/env bash
# Start a named agent session in a new Herdr tab and optionally send it one prompt.
#
# Usage:
#   spawn-agent.sh --name TEXT --kind KIND [--model MODEL] [--task TEXT]
#                  [--focus|--no-focus] [--timeout MS] [-- <extra agent args>]
#
# Focus defaults to --no-focus when --task is given (the caller delegated and stays
# put) and --focus otherwise (the empty session is waiting for the user).
#
# Prints one JSON object on stdout describing the session. Diagnostics go to stderr.
#
# Exit codes:
#   0  session started (and task sent, if given)
#   1  Herdr failure - the tab is closed if the agent never started
#   2  usage or preflight failure - nothing was created
#   3  agent is up but stopped at a startup dialog (folder trust, MCP consent);
#      the task, if given, was NOT sent - inspect the pane and resolve it
#   4  agent is up but the task prompt failed - inspect the pane

set -eu

name='' kind='' model='' task='' focus='' timeout=120000
extra=()

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
die()   { printf 'spawn-agent: %s\n' "$1" >&2; exit "${2:-1}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --name)     name="${2:?}"; shift 2;;
    --kind)     kind="${2:?}"; shift 2;;
    --model)    model="${2:?}"; shift 2;;
    --task)     task="${2:?}"; shift 2;;
    --timeout)  timeout="${2:?}"; shift 2;;
    --focus)    focus='yes'; shift;;
    --no-focus) focus='no'; shift;;
    --)         shift; extra=("$@"); break;;
    -h|--help)  usage;;
    *)          die "unknown option: $1" 2;;
  esac
done

# --- preflight -----------------------------------------------------------------
[ -n "$name" ] || die "--name is required" 2
[ -n "$kind" ] || die "--kind is required" 2
[ "${HERDR_ENV:-}" = 1 ] || die "not running inside Herdr (HERDR_ENV != 1)" 2
[ -n "${HERDR_WORKSPACE_ID:-}" ] || die "HERDR_WORKSPACE_ID is unset" 2
command -v herdr >/dev/null || die "herdr CLI not found" 2
command -v jq >/dev/null || die "jq not found" 2
[ -n "$focus" ] || { [ -n "$task" ] && focus='no' || focus='yes'; }

# Per-kind flags. An unknown flag makes the agent exit at once, which Herdr
# reports as a confusing timeout, so only pass flags known for the kind.
args=()
case "$kind" in
  claude|pi) args+=(--name "$name"); [ -n "$model" ] && args+=(--model "$model");;
  codex)     [ -n "$model" ] && args+=(--model "$model");;
  *)         [ -z "$model" ] || die "no known model flag for kind '$kind'; check '$kind --help' and pass it after --" 2;;
esac
args+=("${extra[@]+"${extra[@]}"}")

# --- handle --------------------------------------------------------------------
# Herdr handles must match [a-z][a-z0-9_-]{0,31} and be unique among live agents.
base=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/^([^a-z])/a-\1/' | cut -c1-32 | sed -E 's/-+$//')
live=$(herdr agent list | jq -r '.result.agents[]?.name // empty')
handle="$base"; n=1
while printf '%s\n' "$live" | grep -qx -- "$handle"; do
  n=$((n + 1)); suffix="-$n"
  handle="$(printf '%s' "$base" | cut -c1-$((32 - ${#suffix})) | sed -E 's/-+$//')$suffix"
done

# --- tab -----------------------------------------------------------------------
focus_flag='--no-focus'; [ "$focus" = yes ] && focus_flag='--focus'
tab_json=$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label "$name" "$focus_flag" 2>&1) \
  || die "herdr tab create failed: $tab_json"
tab_id=$(printf '%s' "$tab_json" | jq -r '.result.tab.tab_id // empty')
pane_id=$(printf '%s' "$tab_json" | jq -r '.result.root_pane.pane_id // empty')
[ -n "$tab_id" ] && [ -n "$pane_id" ] || die "herdr tab create returned no tab/pane id: $tab_json"

# --- agent ---------------------------------------------------------------------
# A brand-new pane reports agent_pane_busy while its shell finishes rc files.
# Nothing was launched in that case, so retrying is safe.
out=''
for _ in 1 2 3 4 5 6 7 8 9 10; do
  if out=$(herdr agent start "$handle" --kind "$kind" --pane "$pane_id" --timeout "$timeout" -- "${args[@]+"${args[@]}"}" 2>&1); then
    status='ready'; break
  fi
  case "$out" in
    *agent_pane_busy*) status='busy'; sleep 1;;
    *agent_not_ready*) status='blocked'; break;;
    *)                 status='failed'; break;;
  esac
done

emit() {
  jq -n --arg handle "$handle" --arg tab_id "$tab_id" --arg pane_id "$pane_id" --arg label "$name" \
        --arg kind "$kind" --arg model "$model" --arg status "$1" --argjson task_sent "$2" \
        '{handle: $handle, tab_id: $tab_id, pane_id: $pane_id, label: $label, kind: $kind,
          model: (if $model == "" then null else $model end), status: $status, task_sent: $task_sent}'
}

pane_dump() { herdr pane read "$pane_id" --source recent-unwrapped --lines 40 2>&1 | sed 's/^/  | /' >&2; }

case "$status" in
  ready) ;;
  blocked)
    printf 'spawn-agent: agent started but is blocked at a startup dialog:\n' >&2; pane_dump
    emit blocked false; exit 3;;
  *)
    printf 'spawn-agent: herdr agent start failed (%s):\n%s\n--- pane %s ---\n' "$status" "$out" "$pane_id" >&2
    pane_dump
    herdr tab close "$tab_id" >/dev/null 2>&1 || printf 'spawn-agent: could not close tab %s\n' "$tab_id" >&2
    exit 1;;
esac

# --- task ----------------------------------------------------------------------
# No --wait: it would block the caller until the new agent finishes its turn.
if [ -n "$task" ]; then
  if ! out=$(herdr agent prompt "$handle" "$task" 2>&1); then
    code=4; case "$out" in *agent_blocked*) code=3;; esac
    printf 'spawn-agent: prompt not delivered:\n%s\n--- pane %s ---\n' "$out" "$pane_id" >&2; pane_dump
    emit "$([ $code = 3 ] && echo blocked || echo prompt_failed)" false; exit "$code"
  fi
  emit ready true; exit 0
fi
emit ready false
