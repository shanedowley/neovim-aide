# Neovim-AIDE

> A Neovim IDE
> Human-controlled. AI-assisted.

## AI Engine

**Codex**

---

# Installing Neovim-AIDE

This guide explains how to install, bootstrap and validate a new Neovim-AIDE installation.

Following this guide establishes a reproducible, self-contained AI-assisted development environment built on Neovim and OpenAI's Codex CLI.

---

# Supported Platforms

| Platform | Status       |
| -------- | ------------ |
| macOS    | Supported    |
| Linux    | Experimental |
| Windows  | Unsupported  |

Neovim-AIDE is currently developed and validated on macOS Apple Silicon using XDG-compliant Neovim installations.

Linux support is actively improving but should currently be regarded as experimental.

---

# Requirements

## Required Dependencies

| Dependency   | Purpose               |
| ------------ | --------------------- |
| Neovim 0.11+ | Editor runtime        |
| Git          | Repository management |
| Clang        | Validation pipeline   |
| Diff         | Preview generation    |
| Codex CLI    | AI-assisted workflows |

Without Codex CLI, Neovim-AIDE remains fully usable as a Neovim configuration, but AI-assisted workflows will not be available.

---

## Optional Dependencies

| Dependency | Purpose                       |
| ---------- | ----------------------------- |
| Node.js    | JavaScript tooling            |
| npm        | JavaScript package management |

---

# Installation

## Clone the Repository

Clone Neovim-AIDE into your Neovim configuration directory.

```bash
git clone https://github.com/shanedowley/neovim-aide.git ~/.config/nvim
cd ~/.config/nvim
```

---

# Bootstrap

The bootstrap script validates the installation and prepares the runtime environment.

The bootstrap script verifies:

- supported platform
- required dependencies
- Neovim configuration
- runtime directory layout
- plugin manager installation
- operational health

| Command                                     | Purpose                                          |
| ------------------------------------------- | ------------------------------------------------ |
| `./scripts/bootstrap.sh --check`            | Validate the installation                        |
| `./scripts/bootstrap.sh --sync`             | Synchronise plugins and validate the environment |
| `./scripts/bootstrap.sh --test-health-gate` | Verify runtime health gate behaviour             |

A typical first installation should begin with:

```bash
./scripts/bootstrap.sh --check
```

Once validation succeeds, synchronise plugins if required:

```bash
./scripts/bootstrap.sh --sync
```

---

# First Launch

Start Neovim.

```bash
nvim
```

On first launch the runtime health status will typically display:

```text
? Codex Unknown
```

This is expected.

Neovim-AIDE uses a **Stale-While-Revalidate** runtime health model.

Startup is intentionally fast, with runtime validation occurring when AI-assisted workflows are first invoked.

Run:

```vim
:CodexHealth
```

to verify that the installation is healthy.

---

# First Workflow

Open a C or C++ source file.

For example:

```bash
nvim hello.c
```

Visually select some source code in Visual mode and execute an AI-assisted workflow.

Example:

```text
<leader>cE
```

This validates:

- Codex CLI integration
- prompt construction
- workflow execution
- runtime health
- operational reporting

---

# Updating Neovim-AIDE

A typical upgrade workflow is:

```bash
git pull
./scripts/bootstrap.sh --sync
```

After synchronising, verify the installation inside Neovim:

```vim
:CodexHealth
```

This confirms that the environment remains healthy after the upgrade.

---

# Runtime Layout

Neovim-AIDE follows the XDG Base Directory Specification.

Expected directory layout:

```text
~/.config/nvim
~/.local/share/nvim
~/.local/state/nvim
~/.cache/nvim
```

Configuration belongs in:

```text
~/.config/nvim
```

Runtime-generated data should remain in the appropriate XDG runtime directories.

The bootstrap script validates this separation automatically.

---

# Operational Logging

Operational logs are written to:

```text
~/.local/state/nvim/codex.log
```

Logging provides visibility into:

- workflow execution
- runtime validation
- diagnostics
- failures
- latency

This information can be useful when troubleshooting installation or runtime issues.

---

# Troubleshooting

## Missing Plugins

Synchronise plugins again:

```bash
./scripts/bootstrap.sh --sync
```

The bootstrap script will ensure that required plugins are installed.

---

## Codex CLI Not Found

If Codex CLI is unavailable, install it and rerun:

```bash
./scripts/bootstrap.sh --check
```

---

## Runtime Health Problems

Inside Neovim run:

```vim
:CodexHealth
```

If problems are reported, inspect:

```text
~/.local/state/nvim/codex.log
```

for additional diagnostics.

---

## Runtime Pollution

Runtime-generated files should not exist inside:

```text
~/.config/nvim
```

The bootstrap script reports any runtime hygiene issues that require attention.

---

# Related Documentation

| Document               | Purpose                          |
| ---------------------- | -------------------------------- |
| `README.md`            | Product overview and quick start |
| `docs/README.md`       | Documentation index              |
| `docs/COMMANDS.md`     | Commands and developer workflows |
| `docs/ARCHITECTURE.md` | System architecture              |
| `docs/CONTRIBUTING.md` | Contribution guidelines          |

---

# Summary

Neovim-AIDE is designed to provide a reproducible, observable and maintainable AI-assisted software development environment.

Following this guide establishes a clean, validated foundation for AI-assisted software development while preserving Neovim-AIDE's guiding principles of Correctness, Control and Traceability.
