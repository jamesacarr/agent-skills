---
name: obsidian-wiki
description: Maintains James Carr's personal knowledge wiki in the Obsidian vault named wiki: ingesting sources, answering questions from existing notes, and auditing stale or weak knowledge. Use when adding knowledge from web pages, Slack, code, PRs, documents, or conversations; querying the wiki; or running wiki maintenance. Do NOT use for generic Obsidian CLI operations (use use-obsidian) or Obsidian Markdown syntax only (use obsidian-markdown).
---

# obsidian-wiki

## Essential Principles

- **The wiki is source-backed** - factual claims need citations because uncited knowledge becomes impossible to trust later. Use `[needs-source]` only when preserving an important claim that cannot yet be verified.
- **Source summaries are citation targets** - external sources get a page in `sources/`; topic and project pages cite that summary, not the original URL. This keeps context one hop away and originals two hops away.
- **One primary target per ingest** - put full detail on the page most directly about the source. Secondary pages get brief cross-references so topic pages stay focused.
- **Conflicts are explicit** - when new information contradicts existing claims, add a `> [!conflict]` callout with both claims and citations. Do not silently overwrite unresolved knowledge.
- **Mutations need a plan** - before creating or updating wiki pages, show the source summary, primary target, secondary targets, and risky assumptions because wiki changes compound over time.
- **Vault name is `wiki`** - prefix Obsidian CLI commands with `vault=wiki`, for example `obsidian 'vault=wiki' search 'query=kafka'`.
- **Use the specialised skills** - use `use-obsidian` for CLI syntax, `use-defuddle` for web extraction, and `obsidian-markdown` for note syntax.

## Intake

What would you like to do?

1. **Ingest** - add knowledge from a source (web page, Slack thread, PR, code repo, document), or from direct conversation
2. **Query** - search the wiki and synthesise an answer
3. **Lint** - audit for staleness, unsourced claims, conflicts, orphans, and graduation candidates

## Routing

| Response | Workflow |
|----------|----------|
| 1, "ingest", "add", "save", "clip", "file", "tell", "note", "remember" | `workflows/ingest.md` |
| 2, "query", "search", "find", "ask the wiki", "what does the wiki say" | `workflows/query.md` |
| 3, "lint", "audit", "check", "maintain", "review" | `workflows/lint.md` |

## References

- **Conventions** (vault structure, page formats, frontmatter, citations, conflicts, code references): `references/conventions.md`

## Success Criteria

- All wiki CLI examples use `obsidian 'vault=wiki' ...` with bare switches, not GNU-style flags
- New or updated claims have citations or `[needs-source]`
- Mutations are planned before execution and summarised afterwards
- Conflicts are preserved for user resolution
- `updated` frontmatter is refreshed on every edited wiki page
