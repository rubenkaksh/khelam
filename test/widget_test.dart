// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/app.dart';
import 'package:khelam/di/app_dependencies.dart';
import 'package:khelam/di/service_locator.dart';

void main() {
  setUp(() {
    serviceLocator.reset();
  });

  testWidgets('App starts on the khelam login screen', (
    WidgetTester tester,
  ) async {
    final AppDependencies dependencies = AppDependencies.create();
    await tester.pumpWidget(KhelamApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('Khelam Login'), findsOneWidget);
    expect(find.text('Sign in'), findsAtLeastNWidgets(1));
    expect(find.text('demo@khelam.dev'), findsOneWidget);
    expect(find.text('Fill demo credentials'), findsOneWidget);
  });

  testWidgets('Demo login opens the template dashboard', (
    WidgetTester tester,
  ) async {
    final AppDependencies dependencies = AppDependencies.create();
    await tester.pumpWidget(KhelamApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in').last);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Khelam Template'), findsOneWidget);
    expect(find.text('Architecture layers'), findsOneWidget);
    expect(find.text('Feature implementation workflow'), findsOneWidget);
  });

  testWidgets('Unauthenticated access to home redirects to login', (
    WidgetTester tester,
  ) async {
    final AppDependencies dependencies = AppDependencies.create();
    await tester.pumpWidget(KhelamApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    dependencies.appRouter.router.goNamed('home');
    await tester.pumpAndSettle();

    expect(find.text('Khelam Login'), findsOneWidget);
    expect(find.text('Sign in'), findsAtLeastNWidgets(1));
  });
}
