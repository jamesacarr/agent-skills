# Vaults & Bases

> Target vaults and work with Obsidian Bases.

## Vaults

```bash
obsidian vault                          # current vault info
obsidian vault info=name                # vault name only
obsidian vault info=path                # vault path
obsidian vault info=files               # file count
obsidian vault info=folders             # folder count
obsidian vault info=size                # vault size
obsidian vaults                         # list known vaults
obsidian vaults total
obsidian vaults verbose                 # include paths
```

Prefix any command with `vault=<name>` or `vault=<id>` when the target vault matters:

```bash
obsidian 'vault=Work' files
obsidian 'vault=Personal' daily:read
```

## Bases

Obsidian Bases are structured data views (`.base` files) within the vault.

```bash
obsidian bases                          # list all .base files
obsidian base:views                     # list views in current base
obsidian base:create 'file=My Base' name=Item 'content=field content'
obsidian base:create 'file=My Base' 'view=View Name' name=Item
obsidian base:query 'file=My Base' format=json
obsidian base:query 'file=My Base' format=csv
obsidian base:query 'file=My Base' format=md
obsidian base:query 'file=My Base' format=paths
```

| Parameter | Purpose |
|-----------|---------|
| `file` / `path` | Target base file |
| `view` | Target view within the base |
| `name` | Item name for creation |
| `content` | Item content |
| `format` | `json`, `csv`, `tsv`, `md`, or `paths` |

Switches for `base:create`: `open`, `newtab`. `base:create` creates a file, so confirm when target, content, or view is ambiguous.
