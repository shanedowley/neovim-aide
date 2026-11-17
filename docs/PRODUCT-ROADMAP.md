# Neovim-AIDE R2.0 — Strategic Product Roadmap

**Product:** Neovim-AIDE  
**Positioning:** _A Neovim IDE. Human-controlled. AI-assisted._  
**Status:** Strategic direction and living roadmap  
**As of:** 17 November 2026  
**Owner of priorities and implementation decisions:** Human developer

> **Vision:** Build a developer-centred IDE in which AI assistance grows more useful as it gains _relevant, trustworthy understanding of the project_—its code, architecture, decisions and history—while the human remains in control of intent, changes and acceptance.

## 1. Why R2.0 exists

R1.x established a capable, responsive Neovim development environment with integrated AI-assisted workflows. R2.0 advances that foundation from isolated AI operations towards **project-aware, traceable, increasingly intelligent development assistance**.

Today, an AI model can explain a buffer or propose a change. The opportunity is to help it understand **why the code is shaped as it is**, what the project has previously decided, which constraints are authoritative and what has been learned through development.

The intended outcome is not greater automation for its own sake. It is **better developer judgement, less repeated explanation, fewer context mistakes and higher-quality assistance**.

## 2. Product principles

1. **Correctness:** Evidence and validation take precedence over plausible-sounding output.
2. **Control:** The human sets goals, approves decisions and applies or authorises changes. AI does not silently acquire authority.
3. **Traceability:** Important AI inputs, decisions, recommendations and outcomes should be inspectable and attributable.
4. **Project context over generic chat history:** Useful knowledge is grounded in the repository, its decisions and the work performed on it.
5. **Models replaceable; capability durable:** Lead, Explorer, Builder, Reviewer and future roles are capabilities, not hardwired model identities. Models can be selected and changed per role.
6. **The organisation is software:** Design roles, interfaces, delegation, review and authority as carefully as product components; make organisational boundaries reinforce modular product boundaries.
7. **Progressive, evidence-led delivery:** Build the smallest valuable vertical slice, verify it, then extend it based on demonstrated developer benefit.
8. **Portable by design:** Support macOS and Linux through platform-neutral interfaces and explicit capability checks; do not claim Linux runtime support until verified.

## 3. The long-term opportunity: accumulating project intelligence

Neovim-AIDE should develop a more useful understanding of a project as the human, editor and AI work together over time.

| Maturity                                  | Capability                                                                                                                            | Developer value                                             |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| **1 — Project awareness**                 | Understand the captured source, repository, relevant documents and current conventions.                                               | More contextual answers than a buffer-only prompt.          |
| **2 — Project memory**                    | Retain selected decisions, rationale, architectural changes, previous issues and validated outcomes across sessions.                  | Less repeated explanation; continuity of intent.            |
| **3 — Accumulating project intelligence** | Select relevant knowledge, detect conflicts with established decisions, recognise recurring patterns and recommend better next steps. | Better assistance informed by the project's own experience. |

**Important distinction:** A transcript of past AI interactions is not automatically project knowledge. Durable project memory should be **curated, project-scoped, source-linked, revisable and human-governed**. It must distinguish established decisions from hypotheses, superseded guidance and transient observations.

For example, if a project establishes that Codex proposes patches while the developer applies edits in Neovim, the system should be able to recognise that as a standing authority boundary—not merely retrieve an old conversation mentioning it. The human may revise that boundary explicitly.

## 4. R2.0 strategic Epics

The following is the **current provisional value-priority order**, not a commitment to execute each Epic sequentially or complete every idea within R2.0.

| Priority | Epic                                            | Strategic outcome                                                                                  |
| -------- | ----------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| **1**    | **E2 — Project-Aware Development**              | AI assistance understands relevant project structure, conventions, decisions and history.          |
| **2**    | **E1 — Intelligent AI Assistance**              | AI help becomes more relevant and useful through deliberate context, model selection and feedback. |
| **3**    | **E4 — Development Safety and Traceability**    | Developer authority, input provenance, validation and recovery remain clear and reliable.          |
| **4**    | **E3 — Human-Controlled Agentic Development**   | Support bounded collaboration among AI roles while retaining human direction and acceptance.       |
| **5**    | **E5 — Multi-Language Development**             | Extend consistent, high-quality workflows across supported languages and tools.                    |
| **6**    | **E6 — Development Experience and Performance** | Keep the editing environment fast, coherent, navigable and low-friction.                           |

These Epics reinforce one another. E2 establishes useful project understanding; E4 makes that understanding auditable; E1 and E3 build on both. E5 and E6 maintain the quality of the everyday developer experience.

### E2 — Project-Aware Development: active focus

- **F1 — Project Context Awareness:** Establish reliable, inspectable project-informed AI requests.
- **F2 — Intelligent Context Selection:** Identify and propose relevant context without requiring the developer to select everything manually.
- **F3 — Cross-Surface Working Continuity:** Carry appropriately governed context between Neovim-AIDE and adjacent development surfaces such as Codex CLI in Ghostty; deferred until simpler foundations prove value.
- **F4 — Context Inspection and Traceability:** Make context inputs, omissions, sources and provenance transparent.

**Current Story:** **E2-F1-S1 — Establish Project-Aware Explain Context.** This Story remains open beyond its completed B1 implementation milestone.

## 5. Delivery roadmap: outcome-led stages

No target dates are assigned here. Progression depends on evidence and explicit human reprioritisation.

| Stage                                  | Focus                                                                                                                                 | Intended evidence / decision gate                                                                                     | Status                                                                                     |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| **Foundation**                         | Reliable source capture, repository identity, validated execution location and native project-instruction integration boundaries.     | Captured requests and execution location remain stable through deferred work.                                         | Completed for current Explain pathway.                                                     |
| **B1 — Project-Informed Explain**      | Select one repository document; append bounded lower-trust evidence; protect recovery; inspect exactly what the application supplied. | Correctness, cancellation, compatibility, content-boundary and persistence tests pass.                                | **Accepted; locally committed** as `039d7f1` on `main`, not yet pushed as of this roadmap. |
| **C — Developer-Value Validation**     | Compare baseline Explain with project-informed Explain using the same source, model and prompt policy.                                | Observable improvement in factual accuracy, project-specific relevance or actionable insight; identify failure modes. | **Next.** No live comparison completed yet.                                                |
| **B2 — Bounded Provenance**            | Retain a small, metadata-only history of Explain requests and outcomes; project-local, excluded from Git.                             | Ten-record bounded history, correct attribution, no sensitive payload persistence, inspectable omissions.             | Planned; not implemented.                                                                  |
| **F1 closeout**                        | Integrate evidence, user guidance and accepted limitations.                                                                           | Human acceptance of the Story's actual value and remaining risks.                                                     | Pending.                                                                                   |
| **F2 — Intelligent Context Selection** | Propose relevant project documents or knowledge based on task and repository evidence.                                                | Better relevance with explicit visibility, bounded cost and human override.                                           | Candidate next capability after F1 value evidence.                                         |
| **Project memory / continuity**        | Curate decisions, rationale, lessons and cross-session knowledge.                                                                     | Durable knowledge remains source-linked, revisable and human-authorised.                                              | Strategic direction; scope and release allocation undecided.                               |
| **Agentic development**                | Bounded Lead / Explorer / Builder / Reviewer collaboration with per-role model assignment.                                            | Delegation, review and approval remain testable and human-governed.                                                   | Future E3 direction; not authorised as autonomous editing.                                 |

### What B1 now does

For **current-buffer Explain**, Neovim-AIDE can:

- Capture the exact buffer text, including unsaved edits, with its source and repository identity.
- Offer **no supplementary document** (the default) or one explicitly selected repository-relative text document, capped at **16 KiB**.
- Treat that document as **lower-trust background evidence**, not an instruction overriding the developer.
- Continue safely with a visible omission if the document is unsuitable or unavailable.
- Keep enriched instructions out of normal operation memory and prompt logs, and persist only approved metadata for protected failure recovery.
- Display the latest submitted application's inputs through **`:CodexExplainContext`**, without pretending to show the complete effective Codex context.

**B1 is infrastructure and workflow proof, not proof of better model answers.** The latter is the purpose of Stage C.

## 6. How we will judge product value

For the next controlled experiment, compare **baseline** and **project-informed** Explain on the same real source and with the same model and core prompt policy. Inspect the actual application-supplied inputs, then evaluate answers on:

- **Correctness:** Does the explanation accurately describe the code and its behaviour?
- **Project relevance:** Does it connect code to real architectural decisions and conventions rather than inventing context?
- **Developer usefulness:** Does it clarify why the implementation exists, key trade-offs and sensible next investigative steps?
- **Trustworthiness:** Does it distinguish evidence from inference and avoid treating supplementary content as commands?
- **Cost and friction:** Is any quality gain worth the additional selection effort, latency and tokens?

A successful experiment should produce **specific examples and documented shortcomings**, not just a subjective impression that an answer sounds better. Negative results can be equally valuable: they should guide whether F2's automatic selection is warranted and what it needs to improve.

## 7. Future architecture: context, memory and authority

A useful working separation is:

| Layer                   | What belongs there                                                                                  | Governance                                                                     |
| ----------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| **Project truth**       | Source, repository-maintained instructions, architecture, conventions, approved decisions.          | Human-approved, versioned where appropriate.                                   |
| **Request context**     | Captured buffer, chosen evidence, model/prompt policy, visible omissions.                           | Explicit, bounded and inspectable per request.                                 |
| **Provenance**          | Request identity, source attribution, document references/hashes, outcomes and validation metadata. | Bounded retention; avoid storing sensitive bodies by default.                  |
| **Project memory**      | Selected rationale, outcomes, known constraints and learning that should survive sessions.          | Curated; source-linked; revisable; distinguish provisional from authoritative. |
| **AI roles and models** | Task-specific reasoning and proposals from replaceable models.                                      | Per-role routing and human acceptance; no model is the ultimate authority.     |

**Architectural hypothesis:** Project intelligence should be accumulated through explicit learning and validation, rather than silent promotion of prior model output into project truth.

This structure supports future continuity across Neovim, CLI tools and models without making an opaque conversation history the foundation of product behaviour.

## 8. Boundaries and risks to manage

- **Developer authority:** Codex CLI currently acts as a read-only analyst/developer proposing exact changes; the human applies changes in Neovim. Autonomous editing is not implied by the roadmap.
- **Native Codex context:** Neovim-AIDE can inspect its _application-supplied inputs_ but cannot claim to know the full effective native instruction set or execution permissions. `AGENTS.md` remains a native Codex concern.
- **Instruction-file exclusions:** Known native filenames are excluded from supplementary selection; additional configured fallbacks may be outside the application's visibility.
- **Sensitive content:** Inspected source and documents can be sensitive. Application-controlled persistence protections do not govern Codex's own storage, explicit exports or third-party plugins.
- **Filesystem races:** Existing guarded document capture reduces risk but does not eliminate every pathname/TOCTOU race.
- **Linux parity:** macOS verification does not establish Linux runtime correctness. Test on real Linux environments before claiming support.
- **Memory quality:** Historic mistakes or stale decisions must not become permanent authority through repetition.
- **Complexity and economics:** Automated retrieval, multi-role orchestration and memory must justify latency, token costs and maintenance burden.

## 9. Immediate priorities and decision points

1. **Run Stage C:** Establish the real developer value of the B1 feature using a controlled, human-approved live Codex comparison.
2. **Document verified behaviour and limits:** Explain the selection and inspector workflows, native-context boundaries and configuration/platform caveats.
3. **Scope B2 deliberately:** Define the minimum useful metadata-only provenance record before implementing persistence.
4. **Use evidence to prioritise F2:** Intelligent context selection should respond to observed gaps in manual project-informed Explain.
5. **Develop the longer-term project-memory model:** Decide what knowledge is worth retaining, who can approve it, how it is revised and how it travels across development surfaces.

## 10. Strategic success statement

R2.0 will succeed if Neovim-AIDE becomes **a more effective thinking and development partner because it understands the project, can show what informed its recommendations, learns from validated work over time and never obscures who is in control**.

The destination is not an IDE that replaces the developer. It is an IDE in which **human judgement is amplified by progressively richer, trustworthy project intelligence**.

---

_Living strategic roadmap. Epic order, Story sequencing and release scope remain subject to explicit human decisions. Completed verification is not a claim that future capabilities, Linux runtime parity or AI-answer quality have already been established._
