---
name: debug-code
description: Guides disciplined debugging with a trusted feedback loop, root-cause investigation, and regression testing. Use any time something is failing, broken, flaky, slow, or behaving unexpectedly and you are about to change code, including bugs, test failures, build failures, integration issues, and performance regressions.
---

# Debug Code

## Essential Principles

Random fixes waste time and create new bugs. Quick patches mask underlying issues; the same bug returns in a different form and the next debug session starts from scratch.

**Build a trusted feedback loop before fixing.** A fast, deterministic, agent-runnable pass/fail signal makes debugging mechanical. Without one, bisection, instrumentation, and hypothesis testing have nothing reliable to consume.

**Find root cause before attempting fixes.** You may form provisional hypotheses to build the loop, but do not propose or implement a fix until root cause is confirmed with evidence.

**Fix at the correct seam.** A regression test is useful only if it exercises the real bug pattern as it occurs at the call site. A shallow test can pass while the original bug remains.

## When to Use

Use for any technical issue: test failures, bugs, unexpected behaviour, performance problems, build failures, integration issues. Use especially when under time pressure, when "just one quick fix" seems obvious, after multiple failed fixes, or when you do not fully understand the issue.

## Steps

| Step | Key Activities | Output |
|------|---------------|--------|
| **1. Feedback Loop** | Build an agent-runnable signal, reproduce, confirm it is the user's bug | Trusted pass/fail loop |
| **2. Evidence and Pattern** | Read errors, check recent changes, compare working examples | Known facts and relevant differences |
| **3. Hypothesis and Instrumentation** | Rank falsifiable causes, test one prediction at a time | Confirmed root cause |
| **4. Implementation and Cleanup** | Regression check at the correct seam, fix, verify, remove probes | Bug resolved without debug debris |

### Step 1: Build the Feedback Loop

The feedback loop is the core asset. Spend disproportionate effort making the bug observable before reading code deeply or changing behaviour. See `references/feedback-loops.md` for loop patterns.

1. **Construct an agent-runnable signal**
   - Failing test at the correct seam: unit, integration, or end-to-end
   - Curl/HTTP script, CLI fixture, headless browser script, or captured trace replay
   - Throwaway harness that exercises the bug path with one function call
   - Property/fuzz loop, bisection harness, or old-vs-new differential loop
   - Human-in-the-loop script only as a last resort, with captured output

2. **Improve the loop itself**
   - Faster: cache setup, skip unrelated init, narrow the scope
   - Sharper: assert on the specific symptom, not merely "didn't crash"
   - More deterministic: pin time, seed randomness, isolate filesystem and network

3. **Handle non-determinism by raising the reproduction rate**

   The goal is not perfect reproduction at first; it is a high enough failure rate to debug. Loop the trigger, parallelise, add stress, narrow timing windows, inject sleeps, and capture every failure.

4. **Reproduce and confirm the symptom**

   Do not proceed until the loop produces the failure mode the user described, reproduces reliably enough to debug, and captures the exact symptom: error message, wrong output, timing, or logs. Wrong bug means wrong fix.

5. **When you cannot build a loop**

   Stop and say so explicitly. List what you tried. Ask the user for access to the reproducing environment, a captured artefact, or permission to add temporary instrumentation. Do not fix without a trusted verification loop.

### Step 2: Gather Evidence and Analyse Patterns

Compare the broken case to known-good behaviour before fixing.

1. **Read error messages carefully**
   - Read stack traces completely
   - Note line numbers, file paths, error codes, warnings, and logs

2. **Check recent changes**
   - `git diff`, `git log`, recent commits
   - `git bisect` if the regression window is wide. See `references/bisection.md`.
   - New dependencies, config changes, environmental differences

3. **Find working examples**
   - Locate similar working code in the same codebase, or a reference implementation if none exists in-tree
   - Read references completely. Partial understanding guarantees bugs.

4. **Identify differences**
   - List every difference between working and broken, however small
   - Note required components, settings, config, data shape, timing, and environment

### Step 3: Form Hypotheses and Instrument Deliberately

Instrumentation should answer a specific question. Random logs create noise and encourage guesswork. See `references/instrumentation.md` for probe selection and performance debugging.

1. **Enumerate hypotheses before testing**

   List at least three plausible causes with likelihood (high/medium/low), reasoning, and evidence that would confirm or reject each. Single-hypothesis debugging anchors on the first plausible idea. Use falsifiable predictions:

   ```text
   If <cause> is true, then <probe or change> will make <observable symptom> disappear, appear, or get worse.
   ```

   If you cannot state the prediction, the hypothesis is a vibe. Sharpen or discard it.

2. **Test one hypothesis at a time**
   - Start with the highest-likelihood or cheapest-to-test hypothesis
   - Change one variable at a time
   - Map every probe to a prediction from the hypothesis list
   - Do not stack fixes or probes that make the result impossible to interpret

3. **Choose the right probe**
   - Prefer debugger or REPL inspection when available
   - Use targeted logs at boundaries that distinguish hypotheses
   - Tag temporary logs with a unique prefix such as `[DEBUG-a4f2]` so cleanup is grepable
   - Never "log everything and grep"

4. **Trace the cause**
   - **Call-chain tracing** for errors deep in the stack or unclear data origin. See `references/root-cause-tracing.md`.
   - **5-whys** for recurring bugs, systemic failures, or "why did this ship?" questions where the cause is not purely in code. See `references/5-whys.md`.
   - Both can apply: use call-chain tracing to find the immediate technical trigger, then 5-whys to find why the trigger went unguarded.

5. **Verify before continuing**
   - Confirmed: move to Step 4
   - Rejected: update the hypothesis list and pick the next one
   - Inconclusive: gather more evidence before choosing the next hypothesis
   - Unknown: say "I don't understand X" rather than pretending

### Step 4: Implement, Verify, and Clean Up

Fix the root cause, not the symptom.

1. **Create a failing regression check before the fix**

   Use the correct seam: the test or harness must exercise the real bug pattern as it occurs. If no correct seam exists, document that finding; the architecture is preventing the bug from being locked down.

   Examples: failing test for correctness, benchmark or regression threshold for performance, stress loop for intermittent bugs. For test-first process, see `../test-driven-development/SKILL.md`.

2. **Implement a single fix**
   - One change addressing the confirmed root cause
   - No "while I'm here" improvements
   - No bundled refactors unless required to make the root-cause fix possible

3. **Verify against both signals**
   - Regression check fails before the fix and passes after it
   - Original Step 1 loop no longer reproduces the bug
   - No other relevant tests or checks are broken

4. **Clean up**
   - Remove debug instrumentation and grep for `[DEBUG-...]`
   - Delete throwaway harnesses, or move them to a clearly named debug location if they remain useful
   - State the confirmed root cause in the commit or PR message so the next debugger learns from it

5. **If the fix does not work**
   - Count fixes attempted. If fewer than 3, return to Step 1 or Step 3 with the new information.
   - If 3 or more fixes have failed, stop and question the architecture before attempting another fix. Repeated fixes that reveal shared state, coupling, large refactors, or new symptoms usually mean the pattern is wrong. Run 5-whys on "why does this keep happening?" (see `references/5-whys.md`) and discuss with the user.

6. **If no root cause is found after full investigation**

   If the issue is truly environmental, timing-dependent, or external, document what you investigated, implement appropriate handling, and add monitoring or logging. Most "no root cause" cases are incomplete investigation.

## Course-Correction Signals

Specific user phrasing usually means the investigation has gone off-track. Treat each as a signal to stop proposing fixes and return to Step 1:

| User says | Likely meaning |
|-----------|---------------|
| "Is that not happening?" | You asserted behaviour without verifying |
| "Will it show us...?" | You should have gathered evidence before proposing a fix |
| "Stop guessing" | You're proposing fixes without understanding |
| "We're stuck?" (frustrated) | Your current approach is not working |

**Self-triggered signal:** after every step, briefly state what was confirmed, what was ruled out, and what's next. If the investigation has gone 10+ tool calls without a confirmed hypothesis, pause and summarise to the user before continuing; you're likely tunnel-visioning or missing evidence.

## Anti-Patterns

If you catch yourself thinking any of these, stop and return to Step 1:

| Excuse | Reality |
|--------|---------|
| "Quick fix for now" / "Emergency, no time for process" | Systematic investigation is faster than guess-and-check thrashing. |
| "Just try changing X and see" | First fix sets the pattern. Do it right from the start. |
| "Skip the test, I'll manually verify" | Untested fixes don't stick. A failing check first proves the fix addresses the real cause. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read references completely. |
| "I can see the bug, no investigation needed" | You see the symptom, not all callers, edge cases, or recent changes. |
| "I don't fully understand but this might work" | Untested guesses mask the real cause. Name what you don't understand. |
| "User explicitly told me to skip investigation" | User is in pain, not debugging. Your job is root cause, not compliance with panic. |
| "One more fix attempt" after 2+ failures | 3+ failures means architectural problem. Question the pattern. |

## Success Criteria

- Trusted feedback loop built before fixing
- Failure reproduced and confirmed as the user's bug
- Root cause identified with evidence before any fix proposed
- Multiple falsifiable hypotheses enumerated and tested one at a time
- Regression check created at the correct seam before implementing the fix, or absence of seam documented
- Original reproduction loop passes after the fix
- Debug instrumentation and throwaway probes cleaned up
- No bundled "while I'm here" changes
- 3+ failed fixes triggers architectural discussion with user

## References

- `references/feedback-loops.md` - Build and improve trusted reproduction loops
- `references/instrumentation.md` - Choose probes, tag debug logs, and measure performance regressions
- `references/root-cause-tracing.md` - Trace bugs backward through the call stack to find the original trigger
- `references/5-whys.md` - Ask why repeatedly to find systemic/procedural root cause
- `references/bisection.md` - Binary-search commits, tests, or inputs to isolate a bug
- `references/defense-in-depth.md` - Add validation at multiple layers after finding root cause
- `references/condition-based-waiting.md` - Replace arbitrary timeouts with condition polling
- `scripts/find-polluter.sh` - Bisect test files to find which test creates unwanted state
