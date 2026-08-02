/// Auth failure with a user-facing [message].
///
/// `toString()` returns the message so the cubit's existing `e.toString()`
/// error surfacing shows something readable (same pattern as
/// `MockAuthException`).
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
