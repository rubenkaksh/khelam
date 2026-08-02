import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'di/service_locator.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/bloc/auth_cubit.dart';
import 'features/auth/models/auth_user.dart';
import 'ui/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(isOptional: true);

  configureDependencies();

  // Restore a persisted session (if any): the auth service reads the token
  // from secure storage and re-attaches it to the HTTP client, so protected
  // API calls work immediately; the cubit then starts authenticated.
  final AuthUser? restoredUser = await serviceLocator<AuthService>().init();
  if (restoredUser != null) {
    serviceLocator<AuthCubit>().restoreSession(restoredUser);
  }

  runApp(KhelamApp(router: serviceLocator<AppRouter>().router));
}
