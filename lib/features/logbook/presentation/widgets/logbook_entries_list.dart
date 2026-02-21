import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_entry.dart';

import 'logbook_list_item.dart';

class LogbookEntriesList extends StatelessWidget {
  const LogbookEntriesList({
    super.key,
    required this.entries,
    this.isCompact = true,
    this.onEntryTap,
  });

  final List<LogbookEntry> entries;
  final bool isCompact;
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
