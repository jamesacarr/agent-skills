# Daily Notes & Templates

> Work with daily notes, templates, and random notes.

## Daily Notes

```bash
obsidian daily                          # open current daily note
obsidian daily paneType=tab             # open in a new tab
obsidian daily:path                     # get daily note file path
obsidian daily:read                     # read daily note contents
obsidian daily:append 'content=## Log\n- Item'
obsidian daily:prepend 'content=Top of note'
```

| Parameter | Purpose |
|-----------|---------|
| `content` | Text to append/prepend (required for append/prepend) |
| `paneType` | `tab`, `split`, or `window` |

| Switch | Purpose |
|--------|---------|
| `inline` | No newline separator |
| `open` | Open after editing |

`daily:prepend` inserts after frontmatter.

## Templates

```bash
obsidian templates                      # list available templates
obsidian templates total                # count only
obsidian template:read 'name=Template'  # read template content
obsidian template:read 'name=Template' 'title=Note Title' resolve
obsidian template:insert 'name=Template'
```

| Parameter | Purpose |
|-----------|---------|
| `name` | Template name (required) |
| `title` | Title for variable resolution |

| Switch | Purpose |
|--------|---------|
| `resolve` | Resolve template variables (date, title, etc.) |

`template:insert` mutates the active file. Confirm the active target if the user did not specify one.

## Random Notes

```bash
obsidian random                         # open random note
obsidian random 'folder=subfolder'      # random from folder
obsidian random newtab                  # open in new tab
obsidian random:read                    # read random note (includes path)
obsidian random:read 'folder=subfolder'
```

## Version-Sensitive Commands

`unique` is not exposed by `obsidian help` in Obsidian 1.12.7. If the user asks for a unique/Zettelkasten note, check `obsidian help unique` first; if absent, use `create` with a generated name only after the naming scheme is clear.
