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

---

## Waste Register Summary (Full Week 07-31 → 08-05)

**Categories with UNCOVERED items** (not fully addressed by implemented measures):
- Tooling discipline: codegraph/graphify rule exists but **not followed** (0 uses in 08-05 session vs 20+ grep/read round trips)
- Scope back-and-forth: samseer wired app-side → move to commons; auth slice grilling → scrap → execute
- Output waste: Graphify 15.5k token build, PDF manual venv, stale debug cycles
- Diagnosis waste: stale idToken, wrong port (5000 = AirPlay), tsx DI bug, wrong lead on API tests
- Process gaps: temp instrumentation left in commons, stray files, platform regen noise, dependency constraints (samseer 0.1.0 due to Dart 3.8)

Full register: see librarian audit of all sessions (2026-08-05).

---

## Open Actions (Ranked)

| # | Action | Owner | Target |
|---|--------|-------|--------|
| 1 | Pre-edit hook: require `codegraph explore`/`graphify query` logged in session before symbol edits | Agent | Next session |
| 2 | Pre-commit gate: block commit if affected tests fail | Agent | Next session |
| 3 | Commons consumer check in weekly review script | Agent | Before 2026-08-09 run |
| 4 | "Verify current state before debugging" rule in Cost Discipline | Agent | Next AGENTS.md edit |
| 5 | Cost note for >5k token ops in session file | Agent | Next session |
| 6 | Cleanup subsection in session template (temp logs, instrumentation, regen files) | Agent | Next AGENTS.md edit |
| 7 | Dependency constraint check before `flutter pub add` | Agent | Next session |
| 8 | Review agent prompt: require codegraph/graphify citations | Agent | Before 2026-08-09 run |

---

## How to Update

After each weekly review (manual or automated):
1. Append a row to **Review History** table.
2. Update **Implemented Measures** if new rules/scripts added.
3. Move closed actions to **Implemented Measures**; add new **Open Actions** from the review's "Top 3 cuts" + any new patterns.
4. Keep under ~120 lines — prune old detail, keep decisions.
