import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'di/service_locator.dart';
import 'ui/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(isOptional: true);

  configureDependencies();
  runApp(KhelamApp(router: serviceLocator<AppRouter>().router));
}
