import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/app.dart';
import 'package:khelam/di/service_locator.dart';
import 'package:khelam/ui/navigation/app_router.dart';

void main() {
  setUp(() {
    serviceLocator.reset();
  });

  testWidgets('App starts on the schedule screen', (WidgetTester tester) async {
    configureDependencies();
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Schedule'), findsOneWidget);
  });

  testWidgets('Unauthenticated access to home redirects to login', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    serviceLocator<AppRouter>().router.goNamed('home');
    await tester.pumpAndSettle();

    expect(find.text('Khelam Login'), findsOneWidget);
    expect(find.text('Sign in'), findsAtLeastNWidgets(1));
  });
}
