import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Returns the value of [key] from `.env`, or `null` when dotenv was never
/// loaded (e.g. widget tests that build dependencies without running
/// `main()`). Prefer this over `dotenv.env` directly, which throws
/// [NotInitializedError] before [DotEnv.load] has been called.
///
/// On web, prefers `String.fromEnvironment` (a `--dart-define` compile-time
/// constant embedded by dart2js).  The `flutter_dotenv` asset-loading path
/// (`rootBundle.loadString`) makes an HTTP fetch on web and can silently fail
/// in release builds (404 on the asset, swallowed by `isOptional: true`) —
/// the dart-define path is a build-time embed, which is reliable.
/// Flutter_dotenv remains the canonical source on non-web platforms (local
/// dev, mobile, desktop) and widget tests where `--dart-define` is not used.
String? envValue(String key) {
  if (kIsWeb) {
    // Try `--dart-define` compile-time constants first (dart2js embeds them
    // into the JS — always reliable).  Fall back to flutter_dotenv for local
    // dev web (where `rootBundle.loadString` works fine through the dev server
    // and --dart-define is typically not used).
    final defined = _dartDefine(key);
    if (defined != null) return defined;
    return dotenv.isInitialized ? dotenv.env[key] : null;
  }
  return dotenv.isInitialized ? dotenv.env[key] : null;
}

/// Returns the `--dart-define` value for [name], or `null` when the define
/// was not passed at build time (`String.fromEnvironment` returns `''`).
String? _dartDefine(String name) {
  // Each branch uses its own const call so dart2js can embed the value
  // directly.  A single `String.fromEnvironment(name)` is never const
  // (name is a parameter, not a literal), so a switch of literals is
  // required.
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  const googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  const useMockAuth = String.fromEnvironment('USE_MOCK_AUTH');
  const useMockBooking = String.fromEnvironment('USE_MOCK_BOOKING');
  const useMockTurfs = String.fromEnvironment('USE_MOCK_TURFS');

  return switch (name) {
    'API_BASE_URL' => apiBaseUrl.isEmpty ? null : apiBaseUrl,
    'GOOGLE_CLIENT_ID' => googleClientId.isEmpty ? null : googleClientId,
    'GOOGLE_SERVER_CLIENT_ID' =>
      googleServerClientId.isEmpty ? null : googleServerClientId,
    'USE_MOCK_AUTH' => useMockAuth.isEmpty ? null : useMockAuth,
    'USE_MOCK_BOOKING' => useMockBooking.isEmpty ? null : useMockBooking,
    'USE_MOCK_TURFS' => useMockTurfs.isEmpty ? null : useMockTurfs,
    _ => null,
  };
}
