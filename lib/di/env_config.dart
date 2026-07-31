import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Returns the value of [key] from `.env`, or `null` when dotenv was never
/// loaded (e.g. widget tests that build dependencies without running
/// `main()`). Prefer this over `dotenv.env` directly, which throws
/// [NotInitializedError] before [DotEnv.load] has been called.
String? envValue(String key) =>
    dotenv.isInitialized ? dotenv.env[key] : null;
