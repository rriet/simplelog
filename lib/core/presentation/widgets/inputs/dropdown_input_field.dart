import 'package:flutter/material.dart';

/// Compact reusable dropdown input field.
class DropdownInputField<T> extends StatelessWidget {
  /// Creates a dropdown field with shared styling.
  const DropdownInputField({
    required this.label,
    required this.items,
    required this.onChanged,
    super.key,
    this.value,
    this.errorText,
  });

  /// Field label.
  final String label;

  /// Currently selected value.
  final T? value;

  /// Available dropdown menu items.
  final List<DropdownMenuItem<T>> items;

  /// Called when the selected value changes.
  final ValueChanged<T?> onChanged;

  /// Optional inline validation error.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
    );
  }
}
