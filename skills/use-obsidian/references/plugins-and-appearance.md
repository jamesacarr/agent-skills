# Plugins & Appearance

> Manage plugins, themes, CSS snippets, and restricted mode.

## Plugins

```bash
obsidian plugins                        # list installed plugins
obsidian plugins filter=core            # core plugins only
obsidian plugins filter=community       # community only
obsidian plugins versions               # include versions
obsidian plugins:enabled                # enabled plugins
obsidian plugins:enabled filter=community versions
obsidian plugin id=plugin-id            # plugin details
```

Formats: `json`, `tsv`, `csv`.

## Enable, Disable, Install, Uninstall

```bash
obsidian plugin:enable id=plugin-id
obsidian plugin:disable id=plugin-id
obsidian plugin:install id=plugin-id
obsidian plugin:install id=plugin-id enable
obsidian plugin:uninstall id=plugin-id
```

Plugin changes can execute third-party code or alter vault behaviour; confirm first.

## Restricted Mode & Development Reload

```bash
obsidian plugins:restrict               # show restricted mode state
obsidian plugins:restrict on            # enable restricted mode
obsidian plugins:restrict off           # disable restricted mode
obsidian plugin:reload id=plugin-id     # reload for development
```

## Themes

```bash
obsidian themes                         # list installed themes
obsidian themes versions
obsidian theme                          # active theme info
obsidian theme 'name=Theme Name'        # theme details
obsidian theme:set 'name=Theme Name'    # set active theme
obsidian theme:install 'name=Theme Name'
obsidian theme:install 'name=Theme Name' enable
obsidian theme:uninstall 'name=Theme Name'
```

## CSS Snippets

```bash
obsidian snippets                       # list installed CSS snippets
obsidian snippets:enabled               # enabled snippets only
obsidian snippet:enable name=snippet
obsidian snippet:disable name=snippet
```

Theme and snippet changes alter the UI. Confirm first unless the user explicitly asked for the exact change.
