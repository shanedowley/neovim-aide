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

# Completed Release

## R1.6 — Code and Documentation Cleanup

R1.6 removed obsolete, redundant and unnecessary code and consolidated project
documentation.

The release preserved existing behaviour and prepared a clean foundation for
future development.

# Current Direction

The agreed release sequence is:

## R2.0 — Intelligent AI Orchestration

R2.0 will introduce intelligent AI orchestration, with provider/model
abstraction as its architectural foundation.

The product direction has three pillars:

- capability routing — select the model best suited to the task
- economic routing — use the most economical model expected to complete the
  task successfully
- correctness and consistency — preserve predictable Neovim-AIDE behaviour
  regardless of provider/model selection

Provider/model abstraction enables these outcomes; it is not the complete
product objective.

## Following Major Release — Java / Multi-Language Support

Java support will follow R2.0 as part of the next major release and should
build on the provider/model abstraction established there.

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
