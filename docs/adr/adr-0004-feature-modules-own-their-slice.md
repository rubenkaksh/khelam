# ADR-0004: Feature Modules Own Their Vertical Slice

**Date**: 2026-08-01  
**Status**: Accepted  
**Deciders**: @rubenk

## Context

The 2026-08-01 architecture review (from first commit `946db2e`) found the app was
feature-first **only in the UI layer**. The booking feature — the product — was split
across five top-level namespaces:

```
lib/ui/features/schedule/   (views, widgets, bloc, di)
lib/domain/models/          (booking, slot, schedule_slot_item, turf_summary, …)
lib/domain/repositories/    (booking_service interface)
lib/data/services/          (mock_booking_service, booking_api_service)
lib/data/repositories/      (booking_repository — a pure pass-through)
```

Understanding "booking" required visiting all five. Meanwhile ADR-0001's deletion
test — which had already killed the shallow use-case layer — applied to the
repository layer too: `BookingRepository`, `AuthRepository`, `TemplateRepository`
and `SampleStatusRepository` were 1:1 delegates of their service interfaces.

## Decision

**Collapse each UI-facing feature into one module under `lib/features/<feature>/`
owning its entire vertical slice** — domain models, service interface, adapters,
cubit, views, widgets, and its DI registry:

```
lib/features/booking/
  booking_service.dart        (interface)
  models/                     (slot, booking, schedule_slot_item, turf_summary, …)
  data/                       (mock + api adapters)
  bloc/                       (schedule_cubit, state)
  views/ · widgets/
  di/booking_dependencies.dart
```

Companion decisions:

- **Pass-through repositories are deleted** (extends ADR-0001's reasoning). Cubits
  depend on the feature's service interface directly. Only repositories with real
  logic are allowed back.
- **Shared infrastructure stays global**: `DioApiClient` moved to
  `lib/core/network/`. The atomic widget catalog stays in `lib/ui/common/`, theming
  in `lib/ui/core/`, navigation in `lib/ui/navigation/`.
- **Routes provide their own state**: each feature route wraps its view in the
  cubit's `BlocProvider` (from its own DI registry), so `app.dart` and the DI
  facade no longer list every feature's cubits. Adding a feature = new
  `lib/features/<feature>/` module + one route + one registry line.
- **Dead forkable-template slices were deleted** (`lib/features/presentation/`,
  sample/local_sample/template chains) rather than preserved as cargo.
- **Home is a placeholder** (no data dependency) until the real home experience
  is designed; login still routes there.

### Before / After

```
Before (booking split by layer):
  ui/features/schedule/  domain/models/  domain/repositories/
  data/services/  data/repositories/  di/{service_locator,app_dependencies,data_dependencies}

After (feature module):
  features/booking/  (models · interface · adapters · bloc · views · widgets · di)
  features/auth/  ·  features/home/  ·  features/theme_preview/
  core/network/   ·  ui/{common,core,navigation}   ·  di/service_locator (aggregator only)
```

## Consequences

- **Locality**: the booking concept is comprehensible from one directory; bugs,
  changes and knowledge concentrate in one module.
- **Leverage**: forkers copy `lib/features/booking/` whole, not five directories.
- **Test surface**: cubit tests mock the feature's service interface — one seam.
  Mock and API adapters are both unit-tested.
- **Deletions**: 5 repositories, ~15 template files, `app_dependencies.dart`,
  `data_dependencies.dart`, empty `use_cases/` and `view_models/` dirs removed.
- **ADR compliance**: future features must live in `lib/features/<feature>/` with
  their own models, interface, adapters and DI; pass-through repositories require
  the same justification ADR-0001 demands of use cases.

## Supersedes

- **ADR-0002** (service interfaces at `lib/domain/repositories/`): interfaces now
  live inside their feature module. The *principle* — data services implement
  domain-level interfaces, mapping happens inside the adapter — still holds.
- **ADR-0003** (per-feature DI under `lib/ui/features/<feature>/di/`): the per-feature
  DI pattern holds, relocated to `lib/features/<feature>/di/`. The central
  aggregator remains a ~15-line registry.

## Related

- ADR-0001: No shallow use-case layer (extended to repositories)
