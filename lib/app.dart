import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samseer/samseer.dart';

import 'ui/core/app_theme.dart';

class KhelamApp extends StatelessWidget {
  const KhelamApp({super.key, required this.router, this.samseer});

  final GoRouter router;

  /// Optional HTTP inspector (see `main()`). When provided, its floating
  /// bubble overlay wraps the whole app so calls are one tap away.
  final Samseer? samseer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Khelam',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: samseer == null
          ? null
          : (BuildContext context, Widget? child) =>
                samseer!.overlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
