# Review Memory — khelam Cost Discipline

**Purpose**: Persistent record of weekly reviews, implemented waste-reduction measures, and open actions. Updated after each weekly review (append-only).

---

## Review History

| Date | Key Findings | Review Doc |
|------|--------------|------------|
| 2026-08-05 | 8 waste instances (DTO rebuild, double @librarian, router guard ×2, deferred API tests, known-broken E2E, samseer rework, widget-test hang, minor churn). Top 3 cuts: upfront scope questions, no deferred diagnosis, check Blockers before E2E. | `docs/reviews/2026-08-05.md` |

---

## Implemented Measures (as of 2026-08-05, commit `145d653`)

| Measure | Location | What It Closes |
|---------|----------|----------------|
| Cost Discipline rules (scope question, codegraph/graphify first, targeted tests, live tests on live-path change only, no commits with known failures, check Blockers before E2E, shared fakes, read files once) | `AGENTS.md` Cost Discipline section | DTO rebuild, deferred diagnosis, redundant verification, integration vs blockers, shared token store, scope back-and-forth |
| Session template `Environment` section | `AGENTS.md` session template | Service-kill accidents (`pkill`) |
| Weekly review automation (script + launchd Sun 18:00) | `scripts/weekly_review.sh`, `scripts/com.khelam.weekly-review.plist` | Automated audit cadence |
| Shared `RecordingTokenStore` fake | `test/helpers/recording_token_store.dart` | Widget-test hang, per-file duplication |
| Review agent reads this memory doc + must cite codegraph/graphify usage | `scripts/weekly_review.sh` prompt | Keeps memory across weeks; dogfoods tooling discipline |
| Pre-edit rule: every symbol-level edit logs its codegraph/graphify lookup in the Work Log | `AGENTS.md` Cost Discipline | Enforces the tooling rule (0-use week was the top burn) |
| Pre-commit gate (analyze + full test, blocks on failure; docs-only skip) | `.git/hooks/pre-commit` → `scripts/pre_commit_check.sh` | Enforces "no commits with known failures" mechanically |
| "Verify current state before debugging" + known-good commands | `AGENTS.md` Cost Discipline | Kills stale-idToken/wrong-port/tsx DI debug cycles |
| Cost note for >5k-token operations, before starting | `AGENTS.md` Cost Discipline | Makes invisible token spend visible |
| `Cleanup` subsection in session template | `AGENTS.md` template | Prevents temp instrumentation / regen noise in commits |
| Dependency-constraint check before `flutter pub add` | `AGENTS.md` Cost Discipline | Avoids version-solving failures (samseer 0.1.0 class) |
| Commons consumer check (analyze both apps when commons changed) | `scripts/weekly_review.sh` | Catches breaking commons changes weekly |
| Sidetrack guard (global): passive `[nudge]` one-liners on prompt drift, major drift → one question; weekly review audits user prompt drift (category 6) | `~/.config/opencode/AGENTS.md` + `scripts/weekly_review.sh` | Catches user-side scope creep / deferred decisions / missing bars before they cost cycles |
| Hard Rule #2 (Strict Rules with rationale, `as T` covered, generated-code exemption) + precedence chain; review-memory wired into Hard Rule #1; session lifecycle (30-day archive); global-config pointer; symbol-level-edit definition; estimate feedback loop; session-time commons check; read-once carve-out | `AGENTS.md` (audit-driven restructure, 2026-08-05) | Closes the audit's structural + rule-coverage gaps |
| Mechanical codegraph/graphify tripwire + filename-date session selection | `scripts/weekly_review.sh` (2026-08-05) | Replaces pure self-report with a computed check; kills mtime double-count |
| Quarterly rule gut-check | `docs/reviews/review-memory.md` How-to-Update | Tracks whether the rule set stays net-positive |

---

## Waste Register Summary (Full Week 07-31 → 08-05)

**Categories with UNCOVERED items** (not fully addressed by implemented measures):
- Tooling discipline: codegraph/graphify rule exists but **not followed** (0 uses in 08-05 session vs 20+ grep/read round trips) — now enforced via pre-edit Work Log rule (closed 08-05)
- Scope back-and-forth: samseer wired app-side → move to commons; auth slice grilling → scrap → execute — covered by scope-question rule + user prompting review
- Output waste: Graphify 15.5k token build, PDF manual venv, stale debug cycles — covered by >5k cost-note + verify-state rules
- Diagnosis waste: stale idToken, wrong port (5000 = AirPlay), tsx DI bug, wrong lead on API tests — covered by verify-state rule + pre-commit gate
- Process gaps: temp instrumentation left in commons, stray files, platform regen noise, dependency constraints — covered by Cleanup subsection + dep-check rule

Full register: `docs/reviews/2026-08-05-full-history-audit.md` (librarian audit, all sessions).

---

## Open Actions (Ranked)

None open as of 2026-08-05 — all 8 from the librarian audit implemented (see Implemented Measures). New actions get added here after each weekly review.

---

## How to Update

After each weekly review (manual or automated):
1. Append a row to **Review History** table.
2. Update **Implemented Measures** if new rules/scripts added.
3. Move closed actions to **Implemented Measures**; add new **Open Actions** from the review's "Top 3 cuts" + any new patterns.
4. Keep under ~120 lines — prune old detail, keep decisions.
5. **Quarterly rule gut-check (every 4th review):** for each rule in AGENTS.md Cost Discipline + Hard Rule #2, ask "did this rule cost more than it saved this quarter?" Drop or merge rules not earning their keep; log the decision in the Review History row.
