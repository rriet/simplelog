import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Wraps list content with compact swipe actions or inline desktop actions.
class SlidableActions extends StatelessWidget {
  /// Creates the slidable/inline actions wrapper.
  const SlidableActions({
    required this.child,
    required this.isCompact,
    required this.lockLabel,
    required this.editLabel,
    required this.deleteLabel,
    super.key,
    this.isLocked = false,
    this.onToggleLock,
    this.onEdit,
    this.onDelete,
    this.inlineActions,
  });

  /// Row content.
  final Widget child;

  /// Enables compact swipe actions when `true`.
  final bool isCompact;

  /// Current locked state.
  final bool isLocked;

  /// Called to toggle lock state.
  final VoidCallback? onToggleLock;

  /// Called to edit item.
  final VoidCallback? onEdit;

  /// Called to delete item.
  final VoidCallback? onDelete;

  /// Localized lock action label.
  final String lockLabel;

  /// Localized edit action label.
  final String editLabel;

  /// Localized delete action label.
  final String deleteLabel;

  /// Optional inline actions widget for non-compact layouts.
  final Widget? inlineActions;

  @override
  Widget build(BuildContext context) {
    if (!isCompact) {
      if (inlineActions == null) {
        return child;
      }
      if (child is ListTile) {
        final tile = child as ListTile;
        return ListTile(
          leading: tile.leading,
          title: tile.title,
          subtitle: tile.subtitle,
          trailing: inlineActions,
          onTap: tile.onTap,
          dense: tile.dense,
          contentPadding: tile.contentPadding,
        );
      }
      return Row(
        children: [
          Expanded(child: child),
          inlineActions!,
        ],
      );
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onToggleLock != null)
            SlidableAction(
              onPressed: (_) => onToggleLock!(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: isLocked ? Icons.lock : Icons.lock_open,
              label: lockLabel,
            ),
          if (!isLocked && onEdit != null) ...[
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              icon: Icons.edit_outlined,
              label: editLabel,
            ),
          ],
          if (!isLocked && onDelete != null) ...[
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              icon: Icons.delete_outline,
              label: deleteLabel,
            ),
          ],
        ],
      ),
      child: child,
    );
  }
}
