import 'package:flutter/material.dart';

/// Dropdown field that binds to integer ids while displaying typed models.
class FormDropdownIdField<T> extends StatelessWidget {
  /// Creates a dropdown mapping [items] to integer ids via [itemValue].
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
  });

  /// Localized label shown above the dropdown.
  final String label;

  /// Currently selected id, if any.
  final int? value;

  /// Full list of items that can be selected.
  final List<T> items;

  /// Returns the label used to represent [value] in the UI.
  final String Function(T value) itemLabel;

  /// Returns the integer id that uniquely identifies [value].
  final int Function(T value) itemValue;

  /// Notified when the selected id changes.
  final ValueChanged<int?> onChanged;

  /// Whether the field is required to have a non‑null value.
  final bool isRequired;

  /// Whether to show an error border when [isRequired] and [value] is `null`.
  final bool showRequiredError;

  /// Whether to use a more compact visual density.
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
