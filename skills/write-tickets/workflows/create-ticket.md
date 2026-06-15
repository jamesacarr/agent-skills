# Create a Ticket

> Draft a well-structured Story, Bug, or Spike from the right template, ready to hand to a tracker.

## Step 1: Determine type

Story (new capability), Bug (defect), or Spike (timeboxed investigation). If unclear, ask. Select the template:

- Story → `templates/story.md`
- Bug → `templates/bug.md`
- Spike → `templates/spike.md`

For a type this skill doesn't cover (task, chore, epic, etc.), default to the Story template and adapt its sections, or confirm the closest fit with the user.

## Step 2: Gather inputs

Collect what each section needs (see `references/writing-guide.md`). Fill from the conversation first; ask only for what's genuinely missing. Required: Title, Type, Description. Recommended: Parent/Project, Labels.

If given only a title or one-liner, ask a single batched question covering type, the user, and the expected outcome before filling the template - don't ask field by field.

If inside a git repo, gather codebase context for Technical Notes following the tool guidance in `writing-guide.md` (Glob/Grep or `ast-grep`, not raw `find`/`grep`) - affected files, patterns to reuse, and for bugs the likely root cause. Read files before citing them; don't cite what you haven't opened.

## Step 3: Fill the template

Copy the skeleton and replace every `{placeholder}`, following the section guidance in `writing-guide.md`. For Potential Solutions, give 1-3 real options with tradeoffs, or omit the section when there's only one sensible path. Write acceptance criteria in the hybrid Given/When/Then + bullet format.

## Step 4: Check readiness

Run the draft against `references/readiness-checklist.md` (INVEST plus the per-type criteria). Close gaps before presenting. Flag anything you can't resolve (missing parent, unknown timebox) rather than inventing it. If gaps remain, mark each in the draft as `{unknown - needs input}` and ask once for all outstanding values before treating the ticket as final.

## Step 5: Present and confirm

Show the formatted ticket plus suggested field values (Title, Type, Parent/Project, Labels - see the Field Mapping table in SKILL.md). Confirm with the user before treating it as final.

## Step 6: Hand off for submission

This skill produces content; it does not submit. If the user wants it filed, route to the tracker's own skill (use-jira, use-gh, use-glab) or output the content for them to paste. Note that Jira needs conversion from Markdown to its own markup or ADF.
