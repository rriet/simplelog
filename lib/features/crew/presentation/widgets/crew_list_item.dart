import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/display/slidable_actions.dart';
import 'package:simplelog/data/models/crew_extensions.dart';
import 'package:simplelog/data/models/crew_row.dart';

/// Single crew row with avatar, contact info, and actions.
class CrewListItem extends StatelessWidget {
  /// Creates one crew list row.
  const CrewListItem({
    required this.row,
    required this.isCompact,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    required this.onPhotoTap,
    super.key,
  });

  /// Backing row data.
  final CrewRow row;
  /// Whether compact/mobile mode is active.
  final bool isCompact;
  /// Called to toggle favorite.
  final VoidCallback onToggleFavorite;
  /// Called to toggle lock.
  final VoidCallback onToggleLock;
  /// Called to edit.
  final VoidCallback onEdit;
  /// Called to delete.
  final VoidCallback onDelete;
  /// Called to open details.
  final VoidCallback onOpenDetails;
  /// Called when photo/avatar is tapped.
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = row.crew;
    final initials = item.initials;
    final phone = item.formattedPhone;
    final email = (item.email ?? '').trim();
    final showPhone = phone.isNotEmpty;
    final showEmail = email.isNotEmpty;

    final tile = InkWell(
      onTap: onOpenDetails,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                row.isFavorite ? Icons.star : Icons.star_border,
                color: row.isFavorite
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: onToggleFavorite,
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onPhotoTap,
              child: CircleAvatar(
                radius: 27,
                backgroundImage: item.picture == null
                    ? null
                    : MemoryImage(item.picture!),
                child: item.picture == null
                    ? Text(
                        initials,
                        style: Theme.of(context).textTheme.labelMedium,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  _InfoLine(
                    icon: Icons.phone,
                    label: l10n.fieldPhone,
                    value: phone,
                    visible: showPhone,
                  ),
                  const SizedBox(height: 4),
                  _InfoLine(
                    icon: Icons.email,
                    label: l10n.fieldEmail,
                    value: email,
                    visible: showEmail,
                  ),
                ],
              ),
            ),
            if (!isCompact)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.lockAction,
                    icon: Icon(
                      row.isLocked ? Icons.lock : Icons.lock_open,
                      color: row.isLocked
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: onToggleLock,
                  ),
                  if (!row.isLocked) ...[
                    IconButton(
                      tooltip: l10n.editAction,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      tooltip: l10n.deleteAction,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );

    return SlidableActions(
      key: ValueKey(row.id),
      isCompact: isCompact,
      isLocked: row.isLocked,
      onToggleLock: onToggleLock,
      onEdit: onEdit,
      onDelete: onDelete,
      lockLabel: l10n.lockAction,
      editLabel: l10n.editAction,
      deleteLabel: l10n.deleteAction,
      child: tile,
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.visible,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox(height: 20);
    }
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
