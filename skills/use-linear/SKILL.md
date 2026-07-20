---
name: use-linear
description: Manages Linear issues, comments, relations, projects, and teams using the linear CLI (schpet/linear-cli). Use when creating, viewing, listing, searching, updating, or commenting on Linear issues, starting work on an issue, or opening a PR from one. Do NOT use for authoring ticket content/acceptance criteria (use write-tickets).
compatibility: Requires linear-cli (schpet/linear-cli) v2+ via brew/deno/npm
---

# use-linear

## Essential Principles

- **Use file-based flags for markdown.** Pass descriptions and comment bodies via `--description-file` / `--body-file`, not inline `-d` / `-b`. Inline flags mangle multi-line content (literal `\n`, shell escaping). Reserve inline flags for single-line content.
- **Pass `--no-interactive` on `issue create`.** The CLI prompts interactively by default, which hangs an agent waiting on input; `--no-interactive` makes it fail loudly on missing required fields instead. Only `create` has this flag — `update` doesn't prompt for missing fields.
- **Priority is numeric 1–4, descending.** `1` = Urgent, `2` = High, `3` = Medium, `4` = Low. Not `High`/`Low` strings.
- **Issue ID is optional on most commands** — when omitted it's inferred from the current git branch (e.g. a branch like `eng-123-fix-thing`). Pass an explicit ID (`ENG-123`) when not on the issue's branch.
- **`list`/`mine` vs `query`.** `issue list` (alias `mine`) shows *your* issues and defaults to `unstarted` state. `issue query` is structured search across teams with `--json`; use it for anything beyond your own active work.
- **`--json` for scripting.** Use it on `issue view` and `issue query` when parsing or piping results.
- **`linear api` is the escape hatch.** Anything the typed commands don't cover, do via raw GraphQL.
- **`--help` is the source of truth.** The flag tables cover the v2.0.0 surface for one-shot use; if a flag is rejected or a subcommand is missing, run `linear <cmd> --help`.
- **Confirm before mutations** (create, update, delete, relation, PR). Don't mutate without user approval.

## Prerequisites

```bash
command -v linear >/dev/null 2>&1
```

If not found: `brew install schpet/tap/linear` (or `npm i -D @schpet/linear-cli`, `deno install -A -g -n linear jsr:@schpet/linear-cli`).

Verify authentication:

```bash
linear auth whoami
```

If not authenticated: create an API key at `linear.app/settings/account/security`, then `linear auth login`. Configure the repo's default team/workspace with `linear config` (writes `.linear.toml`).

## Quick Start

```bash
linear issue view ENG-123                  # view (omit ID to use current branch)
linear issue list --state started          # your in-progress issues
linear issue query --search "oauth" --json # structured search
linear issue start ENG-123                  # create/switch branch + move to started
linear issue create -t "Title" --description-file desc.md --no-interactive
linear issue comment add ENG-123 --body-file note.md
```

## Issues

### Create

Write the description to a file first, then reference it:

```bash
cat > "$TMPDIR/desc.md" <<'EOF'
## Summary
What and why.

## Acceptance criteria
- [ ] First
- [ ] Second
EOF

linear issue create \
  -t "Fix token refresh race" \
  --description-file "$TMPDIR/desc.md" \
  --team ENG -p 2 -l bug --no-interactive
```

| Flag | Purpose |
|------|---------|
| `-t, --title` | Title |
| `-d, --description` | Inline description (single-line only) |
| `--description-file <path>` | Description from file (preferred for markdown) |
| `--team <key>` | Team (if not your configured default) |
| `-p, --priority <1-4>` | Priority: `1` Urgent … `4` Low |
| `-a, --assignee <who>` | `self`, username, or name |
| `-l, --label <name>` | Label (repeatable) |
| `-s, --state <name\|type>` | Initial workflow state |
| `--project <name>` | Project name or slug ID |
| `--milestone <name>` | Project milestone |
| `--cycle <name\|number\|active>` | Cycle |
| `--parent <ID>` | Parent issue (e.g. `ENG-100`) |
| `--estimate <n>` | Points estimate |
| `--due-date <date>` | Due date |
| `--start` | Start the issue immediately after creation |
| `--no-interactive` | Fail instead of prompting for missing fields |

### View

```bash
linear issue view ENG-123                   # full details + comments
linear issue view ENG-123 --no-comments     # skip comments
linear issue view ENG-123 --json            # structured output
linear issue view --web                     # open current-branch issue in browser
linear issue view -a                        # open in Linear.app (desktop)
```

`--show-resolved-threads` includes resolved comment threads in the output.

### Update

```bash
linear issue update ENG-123 -s "In Review" -a self
linear issue update ENG-123 --description-file "$TMPDIR/desc.md"
linear issue update ENG-123 -p 1 --milestone "Beta"
```

Takes the same field flags as `create` (`-t`, `-s`, `-p`, `-a`, `-l`, `--project`, `--milestone`, `--cycle`, `--parent`, `--estimate`, `--due-date`). Omit the ID to update the current-branch issue.

Workflow state names are team-specific — a team may have no `In Review`, or use `Won't Do` instead of `Canceled`. If a state name is rejected (`Workflow state not found`), list the team's states instead of guessing:

```bash
linear api <<'GRAPHQL'
query { teams(filter: { key: { eq: "ENG" } }) { nodes { states { nodes { name type } } } } }
GRAPHQL
```

### List (your issues)

```bash
linear issue list                                  # your unstarted issues (default)
linear issue list --state started --state completed # repeat --state for multiple
linear issue list --all-states --team ENG
linear issue list --label bug --sort priority
```

| Flag | Purpose |
|------|---------|
| `-s, --state <state>` | `triage`, `backlog`, `unstarted`, `started`, `completed`, `canceled` (repeatable) |
| `--all-states` | All states |
| `--team <key>` | Team override |
| `--project` / `--milestone` / `--cycle` | Scope filters (`--milestone` requires `--project`) |
| `-l, --label <name>` | Label (repeatable) |
| `--sort <manual\|priority>` | Sort order (or set `LINEAR_ISSUE_SORT`) |
| `--limit <n>` | Max results (default 50, `0` = unlimited) |
| `--created-after` / `--updated-after <date>` | Date filters (ISO 8601 or `YYYY-MM-DD`) |

### Query (structured search)

```bash
linear issue query --search "rate limit" --all-teams --json
linear issue query --team ENG -s started --assignee alice
linear issue query --unassigned -s backlog --limit 0
```

Like `list` plus: `--search <term>` (full-text; add `--search-comments` to include comments), `--all-teams`, `--assignee <username>`, `-U/--unassigned`, `--include-archived`, `-j/--json`. `--sort` is unavailable with `--search`.

### Start work

```bash
linear issue start ENG-123                  # create/checkout branch, move to started
linear issue start -b custom-branch-name ENG-123
linear issue start -f main ENG-123          # branch from a specific ref
```

Omit the ID to pick from your assigned issues interactively (a picker, not branch inference).

### Comment

```bash
linear issue comment add ENG-123 --body-file "$TMPDIR/note.md"
linear issue comment add ENG-123 -b "Single-line note"
linear issue comment add ENG-123 --body-file reply.md -p <COMMENT_ID>   # reply in thread
linear issue comment list ENG-123
linear issue comment update <COMMENT_ID> --body-file edit.md
linear issue comment delete <COMMENT_ID>
```

`-a/--attach <path>` attaches files (repeatable).

### Relations (dependencies)

```bash
linear issue relation add ENG-123 blocked-by ENG-100
linear issue relation add ENG-123 blocks ENG-456
linear issue relation add ENG-123 related ENG-456
linear issue relation add ENG-123 duplicate ENG-100
linear issue relation list ENG-123
linear issue relation delete ENG-123 blocks ENG-456
```

### Create a PR from an issue

Run from the issue's git branch:

```bash
linear issue pr                             # GitHub PR titled/prefixed with the issue ID
linear issue pr --draft --base main
linear issue pr -t "Custom title" --web
```

`--head` sets the source branch; the Linear issue ID is auto-prefixed onto the title and linked. Requires the `gh` CLI configured for the GitHub side — run `gh auth status` first if unsure. For richer PR authoring (templates, reviewers, body from a description), create the PR with the `use-gh` skill instead; use this when you want Linear to own the issue↔PR link.

### Other issue operations

| Operation | Command |
|-----------|---------|
| Print current-branch issue ID | `linear issue id` |
| Print issue title | `linear issue title [ID]` |
| Print issue URL | `linear issue url [ID]` |
| Commit trailer for the issue | `linear issue describe [ID]` (`-r` for `References` instead of `Fixes`) |
| Attach a file | `linear issue attach ENG-123 ./diagram.png` |
| Link a URL | `linear issue link ENG-123 https://...` |
| Delete an issue | `linear issue delete ENG-123` |

## Teams, Projects, Milestones

```bash
linear team list
linear team members [TEAM_KEY]
linear project list
linear project view <PROJECT_ID>
linear milestone list --project <PROJECT_ID>     # alias: linear m
linear milestone create --project <ID> --name "Beta" --target-date 2026-07-01
```

`project` and `milestone` also support `create` / `update` / `delete`. Use `--help` on any for flags.

## Command Families

Lower-frequency families follow the same `list` / `view` / `create` / `update` / `delete` shape — discover flags with `linear <family> --help` rather than guessing:

| Family | Alias | Manages |
|--------|-------|---------|
| `cycle` | `cy` | Team cycles (sprints) |
| `initiative` | `init` | Initiatives (groups of projects) |
| `initiative-update` | `iu` | Initiative status posts |
| `project-update` | `pu` | Project status posts |
| `label` | `l` | Issue labels |
| `document` | `docs` | Documents (`--content-file` for markdown) |

`team autolinks` configures GitHub repo autolinks for the team's issue prefix.

## Configuration

Config is read from `.linear.toml` (repo or `~/.config/linear/`) or env vars (env wins):

| Setting | Env var | TOML key |
|---------|---------|----------|
| Default team | `LINEAR_TEAM_ID` | `team_id` |
| Workspace slug | `LINEAR_WORKSPACE` | `workspace` |
| Issue sort | `LINEAR_ISSUE_SORT` | `issue_sort` |
| VCS (`git`/`jj`) | `LINEAR_VCS` | `vcs` |

Generate it interactively with `linear config`. Target a non-default workspace per-command with `--workspace <slug>`.

## GraphQL API

For operations the typed commands don't cover. Use heredoc stdin so non-null type markers (`$id: String!`) aren't mangled by the shell:

```bash
linear api --variable teamId=abc123 <<'GRAPHQL'
query($teamId: String!) { team(id: $teamId) { name } }
GRAPHQL
```

`--variable key=value` (coerces booleans/numbers/null; `@file` reads from a path), `--variables-json`, `--paginate`, `--silent`. `linear schema` prints the full GraphQL schema; `linear auth token` prints the token for use with curl.

## Success Criteria

- File-based flags (`--description-file` / `--body-file`) used for any multi-line markdown
- `--no-interactive` used on scripted creates so missing fields fail loudly
- Priority given as a number 1–4, not a string
- `query` (not `list`) used for searches beyond the user's own active issues
- User confirmed before any mutation (create, update, delete, relation, PR)
