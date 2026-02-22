import 'package:flutter/material.dart';

/// Tappable picker field with a companion add button, styled like form inputs.
class PickerWithAddInputField extends StatelessWidget {
  const PickerWithAddInputField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
    this.onAdd,
    this.addTooltip,
  });

  final String label;
  final String valueText;
  final VoidCallback onTap;
  final VoidCallback? onAdd;
  final String? addTooltip;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outline;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      valueText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.search,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onAdd != null) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: addTooltip ?? 'Add',
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add, size: 20),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
