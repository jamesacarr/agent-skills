# Skill Structure

> Structural components of an Agent Skill: YAML frontmatter, Markdown body with standardised headings, and progressive disclosure via file organisation. Follows the [Agent Skills standard](https://agentskills.io/specification).

## YAML Frontmatter

**Required fields:**
```yaml
---
name: skill-name-here
description: What it does and when to use it (third person, specific triggers)
---
```

**Name rules:**
- 1–64 characters
- Lowercase letters, numbers, hyphens only
- No leading/trailing hyphens, no consecutive hyphens
- Must match parent directory name

**Description format:** `"<Capability statement>. Use when <trigger conditions>."` — always include both halves.
- GOOD: `"Extracts text and tables from PDF files. Use when working with PDF documents."`
- BAD: `"Use when working with PDFs"` (missing capability)
- BAD: `"Helps with PDFs"` (missing trigger)

Max 1024 characters. Third person. Description = triggering conditions, NOT workflow summary — the agent may follow the description instead of reading the full skill.

**Undertriggering:** Models tend to *not* invoke skills when they should. Make descriptions slightly pushy — include related terms and contexts a user might mention, even if not an exact match. For example, instead of `"Builds dashboards for internal data"`, write `"Builds dashboards for internal data. Use when the user mentions dashboards, data visualisation, internal metrics, or wants to display any kind of data, even if they don't explicitly ask for a 'dashboard'."`

**Optional fields:**

| Field | Purpose |
|-------|---------|
| `license` | License name or reference to bundled file |
| `compatibility` | Environment requirements (max 500 chars) |
| `metadata` | Arbitrary key-value mapping |
| `allowed-tools` | Space-delimited list of pre-approved tools |
| `disable-model-invocation` | When `true`, skill hidden from system prompt — users must use `/skill:name` |

## Negative Triggers

Use `"Do NOT use for..."` in descriptions to prevent mis-routing between related skills:

```yaml
description: Manages GitLab merge requests. Use when creating MRs or posting comments. Do NOT use for Jira tickets (use jira).
```

Add when: two skills share overlapping trigger words, or users frequently invoke the wrong skill.

## Body Structure

Use **Markdown headings only** — no XML tags. Standardised heading names:

| Concept | Heading | NOT |
|---------|---------|-----|
| What not to do | `## Anti-Patterns` | `## Red Flags`, `## Common Mistakes` |
| Usage guidance | `## When to Use` | `## Usage`, `## Applicability` |
| Related skills | `## Related Skills` | ad hoc prose |
| Sequential actions | `## Step N: Title` inside workflow | `## Phase 1`, `## Phase: Name` |
| Core rules | `## Essential Principles` | `## Rules`, `## Guidelines` |
| User menu | `## Intake` | `## Options`, `## Menu` |
| Route mapping | `## Routing` | `## Dispatch`, `## Navigation` |

## Router Pattern

For complex skills with multiple workflows:

```
skill-name/
├── SKILL.md              # Router + essential principles (~100 lines)
├── workflows/            # Step-by-step procedures
│   ├── workflow-a.md
│   └── workflow-b.md
├── references/           # Domain knowledge
│   └── topic.md
└── templates/            # Output structures (optional)
    └── template.md
```

**Use when:** Multiple distinct workflows, different refs per workflow, essential principles that can't be skipped, skill beyond 200 lines.

## File Conventions

- Workflows and references start with `# Title` + `> blockquote summary`
- SKILL.md does NOT use a blockquote summary — the YAML description serves as the summary
- References one level deep from SKILL.md (no nesting)
- Forward slashes for all paths
- SKILL.md routes, doesn't re-teach workflow content

## Skill Placement

| Location | Use When |
|----------|----------|
| Global skills directory: `~/.agents/skills/` (or harness-specific, e.g. `~/.claude/skills/`, `~/.pi/agent/skills/`) | Reusable across projects, personal preference |
| Project skills directory: `.agents/skills/` (or harness-specific, e.g. `.claude/skills/`, `.pi/skills/`) | Project-specific, committed to version control |
| Settings `skills` array | Custom locations |

Global and project skills with the same name: first found wins (warns on collision).

## Progressive Disclosure

SKILL.md = overview; reference files = details. The agent loads refs only when needed. Keep SKILL.md under ~100 lines for router pattern skills. Add a TOC to references over 100 lines.
