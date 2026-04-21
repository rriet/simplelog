import 'package:flutter/material.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

/// Compact toggle button used for event-type filters.
class EventTypeToggleButton extends StatelessWidget {
  /// Creates an event-type toggle button.
  const EventTypeToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// Visible button label.
  final String label;

  /// Whether the button is currently selected.
  final bool selected;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
    return SizedBox(
      width: double.infinity,
      height: compactHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: controlsTheme.horizontalContentPadding,
          ),
          minimumSize: Size(0, compactHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          side: BorderSide(
            color: colors.outlineVariant,
            width: controlsTheme.compactBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              controlsTheme.compactBorderRadius,
            ),
          ),
          backgroundColor: selected
              ? colors.secondaryContainer
              : colors.surface,
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: effectiveBodyFontSize,
          ),
        ),
      ),
    );
  }
}
