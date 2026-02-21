import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/theme/app_tab_bar_styles.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';

import 'duty_edit_screen.dart';
import 'flight_edit_screen.dart';
import 'positioning_edit_screen.dart';
import 'simulator_edit_screen.dart';
import 'widgets/logbook_entry_dialogs.dart';
import 'widgets/logbook_list.dart';
import 'package:simplelog/presentation/reports/reports_screen.dart';
import 'package:simplelog/presentation/reports/providers/reports_preferences_provider.dart';
import 'package:simplelog/presentation/reports/providers/reports_repository_provider.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen>
    with SingleTickerProviderStateMixin {
  int? _currentYear;
  bool _fabOpen = false;
  int _selectedTabIndex = 0;
  final _scrollController = ScrollController();
  final List<LogbookEntry> _entries = [];
  List<LogbookEntry> _allFilteredEntries = const [];
  int _directOffset = 0;
  int _loadedCount = 0;
  bool _isLoading = false;
  bool _hasMore = false;
  static const int _pageSize = 200;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final persistedTab = ref.read(logbookTopTabIndexProvider).clamp(0, 4);
    _selectedTabIndex = persistedTab;
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: persistedTab,
    )..addListener(_handleTabChanged);
    _scrollController.addListener(_onScroll);
    _reloadFromReportsQuery(ref.read(reportsRuntimeQueryProvider));
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (!_tabController.indexIsChanging &&
        _selectedTabIndex != _tabController.index) {
      setState(() {
        _selectedTabIndex = _tabController.index;
        if (_selectedTabIndex != 0) _fabOpen = false;
      });
      ref.read(logbookTopTabIndexProvider.notifier).state = _selectedTabIndex;
    }
  }

  void _onScroll() {
    if (_isLoading || !_hasMore || !_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      _loadNextPage();
    }
  }

  Future<void> _reloadFromReportsQuery(ReportsRuntimeQueryState query) async {
    await _loadNextPage(reset: true, runtimeQuery: query);
  }

  Future<List<LogbookEntry>> _fetchEntriesForReportsRange({
    required List<ReportsFlightRow> flights,
    required ReportsEventTypesSelection eventTypes,
    required DateTime from,
    required DateTime to,
  }) async {
    final logbookUseCases = ref.read(logbookUseCasesProvider);
    final selectedTypes = <LogbookEventType>{
      if (eventTypes.flights) LogbookEventType.flight,
      if (eventTypes.simulator) LogbookEventType.simulatorTraining,
      if (eventTypes.duty) LogbookEventType.dutyPeriod,
      if (eventTypes.positioning) LogbookEventType.positioning,
    };
    if (selectedTypes.isEmpty) {
      return const [];
    }
    final logbookEntries = await logbookUseCases.fetchLogbookPage(
      LogbookFilters(from: from, to: to, types: selectedTypes),
      limit: 10000,
      offset: 0,
    );
    final flightIds = flights.map((flight) => flight.flightId).toSet();
    return logbookEntries
        .where((entry) {
          if (entry.flight != null) {
            return eventTypes.flights && flightIds.contains(entry.flight!.id);
          }
          if (entry.simulatorTraining != null) {
            return eventTypes.simulator;
          }
          if (entry.positioning != null) {
            return eventTypes.positioning;
          }
          if (entry.dutyStart != null || entry.dutyEnd != null) {
            return eventTypes.duty;
          }
          return false;
        })
        .toList(growable: false);
  }

  Future<void> _reload(LogbookFilters _) async {
    await _loadNextPage(reset: true);
  }

  Future<void> _loadNextPage({
    bool reset = false,
    ReportsRuntimeQueryState? runtimeQuery,
  }) async {
    if (!reset && !_hasMore) return;
    if (_isLoading || !mounted) return;
    final ReportsRuntimeQueryState query =
        runtimeQuery ?? ref.read(reportsRuntimeQueryProvider);
    final includePreviousExperience = ref.read(
      includePreviousExperienceProvider,
    );
    final eventTypes = ref.read(reportsEventTypesProvider);

    if (reset) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_scrollController.hasClients) return;
          _scrollController.jumpTo(0);
        });
      }
      if (mounted && _currentYear != null) {
        setState(() => _currentYear = null);
      }
    }
    setState(() => _isLoading = true);
    try {
      final selectedTypes = <LogbookEventType>{
        if (eventTypes.flights) LogbookEventType.flight,
        if (eventTypes.simulator) LogbookEventType.simulatorTraining,
        if (eventTypes.duty) LogbookEventType.dutyPeriod,
        if (eventTypes.positioning) LogbookEventType.positioning,
      };
      if (selectedTypes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _entries.clear();
          _allFilteredEntries = const [];
          _loadedCount = 0;
          _directOffset = 0;
          _hasMore = false;
        });
        return;
      }

      // Fast path: no advanced conditions -> direct paged query.
      if (query.filters.isEmpty) {
        final useCases = ref.read(logbookUseCasesProvider);
        if (reset) {
          _directOffset = 0;
        }
        final page = await useCases.fetchLogbookPage(
          LogbookFilters(from: query.from, to: query.to, types: selectedTypes),
          limit: _pageSize,
          offset: _directOffset,
        );
        if (!mounted) return;
        setState(() {
          if (reset) {
            _entries
              ..clear()
              ..addAll(page);
            _allFilteredEntries = const [];
            _loadedCount = 0;
          } else {
            _entries.addAll(page);
          }
          _directOffset += page.length;
          _hasMore = page.length == _pageSize;
        });
        return;
      }

      if (reset || _allFilteredEntries.isEmpty) {
        final repo = ref.read(reportsRepositoryProvider);
        final result = await repo.load(
          ReportsQuery(
            from: query.from,
            to: query.to,
            includePreviousExperience: includePreviousExperience,
            filterMatchMode: query.matchMode,
            filters: query.filters,
          ),
        );
        final flights = eventTypes.flights
            ? result.flights
            : const <ReportsFlightRow>[];
        _allFilteredEntries = await _fetchEntriesForReportsRange(
          flights: flights,
          eventTypes: eventTypes,
          from: query.from,
          to: query.to,
        );
        _loadedCount = 0;
        _directOffset = 0;
      }

      if (!mounted) return;
      final nextLoadedCount = (_loadedCount + _pageSize).clamp(
        0,
        _allFilteredEntries.length,
      );
      setState(() {
        _entries
          ..clear()
          ..addAll(_allFilteredEntries.take(nextLoadedCount));
        _loadedCount = nextLoadedCount;
        _hasMore = _loadedCount < _allFilteredEntries.length;
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
        await _createFlight();
        return;
      case _LogbookCreateAction.returnFlight:
        await _createReturnFlight();
        return;
      case _LogbookCreateAction.nextFlight:
        await _createNextFlight();
        return;
      case _LogbookCreateAction.newSimulator:
        await _createSimulator();
        return;
      case _LogbookCreateAction.newPositioning:
        await _createPositioning();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen<ReportsRuntimeQueryState>(reportsRuntimeQueryProvider, (
      prev,
      next,
    ) {
      if (prev == next) return;
      _reloadFromReportsQuery(next);
    });
    ref.listen<ReportsEventTypesSelection>(reportsEventTypesProvider, (
      prev,
      next,
    ) {
      if (prev == next) return;
      _loadNextPage(reset: true);
    });
    ref.listen<LogbookFilters>(logbookFiltersProvider, (prev, next) {
      if (prev == next) return;
      _reload(next); // keeps compatibility with existing providers/listeners
    });

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: AppTabBarStyles.isScrollable,
                tabAlignment: AppTabBarStyles.tabAlignment,
                labelPadding: AppTabBarStyles.labelPadding,
                tabs: [
                  Tab(text: l10n.reportsTabFlights),
                  Tab(text: l10n.reportsTabTotals),
                  Tab(text: l10n.reportsTabAnalyses),
                  Tab(text: l10n.reportsTabReports),
                  Tab(text: l10n.reportsTabFilters),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildSelectedTab()),
              if (_isLoading && _entries.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        if (_selectedTabIndex == 0 && _fabOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _fabOpen = false),
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
            ),
          ),
        if (_selectedTabIndex == 0)
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

  Widget _buildSelectedTab() {
    if (_selectedTabIndex == 0) {
      return _isLoading && _entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : LogbookList(
              controller: _scrollController,
              items: _buildDisplayItems(_entries),
              onOpenEntry: _openEntry,
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
            );
    }

    final section = switch (_selectedTabIndex) {
      1 => ReportsPanelSection.totals,
      2 => ReportsPanelSection.analizes,
      3 => ReportsPanelSection.reports,
      4 => ReportsPanelSection.filters,
      _ => ReportsPanelSection.overview,
    };

    return ReportsScreen(
      key: const ValueKey('logbook_reports_panel'),
      section: section,
    );
  }

  Future<void> _editEntry(LogbookEntry entry) async {
    if (entry.type == LogbookEventType.flight) {
      final flight = entry.flight;
      if (flight == null) return;
      await _editFlight(flight.id, entry.timeLine.id);
      return;
    }
    if (entry.type == LogbookEventType.positioning) {
      final positioning = entry.positioning;
      if (positioning == null) return;
      await _editPositioning(positioning.id, entry.timeLine.id);
      return;
    }
    if (entry.type == LogbookEventType.simulatorTraining) {
      final simulator = entry.simulatorTraining;
      if (simulator == null) return;
      await _editSimulator(simulator.id, entry.timeLine.id);
      return;
    }
    final useCases = ref.read(logbookUseCasesProvider);
    await LogbookEntryDialogs.show(context, entry: entry, useCases: useCases);
    await _refreshEntryByTimelineId(entry.timeLine.id);
  }

  Future<void> _openEntry(LogbookEntry entry) async {
    final useCases = ref.read(logbookUseCasesProvider);
    await LogbookEntryDialogs.show(context, entry: entry, useCases: useCases);
  }

  Future<void> _refreshEntryByTimelineId(int timeLineId) async {
    final useCases = ref.read(logbookUseCasesProvider);
    final updated = await useCases.fetchEntryByTimelineId(timeLineId);
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
    final useCases = ref.read(logbookUseCasesProvider);
    final duty = await useCases.findDutyById(dutyId);
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
    final index = _entries.indexWhere(
      (e) => e.timeLine.id == entry.timeLine.id,
    );
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
    _entries.sort((a, b) {
      final cmp = b.timeLine.eventDateTime.compareTo(a.timeLine.eventDateTime);
      if (cmp != 0) return cmp;
      return b.timeLine.id.compareTo(a.timeLine.id);
    });
  }

  Future<void> _deleteEntry(LogbookEntry entry) async {
    final confirmed = await _confirmDeleteEntry(entry);
    if (confirmed != true || !mounted) return;
    final useCases = ref.read(logbookUseCasesProvider);
    await useCases.deleteEntry(entry);
    if (!mounted) return;
    if (entry.type == LogbookEventType.dutyPeriod) {
      await _loadNextPage(reset: true);
      return;
    }
    setState(() {
      _entries.removeWhere((e) => e.timeLine.id == entry.timeLine.id);
    });
  }

  Future<void> _toggleEntryLock(LogbookEntry entry) async {
    final useCases = ref.read(logbookUseCasesProvider);
    await useCases.toggleEntryLock(entry);
    if (entry.type == LogbookEventType.dutyPeriod) {
      final item = entry.dutyStart ?? entry.dutyEnd;
      if (item == null) return;
      await _refreshDutyById(item.id);
      return;
    }
    await _refreshEntryByTimelineId(entry.timeLine.id);
  }

  Future<void> _editDuty(LogbookDutyGroupItem group) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = DutyEditScreen(
      dutyId: group.dutyId,
      initialStart: group.start,
      initialEnd: group.end,
    );
    if (isCompact) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => screen));
      await _refreshDutyById(group.dutyId);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) =>
          Dialog(child: SizedBox(width: 520, height: 560, child: screen)),
    );
    await _refreshDutyById(group.dutyId);
  }

  Future<void> _deleteDuty(LogbookDutyGroupItem group) async {
    final confirmed = await _confirmDeleteDuty(group);
    if (confirmed != true || !mounted) return;
    final useCases = ref.read(logbookUseCasesProvider);
    await useCases.deleteDutyById(group.dutyId);
    if (!mounted) return;
    await _loadNextPage(reset: true);
  }

  Future<void> _toggleDutyLock(LogbookDutyGroupItem group) async {
    final useCases = ref.read(logbookUseCasesProvider);
    await useCases.toggleDutyLock(group.dutyId);
    await _refreshDutyById(group.dutyId);
  }

  Future<void> _createDuty() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const screen = DutyEditScreen();
    if (isCompact) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => screen));
      await _loadNextPage(reset: true);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) =>
          const Dialog(child: SizedBox(width: 520, height: 560, child: screen)),
    );
    await _loadNextPage(reset: true);
  }

  Future<bool?> _confirmDeleteEntry(LogbookEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (entry.type) {
      LogbookEventType.flight => l10n.logbookEventFlight,
      LogbookEventType.positioning => l10n.logbookEventPositioning,
      LogbookEventType.simulatorTraining => l10n.logbookEventSimulator,
      LogbookEventType.dutyPeriod => l10n.logbookEventDuty,
      LogbookEventType.unknown => l10n.reportsEntryGeneric,
    };
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.reportsDeleteEntryConfirm(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDeleteDuty(LogbookDutyGroupItem group) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.reportsDeleteDutyConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
  }

  Future<void> _editPositioning(int positioningId, int timelineId) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = PositioningEditScreen(positioningId: positioningId);
    if (isCompact) {
      final changed = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => screen));
      if (changed == true) {
        await _refreshEntryByTimelineId(timelineId);
      }
      return;
    }
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          Dialog(child: SizedBox(width: 560, height: 700, child: screen)),
    );
    if (changed == true) {
      await _refreshEntryByTimelineId(timelineId);
    }
  }

  Future<void> _createPositioning() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const screen = PositioningEditScreen();
    if (isCompact) {
      final created = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => screen));
      if (created == true) {
        await _loadNextPage(reset: true);
      }
      return;
    }
    final created = await showDialog<bool>(
      context: context,
      builder: (context) =>
          const Dialog(child: SizedBox(width: 560, height: 700, child: screen)),
    );
    if (created == true) {
      await _loadNextPage(reset: true);
    }
  }

  Future<void> _editFlight(int flightId, int timelineId) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = FlightEditScreen(flightId: flightId);
    if (isCompact) {
      final changed = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => screen));
      if (changed == true) {
        await _refreshEntryByTimelineId(timelineId);
      }
      return;
    }
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          Dialog(child: SizedBox(width: 640, height: 780, child: screen)),
    );
    if (changed == true) {
      await _refreshEntryByTimelineId(timelineId);
    }
  }

  Future<void> _createFlight() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const screen = FlightEditScreen();
    if (isCompact) {
      final created = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => screen));
      if (created == true) {
        await _loadNextPage(reset: true);
      }
      return;
    }
    final created = await showDialog<bool>(
      context: context,
      builder: (context) =>
          const Dialog(child: SizedBox(width: 640, height: 780, child: screen)),
    );
    if (created == true) {
      await _loadNextPage(reset: true);
    }
  }

  LogbookEntry? _latestFlightEntry() {
    for (final entry in _entries) {
      if (entry.type == LogbookEventType.flight && entry.flight != null) {
        return entry;
      }
    }
    return null;
  }

  Future<FlightPrefill?> _buildFlightPrefill({required bool isReturn}) async {
    final latest = _latestFlightEntry();
    if (latest == null || latest.flight == null) return null;
    final flight = latest.flight!;
    final useCases = ref.read(logbookUseCasesProvider);
    final crew = await useCases.fetchFlightCrewAssignments(flight.id);
    final mappedCrew = crew
        .map(
          (c) => SimulatorCrewAssignmentInput(
            crewId: c.crewId,
            position: c.position,
          ),
        )
        .toList(growable: false);

    final previousChocksOff = latest.timeLine.eventDateTime;
    final nextChocksOff = flight.arrivalDateTime ?? previousChocksOff;
    final dep = flight.arrivalAirportId;
    final arr = isReturn ? flight.departureAirportId : null;

    return FlightPrefill(
      aircraftId: flight.aircraftId,
      fromAirportId: dep,
      toAirportId: arr,
      chocksOff: nextChocksOff,
      crewAssignments: mappedCrew,
    );
  }

  Future<void> _createReturnFlight() async {
    final prefill = await _buildFlightPrefill(isReturn: true);
    if (!mounted) return;
    if (prefill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.reportsNoPreviousFlightFound,
          ),
        ),
      );
      return;
    }
    await _createFlightWithPrefill(prefill);
  }

  Future<void> _createNextFlight() async {
    final prefill = await _buildFlightPrefill(isReturn: false);
    if (!mounted) return;
    if (prefill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.reportsNoPreviousFlightFound,
          ),
        ),
      );
      return;
    }
    await _createFlightWithPrefill(prefill);
  }

  Future<void> _createFlightWithPrefill(FlightPrefill prefill) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = FlightEditScreen(prefill: prefill);
    if (isCompact) {
      final created = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => screen));
      if (created == true) {
        await _loadNextPage(reset: true);
      }
      return;
    }
    final created = await showDialog<bool>(
      context: context,
      builder: (context) =>
          Dialog(child: SizedBox(width: 640, height: 780, child: screen)),
    );
    if (created == true) {
      await _loadNextPage(reset: true);
    }
  }

  Future<void> _editSimulator(int simulatorId, int timelineId) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = SimulatorEditScreen(simulatorId: simulatorId);
    if (isCompact) {
      final changed = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => screen));
      if (changed == true) {
        await _refreshEntryByTimelineId(timelineId);
      }
      return;
    }
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          Dialog(child: SizedBox(width: 560, height: 720, child: screen)),
    );
    if (changed == true) {
      await _refreshEntryByTimelineId(timelineId);
    }
  }

  Future<void> _createSimulator() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const screen = SimulatorEditScreen();
    if (isCompact) {
      final created = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => screen));
      if (created == true) {
        await _loadNextPage(reset: true);
      }
      return;
    }
    final created = await showDialog<bool>(
      context: context,
      builder: (context) =>
          const Dialog(child: SizedBox(width: 560, height: 720, child: screen)),
    );
    if (created == true) {
      await _loadNextPage(reset: true);
    }
  }

  List<LogbookListItemModel> _buildDisplayItems(List<LogbookEntry> entries) {
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
          dutyMinutes:
              range.duty?.timeDutyMinutes ??
              range.end!.difference(range.start!).inMinutes,
          factoredMinutes:
              range.duty?.timeFactoredDutyMinutes ??
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
        label: l10n.logbookFabReturnFlight,
        action: _LogbookCreateAction.returnFlight,
      ),
      _FabMenuItem(
        icon: Icons.airline_stops_sharp,
        label: l10n.logbookFabNextFlight,
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
  const _FabMenuButton({required this.item, required this.onTap});

  final _FabMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
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
            ),
          ),
        ),
        const SizedBox(width: 10),
        FloatingActionButton.small(onPressed: onTap, child: Icon(item.icon)),
      ],
    );
  }
}
