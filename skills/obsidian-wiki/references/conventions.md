# Conventions

> Vault structure, page formats, frontmatter schemas, citation model, conflict handling, code references, and tags.

## Contents

- Vault Structure
- Timestamps
- Frontmatter
- Citation Model
- Conflict Handling
- Code References
- Tags
- Primary and Secondary Targets

## Vault Structure

The wiki vault is named `wiki`. Prefix CLI commands with `vault=wiki`:

```bash
obsidian 'vault=wiki' search 'query=kafka'
obsidian 'vault=wiki' create 'path=topics/Kafka.md' 'content=...'
```

Expected top-level folders:

```text
wiki/
├── sources/          # one summary per ingested external source
├── projects/         # work and personal project pages
├── topics/           # concepts, technologies, domains
└── notes/            # catch-all, graduates into projects/ or topics/
```

Single vault. No index file by default; Obsidian CLI search and links handle navigation. No operation log; git history covers changes.

## Timestamps

Use UTC ISO 8601 timestamps. Generate them with:

```bash
date -u '+%Y-%m-%dT%H:%M:%SZ'
```

Update the `updated` field on every edited wiki page.

## Frontmatter

### Source Summary Pages (`sources/`)

```yaml
---
source: https://example.com/article
source_type: web
accessed: 2026-06-02T03:08:27Z
updated: 2026-06-02T03:08:27Z
author: Jane Smith
published: 2026-03-15
tags:
  - kafka
  - data-pipeline
---
```

| Field | Required | Notes |
|-------|----------|-------|
| `source` | Yes | URL, Slack thread link, repo URL, file path, or `direct` |
| `source_type` | Yes | `web`, `slack`, `code`, `pr`, `document`, or `conversation` |
| `accessed` | Yes | When the source was ingested |
| `updated` | Yes | Last modification |
| `author` | If known | Original author |
| `published` | If known | Original publication date |
| `tags` | Yes | At least one topic or project tag |

### Wiki Pages (`projects/`, `topics/`, `notes/`)

```yaml
---
updated: 2026-06-02T03:08:27Z
tags:
  - kafka
  - data-pipeline
---
```

| Field | Required | Notes |
|-------|----------|-------|
| `updated` | Yes | Last modification |
| `tags` | Yes | At least one tag for discovery |

## Citation Model

Every factual claim gets a footnote. Prefer concise citations over vague source lists.

### Citing Source Summaries

```markdown
Kafka is used for cross-region replication in the data pipeline.[^1]

[^1]: [[sources/Platform Architecture Review 2026-03]]
```

The source summary links to the original URL/thread/PR. This keeps the reader one hop from context and two hops from the original.

### Citing Direct Knowledge

Use inline direct citations for brief user-provided facts:

```markdown
Session tokens expire after 24 hours.[^1]

[^1]: Direct - James Carr, 2026-06-02
```

If the user provides multiple facts, detailed context, or history, create a `sources/` page with `source: direct` and `source_type: conversation`.

### Unsourced Claims

```markdown
The service handles approximately 10k requests per second. [needs-source]
```

Use `[needs-source]` only when the claim is worth preserving and no citation is available yet. Lint flags these.

## Conflict Handling

When new information contradicts an existing claim, preserve both claims:

```markdown
> [!conflict] Conflicting information
> **Existing claim:** Sessions stored in Redis with 24h TTL.[^1]
> **New claim:** Sessions migrated to Postgres-backed storage.[^2]
> Needs user resolution.

[^1]: [[sources/Platform Architecture Review 2026-03]]
[^2]: [[sources/Slack Thread - Session Migration 2026-06]]
```

Only remove a conflict after the user resolves it. Keep the accepted claim with its citation.

## Code References

### Current Code (Verifiable)

Point to a thing, not a line number:

```markdown
See: `org/repo` - `src/middleware/auth.ts` -> `validateJWT()`
```

Lint can verify whether the file and symbol still exist.

### Historical Code (Frozen Snapshot)

Use a GitHub permalink for intentionally historical references:

```markdown
See: [auth.ts at time of migration](https://github.com/org/repo/blob/abc123/src/auth.ts#L15-L42)
```

Mark it as historical so lint does not treat it as a stale current-code reference.

## Tags

Use tags consistently for discovery:

| Kind | Pattern | Example |
|------|---------|---------|
| Project | project name | `data-pipeline` |
| Topic | topic name | `kafka`, `jwt`, `typescript` |
| Status | nested status | `status/active`, `status/archived`, `status/draft` |

Prefer flat tags for topics and projects. Use nested tags for orthogonal dimensions like status.

## Primary and Secondary Targets

Every ingest has:

- **Primary target** - the page most directly about the source content. Gets full detail, citations, and new sections.
- **Secondary targets** - related pages that should cross-reference the new information. Get brief mentions and wikilinks back to the primary page.

Example: ingesting a Slack thread about Project X's Kafka migration.

- Primary: `projects/Project X.md` - full migration detail
- Secondary: `topics/Kafka.md` - brief mention that Project X uses Kafka for cross-region replication
