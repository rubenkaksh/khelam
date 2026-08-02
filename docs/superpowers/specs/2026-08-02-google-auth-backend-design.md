# Spec: Google Auth Backend Integration

> **Date:** 2026-08-02
> **Status:** Approved
> **Checklist:** `docs/superpowers/checklist.md`

---

## 1. Goal

After a successful Google Sign-In, exchange the SDK `idToken` with the backend
(`POST /auth/google`), persist the returned `accessToken` in secure storage,
attach it to all protected API calls (booking creation), and restore the
session on app launch.

Backend contract (from the owner):

```
POST /auth/google
Body: { "idToken": "string" }

200 → {
  "accessToken": "eyJhbGci...",
  "user": {
    "id": "...", "full_name": "...", "email": "...", "avatar_url": "...",
    "phone_number": null, "is_active": true,
    "created_at": "2026-07-31T08:32:47.975Z", "updated_at": "2026-07-31T08:32:47.975Z"
  }
}

401 → Invalid or expired Google token
400 → Missing idToken field
```

---

## 2. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Service shape | Extend `AuthService` interface with `googleLogin()` + `init()` | One auth service, two impls (mock/api), mirrors the booking `USE_MOCK_*` switch |
| Token access | Dedicated `AuthTokenStore` singleton (secure storage) | Keeps storage out of the `AuthService` interface; the mock never touches real storage plumbing |
| Token attachment | `DioApiClient.setBearerToken()` on the shared client | `BookingApiService.bookSlot` already documents this mechanism; zero booking changes |
| Restore | `AuthService.init()` called in `main`, returns restored user | Owner directive; cubit emits authenticated when a session is found |
| Persisted shape | Single JSON entry `{access_token, user}` in secure storage | `flutter_secure_storage` stores strings; one entry keeps save/restore atomic |
| Error mapping | `AuthException(message)`; 401/400 → friendly messages | Matches the cubit's `e.toString()` failure pattern |
| API-mode login() | Throws `AuthException` (not wired yet) | Only `/auth/google` is contracted so far |

---

## 3. Flow

```
Google button tap
  → AuthCubit.googleSignIn()
  → GoogleSignInService.signIn()          // commons; canceled → null
  → idToken == null → failure("no ID token — check GOOGLE_SERVER_CLIENT_ID")
  → AuthService.googleLogin(result)       // mock: fake session; api: POST /auth/google
  → AuthTokenStore.saveSession(session)   // secure storage
  → AuthCubit emits authenticated(user)

App launch
  → main(): AuthService.init()            // reads stored session; api impl also re-attaches bearer token
  → restored != null → AuthCubit.restoreSession(user) → authenticated
```

`AuthApiService.googleLogin` also calls `setBearerToken(accessToken)` on the
shared `DioApiClient`, so `POST /slots/:id/book` (and any future protected
endpoint) sends `Authorization: Bearer <accessToken>` automatically.

---

## 4. Slices

Work is delivered as independent slices, each with its own commit:

- **Slice 1 — Models:** `AuthUser` gains optional profile fields
  (`avatarUrl`, `phoneNumber`, `isActive`, `createdAt`, `updatedAt`; snake_case
  `@JsonKey`, `displayName` ← `full_name`) + new `AuthSession` DTO. No breaking
  changes (only `id/email/displayName` required). Regenerate freezed/json, add
  `fromJson` test against the full backend payload.
- **Slice 2 — Services:** add `flutter_secure_storage`; `AuthTokenStore`
  (save/restore/clear, JSON `{access_token, user}`); `AuthService.googleLogin`
  + `init()`; mock impls; new `AuthApiService` (POST /auth/google, error
  mapping, bearer attach, `init()` re-attach); `AuthException`. API service
  tests with a recording Dio adapter (booking test pattern).
- **Slice 3 — Wiring:** `USE_MOCK_AUTH` env switch in `auth_dependencies.dart`;
  token store registration; cubit `googleSignIn()` rewrite + `restoreSession()`;
  `main()` calls `AuthService.init()`; cubit tests updated/added.
- **Slice 4 — Verify:** `flutter analyze`, full `flutter test`, debug APK
  build, session doc, push.

---

## 5. Out of Scope

- Email/password login against the backend (no `/auth/login` contract yet).
- Logout / token invalidation UI.
- Auto-refresh of expired tokens (a 401 mid-session surfaces as a booking
  error for now).
- macOS Keychain Sharing entitlement (Android emulator is the test target;
  noted in the plan for later).

---

## 6. Testing

- Model: `AuthUser.fromJson` parses the full snake_case backend payload.
- `AuthApiService`: recording-adapter tests — success parses session and the
  next request carries the bearer header; 401 and 400 map to friendly messages.
- `AuthCubit`: fake service + fake token store — success saves the session,
  cancel stays silent, missing idToken is a failure, restore emits
  authenticated.
