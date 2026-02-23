import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/presentation/shared/widgets/slidable_actions.dart';

/// Public API documentation.
class AircraftListItem extends StatelessWidget {
  /// Public API documentation.
  const AircraftListItem({
    required this.row,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    super.key,
    this.isMobile = false,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final AircraftRow row;
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
  /// Public API documentation.
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
      title: Row(
        children: [
          Icon(
            row.aircraft.isSimulator
                ? Icons.videogame_asset_outlined
                : Icons.airplanemode_active_outlined,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(row.registration)),
        ],
      ),
      onTap: onOpenDetails,
      subtitle: Text(
        [
          typeLabel,
          '${l10n.fieldMtow}: ${row.effectiveMtow}',
        ].whereType<String>().join(' • '),
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
