import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/ui/common/bottom_sheet.dart';

void main() {
  group('FormBottomSheet', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Test Title',
            body: const Text('Test Body'),
            confirmLabel: 'Confirm',
            onConfirm: () {},
          ),
        ),
      ));
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            subtitle: 'Subtitle text',
            body: const SizedBox(),
            confirmLabel: 'OK',
            onConfirm: () {},
          ),
        ),
      ));
      expect(find.text('Subtitle text'), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'OK',
            onConfirm: () {},
          ),
        ),
      ));
      expect(find.text('Subtitle text'), findsNothing);
    });

    testWidgets('confirm button disabled when confirmEnabled is false', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'Confirm',
            onConfirm: () {},
            confirmEnabled: false,
          ),
        ),
      ));
      final finder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(finder).onPressed, isNull);
    });

    testWidgets('confirm button enabled when confirmEnabled is true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'Confirm',
            onConfirm: () {},
            confirmEnabled: true,
          ),
        ),
      ));
      final finder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(finder).onPressed, isNotNull);
    });

    testWidgets('cancel button calls onCancel when provided', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'Confirm',
            onConfirm: () {},
            onCancel: () => cancelled = true,
          ),
        ),
      ));
      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });

    testWidgets('cancel button uses custom label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'OK',
            onConfirm: () {},
            cancelLabel: 'Close',
          ),
        ),
      ));
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
