# Neovim-AIDE AI Context

> This document is part of the **Neovim-AIDE AI Context Pack**.
>
> These documents provide canonical project context for AI assistants
> contributing to Neovim-AIDE.
>
> They complement—but never replace—the source code and technical
> documentation.
>
> If a conflict exists between these documents and the implementation,
> **the implementation is authoritative**.

---

# Development Guide

## Purpose

This document describes the preferred development practices used throughout the Neovim-AIDE project.

It explains how work is planned, implemented, validated and maintained.

---

# Development Philosophy

Development proceeds through small, incremental improvements.

Large rewrites are avoided unless they provide clear architectural value.

The preferred approach is:

1. Understand the problem.
2. Design the solution.
3. Implement incrementally.
4. Validate thoroughly.
5. Document appropriately.

---

# Seek Understanding First

Before writing code:

- understand the problem
- understand the existing implementation
- understand the architectural intent

Do not optimise or redesign code before understanding why it exists.

Good solutions begin with good understanding.

---

# Work in Stories

Development should be organised into small, focused stories.

Each story should:

- solve one problem
- be independently testable
- be independently reviewable
- minimise implementation risk

Small stories produce better software.

---

# Preserve Existing Architecture

Prefer extending existing components over introducing new ones.

Reuse existing abstractions whenever practical.

Avoid duplicate implementations.

Architectural consistency is more valuable than architectural novelty.

---

# Incremental Releases

Neovim-AIDE evolves through focused releases.

Each release should have:

- a clear objective
- a limited scope
- well-defined acceptance criteria

Avoid combining unrelated work into a single release.

---

# Validation

Every significant change should be validated before it is considered complete.

Validation should provide confidence that:

- the feature works
- existing behaviour is preserved
- documentation remains accurate

Confidence should come from evidence rather than assumption.

---

# Sandbox-First Validation

Where practical, validate changes in an isolated sandbox environment before applying them to the primary development environment.

Sandbox validation reduces risk while encouraging experimentation.

---

# Documentation

Documentation evolves alongside the implementation.

When behaviour changes:

- update documentation
- remove obsolete guidance
- preserve consistency

Well-maintained documentation reduces future maintenance effort.

---

# Code Quality

Good code is:

- readable
- maintainable
- consistent
- appropriately simple

Prefer solutions that future contributors can understand quickly.

---

# Refactoring

Refactoring should have a clear purpose.

Examples include:

- improving readability
- reducing duplication
- simplifying implementation
- improving maintainability

Avoid refactoring solely for stylistic preference.

---

# Removing Code

Dead or obsolete code should be removed.

However:

- confirm it is no longer required
- preserve working behaviour
- avoid speculative clean-up

A useful principle is:

> If it isn't broken, don't fix it.

---

# Reviews

Review changes thoughtfully.

Consider:

- correctness
- architecture
- maintainability
- documentation
- user experience

Look beyond whether the code merely works.

---

# Continuous Improvement

Every contribution should leave the repository in a better state than it was found.

Improvements do not need to be large.

Small, thoughtful improvements accumulate into long-term quality.

---

# Closing Principle

Neovim-AIDE is intentionally developed through careful, incremental evolution.

The goal is not rapid feature growth.

The goal is a codebase that remains:

- understandable
- maintainable
- reliable
- enjoyable to work on

Every contribution should reinforce those qualities.
