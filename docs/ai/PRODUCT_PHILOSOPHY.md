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

# Product Philosophy

## Guiding Principle

Neovim-AIDE is built on a simple idea:

> AI should make developers more effective, not less responsible.

The AI assists.

The developer decides.

---

# Human-Controlled

Every feature should preserve developer control.

The AI may:

- Explain
- Suggest
- Analyse
- Review
- Generate
- Refactor

The AI should never become an opaque decision maker.

Developers should always understand what is being proposed and remain responsible for accepting or rejecting every change.

---

# Simplicity

The project values simplicity over cleverness.

Prefer:

- straightforward designs
- focused modules
- explicit behaviour
- readable code

Avoid complexity unless it produces clear and lasting value.

---

# Incremental Improvement

Neovim-AIDE evolves through small, well-tested improvements.

Avoid large rewrites when incremental evolution can achieve the same outcome.

Small improvements are easier to:

- understand
- review
- validate
- maintain

---

# Architectural Consistency

New functionality should fit naturally within the existing architecture.

Reuse existing components whenever practical.

Avoid introducing parallel implementations simply because they are easier to write.

Consistency is a long-term investment.

---

# Stability First

Working software is valuable.

Avoid unnecessary change to stable code.

When improving existing functionality:

- preserve behaviour unless change is intentional
- minimise risk
- favour compatibility

A useful principle is:

> If it isn't broken, don't fix it.

---

# Correctness Before Convenience

Convenience should never come at the expense of correctness.

If there is a trade-off, favour the solution that is:

- more predictable
- easier to verify
- easier to reason about

---

# Documentation Matters

Documentation is part of the product.

Good documentation should explain:

- intent
- rationale
- trade-offs

not merely implementation.

Documentation should evolve alongside the code.

---

# Transparency

The project values transparent behaviour.

Developers should be able to understand:

- what the AI is doing
- why it is doing it
- what changes are being proposed

Avoid hidden behaviour wherever possible.

---

# Long-Term Thinking

Optimise for the long life of the project.

Consider:

- maintainability
- readability
- consistency
- contributor experience

Short-term convenience should not compromise long-term quality.

---

# Continuous Refinement

No design is considered perfect.

The project welcomes thoughtful improvement through:

- discussion
- experimentation
- validation
- incremental refinement

Every contribution should leave the project in a slightly better state than it was found.
