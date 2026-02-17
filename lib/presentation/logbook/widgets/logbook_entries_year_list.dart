import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_entry.dart';

import 'logbook_list_item.dart';

class LogbookEntriesYearList extends StatefulWidget {
  const LogbookEntriesYearList({
    super.key,
    required this.entries,
    this.isCompact = true,
    this.onEntryTap,
  });

  final List<LogbookEntry> entries;
  final bool isCompact;
  final ValueChanged<LogbookEntry>? onEntryTap;

  @override
  State<LogbookEntriesYearList> createState() =>
      _LogbookEntriesYearListState();
}

class _LogbookEntriesYearListState extends State<LogbookEntriesYearList> {
  final ScrollController _controller = ScrollController();
  final Map<int, GlobalKey> _yearKeys = {};
  final Map<int, double> _yearOffsets = {};
  int? _currentYear;
  static const double _stickyHeight = 36;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCurrentYear());
  }

  @override
  void didUpdateWidget(LogbookEntriesYearList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateCurrentYear());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll() {
    _updateCurrentYear();
  }

  void _updateCurrentYear() {
    if (!mounted) return;
    if (!_controller.hasClients) return;
    final listBox = context.findRenderObject() as RenderBox?;
    if (listBox == null) return;
    final target = _controller.offset + _stickyHeight;

    _measureHeaders(listBox);
    if (_yearOffsets.isEmpty) return;

    final offsets = _yearOffsets.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    int? year;
    for (final entry in offsets) {
      if (entry.value <= target) {
        year = entry.key;
      }
    }
    year ??= offsets.first.key;
    if (year != _currentYear) {
      setState(() => _currentYear = year);
    }
  }

  void _measureHeaders(RenderBox listBox) {
    for (final entry in _yearKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero, ancestor: listBox).dy;
      _yearOffsets[entry.key] = dy + _controller.offset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.entries.isEmpty) {
      return Center(child: Text(l10n.emptyResults));
    }

    final sorted = widget.entries.toList()
      ..sort(
        (a, b) => b.timeLine.eventDateTime.compareTo(
          a.timeLine.eventDateTime,
        ),
      );
    final items = _buildItems(sorted);

    return Stack(
      children: [
        ListView.builder(
          controller: _controller,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            if (item is _YearHeader) {
              final key = _yearKeys.putIfAbsent(
                item.year,
                () => GlobalKey(),
              );
              return _YearHeaderTile(
                key: key,
                year: item.year,
              );
            }
            final entry = (item as _EntryItem).entry;
            return LogbookListItem(
              entry: entry,
              isCompact: widget.isCompact,
              onEdit: widget.onEntryTap == null
                  ? null
                  : (_) => widget.onEntryTap!(entry),
            );
          },
        ),
        if (_currentYear != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _stickyHeight,
            child: _StickyYearHeader(year: _currentYear!),
          ),
      ],
    );
  }

  List<_ListItem> _buildItems(List<LogbookEntry> sorted) {
    final result = <_ListItem>[];
    int? currentYear;
    for (final entry in sorted) {
      final year = entry.timeLine.eventDateTime.year;
      if (currentYear != year) {
        currentYear = year;
        result.add(_YearHeader(year));
      }
      result.add(_EntryItem(entry));
    }
    return result;
  }
}

abstract class _ListItem {
  const _ListItem();
}

class _YearHeader extends _ListItem {
  const _YearHeader(this.year);

  final int year;
}

class _EntryItem extends _ListItem {
  const _EntryItem(this.entry);

  final LogbookEntry entry;
}

class _YearHeaderTile extends StatelessWidget {
  const _YearHeaderTile({super.key, required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        '--- $year ---',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _StickyYearHeader extends StatelessWidget {
  const _StickyYearHeader({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        '--- $year ---',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
