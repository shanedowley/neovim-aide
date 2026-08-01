# Neovim-AIDE

> A Neovim IDE  
> Human-controlled. AI-assisted.

# Command and Key Mapping Reference

This document is the primary user reference for commands, key mappings and developer workflows available in Neovim-AIDE.

For installation, see `INSTALL.md`.

For architecture and runtime behaviour, see `ARCHITECTURE.md`.

For contributor guidance, see `docs/CONTRIBUTING.md`.

---

# Mapping Model

Neovim-AIDE follows a single-owner mapping model.

Each executable mapping should be owned by one feature module. Which-key provides grouping and discoverability rather than duplicating feature behaviour.

The **Owner** column identifies the feature or module responsible for each mapping.

Some mappings are loaded lazily. They may appear through a Lazy.nvim proxy before the underlying plugin has loaded, but their meaning remains stable throughout the session.

---

# Notation

| Notation | Meaning |
| --- | --- |
| `<leader>` | The configured Neovim leader key |
| Normal | Normal mode |
| Visual | Visual selection mode |
| Insert | Insert mode |
| Select | Select mode |
| Terminal | Terminal mode |
| Buffer | Mapping is local to a particular buffer or filetype |
| Contextual | Mapping appears only when its owning feature is active |

---

# Quick Group Reference

| Prefix | Group | Primary purpose |
| --- | --- | --- |
| `<leader>a` | ASM | Assembly debugging workflows |
| `<leader>b` | Buffer | Buffer navigation and management |
| `<leader>c` | Codex | AI-assisted developer workflows |
| `<leader>d` | Debug | DAP debugging |
| `<leader>f` | File | Files, search and save operations |
| `<leader>g` | Git | Git, Gitsigns, Fugitive and Lazygit |
| `<leader>l` | LSP | Language intelligence, diagnostics, formatting and linting |
| `<leader>m` | Surround | Surround editing |
| `<leader>M` | Markdown | Markdown Preview |
| `<leader>n` | Navigation | Function, class and project-marker navigation |
| `<leader>q` | Sessions | Session lifecycle |
| `<leader>r` | Run | Build and run workflows |
| `<leader>t` | Test | Neotest workflows |
| `<leader>u` | UI | User-interface controls |
| `<leader>w` | Window | Window management |

---

# Codex Workflows

The `<leader>c` group contains Neovim-AIDE's AI-assisted developer workflows.

## Explain

### Normal Mode

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>cE` | Normal | Explain the current line | Codex |
| `<leader>cB` | Normal | Explain the current buffer | Codex |
| `<leader>cU` | Normal | Explain the current function | Codex |
| `<leader>cK` | Normal | Explain the current class | Codex |

### Visual Mode

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>ce` | Visual | Explain selected code using the fast workflow | Codex |
| `<leader>cE` | Visual | Explain selected code using the rigorous workflow | Codex |

---

## Review

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>cu` | Normal | Review the current function | Codex |
| `<leader>ck` | Normal | Review the current class | Codex |

---

## Refactor

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>cR` | Normal | Refactor the current function | Codex |
| `<leader>cP` | Normal | Preview a safe refactor before applying changes | Codex |
| `<leader>cp` | Normal | Apply an AI-generated patch to the current buffer | Codex |
| `<leader>cP` | Visual | Preview a safe rewrite or refactor of the selection | Codex |
| `<leader>ca` | Visual | Apply previewed changes | Codex |

---

## Rewrite

### Normal Mode

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>cl` | Normal | Rewrite the current line | Codex |
| `<leader>cF` | Normal | Rewrite the current buffer using a custom prompt | Codex |
| `<leader>cD` | Normal | Preview a rewrite diff for the current line | Codex |

### Visual Mode

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>cr` | Visual | Rewrite the selected code | Codex |
| `<leader>cd` | Visual | Preview a rewrite diff | Codex |
| `<leader>co` | Visual | Open generated output in a scratch buffer | Codex |
| `<leader>cw` | Visual | Write generated output to disk | Codex |

---

## Project Context

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>cc` | Normal | Toggle project-context injection | Codex |
| `<leader>cC` | Normal | Show the current project context | Codex |

---

## Codex Modes

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>cm` | Normal | Cycle the active Codex mode | Codex mode controller |
| `<leader>cM` | Normal | Show the active Codex mode | Codex mode controller |
| `<leader>cmr` | Normal | Select Refactor mode | Codex mode controller |
| `<leader>cmm` | Normal | Cycle the active Codex mode | Codex mode controller |

Available operating modes include:

- Fast
- Balanced
- Strict
- Refactor

---

## Current and Previous Operations

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>c,` | Normal | Show the last AI-assisted operation | Codex memory |
| `<leader>c.` | Normal | Repeat the last AI-assisted operation | Codex memory |

---

## State, Health and Diagnostics

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>cH` | Normal | Open the Codex health report | Codex health |
| `<leader>cS` | Normal | Show the current workflow state | Codex state |
| `<leader>cT` | Normal | Show latency information | Codex latency |
| `<leader>cV` | Normal | Show the active prompt version | Codex prompts |
| `<leader>cX` | Normal | Show the recovery report | Codex recovery |
| `<leader>cL` | Normal | Open the Codex operational log | Codex logging |
| `<leader>cs` | Normal | Open the Codex scratch buffer | Codex scratch |

---

# Navigation

The `<leader>n` group provides structured navigation through functions, classes and project markers.

## Function Navigation

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>nh` | Normal | Jump to the beginning of the current function | Navigation |
| `<leader>nl` | Normal | Jump to the end of the current function | Navigation |
| `<leader>nj` | Normal | Jump to the next function | Navigation |
| `<leader>nk` | Normal | Jump to the previous function | Navigation |

---

## Code Selection

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>nv` | Normal | Select the current function | Navigation |
| `<leader>nV` | Normal | Select the current class | Navigation |

---

## Project Markers

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>nt` | Normal | Jump to the next project marker | Navigation |
| `<leader>nT` | Normal | Jump to the previous project marker | Navigation |

Supported markers include:

- `TODO`
- `FIXME`
- `BUG`
- `HACK`
- `NOTE`
- `XXX`

---

# Files and Search

The `<leader>f` group contains file operations and Telescope search workflows.

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>fe` | Normal | Toggle the file explorer | NvimTree |
| `<leader>ff` | Normal | Find files | Telescope |
| `<leader>fg` | Normal | Search project text with live grep | Telescope |
| `<leader>fb` | Normal | Search open buffers | Telescope |
| `<leader>fh` | Normal | Search Neovim help | Telescope |
| `<leader>fr` | Normal | Open recent files | Which-key file workflow |
| `<leader>fs` | Normal | Save the current file | Which-key file workflow |
| `<leader>fS` | Normal | Save all modified files | Which-key file workflow |
| `<leader>fn` | Normal | Create a new buffer | Which-key file workflow |

Additional file-tree mappings:

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>e` | Normal | Toggle NvimTree | NvimTree |
| `<leader>.` | Normal | Toggle hidden-file filtering | NvimTree |

---

# Buffers

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>bb` | Normal | List open buffers | Which-key buffer workflow |
| `<leader>bn` | Normal | Move to the next buffer | Which-key buffer workflow |
| `<leader>bp` | Normal | Move to the previous buffer | Which-key buffer workflow |
| `<leader>bd` | Normal | Delete the current buffer | Which-key buffer workflow |

---

# Windows

The `<leader>w` group manages editor windows.

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>wh` | Normal | Move to the window on the left | General keymaps |
| `<leader>wj` | Normal | Move to the window below | General keymaps |
| `<leader>wk` | Normal | Move to the window above | General keymaps |
| `<leader>wl` | Normal | Move to the window on the right | General keymaps |
| `<leader>wv` | Normal | Create a vertical split | Which-key window workflow |
| `<leader>ws` | Normal | Create a horizontal split | Which-key window workflow |
| `<leader>wq` | Normal | Close the current window | Which-key window workflow |
| `<leader>w=` | Normal | Equalise window sizes | Which-key window workflow |
| `<leader>w+` | Normal | Increase window height | Which-key window workflow |
| `<leader>w-` | Normal | Decrease window height | Which-key window workflow |
| `<leader>w>` | Normal | Increase window width | Which-key window workflow |
| `<leader>w<` | Normal | Decrease window width | Which-key window workflow |

General non-grouped workflow:

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>w` | Normal | Save the current buffer | General keymaps |

The direct `<leader>w` save mapping overlaps conceptually with the `<leader>w` window group. This is retained as an established product mapping.

---

# Language Intelligence

The `<leader>l` group combines language-server navigation, diagnostics, formatting and linting.

## LSP Navigation and Actions

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>ld` | Normal | Go to definition | LSP |
| `<leader>lD` | Normal | Go to declaration | LSP |
| `<leader>lr` | Normal | Rename symbol | LSP |
| `<leader>la` | Normal | Show code actions | LSP |
| `<leader>lh` | Normal | Show hover documentation | LSP |
| `<leader>li` | Normal | Find implementations | LSP / Telescope |
| `<leader>lt` | Normal | Go to type definition | LSP |
| `<leader>ls` | Normal | Show document symbols | Telescope |
| `<leader>lS` | Normal | Show workspace symbols | Telescope |

---

## Diagnostics

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>le` | Normal | Show diagnostics for the current line | Diagnostics |
| `<leader>l]` | Normal | Jump to the next diagnostic | Diagnostics |
| `<leader>l[` | Normal | Jump to the previous diagnostic | Diagnostics |

---

## Formatting

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>lf` | Normal | Format the current buffer | Conform |

Conform uses configured external formatters when available and falls back to LSP formatting according to the active formatting policy.

Configured formatter families include:

- Stylua for Lua
- clang-format for C and C++
- Prettier for supported web and document filetypes

---

## Linting

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>ll` | Normal | Run linting | nvim-lint |
| `<leader>lo` | Normal | Open the location list | nvim-lint |

---

# Git

The `<leader>g` group combines global Git actions with contextual Gitsigns mappings.

## General Git Actions

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>gg` | Normal | Open Git status | Fugitive |
| `<leader>gB` | Normal | Open Git blame | Fugitive |
| `<leader>gl` | Normal | Open Lazygit | Lazygit |
| `<leader>gb` | Normal | Show or toggle blame information | Git / Gitsigns |
| `<leader>gd` | Normal | Show diff information | Git / Gitsigns |

---

## Gitsigns Hunk Actions

These mappings are buffer-local and appear when Gitsigns attaches to a Git-controlled buffer.

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `]c` | Normal | Jump to the next Git hunk | Gitsigns |
| `[c` | Normal | Jump to the previous Git hunk | Gitsigns |
| `<leader>gs` | Normal | Stage the current hunk | Gitsigns |
| `<leader>gr` | Normal | Reset the current hunk | Gitsigns |
| `<leader>gS` | Normal | Stage the current buffer | Gitsigns |
| `<leader>gR` | Normal | Reset the current buffer | Gitsigns |
| `<leader>gp` | Normal | Preview the current hunk | Gitsigns |
| `<leader>gd` | Normal | Diff against the index | Gitsigns |
| `<leader>gD` | Normal | Diff against the previous revision | Gitsigns |
| `<leader>gn` | Normal | Move to the next hunk | Gitsigns |
| `<leader>gN` | Normal | Move to the previous hunk | Gitsigns |
| `<leader>gu` | Normal | Undo staging for the current hunk | Gitsigns |
| `<leader>tb` | Normal | Toggle line blame | Gitsigns |
| `<leader>gs` | Visual | Stage the selected lines | Gitsigns |
| `<leader>gr` | Visual | Reset the selected lines | Gitsigns |

---

# Testing

The `<leader>t` group is owned by Neotest.

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>tn` | Normal | Run the nearest test | Neotest |
| `<leader>tf` | Normal | Run tests in the current file | Neotest |
| `<leader>ta` | Normal | Run all tests | Neotest |
| `<leader>tR` | Normal | Run the last test again | Neotest |
| `<leader>ts` | Normal | Toggle the test summary | Neotest |
| `<leader>to` | Normal | Show test output | Neotest |
| `<leader>tO` | Normal | Toggle the output panel | Neotest |
| `<leader>td` | Normal | Debug the nearest test | Neotest |
| `<leader>tG` | Normal | Stop the current test run | Neotest |
| `<leader>tD` | Normal | Attach to or inspect a test debug session | Neotest |

The Neotest summary buffer also provides contextual buffer-local mappings for running and navigating tests.

---

# Debugging

The `<leader>d` group contains DAP debugging workflows.

## Core Debug Controls

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>db` | Normal | Toggle a breakpoint | DAP |
| `<leader>dB` | Normal | Set a conditional breakpoint | DAP |
| `<leader>dn` | Normal | Continue or start debugging | DAP |
| `<leader>dL` | Normal | Run the last debug configuration | DAP |
| `<leader>dC` | Normal | Run to cursor | DAP |
| `<leader>dh` | Normal | Show debug hover information | DAP |
| `<leader>dp` | Normal | Preview the value under the cursor | DAP |
| `<leader>df` | Normal | Open stack frames | DAP |
| `<leader>ds` | Normal | Open scopes | DAP |
| `<leader>dr` | Normal | Open the debug REPL | DAP |
| `<leader>dx` | Normal | Terminate the debug session | DAP |
| `<leader>dc` | Normal | Continue execution | DAP |
| `<leader>do` | Normal | Step over | DAP |
| `<leader>di` | Normal | Step into | DAP |
| `<leader>dO` | Normal | Step out | DAP |
| `<leader>dj` | Normal | Move down the stack | DAP |
| `<leader>dk` | Normal | Move up the stack | DAP |
| `<leader>dR` | Normal | Restart the current frame or session | DAP |
| `<leader>dQ` | Normal | Close or terminate the active session | DAP |
| `<leader>da` | Normal | Run with arguments | DAP |
| `<leader>dv` | Normal | Show variables | DAP |
| `<leader>dm` | Normal | Show memory or debug state | DAP |
| `<leader>dw` | Normal | Manage watches | DAP |
| `<leader>dX` | Normal | Clear breakpoints | DAP |
| `<leader>dW` | Normal | Clear watches | DAP |
| `<leader>du` | Normal | Toggle the DAP UI | DAP UI |
| `<leader>de` | Normal / Visual | Evaluate an expression or selection | DAP |

Function-key controls:

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<F5>` | Normal | Continue or start debugging | DAP |
| `<F10>` | Normal | Step over | DAP |
| `<F11>` | Normal | Step into | DAP |
| `<S-F11>` | Normal | Step out | DAP |

---

# Assembly Debugging

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>ad` | Normal | Start the ARM64 assembly debug workflow | DAP / ASM |
| `<leader>ar` | Normal | Rerun the assembly debug workflow | DAP / ASM |

---

# Sessions

The `<leader>q` group controls persistent editor sessions.

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>qs` | Normal | Save the current session | Persistence |
| `<leader>ql` | Normal | Load the current-directory session | Persistence |
| `<leader>qL` | Normal | Load the last session | Persistence |
| `<leader>qd` | Normal | Stop or disable session persistence | Persistence |
| `<leader>qq` | Normal | Save the session and quit | Persistence |

---

# Markdown

Markdown Preview is the supported document-rendering workflow in Neovim-AIDE.

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>Mp` | Normal | Toggle Markdown Preview | markdown-preview.nvim |
| `<leader>Ms` | Normal | Stop Markdown Preview | markdown-preview.nvim |

Markdown Preview renders the current Markdown document through a local browser preview.

Use the browser's print or Save as PDF functionality when a PDF is required.

---

# Surround Editing

The `<leader>m` group provides stable surround-editing shortcuts backed by `nvim-surround`.

## Common Surround Actions

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>mb` | Normal | Surround the current word with braces | nvim-surround |
| `<leader>mb` | Visual | Surround the selection with braces | nvim-surround |
| `<leader>mp` | Normal | Surround the current word with parentheses | nvim-surround |
| `<leader>mp` | Visual | Surround the selection with parentheses | nvim-surround |
| `<leader>mq` | Normal | Surround with quotes | nvim-surround |
| `<leader>mq` | Visual | Surround the selection with quotes | nvim-surround |
| `<leader>mQ` | Normal | Surround with single quotes | nvim-surround |
| `<leader>mQ` | Visual | Surround the selection with single quotes | nvim-surround |
| `<leader>mB` | Normal | Surround with square brackets | nvim-surround |
| `<leader>mB` | Visual | Surround the selection with square brackets | nvim-surround |
| `<leader>ms` | Normal | Surround with a selected delimiter | nvim-surround |
| `<leader>ms` | Visual | Surround the selection with a delimiter | nvim-surround |
| `<leader>mt` | Normal | Surround with an HTML or XML tag | nvim-surround |
| `<leader>mt` | Visual | Surround the selection with an HTML or XML tag | nvim-surround |
| `<leader>md` | Normal | Delete the surrounding delimiter | nvim-surround |
| `<leader>mc` | Normal | Change the surrounding delimiter | nvim-surround |

---

# Run and Build

The `<leader>r` group contains generic and language-specific run workflows.

## Generic Run Actions

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>rr` | Normal | Run `:make` | Which-key run workflow |
| `<leader>rl` | Normal | Run `:make` silently | Which-key run workflow |

## C and C++

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>rb` | Normal | Build or run the current C/C++ target | Run keymaps |
| `<leader>rd` | Normal | Run or debug the current C/C++ target | Run keymaps |
| `<leader>rm` | Normal | Run the configured make workflow | Run keymaps |

## Rust

These mappings are buffer-local to Rust files.

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>rr` | Normal / Buffer | Run the Rust project | Rust keymaps |
| `<leader>rb` | Normal / Buffer | Build the Rust project | Rust keymaps |
| `<leader>rt` | Normal / Buffer | Test the Rust project | Rust keymaps |

## Snippets

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>rs` | Normal | Reload snippets | LuaSnip |

---

# User Interface

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>ut` | Normal | Cycle the active colour scheme | Theme cycle |

---

# Terminal

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<leader>tt` | Normal / Terminal | Toggle the Quake terminal | Toggleterm |
| `<F12>` | Normal / Terminal | Toggle the Quake terminal | Toggleterm |

Terminal navigation:

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<Esc>` | Terminal | Leave terminal-input mode | Terminal keymaps |
| `<C-h>` | Terminal | Move to the window on the left | Terminal keymaps |
| `<C-j>` | Terminal | Move to the window below | Terminal keymaps |
| `<C-k>` | Terminal | Move to the window above | Terminal keymaps |
| `<C-l>` | Terminal | Move to the window on the right | Terminal keymaps |

---

# Editing Utilities

## Autopairs

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<M-w>` | Insert | Fast-wrap with autopairs | nvim-autopairs |
| `<C-f>` | Insert | Autopairs fast-wrap action | nvim-autopairs |

## Snippets

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `<Tab>` | Insert / Select | Expand a snippet or jump forward | LuaSnip |
| `<S-Tab>` | Insert / Select | Jump backward through snippet fields | LuaSnip |

## Indentation

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `>` | Visual | Indent and reselect | General keymaps |
| `<` | Visual | Outdent and reselect | General keymaps |

## Comments

| Mapping | Mode | Description | Owner |
| --- | --- | --- | --- |
| `gc` | Normal / Visual | Toggle comments using an operator | Comment.nvim |
| `gcc` | Normal | Toggle the current line comment | Comment.nvim |
| `gbc` | Normal | Toggle block comments | Comment.nvim |

---

# Core Ex Commands

## Context

| Command | Description | Owner |
| --- | --- | --- |
| `:CodexContext` | Show the current project-context block | Codex context |
| `:CodexToggleContext` | Toggle project-context injection | Codex context |
| `:CodexCommands` | Open the in-editor Codex command reference | Codex |

---

## Operating Modes

| Command | Description | Owner |
| --- | --- | --- |
| `:CodexMode` | Select the active operating mode | Codex modes |
| `:CodexModeCycle` | Cycle through available modes | Codex modes |
| `:CodexModeList` | List all available modes | Codex modes |

---

## Operation Memory

| Command | Description | Owner |
| --- | --- | --- |
| `:CodexLastOp` | Show the last remembered Codex operation | Codex memory |
| `:CodexLastOpClear` | Clear the remembered operation | Codex memory |
| `:CodexRepeat` | Repeat the last remembered operation | Codex memory |

---

## Health and Diagnostics

| Command | Description | Owner |
| --- | --- | --- |
| `:CodexHealth` | Open the complete health report | Codex health |
| `:CodexHealthCheck` | Run a quick health check | Codex health |
| `:CodexState` | Show the current workflow state | Codex state |
| `:CodexStateHistory` | Show recent state transitions | Codex state |
| `:CodexGuardrails` | Display the active safety guardrails | Codex guardrails |
| `:CodexLatency` | Show latency statistics | Codex latency |
| `:CodexLog` | Open the operational log | Codex logging |
| `:CodexPromptVersion` | Show the active prompt version | Codex prompts |

---

## Recovery

| Command | Description | Owner |
| --- | --- | --- |
| `:CodexRecovery` | Show the last captured failure report | Codex recovery |
| `:CodexRecoveryClear` | Clear the captured failure report | Codex recovery |
| `:CodexExplainFailure` | Ask Codex to explain the last recoverable failure | Codex recovery |

---

## Notifications

| Command | Description | Owner |
| --- | --- | --- |
| `:CodexNotifyPlacement {placement}` | Configure notification placement | Codex notifications |
| `:CodexNotifyTest` | Display a test notification | Codex notifications |

Examples:

```vim
:CodexNotifyPlacement top_right
:CodexNotifyPlacement center
:CodexNotifyPlacement bottom_left
```

---

# Plugin Commands

## Telescope

| Command | Description |
| --- | --- |
| `:Telescope` | Open a Telescope picker |

## NvimTree

| Command | Description |
| --- | --- |
| `:NvimTreeToggle` | Toggle the file explorer |
| `:NvimTreeOpen` | Open the file explorer |
| `:NvimTreeFocus` | Focus the file explorer |

## Markdown Preview

| Command | Description |
| --- | --- |
| `:MarkdownPreview` | Start Markdown Preview |
| `:MarkdownPreviewStop` | Stop Markdown Preview |
| `:MarkdownPreviewToggle` | Toggle Markdown Preview |

## Git

| Command | Description |
| --- | --- |
| `:Git` | Run a Fugitive Git command |
| `:G` | Fugitive shorthand |
| `:Gblame` | Open Git blame |
| `:LazyGit` | Open Lazygit |

## Formatting

| Command | Description |
| --- | --- |
| `:ConformInfo` | Show Conform formatter information |

## Testing

| Command | Description |
| --- | --- |
| `:Neotest` | Access Neotest commands where available |

## Debugging

DAP workflows are primarily exposed through key mappings rather than a single Ex command.

---

# Contextual and Lazy Mappings

Some mappings appear only after a plugin, language server or buffer-specific feature becomes active.

Examples include:

- Gitsigns hunk mappings in Git-controlled buffers
- Rust run mappings in Rust buffers
- Neotest summary-buffer mappings
- LSP actions after an LSP client attaches
- Markdown Preview in Markdown buffers
- surround actions when `nvim-surround` loads
- terminal mappings when Toggleterm is active

Which-key automatically discovers mappings that provide a `desc` field.

---

# Related Documentation

| Document | Purpose |
| --- | --- |
| `README.md` | Product overview and quick start |
| `INSTALL.md` | Installation and bootstrap |
| `ARCHITECTURE.md` | Runtime architecture |
| `docs/CONTRIBUTING.md` | Contributor guide |
| `docs/ai/README.md` | AI Context Pack |
| `docs/releases/RELEASE_PROCESS.md` | Release process |
| `docs/releases/RELEASE_NOTES_R1_6.md` | R1.6 release notes |

---

# Summary

Neovim-AIDE combines traditional Neovim workflows with human-controlled AI assistance.

Its command surface is designed around:

- Correctness
- Control
- Traceability
- Discoverability
- Stable feature ownership

Use Which-key inside Neovim to explore the active command surface interactively.

Use this document as the canonical user-facing reference for Neovim-AIDE commands and key mappings.