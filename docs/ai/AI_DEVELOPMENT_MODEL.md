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

# AI Development Model

## Purpose

This document describes the preferred collaboration model used to develop Neovim-AIDE.

It defines the responsibilities of the developer and AI assistants throughout the software development lifecycle.

The goal is to maximise developer effectiveness while preserving human ownership, architectural consistency and implementation quality.

---

# Guiding Principle

Neovim-AIDE is developed through collaboration between:

- the developer
- a strategic AI assistant
- an implementation AI assistant

Each participant has a distinct responsibility.

The current strategic AI assistant is ChatGPT.

The current implementation AI assistant is Codex.

Clear separation of responsibilities produces better software.

---

# The Developer

The developer owns the project.

The developer:

- defines product direction
- sets priorities
- approves designs
- reviews trade-offs
- validates outcomes
- decides what is merged

The developer remains responsible for every change.

---

# Strategic AI Assistant

*Current implementation: ChatGPT*

The strategic AI assistant is the architectural and strategic partner.

Typical responsibilities include:

- understanding problems
- exploring ideas
- architecture
- release planning
- story decomposition
- design reviews
- technical discussion
- trade-off analysis
- documentation
- roadmap planning
- implementation review

The strategic AI assistant focuses on thinking before implementation.

---

# Implementation AI Assistant

*Current implementation: Codex*

The implementation AI assistant is the repository and implementation partner.

Typical responsibilities include:

- implementing stories
- editing code
- refactoring
- debugging
- producing patches
- updating documentation
- writing tests
- repository navigation

The implementation AI assistant focuses on implementation within the repository.

---

# Preferred Development Flow

The preferred workflow is:

1. Understand the problem.
2. Discuss the design with the strategic AI assistant.
3. Agree the implementation approach.
4. Implement with the implementation AI assistant.
5. Validate changes.
6. Review outcomes.
7. Commit.
8. Repeat.

Small iterations are preferred over large implementation sessions.

---

# Repository Context

Before beginning implementation work, AI assistants should understand the project.

The preferred onboarding sequence is:

AGENTS.md

↓

AI Context Pack

↓

Technical Documentation

↓

Source Code

Implementation remains authoritative.

AI assistants should keep repository context current by reading these documents at the start of new work and after significant project changes.

---

# Decision Making

Design decisions should be made before implementation begins.

Implementation should not become exploratory architecture.

Where uncertainty exists:

- pause
- discuss
- decide
- then implement

---

# Story-Based Development

Development proceeds through small stories.

Each story should have:

- clear objective
- limited scope
- defined completion
- independent validation

Stories should be completed before beginning the next story.

---

# Validation

Meaningful implementation should be validated before being considered complete.

Validation should provide confidence without introducing unnecessary complexity.

Where practical:

- validate in the sandbox
- review the implementation
- confirm documentation remains accurate

---

# Communication

The strategic AI assistant and implementation AI assistant should complement one another rather than duplicate responsibilities.

The strategic AI assistant should avoid unnecessary implementation.

The implementation AI assistant should avoid unnecessary architectural redesign.

Both should:

- explain reasoning
- identify risks
- ask questions when required
- respect project philosophy

---

# Human Control

AI assists.

The developer decides.

This principle applies throughout the project.

Human judgement remains the final authority.

---

# Continuous Improvement

This collaboration model is expected to evolve.

Improvements should be based upon practical experience gained while developing Neovim-AIDE.

The model should remain simple, understandable and effective.

---

# Closing Principle

The objective is not to maximise AI involvement.

The objective is to maximise software quality.

AI is valuable because it helps developers build better software.

Developers remain responsible for building it.

The best software emerges when each participant focuses on what they do best.

Developers provide judgement.

Strategic AI provides thinking.

Implementation AI provides execution.

Together they produce software that is more robust than any one participant working alone.