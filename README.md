# Agent Skills

A public collection of shareable agent skills for coding and knowledge-work agents.

The skills are mostly written for personal use, but the goal is for them to be portable across agent harnesses such as Claude Code, Codex, Pi, and similar systems that can load skill directories or prompt files.

## What is in this repo

Each skill lives under `skills/<skill-name>/` and has a `SKILL.md` file with YAML frontmatter plus Markdown instructions. Larger skills may include:

- `workflows/` for step-by-step procedures
- `references/` for supporting domain details
- `scripts/` for validation or helper scripts
- `templates/` for output structures

Current skills:

| Skill | Purpose |
|-------|---------|
| `author-skill` | Create, edit, audit, and upgrade Agent Skills that follow the agentskills.io spec |
| `debug-code` | Disciplined debugging with feedback loops, root-cause investigation, and regression tests |
| `implement-ticket` | Implement a ticket end to end, in the current session or in a dedicated agent spawned in a Herdr tab |
| `merge-ticket` | Merge a ticket's MRs/PRs once CI is green and review comments are addressed, then clean up and close the ticket |
| `obsidian-markdown` | Obsidian-flavoured Markdown syntax: wikilinks, embeds, callouts, properties, tags |
| `obsidian-wiki` | Personal Obsidian wiki workflows: ingest, query, and lint |
| `plan-ticket` | Implementation plans for tickets: persisted plan.md, MR-stack design, risk-sized scoped-critic review loop |
| `spawn-agent` | Start a named Claude Code, Codex, or pi session in a new Herdr tab, optionally on a specific model |
| `test` | Test quality guidance: behavioural assertions, minimal mocking, descriptive naming |
| `test-driven-development` | RED-GREEN-REFACTOR process discipline |
| `upgrade-dependencies` | Safe, atomic JavaScript dependency upgrades |
| `use-defuddle` | Clean web-content extraction with the `defuddle` CLI |
| `use-gcx` | Grafana and Grafana Cloud resources, queries, and alerting via `gcx` |
| `use-gh` | GitHub PRs, issues, comments, reviews, and CI via `gh` |
| `use-glab` | GitLab merge requests and comments via `glab` |
| `use-jira` | Jira issues, epics, sprints, and boards via `jira` |
| `use-obsidian` | Obsidian vault operations via the native `obsidian` CLI |
| `write-tickets` | Consistently structured, ready-for-development tickets (Stories, Bugs, Spikes) for any tracker |

## Installing a skill

If your harness supports the Agent Skills installer, install a single skill with:

```bash
npx skills add jamesacarr/agent-skills --skill debug-code
```

Replace `debug-code` with any directory name under `skills/`.

For harnesses without installer support, copy or symlink the relevant skill directory into your agent harness's configured skills location:

```bash
cp -R skills/debug-code /path/to/your/agent/skills/
```

Some harnesses load skills from a global directory, while others load them from a project directory. Check your harness documentation for the exact location and reload behaviour.

## Portability conventions

These skills are written to avoid depending on a single harness where possible.

- Tool-specific skills name their required CLI explicitly, such as `gh`, `glab`, `jira`, `gcx`, `obsidian`, or `defuddle`, and gate on its availability.
- Harness-specific tools are described generically first, then mapped where useful. For example, a web fallback may be described as the available web fetch/extract tool, with `web_extract` for Pi and `WebFetch` for Claude Code.
- Shell examples are illustrative. Adapt quoting and tool invocation to the harness and shell you are using.
- Some skills encode personal preferences or local conventions. Read the skill before using it in a shared or production context.

## Personal assumptions

A few skills are intentionally personal:

- `obsidian-wiki` assumes an Obsidian vault named `wiki` and conventions that match James Carr's personal knowledge base.
- `spawn-agent` only works inside Herdr, a terminal multiplexer for coding agents (`HERDR_ENV=1`, with the `herdr` and `jq` CLIs available). `implement-ticket` and `merge-ticket` use Herdr for their spawn and remote modes but fall back to running in the current session outside it.
- `implement-ticket` and `merge-ticket` assume a ticket tracker CLI (e.g. Jira via `jira`, GitHub issues via `gh`) and a Git worktree-per-ticket layout.
- Workflow skills such as `debug-code`, `test`, `test-driven-development`, and `plan-ticket` encode strong preferences about engineering process (`plan-ticket` includes a default ~300-production-line MR size cap).
- CLI skills may assume authenticated local CLIs and non-interactive usage.

Fork or copy these skills before changing assumptions that are specific to your environment.

## Validating skills

Some skills include validation scripts under `scripts/`. There is no aggregator; run each one on its own.

```bash
skills/use-obsidian/scripts/validate-examples.py
skills/obsidian-markdown/scripts/validate-skill.py
skills/obsidian-wiki/scripts/validate-examples.py
```

Run these after editing the relevant skill. They are intentionally lightweight and only check local consistency, not full behavioural correctness.

Other `scripts/` directories hold runtime helpers the skill calls rather than validators (for example `debug-code/scripts/find-polluter.sh` and the Herdr dispatch scripts in `spawn-agent`, `implement-ticket`, and `merge-ticket`).

## Contributing

This repo is public, but it is primarily a personal skill library. Contributions are welcome if they preserve portability and keep the skills concise. The `author-skill` skill is the source of truth for structure and style; read it before adding or substantially editing a skill.

Good changes:

- Fix incorrect CLI syntax or stale commands
- Improve portability across harnesses
- Add validation for examples
- Clarify instructions that are ambiguous in real use

Avoid changes that:

- Make a generic skill depend on one harness without an adapter note
- Add broad process rules that only apply to one project
- Inflate `SKILL.md` when details can live in `references/`, `workflows/`, or `templates/`

## License

MIT. See `LICENSE`.
