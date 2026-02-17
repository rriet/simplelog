import 'package:flutter/material.dart';

class FormDropdownField<T> extends StatelessWidget {
  const FormDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
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
