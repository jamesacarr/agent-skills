# Lint

> Audit the wiki for conflicts, unsourced claims, stale pages, broken code references, disconnected pages, unresolved links, and graduation candidates.

## Prerequisites

- Read `references/conventions.md` for expected formats.
- Verify the vault is reachable:

```bash
obsidian 'vault=wiki' vault
```

## Steps

### Step 1: Scope the Audit

Ask or infer scope:

| Scope | Checks |
|-------|--------|
| Full vault | Run all checks below |
| Single page | Run all checks for one page |
| Specific check | Run one check type across the vault |

### Step 2: Run Checks

#### Unresolved Conflicts

```bash
obsidian 'vault=wiki' search 'query=[!conflict]'
```

Report the page, both claims, and cited sources. Conflicts need user resolution.

#### Unsourced Claims

```bash
obsidian 'vault=wiki' search 'query=needs-source'
```

Report the page, claim text, and count per page. High counts are the highest citation priority.

#### Staleness

Check `updated` frontmatter dates across wiki pages. Flag pages older than the folder threshold:

| Folder | Threshold |
|--------|-----------|
| `projects/` | 90 days |
| `topics/` | 180 days |
| `sources/` | No threshold; summaries are point-in-time |
| `notes/` | 60 days |

Use properties and file lists to find candidates:

```bash
obsidian 'vault=wiki' properties name=updated format=json
obsidian 'vault=wiki' files folder=projects
obsidian 'vault=wiki' files folder=topics
obsidian 'vault=wiki' files folder=notes
```

Read flagged pages and assess whether stale content is likely harmful. Report context, not just dates.

#### Code Reference Verification

Search for current-code references using the wiki convention:

```bash
obsidian 'vault=wiki' search 'query=->'
```

For each reference, verify:

1. Does the referenced file still exist?
2. Does the referenced symbol still exist in that file?

Use local filesystem checks when the repo is present; otherwise use `gh` for GitHub repos. Report broken references with the wiki page where they appear.

#### Orphans, Dead Ends, and Unresolved Links

```bash
obsidian 'vault=wiki' orphans
obsidian 'vault=wiki' deadends
obsidian 'vault=wiki' unresolved
```

- **Orphans** - pages with no incoming links. They may need links from project/topic pages.
- **Dead ends** - pages with no outgoing links. They may need related-topic links.
- **Unresolved links** - wikilinks to missing pages. Either create the page or fix the link after approval.

#### Source Link Reachability

For source summary pages with URLs, optionally check whether the original source is reachable. This is slow and network-dependent, so run only when requested.

#### Notes Graduation

Find notes that should move from `notes/` to `projects/` or `topics/`:

```bash
obsidian 'vault=wiki' files folder=notes
```

For each note, check:

- Inbound links: `obsidian 'vault=wiki' backlinks 'file=<note>'`
- Update frequency: git history for the note path, if the vault is a git repo
- Content focus: project-specific pages graduate to `projects/`; concept pages graduate to `topics/`

Suggest moves. Do not move pages without approval.

### Step 3: Report

Group findings by priority:

1. Unresolved conflicts
2. Unsourced claims
3. Broken code references
4. Stale pages
5. Orphans and dead ends
6. Unresolved links
7. Graduation candidates

For each finding, include page, evidence, impact, and suggested action.

### Step 4: Fix with Approval

Offer fixes only when the resolution is clear:

| Finding | Safe Fix |
|---------|----------|
| Broken code reference | Update path/symbol if the new location is known |
| Unresolved link | Fix link or create a stub after approval |
| Dead end | Add relevant wikilinks after approval |
| Stale page | Add review note or ingest updated source after approval |

Do not auto-fix conflicts or remove `[needs-source]` markers. They require user judgement or a verified source.

## Success Criteria

- Requested checks are run against the agreed scope
- Findings are grouped by priority and include context
- Suggested actions are specific
- No vault mutations happen without approval
- Conflicts and unsourced claims remain visible until resolved by the user
