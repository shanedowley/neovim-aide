# Neovim-AIDE 1.3 — Release Notes

Release Date: July 2026

---

# Overview

Neovim-AIDE R1.3 completes the transition from the original
Neovim-Codex project to **Neovim-AIDE**.

The product is now presented as:

> A Neovim IDE.
> Human-controlled. AI-assisted.

The underlying AI engine remains **Codex**.

This release is intentionally evolutionary rather than revolutionary.
The emphasis is on product identity, operational visibility,
workflow configurability and documentation quality.

## Release Summary

Release 1.3 completes the transition of the project from
**Neovim-Codex** to **Neovim-AIDE**.

This release focuses on:

- Product identity
- Workflow configurability
- Operational visibility
- User experience
- Documentation quality

No breaking changes have been introduced.
Existing commands, workflows and configuration remain compatible.

---

# Highlights

## Neovim-AIDE Product Identity

The project has been fully re-positioned as **Neovim-AIDE**.

This release aligns:

- repository identity
- installation documentation
- contributor documentation
- architecture documentation
- command reference
- demonstrations
- project messaging

while preserving complete compatibility with the existing runtime.

The existing `:Codex*` commands remain unchanged.

The Lua namespaces remain unchanged.

Codex continues to provide the AI engine beneath the Neovim-AIDE product.

---

## Workflow Configuration

Workflow mode is now configurable.

The default workflow mode is no longer hard-coded.

Configuration now allows:

```lua
workflow = {
    default_mode = "fast",
}
```

This provides a foundation for future workflow evolution while keeping
the current behaviour unchanged by default.

---

## Mode-aware Model Profiles

Workflow modes may now resolve to different AI model profiles.

Current defaults intentionally route all modes to the same model.

This establishes the configuration architecture required for future
mode-specific model selection without introducing behavioural change.

Example:

- fast
- balanced
- strict
- refactor

may each select different models in future releases.

---

## Operational UX Improvements

Health checking now provides immediate visual feedback.

Running:

:CodexHealth

now displays:

Checking model health...

while diagnostics execute.

This removes the previous perception that the editor had become idle
during model validation.

---

## Improved Statusline

The statusline now presents two complementary pieces of information:

```
✓ Codex Ready · Fast
```

or

```
⚙ Codex Running · Refactor
```

Operational status and workflow mode are now visible simultaneously.

---

## Documentation Refresh

All current documentation has been aligned with the Neovim-AIDE product
identity.

Documentation now consistently communicates:

- Product
- Strapline
- AI Engine

giving new users and contributors a clearer understanding of the
relationship between Neovim-AIDE and Codex.

---

# Compatibility

This release intentionally preserves compatibility.

No existing commands have changed.

Existing workflows continue to function.

Existing configuration remains valid.

---

# Philosophy

Neovim-AIDE continues to follow the same engineering principles that
have guided the project since its inception:

- Correctness
- Control
- Traceability

The AI assists.

The developer decides.

---

# Looking Ahead

R1.3 completes the product identity work begun during the R1.x series.

Future work for R2.0 will build on this foundation with further
improvements to workflow, observability and AI-assisted engineering,
while continuing to prioritise disciplined software engineering over
automation for its own sake.

---

Human-controlled. AI-assisted.
