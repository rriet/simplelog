import 'package:flutter/material.dart';

/// Tappable date selector styled as a form input.
class DateSelectorInputField extends StatelessWidget {
  /// Creates a date selector input styled like other form fields.
  const DateSelectorInputField({
    required this.label,
    required this.valueText,
    required this.onTap,
    super.key,
    this.errorText,
    this.onClear,
    this.labelBackgroundColor,
  });

  /// Field label.
  final String label;

  /// Selected date text shown in the field.
  final String valueText;

  /// Called when the field is tapped.
  final VoidCallback onTap;

  /// Optional inline validation error.
  final String? errorText;

  /// Optional clear callback shown as a trailing clear icon.
  final VoidCallback? onClear;

  /// Optional label background color for floating-label contrast.
  final Color? labelBackgroundColor;

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
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          valueText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (onClear != null)
                        IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.clear, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          visualDensity: VisualDensity.compact,
                          splashRadius: 14,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: -8,
            child: Container(
              color: labelBackgroundColor ?? colorScheme.surface,
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
