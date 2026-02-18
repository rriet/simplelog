import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/presentation/shared/widgets/slidable_actions.dart';

class AircraftListItem extends StatelessWidget {
  const AircraftListItem({
    super.key,
    required this.row,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    this.isMobile = false,
  });

  final AircraftRow row;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleLock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenDetails;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = row.type?.code;

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
      title: Text(row.registration),
      onTap: onOpenDetails,
      subtitle: Text(
        [
          if (typeLabel != null) typeLabel,
          '${l10n.fieldMtow}: ${row.effectiveMtow}',
        ].join(' • '),
      ),
      trailing: isMobile ? null : _buildActions(context, l10n),
    );

    return SlidableActions(
      key: ValueKey(row.id),
      isCompact: isMobile,
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

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Row(
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
    );
  }

}
