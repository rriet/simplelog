import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_entry.dart';

import 'package:simplelog/features/logbook/presentation/widgets/logbook_list_item.dart';

/// Simple flat list of logbook entries.
class LogbookEntriesList extends StatelessWidget {
  /// Creates the entries list.
  const LogbookEntriesList({
    required this.entries,
    super.key,
    this.isCompact = true,
    this.onEntryTap,
  });

  /// Entries to render.
  final List<LogbookEntry> entries;
  /// Compact/mobile mode flag.
  final bool isCompact;
  /// Optional entry tap callback.
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
