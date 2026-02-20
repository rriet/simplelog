import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/presentation/reports/providers/reports_preferences_provider.dart';
import 'package:simplelog/presentation/reports/providers/reports_repository_provider.dart';
import 'package:simplelog/presentation/shared/widgets/time_input_field.dart';
import 'package:simplelog/state/providers/custom_time_labels_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  DateTime _from = DateTime.utc(1990, 1, 1);
  DateTime _to = DateTime.now().toUtc();
  _ReportDateRangePreset _preset = _ReportDateRangePreset.sinceBeginning;
  ReportsFilterMatchMode _filterMatchMode = ReportsFilterMatchMode.all;
  final List<ReportsFilterCondition> _filters = [];
  _AnalysisGroupBy _analysisGroupBy = _AnalysisGroupBy.aircraft;
  late final TabController _tabController;

  bool _loading = false;
  bool _detailsLoaded = false;
  String? _error;

  ReportsData _data = const ReportsData(
    totals: ReportsTotals.zero(),
    flights: [],
  );
  List<LogbookEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOverviewData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOverviewData() async {
    if (_from.isAfter(_to)) {
      setState(() => _error = 'Start date must be before end date.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final includePreviousExperience = ref.read(includePreviousExperienceProvider);
    final eventTypes = ref.read(reportsEventTypesProvider);

    try {
      final repo = ref.read(reportsRepositoryProvider);
      if (_filters.isEmpty) {
        final totals = await repo.loadQuickTotals(
          from: _from,
          to: _to,
          includePreviousExperience: includePreviousExperience,
        );
        if (!mounted) return;
        setState(() {
          _data = ReportsData(
            totals: _applyTypeSelectionToTotals(totals, eventTypes),
            flights: const [],
          );
          _entries = const [];
          _detailsLoaded = false;
        });
      } else {
        final result = await repo.load(
          ReportsQuery(
            from: _from,
            to: _to,
            includePreviousExperience: includePreviousExperience,
            filterMatchMode: _filterMatchMode,
            filters: _filters,
          ),
        );
        final flights = eventTypes.flights ? result.flights : const <ReportsFlightRow>[];
        final entries = await _fetchEntriesForFlights(flights, eventTypes);
        if (!mounted) return;
        setState(() {
          _data = ReportsData(
            totals: _applyTypeSelectionToTotals(result.totals, eventTypes),
            flights: flights,
          );
          _entries = entries;
          _detailsLoaded = true;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadDetailed() async {
    if (_from.isAfter(_to)) {
      setState(() => _error = 'Start date must be before end date.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final includePreviousExperience = ref.read(includePreviousExperienceProvider);
    final eventTypes = ref.read(reportsEventTypesProvider);

    try {
      final repo = ref.read(reportsRepositoryProvider);
      final result = await repo.load(
        ReportsQuery(
          from: _from,
          to: _to,
          includePreviousExperience: includePreviousExperience,
          filterMatchMode: _filterMatchMode,
          filters: _filters,
        ),
      );
      final flights = eventTypes.flights ? result.flights : const <ReportsFlightRow>[];
      final entries = await _fetchEntriesForFlights(flights, eventTypes);
      if (!mounted) return;
      setState(() {
        _data = ReportsData(
          totals: _applyTypeSelectionToTotals(result.totals, eventTypes),
          flights: flights,
        );
        _entries = entries;
        _detailsLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<List<LogbookEntry>> _fetchEntriesForFlights(
    List<ReportsFlightRow> flights,
    ReportsEventTypesSelection eventTypes,
  ) async {
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
      LogbookFilters(
        from: _from,
        to: _to,
        types: selectedTypes,
      ),
      limit: 10000,
      offset: 0,
    );
    final flightIds = flights.map((flight) => flight.flightId).toSet();
    return logbookEntries.where((entry) {
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
    }).toList(growable: false);
  }

  Future<void> _ensureDetailsLoaded() async {
    if (_detailsLoaded || _loading) return;
    await _loadDetailed();
  }

  Future<void> _onTabChanged(int index) async {
    if (index > 0) {
      await _ensureDetailsLoaded();
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final current = isStart ? _from : _to;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current.toLocal(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current.toLocal()),
    );
    if (pickedTime == null || !mounted) return;

    final local = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      if (isStart) {
        _from = local.toUtc();
      } else {
        _to = local.toUtc();
      }
      _preset = _ReportDateRangePreset.custom;
    });
    await _loadOverviewData();
  }

  Future<void> _applyPreset(_ReportDateRangePreset preset) async {
    if (preset == _ReportDateRangePreset.custom) {
      await _pickDateTime(isStart: true);
      if (!mounted) return;
      await _pickDateTime(isStart: false);
      return;
    }

    final now = DateTime.now().toUtc();
    DateTime start;
    DateTime end = now;

    switch (preset) {
      case _ReportDateRangePreset.sinceBeginning:
        start = DateTime.utc(1990, 1, 1);
        break;
      case _ReportDateRangePreset.last7Days:
        start = now.subtract(const Duration(days: 7));
        break;
      case _ReportDateRangePreset.last14Days:
        start = now.subtract(const Duration(days: 14));
        break;
      case _ReportDateRangePreset.last21Days:
        start = now.subtract(const Duration(days: 21));
        break;
      case _ReportDateRangePreset.last28Days:
        start = now.subtract(const Duration(days: 28));
        break;
      case _ReportDateRangePreset.last1Month:
        start = DateTime.utc(
          now.month == 1 ? now.year - 1 : now.year,
          now.month == 1 ? 12 : now.month - 1,
          now.day,
          now.hour,
          now.minute,
        );
        break;
      case _ReportDateRangePreset.last365Days:
        start = now.subtract(const Duration(days: 365));
        break;
      case _ReportDateRangePreset.currentMonth:
        start = DateTime.utc(now.year, now.month, 1);
        break;
      case _ReportDateRangePreset.currentYear:
        start = DateTime.utc(now.year, 1, 1);
        break;
      case _ReportDateRangePreset.lastMonth:
        final monthStart = DateTime.utc(now.year, now.month, 1);
        end = monthStart.subtract(const Duration(minutes: 1));
        start = DateTime.utc(end.year, end.month, 1);
        break;
      case _ReportDateRangePreset.lastYear:
        start = DateTime.utc(now.year - 1, 1, 1);
        end = DateTime.utc(now.year - 1, 12, 31, 23, 59);
        break;
      case _ReportDateRangePreset.custom:
        return;
    }

    setState(() {
      _preset = preset;
      _from = start;
      _to = end;
    });
    await _loadOverviewData();
  }

  Future<void> _addFilter() async {
    final added = await showDialog<ReportsFilterCondition>(
      context: context,
      builder: (context) => const _AddFilterDialog(),
    );
    if (added == null || !mounted) return;
    setState(() => _filters.add(added));
    await _loadOverviewData();
  }

  Future<void> _removeFilter(int index) async {
    if (index < 0 || index >= _filters.length) return;
    setState(() => _filters.removeAt(index));
    await _loadOverviewData();
  }

  Future<void> _setMatchMode(ReportsFilterMatchMode mode) async {
    if (_filterMatchMode == mode) return;
    setState(() => _filterMatchMode = mode);
    await _loadOverviewData();
  }

  Future<void> _setIncludePreviousExperience(bool value) async {
    await ref.read(includePreviousExperienceProvider.notifier).setValue(value);
    if (!mounted) return;
    await _loadOverviewData();
  }

  Future<void> _setEventTypes(ReportsEventTypesSelection value) async {
    await ref.read(reportsEventTypesProvider.notifier).setValue(value);
    if (!mounted) return;
    await _loadOverviewData();
  }

  Future<void> _saveCurrentQuery() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _SaveQueryDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    final query = SavedReportsQuery(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      from: _from,
      to: _to,
      includePreviousExperience: ref.read(includePreviousExperienceProvider),
      filterMatchMode: _filterMatchMode,
      filters: List<ReportsFilterCondition>.from(_filters),
    );
    await ref.read(savedReportsQueriesProvider.notifier).addQuery(query);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved query "${query.name}".')),
    );
  }

  Future<void> _applySavedQuery(SavedReportsQuery query) async {
    setState(() {
      _from = query.from.toUtc();
      _to = query.to.toUtc();
      _preset = _ReportDateRangePreset.custom;
      _filterMatchMode = query.filterMatchMode;
      _filters
        ..clear()
        ..addAll(query.filters);
    });
    await ref
        .read(includePreviousExperienceProvider.notifier)
        .setValue(query.includePreviousExperience);
    if (!mounted) return;
    await _loadOverviewData();
  }

  Future<void> _deleteSavedQuery(String id) async {
    await ref.read(savedReportsQueriesProvider.notifier).removeQuery(id);
  }

  Future<void> _openMapDialog() async {
    await _loadDetailed();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _FlightsMapDialog(flights: _data.flights),
    );
  }

  Future<void> _generatePdf() async {
    await _ensureDetailsLoaded();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generation will be connected next.')),
    );
  }

  List<_AnalysisGroup> _buildAnalysisGroups() {
    final groups = <String, _AnalysisGroupAccumulator>{};
    for (final flight in _data.flights) {
      final key = _analysisGroupBy.keyFor(flight);
      groups.putIfAbsent(key, () => _AnalysisGroupAccumulator()).add(flight);
    }
    final list = groups.entries
        .map((entry) => _AnalysisGroup(title: entry.key, totals: entry.value))
        .toList(growable: false);
    list.sort((a, b) => b.totals.totalMinutes.compareTo(a.totals.totalMinutes));
    return list;
  }

  ReportsTotals _applyTypeSelectionToTotals(
    ReportsTotals totals,
    ReportsEventTypesSelection selection,
  ) {
    return ReportsTotals(
      sectors: selection.flights ? totals.sectors : 0,
      takeoffsDay: selection.flights ? totals.takeoffsDay : 0,
      takeoffsNight: selection.flights ? totals.takeoffsNight : 0,
      landingsDay: selection.flights ? totals.landingsDay : 0,
      landingsNight: selection.flights ? totals.landingsNight : 0,
      ifrApproaches: selection.flights ? totals.ifrApproaches : 0,
      distanceNM: selection.flights ? totals.distanceNM : 0,
      totalMinutes: selection.flights ? totals.totalMinutes : 0,
      nightMinutes: selection.flights ? totals.nightMinutes : 0,
      ifrMinutes: selection.flights ? totals.ifrMinutes : 0,
      simulatedInstrumentMinutes:
          selection.flights ? totals.simulatedInstrumentMinutes : 0,
      picMinutes: selection.flights ? totals.picMinutes : 0,
      picusMinutes: selection.flights ? totals.picusMinutes : 0,
      sicMinutes: selection.flights ? totals.sicMinutes : 0,
      dualMinutes: selection.flights ? totals.dualMinutes : 0,
      instructorMinutes: selection.flights ? totals.instructorMinutes : 0,
      crossCountryMinutes: selection.flights ? totals.crossCountryMinutes : 0,
      simulatorMinutes: selection.simulator ? totals.simulatorMinutes : 0,
      dutyMinutes: selection.duty ? totals.dutyMinutes : 0,
      custom1Minutes: selection.flights ? totals.custom1Minutes : 0,
      custom2Minutes: selection.flights ? totals.custom2Minutes : 0,
      custom3Minutes: selection.flights ? totals.custom3Minutes : 0,
      custom4Minutes: selection.flights ? totals.custom4Minutes : 0,
      multiPilotMinutes: selection.flights ? totals.multiPilotMinutes : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final includePreviousExperience =
        ref.watch(includePreviousExperienceProvider);
    final eventTypes = ref.watch(reportsEventTypesProvider);
    final savedQueries = ref.watch(savedReportsQueriesProvider);
    final customTimeLabels =
        ref.watch(customTimeLabelsProvider).valueOrNull ??
            const CustomTimeLabels();
    final logbookUseCases = ref.read(logbookUseCasesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        const minWideWidth = 980.0;
        const minWideHeight = 700.0;
        if (constraints.maxWidth < minWideWidth ||
            constraints.maxHeight < minWideHeight) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Increase window size to at least '
                  '${minWideWidth.toInt()}x${minWideHeight.toInt()} '
                  'to use Reports wide layout.',
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                controller: _tabController,
                onTap: _onTabChanged,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Flights'),
                  Tab(text: 'Analizes'),
                ],
              ),
              if (_loading) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                Column(
                  children: [
                    _FiltersCard(
                      from: _from,
                      to: _to,
                      preset: _preset,
                      includePreviousExperience: includePreviousExperience,
                      eventTypes: eventTypes,
                      savedQueries: savedQueries,
                      filters: _filters,
                      matchMode: _filterMatchMode,
                      onPresetChanged: _applyPreset,
                      onPickStart: () => _pickDateTime(isStart: true),
                      onPickEnd: () => _pickDateTime(isStart: false),
                      onIncludePreviousExperienceChanged:
                          _setIncludePreviousExperience,
                      onEventTypesChanged: _setEventTypes,
                      onMatchModeChanged: _setMatchMode,
                      onAddFilter: _addFilter,
                      onRemoveFilter: _removeFilter,
                      onSaveQuery: _saveCurrentQuery,
                      onApplySavedQuery: _applySavedQuery,
                      onDeleteSavedQuery: _deleteSavedQuery,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _TotalsCard(
                        totals: _data.totals,
                        customTimeLabels: customTimeLabels,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _generatePdf,
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text('Generate Logbook PDF'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openMapDialog,
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Map'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _EntriesPanel(
                  entries: _entries,
                  onEntryTap: (entry) {
                    LogbookEntryDialogs.show(
                      context,
                      entry: entry,
                      useCases: logbookUseCases,
                    );
                  },
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Text('Analyze by:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<_AnalysisGroupBy>(
                            initialValue: _analysisGroupBy,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _AnalysisGroupBy.values
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value.label),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _analysisGroupBy = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _AnalysisList(groups: _buildAnalysisGroups()),
                    ),
                  ],
                ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _ReportDateRangePreset {
  sinceBeginning,
  last7Days,
  last14Days,
  last21Days,
  last28Days,
  last1Month,
  last365Days,
  currentMonth,
  currentYear,
  lastMonth,
  lastYear,
  custom,
}

extension on _ReportDateRangePreset {
  String get label {
    switch (this) {
      case _ReportDateRangePreset.sinceBeginning:
        return 'Since beginning';
      case _ReportDateRangePreset.last7Days:
        return 'Last 7 days';
      case _ReportDateRangePreset.last14Days:
        return 'Last 14 days';
      case _ReportDateRangePreset.last21Days:
        return 'Last 21 days';
      case _ReportDateRangePreset.last28Days:
        return 'Last 28 days';
      case _ReportDateRangePreset.last1Month:
        return 'Last month (rolling)';
      case _ReportDateRangePreset.last365Days:
        return 'Last 365 days';
      case _ReportDateRangePreset.currentMonth:
        return 'Current month';
      case _ReportDateRangePreset.currentYear:
        return 'Current year';
      case _ReportDateRangePreset.lastMonth:
        return 'Last month';
      case _ReportDateRangePreset.lastYear:
        return 'Last year';
      case _ReportDateRangePreset.custom:
        return 'Custom';
    }
  }
}

enum _AnalysisGroupBy {
  aircraft,
  type,
  family,
  year,
  month,
}

extension on _AnalysisGroupBy {
  String get label {
    switch (this) {
      case _AnalysisGroupBy.aircraft:
        return 'By Aircraft';
      case _AnalysisGroupBy.type:
        return 'By Type';
      case _AnalysisGroupBy.family:
        return 'By Family';
      case _AnalysisGroupBy.year:
        return 'By Year';
      case _AnalysisGroupBy.month:
        return 'By Month';
    }
  }

  String keyFor(ReportsFlightRow row) {
    switch (this) {
      case _AnalysisGroupBy.aircraft:
        return row.registration.trim().isEmpty ? 'Unknown' : row.registration;
      case _AnalysisGroupBy.type:
        return row.modelCode.trim().isEmpty ? 'Unknown type' : row.modelCode;
      case _AnalysisGroupBy.family:
        return row.modelFamily.trim().isEmpty ? 'Unknown family' : row.modelFamily;
      case _AnalysisGroupBy.year:
        return row.departureDateTime.year.toString();
      case _AnalysisGroupBy.month:
        return DateFormat('yyyy-MM').format(row.departureDateTime);
    }
  }
}

class _AnalysisGroupAccumulator {
  int totalMinutes = 0;
  int picMinutes = 0;
  int picusMinutes = 0;
  int sicMinutes = 0;
  int dualMinutes = 0;
  int ifrMinutes = 0;
  int instrumentMinutes = 0;
  int nightMinutes = 0;
  int landings = 0;
  DateTime? firstFlightUtc;
  DateTime? lastFlightUtc;

  void add(ReportsFlightRow row) {
    totalMinutes += row.totalMinutes;
    picMinutes += row.picMinutes;
    picusMinutes += row.picusMinutes;
    sicMinutes += row.sicMinutes;
    dualMinutes += row.dualMinutes;
    ifrMinutes += row.ifrMinutes;
    instrumentMinutes += row.instrumentMinutes;
    nightMinutes += row.nightMinutes;
    landings += row.landings;
    if (firstFlightUtc == null || row.departureDateTime.isBefore(firstFlightUtc!)) {
      firstFlightUtc = row.departureDateTime;
    }
    if (lastFlightUtc == null || row.departureDateTime.isAfter(lastFlightUtc!)) {
      lastFlightUtc = row.departureDateTime;
    }
  }
}

class _AnalysisGroup {
  const _AnalysisGroup({required this.title, required this.totals});

  final String title;
  final _AnalysisGroupAccumulator totals;
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.from,
    required this.to,
    required this.preset,
    required this.includePreviousExperience,
    required this.eventTypes,
    required this.savedQueries,
    required this.filters,
    required this.matchMode,
    required this.onPresetChanged,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onIncludePreviousExperienceChanged,
    required this.onEventTypesChanged,
    required this.onMatchModeChanged,
    required this.onAddFilter,
    required this.onRemoveFilter,
    required this.onSaveQuery,
    required this.onApplySavedQuery,
    required this.onDeleteSavedQuery,
  });

  final DateTime from;
  final DateTime to;
  final _ReportDateRangePreset preset;
  final bool includePreviousExperience;
  final ReportsEventTypesSelection eventTypes;
  final List<SavedReportsQuery> savedQueries;
  final List<ReportsFilterCondition> filters;
  final ReportsFilterMatchMode matchMode;
  final Future<void> Function(_ReportDateRangePreset preset) onPresetChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final ValueChanged<bool> onIncludePreviousExperienceChanged;
  final Future<void> Function(ReportsEventTypesSelection) onEventTypesChanged;
  final Future<void> Function(ReportsFilterMatchMode mode) onMatchModeChanged;
  final Future<void> Function() onAddFilter;
  final Future<void> Function(int index) onRemoveFilter;
  final Future<void> Function() onSaveQuery;
  final Future<void> Function(SavedReportsQuery query) onApplySavedQuery;
  final Future<void> Function(String id) onDeleteSavedQuery;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text('Filters'),
        subtitle: Text(
          '${filters.length} filters • ${DateFormat('dd/MM/yyyy HH:mm').format(from)} UTC - ${DateFormat('dd/MM/yyyy HH:mm').format(to)} UTC',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Flight'),
                selected: eventTypes.flights,
                onSelected: (value) =>
                    onEventTypesChanged(eventTypes.copyWith(flights: value)),
              ),
              FilterChip(
                label: const Text('Sim'),
                selected: eventTypes.simulator,
                onSelected: (value) =>
                    onEventTypesChanged(eventTypes.copyWith(simulator: value)),
              ),
              FilterChip(
                label: const Text('Duty'),
                selected: eventTypes.duty,
                onSelected: (value) =>
                    onEventTypesChanged(eventTypes.copyWith(duty: value)),
              ),
              FilterChip(
                label: const Text('Positioning'),
                selected: eventTypes.positioning,
                onSelected: (value) => onEventTypesChanged(
                  eventTypes.copyWith(positioning: value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 250,
                child: DropdownButtonFormField<_ReportDateRangePreset>(
                  initialValue: preset,
                  decoration: const InputDecoration(
                    labelText: 'Date range',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _ReportDateRangePreset.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      onPresetChanged(value);
                    }
                  },
                ),
              ),
              _DateTimeButton(label: 'From', value: from, onTap: onPickStart),
              _DateTimeButton(label: 'To', value: to, onTap: onPickEnd),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<bool>(
                  initialValue: includePreviousExperience,
                  decoration: const InputDecoration(
                    labelText: 'Previous experience',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Include')),
                    DropdownMenuItem(value: false, child: Text('Exclude')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onIncludePreviousExperienceChanged(value);
                    }
                  },
                ),
              ),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<ReportsFilterMatchMode>(
                  initialValue: matchMode,
                  decoration: const InputDecoration(
                    labelText: 'Match mode',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ReportsFilterMatchMode.all,
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: ReportsFilterMatchMode.any,
                      child: Text('Any'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onMatchModeChanged(value);
                    }
                  },
                ),
              ),
              SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: onAddFilter,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Filter'),
                ),
              ),
            ],
          ),
          if (filters.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var index = 0; index < filters.length; index++)
                  InputChip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      '${filters[index].field.label} · ${filters[index].operator.label} · ${filters[index].displayValue}',
                    ),
                    onDeleted: () => onRemoveFilter(index),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue: null,
                  decoration: const InputDecoration(
                    labelText: 'Saved queries',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: savedQueries
                      .map(
                        (query) => DropdownMenuItem(
                          value: query.id,
                          child: Text(query.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    final query = savedQueries.firstWhere(
                      (item) => item.id == value,
                    );
                    onApplySavedQuery(query);
                  },
                ),
              ),
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: onSaveQuery,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Query'),
                ),
              ),
              if (savedQueries.isNotEmpty)
                PopupMenuButton<String>(
                  onSelected: onDeleteSavedQuery,
                  itemBuilder: (context) => savedQueries
                      .map(
                        (query) => PopupMenuItem(
                          value: query.id,
                          child: Text('Delete: ${query.name}'),
                        ),
                      )
                      .toList(growable: false),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline, size: 18),
                        SizedBox(width: 6),
                        Text('Delete Saved'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 2),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(value),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.totals,
    required this.customTimeLabels,
  });

  final ReportsTotals totals;
  final CustomTimeLabels customTimeLabels;

  @override
  Widget build(BuildContext context) {
    final operations = <(String, String)>[
      ('IFR Approaches', _formatCount(totals.ifrApproaches)),
      ('Takeoff Day', _formatCount(totals.takeoffsDay)),
      ('Takeoff Night', _formatCount(totals.takeoffsNight)),
      ('Landing Day', _formatCount(totals.landingsDay)),
      ('Landing Night', _formatCount(totals.landingsNight)),
    ];
    final times = <(String, String)>[
      ('Total Block', _formatMinutes(totals.totalMinutes)),
      ('PIC', _formatMinutes(totals.picMinutes)),
      ('PICUS', _formatMinutes(totals.picusMinutes)),
      ('SIC', _formatMinutes(totals.sicMinutes)),
      ('Dual', _formatMinutes(totals.dualMinutes)),
      ('Instructor', _formatMinutes(totals.instructorMinutes)),
      ('Night', _formatMinutes(totals.nightMinutes)),
      ('IFR', _formatMinutes(totals.ifrMinutes)),
      (
        'Instrument',
        _formatMinutes(
          totals.simulatedInstrumentMinutes + totals.ifrMinutes,
        ),
      ),
      ('Cross-Country', _formatMinutes(totals.crossCountryMinutes)),
      ('Simulator', _formatMinutes(totals.simulatorMinutes)),
      ('Duty', _formatMinutes(totals.dutyMinutes)),
      ('Distance NM', _formatCount(totals.distanceNM)),
      (customTimeLabels.custom1, _formatMinutes(totals.custom1Minutes)),
      (customTimeLabels.custom2, _formatMinutes(totals.custom2Minutes)),
      (customTimeLabels.custom3, _formatMinutes(totals.custom3Minutes)),
      (customTimeLabels.custom4, _formatMinutes(totals.custom4Minutes)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectionArea(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Flight count: ${_formatCount(totals.sectors)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _MetricWrap(metrics: operations),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      _MetricWrap(metrics: times),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricWrap extends StatelessWidget {
  const _MetricWrap({required this.metrics});

  final List<(String, String)> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final minTileWidth = constraints.maxWidth >= 1000 ? 150.0 : 190.0;
        final maxColumns = constraints.maxWidth >= 1000 ? 5 : 4;
        final columns =
            (constraints.maxWidth / minTileWidth).floor().clamp(1, maxColumns);
        final tileWidth =
            (constraints.maxWidth - (columns - 1) * spacing) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: tileWidth,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        metric.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AnalysisList extends StatelessWidget {
  const _AnalysisList({required this.groups});

  final List<_AnalysisGroup> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Card(
        child: Center(child: Text('No data for selected query.')),
      );
    }

    final maxTotal =
        groups.fold<int>(0, (maxValue, group) => group.totals.totalMinutes > maxValue
            ? group.totals.totalMinutes
            : maxValue);

    return ListView.separated(
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            title: _AnalysisBarRow(
              label: group.title,
              valueText: _formatMinutes(group.totals.totalMinutes),
              ratio: maxTotal > 0 ? group.totals.totalMinutes / maxTotal : 0,
              emphasized: true,
            ),
            children: [
              _AnalysisBarRow(
                label: 'PIC',
                valueText: _formatMinutes(group.totals.picMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.picMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: 'PICUS',
                valueText: _formatMinutes(group.totals.picusMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.picusMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: 'SIC',
                valueText: _formatMinutes(group.totals.sicMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.sicMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: 'Dual',
                valueText: _formatMinutes(group.totals.dualMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.dualMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: 'Night',
                valueText: _formatMinutes(group.totals.nightMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.nightMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: 'IFR',
                valueText: _formatMinutes(group.totals.ifrMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.ifrMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: 'Instrument',
                valueText: _formatMinutes(group.totals.instrumentMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.instrumentMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: 'Landings',
                valueText: '${group.totals.landings}',
                ratio: 1,
              ),
              const SizedBox(height: 8),
              if (group.totals.firstFlightUtc != null)
                Text(
                  'First flight ${DateFormat('dd MMM yyyy HH:mm').format(group.totals.firstFlightUtc!)} UTC',
                ),
              if (group.totals.lastFlightUtc != null)
                Text(
                  'Last flight ${DateFormat('dd MMM yyyy HH:mm').format(group.totals.lastFlightUtc!)} UTC',
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalysisBarRow extends StatelessWidget {
  const _AnalysisBarRow({
    required this.label,
    required this.valueText,
    required this.ratio,
    this.emphasized = false,
  });

  final String label;
  final String valueText;
  final double ratio;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textStyle = emphasized
        ? const TextStyle(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyMedium;
    final barColor = emphasized
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: ratio.clamp(0, 1).toDouble(),
                color: barColor,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              valueText,
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFilterDialog extends StatefulWidget {
  const _AddFilterDialog();

  @override
  State<_AddFilterDialog> createState() => _AddFilterDialogState();
}

class _AddFilterDialogState extends State<_AddFilterDialog> {
  ReportsFilterField _field = ReportsFilterField.departureIcao;
  late ReportsFilterOperator _operator;
  final _textController = TextEditingController();
  final _numberController = TextEditingController();
  final _timeController = TextEditingController(text: '0:00');

  @override
  void initState() {
    super.initState();
    _operator = _field.valueType.supportedOperators.first;
  }

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _onFieldChanged(ReportsFilterField value) {
    setState(() {
      _field = value;
      _operator = value.valueType.supportedOperators.first;
      _textController.clear();
      _numberController.clear();
      _timeController.text = '0:00';
    });
  }

  void _save() {
    final type = _field.valueType;
    String? text;
    int? number;
    if (type == ReportsFilterValueType.text) {
      text = _textController.text.trim();
      if (text.isEmpty) return;
    } else if (type == ReportsFilterValueType.number) {
      number = int.tryParse(_numberController.text.trim());
      if (number == null) return;
    } else if (type == ReportsFilterValueType.time) {
      number = TimeInputField.parseMinutes(_timeController.text.trim());
      if (number == null) return;
    }

    Navigator.of(context).pop(
      ReportsFilterCondition(
        field: _field,
        operator: _operator,
        textValue: text,
        numberValue: number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final operators = _field.valueType.supportedOperators;
    return Dialog(
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Filter',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReportsFilterField>(
                initialValue: _field,
                decoration: const InputDecoration(
                  labelText: 'Field name',
                  border: OutlineInputBorder(),
                ),
                items: ReportsFilterField.values
                    .map(
                      (field) => DropdownMenuItem(
                        value: field,
                        child: Text(field.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    _onFieldChanged(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ReportsFilterOperator>(
                initialValue: _operator,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: operators
                    .map(
                      (operator) => DropdownMenuItem(
                        value: operator,
                        child: Text(operator.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _operator = value);
                  }
                },
              ),
              if (_field.valueType != ReportsFilterValueType.boolean) ...[
                const SizedBox(height: 12),
                _buildValueField(),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueField() {
    switch (_field.valueType) {
      case ReportsFilterValueType.text:
        return TextFormField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
          ),
        );
      case ReportsFilterValueType.number:
        return TextFormField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
          ),
        );
      case ReportsFilterValueType.time:
        return TimeInputField(controller: _timeController, label: 'Value');
      case ReportsFilterValueType.boolean:
        return const SizedBox.shrink();
    }
  }
}

class _SaveQueryDialog extends StatefulWidget {
  const _SaveQueryDialog();

  @override
  State<_SaveQueryDialog> createState() => _SaveQueryDialogState();
}

class _SaveQueryDialogState extends State<_SaveQueryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Save Query',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_controller.text),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntriesPanel extends StatelessWidget {
  const _EntriesPanel({
    required this.entries,
    required this.onEntryTap,
  });

  final List<LogbookEntry> entries;
  final ValueChanged<LogbookEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Flights & Simulator',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${entries.length} entries',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('No flights/sim in selected period.'))
                  : LogbookEntriesYearList(
                      entries: entries,
                      onEntryTap: onEntryTap,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightsMapDialog extends StatefulWidget {
  const _FlightsMapDialog({
    required this.flights,
    this.fullscreen = false,
  });

  final List<ReportsFlightRow> flights;
  final bool fullscreen;

  @override
  State<_FlightsMapDialog> createState() => _FlightsMapDialogState();
}

class _FlightsMapDialogState extends State<_FlightsMapDialog> {
  final _mapController = MapController();
  double _zoom = 2.0;
  bool _showLines = true;
  static const Color _mapLineColor = Color(0x994A90E2);
  static const Color _mapDotColor = Color(0xFF1565C0);

  Future<void> _openFullscreen() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _FlightsMapDialog(
        flights: widget.flights,
        fullscreen: true,
      ),
    );
  }

  void _printMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map printing is not configured yet.'),
      ),
    );
  }

  List<LatLng> _greatCirclePoints(LatLng from, LatLng to, {int segments = 48}) {
    final lat1 = from.latitude * math.pi / 180.0;
    final lon1 = from.longitude * math.pi / 180.0;
    final lat2 = to.latitude * math.pi / 180.0;
    final lon2 = to.longitude * math.pi / 180.0;

    final d = 2 *
        math.asin(
          math.sqrt(
            math.pow(math.sin((lat2 - lat1) / 2), 2).toDouble() +
                math.cos(lat1) *
                    math.cos(lat2) *
                    math.pow(math.sin((lon2 - lon1) / 2), 2).toDouble(),
          ),
        );
    if (d == 0 || d.isNaN) {
      return [from, to];
    }

    final points = <LatLng>[];
    final sinD = math.sin(d);
    for (var i = 0; i <= segments; i++) {
      final f = i / segments;
      final a = math.sin((1 - f) * d) / sinD;
      final b = math.sin(f * d) / sinD;

      final x = a * math.cos(lat1) * math.cos(lon1) +
          b * math.cos(lat2) * math.cos(lon2);
      final y = a * math.cos(lat1) * math.sin(lon1) +
          b * math.cos(lat2) * math.sin(lon2);
      final z = a * math.sin(lat1) + b * math.sin(lat2);

      final lat = math.atan2(z, math.sqrt(x * x + y * y));
      final lon = math.atan2(y, x);
      points.add(LatLng(lat * 180.0 / math.pi, lon * 180.0 / math.pi));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final lines = <Polyline>[];
    final markers = <Marker>[];
    final airports = <String>{};
    final markerKeys = <String>{};

    for (final row in widget.flights) {
      final fromIcao = row.fromIcao.trim().toUpperCase();
      final toIcao = row.toIcao.trim().toUpperCase();
      if (fromIcao.isNotEmpty) airports.add(fromIcao);
      if (toIcao.isNotEmpty) airports.add(toIcao);
      if (row.fromLatitude == null ||
          row.fromLongitude == null ||
          row.toLatitude == null ||
          row.toLongitude == null) {
        continue;
      }

      final fromPoint = LatLng(row.fromLatitude!, row.fromLongitude!);
      final toPoint = LatLng(row.toLatitude!, row.toLongitude!);
      if (_showLines) {
        lines.add(
          Polyline(
            points: _greatCirclePoints(fromPoint, toPoint),
            strokeWidth: 2,
            color: _mapLineColor,
          ),
        );
      }
      final fromKey = '${fromPoint.latitude.toStringAsFixed(4)}_${fromPoint.longitude.toStringAsFixed(4)}';
      if (markerKeys.add(fromKey)) {
        markers.add(
          Marker(
            point: fromPoint,
            width: 14,
            height: 14,
            child: const Icon(
              Icons.circle,
              size: 9,
              color: _mapDotColor,
            ),
          ),
        );
      }
      final toKey = '${toPoint.latitude.toStringAsFixed(4)}_${toPoint.longitude.toStringAsFixed(4)}';
      if (markerKeys.add(toKey)) {
        markers.add(
          Marker(
            point: toPoint,
            width: 14,
            height: 14,
            child: const Icon(
              Icons.circle,
              size: 9,
              color: _mapDotColor,
            ),
          ),
        );
      }
    }
    final airportCount = airports.length;

    final screen = MediaQuery.of(context).size;
    final dialogWidth = widget.fullscreen ? screen.width * 0.98 : 900.0;
    final dialogHeight = widget.fullscreen ? screen.height * 0.96 : 620.0;

    return Dialog(
      insetPadding: widget.fullscreen
          ? const EdgeInsets.all(8)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.fullscreen ? 'Flight Map (Full Screen)' : 'Flight Map',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: _showLines ? 'Hide lines' : 'Show lines',
                    onPressed: () => setState(() => _showLines = !_showLines),
                    icon: Icon(_showLines ? Icons.route : Icons.scatter_plot),
                  ),
                  IconButton(
                    tooltip: 'Print map',
                    onPressed: _printMap,
                    icon: const Icon(Icons.print_outlined),
                  ),
                  if (!widget.fullscreen)
                    IconButton(
                      tooltip: 'Full screen',
                      onPressed: _openFullscreen,
                      icon: const Icon(Icons.open_in_full),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: markers.isEmpty
                  ? const Center(child: Text('No coordinates available.'))
                  : Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(20, 0),
                            initialZoom: 2,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.rietlabs.simplelog',
                            ),
                            PolylineLayer(polylines: lines),
                            MarkerLayer(markers: markers),
                          ],
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Text('Airports: $airportCount'),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Card(
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _zoom += 1;
                                    _mapController.move(_mapController.camera.center, _zoom);
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _zoom -= 1;
                                    _mapController.move(_mapController.camera.center, _zoom);
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMinutes(int minutes) {
  final safe = minutes < 0 ? 0 : minutes;
  final hour = safe ~/ 60;
  final min = safe % 60;
  return '${_formatCount(hour)}:${min.toString().padLeft(2, '0')}';
}

String _formatCount(int value) {
  return NumberFormat.decimalPattern().format(value);
}
