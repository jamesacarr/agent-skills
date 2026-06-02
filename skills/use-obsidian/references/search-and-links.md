# Search & Links

> Search vault content, explore link graphs, and inspect document outlines.

## Search

```bash
obsidian search 'query=search term'
obsidian search 'query=search term' path=folder limit=10
obsidian search 'query=search term' format=json
obsidian search:context 'query=search term'
obsidian search:open 'query=search term'
```

| Parameter | Purpose |
|-----------|---------|
| `query` | Search text (required) |
| `path` | Restrict to folder |
| `limit` | Max files |
| `format` | `text` (default) or `json` |

| Switch | Purpose |
|--------|---------|
| `total` | Count only |
| `case` | Case-sensitive search |

`search:context` returns matches with surrounding lines, useful when the full file is unnecessary.

## Backlinks

```bash
obsidian backlinks                      # backlinks to active file
obsidian backlinks 'file=Note Name'
obsidian backlinks 'file=Note' format=json
obsidian backlinks 'file=Note' counts
obsidian backlinks 'file=Note' total
```

Formats: `json`, `tsv`, `csv`.

## Outgoing Links

```bash
obsidian links                          # links from active file
obsidian links 'file=Note Name'
obsidian links total
```

## Unresolved Links

```bash
obsidian unresolved                     # vault-wide broken links
obsidian unresolved total
obsidian unresolved counts              # count per unresolved target
obsidian unresolved verbose             # include source files
obsidian unresolved format=json
```

## Orphans & Dead Ends

```bash
obsidian orphans                        # files with no incoming links
obsidian orphans total
obsidian orphans all                    # include non-markdown files
obsidian deadends                       # files with no outgoing links
obsidian deadends total
obsidian deadends all                   # include non-markdown files
```

Useful for vault maintenance: orphans are disconnected notes; dead ends are notes that do not link elsewhere.

## Outline

```bash
obsidian outline                        # headings of active file
obsidian outline 'file=Note Name'
obsidian outline format=tree            # tree view (default)
obsidian outline format=md              # markdown list
obsidian outline format=json
obsidian outline total                  # heading count
```
