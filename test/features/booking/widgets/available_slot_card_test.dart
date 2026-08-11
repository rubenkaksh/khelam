import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/features/booking/models/slot.dart';
import 'package:khelam/features/booking/models/slot_status.dart';
import 'package:khelam/features/booking/widgets/available_slot_card.dart';
import 'package:khelam/ui/core/app_theme.dart';
import 'package:khelam/ui/core/theme/app_palette.dart';

Slot _slot() => Slot(
  id: 's1',
  turfId: 'turf-a',
  slotDate: DateTime(2026, 7, 27),
  startTime: DateTime(2026, 7, 27, 7),
  endTime: DateTime(2026, 7, 27, 8),
  status: SlotStatus.available,
);

void main() {
  testWidgets('AvailableSlotCard shows time range and a Book Now button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AvailableSlotCard(slot: _slot()))),
    );

    expect(find.text('7:00 AM – 8:00 AM'), findsOneWidget);
    expect(find.text('Book Now'), findsOneWidget);
  });

  testWidgets('AvailableSlotCard fires onTap when the Book Now button is tapped', (
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

    await tester.tap(find.text('Book Now'));
    expect(tapped, isTrue);
  });

  testWidgets('dark mode: card uses theme-derived surface + onSurface text (readable)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: AvailableSlotCard(slot: _slot())),
      ),
    );

    final Card card = tester.widget<Card>(find.byType(Card));
    expect(card.color, isNot(AppPalette.cardBackground), reason: 'light-only tint must not leak into dark mode');

    final Text time = tester.widget<Text>(find.text('7:00 AM – 8:00 AM'));
    final ColorScheme colors = Theme.of(tester.element(find.byType(Card))).colorScheme;
    expect(time.style?.color, colors.onSurface);
  });
}
