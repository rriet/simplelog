import 'package:flutter/material.dart';

/// Compact outlined button with a square-ish input-like appearance.
class SquareOutlineButton extends StatelessWidget {
  /// Creates a compact square-style outlined button.
  const SquareOutlineButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.height = 40,
  });

  /// Button label.
  final String label;

  /// Tap callback.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;
  /// Explicit button height. Defaults to 40.
  final double height;

  /// Shared outlined style used by form buttons across the app.
  static ButtonStyle outlinedStyle(ColorScheme colorScheme) {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(0, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Shared filled style used by form buttons across the app.
  static ButtonStyle filledStyle(ColorScheme colorScheme) {
    return FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(0, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Shared elevated style used by form buttons across the app.
  static ButtonStyle elevatedStyle(ColorScheme colorScheme) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(0, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final child = icon == null
        ? Text(label, overflow: TextOverflow.ellipsis)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: outlinedStyle(colorScheme).copyWith(
          minimumSize: WidgetStatePropertyAll<Size>(Size(0, height)),
        ),
        child: child,
      ),
    );
  }
}
