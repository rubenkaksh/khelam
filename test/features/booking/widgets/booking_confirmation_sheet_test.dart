import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commons/commons.dart' hide FilledButton;
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

    testWidgets('confirm button disabled until name and phone valid', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BookingConfirmationSheet(slot: testSlot)),
        ),
      );
      // Initially disabled
      final Finder confirmFinder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(confirmFinder).onPressed, isNull);
    });

    testWidgets('confirm button enabled with valid name and phone', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BookingConfirmationSheet(slot: testSlot)),
        ),
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Rohan');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        '9876543210',
      );
      await tester.pump();

      final Finder confirmFinder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(confirmFinder).onPressed, isNotNull);
    });

    testWidgets('shows name and phone inputs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BookingConfirmationSheet(slot: testSlot)),
        ),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('+977'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('confirm returns BookingResult with name and phone', (
      tester,
    ) async {
      BookingResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showFormBottomSheet<BookingResult>(
                      context: context,
                      builder: (_) =>
                          BookingConfirmationSheet(slot: testSlot),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Rohan');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        '9876543210',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result?.slotId, testSlot.id);
      expect(result?.customerName, 'Rohan');
      expect(result?.customerPhone, '9876543210');
    });
  });
}
