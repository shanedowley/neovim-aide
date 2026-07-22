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

# Project Terminology

## Purpose

This document defines the preferred terminology used throughout the Neovim-AIDE project.

Consistent language improves communication between developers, AI assistants and future contributors.

Where practical, prefer the terminology defined here.

---

# Product

## Neovim-AIDE

The name of the project.

Prefer:

> Neovim-AIDE

Do not abbreviate unless the surrounding context is already clear.

---

# Strapline

The preferred product strapline is:

> A Neovim IDE
> Human-controlled. AI-assisted.

---

# Developer

Prefer:

> Developer

Avoid:

> Engineer

This project uses _developer_ consistently when referring to contributors.

---

# Software Development

Prefer:

> Software development

Avoid:

> Software engineering

---

# AI Assistant

Use:

> AI assistant

This documentation intentionally avoids references to specific AI models or products unless discussing implementation details.

---

# Story

A small, focused unit of development work.

Stories should be:

- independently understandable
- independently testable
- independently reviewable

Stories are preferred over large implementation tasks.

---

# Release

A collection of related stories delivered with a single objective.

Each release should have:

- a clear purpose
- limited scope
- defined completion criteria

---

# Sandbox

An isolated development environment used for validation before applying changes to the primary development environment.

Sandbox-first validation is an important development practice within the project.

---

# Validation

The process of confirming that a change behaves as intended.

Validation may include:

- functional testing
- sandbox testing
- manual review
- documentation review

---

# Correctness

Confidence that behaviour is accurate and reliable.

Correctness is valued above convenience.

---

# Control

The developer remains responsible for all decisions.

AI provides assistance rather than autonomy.

---

# Traceability

Changes should be understandable and explainable.

Developers should be able to determine:

- what changed
- why it changed
- how it was validated

---

# Simplicity

Prefer solutions that are:

- easy to understand
- easy to maintain
- easy to extend

Avoid unnecessary complexity.

---

# Incremental Improvement

The preferred method of evolving the project.

Large rewrites are exceptional.

Small improvements are the norm.

---

# Documentation

Documentation is considered part of the product.

It should evolve alongside the implementation.

---

# AI Context Pack

The collection of documents within `docs/ai/`.

Together these documents describe the intent, philosophy and development practices of Neovim-AIDE.

---

# Guiding Principle

When choosing terminology, prefer clarity and consistency over novelty.

A shared vocabulary helps developers and AI assistants collaborate more effectively.
