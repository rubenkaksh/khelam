import 'package:flutter/material.dart' as m;

class TextInput extends m.StatelessWidget {
  const TextInput({
    super.key,
    required this.label,
    this.hint,
    this.error,
    this.enabled = true,
    this.obscure = false,
    this.onChanged,
    this.controller,
    this.validator,
  });

  final String label;
  final String? hint;
  final String? error;
  final bool enabled;
  final bool obscure;
  final m.ValueChanged<String>? onChanged;
  final m.TextEditingController? controller;
  final m.FormFieldValidator<String>? validator;

  @override
  m.Widget build(m.BuildContext context) {
    return m.TextFormField(
      enabled: enabled,
      obscureText: obscure,
      decoration: m.InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
      ),
      onChanged: onChanged,
      controller: controller,
      validator: validator,
    );
  }
}

class PasswordInput extends m.StatefulWidget {
  const PasswordInput({
    super.key,
    required this.label,
    this.hint,
    this.error,
    this.onChanged,
    this.controller,
    this.validator,
  });

  final String label;
  final String? hint;
  final String? error;
  final m.ValueChanged<String>? onChanged;
  final m.TextEditingController? controller;
  final m.FormFieldValidator<String>? validator;

  @override
  m.State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends m.State<PasswordInput> {
  bool _obscured = true;

  @override
  m.Widget build(m.BuildContext context) {
    return m.TextFormField(
      obscureText: _obscured,
      decoration: m.InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.error,
        suffixIcon: m.IconButton(
          onPressed: () => setState(() => _obscured = !_obscured),
          icon: m.Icon(
            _obscured ? m.Icons.visibility_off : m.Icons.visibility,
          ),
          tooltip: _obscured ? 'Show password' : 'Hide password',
        ),
      ),
      onChanged: widget.onChanged,
      controller: widget.controller,
      validator: widget.validator,
    );
  }
}

class SearchInput extends m.StatelessWidget {
  const SearchInput({
    super.key,
    this.hint,
    this.onChanged,
    this.controller,
  });

  final String? hint;
  final m.ValueChanged<String>? onChanged;
  final m.TextEditingController? controller;

  @override
  m.Widget build(m.BuildContext context) {
    return m.SearchBar(
      hintText: hint,
      onChanged: onChanged,
      controller: controller,
      leading: const m.Padding(
        padding: m.EdgeInsetsDirectional.only(start: 12),
        child: m.Icon(m.Icons.search),
      ),
    );
  }
}
