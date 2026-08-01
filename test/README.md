# Test Strategy

Tests in this repo act as examples for future features, not just regressions for
the current code.

Use this pattern when adding a feature (see ADR-0004 — features live in
`lib/features/<feature>/`, tests mirror them under `test/features/<feature>/`):

- Model tests cover JSON parsing (snake_case API keys, string Decimal amounts)
  with no Flutter dependency.
- Service tests verify the adapter's mapping from API responses to domain
  models, using a recording HTTP client adapter.
- Cubit tests verify loading, success, and failure state transitions, mocking
  the feature's service interface directly (no repository layer).
- Widget tests verify visible UI, validation, and user interactions.
- Common widgets (`lib/ui/common/`) are tested under `test/ui/common/`.

Keep tests small and readable. A later agent should be able to copy a test file,
swap the feature names, and understand the expected architecture quickly.
