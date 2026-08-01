import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/navigation/app_routes.dart';

/// Landing screen after sign-in.
///
/// Placeholder for the real home experience; currently just links into the
/// schedule. The template's meta-demo content (architecture layers, feature
/// workflow) was removed with the template chain in the 2026-08-01 review.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khelam'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Preview theme components',
            onPressed: () {
              final Brightness brightness = Theme.of(context).brightness;
              context.pushNamed(AppRoutes.themePreview, extra: brightness);
            },
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.sports_soccer, size: 64),
            const SizedBox(height: 16),
            Text(
              'Welcome to Khelam',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Book turf slots for your team.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.goNamed(AppRoutes.schedule),
              icon: const Icon(Icons.calendar_month),
              label: const Text('View schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
