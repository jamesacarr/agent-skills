---
name: use-glab
description: Manages GitLab merge requests using the glab CLI — creation, viewing, merging, and commenting (top-level and inline). Use when creating MRs, posting comments, merging, or any glab mr operation.
compatibility: Requires glab CLI (brew install glab) and GitLab authentication
---

# glab

## Essential Principles

- **Always squash commits** via `--squash-before-merge` on create or `--squash` on merge
- **Always delete source branch** via `--remove-source-branch` on create or `-d` on merge
- **Use MR templates** when `.gitlab/merge_request_templates/` exists in the repo
- **Comments go through `glab mr note` subcommands** (`create`, `list`, `resolve`, `update`; glab 1.116+). `create --reply` threads a reply and `create --file --line` places an inline diff comment, so the position-JSON dance via `glab api` is only a fallback. GitLab marks these subcommands experimental - if a flag is missing on the installed version, use the `glab api` fallback shown under Comments
- **API path placeholder:** Use `:fullpath` (not `:id`) for project reference in `glab api` calls
- **`--input` needs an explicit `-H "Content-Type: application/json"`** — without it the API returns 415

## Prerequisites

```bash
command -v glab >/dev/null 2>&1
```

If not found: `brew install glab`.

Verify authentication:

```bash
glab auth status
```

If not authenticated: `glab auth login`.

## Quick Start

```bash
glab mr create --title "[PROJ-123] Feature title" --squash-before-merge --remove-source-branch --push
glab mr merge <ID> --squash --remove-source-branch --yes  # use --yes only after user confirms
glab mr note create <ID> -m "Comment"                     # top-level comment (new thread)
glab mr note create <ID> --file src/file.ts --line 42 -m "Comment"   # inline diff comment
glab mr note create <ID> --reply <DISCUSSION_ID> -m "Reply"  # reply in an existing thread
```

## MR Creation

### Step 1: Detect MR Templates

```bash
ls .gitlab/merge_request_templates/ 2>/dev/null
```

If templates exist: list them and ask user which applies. Use `default.md` if present and user doesn't specify. Read the chosen template and use its content as the `--description` value.

### Step 2: Create MR

```bash
glab mr create \
  --title "[PROJ-123] Feature title" \
  --description "<template content or description>" \
  --target-branch main \
  --squash-before-merge \
  --remove-source-branch \
  --push
```

| Flag | Purpose |
|------|---------|
| `--title` | `[TICKET-KEY] Title` format — always include ticket prefix |
| `--squash-before-merge` | Squash commits into one on merge |
| `--remove-source-branch` | Delete branch after merge |
| `--push` | Push branch to remote before creating MR — required if branch not yet pushed |
| `--draft` | Mark as draft if work-in-progress |
| `--reviewer` | Request reviewers by username (comma-separated) |
| `--label` | Add labels (comma-separated) |
| `--assignee` | Assign to user(s) by username (comma-separated) |

**Do NOT use `--related-issue` with Jira ticket IDs** — it expects GitLab issue numbers.

**If creation fails with `403 {error: insufficient_scope}`:** the token cannot create MRs (read-scoped or AI-workflow token). Prefer fixing auth — ask the user to re-run `glab auth login` with an `api`-scope token. To proceed without it, create the MR through git push options, then set remaining fields with `glab mr update`:

```bash
git push -o merge_request.create \
  -o merge_request.target=<target-branch> \
  -o merge_request.title="[PROJ-123] Feature title" \
  origin <branch>
```

## MR View and Merge

### View MR

```bash
glab mr view <ID> -F json    # structured data (includes diff_refs)
glab mr view <ID> -c          # with comments
glab mr diff <ID>             # view diff
```

### Approve and Merge

```bash
glab mr approve <ID>
glab mr merge <ID> --squash --remove-source-branch --squash-message "<MR title>"
```

`--squash-message` defaults to the MR title. Set explicitly if the default doesn't match.

## Comments

### Top-Level Comment

```bash
glab mr note create <ID> -m "Comment text"
glab mr note create <ID> < comment.md                 # multi-line body from a file or stdin
glab mr note create <ID> --resolvable=false -m "CI passed"   # status note that never blocks "all threads resolved"
```

`create` starts a resolvable discussion thread by default; use `--resolvable=false` for automation or status updates nobody needs to resolve.

### Inline Comment (File + Line)

```bash
glab mr note create <ID> --file src/file.ts --line 42 -m "Comment text"
glab mr note create <ID> --file src/file.ts --line 10:15 -m "Range comment"
glab mr note create <ID> --file src/file.ts --old-line 42 -m "On a removed line"
glab mr note create <ID> --file src/file.ts -m "File-level comment"
```

Targets the latest diff version, so no SHA bookkeeping. `--line` and `--old-line` need `--file` and exclude each other.

### Reply to an Existing Discussion (Threaded)

Replies must target the discussion, or they land as a disconnected top-level comment. A note URL fragment like `#note_123456` gives a note ID, not a discussion ID; map it first:

```bash
glab mr note list <ID> -F json --jq '.[] | select(.notes[].id == <NOTE_ID>) | .id'
glab mr note create <ID> --reply <DISCUSSION_ID> -m "Reply text"
```

`--reply` accepts the full discussion ID or a unique prefix of 8+ characters, which is what `glab mr note list` prints in text mode.

### Resolve, List, Update

```bash
glab mr note list <ID> --state unresolved             # open threads; --type diff for inline only
glab mr note resolve <NOTE_ID_OR_DISCUSSION_ID> <ID>  # a note ID resolves its parent discussion
glab mr note update <ID> <NOTE_ID> -m "New body"
```

### Fallback: `glab api`

Use only when the installed glab lacks a `note` flag. Inline comments need `diff_refs` from `glab mr view <ID> -F json` (`base_sha`, `start_sha`, `head_sha`) in a position object:

```json
{"body": "Comment", "position": {"base_sha": "<BASE>", "start_sha": "<START>", "head_sha": "<HEAD>", "position_type": "text", "new_path": "src/file.ts", "new_line": 42}}
```

Use `old_path` + `old_line` for deleted lines, both paths for renames. Post it, or a thread reply, with:

```bash
glab api "projects/:fullpath/merge_requests/<IID>/discussions" --method POST -H "Content-Type: application/json" --input /tmp/glab-comment.json
glab api "projects/:fullpath/merge_requests/<IID>/discussions/<DISCUSSION_ID>/notes" --method POST --field "body=@reply.md"
```

If the post fails, re-fetch `diff_refs` - SHAs go stale after a rebase.

## Other Operations

| Operation | Command |
|-----------|---------|
| List open MRs | `glab mr list` |
| List my MRs | `glab mr list --author=@me` |
| List MRs for review | `glab mr list --reviewer=@me` |
| Close MR | `glab mr close <ID>` |
| Reopen MR | `glab mr reopen <ID>` |
| Update MR | `glab mr update <ID> --title "..." --label "..."` |
| Mark ready | `glab mr update <ID> --ready` |
| Mark draft | `glab mr update <ID> --draft` |
| Rebase MR | `glab mr rebase <ID>` |
| Compare commits | `glab api "projects/:fullpath/repository/compare?from=<SHA>&to=<SHA>"` |

## Success Criteria

- Squash and delete-source-branch set on every MR create and merge
- MR templates used when available in the repo
- Inline comments and thread replies posted via `glab mr note create` (`--file`/`--line`, `--reply`); `glab api` only when a flag is missing
- User confirmed before any mutation (create, merge, comment) — only pass `--yes` after explicit user approval
