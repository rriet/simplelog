import 'package:flutter/material.dart';

/// Public API documentation.
class FormDropdownField<T> extends StatelessWidget {
  /// Public API documentation.
  const FormDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    super.key,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final String label;
  /// Public API documentation.
  final T value;
  /// Public API documentation.
  final List<T> items;
  /// Public API documentation.
  final String Function(T value) itemLabel;
  /// Public API documentation.
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: [
              for (final item in items)
                DropdownMenuItem(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
