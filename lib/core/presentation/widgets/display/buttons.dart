import 'package:flutter/material.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

/// Visual variants supported by [Buttons].
enum ButtonsVariant {
  /// Outlined button.
  outlined,

  /// Filled button.
  filled,
}

/// Shared form button that follows [AppFormControlsTheme].
class Buttons extends StatelessWidget {
  /// Creates a themed button.
  const Buttons({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.variant = ButtonsVariant.outlined,
  });

  /// Visible button text.
  final String label;

  /// Tap callback.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Button visual style.
  final ButtonsVariant variant;

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

    final child = icon == null
        ? Text(label, overflow: TextOverflow.ellipsis)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: controlsTheme.pickerAddIconSize),
              const SizedBox(width: 6),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final horizontalPadding = EdgeInsets.symmetric(
      horizontal: controlsTheme.horizontalContentPadding,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        controlsTheme.compactBorderRadius,
      ),
    );
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: effectiveBodyFontSize,
    );

    final button = switch (variant) {
      ButtonsVariant.filled => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: horizontalPadding,
          minimumSize: Size(0, compactHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.standard,
          shape: shape,
          textStyle: textStyle,
        ),
        child: child,
      ),
      ButtonsVariant.outlined => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: horizontalPadding,
          minimumSize: Size(0, compactHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.standard,
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: controlsTheme.compactBorderWidth,
          ),
          shape: shape,
          textStyle: textStyle,
        ),
        child: child,
      ),
    };

    return SizedBox(height: compactHeight, child: button);
  }
}
