# App & Developer Commands

> Run command palette actions, inspect hotkeys, use general app controls, and access developer commands.

## Command Palette

Execute an Obsidian command by ID when no dedicated CLI command exists. This changes app state, so confirm first unless the user explicitly asked for the exact command.

```bash
obsidian commands                       # list all command IDs
obsidian commands filter=editor         # filter by ID prefix
obsidian command id=editor:toggle-bold  # execute command by ID
```

## Hotkeys

```bash
obsidian hotkeys                        # list hotkeys
obsidian hotkeys total                  # count only
obsidian hotkeys verbose                # show custom/default source
obsidian hotkeys all                    # include commands without hotkeys
obsidian hotkeys format=json
obsidian hotkey id=editor:toggle-bold
obsidian hotkey id=editor:toggle-bold verbose
```

Formats: `json`, `tsv`, `csv`.

## General

```bash
obsidian help                           # list commands
obsidian help search                    # help for one command
obsidian version                        # Obsidian version
obsidian reload                         # reload app window
obsidian restart                        # restart application
```

Confirm before `reload` or `restart` because they interrupt the user's current session.

## Developer Commands

Developer commands inspect or control the Electron app. Prefer read-only inspection unless the user explicitly requests debugging or automation.

```bash
obsidian devtools                       # toggle Electron dev tools
obsidian dev:debug on                   # attach CDP debugger
obsidian dev:debug off                  # detach CDP debugger
obsidian dev:dom 'selector=.workspace' total
obsidian dev:dom 'selector=.view-header-title' text
obsidian dev:css 'selector=.workspace' prop=color
obsidian dev:console level=error limit=20
obsidian dev:errors
obsidian dev:screenshot 'path=/tmp/obsidian.png'
obsidian dev:mobile on
obsidian dev:mobile off
obsidian dev:cdp method=Runtime.evaluate 'params={"expression":"document.title"}'
obsidian eval 'code=app.vault.getName()'
```

Confirm before `dev:cdp`, `eval`, `dev:mobile`, or any developer command that changes app state.

## Version-Sensitive Commands

If a user asks for publish, unique notes, or workspace save/load/delete, run `obsidian help <command>` first. If the command is absent, say the installed CLI does not expose it and use an Obsidian command ID only after confirming the exact action.
