import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/aircraft_row.dart';

import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_list_item.dart';

/// Public API documentation.
class AircraftList extends StatelessWidget {
  /// Public API documentation.
  const AircraftList({
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
  final List<AircraftRow> items;
  /// Public API documentation.
  final bool isCompact;
  /// Public API documentation.
  final ValueChanged<AircraftRow> onToggleFavorite;
  /// Public API documentation.
  final ValueChanged<AircraftRow> onToggleLock;
  /// Public API documentation.
  final ValueChanged<AircraftRow> onEdit;
  /// Public API documentation.
  final ValueChanged<AircraftRow> onDelete;
  /// Public API documentation.
  final ValueChanged<AircraftRow> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return Center(
        child: Text(l10n.emptyResults),
      );
    }

    final sectionEntries = _buildSectionEntries(items);

    return ListView.builder(
      itemCount: sectionEntries.length,
      itemBuilder: (context, index) {
        final entry = sectionEntries[index];
        if (entry.header != null) {
          return _SectionHeader(title: entry.header!);
        }
        final row = entry.row!;
        return Column(
          children: [
            AircraftListItem(
              row: row,
              isMobile: isCompact,
              onToggleFavorite: () => onToggleFavorite(row),
              onToggleLock: () => onToggleLock(row),
              onEdit: () => onEdit(row),
              onDelete: () => onDelete(row),
              onOpenDetails: () => onOpenDetails(row),
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  List<_SectionEntry> _buildSectionEntries(List<AircraftRow> source) {
    final result = <_SectionEntry>[];
    final favorites = source.where((row) => row.isFavorite).toList()
      ..sort((a, b) => a.registration.compareTo(b.registration));
    if (favorites.isNotEmpty) {
      result
        ..add(const _SectionEntry.header('Favorites'))
        ..addAll(favorites.map(_SectionEntry.row));
    }

    final groups = <String, List<AircraftRow>>{};
    for (final row in source) {
      final key = _typeLabel(row);
      groups.putIfAbsent(key, () => <AircraftRow>[]).add(row);
    }
    final keys = groups.keys.toList()..sort();
    for (final key in keys) {
      final rows = groups[key]!
        ..sort((a, b) => a.registration.compareTo(b.registration));
      result
        ..add(_SectionEntry.header(key))
        ..addAll(rows.map(_SectionEntry.row));
    }
    return result;
  }

  String _typeLabel(AircraftRow row) {
    final code = row.type?.code.trim() ?? '';
    if (code.isNotEmpty) return code;
    final longName = row.type?.longName.trim() ?? '';
    if (longName.isNotEmpty) return longName;
    return 'Unknown Type';
  }
}

class _SectionEntry {
  const _SectionEntry.header(this.header) : row = null;
  const _SectionEntry.row(this.row) : header = null;

  final String? header;
  final AircraftRow? row;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
