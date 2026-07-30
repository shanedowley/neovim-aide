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

# Roadmap

## Purpose

This document describes the strategic direction of Neovim-AIDE.

It provides context for future development without prescribing implementation details.

Roadmaps evolve over time.

The principles guiding the project should remain considerably more stable.

---

# Long-Term Vision

Neovim-AIDE aims to become a mature AI-assisted development environment for
Neovim.

The project will continue to evolve while preserving the values and principles
defined in `PRODUCT_PHILOSOPHY.md`.

---

# Current Direction

The agreed release sequence is:

## R1.6 — Code and Documentation Cleanup

R1.6 focuses on removing obsolete, redundant and unnecessary code and
consolidating project documentation.

The release preserves existing behaviour and prepares a clean foundation for
future development.

## R2.0 — Java Support

R2.0 will extend Neovim-AIDE with Java development support.

Java support should integrate with the existing architecture and preserve the
project's human-controlled workflow model.

## R3.0 — Provider/Model Abstraction and OpenRouter

R3.0 will introduce provider and model abstraction, including OpenRouter
integration.

---

# Roadmap Constraints

Roadmap decisions follow `PRODUCT_PHILOSOPHY.md` and
`DEVELOPMENT_GUIDE.md`.

Each roadmap initiative should have a focused objective. Technology choices
should serve product needs rather than technology trends.

---

# Evaluating New Ideas

Potential new features should be evaluated against the following questions.

Does this:

- improve the developer experience?
- preserve developer control?
- fit the existing architecture?
- simplify the product?
- justify its maintenance cost?
- align with the project's philosophy?

If the answer is largely "no", the feature should be reconsidered.

---

# Living Document

This roadmap is expected to evolve.

It should be updated as significant strategic decisions are made.

Historical implementation details belong elsewhere.

This document should remain focused on the future direction of the project.
