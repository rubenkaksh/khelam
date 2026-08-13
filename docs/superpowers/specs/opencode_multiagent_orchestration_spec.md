# OpenCode Multi-Agent Orchestration & Loop Engineering System Spec

## 1. System Overview & State Architecture

This specification defines the multi-agent execution pipeline, trust gates, state management rules, and model routing strategy for the OpenCode Go development environment.

### 1.1 Consolidated State Model (Single Source of Truth)
To prevent duplicate files and state drift, the loop architecture binds directly to existing project files:

| Loop Component | Consolidated Target | Primary Responsibility |
| :--- | :--- | :--- |
| **Active Queue (`STATE.md`)** | `tasklog.md` | Tracks active queue, immediate focus, and daily priorities. |
| **Loop State (`LOOP-STATE.json`)** | Session Status File | Tracks token spend, session budget limits, retry counts, and execution metrics. |
| **Escalations / Open Actions** | `review-memory.md` | Human review queue for unresolvable errors, circuit breaker triggers, and strategic audits. |

---

## 2. Planning vs. Execution Split

Cognitive labor is strictly separated to maximize model efficiency and protect OpenCode subscription limits:

* **The Planner (The Brain):** Managed by **`GLM-5.2`** (Fallback: `Qwen3.7 Max`). Evaluates intent, decomposes tasks, manages tool/terminal loop sequencing, and enforces architectural compliance.
* **The Executor (The Muscle):** Driven by **`MiMo-V2.5-Pro`** (heavy logic/complex code) and **`DeepSeek V4 Flash`** (routine files/UI edits). Applies inline edits, handles generation, and writes unit test suites.

### 2.1 Model Allocation Matrix

| Role | Primary Target Model | Secondary / Budget Model | OpenCode Target Pool | Primary Responsibility |
| :--- | :--- | :--- | :--- | :--- |
| **1. Orchestrator / Planner** | `GLM-5.2` | `Qwen3.7 Plus` | Deep Pool ($60) | High-horizon planning, agent routing, state dispatch to `tasklog.md`. |
| **2. Architect** | `Qwen3.7 Max` | `GLM-5.1` | Deep Pool ($60) | System design, schema mapping, Clean Architecture boundary enforcement. |
| **3. Build / Executor** | `MiMo-V2.5-Pro` | `DeepSeek V4 Flash` | Balanced / Deep | Code generation, inline edits, unit tests execution. |
| **4. Research** | `GPT 5.6 Luna` | `Kimi K2.7 Code` | Restricted ($15) / Deep | Scanning massive docs, dependency tracking, stack-trace breakdown. |
| **5. Subagents** | `MiniMax M3` | `MiMo-V2.5` | Deep Pool ($60) | Log pruning, JSON formatting, lint fixes, micro-tasks. |

---

## 3. Comprehensive Agent System Prompts

### 3.1 Orchestrator (The Planner)
* **Target Model:** `GLM-5.2`
* **Directive:**
  > "You are the Master Orchestrator and lead system engineer. Your primary job is to analyze the user's workspace prompt, create a logical execution roadmap in tasklog.md, and spawn specialized subagents to handle specific codebase files. Do not write raw code implementations yourself. Instead, manage tool loops, review files submitted by the Build Agent, and run self-correcting cycles on terminal compilation errors."

### 3.2 Architect
* **Target Model:** `Qwen3.7 Max`
* **Directive:**
  > "You are the System Architect. You specialize in deep logical reasoning, data structures, state management isolation, and clean architecture borders. When a new layout or feature is requested, map out the technical design schema and layout definitions. Package your design rules into structural instructions for the Build Agent."

### 3.3 Build (The Executor)
* **Target Model:** `MiMo-V2.5-Pro` / `DeepSeek V4 Flash`
* **Directive:**
  > "You are the Execution Engine. Your sole responsibility is writing clean, syntactically flawless code blocks based on architectural specifications. Avoid conversational pleasantries. Output direct code changes, respect local dependency trees, generate thorough unit tests, and execute precise line changes."

### 3.4 Research (The Context Specialist)
* **Target Model:** `GPT 5.6 Luna` / `Kimi K2.7 Code`
* **Directive:**
  > "You are the Research Agent. You possess an extensive context window capable of ingesting massive repository codebases, runtime logs, and framework documentations. Your primary objective is to digest long contextual material, pinpoint where breaking changes occur, look up framework specs, and relay a concise summary to the Planner."

### 3.5 Subagents (Micro-Operators)
* **Target Model:** `MiniMax M3`
* **Directive:**
  > "You are a Micro-Task Subagent. You excel at rigid tool handling, functional script calls, and strict JSON formatting. Your workspace is narrow: you take a single file or array, run atomic corrections (such as lint fixes, log truncation, or pattern matching), and return data exactly as expected by system API schemas."

---

## 4. Trust Dial & Safety Gates (L1 / L2 / L3)

The pipeline inherits a unified 3-tier autonomy and verification model:

* **L1 (Human Gate / Triage):** Read-only planning. Triage agent updates `tasklog.md` with daily queue recommendations but halts execution for human sign-off.
* **L2 (Sandboxed Execution):** Agents execute in isolated worktrees or local state, invoking the `loop-verifier` gate. Changes are held until manual approval or evening review.
* **L3 (Verifier-Driven Autonomy):** Unattended execution where automated inner-loop verifiers validate code integrity and allow auto-commits/merges without direct human intervention.

### 4.1 Two-Layer Verification Architecture

```
[ Maker Agent (Build) ]
          │
          ▼
[ Proposed Diff / Code Changes ]
          │
          ▼
[ Inner-Loop Verifier Gate ]  ── (Fails) ──► Feedback to Maker (Retry / Self-Correct)
   • Architecture / Skill Rules
   • State File Consistency (`tasklog.md`)
   • Fast/Targeted Unit Tests
          │
       (Passes)
          ▼
[ Git Pre-Commit Gate ]      ── (Fails) ──► Block Commit (Halt)
   • `flutter analyze`
   • Full Project Test Suite
          │
       (Passes)
          ▼
[ Checkpoint Commit Written ]
          │
          ▼
[ Evening Outer-Loop Review ]  ──► Updates `review-memory.md` & Backlog
```

---

## 5. Triage & Delivery Pipeline Mechanics

State processing (AI logic) and content delivery (Deterministic scripts) are strictly decoupled:

1. **Upstream (Daily Triage Loop - AI Agent):**
   * Scans `backlog.md` and `review-memory.md`.
   * Re-ranks daily items and writes the prioritized active queue into `tasklog.md`.
2. **Downstream (`daily_digest.sh` - Shell Script):**
   * Reads `tasklog.md` directly.
   * Renders the Discord layout/card payload and triggers webhooks (Costs **0 LLM tokens**).

---

## 6. `@cobusgreyling/loop` Governance & Integration

* **Scaffold-Only Integration:** `@cobusgreyling/loop` is used strictly for utility subcommands (`loop doctor`, `loop audit`, `loop cost`). Execution dispatch remains with your native shell scripts.
* **Safe Initialization (P2 Compliance):** Run `loop init` in a temporary directory (`/tmp/loop-scaffold`) and manually extract schema additions into existing `AGENTS.md` and `opencode.json` files to prevent silent overwrites.
* **Path Aliasing:** Map `STATE.md` and `LOOP-STATE.json` contracts via symbolic links or paths directly to `tasklog.md` and session status files.

---

## 7. Loop Engineering Overlay & Circuit Breakers

### 7.1 The "Write -> Run Tests -> Fix -> Repeat" Loop
* **Planner (`GLM-5.2`):** Ingests test/compilation errors and generates targeted structural instructions (e.g., *"Fix null safety exception at line 42"*).
* **Executor (`MiMo-V2.5-Pro` / `DeepSeek V4 Flash`):** Receives structural patch instructions, updates files, and re-invokes testing.

### 7.2 The 3-Strike Circuit Breaker
1. If the Executor fails to resolve an error within **3 consecutive loop attempts**, execution halts immediately.
2. The Planner escalates the failing stack trace and file context to **`Qwen3.7 Max`** for a single-turn structural architecture overview.
3. If unresolved after `Qwen3.7 Max` assessment, the issue downgrades to an **Open Action in `review-memory.md`** and halts the agent process for human review.

### 7.3 Context Truncation Guardrail
Before submitting error logs into successive loop iterations, the **`MiniMax M3`** subagent strips duplicate stack trace lines, passing only the final 50 lines of relevant compilation output to preserve context windows.

---

## 8. Anti-Throttling Financial Guardrails (OpenCode Go)

1. **Reserve Heavy Models:** `Grok 4.5`, `Qwen3.8 Max`, and `Kimi K3` are excluded from background loops. They are reserved exclusively for explicit manual triggers during catastrophic system failures.
2. **Maximize Deep Pool Usage:** Direct all recurring terminal validations, lint checks, and routine file generation to `DeepSeek V4 Flash` and `MiniMax M3` to leverage OpenCode's deep discount pooling.
