import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/aircraft_type_extensions.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/presentation/shared/widgets/slidable_actions.dart';

/// List tile for a single aircraft type with slide actions on compact layouts.
class AircraftTypeRowTile extends StatelessWidget {
  /// Creates a tile for [row] with callbacks for actions.
  const AircraftTypeRowTile({
    required this.row,
    required this.isCompact,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    super.key,
  });

  /// Backing aircraft type row.
  final AircraftTypeRow row;

  /// Whether to render a compact layout.
  final bool isCompact;

  /// Called when the lock state of [row] should be toggled.
  final ValueChanged<AircraftTypeRow> onToggleLock;

  /// Called when [row] should be edited.
  final ValueChanged<AircraftTypeRow> onEdit;

  /// Called when [row] should be deleted.
  final ValueChanged<AircraftTypeRow> onDelete;

  /// Called when the user taps the row to open more details.
  final ValueChanged<AircraftTypeRow> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = AircraftTypeRowContent(
      row: row,
      isCompact: isCompact,
      onToggleLock: onToggleLock,
      onEdit: onEdit,
      onDelete: onDelete,
      onOpenDetails: onOpenDetails,
    );

    return SlidableActions(
      key: ValueKey(row.id),
      isCompact: isCompact,
      isLocked: row.isLocked,
      onToggleLock: () => onToggleLock(row),
      onEdit: () => onEdit(row),
      onDelete: () => onDelete(row),
      lockLabel: l10n.lockAction,
      editLabel: l10n.editAction,
      deleteLabel: l10n.deleteAction,
      child: content,
    );
  }
}

/// Detailed content layout for an aircraft type row.
class AircraftTypeRowContent extends StatelessWidget {
  /// Creates a content widget for the given [row].
  const AircraftTypeRowContent({
    required this.row,
    required this.isCompact,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    super.key,
  });

  /// Backing aircraft type row.
  final AircraftTypeRow row;

  /// Whether to render a compact layout.
  final bool isCompact;

  /// Called when the lock state of [row] should be toggled.
  final ValueChanged<AircraftTypeRow> onToggleLock;

  /// Called when [row] should be edited.
  final ValueChanged<AircraftTypeRow> onEdit;

  /// Called when [row] should be deleted.
  final ValueChanged<AircraftTypeRow> onDelete;

  /// Called when the user taps to open the details view.
  final ValueChanged<AircraftTypeRow> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = row.type;
    final maker = item.manufacturer?.trim();
    final hasMaker = maker != null && maker.isNotEmpty;
    final longName = item.longName.trim();
    final multiEngine = item.isMultiEngine;

    return InkWell(
      onTap: () => onOpenDetails(row),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isCompact ? 96 : 130,
              child: Text(
                row.code,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (!isCompact) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metaLine(
                      context,
                      l10n.fieldLongName,
                      longName.isEmpty ? '-' : longName,
                    ),
                    _metaLine(
                      context,
                      l10n.fieldManufacturer,
                      hasMaker ? maker : '-',
                    ),
                    _metaLine(
                      context,
                      l10n.fieldEngineType,
                      item.engineType.name,
                    ),
                    _metaLine(
                      context,
                      l10n.fieldCategory,
                      item.category.name,
                    ),
                    _metaLine(
                      context,
                      l10n.fieldMtow,
                      item.mtow.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (isCompact) const Spacer(),
            SizedBox(
              width: isCompact ? null : 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _flagText(context, 'EFIS', item.efis),
                  _flagText(context, 'Complex', item.complex),
                  _flagText(context, 'HighPerf', item.highPerformance),
                  _flagText(context, 'MultiPilot', item.multiPilot),
                  _flagText(context, 'MultiEngine', multiEngine),
                ],
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 8),
              RowActions(
                row: row,
                onToggleLock: onToggleLock,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metaLine(BuildContext context, String label, String value) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$label: ', style: style),
          Flexible(child: Text(value, style: style)),
        ],
      ),
    );
  }

  Widget _flagText(BuildContext context, String label, bool isOn) {
    final color = isOn
        ? Colors.blue
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}

/// Column of icon buttons used for lock/edit/delete actions on a row.
class RowActions extends StatelessWidget {
  /// Creates a vertical action strip bound to [row].
  const RowActions({
    required this.row,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Backing row that actions operate on.
  final AircraftTypeRow row;

  /// Called when the lock state of [row] should be toggled.
  final ValueChanged<AircraftTypeRow> onToggleLock;

  /// Called when [row] should be edited.
  final ValueChanged<AircraftTypeRow> onEdit;

  /// Called when [row] should be deleted.
  final ValueChanged<AircraftTypeRow> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        IconButton(
          tooltip: l10n.lockAction,
          icon: Icon(
            row.isLocked ? Icons.lock : Icons.lock_open,
            color: row.isLocked
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => onToggleLock(row),
        ),
        if (!row.isLocked) ...[
          IconButton(
            tooltip: l10n.editAction,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => onEdit(row),
          ),
          IconButton(
            tooltip: l10n.deleteAction,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => onDelete(row),
          ),
        ],
      ],
    );
  }
}
