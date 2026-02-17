import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/logbook_repository_provider.dart';

import 'duty_edit_screen.dart';
import 'widgets/logbook_entry_dialogs.dart';
import 'widgets/logbook_filters_dialog.dart';
import 'widgets/logbook_list.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  int? _currentYear;
  bool _fabOpen = false;
  final _scrollController = ScrollController();
  final List<LogbookEntry> _entries = [];
  bool _isLoading = false;
  bool _hasMore = true;
  LogbookFilters? _activeFilters;

  static const int _pageSize = 200;

  Future<void> _openFilters() async {
    final filters = ref.read(logbookFiltersProvider);
    final repo = ref.read(logbookRepositoryProvider);
    final updated = await LogbookFiltersDialog.show(
      context,
      initial: filters,
      loadFirstEventDate: repo.fetchFirstEventDate,
    );
    if (!mounted || updated == null) return;
    ref.read(logbookFiltersProvider.notifier).state = updated;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _activeFilters = ref.read(logbookFiltersProvider);
    _loadNextPage(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      _loadNextPage();
    }
  }

  Future<void> _reload(LogbookFilters filters) async {
    _activeFilters = filters;
    await _loadNextPage(reset: true);
  }

  Future<void> _loadNextPage({bool reset = false}) async {
    if (_isLoading) return;
    if (!mounted) return;
    if (!reset && !_hasMore) return;

    final filters = _activeFilters ?? LogbookFilters.initial();
    if (filters.types.isEmpty) {
      setState(() {
        _entries.clear();
        _hasMore = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(logbookRepositoryProvider);
      final offset = reset ? 0 : _entries.length;
      final page = await repo.fetchLogbookPage(
        filters,
        limit: _pageSize,
        offset: offset,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _entries
            ..clear()
            ..addAll(page);
        } else {
          _entries.addAll(page);
        }
        _hasMore = page.length == _pageSize;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleFabMenu() {
    setState(() => _fabOpen = !_fabOpen);
  }

  Future<void> _handleAction(_LogbookCreateAction action) async {
    setState(() => _fabOpen = false);
    switch (action) {
      case _LogbookCreateAction.newDuty:
        await _createDuty();
        return;
      case _LogbookCreateAction.newFlight:
      case _LogbookCreateAction.returnFlight:
      case _LogbookCreateAction.nextFlight:
      case _LogbookCreateAction.newSimulator:
      case _LogbookCreateAction.newPositioning:
        _showComingSoon();
        return;
    }
  }

  void _showComingSoon() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen<LogbookFilters>(logbookFiltersProvider, (prev, next) {
      if (prev == next) return;
      _reload(next);
    });

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.screenLogbook,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.logbookFilterAction,
                    icon: const Icon(Icons.filter_list),
                    onPressed: _openFilters,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading && _entries.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : LogbookList(
                        controller: _scrollController,
                        items: _buildDisplayItems(_entries),
                        onEditEntry: _editEntry,
                        onDeleteEntry: _deleteEntry,
                        onToggleLockEntry: _toggleEntryLock,
                        onEditDuty: _editDuty,
                        onDeleteDuty: _deleteDuty,
                        onToggleLockDuty: _toggleDutyLock,
                        onYearChange: (year) {
                          if (!mounted || _currentYear == year) return;
                          setState(() => _currentYear = year);
                        },
                      ),
              ),
              if (_isLoading && _entries.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        if (_fabOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _fabOpen = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: SafeArea(
            top: false,
            child: _FabMenu(
              isOpen: _fabOpen,
              onToggle: _toggleFabMenu,
              onAction: _handleAction,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editEntry(LogbookEntry entry) async {
    final db = ref.read(databaseProvider);
    await LogbookEntryDialogs.show(
      context,
      entry: entry,
      db: db,
    );
    await _refreshEntryByTimelineId(entry.timeLine.id);
  }

  Future<void> _refreshEntryByTimelineId(int timeLineId) async {
    final repo = ref.read(logbookRepositoryProvider);
    final updated = await repo.fetchEntryByTimelineId(timeLineId);
    if (!mounted) return;
    setState(() {
      if (updated == null) {
        _entries.removeWhere((e) => e.timeLine.id == timeLineId);
      } else {
        _upsertEntry(updated);
      }
    });
  }

  Future<void> _refreshDutyById(int dutyId) async {
    final db = ref.read(databaseProvider);
    final duty = await (db.select(db.dutyPeriods)
          ..where((tbl) => tbl.id.equals(dutyId)))
        .getSingleOrNull();
    if (!mounted) return;
    if (duty == null) {
      setState(() {
        _entries.removeWhere(
          (e) => e.dutyStart?.id == dutyId || e.dutyEnd?.id == dutyId,
        );
      });
      return;
    }
    await _refreshEntryByTimelineId(duty.dutyStartTimeLineId);
    await _refreshEntryByTimelineId(duty.dutyEndTimeLineId);
  }

  void _upsertEntry(LogbookEntry entry) {
    final index =
        _entries.indexWhere((e) => e.timeLine.id == entry.timeLine.id);
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
    _entries.sort((a, b) {
      final cmp =
          b.timeLine.eventDateTime.compareTo(a.timeLine.eventDateTime);
      if (cmp != 0) return cmp;
      return b.timeLine.id.compareTo(a.timeLine.id);
    });
  }

  void _deleteEntry(LogbookEntry entry) {}

  Future<void> _toggleEntryLock(LogbookEntry entry) async {
    final db = ref.read(databaseProvider);
    switch (entry.type) {
      case LogbookEventType.flight:
        final item = entry.flight;
        if (item == null) return;
        await db.update(db.flights).replace(
              item.copyWith(isLocked: !item.isLocked),
            );
        await _refreshEntryByTimelineId(entry.timeLine.id);
        return;
      case LogbookEventType.simulatorTraining:
        final item = entry.simulatorTraining;
        if (item == null) return;
        await db.update(db.simulatorTrainings).replace(
              item.copyWith(isLocked: !item.isLocked),
            );
        await _refreshEntryByTimelineId(entry.timeLine.id);
        return;
      case LogbookEventType.positioning:
        final item = entry.positioning;
        if (item == null) return;
        await db.update(db.positionings).replace(
              item.copyWith(isLocked: !item.isLocked),
            );
        await _refreshEntryByTimelineId(entry.timeLine.id);
        return;
      case LogbookEventType.dutyPeriod:
        final item = entry.dutyStart ?? entry.dutyEnd;
        if (item == null) return;
        await db.update(db.dutyPeriods).replace(
              item.copyWith(isLocked: !item.isLocked),
            );
        await _refreshDutyById(item.id);
        return;
      case LogbookEventType.unknown:
        return;
    }
  }

  Future<void> _editDuty(LogbookDutyGroupItem group) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = DutyEditScreen(
      dutyId: group.dutyId,
      initialStart: group.start,
      initialEnd: group.end,
    );
    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
      await _refreshDutyById(group.dutyId);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 520,
          height: 560,
          child: screen,
        ),
      ),
    );
    await _refreshDutyById(group.dutyId);
  }

  void _deleteDuty(LogbookDutyGroupItem group) {}

  Future<void> _toggleDutyLock(LogbookDutyGroupItem group) async {
    final db = ref.read(databaseProvider);
    final duty = await (db.select(db.dutyPeriods)
          ..where((tbl) => tbl.id.equals(group.dutyId)))
        .getSingleOrNull();
    if (duty == null) return;
    await db.update(db.dutyPeriods).replace(
          duty.copyWith(isLocked: !duty.isLocked),
        );
    await _refreshDutyById(group.dutyId);
  }

  Future<void> _createDuty() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const screen = DutyEditScreen();
    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
      await _loadNextPage(reset: true);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => const Dialog(
        child: SizedBox(
          width: 520,
          height: 560,
          child: screen,
        ),
      ),
    );
    await _loadNextPage(reset: true);
  }

  List<LogbookListItemModel> _buildDisplayItems(
    List<LogbookEntry> entries,
  ) {
    final dutyRanges = <int, _DutyRange>{};

    for (final entry in entries) {
      final start = entry.dutyStart;
      if (start != null) {
        final range = dutyRanges.putIfAbsent(
          start.id,
          () => _DutyRange(dutyId: start.id),
        );
        range.start = entry.timeLine.eventDateTime;
        range.startTimelineId = entry.timeLine.id;
        range.duty = start;
      }
      final end = entry.dutyEnd;
      if (end != null) {
        final range = dutyRanges.putIfAbsent(
          end.id,
          () => _DutyRange(dutyId: end.id),
        );
        range.end = entry.timeLine.eventDateTime;
        range.endTimelineId = entry.timeLine.id;
        range.duty = end;
      }
    }

    final validRanges = dutyRanges.values
        .where((range) => range.start != null && range.end != null)
        .toList();

    final groupedEntries = <int, List<LogbookEntry>>{};
    final assignedEntries = <int>{};

    for (final entry in entries) {
      if (!_isGroupable(entry.type)) continue;
      final entryTime = entry.timeLine.eventDateTime;
      _DutyRange? matchedRange;
      for (final range in validRanges) {
        if (entryTime.isBefore(range.start!)) continue;
        if (entryTime.isAfter(range.end!)) continue;
        matchedRange = range;
        break;
      }
      if (matchedRange == null) continue;
      groupedEntries.putIfAbsent(matchedRange.dutyId, () => []).add(entry);
      assignedEntries.add(entry.timeLine.id);
    }

    final items = <LogbookListItemModel>[];

    for (final range in validRanges) {
      final groupItems = groupedEntries[range.dutyId] ?? const <LogbookEntry>[];
      if (range.startTimelineId != null) {
        assignedEntries.add(range.startTimelineId!);
      }
      if (range.endTimelineId != null) {
        assignedEntries.add(range.endTimelineId!);
      }
      items.add(
        LogbookDutyGroupItem(
          dutyId: range.dutyId,
          start: range.start!,
          end: range.end!,
          entries: List<LogbookEntry>.from(groupItems),
          isLocked: range.duty?.isLocked ?? false,
          dutyMinutes: range.duty?.timeDutyMinutes ??
              range.end!.difference(range.start!).inMinutes,
          factoredMinutes: range.duty?.timeFactoredDutyMinutes ??
              range.end!.difference(range.start!).inMinutes,
        ),
      );
    }

    for (final entry in entries) {
      if (assignedEntries.contains(entry.timeLine.id)) {
        continue;
      }
      if (entry.dutyEnd != null) {
        final range = dutyRanges[entry.dutyEnd!.id];
        if (range != null &&
            range.start != null &&
            range.end != null &&
            (groupedEntries[range.dutyId]?.isNotEmpty ?? false)) {
          continue;
        }
      }
      if (entry.dutyStart != null) {
        final range = dutyRanges[entry.dutyStart!.id];
        if (range != null &&
            range.start != null &&
            range.end != null &&
            (groupedEntries[range.dutyId]?.isNotEmpty ?? false)) {
          continue;
        }
      }
      items.add(LogbookEntryItem(entry));
    }

    items.sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return items;
  }

  bool _isGroupable(LogbookEventType type) {
    return type == LogbookEventType.flight ||
        type == LogbookEventType.positioning ||
        type == LogbookEventType.simulatorTraining;
  }
}

enum _LogbookCreateAction {
  newFlight,
  returnFlight,
  nextFlight,
  newSimulator,
  newPositioning,
  newDuty,
}

class _DutyRange {
  _DutyRange({required this.dutyId});

  final int dutyId;
  DateTime? start;
  DateTime? end;
  int? startTimelineId;
  int? endTimelineId;
  DutyPeriod? duty;
}

class _FabMenu extends StatelessWidget {
  const _FabMenu({
    required this.isOpen,
    required this.onToggle,
    required this.onAction,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<_LogbookCreateAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _FabMenuItem(
        icon: Icons.flight_takeoff,
        label: l10n.logbookEventFlight,
        action: _LogbookCreateAction.newFlight,
      ),
      _FabMenuItem(
        icon: Icons.reply,
        label: 'Return Flight',
        action: _LogbookCreateAction.returnFlight,
      ),
      _FabMenuItem(
        icon: Icons.airline_stops_sharp,
        label: 'Next Flight',
        action: _LogbookCreateAction.nextFlight,
      ),
      _FabMenuItem(
        icon: Icons.monitor,
        label: l10n.logbookEventSimulator,
        action: _LogbookCreateAction.newSimulator,
      ),
      _FabMenuItem(
        icon: Icons.airplane_ticket_outlined,
        label: l10n.logbookEventPositioning,
        action: _LogbookCreateAction.newPositioning,
      ),
      _FabMenuItem(
        icon: Icons.schedule,
        label: l10n.logbookEventDuty,
        action: _LogbookCreateAction.newDuty,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FabMenuButton(
                        item: item,
                        onTap: () => onAction(item.action),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        FloatingActionButton(
          onPressed: onToggle,
          tooltip: l10n.addAction,
          child: Icon(isOpen ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}

class _FabMenuItem {
  const _FabMenuItem({
    required this.icon,
    required this.label,
    required this.action,
  });

  final IconData icon;
  final String label;
  final _LogbookCreateAction action;
}

class _FabMenuButton extends StatelessWidget {
  const _FabMenuButton({
    required this.item,
    required this.onTap,
  });

  final _FabMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            item.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 10),
        FloatingActionButton.small(
          onPressed: onTap,
          child: Icon(item.icon),
        ),
      ],
    );
  }
}
