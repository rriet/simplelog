import 'package:flutter/material.dart';

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
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(0, 34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: colors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: selected
              ? colors.secondaryContainer
              : colors.surface,
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
