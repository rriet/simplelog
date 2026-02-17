import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/crew_row.dart';

import 'crew_list_item.dart';

class CrewList extends StatelessWidget {
  const CrewList({
    super.key,
    required this.items,
    required this.isCompact,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    required this.onPhotoTap,
  });

  final List<CrewRow> items;
  final bool isCompact;
  final ValueChanged<CrewRow> onToggleFavorite;
  final ValueChanged<CrewRow> onToggleLock;
  final ValueChanged<CrewRow> onEdit;
  final ValueChanged<CrewRow> onDelete;
  final ValueChanged<CrewRow> onOpenDetails;
  final ValueChanged<CrewRow> onPhotoTap;

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
        return CrewListItem(
          row: row,
          isCompact: isCompact,
          onToggleFavorite: () => onToggleFavorite(row),
          onToggleLock: () => onToggleLock(row),
          onEdit: () => onEdit(row),
          onDelete: () => onDelete(row),
          onOpenDetails: () => onOpenDetails(row),
          onPhotoTap: () => onPhotoTap(row),
        );
      },
    );
  }
}
