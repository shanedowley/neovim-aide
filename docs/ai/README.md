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

# Purpose

The AI Context Pack captures the intent behind the code.

The source code explains **how** Neovim-AIDE works.

These documents explain **why** it works this way.

Together they provide AI assistants with the context needed to collaborate effectively while respecting the project's architecture, philosophy and development practices.

This context is maintained as part of the repository so that it evolves alongside the software.

---

# Design Principles

The AI Context Pack follows the same principles as the rest of Neovim-AIDE.

- Keep documentation concise and focused.
- Prefer clarity over completeness.
- Avoid duplication wherever possible.
- Make incremental improvements.
- Treat documentation as part of the product.
- Keep these documents under version control.
- Update them whenever significant project decisions are made.

---

# Reading Order

AI assistants should read these documents in the following order.

1. **[README.md](README.md)** _(this document)_
2. **[AI_DEVELOPMENT_MODEL.md](AI_DEVELOPMENT_MODEL.md)**
3. **[CODEX_ROLE.md](CODEX_ROLE.md)**
4. **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)**
5. **[PRODUCT_PHILOSOPHY.md](PRODUCT_PHILOSOPHY.md)**
6. **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)**
7. **[AI_WORKING_AGREEMENT.md](AI_WORKING_AGREEMENT.md)**
8. **[SANDBOX_GUIDE.md](SANDBOX_GUIDE.md)**
9. **[ROADMAP.md](ROADMAP.md)**
10. **[PROJECT_TERMINOLOGY.md](PROJECT_TERMINOLOGY.md)**

Each document has a distinct purpose. Together they provide a complete understanding of the project's direction, expectations and development practices.

---

# Document Ownership

Each subject has one canonical owner.

| Document | Canonical responsibility |
| --- | --- |
| **[README.md](README.md)** | Context Pack index, scope and authority |
| **[AI_DEVELOPMENT_MODEL.md](AI_DEVELOPMENT_MODEL.md)** | Team roles and the collaboration model |
| **[CODEX_ROLE.md](CODEX_ROLE.md)** | Codex-specific repository responsibilities and boundaries |
| **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** | Concise project onboarding overview |
| **[PRODUCT_PHILOSOPHY.md](PRODUCT_PHILOSOPHY.md)** | Enduring product values and principles |
| **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** | Development practices and quality expectations |
| **[AI_WORKING_AGREEMENT.md](AI_WORKING_AGREEMENT.md)** | AI communication and decision-support behaviour |
| **[SANDBOX_GUIDE.md](SANDBOX_GUIDE.md)** | Sandbox architecture, lifecycle, safety and validation |
| **[ROADMAP.md](ROADMAP.md)** | Current and future strategic direction |
| **[PROJECT_TERMINOLOGY.md](PROJECT_TERMINOLOGY.md)** | Preferred project vocabulary |

Other documents should link to the canonical owner rather than duplicate its detailed guidance.

---

# Relationship to the Repository

These documents are guidance.

The source code remains the definitive description of the implementation.

Technical documentation remains the definitive description of the architecture and behaviour.

If uncertainty exists:

1. Trust the implementation.
2. Consult the technical documentation.
3. Use these documents to understand the project's intent.

---

# Scope

These documents describe the long-lived aspects of the project, including:

- Product vision
- Product philosophy
- Development workflow
- Architectural intent
- Roadmap
- Terminology
- Collaboration expectations

They deliberately avoid duplicating implementation details that are already documented elsewhere.

---

# Audience

The AI Context Pack is intended for:

- AI assistants contributing to the project.
- Human contributors onboarding to the project.
- Future maintainers seeking architectural context.

The documents are intentionally AI-agnostic and should remain useful regardless of which tools or models are used.

---

# Project Values

Neovim-AIDE is guided by a small set of enduring values.

- Correctness
- Control
- Traceability
- Simplicity
- Maintainability
- Incremental improvement

These values should inform both implementation decisions and AI-assisted collaboration.

---

# Maintenance

The AI Context Pack is a living part of the repository.

As the project evolves:

- Update these documents when significant decisions are made.
- Remove obsolete guidance.
- Keep the documents concise.
- Preserve consistency across the entire context pack.

Like the code itself, these documents should remain easy to read, easy to maintain and easy to trust.
