import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/ui/common/phone_input.dart';

void main() {
  group('PhoneInput', () {
    testWidgets('renders with +91 prefix and label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: PhoneInput()),
      ));
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('accepts numeric input only', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: PhoneInput()),
      ));
      await tester.enterText(find.byType(TextFormField), '9876543210');
      expect(find.text('9876543210'), findsWidgets);
    });

    group('isValid', () {
      test('accepts valid numbers starting with 6-9', () {
        expect(PhoneInput.isValid('9876543210'), isTrue);
        expect(PhoneInput.isValid('6123456789'), isTrue);
        expect(PhoneInput.isValid('7987654321'), isTrue);
        expect(PhoneInput.isValid('8123456789'), isTrue);
      });

      test('rejects numbers starting with 0-5', () {
        expect(PhoneInput.isValid('1234567890'), isFalse);
        expect(PhoneInput.isValid('5876543210'), isFalse);
        expect(PhoneInput.isValid('0987654321'), isFalse);
      });

      test('rejects wrong length', () {
        expect(PhoneInput.isValid('987654321'), isFalse);   // 9 digits
        expect(PhoneInput.isValid('98765432101'), isFalse);  // 11 digits
        expect(PhoneInput.isValid(''), isFalse);
      });

      test('rejects non-numeric input', () {
        expect(PhoneInput.isValid('abcdefghij'), isFalse);
        expect(PhoneInput.isValid('98765abcd0'), isFalse);
      });
    });

    testWidgets('calls onChanged with input', (tester) async {
      String? received;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PhoneInput(onChanged: (v) => received = v),
        ),
      ));
      await tester.enterText(find.byType(TextFormField), '9876543210');
      expect(received, '9876543210');
    });

    testWidgets('shows error text when error is provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PhoneInput(error: 'Invalid number'),
        ),
      ));
      expect(find.text('Invalid number'), findsOneWidget);
    });
  });
}
