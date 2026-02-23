import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_entry.dart';

import 'package:simplelog/features/logbook/presentation/widgets/logbook_list_item.dart';

/// Public API documentation.
class LogbookEntriesList extends StatelessWidget {
  /// Public API documentation.
  const LogbookEntriesList({
    required this.entries,
    super.key,
    this.isCompact = true,
    this.onEntryTap,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final List<LogbookEntry> entries;
  /// Public API documentation.
  final bool isCompact;
  /// Public API documentation.
  final ValueChanged<LogbookEntry>? onEntryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (entries.isEmpty) {
      return Center(child: Text(l10n.emptyResults));
    }
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return LogbookListItem(
          entry: entry,
          isCompact: isCompact,
          onEdit: onEntryTap == null ? null : (_) => onEntryTap!(entry),
        );
      },
    );
  }
}
