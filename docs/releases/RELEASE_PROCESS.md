# Release Process

This document defines the standard release process for Neovim-AIDE.

The goal is to produce releases that are correct, reproducible and well understood.

This process was developed and validated during the R1.6 release and should be followed for future releases unless there is a deliberate reason to change it.

---

# What Was Learned

This process did not exist at the start of the project.

It evolved over successive releases as the repository matured.

Every stage exists because a previous release exposed uncertainty,
manual work or unnecessary risk.

The process should continue to evolve in the same way.

It is a guide, not a rigid methodology.

When the process becomes simpler without reducing confidence,
prefer the simpler process.

---

# Principles

Every release should be:

- Correct before complete.
- Human-controlled.
- AI-assisted.
- Fully reproducible.
- Backed by evidence rather than assumption.
- Small, disciplined and easy to review.

The release process is intentionally conservative.

---

# Release Lifecycle

Every release follows the same high-level stages.

```
Development
        │
        ▼
Feature Complete
        │
        ▼
Repository Cleanup
        │
        ▼
Architecture Review
        │
        ▼
Documentation Review
        │
        ▼
Release Candidate
        │
        ▼
Sandbox Validation
        │
        ▼
Fix Release Blockers
        │
        ▼
Final Reproducible Validation
        │
        ▼
Merge
        │
        ▼
Tag
        │
        ▼
Publish
        │
        ▼
Post-release Documentation
```

A release does not move to the next stage until the current stage is complete.

---

# 1. Feature Complete

The release branch reaches feature completion.

At this point:

- no planned functionality remains
- all agreed stories are complete
- behaviour matches the intended release scope

No cleanup should be performed while major features are still changing.

---

# 2. Repository Cleanup

Before release, simplify the repository.

Typical work includes:

- removing obsolete code
- removing duplicate implementations
- removing compatibility layers no longer required
- removing unused plugins
- removing obsolete documentation
- consolidating duplicated logic

The objective is to reduce complexity without changing behaviour.

Every cleanup should satisfy the question:

> Does this make the repository easier to understand without changing what it does?

---

# 3. Architecture Review

Review the repository as a whole.

Look for:

- duplicated responsibilities
- inconsistent ownership
- unnecessary abstractions
- unclear module boundaries
- dead code paths

Architecture should become clearer with every release.

---

# 4. Documentation Review

Documentation should accurately describe the repository.

Review:

- README
- installation
- contributor documentation
- AI documentation
- roadmap
- release notes

Documentation should describe reality.

It should never describe intended future behaviour as though it already exists.

---

# 5. Release Candidate

Create a release candidate.

The release candidate should represent the exact code intended for publication.

From this point onward:

- avoid unnecessary changes
- fix only genuine release blockers
- preserve stability

---

# 6. Sandbox Validation

Validate the release candidate in a completely isolated environment.

The sandbox exists to answer one question:

> Can a new user / developer reproduce this release from scratch?

Validation should include:

- clean clone
- dependency installation
- bootstrap
- startup
- representative workflows
- health checks
- repository integrity

The sandbox should always begin from a clean state.

---

# 7. Fix Release Blockers

Only genuine release blockers should interrupt the release candidate.

Examples include:

- broken installation
- reproducibility failures
- failed validation
- incorrect documentation that would mislead users

Fix the smallest possible surface area.

Avoid opportunistic improvements.

After every blocker fix:

- validate
- commit
- repeat validation

---

# 8. Final Reproducible Validation

Perform a complete validation again.

Do not validate only the fix.

Revalidate the entire release candidate.

The final validation should demonstrate:

- clean repository
- reproducible installation
- expected runtime behaviour
- successful representative workflows
- accurate documentation

Only after the complete release candidate passes should it be considered ready.

---

# 9. Merge

Merge the validated release branch into `main`.

Preserve repository history.

Do not merge an unvalidated release candidate.

---

# 10. Tag

Create the release tag.

The tag identifies the exact released code.

Tags should always reference the validated release commit.

---

# 11. Publish

Publish the GitHub Release.

The release notes describe what was released.

Repository documentation describe the repository's current state until publication completes.

---

# 12. Post-release Documentation

After publication:

- update the README
- update release status
- update the roadmap
- archive release-candidate wording

This is intentionally a separate commit.

The released code should remain immutable.

The repository can then move forward.

---

# AI Roles

Neovim-AIDE uses distinct AI roles during development.

These roles intentionally overlap to improve confidence.

## ChatGPT

Primary responsibilities:

- architecture review
- design discussion
- planning
- documentation
- release engineering
- code review
- validation strategy

## Codex

Primary responsibilities:

- implementation
- investigation
- repository analysis
- targeted changes
- validation execution
- structured reporting

Neither AI is the decision maker.

The developer remains responsible for:

- architecture
- acceptance
- commits
- merges
- releases

AI assists.

The developer decides.

---

# Evidence over Assumption

Every significant claim during a release should be supported by evidence.

For example:

Instead of:

> "This should work."

Prefer:

> "Validated in a clean sandbox from a fresh clone."

Instead of:

> "The plugin appears unused."

Prefer:

> "Repository search found no references."

Evidence builds confidence.

Assumptions create risk.

---

# Continuous Improvement

Every release looks to improve both:

- the product
- the release process

If a release uncovers:

- uncertainty
- manual work
- repeated mistakes
- fragile validation
- unclear documentation

the process itself should be improved.

Future releases aims to become simpler, more reproducible and easier to trust.

---

# Release Philosophy

The purpose of a release is not to deliver as much code as possible.

The purpose is to deliver software that people can trust.

A successful release leaves the repository:

- cleaner
- simpler
- better documented
- easier to maintain
- easier to extend
- easier to validate

Every release should increase confidence in the project. That confidence is earned through disciplined engineering, reproducible validation and thoughtful review—not by moving quickly.
