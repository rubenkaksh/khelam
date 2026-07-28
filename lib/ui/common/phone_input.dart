import 'package:flutter/material.dart' as m;

/// A phone number input field with +91 prefix and Indian mobile validation.
///
/// Validates 10-digit Indian mobile numbers starting with 6-9.
/// Use [PhoneInput.isValid] to check validity programmatically.
class PhoneInput extends m.StatelessWidget {
  const PhoneInput({
    super.key,
    this.onChanged,
    this.error,
    this.controller,
  });

  final m.ValueChanged<String>? onChanged;
  final String? error;
  final m.TextEditingController? controller;

  static final RegExp _indianMobileRegex = RegExp(r'^[6-9]\d{9}$');

  /// Returns true if [phone] is a valid 10-digit Indian mobile number.
  static bool isValid(String phone) {
    return _indianMobileRegex.hasMatch(phone);
  }

  @override
  m.Widget build(m.BuildContext context) {
    return m.TextFormField(
      controller: controller,
      keyboardType: m.TextInputType.phone,
      maxLength: 10,
      decoration: m.InputDecoration(
        labelText: 'Phone Number',
        hintText: '9876543210',
        errorText: error,
        counterText: '',
        prefixIcon: const m.Padding(
          padding: m.EdgeInsets.only(left: 12, right: 8),
          child: m.Text(
            '+91',
            style: m.TextStyle(fontSize: 16),
          ),
        ),
        prefixIconConstraints: const m.BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
      onChanged: onChanged,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        }
        if (!isValid(value)) {
          return 'Enter a valid 10-digit mobile number';
        }
        return null;
      },
    );
  }
}
