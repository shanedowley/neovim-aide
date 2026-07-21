# Neovim-AIDE

> A Neovim IDE
> Human-controlled. AI-assisted.

## AI Engine

**Codex**

---

# Neovim-AIDE Commands

This document provides the primary reference for the commands, key mappings and AI-assisted developer workflows available in Neovim-AIDE.

For installation, see `INSTALL.md`.

For architecture and runtime behaviour, see `ARCHITECTURE.md`.

---

# Developer Workflows

Most day-to-day interaction with Neovim-AIDE occurs through key mappings.

The following tables summarise the available AI-assisted workflows.

---

## Explain

### Normal Mode

| Mapping      | Purpose                      |
| ------------ | ---------------------------- |
| `<leader>cE` | Explain the current line     |
| `<leader>cB` | Explain the current buffer   |
| `<leader>cU` | Explain the current function |
| `<leader>cK` | Explain the current class    |

### Visual Mode

| Mapping      | Purpose                              |
| ------------ | ------------------------------------ |
| `<leader>ce` | Explain the selected code (Fast)     |
| `<leader>cE` | Explain the selected code (Rigorous) |

---

## Review

| Mapping      | Purpose                     |
| ------------ | --------------------------- |
| `<leader>cu` | Review the current function |
| `<leader>ck` | Review the current class    |

---

## Refactor

| Mapping      | Purpose                                           |
| ------------ | ------------------------------------------------- |
| `<leader>cR` | Refactor the current function                     |
| `<leader>cP` | Preview a safe refactor before applying changes   |
| `<leader>cp` | Apply an AI-generated patch to the current buffer |

---

## Rewrite

### Normal Mode

| Mapping      | Purpose                                          |
| ------------ | ------------------------------------------------ |
| `<leader>cl` | Rewrite the current line                         |
| `<leader>cF` | Rewrite the current buffer using a custom prompt |
| `<leader>cD` | Preview a rewrite diff for the current line      |

### Visual Mode

| Mapping      | Purpose                                   |
| ------------ | ----------------------------------------- |
| `<leader>cr` | Rewrite the selected code                 |
| `<leader>cP` | Preview a safe rewrite                    |
| `<leader>cd` | Preview rewrite diff                      |
| `<leader>ca` | Apply the previewed changes               |
| `<leader>co` | Open generated output in a scratch buffer |
| `<leader>cw` | Write generated output to disk            |

---

## Current Operation

| Mapping      | Purpose                               |
| ------------ | ------------------------------------- |
| `<leader>c,` | Show the last AI-assisted operation   |
| `<leader>c.` | Repeat the last AI-assisted operation |

---

## Navigation

### Function Navigation

| Mapping      | Purpose                                       |
| ------------ | --------------------------------------------- |
| `<leader>nh` | Jump to the beginning of the current function |
| `<leader>nl` | Jump to the end of the current function       |
| `<leader>nj` | Jump to the next function                     |
| `<leader>nk` | Jump to the previous function                 |

### Code Selection

| Mapping      | Purpose                     |
| ------------ | --------------------------- |
| `<leader>nv` | Select the current function |
| `<leader>nV` | Select the current class    |

### Project Markers

| Mapping      | Purpose                             |
| ------------ | ----------------------------------- |
| `<leader>nt` | Jump to the next project marker     |
| `<leader>nT` | Jump to the previous project marker |

Supported markers:

- TODO
- FIXME
- BUG
- HACK
- NOTE
- XXX

---

## Modes

Neovim-AIDE supports several operating modes optimised for different development tasks.

| Command           | Purpose                          |
| ----------------- | -------------------------------- |
| `:CodexMode`      | Select the active operating mode |
| `:CodexModeCycle` | Cycle through available modes    |
| `:CodexModeList`  | List all available modes         |

Typical modes include:

- Fast
- Balanced
- Strict
- Refactor

---

## Operational Commands

| Mapping      | Purpose                     |
| ------------ | --------------------------- |
| `<leader>cH` | Open the health report      |
| `<leader>cS` | Show current workflow state |
| `<leader>cT` | Show latency information    |
| `<leader>cV` | Show prompt version         |
| `<leader>cX` | Show recovery report        |
| `<leader>cs` | Open the scratch buffer     |

---

# Ex Commands

The following commands provide administrative, diagnostic and configuration functionality.

---

## Core Commands

| Command               | Purpose                                |
| --------------------- | -------------------------------------- |
| `:CodexContext`       | Show the current project context block |
| `:CodexToggleContext` | Toggle project context injection       |
| `:CodexCommands`      | Open the in-editor command reference   |

---

## Session Memory

| Command             | Purpose                                  |
| ------------------- | ---------------------------------------- |
| `:CodexLastOp`      | Show the last remembered Codex operation |
| `:CodexLastOpClear` | Clear the remembered operation           |
| `:CodexRepeat`      | Repeat the last remembered operation     |

---

## Health and Diagnostics

| Command               | Purpose                                |
| --------------------- | -------------------------------------- |
| `:CodexHealth`        | Open the complete health report        |
| `:CodexHealthCheck`   | Run a quick health check               |
| `:CodexState`         | Show the current workflow state        |
| `:CodexStateHistory`  | Show recent workflow state transitions |
| `:CodexGuardrails`    | Display the active safety guardrails   |
| `:CodexLatency`       | Show latency statistics                |
| `:CodexLog`           | Open the operational log               |
| `:CodexPromptVersion` | Show the active prompt version         |

---

## Recovery

| Command                | Purpose                                           |
| ---------------------- | ------------------------------------------------- |
| `:CodexRecovery`       | Show the last captured failure report             |
| `:CodexRecoveryClear`  | Clear the captured failure report                 |
| `:CodexExplainFailure` | Ask Codex to explain the last recoverable failure |

---

## Notifications

| Command                             | Purpose                          |
| ----------------------------------- | -------------------------------- |
| `:CodexNotifyPlacement {placement}` | Configure notification placement |
| `:CodexNotifyTest`                  | Display a test notification      |

Example:

```vim
:CodexNotifyPlacement top_right
:CodexNotifyPlacement center
:CodexNotifyPlacement bottom_left
```

---

# Related Documentation

| Document          | Purpose                          |
| ----------------- | -------------------------------- |
| `README.md`       | Product overview and quick start |
| `INSTALL.md`      | Installation and bootstrap       |
| `ARCHITECTURE.md` | Runtime architecture             |
| `CONTRIBUTING.md` | Contributor guide                |

---

# Summary

Neovim-AIDE provides a developer-centric workflow that combines traditional editor capabilities with AI-assisted software development.

The key mappings documented here are intended to support fast, discoverable and human-controlled development workflows while preserving Neovim-AIDE's guiding principles of Correctness, Control and Traceability.

