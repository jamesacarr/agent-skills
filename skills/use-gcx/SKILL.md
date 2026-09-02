---
name: use-gcx
description: Manages Grafana and Grafana Cloud resources using the gcx CLI - dashboards, datasources, PromQL/LogQL/TraceQL queries, alert rules, SLOs, synthetic checks, IRM/OnCall, k6, fleet, and resources-as-code. Use when the user mentions gcx, Grafana, Loki, Prometheus/Mimir, Tempo, Pyroscope, or wants to query metrics, logs, traces, or profiles, inspect or change a dashboard, or investigate an alert. Do NOT use for driving the Grafana web UI in a browser.
compatibility: Requires gcx CLI (brew install gcx) and a configured Grafana context
---

# use-gcx

## Essential Principles

- **Load the bundled skill before acting.** gcx ships 24 task-specific Agent Skills inside the binary; they carry the query patterns, manifest shapes, and investigation workflows this file deliberately omits so it does not drift from the installed version. Pick one from the routing table below and read it with `gcx agent skills get <name> -otext`.
- **Discover, never guess commands.** The surface is large and versioned. `gcx help-tree --depth 1 -o text` orients; `gcx <group> <cmd> --help` gives exact flags and ends with a `Related skill(s)` pointer.
- **Agent mode is auto-detected** from `CLAUDECODE`, `PI_CODING_AGENT`, `CURSOR_AGENT`, and similar env vars: JSON output, skipped confirmation prompts, and large responses spilled to temp files.
- **gcx's own prompts are not a safety net.** Named `resources delete` selectors never prompt, `datasources delete` auto-approves in agent mode, and other deletes skip the prompt with `--force`. Confirm every mutation (create, update, delete, push, ack/silence/resolve) with the user first - the confirmation gate is you, not the CLI.
- **Verify the context before mutating.** Contexts are named environments (kubectl-style). `gcx config current-context` names the active one; `gcx config check --context <name>` confirms it can reach the server.
- **Prefer dedicated commands over `gcx api`.** They handle pagination, datasource resolution, and token-efficient output. Reserve `gcx api` for endpoints with no dedicated command.

## Prerequisites

```bash
command -v gcx >/dev/null 2>&1
```

If not found: `brew install gcx`.

Verify the active context is configured and reachable:

```bash
gcx config current-context               # name of the active context
gcx config check --context <name>
```

Without `--context`, `config check` tests every context and exits non-zero if any one is broken, even when the active one is healthy. If the active context reports `context references no stack` or a connectivity error, log in (browser OAuth works in agent mode - the user approves in the browser):

```bash
gcx login <context-name> --server https://<stack>.grafana.net --oauth
```

For non-interactive or on-prem setups, or 401/403 failures, load the `setup-gcx` bundled skill.

## Quick Start

```bash
gcx agent skills get <skill> -otext                      # load task guidance first
gcx datasources list --name prom                         # find datasource UIDs (see note below)
gcx metrics query -d <uid> 'up' --since 1h               # PromQL (range with --since/--from/--to)
gcx logs query -d <uid> '{app="api"} |= "error"' --limit 100   # LogQL
gcx traces query -d <uid> '{ status = error }'           # TraceQL
gcx dashboards search "checkout"                         # full-text dashboard search
gcx alert rules list                                     # alert rule state and health
gcx resources pull dashboards/<uid> -p ./resources       # export as manifest for editing
```

`datasources list` can return an empty `type` for every datasource on Grafana Cloud stacks, so `--type` filters match nothing (`datasources get <uid>` still shows it under `spec.type`). Filter with `--name`, or rely on the provisioned UIDs `grafanacloud-prom`, `grafanacloud-logs`, `grafanacloud-traces`, `grafanacloud-profiles`.

## Routing to Bundled Skills

Match the user's intent, then read the skill. Read only one or two; each is a full workflow.

| Intent | Bundled skill |
|--------|---------------|
| Install, log in, contexts, 401/403/connectivity errors | `setup-gcx` |
| Anything not covered below (discovery, output control, resources CRUD, Assistant) | `gcx` |
| Investigate errors/latency with metrics, logs, traces; incident RCA | `debug-with-grafana` |
| Why an alert rule is firing or pending | `investigate-alert` |
| What is paging in OnCall; ack, silence, resolve | `oncall-triage` |
| Audit or inspect an existing dashboard; versions; pull/push manifests | `manage-dashboards` |
| Design or create a dashboard; add panels, variables, annotations | `create-dashboard` |
| Convert live dashboards to Go builder code | `import-dashboards` |
| New resources-as-code Go project | `scaffold-project` |
| SLO health / budget / burn rate | `slo-check-status` |
| Why an SLO is breaching | `slo-investigate` |
| Create, update, push, pull, delete SLO definitions | `slo-manage` |
| Synthetic check health | `synth-check-status` |
| Why a synthetic check fails | `synth-investigate-check` |
| Create/update/delete synthetic checks | `synth-manage-checks` |
| Entity Graph / Knowledge Graph problems | `diagnose-entity-graph` |
| Agent Observability (LLM app telemetry, evaluators, guards) | `agento11y`, `agento11y-instrument`, `agento11y-prod-setup`, `agento11y-test-starter` |

`gcx agent skills list -o text` shows the current bundle with full descriptions if the table above is stale. Bundled skills also have reference files: `gcx agent skills get <skill> references/<file>.md`.

## Agent Mode Output

| Behaviour | How to work with it |
|-----------|---------------------|
| Hint lines (`{"class":"hint",...}`) precede output | They go to stderr; stdout is clean JSON and safe to pipe |
| Responses over 100 KiB spill to `gcx-results-*.json` in the system temp directory, and `--jq`/`--json` are not applied to them | Read the path in the `gcx.spill_reference` object, or pipe `-o json` to external `jq`; run `gcx agent prune` at session end |
| Errors are `gcx.error` objects with `exitCode` and `suggestions` | Follow the suggestions; exit code 4 means partial failure in a batch |
| Field selection and transformation | `--json field1,field2` (discover with `--json list`) or `--jq '<expr>'` - no external `jq` needed |
| Output shape varies per command (`.datasources[]`, `.items[]`, bare array) | Run `--json list` before writing a `--jq` path; a failed `--jq` returns a `gcx.error` that states the actual shape |
| Writes return `gcx.mutation_batch` (`summary`, `failures`, `dry_run`); pulls return `gcx.artifact_receipt` | Use `summary.failed` and `dry_run` to confirm what happened before reporting success |
| List commands return 50 items by default | `--limit 0` fetches everything; `dashboards list` pages with `--continue <token>` |
| Human-readable tables wanted (e.g. pasting to the user) | `-o table`, or `GCX_AGENT_MODE=0 gcx ...` |

`-o json|yaml` work everywhere; `-o table` and `-o text` do not (`gcx api` has neither). Query commands add `-o graph` (metrics), `-o raw` (log lines), and `--llm` (compact Tempo traces).

## Contexts

```bash
gcx config list-contexts                 # all contexts, current marked
gcx config use-context <name>            # switch
gcx <command> --context <name>           # one-off target without switching
gcx config view                          # config with secrets redacted - never cat the config file
gcx config set contexts.<name>.datasources.prometheus <uid>   # default -d for metrics; also .loki, .tempo, .pyroscope
gcx -vvv <command>                       # HTTP debugging; never --insecure-log-http-payload, it logs raw tokens
```

Without a default, `metrics query` fails with `Multiple prometheus datasources found` on stacks that have more than one.

## Mutations

For any change:

1. `gcx config check --context <name>` - confirm the target environment
2. Read current state (`get`, `list`, or `resources pull`)
3. Build from a pulled manifest, `gcx resources list-examples` (provider-backed kinds such as SLOs and checks), or the schema from `gcx resources list-types <kind>` - not a hand-written payload
4. `--dry-run` where the command supports it
5. Show the user the diff or command and get explicit approval
6. Apply, then re-read to verify

For kinds served by `gcx resources` (dashboards, folders, alertrules, and provider-backed `slo` and `checks`) the edit loop is `gcx resources pull <kind>/<name> -p ./dir`, edit the file, `gcx resources validate -p ./dir`, `gcx resources push -p ./dir`.

## Success Criteria

- Relevant bundled skill loaded via `gcx agent skills get` before running domain commands
- Commands discovered via `help-tree`/`--help`, not recalled from memory
- Active context confirmed with `gcx config check --context <name>` before any mutation
- User approved every mutation explicitly; no reliance on gcx prompts
- Dedicated commands used; `gcx api` only where no dedicated command exists
- Spill files read when referenced, then pruned at session end
