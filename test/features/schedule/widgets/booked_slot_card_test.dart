import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/domain/models/booking.dart';
import 'package:khelam/domain/models/booking_status.dart';
import 'package:khelam/domain/models/schedule_slot_item.dart';
import 'package:khelam/domain/models/slot.dart';
import 'package:khelam/domain/models/slot_status.dart';
import 'package:khelam/ui/features/schedule/widgets/booked_slot_card.dart';

Slot _slot(int hour) => Slot(
  id: 's$hour',
  turfId: 'turf-a',
  slotDate: DateTime.now(),
  startTime: DateTime(2026, 7, 27, hour),
  endTime: DateTime(2026, 7, 27, hour + 1),
  status: SlotStatus.booked,
);

Booking _booking(int hour) => Booking(
  id: 'b$hour',
  bookingCode: 'BK-00$hour',
  userId: 'u1',
  turfId: 'turf-a',
  slotId: 's$hour',
  totalAmount: 100.0,
  advanceAmount: 50.0,
  remainingAmount: 50.0,
  status: BookingStatus.confirmed,
);

void main() {
  testWidgets('BookedSlotCard shows customer name when provided', (
    WidgetTester tester,
  ) async {
    final ScheduleSlotItem item = ScheduleSlotItem(
      slot: _slot(10),
      booking: _booking(10),
      customerName: 'Team Alpha',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookedSlotCard(item: item),
        ),
      ),
    );

    expect(find.text('Team Alpha'), findsOneWidget);
  });

  testWidgets('BookedSlotCard shows booking code when no customer name', (
    WidgetTester tester,
  ) async {
    final ScheduleSlotItem item = ScheduleSlotItem(
      slot: _slot(11),
      booking: _booking(11),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookedSlotCard(item: item),
        ),
      ),
    );

    expect(find.text('BK-0011'), findsOneWidget);
  });

  testWidgets('BookedSlotCard shows Confirmed badge', (
    WidgetTester tester,
  ) async {
    final ScheduleSlotItem item = ScheduleSlotItem(
      slot: _slot(9),
      booking: _booking(9),
      customerName: 'FC Rovers',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookedSlotCard(item: item),
        ),
      ),
    );

    expect(find.text('Confirmed'), findsOneWidget);
  });

  testWidgets('BookedSlotCard fires onTap when tapped', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    final ScheduleSlotItem item = ScheduleSlotItem(
      slot: _slot(14),
      booking: _booking(14),
      customerName: 'United Stars',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookedSlotCard(
            item: item,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('United Stars'));
    expect(tapped, isTrue);
  });
}
