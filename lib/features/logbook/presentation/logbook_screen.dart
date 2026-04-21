import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/core/presentation/widgets/display/buttons.dart';
import 'package:simplelog/core/presentation/widgets/display/event_type_toggle_button.dart';
import 'package:simplelog/core/presentation/widgets/inputs/date_selector_input_field.dart';
import 'package:simplelog/core/theme/app_tab_bar_styles.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/duty_edit_screen.dart';
import 'package:simplelog/features/logbook/presentation/flight_edit_screen.dart';
import 'package:simplelog/features/logbook/presentation/flight_prefill.dart';
import 'package:simplelog/features/logbook/presentation/positioning_edit_screen.dart';
import 'package:simplelog/features/logbook/presentation/simulator_edit_screen.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_list.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_preferences_provider.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_repository_provider.dart';
import 'package:simplelog/features/reports/presentation/reports_screen.dart';

/// Main logbook screen with list, analytics, and reports tabs.
class LogbookScreen extends ConsumerStatefulWidget {
  /// Creates the logbook screen.
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
  bool _filtersDialogOpen = false;
  bool _pendingReloadFromFiltersDialog = false;
  ReportsRuntimeQueryState? _pendingRuntimeReloadQuery;
  bool _pendingResetReload = false;
  int _reportsPanelVersion = 0;
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
    unawaited(_reloadFromReportsQuery(ref.read(reportsRuntimeQueryProvider)));
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
      final previousTabIndex = _selectedTabIndex;
      setState(() {
        _selectedTabIndex = _tabController.index;
        if (_selectedTabIndex != 0) _fabOpen = false;
      });
      ref.read(logbookTopTabIndexProvider.notifier).state = _selectedTabIndex;
      if (previousTabIndex != 0 && _selectedTabIndex == 0) {
        unawaited(_loadNextPage(reset: true));
      }
    }
  }

  void _onScroll() {
    if (_isLoading || !_hasMore || !_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      unawaited(_loadNextPage());
    }
  }

  Future<void> _reloadFromReportsQuery(ReportsRuntimeQueryState query) async {
    if (_isLoading) {
      _pendingRuntimeReloadQuery = query;
      _pendingResetReload = true;
      return;
    }
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
    if (_isLoading) {
      _pendingRuntimeReloadQuery = null;
      _pendingResetReload = true;
      return;
    }
    await _loadNextPage(reset: true);
  }

  Future<void> _loadNextPage({
    bool reset = false,
    ReportsRuntimeQueryState? runtimeQuery,
  }) async {
    if (!reset && !_hasMore) return;
    if (_isLoading || !mounted) return;
    final queryOrNull = runtimeQuery ?? ref.read(reportsRuntimeQueryProvider);
    if (queryOrNull == null) return;
    final query = queryOrNull;
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
        if (mounted) {
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
        }
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
      if (mounted) {
        setState(() {
          _entries
            ..clear()
            ..addAll(_allFilteredEntries.take(nextLoadedCount));
          _loadedCount = nextLoadedCount;
          _hasMore = _loadedCount < _allFilteredEntries.length;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (_pendingResetReload && mounted) {
        final pendingQuery = _pendingRuntimeReloadQuery;
        _pendingRuntimeReloadQuery = null;
        _pendingResetReload = false;
        unawaited(_loadNextPage(reset: true, runtimeQuery: pendingQuery));
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
    final runtimeQuery = ref.watch(reportsRuntimeQueryProvider);
    final eventTypes = ref.watch(reportsEventTypesProvider);
    ref
      ..listen<ReportsRuntimeQueryState>(reportsRuntimeQueryProvider, (
        prev,
        next,
      ) {
        if (prev == next) return;
        if (_filtersDialogOpen) {
          _pendingReloadFromFiltersDialog = true;
          return;
        }
        if (_selectedTabIndex != 0 && mounted) {
          setState(() => _reportsPanelVersion++);
        }
        unawaited(_reloadFromReportsQuery(next));
      })
      ..listen<ReportsEventTypesSelection>(reportsEventTypesProvider, (
        prev,
        next,
      ) {
        if (prev == next) return;
        if (_filtersDialogOpen) {
          _pendingReloadFromFiltersDialog = true;
          return;
        }
        if (_selectedTabIndex != 0 && mounted) {
          setState(() => _reportsPanelVersion++);
        }
        unawaited(_loadNextPage(reset: true));
      })
      ..listen<bool>(includePreviousExperienceProvider, (prev, next) {
        if (prev == next) return;
        if (_selectedTabIndex == 0 || !mounted) {
          return;
        }
        setState(() => _reportsPanelVersion++);
      })
      ..listen<LogbookFilters>(logbookFiltersProvider, (prev, next) {
        if (prev == next) return;
        if (_filtersDialogOpen) {
          _pendingReloadFromFiltersDialog = true;
          return;
        }
        unawaited(
          _reload(next),
        ); // keeps compatibility with existing providers/listeners
      });

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GlobalFilterBar(
              fromDateLabel: _dateOnlyLabel(runtimeQuery.from),
              toDateLabel: _dateOnlyLabel(runtimeQuery.to),
              selectedTypes: eventTypes,
              onSelectFromDate: () => _pickRuntimeDate(isFrom: true),
              onSelectToDate: () => _pickRuntimeDate(isFrom: false),
              onToggleFlights: () => _toggleEventType(
                flights: !eventTypes.flights,
              ),
              onToggleSimulator: () => _toggleEventType(
                simulator: !eventTypes.simulator,
              ),
              onToggleDuty: () => _toggleEventType(duty: !eventTypes.duty),
              onTogglePositioning: () => _toggleEventType(
                positioning: !eventTypes.positioning,
              ),
              filtersCount: runtimeQuery.filters.length,
              onMoreFilters: _openMoreFilters,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  8,
                  0,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: AppTabBarStyles.isScrollable,
                      tabAlignment: AppTabBarStyles.tabAlignment,
                      padding: EdgeInsets.zero,
                      labelPadding: AppTabBarStyles.labelPadding,
                      tabs: [
                        Tab(text: l10n.reportsTabFlights),
                        Tab(text: l10n.reportsTabTotals),
                        Tab(text: l10n.reportsTabAnalyses),
                        Tab(text: l10n.reportsTabReports),
                        Tab(
                          text: AppLocalizations.of(context)!.reportsTabBatch,
                        ),
                      ],
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          LogbookList(
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
                          ),
                          ReportsScreen(
                            key: ValueKey(
                              'logbook_reports_totals_$_reportsPanelVersion',
                            ),
                            section: ReportsPanelSection.totals,
                          ),
                          ReportsScreen(
                            key: ValueKey(
                              'logbook_reports_analyses_$_reportsPanelVersion',
                            ),
                            section: ReportsPanelSection.analizes,
                          ),
                          ReportsScreen(
                            key: ValueKey(
                              'logbook_reports_reports_$_reportsPanelVersion',
                            ),
                            section: ReportsPanelSection.reports,
                          ),
                          ReportsScreen(
                            key: ValueKey(
                              'logbook_reports_batch_$_reportsPanelVersion',
                            ),
                            section: ReportsPanelSection.batch,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  String _dateOnlyLabel(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value.toUtc());
  }

  Future<void> _pickRuntimeDate({required bool isFrom}) async {
    final current = ref.read(reportsRuntimeQueryProvider);
    final currentDate = isFrom ? current.from : current.to;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate.toUtc(),
      firstDate: DateTime.utc(1990),
      lastDate: DateTime.utc(2100),
    );
    if (picked == null) return;

    final pickedUtcStart = DateTime.utc(picked.year, picked.month, picked.day);
    final pickedUtcEnd = DateTime.utc(
      picked.year,
      picked.month,
      picked.day,
      23,
      59,
    );

    var nextFrom = current.from;
    var nextTo = current.to;
    if (isFrom) {
      nextFrom = pickedUtcStart;
      if (nextTo.isBefore(nextFrom)) {
        nextTo = pickedUtcEnd;
      }
    } else {
      nextTo = pickedUtcEnd;
      if (nextTo.isBefore(nextFrom)) {
        nextFrom = pickedUtcStart;
      }
    }

    ref
        .read(reportsRuntimeQueryProvider.notifier)
        .value = ReportsRuntimeQueryState(
      from: nextFrom,
      to: nextTo,
      selectedPreset: 'custom',
      matchMode: current.matchMode,
      filters: current.filters,
    );
  }

  Future<void> _toggleEventType({
    bool? flights,
    bool? simulator,
    bool? duty,
    bool? positioning,
  }) async {
    final current = ref.read(reportsEventTypesProvider);
    final next = current.copyWith(
      flights: flights,
      simulator: simulator,
      duty: duty,
      positioning: positioning,
    );
    await ref.read(reportsEventTypesProvider.notifier).setValue(next);
  }

  Future<void> _openMoreFilters() async {
    final l10n = AppLocalizations.of(context)!;
    _filtersDialogOpen = true;
    final shell = AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.reportsTabFilters,
      popupMaxWidth: 900,
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(context),
          child: Text(l10n.reportsDone),
        ),
      ],
      contentView: const ReportsScreen(section: ReportsPanelSection.filters),
    );
    if (isCompactDialogScreen(context)) {
      await AppNavigator.pushMaterial<void>(
        context,
        (_) => shell,
        rootNavigator: true,
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (_) => shell,
      );
    }
    _filtersDialogOpen = false;
    if (_pendingReloadFromFiltersDialog) {
      _pendingReloadFromFiltersDialog = false;
      if (_selectedTabIndex == 0) {
        await _loadNextPage(reset: true);
      } else if (mounted) {
        setState(() => _reportsPanelVersion++);
      }
    }
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
    if (mounted) {
      setState(() {
        if (updated == null) {
          _entries.removeWhere((e) => e.timeLine.id == timeLineId);
        } else {
          _upsertEntry(updated);
        }
      });
    }
  }

  Future<void> _refreshDutyById(int dutyId) async {
    final useCases = ref.read(logbookUseCasesProvider);
    final duty = await useCases.findDutyById(dutyId);
    if (!mounted) return;
    if (duty == null) {
      if (mounted) {
        setState(() {
          _entries.removeWhere(
            (e) => e.dutyStart?.id == dutyId || e.dutyEnd?.id == dutyId,
          );
        });
      }
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
    if (mounted) {
      setState(() {
        _entries.removeWhere((e) => e.timeLine.id == entry.timeLine.id);
      });
    }
  }

  Future<void> _toggleEntryLock(LogbookEntry entry) async {
    if (await _requiresEndorsementUnlockConfirmation(entry)) {
      final confirmed = await _confirmEndorsementUnlock();
      if (confirmed != true || !mounted) {
        return;
      }
    }
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

  Future<bool> _requiresEndorsementUnlockConfirmation(
    LogbookEntry entry,
  ) async {
    if (entry.type == LogbookEventType.flight) {
      final flight = entry.flight;
      if (flight == null || !flight.isLocked) return false;
      return (flight.endorsementData?.trim().isNotEmpty ?? false) ||
          (flight.signatureImage?.isNotEmpty ?? false);
    }
    if (entry.type == LogbookEventType.simulatorTraining) {
      final simulator = entry.simulatorTraining;
      if (simulator == null || !simulator.isLocked) return false;
      return (simulator.endorsementData?.trim().isNotEmpty ?? false) ||
          (simulator.signatureImage?.isNotEmpty ?? false);
    }
    return false;
  }

  Future<bool?> _confirmEndorsementUnlock() {
    final l10n = AppLocalizations.of(context)!;
    return _showConfirmDialog(
      title: Text(l10n.logbookUnlockEndorsedEntryTitle),
      content: Text(l10n.logbookUnlockEndorsementWarning),
      cancelLabel: Text(l10n.cancelAction),
      confirmLabel: Text(l10n.logbookUnlockAction),
    );
  }

  Future<void> _editDuty(LogbookDutyGroupItem group) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = DutyEditScreen(
      dutyId: group.dutyId,
      initialStart: group.start,
      initialEnd: group.end,
    );
    if (isCompact) {
      await AppNavigator.pushMaterial<void>(context, (_) => screen);
      await _refreshDutyById(group.dutyId);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => screen,
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
      await AppNavigator.pushMaterial<void>(context, (_) => screen);
      await _loadNextPage(reset: true);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => screen,
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
    return _showDeleteConfirmDialog(l10n.reportsDeleteEntryConfirm(label));
  }

  Future<bool?> _confirmDeleteDuty(LogbookDutyGroupItem group) {
    final l10n = AppLocalizations.of(context)!;
    return _showDeleteConfirmDialog(l10n.reportsDeleteDutyConfirm);
  }

  Future<bool?> _showConfirmDialog({
    required Widget title,
    required Widget content,
    required Widget cancelLabel,
    required Widget confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: title,
        content: content,
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(dialogContext, false),
            child: cancelLabel,
          ),
          FilledButton(
            onPressed: () => AppNavigator.pop(dialogContext, true),
            child: confirmLabel,
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    return _showConfirmDialog(
      title: Text(l10n.confirmDeleteTitle),
      content: Text(message),
      cancelLabel: Text(l10n.cancelAction),
      confirmLabel: Text(l10n.deleteAction),
    );
  }

  Future<void> _editPositioning(int positioningId, int timelineId) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = PositioningEditScreen(positioningId: positioningId);
    if (isCompact) {
      final changed = await AppNavigator.pushMaterial<bool>(
        context,
        (_) => screen,
      );
      if (changed == true) {
        await _refreshEntryByTimelineId(timelineId);
      }
      return;
    }
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => screen,
    );
    if (changed == true) {
      await _refreshEntryByTimelineId(timelineId);
    }
  }

  Future<void> _createPositioning() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const screen = PositioningEditScreen();
    if (isCompact) {
      final created = await AppNavigator.pushMaterial<bool>(
        context,
        (_) => screen,
      );
      if (created == true) {
        await _loadNextPage(reset: true);
      }
      return;
    }
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => screen,
    );
    if (created == true) {
      await _loadNextPage(reset: true);
    }
  }

  Future<void> _editFlight(int flightId, int timelineId) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = FlightEditScreen(flightId: flightId);
    if (isCompact) {
      final changed = await AppNavigator.pushMaterial<bool>(
        context,
        (_) => screen,
      );
      if (changed == true) {
        await _refreshEntryByTimelineId(timelineId);
      }
      return;
    }
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => screen,
    );
    if (changed == true) {
      await _refreshEntryByTimelineId(timelineId);
    }
  }

  Future<void> _createFlight() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const screen = FlightEditScreen();
    if (isCompact) {
      final created = await AppNavigator.pushMaterial<bool>(
        context,
        (_) => screen,
      );
      if (created == true) {
        await _loadNextPage(reset: true);
      }
      return;
    }
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => screen,
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
      await showAppMessageDialog(
        context,
        message: AppLocalizations.of(context)!.reportsNoPreviousFlightFound,
      );
      return;
    }
    await _createFlightWithPrefill(prefill);
  }

  Future<void> _createNextFlight() async {
    final prefill = await _buildFlightPrefill(isReturn: false);
    if (!mounted) return;
    if (prefill == null) {
      await showAppMessageDialog(
        context,
        message: AppLocalizations.of(context)!.reportsNoPreviousFlightFound,
      );
      return;
    }
    await _createFlightWithPrefill(prefill);
  }

  Future<void> _createFlightWithPrefill(FlightPrefill prefill) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = FlightEditScreen(prefill: prefill);
    if (isCompact) {
      final created = await AppNavigator.pushMaterial<bool>(
        context,
        (_) => screen,
      );
      if (created == true) {
        await _loadNextPage(reset: true);
      }
      return;
    }
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => screen,
    );
    if (created == true) {
      await _loadNextPage(reset: true);
    }
  }

  Future<void> _editSimulator(int simulatorId, int timelineId) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = SimulatorEditScreen(simulatorId: simulatorId);
    if (isCompact) {
      final changed = await AppNavigator.pushMaterial<bool>(
        context,
        (_) => screen,
      );
      if (changed == true) {
        await _refreshEntryByTimelineId(timelineId);
      }
      return;
    }
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => screen,
    );
    if (changed == true) {
      await _refreshEntryByTimelineId(timelineId);
    }
  }

  Future<void> _createSimulator() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const screen = SimulatorEditScreen();
    if (isCompact) {
      final created = await AppNavigator.pushMaterial<bool>(
        context,
        (_) => screen,
      );
      if (created == true) {
        await _loadNextPage(reset: true);
      }
      return;
    }
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => screen,
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
        dutyRanges.putIfAbsent(start.id, () => _DutyRange(dutyId: start.id))
          ..start = DbDateTime.dbToUtc(entry.timeLine.eventDateTime)
          ..startTimelineId = entry.timeLine.id
          ..duty = start;
      }
      final end = entry.dutyEnd;
      if (end != null) {
        dutyRanges.putIfAbsent(end.id, () => _DutyRange(dutyId: end.id))
          ..end = DbDateTime.dbToUtc(entry.timeLine.eventDateTime)
          ..endTimelineId = entry.timeLine.id
          ..duty = end;
      }
    }

    final validRanges = dutyRanges.values
        .where((range) => range.start != null && range.end != null)
        .toList();

    final groupedEntries = <int, List<LogbookEntry>>{};
    final assignedEntries = <int>{};

    for (final entry in entries) {
      if (!_isGroupable(entry.type)) continue;
      final entryTime = DbDateTime.dbToUtc(entry.timeLine.eventDateTime);
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

class _GlobalFilterBar extends StatelessWidget {
  const _GlobalFilterBar({
    required this.fromDateLabel,
    required this.toDateLabel,
    required this.onSelectFromDate,
    required this.onSelectToDate,
    required this.selectedTypes,
    required this.onToggleFlights,
    required this.onToggleSimulator,
    required this.onToggleDuty,
    required this.onTogglePositioning,
    required this.filtersCount,
    required this.onMoreFilters,
  });

  final String fromDateLabel;
  final String toDateLabel;
  final VoidCallback onSelectFromDate;
  final VoidCallback onSelectToDate;
  final ReportsEventTypesSelection selectedTypes;
  final VoidCallback onToggleFlights;
  final VoidCallback onToggleSimulator;
  final VoidCallback onToggleDuty;
  final VoidCallback onTogglePositioning;
  final int filtersCount;
  final VoidCallback onMoreFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final showTypeChips = constraints.maxWidth >= 1020;
        const dateFieldWidth = 116.0;
        return Material(
          color: colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8,
              top: 4,
              right: 8,
              bottom: 8,
            ),
            child: showTypeChips
                ? Row(
                    children: [
                      _buildDateSelector(
                        context: context,
                        width: dateFieldWidth,
                        label: 'From',
                        valueText: fromDateLabel,
                        onTap: onSelectFromDate,
                      ),
                      const SizedBox(width: 8),
                      _buildDateSelector(
                        context: context,
                        width: dateFieldWidth,
                        label: 'To',
                        valueText: toDateLabel,
                        onTap: onSelectToDate,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(children: _buildTypeToggleItems(l10n)),
                      ),
                      const SizedBox(width: 8),
                      Buttons(
                        onPressed: onMoreFilters,
                        icon: Icons.filter_list,
                        label: filtersCount > 0
                            ? '${l10n.reportsTabFilters} ($filtersCount)'
                            : l10n.reportsTabFilters,
                      ),
                      const SizedBox(width: 6),
                      InfoHelpButton(
                        title: l10n.logbookFiltersHelpTitle,
                        message: l10n.logbookFiltersHelpBody,
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDateSelector(
                          context: context,
                          width: dateFieldWidth,
                          label: 'From',
                          valueText: fromDateLabel,
                          onTap: onSelectFromDate,
                        ),
                        const SizedBox(width: 8),
                        _buildDateSelector(
                          context: context,
                          width: dateFieldWidth,
                          label: 'To',
                          valueText: toDateLabel,
                          onTap: onSelectToDate,
                        ),
                        const SizedBox(width: 8),
                        Buttons(
                          onPressed: onMoreFilters,
                          label: filtersCount > 0
                              ? '${l10n.reportsTabFilters} ($filtersCount)'
                              : l10n.reportsTabFilters,
                        ),
                        const SizedBox(width: 6),
                        InfoHelpButton(
                          title: l10n.logbookFiltersHelpTitle,
                          message: l10n.logbookFiltersHelpBody,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTypeToggle({
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: EventTypeToggleButton(
        key: key,
        label: label,
        selected: selected,
        onTap: onTap,
      ),
    );
  }

  List<Widget> _buildTypeToggleItems(AppLocalizations l10n) {
    final items = [
      (
        const ValueKey('main_filter_flight'),
        l10n.logbookEventFlight,
        selectedTypes.flights,
        onToggleFlights,
      ),
      (
        const ValueKey('main_filter_simulator'),
        l10n.fieldIsSimulator,
        selectedTypes.simulator,
        onToggleSimulator,
      ),
      (
        const ValueKey('main_filter_duty'),
        l10n.reportsMetricDuty,
        selectedTypes.duty,
        onToggleDuty,
      ),
      (
        const ValueKey('main_filter_positioning'),
        l10n.logbookEventPositioning,
        selectedTypes.positioning,
        onTogglePositioning,
      ),
    ];

    return [
      for (var i = 0; i < items.length; i++) ...[
        _buildTypeToggle(
          key: items[i].$1,
          label: items[i].$2,
          selected: items[i].$3,
          onTap: items[i].$4,
        ),
        if (i < items.length - 1) const SizedBox(width: 8),
      ],
    ];
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required double width,
    required String label,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: DateSelectorInputField(
        label: label,
        valueText: valueText,
        onTap: onTap,
        labelBackgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
      ),
    );
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
