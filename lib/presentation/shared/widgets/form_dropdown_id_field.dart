import 'package:flutter/material.dart';

/// Public API documentation.
class FormDropdownIdField<T> extends StatelessWidget {
  /// Public API documentation.
  const FormDropdownIdField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.itemValue,
    required this.onChanged,
    super.key,
    this.isRequired = false,
    this.showRequiredError = true,
    this.isDense = false,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final String label;
  /// Public API documentation.
  final int? value;
  /// Public API documentation.
  final List<T> items;
  /// Public API documentation.
  final String Function(T value) itemLabel;
  /// Public API documentation.
  final int Function(T value) itemValue;
  /// Public API documentation.
  final ValueChanged<int?> onChanged;
  /// Public API documentation.
  final bool isRequired;
  /// Public API documentation.
  final bool showRequiredError;
  /// Public API documentation.
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: isRequired && showRequiredError && value == null
              ? ''
              : null,
          isDense: isDense,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            isDense: isDense,
            items: [
              for (final item in items)
                DropdownMenuItem(
                  value: itemValue(item),
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
