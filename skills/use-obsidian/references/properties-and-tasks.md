# Properties & Tasks

> Manage frontmatter properties, tags, tasks, aliases, and word counts.

## Contents

- Properties
- Set Property
- Read & Remove
- Tags
- Aliases
- Tasks
- Update Task
- Word Count

## Properties

```bash
obsidian properties                     # list all vault properties
obsidian properties 'file=Note'         # properties of specific note
obsidian properties name=status         # count notes with property
obsidian properties active              # properties of active file
obsidian properties format=yaml         # output as YAML
obsidian properties counts              # include usage counts
obsidian properties sort=count          # sort by frequency
```

Formats: `yaml`, `json`, `tsv`. Switches: `total`, `counts`, `active`.

## Set Property

```bash
obsidian property:set name=status value=draft 'file=Note'
obsidian property:set name=tags value=project,active type=list 'file=Note'
obsidian property:set name=priority value=1 type=number 'file=Note'
obsidian property:set name=done value=true type=checkbox 'file=Note'
```

| Type | Example Values |
|------|----------------|
| `text` | `draft` (default) |
| `list` | `item1,item2` |
| `number` | `42` |
| `checkbox` | `true`, `false` |
| `date` | `2026-04-07` |
| `datetime` | `2026-04-07T10:00:00` |

## Read & Remove

```bash
obsidian property:read name=status 'file=Note'
obsidian property:remove name=status 'file=Note'
```

`property:set` and `property:remove` mutate frontmatter. Confirm if the target or value is ambiguous.

## Tags

```bash
obsidian tags                           # list all vault tags
obsidian tags 'file=Note'               # tags in specific note
obsidian tags active                    # tags in active file
obsidian tags counts                    # include usage counts
obsidian tags sort=count                # sort by frequency
obsidian tag name=project               # tag info and usage
obsidian tag name=project total         # count notes with tag
obsidian tag name=project verbose       # list files with tag
```

Formats: `json`, `tsv`, `csv`.

## Aliases

```bash
obsidian aliases                        # list all aliases
obsidian aliases active                 # aliases of active file
obsidian aliases total                  # count
obsidian aliases verbose                # include source files
```

## Tasks

```bash
obsidian tasks                          # list all tasks
obsidian tasks todo                     # incomplete only
obsidian tasks done                     # completed only
obsidian tasks 'file=Note'              # tasks in specific note
obsidian tasks active                   # tasks in active file
obsidian tasks daily                    # tasks in daily note
obsidian tasks 'status=x'               # filter by status character
obsidian tasks format=json
```

Formats: `json`, `tsv`, `csv`, `text`. Switches: `total`, `verbose`, `active`, `daily`, `done`, `todo`.

## Update Task

```bash
obsidian task 'ref=folder/note.md:15'       # show task details
obsidian task 'file=Note' line=15 toggle    # toggle completion
obsidian task 'file=Note' line=15 done      # mark complete
obsidian task 'file=Note' line=15 todo      # mark incomplete
obsidian task 'file=Note' line=15 'status=/'
```

`ref` comes from task list output. `line` is the 1-based line number in the file. Updating a task mutates the note.

## Word Count

```bash
obsidian wordcount                      # active file
obsidian wordcount 'file=Note'
obsidian wordcount words                # words only
obsidian wordcount characters           # characters only
```
