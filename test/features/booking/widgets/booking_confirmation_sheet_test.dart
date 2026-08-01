import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/features/booking/models/slot.dart';
import 'package:khelam/features/booking/models/slot_status.dart';
import 'package:khelam/features/booking/widgets/booking_confirmation_sheet.dart';

void main() {
  final DateTime slotDate = DateTime(2026, 7, 28);
  final Slot testSlot = Slot(
    id: 'slot-2026-7-28-10',
    turfId: 'turf-a',
    slotDate: slotDate,
    startTime: DateTime(2026, 7, 28, 10),
    endTime: DateTime(2026, 7, 28, 11),
    status: SlotStatus.available,
  );

  group('BookingConfirmationSheet', () {
    testWidgets('renders title and slot time range', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BookingConfirmationSheet(slot: testSlot)),
        ),
      );
      expect(find.text('Confirm Booking'), findsOneWidget);
      expect(find.textContaining('10:00'), findsOneWidget);
      expect(find.textContaining('11:00'), findsOneWidget);
    });

    testWidgets('confirm button disabled until valid phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BookingConfirmationSheet(slot: testSlot)),
        ),
      );
      // Initially disabled
      final Finder confirmFinder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(confirmFinder).onPressed, isNull);
    });

    testWidgets('confirm button enabled with valid phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BookingConfirmationSheet(slot: testSlot)),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.pump();

      final Finder confirmFinder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(confirmFinder).onPressed, isNotNull);
    });

    testWidgets('shows phone input with +91 prefix', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BookingConfirmationSheet(slot: testSlot)),
        ),
      );
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });
  });
}
