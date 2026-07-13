# Neovim-AIDE 1.4 — Release Notes

Release Date: 13 July 2026

---

# Overview

Neovim-AIDE R1.4 is a focused daily-use workflow release.

It is the final pre-R2.0 product increment before the project moves into
provider abstraction and OpenRouter multi-model architecture work.

R1.4 does not introduce architectural change.

Instead, it improves practical developer experience in two areas:

- DAP watch workflows
- Visual-selection Codex workflows

This release continues the established Neovim-AIDE approach:

> A Neovim IDE.
> Human-controlled. AI-assisted.

The underlying AI engine remains **Codex**.

No breaking changes have been introduced.

---

# Release Summary

Release 1.4 focuses on small, practical workflow improvements discovered
through daily use of the public R1.3 release.

This release includes:

- Improved DAP watches UX
- Better distinction between watch expressions and LLDB watchpoints
- Visual-mode Codex workflow parity improvement
- Safe refactor preview for selected code
- Cleaner Codex which-key workflow descriptions
- Removal of stale which-key entries
- Cleaner sandbox startup by guarding markdown-preview build behaviour

The release intentionally avoids major new workflow expansion.

Larger workflow ideas have been banked for future R2.x/R3.x releases.

---

# Highlights

## DAP Watches UX

R1.4 improves the debugger watch workflow.

New and refined mappings:

```text
<leader>dw  DAP: Add watch expression
<leader>dX  DAP: Clear watch expressions
<leader>dW  DAP: Set LLDB watchpoint on symbol
```
