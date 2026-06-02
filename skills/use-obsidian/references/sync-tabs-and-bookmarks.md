# Sync, Tabs & Bookmarks

> Manage sync state, workspace inspection, tabs, recent files, and bookmarks.

## Sync

```bash
obsidian sync                           # show/toggle sync state if supported
obsidian sync on                        # resume sync
obsidian sync off                       # pause sync
obsidian sync:status                    # sync status and usage
obsidian sync:history                   # history for active file
obsidian sync:history 'file=Note'
obsidian sync:history 'file=Note' total
obsidian sync:read 'file=Note' version=1
obsidian sync:restore 'file=Note' version=1
obsidian sync:deleted                   # deleted files in sync
obsidian sync:deleted total
obsidian sync:open 'file=Note'          # open sync history UI
```

`sync on/off` and `sync:restore` affect synced state. Confirm first.

## Workspace, Tabs & Recent Files

```bash
obsidian workspace                      # current workspace tree
obsidian workspace ids                  # include workspace item IDs
obsidian tabs                           # list open tabs
obsidian tabs ids                       # include tab IDs
obsidian tab:open                       # new empty tab
obsidian tab:open 'file=folder/note.md' # open path in a new tab
obsidian recents                        # recently opened files
obsidian recents total
```

`workspace:save`, `workspace:load`, and `workspace:delete` are not exposed by `obsidian help` in Obsidian 1.12.7. Check `obsidian help workspace:save` before using version-specific workspace commands.

## Bookmarks

```bash
obsidian bookmarks                      # list bookmarks
obsidian bookmarks verbose              # include bookmark types
obsidian bookmarks format=json
obsidian bookmark 'file=folder/note.md'
obsidian bookmark 'file=folder/note.md' 'subpath=#heading'
obsidian bookmark 'folder=folder/path' title=Folder
obsidian bookmark 'search=tag:#project' 'title=Project Search'
obsidian bookmark 'url=https://example.com' title=Example
```

Adding bookmarks mutates app configuration. Confirm if the target or title is ambiguous.
