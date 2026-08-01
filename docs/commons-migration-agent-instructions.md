# Agent Instructions: Extract Shared Code into `commons` Package
## Purpose

Scan the child repo (the customized fork — e.g. khelam, forked from the base
template per ADR-0004) for reusable code, extract it into a new standalone
Flutter package repo called `commons`, and wire `commons` into **both** the base
repo (the forkable parent template) and the child repo.

> **Why a separate `commons` repo at all?** The child was forked from base, and
> base is the forkable parent — so why not just keep the shared code in base and
> sync it into forks? Three reasons, in order of importance:
> 1. **Independent versioning.** `commons` gets its own semver tags (`v0.1.0`, …)
>    that *every* fork pins by `ref:`. Base can consume `commons` the same way
>    future forks can — base is not special-cased as the "real" owner.
> 2. **Child-driven iteration without base churn.** Post-ADR-0004, khelam evolved
>    shared code independently of base: 5 new atomic widgets, `DioApiClient`
>    relocated to `lib/core/network/`, centralized theme, and `go_router`
>    navigation. Extracting these to `commons` makes that innovation portable to
>    base and to other forks without forcing a re-fork.
> 3. **Multi-fork reuse.** `~/Projects` already hosts several forkable-derived
>    apps (booker, …); `commons` is the single shared source all of them cite.
>
> This only pays off if base is **actively maintained and will adopt `commons`**
> (see Phase 2). If base is dormant, the third repo is doing work for nothing —
> keep the shared code in base instead.

`commons` is wired in as a **git dependency pinned by tag** in each repo's
committed `pubspec.yaml` (so CI and teammates without a local clone resolve via
git), plus a **local path override** in an uncommitted `pubspec_overrides.yaml`
(so the operator resolves to a local folder for fast iteration). This
git-dep + path-override pattern is the canonical approach for *separate* repos;
pub *workspaces* only apply if you later fold base + child + commons into a
single monorepo (see Phase 6 note).

> **Post-ADR-0004 structure**: after the 2026-08-01 refactor (commit `601ec7b`),
> the child repo no longer has `lib/services/`, `lib/widgets/`, `lib/utils/`,
> or `lib/screens/`. Shared code now lives in `lib/ui/common/` (the atomic
> widget catalog), `lib/core/network/` (DioApiClient), `lib/ui/core/` (theme),
> and `lib/ui/navigation/`. Feature code is per-feature vertical slices under
> `lib/features/<feature>/` and is NOT shared across forks — see the updated
> scan paths in Phase 1 below.

## Required inputs (fill in before running)
```
BASE_REPO_PATH    = <path to the base template — the forkable parent,
                    e.g. /Users/rubenk/Projects/forkable  (NOT ~/dev — verify it exists)>
CHILD_REPO_PATH   = <path to the child fork — the customized app,
                    e.g. /Users/rubenk/projects/khel-service/khelam>
COMMONS_REPO_PATH = <path where commons should be created,
                    e.g. /Users/rubenk/projects/commons  (sibling of forkable;
                    OUTSIDE khel-service per user decision 2026-08-01)>
GIT_HOST_URL      = <e.g. https://github.com/yourorg>
```
**Sibling layout (the important constraint):** `commons` lives at
`/Users/rubenk/projects/commons` — a sibling of the base repo
(`/Users/rubenk/projects/forkable`, relative override `../commons` works) but
NOT of the child (`khelam` is nested under `projects/khel-service/`). So in
Phase 6: **forkable** uses the sibling-relative `path: ../commons`; **khelam**
uses an **absolute** `path: /Users/rubenk/projects/commons` in its
`pubspec_overrides.yaml` (or the git dependency with no override). Only repos
co-located as siblings get the relative form.

---

## Phase 0 — Preflight & Scaffold

1. Confirm `flutter --version` reports **Flutter ≥ 3.24 / Dart ≥ 3.6** on the
   machine that will create `commons` and edit both consumers. (The git-dep +
   `pubspec_overrides.yaml` pattern itself has been stable since Dart 2.16, but
   3.24/3.6 is the modern floor: it is what the installed SDK (3.32/Dart 3.8)
   exceeds by a wide margin, and it keeps the *pub workspaces* alternative —
   only viable if you later merge the three repos into one monorepo — open.) If
   the consumer repos (`pubspec.yaml` `environment.sdk`) pin an older SDK than
   `commons` will require, raise them in the same pass. If stuck on an older
   toolchain, flag it — the fallback is a single shared `path:` dependency with
   no git dependency, which is less flexible.
2. Create the remote repo `commons` under `GIT_HOST_URL` (via `gh repo create`
   / `glab repo create`, or manually in the UI — this step needs human/API
   credentials, do not attempt to fake it).
3. Scaffold the package locally:
   ```bash
   cd $(dirname $COMMONS_REPO_PATH)
   flutter create --template=package commons
   cd commons
   git init
   git add .
   git commit -m "chore: scaffold commons package"
   git remote add origin $GIT_HOST_URL/commons.git
   git push -u origin main
   ```

---

## Phase 1 — Scan child repo for extraction candidates

Goal: produce a manifest, **not** to move any files yet.

For every file under `$CHILD_REPO_PATH/lib/`, apply these checks:

| Check | Rule |
|---|---|
| Location | Prioritize `lib/ui/common/**` (the atomic widget catalog — see `docs/commons.md`), `lib/core/**` (shared infra like `DioApiClient`), `lib/ui/core/**` (theme), `lib/ui/navigation/**`. Skip `lib/features/**` — per ADR-0004 these are per-feature vertical slices owned by each fork and are NOT shared across forks; skip `main.dart` and anything importing feature-specific models. |
| Coupling | `grep` the file's imports. If it imports anything from `lib/features/` or app-specific model/controller files, flag as **COUPLED — needs decoupling before move**, don't auto-include. (`lib/screens/` was removed by ADR-0004, so it is not a live coupling check — `lib/features/` is the only shared code boundary that still exists.) |
| Hardcoded values | Search for literal app name, package ID, API base URLs, brand colors. Flag any hit as **COUPLED**. |
| Already in base? | Compare against `$BASE_REPO_PATH` (the forkable parent). **Important:** base predates ADR-0004 — its layout diverged from the child's (`DioApiClient` lived at `lib/data/services/dio_api_client.dart` in base, now `lib/core/network/dio_api_client.dart` in the child; base ships 4/9 `lib/ui/common/` widgets, not 9). A naive relative-path `diff` produces false **NEW**/**MODIFIED** results because files moved between directories. Trace file history across renames first (`git log --follow` / `git diff --find-renames <fork-point>..HEAD`). <br>• Identical content (rename-aware) → **MIGRATE (dedup — `commons` becomes canonical; delete from BOTH base and child, not "skip")** <br>• Present but different → **MIGRATE (divergent fork — resolve one canonical in `commons`; delete from both)** <br>• Absent in base → **NEW (child-only candidate — migrate; delete from child)** <br>• Present only in base (child has no copy) → **BASE-LEGACY (out of scope this pass — base's own cleanup)** |

Example scan script to run and adapt:
```bash
cd $CHILD_REPO_PATH
for f in $(find lib/ui/common lib/core lib/ui/core lib/ui/navigation -type f -name "*.dart" 2>/dev/null); do
  echo "== $f =="
  grep -E "import '.*/(features)/" "$f" && echo "  -> COUPLED (imports feature code — ADR-0004 removed lib/screens/)"
  base_file="$BASE_REPO_PATH/$f"
  if [ -f "$base_file" ]; then
    diff -q "$f" "$base_file" >/dev/null && echo "  -> MIGRATE (dedup identical to base — canonical in commons)" || echo "  -> MIGRATE (differs from base — resolve canonical in commons)"
  else
    echo "  -> NEW (child-only — verify with git history before trusting)"
  fi
done
# NOTE: to detect BASE-LEGACY files (in base, absent in child), invert: list base
# lib/ui/common/** and flag any not present under the child.
```

Output a `candidates.md` with **five** buckets: **NEW**, **MIGRATE** (dedup /
divergent), **BASE-LEGACY**, **COUPLED**, each listing file paths and one-line
reasoning. **Default first migration slice = the 9 files in `lib/ui/common/`**
(the atomic widget catalog). `lib/core/network/dio_api_client.dart`,
`lib/ui/core/`, and `lib/ui/navigation/` are scanned in the same pass but treated
as **follow-up slices** — Phase 2 must explicitly approve each slice before it
moves.

> **`docs/commons.md` is the manifest.** The atomic-widget checklist there is the
> de facto source of truth for the shared widget catalog. Cross-reference it
> during the scan and keep it in sync as widgets migrate into `commons` — if a
> widget in `lib/ui/common/` is not on the `commons.md` roster, flag it for the
> approval gate rather than auto-including it.
>
> **Tests move with the code — but check what actually exists.** Verify under
> `test/` which common widgets have coverage before migrating: only the files
> with tests need their tests ported (see Phase 4). Do **not** assume the whole
> catalog is tested.

---

## Phase 2 — 🛑 Human approval gate

**STOP HERE.** Present `candidates.md` to the user. Do not proceed to Phase 3
until they explicitly:

1. Approve **which slice** migrates in this pass (default = the 9
   `lib/ui/common/` widgets). Everything else stays a follow-up slice that
   re-runs Phase 1+2.
2. Approve which NEW/MIGRATE files to migrate and confirm how to handle COUPLED
   files (decouple now, leave in child, or skip).
3. **Confirm base participation** — ask the user: (a) is the base repo actively
   maintained and will it adopt `commons`? (b) will base delete its divergent
   old copies (`lib/ui/common/{buttons,feedback,inputs,typography}.dart`,
   `lib/data/services/dio_api_client.dart`, …) and point at `commons`? If the user
   answers "base is dormant / no," drop the third-repo premise (Phase 1) and keep
   shared code in base instead. This gate exists because the entire migration is
   wasted work if base won't consume `commons`.

---

## Phase 3 — Extract the approved slice into `commons`

**Default (recommended): clean import.** Copy the approved files into
`commons/lib/src/<category>/` and commit once, crediting the source. The child
repo's git history is *not* lost — it stays intact in the child repo itself. For
the default first slice (`lib/ui/common/`, ~9 small widget files spanning a few
commits) a clean import is lower-risk and more debuggable than rewriting
history, and the bar for preserving blame on a brand-new package repo is high.

```bash
cd $CHILD_REPO_PATH
mkdir -p $COMMONS_REPO_PATH/lib/src/widgets
cp lib/ui/common/*.dart $COMMONS_REPO_PATH/lib/src/widgets/
cp test/ui/common/*.dart $COMMONS_REPO_PATH/test/src/widgets/ 2>/dev/null || true
cd $COMMONS_REPO_PATH
git add -A
git commit -m "import: shared widgets from child repo (khelam lib/ui/common)"
```

> **Advanced — preserve child git history (optional).** If the operator
> specifically needs `git blame`/audit continuity in `commons`:
> **If all approved files share one common parent folder** (e.g. all under
> `lib/ui/common/`), use `git subtree split` (in a scratch clone, never the
> working repo):
> ```bash
> cd /tmp && git clone $CHILD_REPO_PATH child-scratch && cd child-scratch
> git subtree split --prefix=lib/ui/common -b commons-import
> cd $COMMONS_REPO_PATH
> git remote add child-history /tmp/child-scratch
> git fetch child-history commons-import
> git merge child-history/commons-import --allow-unrelated-histories -m "import: shared code from child repo"
> git remote remove child-history
> ```
> **If approved files are scattered across multiple unrelated folders**, use
> `git filter-repo` instead (install via `pip install git-filter-repo`):
> ```bash
> cd /tmp && git clone $CHILD_REPO_PATH child-scratch && cd child-scratch
> git filter-repo --path lib/ui/common/buttons.dart --path lib/core/network/dio_api_client.dart --force
> cd $COMMONS_REPO_PATH
> git remote add child-history /tmp/child-scratch
> git fetch child-history
> git merge child-history/main --allow-unrelated-histories -m "import: shared code from child repo"
> git remote remove child-history
> ```
> Caveat: both methods are brittle when files move between directories after
> `601ec7b` (rename-aware history), and they only cover files present in the
> *child* — duplicated files that live only in *base* won't be recovered. Prefer
> the clean import unless you have a concrete need for the history.

---

## Phase 4 — Restructure into a proper package

1. Move imported files into `lib/src/<category>/` — map to the categories in
   `docs/commons.md` (e.g. `lib/src/widgets/buttons.dart`, `lib/src/widgets/inputs.dart`,
   `lib/src/network/`, `lib/src/theme/`).
2. Create a single barrel file `lib/commons.dart` exporting the public API:
   ```dart
   export 'src/widgets/buttons.dart';
   export 'src/widgets/inputs.dart';
   // ...
   ```
3. Fix now-broken relative imports inside moved files. **Rewrite package imports
   from the child's package name to `commons`** — moved test files and widgets
   import e.g. `package:khelam/ui/common/bottom_sheet.dart`; change these to
   `package:commons/commons.dart`. Run `dart fix --apply` in `commons/` and fix
   the rest by hand.
4. Inspect original imports for third-party packages used (e.g. `dio`,
   `get_it`) and add matching versions to `commons/pubspec.yaml`.
5. Move the tests that travel with the migrated files: copy the
   `test/ui/common/*.dart` files that cover migrated widgets into
   `test/src/widgets/` (Phase 1 verified which existed — the common catalog has
   tests for **2 of 9** widgets: `bottom_sheet` and `phone_input`; the other seven
   migrate unported). Add `flutter_test` to `commons` dev_dependencies and
   rewrite their imports to `package:commons/...`.
6. Run `flutter pub get && flutter analyze` inside `commons/` and fix errors.

---

## Phase 5 — Tag initial version

```bash
cd $COMMONS_REPO_PATH
# set version: 0.1.0 in pubspec.yaml
git add -A && git commit -m "feat: initial commons package v0.1.0"
git tag v0.1.0
git push origin main --tags
```

---

## Phase 6 — Wire the git + local-path-override pattern

> **Pattern choice (grill note).** This git-dep + `pubspec_overrides.yaml`
> pattern is the canonical way to share a package *across separate repos* with
> local iteration: the committed `pubspec.yaml` pins `commons` by git `ref:` (so
> CI and teammates without a local clone resolve via git), and the uncommitted
> override swaps in a local `path:` for the operator who has `commons` cloned.
> (Cited: dart-lang/pub#4387; flutter.dev/docs/packages-and-plugins/using-packages.)
> Pub **workspaces** instead require collapsing base + child + commons into a
> *single* monorepo — they do not help the cross-repo model documented here. If
> you later merge the three repos into one, switch to a root `workspace:` and
> drop `pubspec_overrides.yaml` entirely.

In **both** `$BASE_REPO_PATH/pubspec.yaml` and `$CHILD_REPO_PATH/pubspec.yaml`
(this file IS committed — everyone without an override resolves via git):
```yaml
dependencies:
  commons:
    git:
      url: $GIT_HOST_URL/commons.git
      ref: v0.1.0
```

In **both** repos, create `pubspec_overrides.yaml` (this file is NOT committed — it's
your personal local override). **Child (local iteration) — commons is a sibling of the
child:**
```yaml
dependency_overrides:
  commons:
    path: ../commons
```
**Base — only if base sits next to `commons` (same parent folder):**
```yaml
dependency_overrides:
  commons:
    path: ../commons
```
**Base — if base is on a different parent (e.g. forkable under `~/Projects` vs
commons under `~/projects/khel-service`):** omit the override and resolve `commons`
purely from git (`flutter pub get`); or, as a fallback, point at an absolute path:
```yaml
dependency_overrides:
  commons:
    path: /abs/path/to/commons   # absolute fallback only
```

Add `pubspec_overrides.yaml` to each repo's `.gitignore` — **this is required**,
not optional: neither base nor child ships one (verified) and without the entry
the override file leaks into the repo. Add if absent:
```
pubspec_overrides.yaml
```

Run in both repos:
```bash
flutter pub get
```
Confirm it resolves to the local path (pub prints that `commons` is resolved via
override) rather than fetching from git.

---

## Phase 7 — Remove migrated code from child (and base, **if** base is participating)

1. Delete the original files/folders now living in `commons` (from the child).
2. Replace their imports throughout the child repo with:
   ```dart
   import 'package:commons/commons.dart';
   ```
3. Run `flutter analyze` and `dart fix --apply`, resolve remaining errors.
4. Run existing tests: `flutter test` (including the ported `test/ui/common/*`
   tests that were moved into `commons`; the unported widgets simply have no
   tests to carry over).

> **Base cleanup is conditional on Phase 2.** Only proceed with base if the
> approval gate confirmed base is actively maintained and will adopt `commons`.
> If yes, in `$BASE_REPO_PATH` repeat the migration in reverse: delete base's
> divergent old copies (`lib/ui/common/{buttons,feedback,inputs,typography}.dart`,
> `lib/data/services/dio_api_client.dart`, etc.), replace their imports with
> `package:commons/commons.dart`, wire `base`'s git dep + override per Phase 6,
> and run `flutter analyze && flutter test` in base. If Phase 2 answered "base
> is dormant / no," **skip this** — shared code stays in base; `commons` then
> serves only the child (and future forks), and base is out of scope.

---

## Phase 8 — Verify end-to-end

- [ ] `flutter pub get` succeeds in `commons`, `base`, and `child`
- [ ] `flutter analyze` is clean in all three (`commons`, `base`, `child`)
- [ ] `flutter test` passes in **all three**: `commons` (the ported widget tests),
      `base`, and `child` (child tests must still pass after imports switched to
      `package:commons/commons.dart`)
- [ ] `flutter run` / a debug build launches successfully for `child`
- [ ] `git status` in `base`/`child` shows `pubspec_overrides.yaml` as **ignored
      (untracked, not staged)** — this only holds if Phase 6's `.gitignore` entry
      was applied; if it shows as a normal untracked file, it will leak into
      commits. Confirm `git check-ignore pubspec_overrides.yaml` succeeds.

---

## Phase 9 — Ongoing workflow (repeat for future syncs)

- Whenever new reusable code appears in a child repo, re-run **Phase 1**
  scan against `commons` (not just `base`) to find what's missing.
- Bump `commons` version (semver) on each addition, tag it, push.
- Update the `ref:` in `base`/child `pubspec.yaml` files that don't use the
  local override (e.g. CI, teammates without a local `commons` clone).
- Anyone actively developing across repos together clones `commons` as a
  sibling of the repo they are iterating in and adds the same
  `pubspec_overrides.yaml` locally (only the active pair needs co-location;
  others resolve via git).
- Consider **Melos** once you have more than one shared package. Note: modern
  Melos runs *on top of* pub workspaces (Dart 3.6+/Flutter 3.27+), so if you
  consolidate `commons` + `base` + children into a single monorepo, use a root
  `workspace:` and let Melos own task-running/versioning (see the Phase 6
  workspaces note). In the cross-repo model kept here, Melos can still bootstrap
  per-repo overrides, but is not required for a single shared package.
