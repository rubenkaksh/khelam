# Agent Optimization & Learning Strategy

*To be integrated into `Agents.md` to govern agent behavior, prevent token waste, and enforce strict process boundaries.*

## 1. System Wins: Core Directives (Reward & Maintain)
These behaviors have proven highly effective and must be strictly maintained across all agent operations:
*   **MANDATORY: Pre-edit Work Log Rule:** Agents must continue to perform `codegraph` and `graphify` lookups *before* executing edits. The baseline expectation is active research over assumption. 
*   **MANDATORY: Strict Testing Discipline:** All code changes must pass pre-commit gates and commons consumer checks before completion. The current rate of 17-19 justified full suite runs per week is the gold standard.
*   **Cost Efficiency Routing:** Continue delegating tasks to free-tier models (DeepSeek, Nemotron, Mimo) wherever applicable to maintain the $0.00 cost baseline despite high token volume.

---

## 2. Efficiency & Token Waste Mitigation

### A. Session Lifecycle Management (Combating 93% Cache Burn)
*   **RULE: Max Session Lifespan:** Agents must not append endlessly to long-running continuations (e.g., sessions spanning 100+ hours). 
*   **ACTION:** When a session exceeds 24 hours of active context or shows signs of severe cache bloat, the agent must proactively propose summarizing the current state and opening a fresh session file to reset the context window.

### B. Subagent Empty-State Validation
*   **RULE: Halt on EMPTY:** If a delegated subagent (like `@librarian`) returns an `EMPTY` result, the general agent **MUST NOT** blindly accept it and trigger a generic re-run.
*   **ACTION:** The caller agent must halt, validate the query parameters sent to the subagent, and confirm the target data actually exists before attempting another run.

### C. Estimation Calibration
*   **RULE: Baseline Adjustment:** Agent token estimation heuristics must be updated. 
*   **ACTION:** All script generation, specification drafting, and validation batches must baseline at **~35,000 tokens** minimum. Stop underestimating these batches at 10k-15k.

---

## 3. Workflow & Process Deficits

### A. The Scoping-Question Rule (Agent-Side)
*   **RULE: No Assumed Scopes:** Agents are strictly forbidden from assuming broad directory scopes (e.g., `~/projects/**`) or executing batch operations without explicit user confirmation.
*   **ACTION:** If the target directory or scope is ambiguous, the agent must pause and ask a clarifying question before proceeding to implementation. 

### B. Safe Documentation Handling (Preventing Overwrites)
*   **RULE: Append/Patch Only:** Subagents (specifically `@architect`) are forbidden from performing destructive overwrites on documentation and session files (e.g., `docs/sessions/*.md`).
*   **ACTION:** All documentation updates must use strict append operations or precise diff-patching.

### C. Upfront Requirements Gathering (Preventing Trickle-Down Churn)
*   **RULE: Comprehensive Spec Confirmation:** Before implementing complex layouts, formatting, or E2E pipelines (e.g., Discord digest formatting), the agent must request the full specification.
*   **ACTION:** Proactively ask the user: *"Before I implement, please confirm: Will this require file attachments? Should the output be split into multiple messages or kept as one? Are there specific divider requirements?"* Do not implement until the full layout is confirmed to prevent multiple E2E rebuild cycles.
