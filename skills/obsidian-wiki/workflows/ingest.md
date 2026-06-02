# Ingest

> Add knowledge from a source into the wiki with source summaries, citations, primary targets, and secondary cross-references.

## Prerequisites

- Read `references/conventions.md` for frontmatter, citations, conflicts, tags, and target selection.
- Verify the vault is reachable:

```bash
obsidian 'vault=wiki' vault
```

- Generate timestamps with:

```bash
date -u '+%Y-%m-%dT%H:%M:%SZ'
```

## Steps

### Step 1: Identify Source Type

| User provides | Source type | Extractor |
|---------------|-------------|-----------|
| Web page or article URL | `web` | `defuddle parse <url> --json`; fall back to the available web fetch/extract tool if incomplete |
| Slack thread link or channel reference | `slack` | Slack tooling if available; otherwise ask for pasted/exported thread content |
| GitHub PR/issue URL or reference | `pr` | `gh pr view` or `gh issue view` |
| File path to PDF/document | `document` | `read` for supported files; otherwise extract text with available local tooling |
| Repository path or URL | `code` | `read`, `rg`, `find`, git history, and `gh` as needed |
| Verbal/typed knowledge | `conversation` | User statement is the source |

### Step 2: Extract Content

Extract enough source content to support citations. Do not ingest everything by default.

For web pages:

```bash
defuddle parse 'https://example.com/article' --json
```

Capture title, author, published date, URL, accessed timestamp, and the extracted content.

For Slack threads, capture participants, timestamps, decisions, actions, and linked context.

For code repos, focus on:

- What the project does
- Key architecture decisions and rationale
- Current conventions and gotchas
- Important symbols or files worth referencing

### Step 3: Find Related Wiki Pages

Search before deciding targets:

```bash
obsidian 'vault=wiki' search 'query=<key terms>'
obsidian 'vault=wiki' tags
obsidian 'vault=wiki' files folder=projects
obsidian 'vault=wiki' files folder=topics
```

Read candidate pages before updating them. Existing structure should guide target choice.

### Step 4: Identify Targets and Ask Approval

Choose one primary target and zero or more secondary targets.

| Source focus | Primary target |
|--------------|----------------|
| Specific project | `projects/<Project>.md` |
| Concept, technology, domain | `topics/<Topic>.md` |
| Unclear or early note | `notes/<Name>.md` |

Before mutating the vault, present:

- Source summary path, unless using a brief direct citation
- Primary page to create/update
- Secondary pages to update
- Conflicts or assumptions already visible

Ask for approval if the user has not already approved this exact plan.

### Step 5: Create or Update Source Summary

Skip this step only for brief direct knowledge that can be cited inline.

For all other sources, create or update a page in `sources/`:

```bash
obsidian 'vault=wiki' create 'path=sources/<Title>.md' 'content=...'
obsidian 'vault=wiki' read 'path=sources/<Title>.md'
```

The source summary contains:

- Frontmatter from `references/conventions.md`
- Concise summary of key information
- Notable quotes, data points, or decisions
- Wikilinks to related project/topic pages
- Original source link in `source`

If the summary already exists, read it first, merge new information, and refresh `updated`.

### Step 6: Update Primary Target

Read the existing page if present:

```bash
obsidian 'vault=wiki' read 'path=projects/<Project>.md'
```

Integrate new knowledge:

- Add or update sections with cited claims
- Cite the source summary, or direct knowledge for brief user statements
- Add `> [!conflict]` when new claims contradict existing ones
- Refresh `updated`
- Add useful tags without duplicating existing ones

If the page does not exist, create it with frontmatter and the new content.

### Step 7: Update Secondary Targets

For each secondary page:

- Add a brief mention with a wikilink to the primary page
- Add a citation when the mention makes a factual claim
- Refresh `updated`

Create secondary pages only when the information is substantial. Do not create stubs for tangential mentions.

### Step 8: Report Results

Report:

- Source summary created or updated
- Primary page created or updated
- Secondary pages updated
- Conflicts added
- `[needs-source]` markers added
- Any source content intentionally skipped

## Source-Specific Guidance

### Web Pages

Use defuddle first because it strips navigation and clutter:

```bash
defuddle parse 'https://example.com/article' --json
```

If extraction is empty or clearly incomplete, use the available web fetch/extract tool and note the fallback in the source summary if relevant.

| Harness | Fallback tool |
|---------|---------------|
| Pi | `web_extract` |
| Claude Code | `WebFetch` |
| Other / unavailable | Ask the user to paste the source or provide an accessible export |

### Slack Threads

Distil decisions and outcomes. Preserve enough speaker/timestamp context for later verification, but do not quote entire threads unless the wording matters.

### Code Repositories

Focus on durable knowledge:

- What the project does
- Architectural decisions and rationale
- Gotchas and tribal knowledge
- Current initiatives if known

Use verifiable code references:

```markdown
See: `org/repo` - `path/to/file.ts` -> `functionName()`.
```

### Re-Ingesting Updated Sources

1. Read the existing source summary.
2. Extract the current source content.
3. Compare old summary to new extraction.
4. Update changed information and refresh `updated`.
5. Check pages citing the summary; add conflict callouts when old cited claims are contradicted.

### Direct Knowledge

For a single fact, update the relevant page with an inline direct citation:

```markdown
The token TTL is 24 hours.[^1]

[^1]: Direct - James Carr, 2026-06-02
```

For substantial direct knowledge, create a `sources/` page with `source: direct` and `source_type: conversation`.

## Success Criteria

- Source summary exists for external or substantial sources
- Primary page contains full detail with citations
- Secondary pages cross-reference the primary page
- Conflicts are flagged, not overwritten
- New claims have citations or `[needs-source]`
- Edited pages have refreshed `updated` timestamps
