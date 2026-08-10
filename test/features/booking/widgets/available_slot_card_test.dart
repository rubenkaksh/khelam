import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/features/booking/models/slot.dart';
import 'package:khelam/features/booking/models/slot_status.dart';
import 'package:khelam/features/booking/widgets/available_slot_card.dart';

Slot _slot() => Slot(
  id: 's1',
  turfId: 'turf-a',
  slotDate: DateTime(2026, 7, 27),
  startTime: DateTime(2026, 7, 27, 7),
  endTime: DateTime(2026, 7, 27, 8),
  status: SlotStatus.available,
);

void main() {
  testWidgets('AvailableSlotCard shows time range and + Available text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AvailableSlotCard(slot: _slot()))),
    );

    expect(find.text('7:00 AM – 8:00 AM'), findsOneWidget);
    expect(find.text('+ Available'), findsOneWidget);
  });

  testWidgets('AvailableSlotCard fires onTap when tapped', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvailableSlotCard(slot: _slot(), onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.text('+ Available'));
    expect(tapped, isTrue);
  });
}
