# Google Auth Backend — Implementation Plan

> **Spec:** `docs/superpowers/specs/2026-08-02-google-auth-backend-design.md`
> **Checklist:** `docs/superpowers/checklist.md`
> **Slices:** independent units, one commit each, verified at the end.

**Goal:** Exchange the Google idToken for a backend session, persist the accessToken in secure storage, attach it to protected API calls, and restore on launch.

**Tech Stack:** Dart, Flutter, flutter_bloc, freezed, dio, flutter_secure_storage, flutter_test

## Global Constraints
- No null force operator `!` — null-aware patterns only
- Follow existing patterns: booking's `USE_MOCK_*` env switch, `_RecordingAdapter` test style, freezed + json_serializable models with snake_case `@JsonKey`
- Per-feature DI registries (ADR-0003)

---

## Slice 1 — Models

### Files

| File | Action | Purpose |
|------|--------|---------|
| `lib/features/auth/models/auth_user.dart` | Modify | Optional profile fields, snake_case JsonKeys |
| `lib/features/auth/models/auth_user.g.dart` / `.freezed.dart` | Regenerate | `dart run build_runner build --delete-conflicting-outputs` |
| `lib/features/auth/models/auth_session.dart` | Create | `{accessToken, user}` DTO |
| `test/features/auth/models/auth_user_test.dart` | Create | fromJson full backend payload |

### AuthUser shape

```dart
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
}
```

`AuthSession` is a plain immutable class (assembled by services, never parsed).

**Verify:** `flutter analyze` + `flutter test test/features/auth/models` — old constructions still compile (all new fields optional).

---

## Slice 2 — Services

### Files

| File | Action | Purpose |
|------|--------|---------|
| `pubspec.yaml` | Modify | `flutter_secure_storage` |
| `lib/features/auth/data/auth_token_store.dart` | Create | Secure-storage singleton wrapper |
| `lib/features/auth/auth_service.dart` | Modify | `googleLogin(GoogleSignInResult)` + `init()` |
| `lib/features/auth/data/mock_auth_service.dart` | Modify | googleLogin + init |
| `lib/features/auth/data/auth_api_service.dart` | Create | Real backend impl |
| `lib/features/auth/data/auth_exception.dart` | Create | Message-carrying exception |
| `test/features/auth/data/auth_api_service_test.dart` | Create | Recording-adapter tests |

### Contracts

```dart
abstract interface class AuthService {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthSession> googleLogin(GoogleSignInResult result);
  Future<AuthUser?> init(); // restores persisted session (null when absent)
}
```

`AuthTokenStore` — one JSON entry `{access_token, user}`:

```dart
class AuthTokenStore {
  AuthTokenStore({FlutterSecureStorage? storage});
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> restoreSession();
  Future<void> clear();
}
```

`AuthApiService.googleLogin(result)`:
1. `postJson('/auth/google', {'idToken': result.idToken})`
2. parse `{accessToken, user}` → `AuthSession`
3. `_apiClient.setBearerToken(accessToken)` ← booking header works
4. DioException → 401 "Invalid or expired Google token", 400 "Missing idToken", else generic → `AuthException`

`AuthApiService.init()`: restore session, re-attach bearer, return user.
`login()` in API mode throws `AuthException('Email/password login is not wired to the backend yet')`.

`MockAuthService.googleLogin(result)`: fake `AuthSession('mock-token', AuthUser(id: 'google:<email>', ...))` — preserves today's dev behavior.

**Verify:** `flutter analyze` + `flutter test test/features/auth/data`.

---

## Slice 3 — Wiring

### Files

| File | Action | Purpose |
|------|--------|---------|
| `lib/features/auth/di/auth_dependencies.dart` | Modify | `USE_MOCK_AUTH` switch, `AuthTokenStore` registration, inject token store into services + cubit |
| `lib/features/auth/bloc/auth_cubit.dart` | Modify | `googleSignIn()` rewrite + `restoreSession()` |
| `lib/main.dart` | Modify | `await serviceLocator<AuthService>().init()` → cubit restore |
| `test/features/auth/auth_cubit_test.dart` | Modify | Rewire fakes + new cases |

Cubit `googleSignIn()`:
1. `signIn()` → null → `initial` (cancel, silent)
2. `result.idToken == null` → failure "Google sign-in returned no ID token (is GOOGLE_SERVER_CLIENT_ID set?)"
3. `googleLogin(result)` → `tokenStore.saveSession(session)` → `authenticated(user)`

Cubit `restoreSession(AuthUser user)` → emits `authenticated(user)`.

**Verify:** `flutter analyze` + `flutter test test/features/auth`.

---

## Slice 4 — Verify & Ship

- `flutter analyze` (repo clean)
- `flutter test` (full suite green)
- `flutter build apk --debug` (minSdk may need a bump for flutter_secure_storage ≥ v9 — if so, document it)
- Update `docs/sessions/2026-08-02.md`, commit, push

## Open Items for the Owner
- Replace `GOOGLE_SERVER_CLIENT_ID` in `.env` — without it the SDK returns no idToken and the flow fails with the new guided message.
- Confirm whether the backend has `/auth/login` (would unblock API-mode email login).
- macOS runs need Keychain Sharing in Runner entitlements (Android emulator is the current target).
