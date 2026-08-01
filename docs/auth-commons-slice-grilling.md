# Commons Auth Slice — Grilling Output & Open Decisions

> Status: **PLANNED, NOT STARTED.** Grilling done 2026-08-01 (architect subagent, evidence-based). Open decisions below were stored per user request ("store your questions in a .md file we'll pick this later") — the global engineering-context discussion was **scrapped for now** (last section, parked).

## Evidence (from the grill, read against actual code)

1. The auth slice is **~98% identical** across khelam + forkable — `auth_service.dart`, `auth_user.dart` (+freezed/g), `auth_dependencies.dart`, and the entire bodies of `login_view.dart` + `auth_cubit.dart` are byte-identical. Only divergences are identity strings:
   - `mock_auth_service.dart`: `demo@khelam.dev`/`Khelam Demo` vs `demo@forkable.dev`/`Forkable Demo`
   - `auth_cubit.dart` catch-block: `'Use demo@<fork>.dev and password123.'` (hardcoded — a latent identity leak)
   - `login_view.dart`: AppBar title, pre-filled email, demo-fill button text
2. The login view uses **raw Material widgets** — it re-implements `TextInput`, `PasswordInput`, button catalog that already exist in commons. Catalog gaps exposed: buttons have no `icon`/`isLoading` props; `TextInput` has no `keyboardType`/`textInputAction`.
3. **commons has a strict dep profile** (`dio` + `flutter` only — no bloc/router/freezed). Moving the cubit/service/model in would drag three new deps into the package.

## Refined plan (from the grill)

- **commons v0.4.0 (additive):** `lib/src/auth/login_screen.dart` — presentational `LoginScreen` shell (`Scaffold`+`AppBar`+`Form`+fields+error+submit+fill-demo), params: `appBarTitle`, `appBarActions`, `subtitle`, `onSubmit(email,password)`, `isLoading`, `errorMessage`, `demoEmail`, `demoPassword`, controllers, validators. Barrel export. ~4-5 widget tests (21 → ~25).
- **Catalog additions (additive):** `FilledButton`/`PrimaryButton` + optional `icon` + `isLoading`; `TextInput` + optional `keyboardType` + `textInputAction`.
- **khelam diff:** `login_view.dart` → thin wrapper (~15 lines) reading cubit state, keeping the `BlocConsumer` redirect listener; fix cubit `catch (_)` to propagate exception message; `ref: v0.4.0`. Router/DI unchanged.
- **forkable diff:** same wrapper with `'Forkable Login'` + demo creds; `ref: v0.4.0`.
- **Test gates:** commons ~25/25, khelam 30/30, forkable 5/5. Migration order: commons → khelam → forkable (additive, order-safe).

## Open decisions (yay/nay needed before implementation)

1. **Scope** — presentational `LoginScreen` shell only (cubit/service/model/mock/DI/router stay per-fork)? *(rec: yes — full slice would freeze khelam's future JWT evolution + drag bloc/freezed into commons)*
2. **AppBar ownership** — shell owns `Scaffold`+`AppBar`, fork injects `appBarTitle`+`appBarActions`? *(rec: yes)*
3. **Catalog gaps** — extend `FilledButton`/`PrimaryButton` (icon+isLoading) + `TextInput` (keyboardType+textInputAction) as part of v0.4.0? *(rec: yes)*
4. **Cubit error leak** — fix `catch (_)` → propagate exception message in both forks this pass? *(rec: yes)*
5. **Redirect listener** — stays in fork's `LoginView` wrapper (shell nav-agnostic)? *(rec: yes)*
6. **Version/cadence** — ship v0.4.0 now, one-pass consumer pin? *(rec: yes)*
7. *(Scrapped 2026-08-01 per user)* Global engineering context across khelam/commons/forkable — see parked section below.

## Parked: global Flutter engineering context (scrapped for now)

User: "Let's scrap context discussion for now." Architect's option analysis (for when/if revived):
- (a) dedicated 4th repo `rubenkaksh/flutter-app-context` (AGENTS.md + CONTEXT.md + docs/adr/ + docs/engineering/) — best but heaviest (sync = submodule/subrepo/citation)
- (b) `docs/engineering/` copied per repo — cheap now, drifts
- (c) git submodule into each `docs/engineering/`
- (d) stash standards in `commons/` docs — mixes concerns
- (e) defer, codify pattern as an ADR (e.g. adr-0005-shared-engineering-context.md) — lowest risk; was the architect's recommendation
