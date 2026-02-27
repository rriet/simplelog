import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/crew_row.dart';

import 'package:simplelog/features/crew/presentation/widgets/crew_list_item.dart';

/// Crew list widget with item actions.
class CrewList extends StatelessWidget {
  /// Creates the crew list.
  const CrewList({
    required this.items,
    required this.isCompact,
    required this.onToggleFavorite,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    required this.onPhotoTap,
    super.key,
  });

  /// Crew rows to render.
  final List<CrewRow> items;
  /// Whether compact/mobile mode is active.
  final bool isCompact;
  /// Called to toggle favorite.
  final ValueChanged<CrewRow> onToggleFavorite;
  /// Called to toggle lock.
  final ValueChanged<CrewRow> onToggleLock;
  /// Called to edit.
  final ValueChanged<CrewRow> onEdit;
  /// Called to delete.
  final ValueChanged<CrewRow> onDelete;
  /// Called to open details.
  final ValueChanged<CrewRow> onOpenDetails;
  /// Called when avatar/photo is tapped.
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
