---
name: use-obsidian
description: Manages Obsidian vaults using the native obsidian CLI: files, folders, search, links, daily notes, templates, properties, tags, tasks, vaults, plugins, themes, sync, tabs, bookmarks, hotkeys, and app commands. Use when creating, reading, searching, or organising notes, managing metadata or tasks, working across vaults, controlling the Obsidian app, or running any obsidian CLI operation. Do NOT use for Obsidian Markdown syntax guidance (wikilinks, callouts, embeds) - that is content formatting, not CLI operation.
---

# use-obsidian

## Essential Principles

- **Obsidian must be running** - the CLI communicates with the app via IPC. The first command may launch Obsidian, so allow for startup delay.
- **Use real CLI syntax** - parameters are `key=value`; switches are bare words (`total`, `verbose`, `open`), not GNU flags (`--total`). Unsupported words may be ignored, so verify unfamiliar commands with `obsidian help <command>`.
- **`file=` vs `path=`** - `file=` uses wikilink-style resolution (partial names, no extension needed); `path=` requires the exact vault-root-relative path. Prefer `file=` for user-facing lookups, `path=` for scripting precision.
- **Default vault is CWD** - inside a vault, that vault is used. Otherwise, the active vault is used. Prefix commands with `vault=<name>` or `vault=<id>` when the target vault matters.
- **Quote shell arguments** - pass each `key=value` as one shell argument when values contain spaces or escaped newlines: `obsidian read 'file=My Note'`, `obsidian create 'name=New Note' 'content=# Title\nBody'`.

## Mutation Policy

| Operation | Behaviour |
|-----------|-----------|
| Read, search, list, info, count, open | Run without confirmation. |
| Specific mutation explicitly requested by the user | Proceed when target and content are unambiguous. |
| Destructive, broad, restore, overwrite, sync state, plugin/theme/snippet changes, reload/restart, arbitrary `command`/`eval`/`dev:*` | Summarise the exact action and ask for confirmation first because these can change the vault, app state, or synced data. |

## Prerequisites

```bash
command -v obsidian >/dev/null 2>&1
```

If not found: enable Obsidian Settings > General > Command line interface, then restart the terminal.

Verify the CLI can reach the running app:

```bash
obsidian vault
```

If IPC fails, ensure Obsidian is running and rerun the command.

## Quick Start

```bash
obsidian vault                         # show current vault info
obsidian 'vault=Work' files            # list files in a specific vault
obsidian files                         # list vault files
obsidian read 'file=Note Name'         # read a note
obsidian create 'name=New Note' 'content=# Title\nBody text'
obsidian search 'query=search term'    # search vault
obsidian daily:read                    # read current daily note
obsidian properties 'file=Note'        # list note properties
obsidian tags                          # list all tags
obsidian tasks todo                    # list incomplete tasks
```

## References

- **Files & Folders** (create, read, append, prepend, move, rename, delete, open, list, history, diff): `references/files-and-folders.md`
- **Search & Links** (search, backlinks, outgoing links, orphans, unresolved, outline): `references/search-and-links.md`
- **Daily Notes & Templates** (daily notes, templates, random notes): `references/daily-notes-and-templates.md`
- **Properties & Tasks** (frontmatter properties, tags, tasks, aliases, wordcount): `references/properties-and-tasks.md`
- **Vaults & Bases** (vault info, vault targeting, bases): `references/vault-and-bases.md`
- **Plugins & Appearance** (plugins, restricted mode, themes, snippets): `references/plugins-and-appearance.md`
- **Sync, Tabs & Bookmarks** (sync, workspace inspection, tabs, recents, bookmarks): `references/sync-tabs-and-bookmarks.md`
- **App & Developer Commands** (command palette, hotkeys, help, version, reload/restart, dev commands): `references/app-and-developer-commands.md`

## Success Criteria

- Bare switches used (`total`, `verbose`, `open`), never `--flags`
- `file=` used for user-facing lookups, `path=` for exact paths
- `vault=` specified when operating outside the target vault's directory
- Risky mutations confirmed before execution
- Output formats (`format=json`, `format=tsv`, `format=csv`) used when parsing results programmatically
- `obsidian help <command>` checked before using commands not covered here
