import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/presentation/shared/widgets/slidable_actions.dart';

import 'logbook_list_item.dart';

abstract class LogbookListItemModel {
  const LogbookListItemModel();

  DateTime get sortDate;
}

class LogbookEntryItem extends LogbookListItemModel {
  const LogbookEntryItem(this.entry);

  final LogbookEntry entry;

  @override
  DateTime get sortDate => entry.timeLine.eventDateTime;
}

class LogbookDutyGroupItem extends LogbookListItemModel {
  const LogbookDutyGroupItem({
    required this.dutyId,
    required this.start,
    required this.end,
    required this.entries,
    required this.isLocked,
    required this.dutyMinutes,
    required this.factoredMinutes,
  });

  final int dutyId;
  final DateTime start;
  final DateTime end;
  final List<LogbookEntry> entries;
  final bool isLocked;
  final int dutyMinutes;
  final int factoredMinutes;

  @override
  DateTime get sortDate => start;
}

class LogbookYearHeaderItem extends LogbookListItemModel {
  const LogbookYearHeaderItem(this.year, DateTime date)
      : _date = date;

  final int year;
  final DateTime _date;

  @override
  DateTime get sortDate => _date;
}

class LogbookList extends StatefulWidget {
  const LogbookList({
    super.key,
    required this.onOpenEntry,
    required this.items,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.onToggleLockEntry,
    required this.onEditDuty,
    required this.onDeleteDuty,
    required this.onToggleLockDuty,
    required this.onYearChange,
    this.controller,
  });

  final List<LogbookListItemModel> items;
  final ValueChanged<LogbookEntry> onOpenEntry;
  final ValueChanged<LogbookEntry> onEditEntry;
  final ValueChanged<LogbookEntry> onDeleteEntry;
  final ValueChanged<LogbookEntry> onToggleLockEntry;
  final ValueChanged<LogbookDutyGroupItem> onEditDuty;
  final ValueChanged<LogbookDutyGroupItem> onDeleteDuty;
  final ValueChanged<LogbookDutyGroupItem> onToggleLockDuty;
  final ValueChanged<int?> onYearChange;
  final ScrollController? controller;

  @override
  State<LogbookList> createState() => _LogbookListState();
}

class _LogbookListState extends State<LogbookList> {
  final ScrollController _internalController = ScrollController();
  final Map<int, GlobalKey> _yearKeys = {};
  final Map<int, double> _yearOffsets = {};
  int? _currentYear;
  static const double _stickyHeight = 40;
  bool _ownsController = true;

  ScrollController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCurrentYear());
  }

  @override
  void didUpdateWidget(LogbookList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _internalController.removeListener(_handleScroll);
      } else {
        oldWidget.controller?.removeListener(_handleScroll);
      }
      _ownsController = widget.controller == null;
      _controller.addListener(_handleScroll);
    }
    if (oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateCurrentYear());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    if (_ownsController) {
      _internalController.dispose();
    }
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
      _currentYear = year;
      widget.onYearChange(year);
      setState(() {});
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

    if (widget.items.isEmpty) {
      return Center(
        child: Text(l10n.emptyResults),
      );
    }

    final isCompact = MediaQuery.of(context).size.width < 600;
    final displayItems = _withYearHeaders(widget.items);

    return Stack(
      children: [
        ListView.builder(
          controller: _controller,
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            if (item is LogbookYearHeaderItem) {
              final key = _yearKeys.putIfAbsent(
                item.year,
                () => GlobalKey(),
              );
              return _YearHeader(
                key: key,
                year: item.year,
              );
            }
            return Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1.2,
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.6),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 6,
                  ),
                  child: _buildItem(item, isCompact),
                ),
              ],
            );
          },
        ),
        if (_currentYear != null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SizedBox(
              height: _stickyHeight,
              child: _StickyYearHeader(year: _currentYear!),
            ),
          ),
      ],
    );
  }

  Widget _buildItem(
    LogbookListItemModel item,
    bool isCompact,
  ) {
    if (item is LogbookEntryItem) {
      return LogbookListItem(
        entry: item.entry,
        isCompact: isCompact,
        onOpen: widget.onOpenEntry,
        onEdit: widget.onEditEntry,
        onDelete: widget.onDeleteEntry,
        onToggleLock: widget.onToggleLockEntry,
      );
    }
    if (item is LogbookDutyGroupItem) {
      return _LogbookDutyGroupCard(
        group: item,
        isCompact: isCompact,
        onEdit: widget.onEditDuty,
        onDelete: widget.onDeleteDuty,
        onToggleLock: widget.onToggleLockDuty,
        onOpenEntry: widget.onOpenEntry,
        onEditEntry: widget.onEditEntry,
        onDeleteEntry: widget.onDeleteEntry,
        onToggleLockEntry: widget.onToggleLockEntry,
      );
    }
    return const SizedBox.shrink();
  }

  List<LogbookListItemModel> _withYearHeaders(
    List<LogbookListItemModel> items,
  ) {
    final result = <LogbookListItemModel>[];
    int? currentYear;
    for (final item in items) {
      final year = item.sortDate.year;
      if (year != currentYear) {
        currentYear = year;
        result.add(LogbookYearHeaderItem(year, item.sortDate));
      }
      result.add(item);
    }
    return result;
  }
}

class _LogbookDutyGroupCard extends StatelessWidget {
  const _LogbookDutyGroupCard({
    required this.group,
    required this.isCompact,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleLock,
    required this.onOpenEntry,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.onToggleLockEntry,
  });

  final LogbookDutyGroupItem group;
  final bool isCompact;
  final ValueChanged<LogbookDutyGroupItem> onEdit;
  final ValueChanged<LogbookDutyGroupItem> onDelete;
  final ValueChanged<LogbookDutyGroupItem> onToggleLock;
  final ValueChanged<LogbookEntry> onOpenEntry;
  final ValueChanged<LogbookEntry> onEditEntry;
  final ValueChanged<LogbookEntry> onDeleteEntry;
  final ValueChanged<LogbookEntry> onToggleLockEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titleText = _formatDutyTitle(context, group.start, group.end);
    final dutyTimeText = _formatMinutes(group.dutyMinutes);
    final factoredText = _formatMinutes(group.factoredMinutes);
    final showFactored = group.factoredMinutes != group.dutyMinutes;
    final entries = List<LogbookEntry>.from(group.entries)
      ..sort(
        (a, b) =>
            b.timeLine.eventDateTime.compareTo(a.timeLine.eventDateTime),
      );

    final isCompact = MediaQuery.of(context).size.width < 600;
    final headerTitle = _DutyTitle(
      titleText: titleText,
      isCompact: isCompact,
    );
    final headerTile = ListTile(
      title: isCompact
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: headerTitle,
                  ),
                ),
                const SizedBox(width: 12),
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total: ${dutyTimeText}h',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      if (showFactored)
                        Text(
                          'Factored: ${factoredText}h',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: headerTitle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${dutyTimeText}h',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      if (showFactored)
                        Text(
                          'Factored: ${factoredText}h',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
    );
    final isLocked = group.isLocked;

    return Card(
      elevation: 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlidableActions(
              isCompact: isCompact,
              isLocked: isLocked,
              lockLabel: l10n.lockAction,
              editLabel: l10n.editAction,
              deleteLabel: l10n.deleteAction,
              onEdit: () => onEdit(group),
              onDelete: () => onDelete(group),
              onToggleLock: () => onToggleLock(group),
              inlineActions: SizedBox(
                width: 144,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.lockAction,
                      icon: Icon(
                        isLocked ? Icons.lock : Icons.lock_open,
                        color: isLocked
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => onToggleLock(group),
                    ),
                    if (!isLocked)
                      IconButton(
                        tooltip: l10n.editAction,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(group),
                      ),
                    if (!isLocked)
                      IconButton(
                        tooltip: l10n.deleteAction,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(group),
                      ),
                  ],
                ),
              ),
              child: headerTile,
            ),
            ...entries.map((entry) {
              return Column(
                children: [
                  Divider(
                    height: 1,
                    thickness: 1.2,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.6),
                  ),
                  LogbookListItem(
                    entry: entry,
                    isCompact: isCompact,
                    onOpen: onOpenEntry,
                    onEdit: onEditEntry,
                    onDelete: onDeleteEntry,
                    onToggleLock: onToggleLockEntry,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDutyTitle(
    BuildContext context,
    DateTime start,
    DateTime end,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat('HH:mm', locale);
    final startTime = timeFormat.format(start);
    final endTime = timeFormat.format(end);
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    final dayDelta = endDate.difference(startDate).inDays;
    final suffix = dayDelta > 0 ? ' (+$dayDelta)' : '';
    return 'Duty $startTime → $endTime$suffix';
  }

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0:00';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }
}

class _DutyTitle extends StatelessWidget {
  const _DutyTitle({
    required this.titleText,
    required this.isCompact,
  });

  final String titleText;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final parts = titleText.split(' ');
    if (parts.length < 2) {
      return Text(titleText);
    }
    final label = parts.first;
    final timeText = parts.sublist(1).join(' ');
    final baseStyle = Theme.of(context).textTheme.titleMedium;
    final timeStyle = Theme.of(context).textTheme.labelMedium;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$label ', style: baseStyle),
          TextSpan(text: timeText, style: timeStyle),
        ],
      ),
      maxLines: isCompact ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _YearHeader extends StatelessWidget {
  const _YearHeader({
    super.key,
    required this.year,
  });

  final int year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        '— $year —',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StickyYearHeader extends StatelessWidget {
  const _StickyYearHeader({
    required this.year,
  });

  final int year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        '— $year —',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
