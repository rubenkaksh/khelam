# ADR-0002: Service Interfaces at Domain Layer

**Date**: 2026-06-22  
**Status**: Accepted  
**Deciders**: @rubenk

## Context

Data-layer services (`MockAuthService`, `TemplateCatalogService`, `SampleApiService`) were concrete classes with no abstract interface. Repositories depended on these concrete classes directly, making substitution (e.g., swapping mock for real API) impossible without modifying repository code.

`LocalSampleStorageService` was already an `abstract interface class` — the only correct pattern in the data layer.

## Decision

**Extract abstract service interfaces in `lib/domain/repositories/`** with names reflecting the domain capability. Each concrete service in `lib/data/services/` implements the corresponding interface.

### Created interfaces

| Interface | Location | Implemented by |
|-----------|----------|----------------|
| `AuthService` | `lib/domain/repositories/auth_service.dart` | `MockAuthService` |
| `TemplateService` | `lib/domain/repositories/template_service.dart` | `TemplateCatalogService` |
| `SampleService` | `lib/domain/repositories/sample_service.dart` | `SampleApiService` |

### Key design rule

Services return **domain models**, not API models. The mapping from API response → domain model happens inside the service, not the repository. This makes the repository a thin seam that can be tested with any service adapter.

### Before

```
AuthRepository → MockAuthService (concrete)
                   ↑ no seam — substitution impossible
```

### After

```
AuthRepository → AuthService (abstract) ← SEAM
                   ↑                ↑
            MockAuthService    FutureApiAuthService
```

## Consequences

- **3 new interface files** in `lib/domain/repositories/`
- **Repositories no longer import concrete services** — depend only on abstract interfaces
- **Forkers can inject a real API service** without touching repository code
- **Service tests already cover the domain mapping** — no new test surface needed
- **Future**: every data service MUST implement a domain-level interface

## Superseded in part

**ADR-0004** (2026-08-01) moved service interfaces from `lib/domain/repositories/`
into their feature modules (`lib/features/<feature>/`). The principle here — data
services implement domain-level interfaces; the mapping from API response to
domain model happens inside the adapter — remains the rule.

## Related

- ADR-0001: No shallow use-case layer
- ADR-0003: Per-feature dependency injection modules
