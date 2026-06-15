# Audit a Ticket

> Check an existing ticket against structure and readiness, then report concrete fixes.

## Step 1: Obtain the ticket

Get the full current content. If the user pasted it, use that. If they gave only a ticket ID or URL, fetch it first via the matching tracker skill (use-jira, use-gh, use-glab) or ask them to paste it. Don't audit from the title alone.

## Step 2: Identify type

Story, Bug, or Spike. This determines which sections and which per-type criteria apply.

## Step 3: Check structure

Verify the expected sections for the type are present and non-empty, using the Structure Check in `references/readiness-checklist.md` and the section guidance in `references/writing-guide.md`.

## Step 4: Check readiness

Run the ticket through the INVEST, general, and per-type criteria in `references/readiness-checklist.md`. Score against the readiness verdict table.

## Step 5: Report

Use the audit output format in `readiness-checklist.md`: list passing items, then issues found (most critical first, each with a concrete fix), then a corrected description ready to apply. For vague acceptance criteria or technical notes, supply the rewritten version - not just "make it specific".

## Step 6: Apply (optional)

If the user wants the fixes applied, route to the matching tracker skill (use-jira, use-gh, use-glab) with confirmation. Otherwise hand back the corrected content for them to paste.
