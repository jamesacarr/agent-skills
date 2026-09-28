# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A public library of portable **Agent Skills** (per the [agentskills.io](https://agentskills.io/specification) standard). There is no build system, no package manager, and no CI. The "code" is Markdown instructions plus a few standalone validation scripts. Skills are authored to be portable across harnesses (Claude Code, Codex, Pi), so avoid baking in a single harness's tool names without an adapter note.

## Layout

Each skill is a directory under `skills/<skill-name>/` containing a `SKILL.md` with YAML frontmatter + Markdown body. Larger skills add:

- `workflows/` — step-by-step procedures (router pattern)
- `references/` — domain detail loaded on demand
- `scripts/` — validation/helper scripts
- `templates/` — output structures

## Validating skills

Validation scripts are per-skill and run individually — there is no aggregator. Run the relevant one after editing a skill:

```bash
skills/obsidian-markdown/scripts/validate-skill.py
skills/use-obsidian/scripts/validate-examples.py
skills/obsidian-wiki/scripts/validate-examples.py
```

They are lightweight: they check local structural consistency (required snippets present, fenced blocks balanced, referenced files exist), not behavioural correctness.

The other `scripts/` files are runtime helpers the skill invokes, not validators: `debug-code/scripts/find-polluter.sh` and the Herdr dispatch scripts in `spawn-agent`, `implement-ticket`, and `merge-ticket`. Their SKILL.md documents each script's flags, JSON output, and exit codes. Change a script's contract and update that table in the same edit.

## Authoring conventions

The `author-skill` skill is the source of truth for how skills here are written; read it (and its `references/`) before creating or substantially editing a skill. Key rules:

- **SKILL.md is always loaded** — keep it lean (router skills ~100 lines). Push detail into `workflows/` and `references/`.
- **Pure Markdown, no XML tags.** Use the standardised headings: `## Essential Principles`, `## When to Use`, `## Anti-Patterns`, `## Related Skills`, and for router skills `## Intake` + `## Routing`.
- **Frontmatter:** `name` (lowercase/hyphens, must match the directory name) and `description` are required. The description must state both capability and trigger: `"<Capability>. Use when <triggers>."` Add `"Do NOT use for..."` negative triggers when skills have overlapping trigger words. Optional fields include `compatibility` (CLI/harness requirements).
- **Write for understanding** — explain *why*, not just *what*; escalate to mandate language only when reasoning fails in testing.
- Workflows/references start with `# Title` + a `> blockquote` summary; SKILL.md does not (its YAML description serves that role).

## Two skill shapes

- **Simple skill:** a single `SKILL.md` (e.g. `test-driven-development`, `use-defuddle`, `use-gh`).
- **Router pattern:** `SKILL.md` routes via an `## Intake` menu + `## Routing` table to `workflows/` files, with shared detail in `references/` (e.g. `author-skill`, `obsidian-wiki`, `upgrade-dependencies`, `write-tickets`). Use when there are multiple distinct workflows or the skill exceeds ~200 lines.

## Portability notes

- Tool skills name their required CLI explicitly (`gh`, `glab`, `jira`, `gcx`, `obsidian`, `defuddle`) and gate on availability (`command -v <cli>`).
- `spawn-agent`, `implement-ticket`, and `merge-ticket` depend on Herdr (a terminal multiplexer for coding agents). `spawn-agent` requires it outright; the ticket skills use it for spawn/remote modes and fall back to the current session otherwise. The gate is `HERDR_ENV=1`, checked in each skill's script alongside the `herdr` and `jq` CLIs.
- Harness-specific tools are described generically first, then mapped (e.g. web fetch/extract described abstractly, then `web_extract` for Pi / `WebFetch` for Claude Code).
- Some skills encode personal conventions (notably `obsidian-wiki`, which assumes a vault named `wiki`). Fork before changing environment-specific assumptions.
