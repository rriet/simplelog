import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/aircraft_row.dart';

import 'aircraft_list_item.dart';

class AircraftList extends StatelessWidget {
  const AircraftList({
    super.key,
    required this.items,
    required this.isCompact,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
  });

  final List<AircraftRow> items;
  final bool isCompact;
  final ValueChanged<AircraftRow> onToggleFavorite;
  final ValueChanged<AircraftRow> onToggleLock;
  final ValueChanged<AircraftRow> onEdit;
  final ValueChanged<AircraftRow> onDelete;
  final ValueChanged<AircraftRow> onOpenDetails;

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
        return AircraftListItem(
          row: row,
          isMobile: isCompact,
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
