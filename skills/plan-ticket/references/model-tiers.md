# Model Tiers

> Which model each role in the ticket flow runs on. Roles map to tiers; tiers map to a harness's model option in one table here, so the workflows never name a model.

## Why tiers, not models

Planning and review are where a stronger model pays: judgement about scope, structure, and evidence compounds through everything downstream. Implementing a precise plan is most of the tokens and rarely needs it. Writing `opus` into a workflow would tie the skill to one harness's aliases, which rot; a tier names the intent, and this table is the only place an alias appears.

## Tiers

| Tier | Meaning | Roles |
|------|---------|-------|
| full | The session's own model - the user chose it when they started the session | Plan author, every plan critic, the diff reviewers, and the implementer for `full` plans |
| standard | One step below the session's model | Implementer for most plans |
| light | Two steps below | Implementer for contained, low-risk plans |

Reasoning roles are always `full`, so nothing is passed for them: subagents inherit the session model unless told otherwise. The one decision is the implementer's tier, and plan-ticket makes it from the risk classification that already sizes the panel:

| Panel (SKILL.md Step 1) | `implementation_tier` | Why |
|-------------------------|-----------------------|-----|
| No critics, or pragmatist only | light | The plan is precise and the change contained; capability beyond following it goes unused |
| Two critics | standard | The plan carries the design choices; the implementer follows them |
| All critics | full | Hard to reverse; a weaker implementer's shortcut costs more than the saving, and the diff review would bounce it anyway |

Record it in plan.md frontmatter as `implementation_tier`. The user sees it at the handoff and can override it; an explicit user choice always wins over this table.

## Harness mapping

Never pass a model above the session's own. If the mapped alias isn't below the session model, or the session can't tell which model it runs, omit the override and inherit - a session already on `opus` runs `standard` work on `opus`.

| Harness | full | standard | light |
|---------|------|----------|-------|
| Claude Code - `model` option on the Agent tool or Workflow `agent()` | omit | `opus` | `sonnet` |
| Harness whose subagents take a model | omit | one alias below the session | two below |
| Harness whose subagents take no model | omit | omit - inherit, and say so in the handoff | omit - same |

Claude Code also has an `effort` option, independent of model. Leave it at the session default. The one role where lower effort is cheap and safe is the pragmatist, whose checks (paths exist, commands run) are mechanical - drop it to `low` if panel cost matters.
