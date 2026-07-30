# Neovim-AIDE

> A Neovim IDE
> Human-controlled. AI-assisted.

# Release Notes

## Release 1.6

**Repository Cleanup and Architectural Consistency**

---

## Overview

Release 1.6 is a focused cleanup release.

It removes obsolete, unreachable, duplicated and experimental configuration
while preserving the established Neovim-AIDE workflows.

Compared with the final R1.5 branch, R1.6 removes more than 1,300 lines of
obsolete or duplicated repository content. It does not introduce a major new
end-user feature. Its purpose is to leave the project clearer, more accurate
and easier to maintain before the next planned development phase.

# Highlights

## Leaner Startup and Plugin Discovery

The startup configuration now relies on Lazy.nvim's normal plugin-directory
discovery rather than maintaining a parallel explicit import layer.

Redundant explicit imports, obsolete Mason and LSP placeholders, old
compatibility paths in `init.lua` and a stale Treesitter lockfile entry have
been removed. The active plugin specifications continue to be discovered
normally.

## Removal of Obsolete and Experimental Code

R1.6 removes:

- the unreachable `lua/commands.lua` module;
- the obsolete `lua/theme_controller.lua` implementation superseded by the
  active theme-cycle module;
- unused experimental VimTeX support and its lockfile entry;
- obsolete TeX and PDF Which-key workflows;
- dead Hop mappings; and
- the stale `:WKDump` debugging command.

## Clearer Mapping Ownership

Which-key now focuses more closely on discovery and grouping rather than
duplicating mappings owned by feature modules.

R1.6 removes duplicate Which-key mappings already provided by Telescope,
window navigation and Neotest.

It also stabilises two mapping areas:

- surround mappings are owned by the `nvim-surround` plugin specification and
  keep the same meaning before and after plugin loading; and
- `<leader>lf` is owned by Conform and consistently uses the configured
  external-formatter policy with LSP formatting as a fallback.

These changes eliminate mapping ownership transitions during a Neovim
session.

## Development Documentation

The AI Context Pack has been consolidated into focused canonical guidance for
human-controlled, AI-assisted development. Documentation now also includes the
sandbox validation procedure used throughout development and release
verification.

# Compatibility

R1.6 preserves the established supported Neovim-AIDE workflows and does not
change the existing `:Codex*` command namespace.

No configuration migration is required for the supported feature set.

Users who independently relied on the removed experimental VimTeX or TeX/PDF
mappings will need to maintain that functionality in their own configuration.

# Looking Ahead

R1.6 provides the stable cleanup baseline for the planned Java-focused R2.0
release.

R1.6 reflects the project's preference for small, evidence-based changes that
improve maintainability without unnecessary behavioural change.

**Human-controlled. AI-assisted.**
