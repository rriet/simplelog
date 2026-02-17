import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableActions extends StatelessWidget {
  const SlidableActions({
    super.key,
    required this.child,
    required this.isCompact,
    this.isLocked = false,
    this.onToggleLock,
    this.onEdit,
    this.onDelete,
    required this.lockLabel,
    required this.editLabel,
    required this.deleteLabel,
    this.inlineActions,
  });

  final Widget child;
  final bool isCompact;
  final bool isLocked;
  final VoidCallback? onToggleLock;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String lockLabel;
  final String editLabel;
  final String deleteLabel;
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
