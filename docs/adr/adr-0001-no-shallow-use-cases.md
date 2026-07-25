# ADR-0001: No Shallow Use-Case Layer

**Date**: 2026-06-22  
**Status**: Accepted  
**Deciders**: @rubenk

## Context

The project had 5 use cases in `lib/domain/use_cases/`, each a pure delegate:
- `LoginWithEmailUseCase` → calls `AuthRepository.login()`
- `GetTemplateInfoUseCase` → calls `TemplateRepository.getTemplateInfo()`
- `GetSampleStatusUseCase` → calls `SampleStatusRepository.getStatus()`
- `GetLocalSampleRecordUseCase` → calls `LocalSampleRepository.find()`
- `SaveLocalSampleRecordUseCase` → calls `LocalSampleRepository.save()`

Each use case was ~13 lines with zero business logic: no validation, no composition, no side effects. The interface was as complex as the implementation — shallow modules.

Applying the **deletion test**: deleting each use case does not concentrate complexity; it moves the one-line delegation up to the Cubit.

## Decision

**Delete all shallow use cases.** Cubits depend on repositories directly. A use case is only introduced when it contains non-trivial logic (validation, orchestration across multiple repositories, audit logging, rate limiting, etc.).

### Before

```
Cubit → UseCase → Repository → Service
         (pass-through)
```

### After

```
Cubit → Repository → Service
```

The repository becomes the single seam between the UI and data layers.

## Consequences

- **Removed 5 files, ~65 lines** from the domain layer
- **Cubits gain 1 direct dependency** (repository instead of use case)
- **Tests**: Cubit unit tests that mocked the use case now mock the repository directly — same test surface, fewer layers
- **ADR compliance**: any future contributor proposing a use case must first demonstrate that the use case contains non-trivial logic beyond delegation

## Related

- ADR-0002: Service interfaces at domain/repositories layer
- ADR-0003: Per-feature dependency injection modules
