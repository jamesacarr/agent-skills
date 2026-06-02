# Query

> Search the wiki and synthesise an answer from existing notes. Optionally file valuable synthesis back into the wiki.

## Prerequisites

- Read `references/conventions.md` for citation and staleness conventions.
- Verify the vault is reachable:

```bash
obsidian 'vault=wiki' vault
```

## Steps

### Step 1: Understand the Question

| Question Type | Approach |
|---------------|----------|
| Factual lookup | Find the specific page and answer with citation |
| Synthesis | Read multiple pages and combine supported claims |
| Comparison | Read both project/topic pages and compare cited differences |
| Exploration | Start with the topic page, then follow backlinks and outgoing links |

### Step 2: Search the Wiki

Use Obsidian CLI to find relevant pages:

```bash
obsidian 'vault=wiki' search 'query=<key terms>'
obsidian 'vault=wiki' tag 'name=<relevant-tag>' verbose
obsidian 'vault=wiki' backlinks 'file=<known relevant page>'
obsidian 'vault=wiki' links 'file=<known relevant page>'
```

Strategy:

1. Search by key terms from the question.
2. If the question names a known project or topic, read that page directly.
3. Check backlinks and outgoing links to find related pages.
4. Read the most relevant source summary pages behind important citations.

If no relevant pages are found, say the wiki has no information on the topic. Offer to ingest a source or direct knowledge now.

### Step 3: Synthesise Answer

Answer only from wiki content unless the user explicitly asks for external research.

Rules:

- Cite the wiki pages used: `According to [[projects/Project X]]...`
- Surface gaps instead of guessing.
- Mention stale pages when relevant: `This page was last updated on 2026-01-10 and may be outdated.`
- Surface relevant `> [!conflict]` callouts.
- Distinguish what the wiki says from your inference.

### Step 4: Offer to File the Answer

If the answer is a useful synthesis rather than a simple lookup, offer to save it:

```text
This comparison looks reusable. Want me to save it as topics/Authentication Patterns.md?
```

If the user agrees, follow the ingest conventions:

- Present the page path, tags, and source pages before writing
- Use proper frontmatter with refreshed `updated`
- Cite wiki pages or source summaries used
- Add wikilinks to related pages
- Summarise changes after writing

## Success Criteria

- Answers cite specific wiki pages or source summaries
- Knowledge gaps, stale pages, and conflicts are surfaced
- No unsupported claims are introduced as wiki knowledge
- Valuable synthesis is offered back to the wiki without writing until approved
