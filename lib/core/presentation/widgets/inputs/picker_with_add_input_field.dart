import 'package:flutter/material.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

/// Tappable picker field with a companion add button, styled like form inputs.
class PickerWithAddInputField extends StatelessWidget {
  /// Creates a picker row with optional add action button.
  const PickerWithAddInputField({
    required this.label,
    required this.valueText,
    required this.onTap,
    super.key,
    this.onAdd,
    this.addTooltip,
    this.errorText,
  });

  /// Field label.
  final String label;

  /// Selected value text shown in the field.
  final String valueText;

  /// Called when the picker field is tapped.
  final VoidCallback onTap;

  /// Optional action triggered by the add button.
  final VoidCallback? onAdd;

  /// Optional tooltip for the add button.
  final String? addTooltip;

  /// Optional inline validation error.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controlsTheme =
        theme.extension<AppFormControlsTheme>() ??
        AppFormControlsTheme.fallback;
    final compactHeight = controlsTheme.resolvedCompactFieldHeight(
      context,
      baseTextStyle: theme.textTheme.bodyMedium,
    );
    final effectiveBodyFontSize = controlsTheme.resolvedBodyFontSize(
      context,
      baseTextStyle: theme.textTheme.bodyMedium,
      controlHeight: compactHeight,
    );
    final addIconSize = controlsTheme.pickerAddIconSize;
    final addBorderRadius = controlsTheme.pickerAddBorderRadius;
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
                  controlsTheme.compactBorderRadius,
                ),
                side: BorderSide(
                  color: borderColor,
                  width: controlsTheme.compactBorderWidth,
                ),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(
                  controlsTheme.compactBorderRadius,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: controlsTheme.horizontalContentPadding,
                    vertical: controlsTheme.verticalContentPadding,
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
                      Icon(
                        Icons.search,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: controlsTheme.labelOffsetLeft,
            top: controlsTheme.labelOffsetTop,
            child: Container(
              color: colorScheme.surface,
              padding: EdgeInsets.symmetric(
                horizontal: controlsTheme.labelChipHorizontalPadding,
              ),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: labelColor,
                  fontSize: controlsTheme.labelFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final field = !hasError
        ? control
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              control,
              SizedBox(height: controlsTheme.errorTopSpacing),
              Padding(
                padding: EdgeInsets.only(left: controlsTheme.errorLeftPadding),
                child: Text(
                  errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontSize: controlsTheme.errorFontSize,
                  ),
                ),
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: controlsTheme.fieldVerticalGap / 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: field),
          if (onAdd != null) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: addTooltip ?? 'Add',
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(addBorderRadius),
                child: Container(
                  width: compactHeight,
                  height: compactHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(addBorderRadius),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.add, size: addIconSize),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
