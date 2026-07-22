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

# Project Context

## Product Name

**Neovim-AIDE**

## Strapline

> A Neovim IDE
> Human-controlled. AI-assisted.

---

# Purpose

Neovim-AIDE is an AI-assisted software development environment built on Neovim.

Its purpose is to help developers understand, modify and maintain software while keeping the developer firmly in control of all decisions.

AI is used to augment the developer's capabilities, not replace them.

---

# Vision

Neovim-AIDE aims to demonstrate that AI can be integrated into a development environment without sacrificing correctness, transparency or developer control.

Every feature should reinforce the principle that the AI assists while the developer decides.

---

# Product Values

The project is guided by a small set of enduring values.

- Correctness
- Control
- Traceability
- Simplicity
- Maintainability
- Incremental improvement

These values take precedence over convenience or novelty.

---

# Design Philosophy

Neovim-AIDE favours simple, understandable solutions over unnecessary complexity.

The project deliberately avoids feature bloat.

Every feature should provide clear value, integrate naturally with the existing architecture and remain easy to understand.

When faced with multiple possible solutions, prefer the one that is:

- Simpler
- Easier to maintain
- Easier to understand
- Easier to validate

---

# Architecture

The project is organised as a collection of focused, loosely coupled modules.

New functionality should integrate with existing components wherever possible rather than introducing parallel implementations.

Architectural consistency is valued more highly than rapid feature growth.

---

# Development Philosophy

Development proceeds through small, incremental releases.

Large rewrites are discouraged unless there is a compelling architectural reason.

Every change should be:

- Easy to review
- Easy to validate
- Easy to revert if necessary

The project values steady evolution over disruptive change.

---

# Quality

Code quality is measured by more than correctness.

Good contributions should also improve:

- Readability
- Maintainability
- Consistency
- User experience
- Documentation

Documentation is considered part of the product.

---

# AI Collaboration

AI assistants are expected to understand the project's intent before proposing changes.

Suggestions should:

- Respect the existing architecture.
- Reuse existing components where practical.
- Avoid unnecessary abstraction.
- Preserve backwards compatibility where appropriate.
- Consider the long-term maintainability of the project.

When uncertain, ask for clarification rather than making assumptions.

---

# Success

A successful contribution is one that leaves the project:

- Simpler
- Clearer
- Better documented
- Better tested
- Easier to maintain

Every change should move the project forward while preserving the qualities that make Neovim-AIDE reliable and approachable.
