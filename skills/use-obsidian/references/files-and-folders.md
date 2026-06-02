# Files & Folders

> Create, read, edit, move, and list files and folders in the vault.

## Contents

- File Targeting
- Create
- Read
- Append & Prepend
- Open
- Move & Rename
- Delete
- List Files & Folders
- File & Folder Info
- File History & Versions
- Comparing Versions

## File Targeting

| Parameter | Resolution | Use When |
|-----------|------------|----------|
| `file=` | Wikilink-style resolution (partial name, no extension) | User-facing lookups - `file=Meeting Notes` |
| `path=` | Exact vault-root-relative path | Scripting - `path=projects/2026/spec.md` |

Both parameters work on file commands. Omit both only when the active file is the intended target.

## Create

```bash
obsidian create 'name=Note Title' 'content=# Heading\nBody text'
obsidian create 'path=folder/note.md' 'content=Content here'
obsidian create 'name=From Template' 'template=Template Name'
obsidian create 'name=Replace Me' 'content=New content' overwrite
```

| Parameter | Purpose |
|-----------|---------|
| `name` | Note title (creates `name.md`) |
| `path` | Exact path from vault root |
| `content` | Note body (`\n` for newlines, `\t` for tabs) |
| `template` | Apply a template |

| Switch | Purpose |
|--------|---------|
| `overwrite` | Overwrite if file exists. Destructive - requires confirmation |
| `open` | Open after creation |
| `newtab` | Open in a new tab |

## Read

```bash
obsidian read                          # active file
obsidian read 'file=Note Name'
obsidian read 'path=folder/note.md'
```

## Append & Prepend

```bash
obsidian append 'file=Note' 'content=\n## New Section\nContent'
obsidian prepend 'file=Note' 'content=Added before existing content'
```

| Switch | Purpose |
|--------|---------|
| `inline` | Append/prepend inline (no newline separator) |
| `open` | Open after editing |

`prepend` inserts after frontmatter, preserving YAML properties.

## Open

```bash
obsidian open 'file=Note Name'
obsidian open 'path=folder/note.md'
obsidian open 'file=Note Name' newtab
```

## Move & Rename

```bash
obsidian move 'file=Old Name' 'to=new/path/note.md'
obsidian rename 'file=Old Name' 'name=New Name'
```

Both commands update internal links throughout the vault. `rename` preserves the file extension, so pass the name without `.md`.

## Delete

```bash
obsidian delete 'file=Note Name'
obsidian delete 'file=Note Name' permanent
```

Default delete moves to system trash. `permanent` skips trash and requires explicit confirmation.

## List Files & Folders

```bash
obsidian files                         # all vault files
obsidian files 'folder=subfolder'      # files in folder
obsidian files ext=md                  # filter by extension
obsidian files total                   # count only

obsidian folders                       # all folders
obsidian folders 'folder=parent'       # subfolders of parent
obsidian folder 'path=folder' info=size
```

## File & Folder Info

```bash
obsidian file                          # active file info
obsidian file 'file=Note Name'         # specific file info
obsidian folder 'path=folder' info=files
```

`folder info=` options: `files`, `folders`, `size`.

## File History & Versions

Local file recovery - view and restore previous versions.

```bash
obsidian history 'file=Note'           # list local versions
obsidian history:list                  # list files with local history
obsidian history:read 'file=Note'      # read most recent version
obsidian history:read 'file=Note' version=3
obsidian history:restore 'file=Note' version=2
obsidian history:open 'file=Note'
```

`history:restore` mutates the file and requires confirmation.

## Comparing Versions

```bash
obsidian diff 'file=Note'              # list all versions (local + sync)
obsidian diff 'file=Note' filter=local
obsidian diff 'file=Note' filter=sync
obsidian diff 'file=Note' from=1 to=3
```
