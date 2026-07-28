import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/ui/features/schedule/widgets/available_slot_card.dart';

void main() {
  testWidgets('AvailableSlotCard shows + Available text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvailableSlotCard(),
        ),
      ),
    );

    expect(find.text('+ Available'), findsOneWidget);
  });

  testWidgets('AvailableSlotCard fires onTap when tapped', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvailableSlotCard(onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.text('+ Available'));
    expect(tapped, isTrue);
  });
}
