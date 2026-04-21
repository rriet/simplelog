import 'package:flutter/material.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

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
    this.hintText,
    this.showLabel = true,
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

  /// Optional placeholder shown when no [value] is selected.
  final String? hintText;

  /// Whether the floating label chip is shown.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inputTheme =
        theme.extension<AppFormControlsTheme>() ??
        AppFormControlsTheme.fallback;
    final hasError = (errorText ?? '').trim().isNotEmpty;
    final borderColor = hasError
        ? colorScheme.error
        : colorScheme.outlineVariant;
    final labelColor = hasError
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      fontSize: inputTheme.bodyFontSize,
    );
    final hintStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: inputTheme.bodyFontSize,
    );

    final control = SizedBox(
      height: inputTheme.compactFieldHeight,
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
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: inputTheme.horizontalContentPadding,
                  vertical: inputTheme.verticalContentPadding,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    items: items,
                    onChanged: onChanged,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: textStyle,
                    hint: hintText == null
                        ? null
                        : Text(
                            hintText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: hintStyle,
                          ),
                  ),
                ),
              ),
            ),
          ),
          if (showLabel)
            Positioned(
              left: inputTheme.labelOffsetLeft,
              top: inputTheme.labelOffsetTop,
              child: Container(
                color: colorScheme.surface,
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
