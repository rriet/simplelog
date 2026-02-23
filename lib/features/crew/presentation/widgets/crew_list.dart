import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/crew_row.dart';

import 'package:simplelog/features/crew/presentation/widgets/crew_list_item.dart';

/// Public API documentation.
class CrewList extends StatelessWidget {
  /// Public API documentation.
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
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final List<CrewRow> items;
  /// Public API documentation.
  final bool isCompact;
  /// Public API documentation.
  final ValueChanged<CrewRow> onToggleFavorite;
  /// Public API documentation.
  final ValueChanged<CrewRow> onToggleLock;
  /// Public API documentation.
  final ValueChanged<CrewRow> onEdit;
  /// Public API documentation.
  final ValueChanged<CrewRow> onDelete;
  /// Public API documentation.
  final ValueChanged<CrewRow> onOpenDetails;
  /// Public API documentation.
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
