---
name: spawn-agent
description: Starts a named agent session (Claude Code, Codex, pi, or any Herdr-supported kind) in a new Herdr tab in the current workspace, optionally on a specific model. Use when the user asks to spawn an agent, open a new tab running Claude, Codex, or pi, or hand a side task to a fresh session (e.g. "/spawn-agent ABC-123 review", "spin up a codex agent for the docs"). Requires HERDR_ENV=1.
compatibility: Requires running inside Herdr (HERDR_ENV=1) with the herdr CLI available
---

# spawn-agent

## Essential Principles

- Herdr owns the tab, the agent owns the session. `herdr tab create` yields a shell pane, `herdr agent start` turns that pane into an agent session, and everything after `--` goes to the agent's own CLI.
- One tab per invocation. When a step fails, repair the tab you already created instead of making another - orphan tabs are invisible cleanup for the user.
- The new session inherits only cwd. Its context is empty, so any task detail must be sent as a prompt.

## Parameters

| Param | Required | Default |
|-------|----------|---------|
| `name` | yes | - |
| `kind` | no | the agent running this skill |
| `model` | no | omitted, so the new session starts on that agent's default model |
| `focus` | no | conditional - resolved below |

`kind` maps directly to herdr's `--kind` flag and names which agent CLI to launch (`claude`, `codex`, `pi`, ...). The default needs no detection command: you know which harness is executing this skill, so resolve it yourself (Claude Code → `claude`, Codex → `codex`, pi → `pi`). Pass an unfamiliar kind through untouched - `herdr agent start` validates against its own supported list, so don't maintain one here.

When `focus` isn't given, key it to the same decision Step 4 makes about sending a prompt: an initial task will be sent → `no`, because the user delegated and stays put; no initial task → `yes`, because the empty session waits for their input, so land them there. A user asking to switch context ("open a tab", "take me there") is an explicit `yes`, and an explicit `focus` from the user or a calling skill always wins.

`name` is free text (spaces and capitals are fine). It is used three ways: the tab label, the session display name for kinds that support one, and a slugified Herdr agent handle. `model` is passed verbatim to the agent's model flag - never guess a value the user didn't give, and never translate a model between agents (`sonnet` means something to `claude` and nothing to `codex`). For reference: `claude` takes an alias (`opus`, `sonnet`, `fable`, `haiku`) or a full ID (`claude-opus-5`); `pi` takes a pattern or ID (`provider/id`, fuzzy like `*sonnet*`, optional `:<thinking>` suffix); `codex` takes a model ID.

If `name` is missing and can't be inferred from the request, ask for it rather than inventing one.

## Per-Agent CLI Flags

Each agent CLI accepts different flags after `--`:

| Kind | Name flag | Model flag |
|------|-----------|------------|
| `claude` | `--name` | `--model` |
| `pi` | `--name` | `--model` |
| `codex` | none - the tab label carries the name | `--model` |
| others | none | verify with `<cli> --help` before passing one |

Never pass a flag this table doesn't list for the kind without checking the CLI's help first: an unknown flag makes the agent exit immediately, which surfaces confusingly as a Herdr `timeout` error.

## Process

### Step 1: Preflight

```bash
test "${HERDR_ENV:-}" = 1
```

If this fails, say you're not running inside Herdr and stop - none of the commands below can reach a session.

### Step 2: Derive the Agent Handle

Herdr handles must match `[a-z][a-z0-9_-]{0,31}` and be unique among live agents, so slugify `name` for the handle and keep the raw text for the label:

```bash
handle=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/^([^a-z])/a-\1/' | cut -c1-32 | sed -E 's/-+$//')
herdr agent list | jq -r '.result.agents[]?.name // empty'
```

On a collision, suffix the handle (`-2`, `-3`). Names from exited agents are already released and safe to reuse.

### Step 3: Create the Tab and Start the Agent

```bash
pane=$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label "$name" --focus | jq -r '.result.root_pane.pane_id')

args=()
case "$kind" in claude|pi) args+=(--name "$name");; esac
[ -n "$model" ] && args+=(--model "$model")

for attempt in 1 2 3 4 5 6 7 8 9 10; do
  out=$(herdr agent start "$handle" --kind "$kind" --pane "$pane" --timeout 120000 -- "${args[@]}" 2>&1)
  case "$out" in *agent_pane_busy*) sleep 1; continue;; esac
  break
done
printf '%s\n' "$out"
```

Why each part is shaped that way:

- `--cwd "$PWD"` - a tab created without it starts wherever the Herdr server was launched, not in the repo being worked on.
- `--focus` - include only when `focus` resolves to `yes` (see Parameters); otherwise omit the flag - everything else is unchanged.
- The retry loop - a brand-new pane usually reports `agent_pane_busy` for the first second or two while the shell finishes its rc files. That error means nothing was launched, so retrying is safe. Any other error breaks the loop immediately.
- The `args` array - it keeps each flag and value a separate argv entry. Do **not** replace it with an inline `${model:+--model "$model"}` expansion: that passes `--model sonnet` as a single argv entry, hitting the unknown-flag failure described in Per-Agent CLI Flags. The `case` keys off that table.
- `--timeout 120000` - the default 30s can be tight while the new session loads MCP servers, extensions, and plugins.

On failure, read the pane before doing anything else: `herdr pane read "$pane"` (positional, no `--pane`) shows the shell's own error. If `$pane` is empty, `herdr tab create` itself failed - inspect its output and stop rather than calling `herdr agent start` with an empty pane. Close the tab with `herdr tab close <tab_id>` (also positional) only if you're abandoning the attempt.

### Step 4: Report Back

Give the user the tab label, the handle, the kind (when it isn't the default), the model if one was requested, and how to drive it:

```bash
herdr agent prompt <handle> "<task>" --wait
```

Send a prompt yourself only if the user asked the new session to start on something specific.

## Success Criteria

- A new tab in the current workspace (focused only when `focus` resolved to `yes`), labelled `name`, cwd matching the invoking session.
- `herdr agent list` shows the handle with the resolved kind; for kinds with a name flag (`claude`, `pi`) the session's terminal title reads `name`.
- The session runs the requested model, or that agent's default when `model` was omitted.
- Exactly one tab created - no orphans left by a retry.
