import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/airport_extensions.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/presentation/shared/widgets/slidable_actions.dart';

/// Public API documentation.
class AirportListItem extends StatelessWidget {
  /// Public API documentation.
  const AirportListItem({
    required this.row,
    required this.isCompact,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    super.key,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final AirportRow row;
  /// Public API documentation.
  final bool isCompact;
  /// Public API documentation.
  final VoidCallback onToggleFavorite;
  /// Public API documentation.
  final VoidCallback onToggleLock;
  /// Public API documentation.
  final VoidCallback onEdit;
  /// Public API documentation.
  final VoidCallback onDelete;
  /// Public API documentation.
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = row.airport;
    final subtitleParts = [
      if (item.name != null) item.name!,
      if (item.city != null) item.city!,
      if (item.country != null) item.country!,
    ].where((value) => value.trim().isNotEmpty).toList();

    final code = item.displayCode;
    final visitLabel = 'Times visited: ${row.totalVisits}';

    final tile = ListTile(
      leading: IconButton(
        icon: Icon(
          row.isFavorite ? Icons.star : Icons.star_border,
          color: row.isFavorite
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: onToggleFavorite,
      ),
      title: isCompact
          ? Row(
              children: [
                Expanded(child: Text(code)),
                const SizedBox(width: 8),
                Text(
                  visitLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            )
          : Text(code),
      subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
      onTap: onOpenDetails,
      trailing: isCompact
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    visitLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
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
