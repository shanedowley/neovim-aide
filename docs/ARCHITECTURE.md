# Neovim-AIDE

> A Neovim IDE
> Human-controlled. AI-assisted.

## Runtime Engine

**Codex CLI**

---

# Neovim-AIDE Architecture

Neovim-AIDE is an AI-assisted IDE for Neovim.

This document describes the architecture of the shipped system, the responsibilities of its major runtime subsystems, and the engineering principles that guide their design.

The architecture is intentionally conservative. Rather than maximising automation, it emphasises correctness, explicit developer control and operational visibility.

---

# Architectural Principles

The design of Neovim-AIDE is guided by a small number of engineering principles.

## Correctness

Safe development outcomes take precedence over automation.

## Control

Developers remain responsible for development decisions. AI assists the workflow but does not replace human judgement.

## Traceability

Workflow execution should remain observable, understandable and diagnosable.

## Operational Visibility

The system should make its current state, progress and failures visible rather than hiding them behind background automation.

## Human-controlled. AI-assisted.

AI is treated as a development tool operating within explicit workflows rather than an autonomous agent.

---

# Architectural Overview

Neovim-AIDE consists of a set of cooperating runtime subsystems.

Each subsystem has a clearly defined responsibility.

```text
                  Developer
                      │
            Commands / Key Mappings
                      │
             Workflow Coordination
                      │
            Prompt Construction
                      │
           Runner Coordination
                      │
       Health & Execution Readiness
                      │
               AI Execution
                      │
             Streaming Output
                      │
          Report & Preview Generation
                      │
      Validation & Explicit Confirmation
                      │
               Apply Changes
                      │
     State • Logging • Recovery • Metrics
```

The architecture intentionally provides a single, predictable execution model regardless of the AI-assisted operation being performed.

---

# Runtime Workflow

AI-assisted workflows share a common execution foundation, while their final stages depend on whether the operation is read-only or modifies project files.

```text
User Request
      ↓
Workflow Selection
      ↓
Prompt Construction
      ↓
Runner Coordination
      ↓
Runtime Health Validation
      ↓
AI Execution
      ↓
Streaming Output
      ↓
Structured Report
      ↓
Read-only Result
        or
Preview → Validation → Explicit Confirmation → Apply
      ↓
State / Logging / Metrics
```

Explain, review and diagnostic workflows conclude with a structured result. Workflows that propose source changes continue through preview, validation and explicit developer confirmation before anything is applied.

This shared execution foundation keeps behaviour predictable, simplifies debugging and makes operational state easy to understand.

---

# Core Runtime Subsystems

Neovim-AIDE is organised as a collection of focused runtime subsystems.

Each subsystem has a single primary responsibility and communicates with neighbouring subsystems through well-defined workflow boundaries.

This separation keeps the architecture understandable, maintainable and testable.

---

## Workflow

The workflow subsystem provides the primary entry point into Neovim-AIDE.

It coordinates every AI-assisted workflow from initial request through completion.

Responsibilities include:

- user commands
- key mappings
- workflow selection
- workflow orchestration
- lifecycle coordination

---

## Prompt Construction

Prompt construction transforms developer intent into structured prompts suitable for AI execution.

Responsibilities include:

- prompt templates
- instruction construction
- project context injection
- language-aware prompting
- prompt versioning

---

## Runner

The runner is the central orchestration component.

It coordinates execution from workflow initiation through completion and ensures that each stage executes in the correct order.

Responsibilities include:

- workflow orchestration
- execution scheduling
- preflight validation
- execution coordination
- failure handling

---

## Runtime Health

The runtime health subsystem determines whether AI-assisted workflows can execute safely.

Neovim-AIDE uses a **Stale-While-Revalidate (SWR)** health model.

At startup, the most recently known health state is restored from persistent cache. This allows Neovim to become immediately responsive without performing a blocking health check.

Immediately before an AI-assisted workflow executes, a fresh runtime health check validates the current environment.

Responsibilities include:

- dependency validation
- environment verification
- persistent health cache
- execution gating
- health reporting

This approach combines fast startup with mandatory runtime validation.

---

## Runtime State

Runtime state provides visibility into both environment readiness and workflow execution.

Two complementary state models are maintained.

### Health State

Health state describes whether the environment is capable of safely executing AI-assisted workflows.

Typical states include:

- Unknown
- Health Check Running
- Ready
- Blocked

### Operational State

Operational state reflects the active workflow lifecycle.

Typical states include:

- Running
- Preview
- Validating
- Applied
- Failed

During workflow execution, operational state temporarily takes precedence over health state so that the statusline reflects the activity most relevant to the developer.

---

## AI Execution

The AI execution subsystem delegates model interaction to **Codex CLI**, the execution backend shipped with the current release.

Execution is coordinated through focused runtime modules so that provider-specific concerns remain contained as far as the current architecture permits. A formal provider and model abstraction is reserved for a future release.

Responsibilities include:

- process execution
- asynchronous communication
- response collection
- Codex CLI integration

---

## Streaming Output

Streaming output provides continuous feedback while AI-assisted operations execute.

Rather than waiting for a complete response, Neovim-AIDE streams execution progress as it becomes available.

Responsibilities include:

- stdout streaming
- stderr streaming
- incremental status updates
- latency timing
- output capture

Streaming improves perceived responsiveness while preserving complete operational visibility.

---

## Report Windows

Report windows provide consistent operational feedback throughout workflow execution.

Rather than exposing raw command output, Neovim-AIDE presents structured reports that explain the current operation, its outcome and any required developer action.

Examples include:

- health reports
- validation reports
- execution summaries
- diagnostics

This provides a consistent user experience across all workflows.

---

## Preview

The preview subsystem presents generated changes before they are applied.

Responsibilities include:

- unified diff generation
- review interface
- confirmation workflow

No silent apply path exists.

---

## Validation

Validation provides confidence that generated changes are suitable for application.

Depending on the workflow, validation may include:

- syntax validation
- constrained refactoring
- language-aware analysis

Validation exists to reduce incorrect or unsafe modifications before they reach the developer's project.

---

## Apply

The apply subsystem performs controlled modification of project files.

Changes are applied only after successful completion of the workflow lifecycle and explicit developer confirmation.

The architecture intentionally avoids autonomous source-code modification.

---

## Observability

Operational observability is treated as a core architectural capability rather than an implementation detail.

Responsibilities include:

- structured logging
- workflow state
- latency tracking
- prompt version visibility
- recovery reporting
- diagnostics
- operational metrics

These capabilities support debugging, troubleshooting and performance analysis while giving developers confidence in every AI-assisted workflow.

---

## Bootstrap

Bootstrap prepares a new environment for reliable operation.

Responsibilities include:

- dependency verification
- installation validation
- runtime directory validation
- configuration checks

Development follows a **sandbox-first validation** philosophy.

Changes are validated in isolated environments before they are merged or released, helping ensure reproducible installations and reducing regression risk.

---

# Runtime Model

Neovim-AIDE separates configuration, runtime state, cache and operational data in accordance with the XDG Base Directory Specification.

This separation improves:

- maintainability
- reproducibility
- troubleshooting
- operational hygiene

Runtime-generated artefacts are intentionally kept outside the configuration directory.

---

# Repository Structure

The repository broadly mirrors the architectural organisation of the runtime.

```text
bootstrap.sh

lua/
    <runtime configuration and focused Codex modules>

docs/
tests/
demo/
tools/
```

The runtime is divided into focused modules covering workflow coordination, execution, health, prompts, state, preview, validation, reporting, logging and related operational concerns.

This alignment between architecture and implementation helps contributors navigate the codebase while reducing architectural drift over time.

---

# Safety Model

Neovim-AIDE is intentionally designed to favour explicit development workflows over autonomous behaviour.

Safety mechanisms include:

- runtime health validation
- preview-before-apply
- validation-before-apply
- explicit developer confirmation
- structured operational logging
- observable workflow state
- sandbox-first validation

The architecture assumes:

- AI-generated code can be incorrect.
- Development environments can degrade.
- Human review remains essential.

---

# Architectural Non-Goals

Neovim-AIDE is intentionally **not** designed to become:

- an autonomous coding agent
- an invisible background automation system
- a zero-review code generator
- a fully automatic source-code mutator

The architecture deliberately favours explicit interaction over hidden automation.

---

# Summary

Neovim-AIDE is an AI-assisted IDE built around predictable workflows, runtime validation and explicit developer control.

Its architecture combines workflow orchestration, runtime health validation, streaming execution, operational visibility and explicit developer approval into a coherent development model.

The guiding principles remain unchanged:

- Correctness
- Control
- Traceability

**Human-controlled. AI-assisted.**

