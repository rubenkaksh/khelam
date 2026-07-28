import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/app.dart';
import 'package:khelam/di/app_dependencies.dart';
import 'package:khelam/di/service_locator.dart';

void main() {
  setUp(() {
    serviceLocator.reset();
  });

  testWidgets('App starts on the schedule screen', (
    WidgetTester tester,
  ) async {
    final AppDependencies dependencies = AppDependencies.create();
    await tester.pumpWidget(KhelamApp(dependencies: dependencies));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Schedule'), findsOneWidget);
  });

  testWidgets('Unauthenticated access to home redirects to login', (
    WidgetTester tester,
  ) async {
    final AppDependencies dependencies = AppDependencies.create();
    await tester.pumpWidget(KhelamApp(dependencies: dependencies));
    await tester.pump(const Duration(milliseconds: 500));

    dependencies.appRouter.router.goNamed('home');
    await tester.pumpAndSettle();

    expect(find.text('Khelam Login'), findsOneWidget);
    expect(find.text('Sign in'), findsAtLeastNWidgets(1));
  });
}
