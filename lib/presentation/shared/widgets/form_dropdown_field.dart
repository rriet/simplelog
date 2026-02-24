import 'package:flutter/material.dart';

/// Labeled dropdown field suitable for use inside forms.
class FormDropdownField<T> extends StatelessWidget {
  /// Creates a dropdown that renders [items] using [itemLabel].
  const FormDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    super.key,
  });

  /// Localized label shown above the dropdown.
  final String label;

  /// Currently selected value.
  final T value;

  /// All selectable items.
  final List<T> items;

  /// Maps an item into the display text shown in the list.
  final String Function(T value) itemLabel;

  /// Invoked when the selected value changes.
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
