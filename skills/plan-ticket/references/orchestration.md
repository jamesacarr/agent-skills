# Running the Critic Panel

> One review round = all panel critics in parallel, each returning structured findings; the main session revises and decides re-runs. Generic pattern first, then harness mappings.

## Pattern

The main session authors and revises the plan - it holds the conversation context and can ask the user questions; critics cannot. Each round:

1. Build one prompt per critic: its brief from critic-scopes.md verbatim, the plan path, the ticket summary, the severity definitions, and the instruction to report only in-scope findings.
2. Run the critics **in parallel** - they are independent by construction, and serialising them wastes wall-clock without adding information.
3. Collect findings, apply the gate (workflow Step 6), revise in the main session, and re-run the round if any High was found.

Re-runs are fresh invocations on the updated plan. Never resume or reuse a previous round's run - the prompts are identical, so cached results would replay stale reviews of the old plan.

## Claude Code: Workflow tool

Preferred when available - deterministic fan-out with schema-validated findings. Pass `args` as real JSON values, not a JSON-encoded string (a stringified object arrives as one string and every field reads as undefined).

```js
export const meta = {
  name: 'plan-review',
  description: 'Scoped-critic review of a plan document',
  phases: [{ title: 'Review' }],
}
const FINDINGS = {
  type: 'object',
  required: ['findings'],
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['severity', 'section', 'finding', 'why'],
        properties: {
          severity: { enum: ['High', 'Medium', 'Low'] },
          section: { type: 'string' },
          finding: { type: 'string' },
          why: { type: 'string' },
        },
      },
    },
  },
}
phase('Review')
const reviews = await parallel(args.critics.map(c => () =>
  agent(
    `You are the ${c.name} critic reviewing an implementation plan.\n\n${c.brief}\n\n` +
    `Read ${args.planPath}, then verify its claims against the repo before judging.\n` +
    `Ticket: ${args.ticket}\n\n` +
    `Report only findings inside your scope. Severity: High = plan as written fails, fixes ` +
    `the wrong thing, or creates an outsized hazard; Medium = material improvement; Low = polish. ` +
    `Every finding needs a why grounded in the plan or the code.`,
    { label: `critic:${c.name}`, schema: FINDINGS },
  )))
const findings = reviews.flatMap((r, i) =>
  r ? r.findings.map(f => ({ critic: args.critics[i].name, ...f })) : [])
return { findings, high: findings.filter(f => f.severity === 'High').length }
```

Invoke with:

```js
Workflow({
  script: <above>,
  args: {
    planPath: '.planning/KEY-123/plan.md',
    ticket: 'KEY-123: <one-line summary>',
    critics: [{ name: 'pragmatist', brief: '<full brief from critic-scopes.md>' }, ...],
  },
})
```

## Other harnesses: parallel subagents

Spawn one read-only subagent per critic in a single message so they run concurrently. Give each the same prompt content as above and ask it to return its findings as a Markdown table with the four columns; parse and apply the same gate. A panel of one does not need orchestration - a single subagent call is enough.

## No subagent support

Degrade to sequential self-review: adopt each critic brief in turn and review the plan in a separate pass per scope. Weaker than independent critics (one context, shared blind spots) - say so in the handoff report.
