# Instrumentation

> Add probes only to answer falsifiable hypotheses. Instrumentation that is not tied to a prediction creates noise and encourages guessing.

## Probe Selection

Prefer probes in this order:

1. **Debugger or REPL inspection** when the environment supports it. One breakpoint beats ten logs.
2. **Targeted logs** at boundaries that distinguish hypotheses: function inputs/outputs, service calls, database queries, queue payloads, config resolution, environment reads.
3. **Trace capture** when data crosses process boundaries: request/response bodies, headers, event messages, task payloads, query plans.

Avoid "log everything and grep". If a log line does not test a prediction, delete it or make the prediction explicit.

## Debug Log Hygiene

Tag every temporary log with a unique prefix:

```text
[DEBUG-a4f2] parsed payload
[DEBUG-a4f2] resolved config
[DEBUG-a4f2] database result
```

Use the same prefix for one investigation. Cleanup becomes a single grep:

```bash
grep -R '\[DEBUG-a4f2\]' .
```

Untagged logs survive. Tagged logs die.

## Boundary Logging

For multi-component systems, log at every boundary on one run, then analyse where the value changes before investigating why:

```text
client -> API -> service -> queue -> worker -> database
```

Capture:

- Input and output at each boundary
- Config and environment values that affect branching
- Identifiers that connect events across services
- Timestamps for ordering, using the project's timestamp convention

## Performance Regressions

For performance bugs, logs are usually the wrong first tool. Measure first, fix second.

1. Establish a baseline with a timing harness, profiler, query plan, benchmark, or production trace.
2. Re-run the same workload across old vs new versions or config A vs config B.
3. Bisect when the regression window is wide.
4. Inspect the measured slow path.
5. Fix only after the slow path is localised.

Do not optimise based on intuition. Most performance guesses target code that is not on the hot path.
