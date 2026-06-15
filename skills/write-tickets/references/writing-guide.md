# Writing Guide

> Section-by-section guidance for writing well-structured ticket descriptions. Template skeletons live in `templates/` - copy one and fill the `{placeholders}` using this guide.

## User Statement

Frame the work from the user's perspective, even for technical work.

- Use "As a {user type}, I want to... so that...".
- Be specific about the user type (developer, admin, end user).
- Examples:
  - "As a user, I want to log out from the header so that I can securely end my session from any page."
  - "As a developer, I want typed API responses so that I catch errors at compile time."

## Background

Provide context for why the work matters: links to discussions and threads, historical context, business justification, user feedback, specs. Do not repeat the User Statement, and keep implementation detail out - that belongs in Technical Notes. Add design links (Figma, mockups, prototypes) here or as attachments.

## Technical Notes

Guide implementation with specifics: components and files to modify, existing utilities or patterns to reuse, APIs involved, known constraints. Avoid vague guidance like "update the component"; equally, don't over-specify - leave room for developer judgement.

**When inside a git repo**, gather concrete context so the implementer has a starting point:

1. Find affected files and existing patterns for similar functionality (Glob/Grep, or `ast-grep` for structural search - prefer these over raw `find`/`grep`).
2. Note utilities, hooks, types, or services to reuse, and where tests for similar features live.
3. For bugs, trace from symptom to likely root cause and cite `file:line`.

Read files before citing them - if you haven't opened it, don't reference it. Note unknowns honestly ("pattern TBD") rather than inventing detail.

Before/after:

```markdown
# Vague
- Add logout button to header

# With codebase context
- Add logout button to `src/components/Header/HeaderNav.tsx`
- Use the existing `useAuth()` hook for logout (`src/hooks/useAuth.ts:23`)
- Clear tokens via `clearSession()` (`src/utils/auth.ts`)
- Add tests alongside `src/components/Header/__tests__/HeaderNav.test.tsx`
```

## Reproduction Steps (Bugs only)

Enable anyone to reproduce the defect: environment (browser, OS, version), preconditions, numbered steps, then expected vs actual behaviour.

```markdown
## Reproduction Steps
**Environment**: Chrome 120, macOS 14.2, Production

1. Log in as a standard user
2. Navigate to Settings > Profile
3. Click "Change Password" and enter the current password incorrectly
4. **Expected**: Error message appears below the field
5. **Actual**: Page refreshes with no feedback
```

## Potential Solutions

Suggest approaches without being prescriptive. Include this section only when there's a real choice to make.

- 1-3 options maximum; each a genuine alternative with a different tradeoff.
- Keep them accessible to non-engineers - stakeholders decide direction, so a PM should be able to follow the tradeoffs.
- Base them on existing patterns when in a repo.
- **Stories**: alternative features or UX approaches.
- **Bugs**: scope choices (minimal fix vs fix + harden vs fix + audit). The root cause itself goes in Technical Notes.
- Anti-pattern: "fix the bug" is not an option - it's not a choice.

## Acceptance Criteria

Define what "done" looks like. Mix Given/When/Then scenarios and plain bullets in one list - no subheadings.

**Decision rule**: use Given/When/Then when a precondition changes the expected outcome (different starting state → different result). Use a plain bullet when the criterion holds regardless of state (always visible, always present).

- Each criterion independently verifiable; be specific, not "works correctly".
- Behavioural criteria first, then static and non-functional requirements; don't forget edge cases.

```markdown
## Acceptance Criteria
- Given I am authenticated, When I click logout, Then my session clears and I'm redirected to login
- Given I am not authenticated, When I view the header, Then no logout button is visible
- The logout button reuses the existing `IconButton` component
- Works on mobile viewport (≥320px width)
- Regression test covers the logout flow
```

Anti-patterns: wrapping a stateless fact in Given/When/Then ("Given the page loads, When I look, Then the logo is visible" → use a bullet); using a bare bullet for state-dependent behaviour ("error shows on invalid input" → specify which input and which error with Given/When/Then).

## Spike Sections (Spikes only)

- **Objective**: 1-2 sentences on what the spike will learn or decide.
- **Spike Scope**: In Scope (questions to answer, approaches to evaluate) and Out of Scope (adjacent concerns explicitly deferred - prevents scope creep).
- **Timebox**: an explicit duration. Open-ended spikes are not ready.
- **Output**: where learnings will be documented (ADR, linked doc, ticket comment) - agreed before the spike starts, not "figured out later".
- **Success Criteria**: learning outcomes, not feature delivery. Each is a question answered or a decision enabled ("We will know whether X is feasible"; "A recommendation is made for Y"). Avoid "user can..." language - that belongs on the follow-up story.

## Anti-Patterns

- Missing user perspective - technical tasks still need a User Statement (or Objective for spikes).
- Vague acceptance criteria - "works correctly" is not testable.
- Bugs without reproduction steps.
- Implementation detail in Background instead of Technical Notes.
