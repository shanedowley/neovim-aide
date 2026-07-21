# Neovim-AIDE

> A Neovim IDE
> Human-controlled. AI-assisted.

## AI Engine

**Codex**

---

# What is Neovim-AIDE?

Neovim-AIDE is an AI-assisted IDE for Neovim.

It combines AI-assisted software development workflows with runtime validation, operational visibility and explicit developer control, allowing AI to strengthen software development practice without replacing human judgement.

Neovim-AIDE is designed around three core principles:

- **Correctness**
- **Control**
- **Traceability**

The AI assists.

The developer decides.

---

# Why Neovim-AIDE Exists

Many AI coding tools optimise for speed and automation.

Neovim-AIDE instead optimises for:

- developer confidence
- operational safety
- explicit review
- deterministic workflows
- observable behaviour
- recoverable failures

The goal is not autonomous coding.

The goal is trustworthy AI-assisted software development.

---

# Latest Release

**Current Public Release: R1.5**

Neovim-AIDE R1.5 is a focused Developer Flow release.

Highlights include:

- Explain Current Buffer
- Explain Current Function and Class
- Review Current Function and Class
- Improved developer navigation
- Documentation refresh

Release notes:

- `docs/releases/RELEASE_NOTES_R1_5.md`

Earlier release notes are listed in the Documentation section below.

---

# Developer Flow

Neovim-AIDE is organised around developer workflows rather than isolated AI commands.

Developer workflows include:

- explain the current line, buffer, function or class
- review the current function or class
- safely preview refactoring changes
- perform controlled source-code mutation
- function and class navigation
- function and class selection
- code-marker navigation
- runtime health validation
- operational diagnostics
- failure recovery
- latency instrumentation

Every workflow follows the same philosophy:

```text
Request
    ↓
Validate
    ↓
Execute
    ↓
Review
    ↓
Approve
    ↓
Apply (when applicable)
```

Read-only workflows stop after review.

Mutation workflows require explicit developer approval.

---

# Quick Start

Clone the repository:

```bash
git clone https://github.com/shanedowley/neovim-aide.git ~/.config/nvim
cd ~/.config/nvim
```

Validate the installation:

```bash
./scripts/bootstrap.sh --check
```

Launch Neovim and verify runtime health:

```vim
:CodexHealth
```

Open a source file, visually select some code and run:

```text
<leader>cE
```

to execute your first explainability workflow.

For complete installation instructions see:

- `INSTALL.md`

---

# Requirements

## Required

- Neovim 0.11+
- git
- clang
- diff
- Codex CLI
- authenticated OpenAI account

## Recommended

- Neovim 0.12.x
- macOS Apple Silicon

## Optional

- Node.js
- npm

Node.js is only required for JavaScript-related workflows.

---

# Documentation

Documentation is organised by purpose.

## Getting Started

- `INSTALL.md`

Installation, bootstrap validation and first-run guidance.

## Commands

- `docs/COMMANDS.md`

Developer workflows, key mappings and Ex commands.

## Architecture

- `docs/ARCHITECTURE.md`

Runtime architecture, workflow model, health model and operational design.

## Contributing

- `docs/CONTRIBUTING.md`

Contribution guidelines, project philosophy and sandbox-first validation.

## Documentation Index

- `docs/README.md`

Complete documentation map.

## Release History

- `docs/releases/RELEASE_NOTES_RC1_0.md`
- `docs/releases/RELEASE_NOTES_R1_1.md`
- `docs/releases/RELEASE_NOTES_R1_3.md`
- `docs/releases/RELEASE_NOTES_R1_4.md`

---

# Key Features

## AI-Assisted Development

- explainability workflows
- review workflows
- controlled refactoring
- safe mutation
- prompt versioning

## Operational Confidence

- runtime health validation
- workflow state visibility
- structured logging
- latency instrumentation
- failure recovery

## Developer Experience

- function and class navigation
- code-marker navigation
- DAP integration
- sandbox-first validation
- integrated diagnostics

---

# Supported Platforms

| Platform | Status       |
| -------- | ------------ |
| macOS    | Supported    |
| Linux    | Experimental |
| Windows  | Unsupported  |

Neovim-AIDE is currently developed and validated on macOS Apple Silicon.

---

# Roadmap

Near-term development focuses on:

- continued developer workflow improvements
- platform hardening
- documentation quality
- operational observability

Future major releases will introduce provider abstraction and support for multiple AI model providers while preserving the existing human-controlled workflow model.

---

# Acknowledgements

Neovim-AIDE exists because of the remarkable work of those who shaped modern programmable editors.

With gratitude to:

- Tim Thompson, creator of Stevie
- Bram Moolenaar, creator of Vim

Their emphasis on composability, transparency and developer control continues to influence Neovim-AIDE today.

---

# Closing

Neovim-AIDE is an AI-assisted IDE built around explicit developer workflows rather than autonomous automation.

Its guiding principles remain unchanged:

- Correctness
- Control
- Traceability

**Human-controlled. AI-assisted.**
