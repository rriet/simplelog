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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = (errorText ?? '').trim().isNotEmpty;
    final borderColor = hasError
        ? colorScheme.error
        : colorScheme.outlineVariant;
    final labelColor = hasError
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    const controlHeight = 34.0;

    final control = SizedBox(
      height: controlHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    items: items,
                    onChanged: onChanged,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: -8,
            child: Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: labelColor),
              ),
            ),
          ),
        ],
      ),
    );

    if (!hasError) return control;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        control,
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}
