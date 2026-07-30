# Neovim-AIDE

> A Neovim IDE
> Human-controlled. AI-assisted.

# Development Sandbox

## Purpose

The Neovim-AIDE sandbox provides an isolated Neovim configuration and runtime
for installation testing, regression testing and release validation.

A contributor's personal Neovim configuration is the development environment.
The sandbox is the release validation environment.

---

# Canonical Guide

`docs/ai/SANDBOX_GUIDE.md` is the canonical reference for:

- sandbox architecture and paths
- XDG environment isolation
- lifecycle operations
- committed baseline synchronisation
- approved uncommitted patch transfer
- startup, bootstrap and health validation
- logging
- safety rules and stop conditions

Read that guide before creating, updating or validating in the sandbox.

This contributor document intentionally does not duplicate operational
commands. If the implementation or workflow changes, update the canonical
guide.

---

# Contributor Workflow

The canonical order is:

```text
inspect → edit → local checks → sandbox validation → commit → push
```

Use the sandbox when:

- validating functional changes
- reproducing defects
- testing installation or bootstrap behaviour
- checking dependency or plugin setup
- preparing a release candidate
- verifying a clean first-time experience

Stop and investigate any failed validation before committing.

---

# Release Validation

Release candidates should be validated from a clean sandbox runtime.

Use `docs/releases/RELEASE_CHECKLIST.md` to record the required release checks,
and follow `docs/ai/SANDBOX_GUIDE.md` for the exact safe procedure.
