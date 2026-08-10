import 'package:flutter/material.dart' as m;
import 'package:intl/intl.dart';

import 'package:commons/commons.dart';
import '../models/slot.dart';

/// Result returned when the user confirms a booking via [BookingConfirmationSheet].
class BookingResult {
  const BookingResult({
    required this.slotId,
    required this.customerName,
    required this.customerPhone,
  });

  final String slotId;
  final String customerName;
  final String customerPhone;
}

/// A bottom sheet that asks for the booker's name and phone before confirming.
///
/// Composes the reusable [FormBottomSheet], [TextInput] and [PhoneInput]
/// widgets. Returns a [BookingResult] on confirm, or null if dismissed.
class BookingConfirmationSheet extends m.StatefulWidget {
  const BookingConfirmationSheet({super.key, required this.slot});

  final Slot slot;

  @override
  m.State<BookingConfirmationSheet> createState() =>
      _BookingConfirmationSheetState();
}

class _BookingConfirmationSheetState extends m.State<BookingConfirmationSheet> {
  final m.TextEditingController _nameController = m.TextEditingController();
  final m.TextEditingController _phoneController = m.TextEditingController();
  String? _nameError;
  String? _phoneError;
  bool _isValid = false;

  void _onChanged() {
    setState(() {
      final String name = _nameController.text.trim();
      _isValid = name.isNotEmpty && PhoneInput.isValid(_phoneController.text);
      _nameError = null;
      _phoneError = null;
    });
  }

  void _onConfirm() {
    final String name = _nameController.text.trim();
    final bool nameValid = name.isNotEmpty;
    final bool phoneValid = PhoneInput.isValid(_phoneController.text);
    if (!nameValid || !phoneValid) {
      setState(() {
        _isValid = nameValid && phoneValid;
        _nameError = nameValid ? null : "Enter the booker's name";
        _phoneError = phoneValid ? null : 'Enter a valid 10-digit mobile number';
      });
      return;
    }
    m.Navigator.pop(
      context,
      BookingResult(
        slotId: widget.slot.id,
        customerName: name,
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
      body: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.stretch,
        children: <m.Widget>[
          TextInput(
            label: 'Name',
            hint: 'e.g. Rohan Shrestha',
            controller: _nameController,
            error: _nameError,
            onChanged: (_) => _onChanged(),
            textInputAction: m.TextInputAction.next,
          ),
          const m.SizedBox(height: 12),
          PhoneInput(
            controller: _phoneController,
            onChanged: (_) => _onChanged(),
            error: _phoneError,
          ),
        ],
      ),
      confirmLabel: 'Confirm',
      confirmEnabled: _isValid,
      onConfirm: _onConfirm,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
