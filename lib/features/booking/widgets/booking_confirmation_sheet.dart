import 'package:flutter/material.dart' as m;
import 'package:intl/intl.dart';

import '../../../ui/common/bottom_sheet.dart';
import '../../../ui/common/phone_input.dart';
import '../models/slot.dart';

/// Result returned when the user confirms a booking via [BookingConfirmationSheet].
class BookingResult {
  const BookingResult({required this.slotId, required this.customerPhone});

  final String slotId;
  final String customerPhone;
}

/// A bottom sheet that asks for the booker's phone number before confirming.
///
/// Composes the reusable [FormBottomSheet] and [PhoneInput] widgets.
/// Returns a [BookingResult] on confirm, or null if dismissed.
class BookingConfirmationSheet extends m.StatefulWidget {
  const BookingConfirmationSheet({super.key, required this.slot});

  final Slot slot;

  @override
  m.State<BookingConfirmationSheet> createState() =>
      _BookingConfirmationSheetState();
}

class _BookingConfirmationSheetState extends m.State<BookingConfirmationSheet> {
  final m.TextEditingController _phoneController = m.TextEditingController();
  String? _phoneError;
  bool _isValid = false;

  void _onPhoneChanged(String value) {
    setState(() {
      _isValid = PhoneInput.isValid(value);
      _phoneError = null;
    });
  }

  void _onConfirm() {
    if (!_isValid) {
      setState(() {
        _phoneError = 'Enter a valid 10-digit mobile number';
      });
      return;
    }
    m.Navigator.pop(
      context,
      BookingResult(
        slotId: widget.slot.id,
        customerPhone: _phoneController.text,
      ),
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    final DateFormat timeFormat = DateFormat('hh:mm a');
    final String startTime = timeFormat.format(widget.slot.startTime);
    final String endTime = timeFormat.format(widget.slot.endTime);

    return FormBottomSheet(
      title: 'Confirm Booking',
      subtitle: '$startTime – $endTime',
      body: PhoneInput(
        controller: _phoneController,
        onChanged: _onPhoneChanged,
        error: _phoneError,
      ),
      confirmLabel: 'Confirm',
      confirmEnabled: _isValid,
      onConfirm: _onConfirm,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
