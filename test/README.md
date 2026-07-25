# Test Strategy

Tests in this khelam template should act as examples for future modules, not
just as regressions for the current code.

Use this pattern when adding a feature:

- Domain/use case tests cover business rules with no Flutter dependency.
- Repository tests use fake services and verify mapping from data models to
  domain models.
- Cubit/Bloc tests verify loading, success, and failure state transitions.
- Widget tests verify visible UI, validation, and user interactions.
- Local storage tests prove Hive, Drift, and secure storage wrappers work before
  real modules depend on them.
- Until Hive and Drift are installed, local storage examples should use the
  in-memory sample service as the contract test pattern.

Keep tests small and readable. A later agent should be able to copy a test file,
swap the feature names, and understand the expected architecture quickly.
