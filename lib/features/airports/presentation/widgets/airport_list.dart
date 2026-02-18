import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/airport_row.dart';

import 'airport_list_item.dart';

class AirportList extends StatelessWidget {
  const AirportList({
    super.key,
    required this.items,
    required this.isCompact,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
  });

  final List<AirportRow> items;
  final bool isCompact;
  final ValueChanged<AirportRow> onToggleFavorite;
  final ValueChanged<AirportRow> onToggleLock;
  final ValueChanged<AirportRow> onEdit;
  final ValueChanged<AirportRow> onDelete;
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
