import 'package:flutter/material.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

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
    final inputTheme =
        theme.extension<AppFormControlsTheme>() ??
        AppFormControlsTheme.fallback;
    final compactHeight = inputTheme.resolvedCompactFieldHeight(
      context,
      baseTextStyle: theme.textTheme.bodyMedium,
    );
    final effectiveBodyFontSize = inputTheme.resolvedBodyFontSize(
      context,
      baseTextStyle: theme.textTheme.bodyMedium,
      controlHeight: compactHeight,
    );
    final hasError = (errorText ?? '').trim().isNotEmpty;
    final borderColor = hasError
        ? colorScheme.error
        : colorScheme.outlineVariant;
    final labelColor = hasError
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    final control = SizedBox(
      height: compactHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  inputTheme.compactBorderRadius,
                ),
                side: BorderSide(
                  color: borderColor,
                  width: inputTheme.compactBorderWidth,
                ),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(
                  inputTheme.compactBorderRadius,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: inputTheme.horizontalContentPadding,
                    vertical: inputTheme.verticalContentPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          valueText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: effectiveBodyFontSize,
                          ),
                        ),
                      ),
                      if (onClear != null)
                        IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.clear, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: inputTheme.suffixIconMinSize,
                            minHeight: inputTheme.suffixIconMinSize,
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
            left: inputTheme.labelOffsetLeft,
            top: inputTheme.labelOffsetTop,
            child: Container(
              color: labelBackgroundColor ?? colorScheme.surface,
              padding: EdgeInsets.symmetric(
                horizontal: inputTheme.labelChipHorizontalPadding,
              ),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: labelColor,
                  fontSize: inputTheme.labelFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final padded = EdgeInsets.symmetric(
      vertical: inputTheme.fieldVerticalGap / 2,
    );
    if (!hasError) return Padding(padding: padded, child: control);

    return Padding(
      padding: padded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          control,
          SizedBox(height: inputTheme.errorTopSpacing),
          Padding(
            padding: EdgeInsets.only(left: inputTheme.errorLeftPadding),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontSize: inputTheme.errorFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
