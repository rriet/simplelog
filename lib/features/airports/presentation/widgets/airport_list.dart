import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/airport_row.dart';

import 'package:simplelog/features/airports/presentation/widgets/airport_list_item.dart';

/// Airport list widget with item actions.
class AirportList extends StatelessWidget {
  /// Creates the airport list.
  const AirportList({
    required this.items,
    required this.isCompact,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    super.key,
  });

  /// Airport rows to render.
  final List<AirportRow> items;
  /// Whether compact/mobile mode is active.
  final bool isCompact;
  /// Called to toggle favorite state.
  final ValueChanged<AirportRow> onToggleFavorite;
  /// Called to toggle lock state.
  final ValueChanged<AirportRow> onToggleLock;
  /// Called to edit an item.
  final ValueChanged<AirportRow> onEdit;
  /// Called to delete an item.
  final ValueChanged<AirportRow> onDelete;
  /// Called to open airport details.
  final ValueChanged<AirportRow> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return Center(
        child: Text(l10n.emptyResults),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = items[index];
        return AirportListItem(
          row: row,
          isCompact: isCompact,
          onToggleFavorite: () => onToggleFavorite(row),
          onToggleLock: () => onToggleLock(row),
          onEdit: () => onEdit(row),
          onDelete: () => onDelete(row),
          onOpenDetails: () => onOpenDetails(row),
        );
      },
    );
  }
}
