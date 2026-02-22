import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact numeric input field (integer values).
class NumberInputField extends StatelessWidget {
  const NumberInputField({
    super.key,
    required this.controller,
    required this.label,
    this.allowEmpty = false,
    this.enabled = true,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
    this.hintText,
    this.floatingLabelBehavior,
  });

  final TextEditingController controller;
  final String label;
  final bool allowEmpty;
  final bool enabled;
  final ValueChanged<int?>? onChanged;
  final Widget? suffixIcon;
  final String? errorText;
  final String? hintText;
  final FloatingLabelBehavior? floatingLabelBehavior;

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
