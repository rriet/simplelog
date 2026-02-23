import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/airport_row.dart';

import 'package:simplelog/features/airports/presentation/widgets/airport_list_item.dart';

/// Public API documentation.
class AirportList extends StatelessWidget {
  /// Public API documentation.
  const AirportList({
    required this.items,
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
  final List<AirportRow> items;
  /// Public API documentation.
  final bool isCompact;
  /// Public API documentation.
  final ValueChanged<AirportRow> onToggleFavorite;
  /// Public API documentation.
  final ValueChanged<AirportRow> onToggleLock;
  /// Public API documentation.
  final ValueChanged<AirportRow> onEdit;
  /// Public API documentation.
  final ValueChanged<AirportRow> onDelete;
  /// Public API documentation.
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
