import 'package:flutter/material.dart';

/// Compact outlined button with a square-ish input-like appearance.
class SquareOutlineButton extends StatelessWidget {
  /// Creates a compact square-style outlined button.
  const SquareOutlineButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
  });

  /// Button label.
  final String label;

  /// Tap callback.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

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
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: child,
      ),
    );
  }
}
