# Neovim-AIDE

> A Neovim IDE
> Human-controlled. AI-assisted.

## Runtime Engine

**Codex CLI**

---

# Contributing to Neovim-AIDE

Thank you for taking an interest in contributing to Neovim-AIDE.

Neovim-AIDE is an AI-assisted IDE built on Neovim.

The project is built around a simple principle:

> **Human-controlled. AI-assisted.**

We welcome contributions that improve the reliability, maintainability and usability of the project while preserving its core development philosophy.

---

# Project Philosophy

Neovim-AIDE is intentionally designed as a developer environment rather than an autonomous AI coding system.

The project prioritises:

- correctness
- explicit developer control
- operational visibility
- validation
- traceability
- maintainability

The architecture assumes:

- AI-generated code can be incorrect.
- Development environments can degrade.
- Developers remain responsible for decisions.
- AI should assist development workflows rather than replace them.

Features that reduce visibility, bypass validation or introduce opaque automation are unlikely to align with the goals of the project.

---

# Development Workflow

Neovim-AIDE has been developed using a disciplined, incremental development process.

Contributors are encouraged to follow the same approach.

```text
Observe
    ↓
Analyse
    ↓
Design
    ↓
Implement
    ↓
Review
    ↓
Validate
    ↓
Commit
```

In practice this means:

- understand the problem before proposing a solution
- make small, focused changes
- complete one story at a time
- avoid speculative refactoring
- review changes before committing
- validate behaviour before merging
- prefer incremental improvement over large rewrites

Development confidence is valued more highly than feature velocity.

---

# Contribution Scope

Contributions are welcome in areas including:

- documentation
- developer workflow improvements
- navigation and editing workflows
- operational observability
- runtime validation
- installation and bootstrap
- testing
- diagnostics
- Neovim UX improvements
- platform compatibility
- maintainability

Small, focused and reviewable pull requests are strongly preferred.

---

# Sandbox-First Validation

All changes should be validated before they are merged.

Where practical, contributors are encouraged to validate changes using an isolated sandbox environment before testing within their primary development environment.

The typical workflow is:

```text
Develop
    ↓
Validate in Sandbox
    ↓
Verify Behaviour
    ↓
Submit
```

Sandbox-first validation helps identify installation issues, dependency problems and behavioural regressions before they reach other users.

It is considered a core development practice for the project and should be used whenever practical.

---

# Code Style

The project values code that is easy to understand and maintain.

General guidelines include:

- prefer readability over cleverness
- keep functions focused
- favour focused modules with a single primary responsibility
- minimise unnecessary complexity
- favour explicit behaviour over hidden side effects
- use descriptive names
- follow existing project conventions

Consistency with the surrounding codebase is generally more important than individual coding style.

---

# Testing and Validation

Contributors should verify that changes behave as intended before submitting them.

Depending on the nature of the change, this may include:

- sandbox validation
- runtime validation
- bootstrap verification
- workflow testing
- preview and apply behaviour
- logging and diagnostics
- failure-path testing

Documentation updates should accompany behavioural or architectural changes where appropriate.

---

# Safety Expectations

Neovim-AIDE deliberately favours explicit development workflows over autonomous behaviour.

Contributions should preserve that philosophy.

In particular:

- preserve explicit developer confirmation
- avoid silent source-code modification
- avoid hidden background automation
- maintain observable workflow state
- preserve validation before application

Operational visibility is considered a feature rather than an implementation detail.

---

# Pull Request Expectations

Good pull requests are:

- focused
- incremental
- easy to review
- well described
- technically justified
- appropriately documented
- validated before submission

Large pull requests that combine unrelated changes are more difficult to review and are generally discouraged.

---

# Documentation

Documentation is considered part of the product and should evolve alongside the implementation.

Contributors making behavioural or architectural changes should update relevant documentation where appropriate.

Commonly updated documents include:

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/README.md`
- user-facing help
- installation documentation

Documentation should remain:

- technically accurate
- concise
- practical
- welcoming
- consistent with the shipped product

---

# What Not To Submit

The following types of changes are unlikely to align with the goals of the project:

- autonomous coding workflows
- silent auto-apply behaviour
- hidden background mutation
- opaque automation
- unnecessary architectural complexity
- features that reduce developer control

Neovim-AIDE deliberately favours explicit development over invisible automation.

---

# Community

Constructive discussion, thoughtful development trade-offs and respectful collaboration are encouraged.

Questions, ideas and well-reasoned proposals are always welcome.

The best contributions improve the project while preserving its guiding principles:

- Correctness
- Control
- Traceability

**Human-controlled. AI-assisted.**