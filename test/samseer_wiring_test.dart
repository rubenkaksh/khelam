import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samseer/samseer.dart';

import 'package:commons/commons.dart';
import 'package:khelam/app.dart';
import 'package:khelam/di/service_locator.dart';
import 'package:khelam/ui/navigation/app_router.dart';

void main() {
  setUp(() {
    serviceLocator.reset();
  });

  testWidgets('DioApiClient factory attaches the samseer interceptor', (
    WidgetTester tester,
  ) async {
    final Samseer samseer = Samseer();
    configureDependencies(samseer: samseer);

    final DioApiClient client = serviceLocator<DioApiClient>();
    expect(
      client.raw.interceptors.any((Interceptor i) => i is SamseerDioInterceptor),
      isTrue,
      reason: 'shared Dio client must record calls into samseer',
    );
  });

  testWidgets('no samseer → shared Dio client stays clean', (
    WidgetTester tester,
  ) async {
    configureDependencies();

    final DioApiClient client = serviceLocator<DioApiClient>();
    expect(
      client.raw.interceptors.any((Interceptor i) => i is SamseerDioInterceptor),
      isFalse,
      reason: 'widget tests must not capture HTTP traffic',
    );
  });

  testWidgets('GoRouter attaches the samseer navigator key to the app navigator', (
    WidgetTester tester,
  ) async {
    final Samseer samseer = Samseer();
    configureDependencies(samseer: samseer);
    await tester.pumpWidget(
      KhelamApp(
        router: serviceLocator<AppRouter>().router,
        samseer: samseer,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // With MaterialApp.router, go_router keys the root Navigator — samseer's
    // key must be that key or showInspector() silently no-ops.
    expect(
      samseer.navigatorKey.currentState,
      isNotNull,
      reason: 'samseer navigator key must be the GoRouter root navigator key',
    );
  });

  testWidgets('floating bubble renders and the inspector opens over the app', (
    WidgetTester tester,
  ) async {
    final Samseer samseer = Samseer(
      configuration: const SamseerConfiguration(showFloatingBubble: true),
    );
    configureDependencies(samseer: samseer);
    await tester.pumpWidget(
      KhelamApp(
        router: serviceLocator<AppRouter>().router,
        samseer: samseer,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // The draggable bubble with the recorded-call count is visible.
    expect(find.byType(SamseerOverlay), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Opening the inspector pushes onto the app navigator (via the shared
    // GoRouter key) and shows the call log. Not awaited: the future only
    // completes when the route pops.
    unawaited(samseer.showInspector());
    await tester.pumpAndSettle();

    expect(find.text('Samseer'), findsOneWidget);
    expect(find.text('No HTTP calls yet'), findsOneWidget);
  });
}
