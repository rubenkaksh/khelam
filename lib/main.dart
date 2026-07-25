import 'package:flutter/widgets.dart';

import 'app.dart';
import 'di/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final AppDependencies dependencies = AppDependencies.create();
  runApp(KhelamApp(dependencies: dependencies));
}
