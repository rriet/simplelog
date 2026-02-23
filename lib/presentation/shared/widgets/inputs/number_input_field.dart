import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact numeric input field (integer values).
class NumberInputField extends StatelessWidget {
  /// Creates a numeric input field with shared form styling.
  const NumberInputField({
    required this.controller,
    required this.label,
    super.key,
    this.allowEmpty = false,
    this.enabled = true,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
    this.hintText,
    this.floatingLabelBehavior,
  });

  /// Text controller used by the field.
  final TextEditingController controller;

  /// Field label.
  final String label;

  /// Whether empty values are accepted.
  final bool allowEmpty;

  /// Whether user input is enabled.
  final bool enabled;

  /// Called when the parsed number changes.
  final ValueChanged<int?>? onChanged;

  /// Optional trailing icon widget.
  final Widget? suffixIcon;

  /// Optional external inline error text.
  final String? errorText;

  /// Optional placeholder text.
  final String? hintText;

  /// Label floating behavior override.
  final FloatingLabelBehavior? floatingLabelBehavior;

  /// Parses an integer value from raw text.
  static int? parse(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: floatingLabelBehavior,
        border: const OutlineInputBorder(),
        errorText: errorText,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        suffixIcon: suffixIcon,
      ),
      onChanged: (value) => onChanged?.call(parse(value)),
      validator: (value) {
        final raw = value ?? '';
        if (allowEmpty && raw.trim().isEmpty) return null;
        if (parse(raw) == null) return 'Invalid number.';
        return null;
      },
    );
  }
}
