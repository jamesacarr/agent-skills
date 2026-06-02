# Feedback Loops

> Build a fast, deterministic, agent-runnable signal for the bug. The loop is the asset that bisection, hypothesis testing, instrumentation, and verification all consume.

## Loop Patterns

Try these in roughly this order. Prefer the narrowest loop that still reaches the real bug.

| Pattern | Use When |
|---------|----------|
| Failing test | A unit, integration, or e2e seam reaches the bug |
| Curl / HTTP script | The bug is exposed by a running service endpoint |
| CLI fixture | A command with stable input can produce wrong stdout, stderr, exit code, or output files |
| Headless browser script | The failure is in UI, DOM, console, routing, or network behaviour |
| Captured trace replay | Real request, HAR, payload, event log, or queue message can be replayed |
| Throwaway harness | One function or service can be exercised with mocked or minimal dependencies |
| Property / fuzz loop | Output is sometimes wrong across many input shapes |
| Bisection harness | The bug appeared between commits, datasets, versions, or configs |
| Differential loop | Old vs new version, config A vs config B, or implementation A vs implementation B differs |
| Human-in-the-loop script | A human must click or observe, but the prompt and captured output can be structured |

## Improve the Loop

Treat the loop as a product. Before deeper investigation, ask:

- **Can it be faster?** Cache setup, skip unrelated initialisation, narrow the test scope.
- **Can the signal be sharper?** Assert the specific symptom instead of "did not crash".
- **Can it be more deterministic?** Pin time, seed randomness, isolate filesystem, freeze or fake network.

A flaky 30-second loop is barely better than no loop. A deterministic 2-second loop is a debugging superpower.

## Non-Deterministic Bugs

The goal is not an immediate clean reproduction; it is a higher reproduction rate. Loop the trigger 100 times, parallelise, add stress, narrow timing windows, inject sleeps, and capture every failure.

A 50% flake is debuggable. A 1% flake usually is not. Keep raising the rate until the signal is useful.

## If No Loop Can Be Built

Stop and say so explicitly. List what you tried. Ask the user for one of:

- Access to the environment that reproduces it
- Captured artefact: HAR file, log dump, core dump, payload, queue message, database snapshot, screen recording with timestamps
- Permission to add temporary instrumentation to the relevant environment

Do not fix without a trusted verification loop. You may use provisional hypotheses to decide what artefact or access to request, but label them provisional.
