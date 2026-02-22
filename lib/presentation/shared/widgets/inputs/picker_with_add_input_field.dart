import 'package:flutter/material.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

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
    final controlsTheme = Theme.of(context).extension<AppFormControlsTheme>();
    final addButtonSize = controlsTheme?.pickerAddButtonSize ?? 40;
    final addIconSize = controlsTheme?.pickerAddIconSize ?? 20;
    final addBorderRadius = controlsTheme?.pickerAddBorderRadius ?? 8;
    final borderColor = Theme.of(context).colorScheme.outline;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(addBorderRadius),
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
              borderRadius: BorderRadius.circular(addBorderRadius),
              child: Container(
                width: addButtonSize,
                height: addButtonSize,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(addBorderRadius),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.add, size: addIconSize),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
