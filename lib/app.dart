import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/core/app_theme.dart';

class KhelamApp extends StatelessWidget {
  const KhelamApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Khelam',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
