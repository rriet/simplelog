import 'package:flutter/material.dart';

class FormDropdownIdField<T> extends StatelessWidget {
  const FormDropdownIdField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.itemValue,
    required this.onChanged,
    this.isRequired = false,
    this.isDense = false,
  });

  final String label;
  final int? value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final int Function(T value) itemValue;
  final ValueChanged<int?> onChanged;
  final bool isRequired;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: isRequired && value == null ? '' : null,
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
