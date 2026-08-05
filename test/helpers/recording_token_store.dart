import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/models/auth_session.dart';

/// In-memory token store for tests. Shared by all test files (AGENTS.md:
/// "Shared test fakes, not per-file copies") — widget tests must never hit
/// the real FlutterSecureStorage platform channel, because those futures
/// never complete in tests and the app hangs on the login spinner.
class RecordingTokenStore extends AuthTokenStore {
  AuthSession? savedSession;
  bool cleared = false;

  @override
  Future<void> saveSession(AuthSession session) async {
    savedSession = session;
  }

  @override
  Future<AuthSession?> restoreSession() async => savedSession;

  @override
  Future<void> clear() async {
    cleared = true;
    savedSession = null;
  }
}
