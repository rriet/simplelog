import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart' as d;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/core/presentation/widgets/display/buttons.dart';
import 'package:simplelog/core/presentation/widgets/display/event_type_toggle_button.dart';
import 'package:simplelog/core/presentation/widgets/display/square_outline_button.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/maps/flight_routes_map_view.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';
import 'package:simplelog/core/theme/app_tab_bar_styles.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/user_settings_json.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/report_pdf_models.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/data/reports/report_xsl_template_loader.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/flight_edit_screen.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_list_item.dart';
import 'package:simplelog/features/reports/application/report_pdf_application_service.dart';
import 'package:simplelog/features/reports/presentation/providers/report_pdf_application_service_provider.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_preferences_provider.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_repository_provider.dart';
import 'package:simplelog/features/reports/presentation/widgets/reports_form_components.dart';
import 'package:simplelog/features/settings/presentation/widgets/pilot_profile_settings_card.dart';
import 'package:simplelog/state/providers/batch_write_guard_provider.dart';
import 'package:simplelog/state/providers/custom_time_labels_provider.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/duty_rules_settings_provider.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';
import 'package:simplelog/state/providers/flight_form_settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _batchCalculateAllPreferencesKey =
    'reports_batch_calculate_all_preferences_v1';

/// Entry section to open directly when navigating into the reports module.
enum ReportsPanelSection {
  /// Dashboard-style overview totals and KPIs.
  overview,

  /// Flight/simulator entry list and map tools.
  flights,

  /// Grouped analytics and comparisons.
  analizes,

  /// PDF report generation controls.
  reports,

  /// Batch processing controls for filtered flights.
  batch,

  /// Filter builder and saved filters.
  filters,

  /// Totals-focused panel.
  totals,
}

class _CoverSummaryColumn {
  const _CoverSummaryColumn({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;
}

const _defaultCoverSummaryColumns = <_CoverSummaryColumn>[
  _CoverSummaryColumn(key: 'type', label: 'TYPE'),
  _CoverSummaryColumn(key: 'night', label: 'NIGHT'),
  _CoverSummaryColumn(key: 'ifr', label: 'IFR'),
  _CoverSummaryColumn(key: 'pic', label: 'PIC'),
  _CoverSummaryColumn(key: 'picus', label: 'PICUS'),
  _CoverSummaryColumn(key: 'picPicus', label: 'PIC+PICUS'),
  _CoverSummaryColumn(key: 'sic', label: 'SIC'),
  _CoverSummaryColumn(key: 'dual', label: 'DUAL'),
  _CoverSummaryColumn(key: 'instructor', label: 'INSTRUCTOR'),
  _CoverSummaryColumn(key: 'examiner', label: 'EXAMINER'),
  _CoverSummaryColumn(key: 'total', label: 'TOTAL'),
];

class _XslTemplateOption {
  /// Creates a selectable template entry for the PDF generator UI.
  const _XslTemplateOption({
    required this.fileName,
    required this.description,
    required this.numberOfLines,
    required this.template,
  });

  /// Internal template file identifier.
  final String fileName;
  final String description;

  /// Number of rows this template can render per PDF page.
  final int numberOfLines;
  final ReportPdfTemplate template;
}

String _sanitizeTemplateName(String raw) {
  return raw
      .trim()
      .replaceAll('_', ' ')
      .replaceAll(RegExp('[^A-Za-z0-9 -]'), '')
      .replaceAll(RegExp(' +'), ' ');
}

/// Reports module screen for analytics, filtering, and PDF generation.
class ReportsScreen extends ConsumerStatefulWidget {
  /// Creates the reports screen.
  ///
  /// [section] can preselect and preload a specific panel when opened from
  /// another part of the app.
  const ReportsScreen({super.key, this.section});

  /// Optional panel that should be shown first.
  final ReportsPanelSection? section;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  DateTime _from = DateTime.utc(1990);
  DateTime _to = DateTime.now().toUtc();
  _ReportDateRangePreset _preset = _ReportDateRangePreset.sinceBeginning;
  ReportsFilterMatchMode _filterMatchMode = ReportsFilterMatchMode.all;
  final List<ReportsFilterCondition> _filters = [];
  _AnalysisGroupBy _analysisGroupBy = _AnalysisGroupBy.family;
  _AnalysisOrderBy _analysisOrderBy = _AnalysisOrderBy.hours;
  late final TabController _tabController;
  List<_XslTemplateOption> _xslTemplateOptions = const [];
  _XslTemplateOption? _selectedTemplate;
  bool _showPathOnMap = true;
  bool _isGeneratingPdf = false;
  String _pdfGenerationStatus = '';
  double? _pdfGenerationProgress;

  bool _loading = false;
  bool _detailsLoaded = false;
  bool _entriesLoaded = false;
  bool _pendingDetailsLoad = false;
  bool _pendingIncludeEntries = false;
  bool _pendingOverviewLoad = false;
  String? _error;
  bool _analysisLoading = false;
  int _analysisBuildToken = 0;
  List<_AnalysisGroup> _analysisGroups = const [];
  String _analysisBaseBucketsKey = '';
  String _analysisPreviousBucketsKey = '';
  Map<String, _AnalysisGroupAccumulator> _analysisBaseBuckets = const {};
  Map<String, _AnalysisGroupAccumulator> _analysisPreviousBuckets = const {};
  static const List<_AnalysisGroupBy> _analysisGroupByOptions =
      <_AnalysisGroupBy>[
        _AnalysisGroupBy.family,
        _AnalysisGroupBy.type,
        _AnalysisGroupBy.aircraft,
        _AnalysisGroupBy.airport,
        _AnalysisGroupBy.year,
        _AnalysisGroupBy.month,
      ];
  ProviderSubscription<String?>? _selectedTemplateSubscription;
  final _fromTimeController = TextEditingController();
  final _toTimeController = TextEditingController();
  int _lastHandledTabIndex = 0;

  ReportsData _data = const ReportsData(
    totals: ReportsTotals.zero(),
    flights: [],
  );
  String? _flightRowsCacheKey;
  List<ReportsFlightRow> _flightRowsCache = const [];
  String? _mapDataCacheKey;
  ReportsMapData _mapDataCache = const ReportsMapData(airports: [], routes: []);
  int _batchFlightCount = 0;
  bool _isCheckingBatchFlights = false;
  bool _isPreparingBatchData = false;
  bool _isCalculatingBatchDuty = false;
  List<LogbookEntry> _entries = const [];
  DateTime? _firstFlightDate;
  DateTime? _lastFlightDate;

  @override
  void initState() {
    super.initState();
    final runtimeQuery = ref.read(reportsRuntimeQueryProvider);
    _from = runtimeQuery.from;
    _to = runtimeQuery.to;
    _preset = _presetFromName(runtimeQuery.selectedPreset);
    _syncRangeTimeControllers();
    _filterMatchMode = runtimeQuery.matchMode;
    _filters
      ..clear()
      ..addAll(runtimeQuery.filters);
    _selectedTemplateSubscription = ref.listenManual<String?>(
      selectedReportTemplateFileNameProvider,
      (_, next) {
        if (!mounted || next == null || next.isEmpty) return;
        if (_xslTemplateOptions.isEmpty) return;
        final matched = _xslTemplateOptions.where(
          (option) => option.fileName == next,
        );
        if (matched.isEmpty) return;
        final template = matched.first;
        if (_selectedTemplate?.fileName == template.fileName) return;
        setState(() => _selectedTemplate = template);
      },
    );
    _tabController = TabController(length: 5, vsync: this);
    _lastHandledTabIndex = _tabController.index;
    _tabController.addListener(_handleTabIndexChange);
    unawaited(_loadTemplateOptions());
    if (widget.section == null) {
      if (_shouldPreloadOverview(widget.section)) {
        unawaited(_loadOverviewData());
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          _ensureDetailsLoaded(
            includeEntries: true,
          ),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_preloadForSection(widget.section!));
      });
    }
  }

  Future<void> _loadTemplateOptions() async {
    final db = ref.read(databaseProvider);
    final templates = await ReportXslTemplateLoader(db).load();
    if (!mounted) {
      return;
    }
    final options = templates
        .map(
          (template) => _XslTemplateOption(
            fileName: template.fileName,
            description: template.displayName,
            numberOfLines: template.rowsPerPage,
            template: template,
          ),
        )
        .toList(growable: false);
    if (options.isEmpty) {
      return;
    }
    final preferredTemplateFileName = ref.read(
      selectedReportTemplateFileNameProvider,
    );
    final preferred = options.where((option) {
      return option.fileName == preferredTemplateFileName;
    });
    if (mounted) {
      setState(() {
        _xslTemplateOptions = options;
        _selectedTemplate = preferred.isNotEmpty
            ? preferred.first
            : (_selectedTemplate ?? options.first);
      });
    }
  }

  Future<void> _openTemplateEditorDialog() async {
    final db = ref.read(databaseProvider);
    final changed = await _presentAdaptiveShellDialog<bool>(
      _EditTemplatesDialog(
        db: db,
      ),
    );
    if (!mounted || changed != true) {
      return;
    }
    final previouslySelected = _selectedTemplate?.fileName;
    await _loadTemplateOptions();
    if (!mounted) {
      return;
    }
    if (_xslTemplateOptions.isEmpty) {
      if (mounted) {
        setState(() => _selectedTemplate = null);
      }
      return;
    }
    final preferredName =
        previouslySelected ?? _xslTemplateOptions.first.fileName;
    final matched = _xslTemplateOptions.where(
      (option) => option.fileName == preferredName,
    );
    final next = matched.isNotEmpty ? matched.first : _xslTemplateOptions.first;
    if (mounted) {
      setState(() => _selectedTemplate = next);
    }
    await ref
        .read(selectedReportTemplateFileNameProvider.notifier)
        .setValue(value: next.fileName);
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section && widget.section != null) {
      unawaited(_preloadForSection(widget.section!));
    }
  }

  Future<void> _preloadForSection(ReportsPanelSection section) async {
    switch (section) {
      case ReportsPanelSection.totals:
      case ReportsPanelSection.overview:
        if (_loading) {
          _pendingOverviewLoad = true;
          return;
        }
        await _loadOverviewData();
        return;
      case ReportsPanelSection.flights:
        await _ensureDetailsLoaded(includeEntries: true);
        return;
      case ReportsPanelSection.analizes:
        if (_filters.isEmpty) {
          if (_loading) {
            _pendingOverviewLoad = true;
            return;
          }
          await _loadOverviewData();
        } else {
          await _ensureDetailsLoaded(includeEntries: false);
        }
        if (!mounted) return;
        unawaited(_refreshAnalysisGroups());
        return;
      case ReportsPanelSection.batch:
        if (_loading) {
          _pendingOverviewLoad = true;
          return;
        }
        await _loadOverviewData();
        return;
      case ReportsPanelSection.reports:
      case ReportsPanelSection.filters:
        return;
    }
  }

  bool _shouldPreloadOverview(ReportsPanelSection? section) {
    return section != ReportsPanelSection.reports &&
        section != ReportsPanelSection.filters;
  }

  bool get _isFiltersOnlySection {
    return widget.section == ReportsPanelSection.filters;
  }

  bool get _isAnalysesVisible {
    if (widget.section == ReportsPanelSection.analizes) {
      return true;
    }
    return widget.section == null && _tabController.index == 2;
  }

  bool get _isFlightsVisible {
    if (widget.section == ReportsPanelSection.flights) {
      return true;
    }
    return widget.section == null && _tabController.index == 0;
  }

  bool get _analysisSupportsPreviousExperience =>
      _analysisGroupBy == _AnalysisGroupBy.type ||
      _analysisGroupBy == _AnalysisGroupBy.family;

  String _analysisBucketsKey() {
    return '${_analysisGroupBy.name}|${_from.millisecondsSinceEpoch}|'
        '${_to.millisecondsSinceEpoch}|${_data.flights.length}|'
        '${_data.flights.isEmpty ? 0 : _data.flights.first.flightId}|'
        '${_data.flights.isEmpty ? 0 : _data.flights.last.flightId}';
  }

  void _invalidateAnalysisCache() {
    _analysisBaseBucketsKey = '';
    _analysisPreviousBucketsKey = '';
    _analysisBaseBuckets = const {};
    _analysisPreviousBuckets = const {};
  }

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _selectedTemplateSubscription?.close();
    _tabController
      ..removeListener(_handleTabIndexChange)
      ..dispose();
    super.dispose();
  }

  void _handleTabIndexChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    final index = _tabController.index;
    if (index == _lastHandledTabIndex) {
      return;
    }
    _lastHandledTabIndex = index;
    unawaited(_onTabChanged(index));
  }

  Future<void> _loadOverviewData() async {
    if (_from.isAfter(_to)) {
      setState(
        () => _error = AppLocalizations.of(context)!.reportsStartBeforeEndError,
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final includePreviousExperience = ref.read(
      includePreviousExperienceProvider,
    );
    final eventTypes = ref.read(reportsEventTypesProvider);

    try {
      final repo = ref.read(reportsRepositoryProvider);
      if (_filters.isEmpty) {
        final totals = await repo.loadQuickTotals(
          from: _from,
          to: _to,
          includePreviousExperience: includePreviousExperience,
        );
        final flightRange = await repo.loadFlightDateRange(
          from: _from,
          to: _to,
        );
        final range = await _resolveDisplayedDateRange(
          baseRange: flightRange,
          includePreviousExperience: includePreviousExperience,
        );
        if (mounted) {
          setState(() {
            _data = ReportsData(
              totals: _applyTypeSelectionToTotals(totals, eventTypes),
              flights: const [],
            );
            _batchFlightCount = eventTypes.flights ? totals.sectors : 0;
            _entries = const [];
            _detailsLoaded = false;
            _entriesLoaded = false;
            _analysisGroups = const [];
            _analysisLoading = false;
            _invalidateAnalysisCache();
            _firstFlightDate = range.$1;
            _lastFlightDate = range.$2;
          });
        }
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
        final flights = eventTypes.flights
            ? result.flights
            : const <ReportsFlightRow>[];
        if (!mounted) return;
        final baseRange = _flightRangeFromRows(flights);
        final range = await _resolveDisplayedDateRange(
          baseRange: baseRange,
          includePreviousExperience: includePreviousExperience,
        );
        if (mounted) {
          setState(() {
            _data = ReportsData(
              totals: _applyTypeSelectionToTotals(result.totals, eventTypes),
              flights: flights,
            );
            _batchFlightCount = eventTypes.flights ? flights.length : 0;
            _entries = const [];
            _detailsLoaded = true;
            _entriesLoaded = false;
            _invalidateAnalysisCache();
            _firstFlightDate = range.$1;
            _lastFlightDate = range.$2;
          });
        }
        unawaited(_refreshAnalysisGroups());
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        if (_pendingOverviewLoad) {
          _pendingOverviewLoad = false;
          unawaited(_loadOverviewData());
        } else if (_pendingDetailsLoad) {
          final includeEntries = _pendingIncludeEntries;
          _pendingDetailsLoad = false;
          _pendingIncludeEntries = false;
          unawaited(
            _ensureDetailsLoaded(
              includeEntries: includeEntries,
            ),
          );
        }
      }
    }
  }

  void _persistRuntimeQuery() {
    ref
        .read(reportsRuntimeQueryProvider.notifier)
        .value = ReportsRuntimeQueryState(
      from: _from,
      to: _to,
      selectedPreset: _preset.name,
      matchMode: _filterMatchMode,
      filters: List<ReportsFilterCondition>.from(_filters),
    );
  }

  void _syncRangeTimeControllers() {
    _fromTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _from.hour * 60 + _from.minute,
    );
    _toTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _to.hour * 60 + _to.minute,
    );
  }

  _ReportDateRangePreset _presetFromName(String value) {
    for (final preset in _ReportDateRangePreset.values) {
      if (preset.name == value) {
        return preset;
      }
    }
    return _ReportDateRangePreset.sinceBeginning;
  }

  Future<void> _loadDetailed({
    required bool includeEntries,
  }) async {
    if (_from.isAfter(_to)) {
      setState(
        () => _error = AppLocalizations.of(context)!.reportsStartBeforeEndError,
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final includePreviousExperience = ref.read(
      includePreviousExperienceProvider,
    );
    final eventTypes = ref.read(reportsEventTypesProvider);

    try {
      final repo = ref.read(reportsRepositoryProvider);
      if (!includeEntries && _filters.isEmpty) {
        final totalsFuture = repo.loadQuickTotals(
          from: _from,
          to: _to,
          includePreviousExperience: includePreviousExperience,
        );
        final flightsFuture = eventTypes.flights
            ? repo.loadFlightsForAnalysis(
                from: _from,
                to: _to,
              )
            : Future.value(const <ReportsFlightRow>[]);
        final flightRangeFuture = repo.loadFlightDateRange(
          from: _from,
          to: _to,
        );

        final totals = await totalsFuture;
        final flights = await flightsFuture;
        final flightRange = await flightRangeFuture;
        final range = await _resolveDisplayedDateRange(
          baseRange: flightRange,
          includePreviousExperience: includePreviousExperience,
        );

        if (mounted) {
          setState(() {
            _data = ReportsData(
              totals: _applyTypeSelectionToTotals(totals, eventTypes),
              flights: flights,
            );
            _batchFlightCount = eventTypes.flights ? flights.length : 0;
            _entries = const [];
            _detailsLoaded = true;
            _entriesLoaded = false;
            _invalidateAnalysisCache();
            _firstFlightDate = range.$1;
            _lastFlightDate = range.$2;
          });
        }
        unawaited(_refreshAnalysisGroups());
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
        final flights = eventTypes.flights
            ? result.flights
            : const <ReportsFlightRow>[];
        final entries = includeEntries
            ? await _fetchEntriesForFlights(flights, eventTypes)
            : const <LogbookEntry>[];
        final baseRange = _flightRangeFromRows(flights);
        final range = await _resolveDisplayedDateRange(
          baseRange: baseRange,
          includePreviousExperience: includePreviousExperience,
        );
        if (mounted) {
          setState(() {
            _data = ReportsData(
              totals: _applyTypeSelectionToTotals(result.totals, eventTypes),
              flights: flights,
            );
            _batchFlightCount = eventTypes.flights ? flights.length : 0;
            _entries = entries;
            _detailsLoaded = true;
            _entriesLoaded = includeEntries;
            _invalidateAnalysisCache();
            _firstFlightDate = range.$1;
            _lastFlightDate = range.$2;
          });
        }
        unawaited(_refreshAnalysisGroups());
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        if (_pendingOverviewLoad) {
          _pendingOverviewLoad = false;
          unawaited(_loadOverviewData());
        }
      }
    }
  }

  Future<List<LogbookEntry>> _fetchEntriesForFlights(
    List<ReportsFlightRow> flights,
    ReportsEventTypesSelection eventTypes,
  ) async {
    return _fetchEntriesForRange(
      includedFlightIds: flights.map((flight) => flight.flightId).toSet(),
      eventTypes: eventTypes,
      from: _from,
      to: _to,
    );
  }

  Future<(DateTime?, DateTime?)> _resolveDisplayedDateRange({
    required (DateTime?, DateTime?) baseRange,
    required bool includePreviousExperience,
  }) async {
    if (!includePreviousExperience) {
      return baseRange;
    }
    final previousExperienceRange = await ref
        .read(reportsRepositoryProvider)
        .loadPreviousExperienceDateRange(from: _from, to: _to);
    return _mergeDateRanges(baseRange, previousExperienceRange);
  }

  (DateTime?, DateTime?) _mergeDateRanges(
    (DateTime?, DateTime?) left,
    (DateTime?, DateTime?) right,
  ) {
    final first = _minDate(left.$1, right.$1);
    final last = _maxDate(left.$2, right.$2);
    return (first, last);
  }

  DateTime? _minDate(DateTime? left, DateTime? right) {
    if (left == null) return right;
    if (right == null) return left;
    return left.isBefore(right) ? left : right;
  }

  DateTime? _maxDate(DateTime? left, DateTime? right) {
    if (left == null) return right;
    if (right == null) return left;
    return left.isAfter(right) ? left : right;
  }

  Future<List<LogbookEntry>> _fetchEntriesForRange({
    required Set<int>? includedFlightIds,
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
    if (eventTypes.flights &&
        includedFlightIds != null &&
        includedFlightIds.isEmpty) {
      return const [];
    }
    const pageSize = 500;
    var offset = 0;
    final filteredEntries = <LogbookEntry>[];
    final queryFlightIds =
        includedFlightIds != null && includedFlightIds.length <= 800
        ? includedFlightIds
        : null;
    while (true) {
      final page = await logbookUseCases.fetchLogbookPage(
        LogbookFilters(from: from, to: to, types: selectedTypes),
        limit: pageSize,
        offset: offset,
        includedFlightIds: queryFlightIds,
      );
      if (page.isEmpty) {
        break;
      }
      for (final entry in page) {
        if (entry.flight != null) {
          if (!eventTypes.flights) {
            continue;
          }
          if (includedFlightIds != null &&
              !includedFlightIds.contains(entry.flight!.id)) {
            continue;
          }
          filteredEntries.add(entry);
          continue;
        }
        if (entry.simulatorTraining != null) {
          if (eventTypes.simulator) {
            filteredEntries.add(entry);
          }
          continue;
        }
        if (entry.positioning != null) {
          if (eventTypes.positioning) {
            filteredEntries.add(entry);
          }
          continue;
        }
        if (entry.dutyStart != null || entry.dutyEnd != null) {
          if (eventTypes.duty) {
            filteredEntries.add(entry);
          }
        }
      }
      if (page.length < pageSize) {
        break;
      }
      offset += page.length;
      await Future<void>.delayed(Duration.zero);
    }
    return filteredEntries;
  }

  Future<void> _ensureDetailsLoaded({
    required bool includeEntries,
  }) async {
    if (_detailsLoaded && (!includeEntries || _entriesLoaded)) {
      return;
    }
    if (_loading) {
      _pendingDetailsLoad = true;
      _pendingIncludeEntries = _pendingIncludeEntries || includeEntries;
      return;
    }
    await _loadDetailed(
      includeEntries: includeEntries,
    );
  }

  Future<void> _onTabChanged(int index) async {
    if (index == 0) {
      await _ensureDetailsLoaded(
        includeEntries: true,
      );
    } else if (index == 1) {
      if (_loading) {
        _pendingOverviewLoad = true;
        return;
      }
      await _loadOverviewData();
    } else if (index == 2) {
      if (_filters.isEmpty) {
        if (_loading) {
          _pendingOverviewLoad = true;
          return;
        }
        await _loadOverviewData();
      } else {
        await _ensureDetailsLoaded(
          includeEntries: false,
        );
      }
      if (!mounted) return;
      await _refreshAnalysisGroups();
    } else if (index == 3) {
      // Reports tab does not require preloading analysis details.
      // Keep current analysis cache untouched to avoid transient empty states
      // when switching back to Analyses.
    } else if (index == 4) {
      if (_loading) {
        _pendingOverviewLoad = true;
        return;
      }
      await _loadOverviewData();
    }
  }

  Future<void> _primeBatchDataIfNeeded() async {
    if (!mounted) return;
    if (_batchFlightCount <= 0) return;
    if (_data.flights.isNotEmpty) return;
    if (_isPreparingBatchData) return;
    setState(() => _isPreparingBatchData = true);
    await Future<void>.delayed(Duration.zero);
    try {
      await _ensureDetailsLoaded(
        includeEntries: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isPreparingBatchData = false);
      }
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _from : _to;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.utc(current.year, current.month, current.day),
      firstDate: DateTime.utc(1970),
      lastDate: DateTime.utc(2100),
    );
    if (pickedDate == null || !mounted) return;

    final selectedUtc = DateTime.utc(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      current.hour,
      current.minute,
    );
    if (mounted) {
      setState(() {
        if (isStart) {
          _from = selectedUtc;
        } else {
          _to = selectedUtc;
        }
        _preset = _ReportDateRangePreset.custom;
      });
    }
    _syncRangeTimeControllers();
    _persistRuntimeQuery();
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
    }
  }

  Future<void> _onRangeTimeChanged({
    required bool isStart,
    required int minutesOfDay,
  }) async {
    final hour = (minutesOfDay ~/ 60) % 24;
    final minute = minutesOfDay % 60;
    if (!mounted) return;
    setState(() {
      if (isStart) {
        _from = DateTime.utc(_from.year, _from.month, _from.day, hour, minute);
      } else {
        _to = DateTime.utc(_to.year, _to.month, _to.day, hour, minute);
      }
      _preset = _ReportDateRangePreset.custom;
    });
    _persistRuntimeQuery();
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
    }
  }

  Future<void> _applyPreset(_ReportDateRangePreset preset) async {
    if (preset == _ReportDateRangePreset.custom) {
      await _pickDate(isStart: true);
      if (!mounted) return;
      await _pickDate(isStart: false);
      return;
    }

    final now = DateTime.now().toUtc();
    DateTime start;
    var end = now;

    switch (preset) {
      case _ReportDateRangePreset.sinceBeginning:
        start = DateTime.utc(1990);
      case _ReportDateRangePreset.last7Days:
        start = now.subtract(const Duration(days: 7));
      case _ReportDateRangePreset.last14Days:
        start = now.subtract(const Duration(days: 14));
      case _ReportDateRangePreset.last21Days:
        start = now.subtract(const Duration(days: 21));
      case _ReportDateRangePreset.last28Days:
        start = now.subtract(const Duration(days: 28));
      case _ReportDateRangePreset.last1Month:
        start = DateTime.utc(
          now.month == 1 ? now.year - 1 : now.year,
          now.month == 1 ? 12 : now.month - 1,
          now.day,
          now.hour,
          now.minute,
        );
      case _ReportDateRangePreset.last365Days:
        start = now.subtract(const Duration(days: 365));
      case _ReportDateRangePreset.currentMonth:
        start = DateTime.utc(now.year, now.month);
      case _ReportDateRangePreset.currentYear:
        start = DateTime.utc(now.year);
      case _ReportDateRangePreset.lastMonth:
        final monthStart = DateTime.utc(now.year, now.month);
        end = monthStart.subtract(const Duration(minutes: 1));
        start = DateTime.utc(end.year, end.month);
      case _ReportDateRangePreset.lastYear:
        start = DateTime.utc(now.year - 1);
        end = DateTime.utc(now.year - 1, 12, 31, 23, 59);
      case _ReportDateRangePreset.custom:
        return;
    }

    if (mounted) {
      setState(() {
        _preset = preset;
        _from = start;
        _to = end;
      });
    }
    _syncRangeTimeControllers();
    _persistRuntimeQuery();
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
    }
  }

  Future<void> _addFilter() async {
    final added = await showSmallDialogScreen<ReportsFilterCondition>(
      context: context,
      builder: (context) => const _AddFilterDialog(),
    );
    if (added == null || !mounted) return;
    if (mounted) {
      setState(() => _filters.add(added));
    }
    _persistRuntimeQuery();
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
    }
  }

  Future<void> _removeFilter(int index) async {
    if (index < 0 || index >= _filters.length) return;
    setState(() => _filters.removeAt(index));
    _persistRuntimeQuery();
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
    }
  }

  Future<void> _setMatchMode(ReportsFilterMatchMode mode) async {
    if (_filterMatchMode == mode) return;
    setState(() => _filterMatchMode = mode);
    _persistRuntimeQuery();
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
    }
  }

  Future<void> _setIncludePreviousExperience(bool value) async {
    await ref
        .read(includePreviousExperienceProvider.notifier)
        .setValue(value: value);
    if (!mounted) return;
    if (_isAnalysesVisible && _analysisSupportsPreviousExperience) {
      if (_detailsLoaded) {
        await _refreshAnalysisGroups();
      } else {
        await _ensureDetailsLoaded(
          includeEntries: false,
        );
      }
      return;
    }
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
      if (!mounted) return;
      if (_isAnalysesVisible) {
        await _ensureDetailsLoaded(
          includeEntries: false,
        );
      } else if (_isFlightsVisible) {
        await _ensureDetailsLoaded(
          includeEntries: true,
        );
      }
    }
  }

  Future<void> _setEventTypes(ReportsEventTypesSelection value) async {
    await ref.read(reportsEventTypesProvider.notifier).setValue(value);
    if (!mounted) return;
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
    }
  }

  Future<void> _saveCurrentQuery() async {
    final name = await showSmallDialogScreen<String>(
      context: context,
      builder: (context) => const _SaveQueryDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    final query = SavedReportsQuery(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      from: _from,
      to: _to,
      includePreviousExperience: false,
      filterMatchMode: _filterMatchMode,
      filters: List<ReportsFilterCondition>.from(_filters),
    );
    await ref.read(savedReportsQueriesProvider.notifier).addQuery(query);
    if (!mounted) return;
    await _showInfoDialog(
      AppLocalizations.of(context)!.reportsSavedQuery(query.name),
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
    _syncRangeTimeControllers();
    _persistRuntimeQuery();
    if (!mounted) return;
    if (!_isFiltersOnlySection) {
      await _loadOverviewData();
    }
  }

  Future<void> _deleteSavedQuery(String id) async {
    await ref.read(savedReportsQueriesProvider.notifier).removeQuery(id);
  }

  Future<void> _openMapDialog() async {
    final mapData = await _loadMapDataForCurrentQuery();
    if (!mounted) return;
    if (mapData.airports.isEmpty) {
      await _showInfoDialog(
        AppLocalizations.of(context)!.reportsNoFlightsInPeriod,
      );
      return;
    }
    await _presentAdaptiveShellDialog<void>(
      _FlightsMapDialog(
        mapData: mapData,
        fullscreen: true,
        initialShowLines: _showPathOnMap,
      ),
    );
  }

  Future<T?> _presentAdaptiveShellDialog<T>(Widget child) async {
    if (isCompactDialogScreen(context)) {
      return AppNavigator.pushMaterial<T>(
        context,
        (_) => child,
        rootNavigator: true,
      );
    }
    return showDialog<T>(
      context: context,
      builder: (_) => child,
    );
  }

  Future<void> _generatePdf() async {
    if (_isGeneratingPdf) {
      return;
    }
    var selectedTemplate = _selectedTemplate;
    selectedTemplate = await _resolveLatestSelectedTemplate(selectedTemplate);
    if (selectedTemplate == null) {
      if (!mounted) return;
      await _showInfoDialog(
        AppLocalizations.of(context)!.reportsNoTemplateAvailable,
      );
      return;
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await _setPdfGenerationProgress(l10n.reportsPdfPreparing, progress: 0.1);

    try {
      final templateConfig = selectedTemplate.template;
      final pdfService = ref.read(reportPdfApplicationServiceProvider);
      final pdfEventTypes = _eventTypesForPdf(
        ref.read(reportsEventTypesProvider),
      );
      Set<int>? includedFlightIds;
      if (pdfEventTypes.flights && _filters.isNotEmpty) {
        final flightsForPdf = await _loadFlightsForCurrentQuery(
          flightsEnabled: true,
        );
        includedFlightIds = flightsForPdf
            .map((flight) => flight.flightId)
            .toSet();
      }
      final entriesForPdf = await _fetchEntriesForRange(
        includedFlightIds: includedFlightIds,
        eventTypes: pdfEventTypes,
        from: _from,
        to: _to,
      );

      await _setPdfGenerationProgress(l10n.reportsPdfGenerating, progress: 0.5);
      final includeHoursBefore = ref.read(includeHoursBeforeProvider);
      final includePreviousExperience = ref.read(
        includePreviousExperienceProvider,
      );
      final needsCrewNames = _templateUsesCrewColumns(templateConfig);
      final crewMaps = needsCrewNames
          ? await _loadReportCrewNames(entriesForPdf)
          : const (
              <int, ReportEntryCrewNames>{},
              <int, ReportEntryCrewNames>{},
            );
      final startingTotals = includeHoursBefore
          ? await _loadStandardStartingTotals(
              pdfService,
              templateConfig.timeFormat,
            )
          : includePreviousExperience
          ? _templateTotalsFromReportsTotals(
              await ref
                  .read(reportsRepositoryProvider)
                  .loadAllPreviousExperienceTotals(),
            )
          : const ReportTemplateTotals();
      final bytes = await pdfService.generateFromTemplate(
        template: templateConfig,
        entries: entriesForPdf,
        startingTotals: startingTotals,
        coverValues: _buildCoverValues(
          template: templateConfig,
          entriesForPdf: entriesForPdf,
          startingTotals: startingTotals,
        ),
        coverImages: await _buildCoverImages(),
        flightCrewById: crewMaps.$1,
        simulatorCrewById: crewMaps.$2,
      );
      if (bytes.isEmpty) {
        throw StateError('Generated PDF is empty.');
      }

      await _setPdfGenerationProgress(l10n.reportsPdfSaving, progress: 0.85);
      final path = await _savePdfBytes(
        bytes: bytes,
        fileName: _buildPdfFileName(selectedTemplate),
      );
      if (!mounted) return;
      if (path == null) return;
      await _setPdfGenerationProgress(l10n.reportsPdfDone, progress: 1);
      final openPdfAfterSaving = ref.read(openPdfAfterSavingProvider);
      if (openPdfAfterSaving) {
        await _openExportedFile(path);
      } else {
        _showPdfExportToast(path);
      }
    } on Object catch (error, stackTrace) {
      debugPrint('PDF generation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      await _showInfoDialog(l10n.reportsPdfFailed(error.toString()));
    } finally {
      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        setState(() {
          _isGeneratingPdf = false;
          _pdfGenerationStatus = '';
          _pdfGenerationProgress = null;
        });
      }
    }
  }

  Future<_XslTemplateOption?> _resolveLatestSelectedTemplate(
    _XslTemplateOption? current,
  ) async {
    final selectedFileName =
        current?.fileName ??
        ref.read(selectedReportTemplateFileNameProvider) ??
        '';
    if (selectedFileName.isEmpty) {
      return current;
    }
    try {
      final db = ref.read(databaseProvider);
      final templates = await ReportXslTemplateLoader(db).load();
      final options = templates
          .map(
            (template) => _XslTemplateOption(
              fileName: template.fileName,
              description: template.displayName,
              numberOfLines: template.rowsPerPage,
              template: template,
            ),
          )
          .toList(growable: false);
      if (options.isEmpty) {
        return current;
      }
      final matched = options.where(
        (option) => option.fileName == selectedFileName,
      );
      final resolved = matched.isNotEmpty ? matched.first : options.first;
      if (mounted) {
        setState(() {
          _xslTemplateOptions = options;
          _selectedTemplate = resolved;
        });
      }
      return resolved;
    } on Object {
      return current;
    }
  }

  String _flightRowsQueryKey({
    required bool flightsEnabled,
  }) {
    final filtersKey = _filters
        .map(
          (condition) {
            final textValue = condition.textValue ?? '';
            final numberValue = condition.numberValue?.toString() ?? '';
            return '${condition.field.name}:${condition.operator.name}:'
                '$textValue:$numberValue';
          },
        )
        .join('|');
    final parts = <Object>[
      _from.microsecondsSinceEpoch,
      _to.microsecondsSinceEpoch,
      _filterMatchMode.name,
      if (flightsEnabled) '1' else '0',
      filtersKey,
    ];
    return parts.join('::');
  }

  String _mapDataQueryKey() {
    final filtersKey = _filters
        .map(
          (condition) {
            final textValue = condition.textValue ?? '';
            final numberValue = condition.numberValue?.toString() ?? '';
            return '${condition.field.name}:${condition.operator.name}:'
                '$textValue:$numberValue';
          },
        )
        .join('|');
    return <Object>[
      _from.microsecondsSinceEpoch,
      _to.microsecondsSinceEpoch,
      _filterMatchMode.name,
      filtersKey,
    ].join('::');
  }

  Future<ReportsMapData> _loadMapDataForCurrentQuery() async {
    final cacheKey = _mapDataQueryKey();
    if (_mapDataCacheKey == cacheKey) {
      return _mapDataCache;
    }
    final repo = ref.read(reportsRepositoryProvider);
    final mapData = await repo.loadMapData(
      ReportsQuery(
        from: _from,
        to: _to,
        includePreviousExperience: false,
        filterMatchMode: _filterMatchMode,
        filters: _filters,
      ),
    );
    _mapDataCacheKey = cacheKey;
    _mapDataCache = mapData;
    return mapData;
  }

  Future<List<ReportsFlightRow>> _loadFlightsForCurrentQuery({
    required bool flightsEnabled,
  }) async {
    if (!flightsEnabled) {
      return const [];
    }
    final cacheKey = _flightRowsQueryKey(flightsEnabled: flightsEnabled);
    if (_flightRowsCacheKey == cacheKey) {
      return _flightRowsCache;
    }
    final repo = ref.read(reportsRepositoryProvider);
    final List<ReportsFlightRow> flights;
    if (_filters.isEmpty) {
      flights = await repo.loadFlightsForAnalysis(from: _from, to: _to);
    } else {
      final result = await repo.load(
        ReportsQuery(
          from: _from,
          to: _to,
          includePreviousExperience: false,
          filterMatchMode: _filterMatchMode,
          filters: _filters,
        ),
      );
      flights = result.flights;
    }
    _flightRowsCacheKey = cacheKey;
    _flightRowsCache = flights;
    return flights;
  }

  bool _templateUsesCrewColumns(ReportPdfTemplate template) {
    const crewKeys = <String>{
      'picCrewName',
      'sicCrewName',
      'pilotPicName',
      'pilotSicName',
      'anyPIC',
      'anySIC',
      'flightPIC',
      'flightSIC',
      'simPIC',
      'simSIC',
    };
    for (final table in template.tables) {
      for (final column in table.columns) {
        if (crewKeys.contains(column.key)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _setPdfGenerationProgress(
    String status, {
    required double progress,
  }) async {
    if (!mounted) return;
    setState(() {
      _isGeneratingPdf = true;
      _pdfGenerationStatus = status;
      _pdfGenerationProgress = progress.clamp(0, 1);
    });
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  (DateTime?, DateTime?) _flightRangeFromRows(List<ReportsFlightRow> rows) {
    if (rows.isEmpty) return (null, null);
    var first = rows.first.departureDateTime;
    var last = rows.first.departureDateTime;
    for (final row in rows) {
      final value = row.departureDateTime;
      if (value.isBefore(first)) first = value;
      if (value.isAfter(last)) last = value;
    }
    return (first, last);
  }

  Future<void> _showInfoDialog(String message) async {
    if (!mounted) return;
    await showAppMessageDialog(context, message: message);
  }

  void _showPdfExportToast(String path) {
    final fileName = _fileNameFromPath(path);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: GestureDetector(
            onTap: messenger.hideCurrentSnackBar,
            behavior: HitTestBehavior.opaque,
            child: Text('Report exported: $fileName'),
          ),
        ),
      );
  }

  String _fileNameFromPath(String path) {
    final separator = Platform.pathSeparator;
    final index = path.lastIndexOf(separator);
    if (index < 0 || index + 1 >= path.length) return path;
    return path.substring(index + 1);
  }

  Future<void> _openExportedFile(String path) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [path]);
        return;
      }
      if (Platform.isWindows) {
        await Process.run('explorer', [path]);
        return;
      }
      if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
        return;
      }
      final uri = Uri.file(path);
      await launchUrl(uri);
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<ReportTemplateTotals> _loadStandardStartingTotals(
    ReportPdfApplicationService service,
    ReportPdfTimeFormat timeFormat,
  ) async {
    final cutoff = _from.subtract(const Duration(microseconds: 1));
    final firstDate = DateTime.utc(1970);
    if (cutoff.isBefore(firstDate)) {
      return const ReportTemplateTotals();
    }

    final repo = ref.read(reportsRepositoryProvider);
    final eventTypes = _eventTypesForPdf(ref.read(reportsEventTypesProvider));
    Set<int>? includedFlightIds;
    if (_filters.isNotEmpty && eventTypes.flights) {
      final beforeResult = await repo.load(
        ReportsQuery(
          from: firstDate,
          to: cutoff,
          includePreviousExperience: ref.read(
            includePreviousExperienceProvider,
          ),
          filterMatchMode: _filterMatchMode,
          filters: _filters,
        ),
      );
      includedFlightIds = beforeResult.flights
          .map((flight) => flight.flightId)
          .toSet();
    }

    final beforeEntries = await _fetchEntriesForRange(
      includedFlightIds: includedFlightIds,
      eventTypes: eventTypes,
      from: firstDate,
      to: cutoff,
    );
    var startingTotals = service.sumTotalsFromEntries(
      beforeEntries,
      timeFormat: timeFormat,
    );
    if (ref.read(includePreviousExperienceProvider)) {
      final previousTotals = await repo.loadAllPreviousExperienceTotals();
      startingTotals = startingTotals.addTotals(
        _templateTotalsFromReportsTotals(previousTotals),
      );
    }
    return startingTotals;
  }

  ReportsEventTypesSelection _eventTypesForPdf(
    ReportsEventTypesSelection eventTypes,
  ) {
    return eventTypes.copyWith(duty: false, positioning: false);
  }

  ReportTemplateTotals _templateTotalsFromReportsTotals(ReportsTotals totals) {
    final totalMinutes = totals.totalMinutes;
    final nightMinutes = totals.nightMinutes;
    final dayMinutes = math.max(0, totalMinutes - nightMinutes);
    return ReportTemplateTotals(
      ifrApproaches: totals.ifrApproaches,
      landingsTotal: totals.landingsDay + totals.landingsNight,
      xcMinutes: totals.crossCountryMinutes,
      dayMinutes: dayMinutes,
      nightMinutes: nightMinutes,
      ifrMinutes: totals.ifrMinutes,
      fstdMinutes: totals.simulatorMinutes,
      dualMinutes: totals.dualMinutes,
      picMinutes: totals.picMinutes,
      picusMinutes: totals.picusMinutes,
      picPicusMinutes: totals.picMinutes + totals.picusMinutes,
      sicMinutes: totals.sicMinutes,
      instructorMinutes: totals.instructorMinutes,
      totalMinutes: totalMinutes,
    );
  }

  Map<String, String> _buildCoverValues({
    required ReportPdfTemplate template,
    required List<LogbookEntry> entriesForPdf,
    required ReportTemplateTotals startingTotals,
  }) {
    final pilotInfo = ref.read(reportPilotInfoProvider);
    final dateFormat = DateFormat('MMMM d, yyyy');
    final fromDate = dateFormat.format(_from.toUtc());
    final toDate = dateFormat.format(_to.toUtc());
    final rangeLabel = '$fromDate to $toDate';
    final summaryTable = _buildCoverSummaryTable(
      template: template,
      entriesForPdf: entriesForPdf,
      startingTotals: startingTotals,
    );
    return {
      'pilot.name': pilotInfo.name,
      'pilot.licenses': pilotInfo.licenses,
      'pilot.licenceNumber': pilotInfo.licenses,
      'pilot.address': pilotInfo.address,
      'report.fromDate': dateFormat.format(_from.toUtc()),
      'report.toDate': dateFormat.format(_to.toUtc()),
      'report.rangeLabel': rangeLabel,
      'cover.summaryTable': summaryTable,
      'cover.certification':
          'I certify that statements made by me in this log book are true.',
    };
  }

  String _buildCoverSummaryTable({
    required ReportPdfTemplate template,
    required List<LogbookEntry> entriesForPdf,
    required ReportTemplateTotals startingTotals,
  }) {
    final byFamily = <String, _CoverFleetTotals>{};
    for (final entry in entriesForPdf) {
      final flight = entry.flight;
      if (flight == null) continue;
      final rawFamily = entry.aircraftType?.family ?? entry.aircraftType?.code;
      final family = (rawFamily ?? '').trim().toUpperCase();
      if (family.isEmpty) continue;
      byFamily.putIfAbsent(family, _CoverFleetTotals.new).addFlight(flight);
    }

    final familyRows = byFamily.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final logbookTotals = _CoverFleetTotals();
    for (final entry in familyRows) {
      logbookTotals.add(entry.value);
    }

    final totalBefore = _CoverFleetTotals.fromTemplateTotals(startingTotals);
    final grandTotal = _CoverFleetTotals.from(totalBefore)..add(logbookTotals);

    final columns = _resolveCoverSummaryColumns(template);
    String line(String name, _CoverFleetTotals totals) {
      return columns
          .map((column) => _coverSummaryCellValue(column.key, name, totals))
          .join('\t');
    }

    final header = columns.map((column) => column.label).join('\t');
    final lines = <String>[
      header,
      for (final row in familyRows) line(row.key, row.value),
      line('Total Before', totalBefore),
      line('Logbook Total', logbookTotals),
      line('Total', grandTotal),
    ];
    return lines.join('\n');
  }

  List<_CoverSummaryColumn> _resolveCoverSummaryColumns(
    ReportPdfTemplate template,
  ) {
    final block = template.coverPage?.blocks
        .where((b) => b.valueKey?.trim() == 'cover.summaryTable')
        .firstOrNull;
    if (block == null || block.items.isEmpty) {
      return _defaultCoverSummaryColumns;
    }
    final columns = block.items
        .map(
          (item) => _CoverSummaryColumn(
            key: item.valueKey.trim(),
            label: item.label.trim().isEmpty
                ? item.valueKey.trim().toUpperCase()
                : item.label.trim(),
          ),
        )
        .where((column) => _isSupportedCoverSummaryColumn(column.key))
        .toList(growable: false);
    return columns.isEmpty ? _defaultCoverSummaryColumns : columns;
  }

  bool _isSupportedCoverSummaryColumn(String key) {
    return const {
      'type',
      'night',
      'ifr',
      'pic',
      'picus',
      'picPicus',
      'sic',
      'dual',
      'instructor',
      'examiner',
      'total',
    }.contains(key);
  }

  String _coverSummaryCellValue(
    String key,
    String typeName,
    _CoverFleetTotals totals,
  ) {
    switch (key) {
      case 'type':
        return typeName;
      case 'night':
        return _formatMinutes(totals.night);
      case 'ifr':
        return _formatMinutes(totals.ifr);
      case 'pic':
        return _formatMinutes(totals.pic);
      case 'picus':
        return _formatMinutes(totals.picus);
      case 'picPicus':
        return _formatMinutes(totals.pic + totals.picus);
      case 'sic':
        return _formatMinutes(totals.sic);
      case 'dual':
        return _formatMinutes(totals.dual);
      case 'instructor':
        return _formatMinutes(totals.instructor);
      case 'examiner':
        return _formatMinutes(totals.examiner);
      case 'total':
        return _formatMinutes(totals.total);
      default:
        return '';
    }
  }

  Future<Map<String, Uint8List>> _buildCoverImages() async {
    Uint8List? signatureImage;
    try {
      final db = ref.read(databaseProvider);
      final profile = await db.select(db.userProfiles).getSingleOrNull();
      signatureImage = profile?.signatureImage;
    } on Object {
      signatureImage = null;
    }
    signatureImage ??= ref.read(reportPilotInfoProvider).signatureImage;
    if (signatureImage == null || signatureImage.isEmpty) {
      return const <String, Uint8List>{};
    }
    return <String, Uint8List>{
      'pilot.signatureImage': signatureImage,
      'anySignature': signatureImage,
      'flightSignature': signatureImage,
      'simSignature': signatureImage,
    };
  }

  Future<(Map<int, ReportEntryCrewNames>, Map<int, ReportEntryCrewNames>)>
  _loadReportCrewNames(List<LogbookEntry> entries) async {
    final flightIds = entries
        .map((entry) => entry.flight?.id)
        .whereType<int>()
        .toSet()
        .toList(growable: false);
    final simulatorIds = entries
        .map((entry) => entry.simulatorTraining?.id)
        .whereType<int>()
        .toSet()
        .toList(growable: false);

    final db = ref.read(databaseProvider);
    final flightMap = <int, ReportEntryCrewNames>{};
    final simulatorMap = <int, ReportEntryCrewNames>{};

    if (flightIds.isNotEmpty) {
      final rows = await (db.select(db.flightCrewAssignments).join([
        d.innerJoin(
          db.crew,
          db.crew.id.equalsExp(db.flightCrewAssignments.crewId),
        ),
      ])..where(db.flightCrewAssignments.flightId.isIn(flightIds))).get();
      for (final row in rows) {
        final assignment = row.readTable(db.flightCrewAssignments);
        final crew = row.readTable(db.crew);
        final current =
            flightMap[assignment.flightId] ?? const ReportEntryCrewNames();
        if (assignment.position == CrewPosition.pic && current.pic.isEmpty) {
          flightMap[assignment.flightId] = ReportEntryCrewNames(
            pic: crew.name,
            sic: current.sic,
          );
        } else if (assignment.position == CrewPosition.sic &&
            current.sic.isEmpty) {
          flightMap[assignment.flightId] = ReportEntryCrewNames(
            pic: current.pic,
            sic: crew.name,
          );
        }
      }
    }

    if (simulatorIds.isNotEmpty) {
      final rows =
          await (db.select(db.simulatorCrewAssignments).join([
                d.innerJoin(
                  db.crew,
                  db.crew.id.equalsExp(db.simulatorCrewAssignments.crewId),
                ),
              ])..where(
                db.simulatorCrewAssignments.simulatorId.isIn(simulatorIds),
              ))
              .get();
      for (final row in rows) {
        final assignment = row.readTable(db.simulatorCrewAssignments);
        final crew = row.readTable(db.crew);
        final current =
            simulatorMap[assignment.simulatorId] ??
            const ReportEntryCrewNames();
        if (assignment.position == CrewPosition.pic && current.pic.isEmpty) {
          simulatorMap[assignment.simulatorId] = ReportEntryCrewNames(
            pic: crew.name,
            sic: current.sic,
          );
        } else if (assignment.position == CrewPosition.sic &&
            current.sic.isEmpty) {
          simulatorMap[assignment.simulatorId] = ReportEntryCrewNames(
            pic: current.pic,
            sic: crew.name,
          );
        }
      }
    }

    return (flightMap, simulatorMap);
  }

  String _buildPdfFileName(_XslTemplateOption selectedTemplate) {
    final rawDescription = selectedTemplate.description.trim();
    final lower = rawDescription.toLowerCase();
    final reportTitle = switch (lower) {
      final value when value.contains('easa') => 'EASA',
      final value
          when value.contains('standard') || value.contains('jeppesen') =>
        'Standard',
      _ => rawDescription.isEmpty ? 'Report' : rawDescription,
    };
    var safeTitle = reportTitle
        .replaceAll(RegExp('[^a-zA-Z0-9]+'), '-')
        .replaceAll(RegExp('-+'), '-');
    while (safeTitle.startsWith('-')) {
      safeTitle = safeTitle.substring(1);
    }
    while (safeTitle.endsWith('-')) {
      safeTitle = safeTitle.substring(0, safeTitle.length - 1);
    }
    final datePart = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    return 'SimpleLog-$safeTitle $datePart.pdf';
  }

  Future<String?> _savePdfBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = Platform.isIOS || Platform.isAndroid;
    String? path;
    try {
      path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.reportsSavePdfDialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: isMobile ? bytes : null,
      );
    } on Object {
      // On some desktop providers saveFile may not be implemented.
      if (isMobile) {
        return null;
      }
      final directory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: l10n.reportsSavePdfDialogTitle,
      );
      if (directory == null || directory.isEmpty) {
        return null;
      }
      path = '$directory${Platform.pathSeparator}$fileName';
    }

    if (path == null || path.isEmpty) {
      return null;
    }

    if (isMobile) {
      try {
        final exportedFile = File(path);
        if (exportedFile.existsSync() && exportedFile.lengthSync() > 0) {
          return path;
        }
      } on Object catch (error, stackTrace) {
        Zone.current.handleUncaughtError(error, stackTrace);
      }
      final docsDir = await getApplicationDocumentsDirectory();
      final fallbackPath = '${docsDir.path}${Platform.pathSeparator}$fileName';
      await File(fallbackPath).writeAsBytes(bytes, flush: true);
      return fallbackPath;
    }

    try {
      await File(path).writeAsBytes(bytes, flush: true);
    } on FileSystemException {
      final docsDir = await getApplicationDocumentsDirectory();
      path = '${docsDir.path}${Platform.pathSeparator}$fileName';
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return path;
  }

  Future<void> _refreshAnalysisGroups() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final token = ++_analysisBuildToken;
    setState(() => _analysisLoading = true);
    final includePreviousExperience = ref.read(
      includePreviousExperienceProvider,
    );
    final bucketsKey = _analysisBucketsKey();

    if (_analysisBaseBucketsKey != bucketsKey) {
      if (_filters.isEmpty) {
        final rows = await ref
            .read(reportsRepositoryProvider)
            .loadFlightAnalysisAggregates(
              from: _from,
              to: _to,
              groupBy: _analysisGroupBy.toRepoGroupBy(),
              unknownAircraft: l10n.reportsUnknown,
              unknownType: l10n.reportsUnknownType,
              unknownFamily: l10n.reportsUnknownFamily,
              unknownAirport: l10n.reportsUnknownAirport,
            );
        if (!mounted || token != _analysisBuildToken) return;
        _analysisBaseBuckets = _aggregateBucketsFromRows(rows);
      } else {
        final groups = <String, _AnalysisGroupAccumulator>{};
        for (var i = 0; i < _data.flights.length; i++) {
          final flight = _data.flights[i];
          final keys = _analysisGroupKeysForFlight(flight, l10n);
          for (final key in keys) {
            final bucket = groups.putIfAbsent(
              key,
              _AnalysisGroupAccumulator.new,
            );
            if (_analysisGroupBy == _AnalysisGroupBy.airport) {
              bucket.addForAirport(
                flight,
                airportIcao: key,
                unknownAirportLabel: l10n.reportsUnknownAirport,
              );
            } else {
              bucket.add(flight);
            }
          }
          if (i % 250 == 0) {
            await Future<void>.delayed(Duration.zero);
            if (!mounted || token != _analysisBuildToken) return;
          }
        }
        _analysisBaseBuckets = groups;
      }
      _analysisBaseBucketsKey = bucketsKey;
      _analysisPreviousBuckets = const {};
      _analysisPreviousBucketsKey = '';
    }

    if (includePreviousExperience && _analysisSupportsPreviousExperience) {
      if (_analysisPreviousBucketsKey != bucketsKey) {
        if (_filters.isEmpty) {
          final previousRows = await ref
              .read(reportsRepositoryProvider)
              .loadPreviousExperienceAnalysisAggregates(
                from: _from,
                to: _to,
                groupBy: _analysisGroupBy.toRepoGroupBy(),
                unknownType: l10n.reportsUnknownType,
                unknownFamily: l10n.reportsUnknownFamily,
              );
          if (!mounted || token != _analysisBuildToken) return;
          _analysisPreviousBuckets = _aggregateBucketsFromRows(previousRows);
        } else {
          final previousRows = await ref
              .read(reportsRepositoryProvider)
              .loadPreviousExperienceForAnalysis(from: _from, to: _to);
          if (!mounted || token != _analysisBuildToken) return;
          final previousGroups = <String, _AnalysisGroupAccumulator>{};
          for (final row in previousRows) {
            final keys = _analysisGroupKeysForPreviousExperience(row, l10n);
            for (final key in keys) {
              previousGroups
                  .putIfAbsent(key, _AnalysisGroupAccumulator.new)
                  .addPreviousExperience(row);
            }
          }
          _analysisPreviousBuckets = previousGroups;
        }
        _analysisPreviousBucketsKey = bucketsKey;
      }
    }

    final groups = <String, _AnalysisGroupAccumulator>{
      for (final entry in _analysisBaseBuckets.entries)
        entry.key: entry.value.copy(),
    };
    if (includePreviousExperience && _analysisSupportsPreviousExperience) {
      for (final entry in _analysisPreviousBuckets.entries) {
        groups
            .putIfAbsent(entry.key, _AnalysisGroupAccumulator.new)
            .addAll(entry.value);
      }
    }

    final builtGroups =
        groups.entries
            .map(
              (entry) => _AnalysisGroup(title: entry.key, totals: entry.value),
            )
            .toList(growable: false)
          ..sort(_analysisSortCompare);

    if (!mounted || token != _analysisBuildToken) return;
    if (mounted) {
      setState(() {
        _analysisGroups = builtGroups;
        _analysisLoading = false;
      });
    }
  }

  Map<String, _AnalysisGroupAccumulator> _aggregateBucketsFromRows(
    List<ReportsAnalysisAggregateRow> rows,
  ) {
    final groups = <String, _AnalysisGroupAccumulator>{};
    for (final row in rows) {
      final key = row.groupKey.trim();
      if (key.isEmpty) continue;
      groups[key] = _AnalysisGroupAccumulator.fromAggregateRow(row);
    }
    return groups;
  }

  List<String> _analysisGroupKeysForFlight(
    ReportsFlightRow row,
    AppLocalizations l10n,
  ) {
    if (_analysisGroupBy == _AnalysisGroupBy.airport) {
      final keys = <String>{};
      final fromIcao = row.fromIcao.trim();
      final toIcao = row.toIcao.trim();
      if (fromIcao.isNotEmpty) {
        keys.add(fromIcao);
      }
      if (toIcao.isNotEmpty) {
        keys.add(toIcao);
      }
      if (keys.isEmpty) {
        return <String>[l10n.reportsUnknownAirport];
      }
      return keys.toList(growable: false);
    }

    return <String>[
      _analysisGroupBy.keyFor(
        row,
        unknownAircraft: l10n.reportsUnknown,
        unknownType: l10n.reportsUnknownType,
        unknownFamily: l10n.reportsUnknownFamily,
        unknownAirport: l10n.reportsUnknownAirport,
      ),
    ];
  }

  List<String> _analysisGroupKeysForPreviousExperience(
    ReportsPreviousExperienceRow row,
    AppLocalizations l10n,
  ) {
    switch (_analysisGroupBy) {
      case _AnalysisGroupBy.aircraft:
        return const <String>[];
      case _AnalysisGroupBy.type:
        final code = row.modelCode.trim();
        return <String>[
          if (code.isEmpty) l10n.reportsUnknownType else code,
        ];
      case _AnalysisGroupBy.family:
        final family = row.modelFamily.trim();
        return <String>[
          if (family.isEmpty) l10n.reportsUnknownFamily else family,
        ];
      case _AnalysisGroupBy.airport:
      case _AnalysisGroupBy.year:
      case _AnalysisGroupBy.month:
        return const <String>[];
    }
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
      flightMinutes: selection.flights ? totals.flightMinutes : 0,
      nightMinutes: selection.flights ? totals.nightMinutes : 0,
      ifrMinutes: selection.flights ? totals.ifrMinutes : 0,
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

  String _analysisGroupByLabel(AppLocalizations l10n, _AnalysisGroupBy value) {
    switch (value) {
      case _AnalysisGroupBy.aircraft:
        return l10n.reportsAnalyzeByAircraft;
      case _AnalysisGroupBy.type:
        return l10n.reportsAnalyzeByType;
      case _AnalysisGroupBy.family:
        return l10n.reportsAnalyzeByFamily;
      case _AnalysisGroupBy.airport:
        return l10n.reportsAnalyzeByAirport;
      case _AnalysisGroupBy.year:
        return l10n.reportsAnalyzeByYear;
      case _AnalysisGroupBy.month:
        return l10n.reportsAnalyzeByMonth;
    }
  }

  String _analysisOrderByLabel(AppLocalizations l10n, _AnalysisOrderBy value) {
    switch (value) {
      case _AnalysisOrderBy.natural:
        return l10n.reportsOrderByNatural;
      case _AnalysisOrderBy.hours:
        return l10n.reportsOrderByHours;
      case _AnalysisOrderBy.landings:
        return l10n.reportsOrderByLandings;
      case _AnalysisOrderBy.takeoff:
        return l10n.reportsOrderByTakeoff;
      case _AnalysisOrderBy.operations:
        return l10n.reportsOrderByOperations;
    }
  }

  int _naturalCompare(_AnalysisGroup a, _AnalysisGroup b) {
    if (_analysisGroupBy == _AnalysisGroupBy.year) {
      final yearA = int.tryParse(a.title) ?? -1;
      final yearB = int.tryParse(b.title) ?? -1;
      return yearB.compareTo(yearA);
    }
    if (_analysisGroupBy == _AnalysisGroupBy.month) {
      return b.title.compareTo(a.title);
    }
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  int _groupCompareByMetric(
    _AnalysisGroup a,
    _AnalysisGroup b, {
    required int Function(_AnalysisGroup group) selector,
  }) {
    final metricDiff = selector(b).compareTo(selector(a));
    if (metricDiff != 0) {
      return metricDiff;
    }
    return _naturalCompare(a, b);
  }

  int _analysisSortCompare(_AnalysisGroup a, _AnalysisGroup b) {
    switch (_analysisOrderBy) {
      case _AnalysisOrderBy.natural:
        return _naturalCompare(a, b);
      case _AnalysisOrderBy.hours:
        return _groupCompareByMetric(
          a,
          b,
          selector: (group) => group.totals.totalMinutes,
        );
      case _AnalysisOrderBy.landings:
        return _groupCompareByMetric(
          a,
          b,
          selector: (group) => group.totals.landings,
        );
      case _AnalysisOrderBy.takeoff:
        return _groupCompareByMetric(
          a,
          b,
          selector: (group) => group.totals.takeoffs,
        );
      case _AnalysisOrderBy.operations:
        return _groupCompareByMetric(
          a,
          b,
          selector: (group) => group.totals.operations,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final includePreviousExperience = ref.watch(
      includePreviousExperienceProvider,
    );
    final eventTypes = ref.watch(reportsEventTypesProvider);
    final savedQueries = ref.watch(savedReportsQueriesProvider);
    final customTimeLabels =
        ref.watch(customTimeLabelsProvider).valueOrNull ??
        const CustomTimeLabels();
    final logbookUseCases = ref.read(logbookUseCasesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 900 || constraints.maxHeight < 700;
        final section = widget.section;
        final showTabbedLayout = section == null;
        const horizontalPadding = 0.0;
        final verticalPadding = compact ? 8.0 : 16.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showTabbedLayout)
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
                    Tab(text: l10n.reportsTabBatch),
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
                child: showTabbedLayout
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          _buildFlightsSection(logbookUseCases),
                          _TotalsCard(
                            totals: _data.totals,
                            customTimeLabels: customTimeLabels,
                            firstFlightDate: _firstFlightDate,
                            lastFlightDate: _lastFlightDate,
                          ),
                          _buildAnalizesSection(
                            compact: compact,
                          ),
                          _buildReportsSection(compact: compact),
                          _buildBatchSection(compact: compact),
                        ],
                      )
                    : _buildPanelSection(
                        section: section,
                        compact: compact,
                        includePreviousExperience: includePreviousExperience,
                        eventTypes: eventTypes,
                        savedQueries: savedQueries,
                        customTimeLabels: customTimeLabels,
                        logbookUseCases: logbookUseCases,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanelSection({
    required ReportsPanelSection? section,
    required bool compact,
    required bool includePreviousExperience,
    required ReportsEventTypesSelection eventTypes,
    required List<SavedReportsQuery> savedQueries,
    required CustomTimeLabels customTimeLabels,
    required LogbookUseCases logbookUseCases,
  }) {
    switch (section) {
      case ReportsPanelSection.filters:
        return _buildFiltersSection(
          eventTypes: eventTypes,
          savedQueries: savedQueries,
          includePreviousExperience: includePreviousExperience,
          useOuterCardFrame: false,
        );
      case ReportsPanelSection.totals:
        return _TotalsCard(
          totals: _data.totals,
          customTimeLabels: customTimeLabels,
          firstFlightDate: _firstFlightDate,
          lastFlightDate: _lastFlightDate,
        );
      case ReportsPanelSection.analizes:
        return _buildAnalizesSection(
          compact: compact,
        );
      case ReportsPanelSection.reports:
        return _buildReportsSection(compact: compact);
      case ReportsPanelSection.batch:
        return _buildBatchSection(compact: compact);
      case ReportsPanelSection.flights:
        return _buildFlightsSection(logbookUseCases);
      case ReportsPanelSection.overview:
      case null:
        return _buildOverviewSection(
          compact: compact,
          includePreviousExperience: includePreviousExperience,
          eventTypes: eventTypes,
          savedQueries: savedQueries,
          customTimeLabels: customTimeLabels,
        );
    }
  }

  Widget _buildOverviewSection({
    required bool compact,
    required bool includePreviousExperience,
    required ReportsEventTypesSelection eventTypes,
    required List<SavedReportsQuery> savedQueries,
    required CustomTimeLabels customTimeLabels,
  }) {
    return Column(
      children: [
        _buildFiltersSection(
          eventTypes: eventTypes,
          savedQueries: savedQueries,
          includePreviousExperience: includePreviousExperience,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _TotalsCard(
            totals: _data.totals,
            customTimeLabels: customTimeLabels,
            firstFlightDate: _firstFlightDate,
            lastFlightDate: _lastFlightDate,
          ),
        ),
        const SizedBox(height: 10),
        _buildReportsControls(compact: compact),
      ],
    );
  }

  Widget _buildFiltersSection({
    required ReportsEventTypesSelection eventTypes,
    required List<SavedReportsQuery> savedQueries,
    required bool includePreviousExperience,
    bool useOuterCardFrame = true,
  }) {
    return _FiltersCard(
      from: _from,
      to: _to,
      fromTimeController: _fromTimeController,
      toTimeController: _toTimeController,
      preset: _preset,
      eventTypes: eventTypes,
      savedQueries: savedQueries,
      filters: _filters,
      matchMode: _filterMatchMode,
      includePreviousExperience: includePreviousExperience,
      onPresetChanged: _applyPreset,
      onPickStart: () => _pickDate(isStart: true),
      onPickEnd: () => _pickDate(isStart: false),
      onFromTimeChanged: (minutes) =>
          _onRangeTimeChanged(isStart: true, minutesOfDay: minutes),
      onToTimeChanged: (minutes) =>
          _onRangeTimeChanged(isStart: false, minutesOfDay: minutes),
      onEventTypesChanged: _setEventTypes,
      onMatchModeChanged: _setMatchMode,
      onAddFilter: _addFilter,
      onRemoveFilter: _removeFilter,
      onToggleIncludePreviousExperience: () {
        unawaited(
          _setIncludePreviousExperience(!includePreviousExperience),
        );
      },
      onSaveQuery: _saveCurrentQuery,
      onApplySavedQuery: _applySavedQuery,
      onDeleteSavedQuery: _deleteSavedQuery,
      useOuterCardFrame: useOuterCardFrame,
    );
  }

  Widget _buildFlightsSection(LogbookUseCases logbookUseCases) {
    return _EntriesPanel(
      entries: _entries,
      onEntryTap: (entry) {
        unawaited(
          LogbookEntryDialogs.show(
            context,
            entry: entry,
            useCases: logbookUseCases,
          ),
        );
      },
    );
  }

  Widget _buildAnalizesSection({
    required bool compact,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportsEnumDropdownField<_AnalysisGroupBy>(
                value: _analysisGroupBy,
                label: l10n.reportsAnalyzeByLabel,
                options: _analysisGroupByOptions,
                optionLabel: (value) => _analysisGroupByLabel(l10n, value),
                onChanged: (value) {
                  setState(() => _analysisGroupBy = value);
                  if (_detailsLoaded) {
                    unawaited(_refreshAnalysisGroups());
                  } else {
                    unawaited(
                      _ensureDetailsLoaded(
                        includeEntries: false,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ReportsEnumDropdownField<_AnalysisOrderBy>(
                value: _analysisOrderBy,
                label: l10n.reportsOrderByLabel,
                options: _AnalysisOrderBy.values.toList(growable: false),
                optionLabel: (value) => _analysisOrderByLabel(l10n, value),
                onChanged: (value) {
                  setState(() => _analysisOrderBy = value);
                  unawaited(_refreshAnalysisGroups());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_analysisLoading) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 10),
        ],
        Expanded(
          child: _AnalysisList(groups: _analysisGroups),
        ),
      ],
    );
  }

  Widget _buildReportsSection({required bool compact}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          child: _buildReportsControls(compact: compact),
        ),
      ),
    );
  }

  Future<void> _openPdfOptionsAndGenerate() async {
    if (_isGeneratingPdf) return;
    var openPdfAfterSaving = ref.read(openPdfAfterSavingProvider);
    var includeHoursBefore = ref.read(includeHoursBeforeProvider);
    var includePreviousExperience = ref.read(includePreviousExperienceProvider);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final shouldGenerate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return SizedBox(
              width: 460,
              child: AdaptiveFormShell(
                onClose: () => AppNavigator.pop(context, false),
                title: l10n.reportsPdfTitle,
                fullScreen: false,
                actions: [
                  TextButton(
                    onPressed: () => AppNavigator.pop(context, true),
                    child: Text(l10n.reportsGeneratePdf),
                  ),
                ],
                contentView: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile.adaptive(
                        value: openPdfAfterSaving,
                        title: Text(l10n.reportsOpenPdfAfterSaving),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setDialogState(() => openPdfAfterSaving = value);
                        },
                      ),
                      SwitchListTile.adaptive(
                        value: includeHoursBefore,
                        title: Text(l10n.reportsIncludeHoursBefore),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setDialogState(() => includeHoursBefore = value);
                        },
                      ),
                      SwitchListTile.adaptive(
                        value: includePreviousExperience,
                        title: Text(l10n.reportsPreviousExperienceLabel),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setDialogState(
                            () => includePreviousExperience = value,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Buttons(
                          onPressed: () =>
                              showPilotProfileEditorDialog(context),
                          icon: Icons.person_outline,
                          label: l10n.reportsEditPilotProfile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (shouldGenerate != true || !mounted) return;
    final openNotifier = ref.read(openPdfAfterSavingProvider.notifier);
    final hoursNotifier = ref.read(includeHoursBeforeProvider.notifier);
    final previousNotifier = ref.read(
      includePreviousExperienceProvider.notifier,
    );
    final currentOpenPdfAfterSaving = ref.read(openPdfAfterSavingProvider);
    final currentIncludeHoursBefore = ref.read(includeHoursBeforeProvider);
    final currentIncludePreviousExperience = ref.read(
      includePreviousExperienceProvider,
    );
    if (currentOpenPdfAfterSaving != openPdfAfterSaving) {
      await openNotifier.setValue(value: openPdfAfterSaving);
    }
    if (currentIncludeHoursBefore != includeHoursBefore) {
      await hoursNotifier.setValue(value: includeHoursBefore);
    }
    if (currentIncludePreviousExperience != includePreviousExperience) {
      await previousNotifier.setValue(value: includePreviousExperience);
    }
    if (!mounted) return;
    await _generatePdf();
  }

  Widget _buildReportsControls({required bool compact}) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final controlsTheme = Theme.of(context).extension<AppFormControlsTheme>();
    final addButtonSize = controlsTheme?.pickerAddButtonSize ?? 40;
    final addIconSize = controlsTheme?.pickerAddIconSize ?? 20;
    final addBorderRadius = controlsTheme?.pickerAddBorderRadius ?? 8;
    final addBorderColor = Theme.of(context).colorScheme.outline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReportsSectionCard(
          title: l10n.mapTitle,
          subtitle: l10n.reportsMapSectionSubtitle,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ReportsActionButton(
                    icon: Icons.map_outlined,
                    label: l10n.reportsShowMap,
                    onPressed: _isGeneratingPdf ? null : _openMapDialog,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: compact ? 132 : 180,
                  child: EventTypeToggleButton(
                    label: l10n.reportsShowPath,
                    selected: _showPathOnMap,
                    onTap: _isGeneratingPdf
                        ? () {}
                        : () =>
                              setState(() => _showPathOnMap = !_showPathOnMap),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ReportsSectionCard(
          title: l10n.reportsPdfGenerationTitle,
          subtitle: l10n.reportsPdfSectionSubtitle,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownInputField<_XslTemplateOption>(
                    key: ValueKey(
                      _selectedTemplate?.fileName ?? 'template_selector',
                    ),
                    label: l10n.reportsXmlTemplateLabel,
                    value: _selectedTemplate,
                    hintText: _xslTemplateOptions.isEmpty
                        ? l10n.reportsNoTemplateAvailable
                        : null,
                    items: _xslTemplateOptions
                        .map(
                          (template) => DropdownMenuItem<_XslTemplateOption>(
                            value: template,
                            child: _overflowText(template.description),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (_isGeneratingPdf) return;
                      if (value == null) return;
                      setState(() => _selectedTemplate = value);
                      unawaited(
                        ref
                            .read(
                              selectedReportTemplateFileNameProvider.notifier,
                            )
                            .setValue(value: value.fileName),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: l10n.reportsEditTemplates,
                  child: InkWell(
                    onTap: _isGeneratingPdf ? null : _openTemplateEditorDialog,
                    borderRadius: BorderRadius.circular(addBorderRadius),
                    child: Container(
                      width: addButtonSize,
                      height: addButtonSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: addBorderColor),
                        borderRadius: BorderRadius.circular(addBorderRadius),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.edit_outlined, size: addIconSize),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ReportsActionButton(
              icon: Icons.picture_as_pdf_outlined,
              label: _isGeneratingPdf
                  ? l10n.reportsGeneratingShort
                  : l10n.reportsGeneratePdf,
              onPressed: _isGeneratingPdf ? null : _openPdfOptionsAndGenerate,
              filled: true,
            ),
            if (_isGeneratingPdf) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: LinearProgressIndicator(
                      value: _pdfGenerationProgress,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _pdfGenerationStatus,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: onSurface),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBatchSection({required bool compact}) {
    final l10n = AppLocalizations.of(context)!;
    final filteredCount = _batchFlightCount;
    final actionsDisabled =
        filteredCount == 0 ||
        _isPreparingBatchData ||
        _isCheckingBatchFlights ||
        _isCalculatingBatchDuty;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportsSectionCard(
                title: l10n.reportsBatchTitle,
                subtitle: l10n.reportsBatchSubtitle,
                headerTrailing: InfoHelpButton(
                  title: l10n.reportsBatchHelpTitle,
                  message: l10n.reportsBatchHelpBody,
                ),
                children: [
                  Text(
                    l10n.reportsBatchWarning(filteredCount),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isCheckingBatchFlights) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                  if (_isPreparingBatchData) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(minHeight: 3),
                    const SizedBox(height: 6),
                    Text(l10n.reportsPreparingBatchData),
                  ],
                  if (_isCalculatingBatchDuty) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(minHeight: 3),
                    const SizedBox(height: 6),
                    Text(l10n.reportsCalculatingDutyPeriods),
                  ],
                  const SizedBox(height: 8),
                  _ReportsActionButton(
                    icon: _isCheckingBatchFlights
                        ? Icons.hourglass_top
                        : Icons.rule_folder_outlined,
                    label: _isCheckingBatchFlights
                        ? l10n.reportsCheckingShort
                        : l10n.reportsCheckFlights,
                    onPressed: actionsDisabled ? null : _checkBatchFlights,
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  _ReportsActionButton(
                    icon: Icons.groups_outlined,
                    label: l10n.reportsSetCrew,
                    onPressed: actionsDisabled ? null : _batchSetCrewSelf,
                  ),
                  const SizedBox(height: 8),
                  _ReportsActionButton(
                    icon: Icons.lock_outline,
                    label: l10n.reportsLock,
                    onPressed: actionsDisabled ? null : _batchSetLockStateTrue,
                  ),
                  const SizedBox(height: 8),
                  _ReportsActionButton(
                    icon: Icons.lock_open_outlined,
                    label: l10n.reportsUnlock,
                    onPressed: actionsDisabled ? null : _batchSetLockStateFalse,
                  ),
                  const SizedBox(height: 8),
                  _ReportsActionButton(
                    icon: Icons.calculate_outlined,
                    label: l10n.reportsCalculateAll,
                    onPressed: actionsDisabled ? null : _batchCalculateAll,
                  ),
                  const SizedBox(height: 8),
                  _ReportsActionButton(
                    icon: Icons.timelapse_outlined,
                    label: _isCalculatingBatchDuty
                        ? l10n.reportsCalculatingDutyShort
                        : l10n.reportsCalculateDuty,
                    onPressed: actionsDisabled
                        ? null
                        : _confirmAndBatchCalculateDuty,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkBatchFlights() async {
    if (_isCheckingBatchFlights) return;
    if (!mounted) return;
    final selectedChecks = await _BatchFlightChecksDialog.show(context);
    if (selectedChecks == null || selectedChecks.isEmpty) {
      return;
    }
    if (mounted) {
      setState(() => _isCheckingBatchFlights = true);
    }
    try {
      await _ensureBatchFlightsReadyForActions();
      final snapshots = await _loadBatchSnapshots(_filteredFlightIds());
      final issues = <String>[];
      String hhmm(int minutes) => TimeInputField.formatMinutes(minutes);
      final yieldStopwatch = Stopwatch()..start();
      for (final snapshot in snapshots.values) {
        if (yieldStopwatch.elapsedMicroseconds >= 16000) {
          await Future<void>.delayed(Duration.zero);
          yieldStopwatch.reset();
        }
        final block = snapshot.timeBlockMinutes;
        if (selectedChecks.contains(_BatchFlightCheck.timelineConsistency)) {
          if (snapshot.arrivalUtc != null &&
              snapshot.arrivalUtc!.isBefore(snapshot.departureUtc)) {
            issues.add(
              'Flight ${snapshot.id}: arrival is before departure.',
            );
          }
          if (block < 0 || snapshot.timeTotalBlockMinutes < 0) {
            issues.add('Flight ${snapshot.id}: negative block values.');
          }
          if (snapshot.fromIcao.trim().isEmpty ||
              snapshot.toIcao.trim().isEmpty) {
            issues.add('Flight ${snapshot.id}: missing airport ICAO.');
          }
        }
        final totalBlock = snapshot.timeTotalBlockMinutes;
        final takeoffs = snapshot.takeOffsDays + snapshot.takeOffsNight;
        final landings = snapshot.landingsDay + snapshot.landingsNight;
        final canonicalFunction = PilotFunctionLogic.canonicalize(
          snapshot.pilotFunction,
          takeoffCount: takeoffs,
          landingCount: landings,
        );
        if (snapshot.arrivalUtc != null &&
            (selectedChecks.contains(
              _BatchFlightCheck.chocksEqualsTotalBlock,
            ))) {
          final chocksBlock = snapshot.arrivalUtc!
              .difference(snapshot.departureUtc)
              .inMinutes;
          if (selectedChecks.contains(
                _BatchFlightCheck.chocksEqualsTotalBlock,
              ) &&
              chocksBlock >= 0 &&
              totalBlock != chocksBlock) {
            issues.add(
              'Flight ${snapshot.id}: chocks block (${hhmm(chocksBlock)}) '
              '!= Total Block (${hhmm(totalBlock)}).',
            );
          }
        }
        if (selectedChecks.contains(
              _BatchFlightCheck.flightElapsedMatchesTimes,
            ) &&
            snapshot.takeoffUtc != null &&
            snapshot.landingUtc != null) {
          final flightElapsed = snapshot.landingUtc!
              .difference(snapshot.takeoffUtc!)
              .inMinutes;
          if (flightElapsed >= 0 &&
              snapshot.timeFlightMinutes != flightElapsed) {
            issues.add(
              'Flight ${snapshot.id}: elapsed flight time '
              '(${hhmm(flightElapsed)}) != Flight time '
              '(${hhmm(snapshot.timeFlightMinutes)}).',
            );
          }
        }
        if (selectedChecks.contains(_BatchFlightCheck.crewTimesEqualBlock)) {
          final crewTotal =
              snapshot.timePICMinutes +
              snapshot.timePICUSMinutes +
              snapshot.timeSICMinutes +
              snapshot.timeDualMinutes;
          if (crewTotal != block) {
            issues.add(
              'Flight ${snapshot.id}: PIC+PICUS+SIC+Dual '
              '(${hhmm(crewTotal)}) != Block (${hhmm(block)}).',
            );
          }
        }
        if (selectedChecks.contains(_BatchFlightCheck.cappedTimesWithinBlock)) {
          final cappedFields = <(String, int)>[
            ('Night', snapshot.timeNightMinutes),
            ('IFR', snapshot.timeIFRMinutes),
            ('IFR', snapshot.timeIFRMinutes),
            ('CrossCountry', snapshot.timeCrossCountryMinutes),
            ('Flight', snapshot.timeFlightMinutes),
          ];
          for (final (label, minutes) in cappedFields) {
            if (minutes > block) {
              issues.add(
                'Flight ${snapshot.id}: $label time '
                '(${hhmm(minutes)}) is greater than Block (${hhmm(block)}).',
              );
            }
          }
        }
        if (selectedChecks.contains(
          _BatchFlightCheck.customTimesWithinTotalBlock,
        )) {
          final customCappedFields = <(String, int)>[
            ('Custom1', snapshot.timeCustom1Minutes),
            ('Custom2', snapshot.timeCustom2Minutes),
            ('Custom3', snapshot.timeCustom3Minutes),
            ('Custom4', snapshot.timeCustom4Minutes),
          ];
          for (final (label, minutes) in customCappedFields) {
            if (minutes > totalBlock) {
              issues.add(
                'Flight ${snapshot.id}: $label time '
                '(${hhmm(minutes)}) is greater than '
                'Total Block (${hhmm(totalBlock)}).',
              );
            }
          }
        }
        if (selectedChecks.contains(_BatchFlightCheck.distanceValidation)) {
          if (snapshot.distanceNm < 0) {
            issues.add('Flight ${snapshot.id}: negative distance.');
          } else if (snapshot.fromLatitude != null &&
              snapshot.fromLongitude != null &&
              snapshot.toLatitude != null &&
              snapshot.toLongitude != null &&
              (snapshot.fromIcao != snapshot.toIcao) &&
              snapshot.distanceNm > 0) {
            final calcDistance = FlightCalculations(
              latDep: snapshot.fromLatitude!,
              longDep: snapshot.fromLongitude!,
              latArr: snapshot.toLatitude!,
              longArr: snapshot.toLongitude!,
              depTimeEpochSeconds:
                  snapshot.departureUtc.millisecondsSinceEpoch ~/ 1000,
              arrTimeEpochSeconds:
                  (snapshot.arrivalUtc ?? snapshot.departureUtc)
                      .millisecondsSinceEpoch ~/
                  1000,
            ).flightDistanceNm.round();
            final diff = (snapshot.distanceNm - calcDistance).abs();
            final tolerance = math.max(30, (calcDistance * 0.4).round());
            if (diff > tolerance) {
              issues.add(
                'Flight ${snapshot.id}: distance seems incorrect '
                '(stored ${snapshot.distanceNm}nm, '
                'great-circle ${calcDistance}nm).',
              );
            }
          }
        }
        if (selectedChecks.contains(_BatchFlightCheck.pilotFunctionPattern)) {
          final patternOk = PilotFunctionLogic.matchesTakeoffLandingPattern(
            canonicalFunction,
            takeoffCount: takeoffs,
            landingCount: landings,
          );
          if (!patternOk) {
            issues.add(
              'Flight ${snapshot.id}: takeoff/landing mismatch for '
              '$canonicalFunction (takeoffs=$takeoffs, landings=$landings; '
              '${PilotFunctionLogic.takeoffLandingRule(canonicalFunction)}).',
            );
          }
        }
      }
      await _showBatchIssues(issues);
    } finally {
      if (mounted) {
        setState(() => _isCheckingBatchFlights = false);
      }
    }
  }

  Future<void> _batchSetCrewSelf() async {
    final db = ref.read(databaseProvider);
    final selfCrew = await (db.select(
      db.crew,
    )..where((t) => t.isSelf.equals(true))).getSingleOrNull();
    if (selfCrew == null) {
      await _showInfoDialog('Select one crew member as self first.');
      return;
    }
    if (!mounted) return;
    var selectedPosition = CrewPosition.pic;
    final selected = await showDialog<CrewPosition>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => SizedBox(
          width: 420,
          child: AdaptiveFormShell(
            onClose: () => AppNavigator.pop(context),
            title: AppLocalizations.of(context)!.reportsSetCrew,
            fullScreen: false,
            actions: [
              TextButton(
                onPressed: () => AppNavigator.pop(context, selectedPosition),
                child: Text(AppLocalizations.of(context)!.applyAction),
              ),
            ],
            contentView: Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownInputField<CrewPosition>(
                label: AppLocalizations.of(context)!.crewPositionLabel,
                value: selectedPosition,
                items: [
                  DropdownMenuItem(
                    value: CrewPosition.pic,
                    child: Text(AppLocalizations.of(context)!.crewPositionPic),
                  ),
                  DropdownMenuItem(
                    value: CrewPosition.sic,
                    child: Text(AppLocalizations.of(context)!.crewPositionSic),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setStateDialog(() => selectedPosition = value);
                },
              ),
            ),
          ),
        ),
      ),
    );
    if (selected == null) return;
    final finalPosition = selected;
    await _runGuardedBatchWrite(() async {
      await _ensureBatchFlightsReadyForActions();
      final snapshots = await _loadBatchSnapshots(_filteredFlightIds());
      final modifiable = _unlockedBatchSnapshots(snapshots);
      final skippedLocked = snapshots.length - modifiable.length;
      if (modifiable.isEmpty) {
        await _showInfoDialog('All filtered flights are locked.');
        return;
      }
      await db.transaction(() async {
        for (final id in modifiable.keys) {
          await (db.delete(db.flightCrewAssignments)..where(
                (t) => t.flightId.equals(id) & t.crewId.equals(selfCrew.id),
              ))
              .go();
          await db
              .into(db.flightCrewAssignments)
              .insert(
                FlightCrewAssignmentsCompanion.insert(
                  flightId: id,
                  crewId: selfCrew.id,
                  position: finalPosition,
                ),
              );
        }
      });
      await _showInfoDialog(
        'Set self crew as ${finalPosition.name.toUpperCase()} '
        'for ${modifiable.length} flights.${_lockedSkipSuffix(skippedLocked)}',
      );
    });
  }

  Future<void> _batchCalculateAll() async {
    if (!mounted) return;
    final initialPreferences = await _loadBatchCalculateAllPreferences();
    if (!mounted) return;
    final selection = await _BatchCalculateAllDialog.show(
      context,
      initialPreferences: initialPreferences,
    );
    if (selection == null) return;
    await _runGuardedBatchWrite(() async {
      await _saveBatchCalculateAllPreferences(selection);
      await _ensureBatchFlightsReadyForActions();
      final snapshots = await _loadBatchSnapshots(_filteredFlightIds());
      final modifiable = _unlockedBatchSnapshots(snapshots);
      final skippedLocked = snapshots.length - modifiable.length;
      if (modifiable.isEmpty) {
        await _showInfoDialog('All filtered flights are locked.');
        return;
      }
      final settings = await ref.read(flightFactoringSettingsProvider.future);
      final changes = <_BatchFlightChange>[];
      final db = ref.read(databaseProvider);
      await db.transaction(() async {
        for (final snapshot in modifiable.values) {
          final next = snapshot.copy();
          final blockMode = selection.modeFor(_BatchCalcField.block);
          if (blockMode == _BatchFieldMode.recalculate) {
            final calculatedBlock = _calculateBlockMinutesFromChocks(snapshot);
            if (calculatedBlock != null) {
              next
                ..timeBlockMinutes = calculatedBlock
                ..timeTotalBlockMinutes = calculatedBlock;
            }
          } else if (blockMode == _BatchFieldMode.setZero) {
            next
              ..timeBlockMinutes = 0
              ..timeTotalBlockMinutes = 0;
          }
          final base = next.timeBlockMinutes;

          _applyTimeMode(
            mode: selection.modeFor(_BatchCalcField.instructor),
            recalculateValue: base,
            assign: (value) => next.timeInstructorMinutes = value,
          );
          _applyTimeMode(
            mode: selection.modeFor(_BatchCalcField.ifr),
            recalculateValue: base,
            assign: (value) => next.timeIFRMinutes = value,
          );
          _applyTimeMode(
            mode: selection.modeFor(_BatchCalcField.ifr),
            recalculateValue: base,
            assign: (value) => next.timeIFRMinutes = value,
          );
          _applyTimeMode(
            mode: selection.modeFor(_BatchCalcField.flight),
            recalculateValue: base,
            assign: (value) => next.timeFlightMinutes = value,
          );

          final distanceMode = selection.modeFor(_BatchCalcField.distanceNm);
          if (distanceMode == _BatchFieldMode.recalculate) {
            final distance = _calculateDistanceForSnapshot(snapshot);
            if (distance != null) {
              next.distanceNm = distance;
            }
          } else if (distanceMode == _BatchFieldMode.setZero) {
            next.distanceNm = 0;
          }

          final crossMode = selection.modeFor(_BatchCalcField.crossCountry);
          if (crossMode == _BatchFieldMode.recalculate) {
            next.timeCrossCountryMinutes =
                next.distanceNm >= settings.crossCountryThresholdNm ? base : 0;
          } else if (crossMode == _BatchFieldMode.setZero) {
            next.timeCrossCountryMinutes = 0;
          }

          final applyNightDerivedValues =
              selection.modeFor(_BatchCalcField.night) ==
                  _BatchFieldMode.recalculate ||
              selection.modeFor(_BatchCalcField.takeoffDay) ==
                  _BatchFieldMode.recalculate ||
              selection.modeFor(_BatchCalcField.takeoffNight) ==
                  _BatchFieldMode.recalculate ||
              selection.modeFor(_BatchCalcField.landingDay) ==
                  _BatchFieldMode.recalculate ||
              selection.modeFor(_BatchCalcField.landingNight) ==
                  _BatchFieldMode.recalculate;
          if (applyNightDerivedValues) {
            final calc = _calculateNightForSnapshot(snapshot);
            if (calc != null) {
              if (selection.modeFor(_BatchCalcField.night) ==
                  _BatchFieldMode.recalculate) {
                next.timeNightMinutes = calc.nightMinutes;
              }
              if (selection.modeFor(_BatchCalcField.takeoffDay) ==
                  _BatchFieldMode.recalculate) {
                next.takeOffsDays = calc.takeoffsDay;
              }
              if (selection.modeFor(_BatchCalcField.takeoffNight) ==
                  _BatchFieldMode.recalculate) {
                next.takeOffsNight = calc.takeoffsNight;
              }
              if (selection.modeFor(_BatchCalcField.landingDay) ==
                  _BatchFieldMode.recalculate) {
                next.landingsDay = calc.landingsDay;
              }
              if (selection.modeFor(_BatchCalcField.landingNight) ==
                  _BatchFieldMode.recalculate) {
                next.landingsNight = calc.landingsNight;
              }
            }
          }

          if (selection.modeFor(_BatchCalcField.night) ==
              _BatchFieldMode.setZero) {
            next.timeNightMinutes = 0;
          }
          if (selection.modeFor(_BatchCalcField.takeoffDay) ==
              _BatchFieldMode.setZero) {
            next.takeOffsDays = 0;
          }
          if (selection.modeFor(_BatchCalcField.takeoffNight) ==
              _BatchFieldMode.setZero) {
            next.takeOffsNight = 0;
          }
          if (selection.modeFor(_BatchCalcField.landingDay) ==
              _BatchFieldMode.setZero) {
            next.landingsDay = 0;
          }
          if (selection.modeFor(_BatchCalcField.landingNight) ==
              _BatchFieldMode.setZero) {
            next.landingsNight = 0;
          }

          _applyTimeMode(
            mode: selection.modeFor(_BatchCalcField.custom1),
            recalculateValue: base,
            assign: (value) => next.timeCustom1Minutes = value,
          );
          _applyTimeMode(
            mode: selection.modeFor(_BatchCalcField.custom2),
            recalculateValue: base,
            assign: (value) => next.timeCustom2Minutes = value,
          );
          _applyTimeMode(
            mode: selection.modeFor(_BatchCalcField.custom3),
            recalculateValue: base,
            assign: (value) => next.timeCustom3Minutes = value,
          );
          _applyTimeMode(
            mode: selection.modeFor(_BatchCalcField.custom4),
            recalculateValue: base,
            assign: (value) => next.timeCustom4Minutes = value,
          );
          final fieldChanges = _buildBatchFieldChanges(snapshot, next);
          if (fieldChanges.isEmpty) continue;
          changes.add(
            _BatchFlightChange(snapshot: snapshot, fields: fieldChanges),
          );
          await _updateFlightFromSnapshot(next);
        }
      });
      await _showBatchChanges(changes);
      if (skippedLocked > 0) {
        await _showInfoDialog(
          'Skipped $skippedLocked locked flight'
          '${skippedLocked == 1 ? '' : 's'}.',
        );
      }
      await _ensureDetailsLoaded(
        includeEntries: false,
      );
    });
  }

  Future<void> _batchCalculateDuty() async {
    if (_isCalculatingBatchDuty) return;
    if (!mounted) return;
    setState(() => _isCalculatingBatchDuty = true);
    try {
      await _runGuardedBatchWrite(() async {
        final eventTypes = ref
            .read(reportsEventTypesProvider)
            .copyWith(
              duty: false,
            );
        final includedFlightIds = _filters.isEmpty
            ? null
            : _filteredFlightIds();
        final entries = await _fetchEntriesForRange(
          includedFlightIds: includedFlightIds,
          eventTypes: eventTypes,
          from: _from,
          to: _to,
        );

        final flightIds = <int>{};
        final nonFlightTimelineIds = <int>{};
        for (final entry in entries) {
          if (entry.flight case final flight?) {
            flightIds.add(flight.id);
            continue;
          }
          if (entry.positioning != null || entry.simulatorTraining != null) {
            nonFlightTimelineIds.add(entry.timeLine.id);
          }
        }

        if (flightIds.isEmpty && nonFlightTimelineIds.isEmpty) {
          await _showInfoDialog(
            'No filtered flight, positioning, or simulator entries found.',
          );
          return;
        }
        final settings = await ref.read(dutyRulesSettingsProvider.future);
        final result = await ref
            .read(logbookUseCasesProvider)
            .calculateDutyForFlights(
              flightIds: flightIds,
              nonFlightTimelineIds: nonFlightTimelineIds,
              rules: DutyCalculationRules(
                crewHomeBaseAirportId: settings.crewHomeBaseAirportId,
                reportingTimeOnBaseMinutes: settings.reportingTimeOnBaseMinutes,
                reportingTimeOffBaseMinutes:
                    settings.reportingTimeOffBaseMinutes,
                dutyEndTimeAllowanceMinutes:
                    settings.dutyEndTimeAllowanceMinutes,
                minimumRestTimeMinutes: settings.minimumRestTimeMinutes,
              ),
            );
        if (!mounted) return;
        final message = StringBuffer()
          ..write(
            'Duty calculation completed.\n'
            'Created: ${result.created}, '
            'Updated: ${result.updated}, '
            'Unchanged: ${result.unchanged}.',
          );
        if (result.skippedLockedDuty > 0) {
          message.write(
            '\nSkipped locked duties: ${result.skippedLockedDuty}.',
          );
        }
        if (result.skippedMissingTargetEvent > 0) {
          message.write(
            '\nSkipped filtered entries without a resolved operational event: '
            '${result.skippedMissingTargetEvent}.',
          );
        }
        await _showInfoDialog(message.toString());
        await _ensureDetailsLoaded(
          includeEntries: false,
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isCalculatingBatchDuty = false);
      }
    }
  }

  Future<void> _confirmAndBatchCalculateDuty() async {
    if (!mounted) return;
    final count = _batchFlightCount;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ReportsConfirmActionDialog(
        title: AppLocalizations.of(context)!.reportsCalculateDutyConfirmTitle,
        actionLabel: AppLocalizations.of(context)!.reportsCalculateAction,
        message: AppLocalizations.of(context)!.reportsCalculateDutyConfirmBody(
          count,
        ),
      ),
    );
    if (confirmed != true) return;
    await _batchCalculateDuty();
  }

  List<_BatchCalcField> get _batchCalcFieldOrder => const [
    _BatchCalcField.block,
    _BatchCalcField.ifr,
    _BatchCalcField.crossCountry,
    _BatchCalcField.distanceNm,
    _BatchCalcField.flight,
    _BatchCalcField.night,
    _BatchCalcField.takeoffDay,
    _BatchCalcField.takeoffNight,
    _BatchCalcField.landingDay,
    _BatchCalcField.landingNight,
    _BatchCalcField.instructor,
    _BatchCalcField.custom1,
    _BatchCalcField.custom2,
    _BatchCalcField.custom3,
    _BatchCalcField.custom4,
  ];

  Future<_BatchCalculateAllPreferences>
  _loadBatchCalculateAllPreferences() async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    final settings = await store.load();
    final raw = settings[_batchCalculateAllPreferencesKey];
    if (raw is Map<String, dynamic>) {
      return _BatchCalculateAllPreferences.fromJson(
        raw,
        fallbackFields: _batchCalcFieldOrder,
      );
    }
    final checks = await ref.read(flightFormTimeChecksProvider.future);
    return _batchPreferencesFromFlightChecks(checks);
  }

  Future<void> _saveBatchCalculateAllPreferences(
    _BatchCalculateAllPreferences preferences,
  ) async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    await store.patch(
      (json) => json[_batchCalculateAllPreferencesKey] = preferences.toJson(),
    );
  }

  _BatchCalculateAllPreferences _batchPreferencesFromFlightChecks(
    FlightFormTimeChecks checks,
  ) {
    final modes = <_BatchCalcField, _BatchFieldMode>{
      for (final field in _batchCalcFieldOrder)
        field: _BatchFieldMode.dontChange,
    };
    if (checks.ifr) modes[_BatchCalcField.ifr] = _BatchFieldMode.recalculate;
    if (checks.crossCountry) {
      modes[_BatchCalcField.crossCountry] = _BatchFieldMode.recalculate;
    }
    if (checks.night) {
      modes[_BatchCalcField.night] = _BatchFieldMode.recalculate;
    }
    if (checks.instructor) {
      modes[_BatchCalcField.instructor] = _BatchFieldMode.recalculate;
    }
    if (checks.custom1) {
      modes[_BatchCalcField.custom1] = _BatchFieldMode.recalculate;
    }
    if (checks.custom2) {
      modes[_BatchCalcField.custom2] = _BatchFieldMode.recalculate;
    }
    if (checks.custom3) {
      modes[_BatchCalcField.custom3] = _BatchFieldMode.recalculate;
    }
    if (checks.custom4) {
      modes[_BatchCalcField.custom4] = _BatchFieldMode.recalculate;
    }
    return _BatchCalculateAllPreferences(
      fieldModes: modes,
    );
  }

  void _applyTimeMode({
    required _BatchFieldMode mode,
    required int recalculateValue,
    required void Function(int value) assign,
  }) {
    if (mode == _BatchFieldMode.recalculate) {
      assign(recalculateValue);
    } else if (mode == _BatchFieldMode.setZero) {
      assign(0);
    }
  }

  int? _calculateDistanceForSnapshot(_BatchFlightSnapshot snapshot) {
    if (snapshot.fromLatitude == null ||
        snapshot.fromLongitude == null ||
        snapshot.toLatitude == null ||
        snapshot.toLongitude == null) {
      return null;
    }
    return FlightCalculations(
      latDep: snapshot.fromLatitude!,
      longDep: snapshot.fromLongitude!,
      latArr: snapshot.toLatitude!,
      longArr: snapshot.toLongitude!,
      depTimeEpochSeconds: snapshot.departureUtc.millisecondsSinceEpoch ~/ 1000,
      arrTimeEpochSeconds:
          (snapshot.arrivalUtc ?? snapshot.departureUtc)
              .millisecondsSinceEpoch ~/
          1000,
    ).flightDistanceNm.round();
  }

  int? _calculateBlockMinutesFromChocks(_BatchFlightSnapshot snapshot) {
    final arrival = snapshot.arrivalUtc;
    if (arrival == null) return null;
    final diffMinutes = arrival.difference(snapshot.departureUtc).inMinutes;
    return diffMinutes < 0 ? 0 : diffMinutes;
  }

  Future<void> _batchSetLockStateTrue() async {
    await _batchSetLockState(lockState: true);
  }

  Future<void> _batchSetLockStateFalse() async {
    await _batchSetLockState(lockState: false);
  }

  Future<void> _batchSetLockState({required bool lockState}) async {
    final targets = await _loadBatchLockTargets(lockState: lockState);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final targetCount = targets.totalCount;
    if (targetCount == 0) return;
    if (targets.flightIds.isEmpty &&
        targets.simulatorIds.isEmpty &&
        targets.positioningIds.isEmpty &&
        targets.dutyIds.isEmpty) {
      await _showInfoDialog(
        lockState
            ? l10n.reportsAllEntriesAlreadyLocked
            : l10n.reportsAllEntriesAlreadyUnlocked,
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ReportsConfirmActionDialog(
        title: lockState
            ? AppLocalizations.of(context)!.reportsLockEntriesConfirmTitle
            : AppLocalizations.of(context)!.reportsUnlockEntriesConfirmTitle,
        actionLabel: lockState
            ? AppLocalizations.of(context)!.reportsLock
            : AppLocalizations.of(context)!.reportsUnlock,
        message: lockState
            ? AppLocalizations.of(context)!.reportsLockFilteredEntriesMessage(
                targets.changeCount,
              )
            : AppLocalizations.of(context)!.reportsUnlockFilteredEntriesMessage(
                targets.changeCount,
              ),
      ),
    );
    if (confirmed != true) return;
    await _runGuardedBatchWrite(() async {
      final db = ref.read(databaseProvider);
      var updatedFlights = 0;
      var updatedSimulators = 0;
      var updatedPositionings = 0;
      var updatedDuty = 0;
      await db.transaction(() async {
        if (targets.flightIds.isNotEmpty) {
          updatedFlights =
              await (db.update(db.flights)
                    ..where((t) => t.id.isIn(targets.flightIds)))
                  .write(FlightsCompanion(isLocked: d.Value(lockState)));
        }
        if (targets.simulatorIds.isNotEmpty) {
          updatedSimulators =
              await (db.update(
                db.simulatorTrainings,
              )..where((t) => t.id.isIn(targets.simulatorIds))).write(
                SimulatorTrainingsCompanion(isLocked: d.Value(lockState)),
              );
        }
        if (targets.positioningIds.isNotEmpty) {
          updatedPositionings =
              await (db.update(db.positionings)
                    ..where((t) => t.id.isIn(targets.positioningIds)))
                  .write(PositioningsCompanion(isLocked: d.Value(lockState)));
        }
        if (targets.dutyIds.isNotEmpty) {
          updatedDuty =
              await (db.update(db.dutyPeriods)
                    ..where((t) => t.id.isIn(targets.dutyIds)))
                  .write(DutyPeriodsCompanion(isLocked: d.Value(lockState)));
        }
      });
      final updatedTotal =
          updatedFlights +
          updatedSimulators +
          updatedPositionings +
          updatedDuty;
      await _showInfoDialog(
        '${lockState ? 'Locked' : 'Unlocked'} $updatedTotal entries '
        '(Flights: $updatedFlights, Sim: $updatedSimulators, '
        'Positioning: $updatedPositionings, Duty: $updatedDuty).',
      );
      await _ensureDetailsLoaded(
        includeEntries: false,
      );
    });
  }

  Future<T> _runGuardedBatchWrite<T>(Future<T> Function() action) async {
    final guard = ref.read(batchWriteGuardControllerProvider.notifier)..enter();
    try {
      return await action();
    } finally {
      guard.exit();
    }
  }

  Set<int> _filteredFlightIds() {
    return _data.flights.map((row) => row.flightId).toSet();
  }

  Future<void> _ensureBatchFlightsReadyForActions() async {
    if (_batchFlightCount <= 0) return;
    if (_data.flights.isNotEmpty) return;
    await _primeBatchDataIfNeeded();
  }

  Future<_BatchLockTargets> _loadBatchLockTargets({
    required bool lockState,
  }) async {
    final eventTypes = ref.read(reportsEventTypesProvider);
    final includedFlightIds = _filters.isEmpty ? null : _filteredFlightIds();
    final entries = await _fetchEntriesForRange(
      includedFlightIds: includedFlightIds,
      eventTypes: eventTypes,
      from: _from,
      to: _to,
    );
    final flightIds = <int>{};
    final simulatorIds = <int>{};
    final positioningIds = <int>{};
    final dutyIds = <int>{};
    for (final entry in entries) {
      final flight = entry.flight;
      if (flight != null) {
        flightIds.add(flight.id);
      }
      final simulator = entry.simulatorTraining;
      if (simulator != null) {
        simulatorIds.add(simulator.id);
      }
      final positioning = entry.positioning;
      if (positioning != null) {
        positioningIds.add(positioning.id);
      }
      final dutyStart = entry.dutyStart;
      if (dutyStart != null) {
        dutyIds.add(dutyStart.id);
      }
      final dutyEnd = entry.dutyEnd;
      if (dutyEnd != null) {
        dutyIds.add(dutyEnd.id);
      }
    }

    final db = ref.read(databaseProvider);
    final unlockedFlightIds = flightIds.isEmpty
        ? const <int>{}
        : (await (db.select(
                db.flights,
              )..where((t) => t.id.isIn(flightIds.toList()))).get())
              .where((row) => row.isLocked != lockState)
              .map((row) => row.id)
              .toSet();
    final unlockedSimulatorIds = simulatorIds.isEmpty
        ? const <int>{}
        : (await (db.select(
                db.simulatorTrainings,
              )..where((t) => t.id.isIn(simulatorIds.toList()))).get())
              .where((row) => row.isLocked != lockState)
              .map((row) => row.id)
              .toSet();
    final unlockedPositioningIds = positioningIds.isEmpty
        ? const <int>{}
        : (await (db.select(
                db.positionings,
              )..where((t) => t.id.isIn(positioningIds.toList()))).get())
              .where((row) => row.isLocked != lockState)
              .map((row) => row.id)
              .toSet();
    final unlockedDutyIds = dutyIds.isEmpty
        ? const <int>{}
        : (await (db.select(
                db.dutyPeriods,
              )..where((t) => t.id.isIn(dutyIds.toList()))).get())
              .where((row) => row.isLocked != lockState)
              .map((row) => row.id)
              .toSet();

    return _BatchLockTargets(
      totalCount:
          flightIds.length +
          simulatorIds.length +
          positioningIds.length +
          dutyIds.length,
      flightIds: unlockedFlightIds.toList(growable: false),
      simulatorIds: unlockedSimulatorIds.toList(growable: false),
      positioningIds: unlockedPositioningIds.toList(growable: false),
      dutyIds: unlockedDutyIds.toList(growable: false),
    );
  }

  Map<int, _BatchFlightSnapshot> _unlockedBatchSnapshots(
    Map<int, _BatchFlightSnapshot> snapshots,
  ) {
    return Map<int, _BatchFlightSnapshot>.fromEntries(
      snapshots.entries.where((entry) => !entry.value.isLocked),
    );
  }

  String _lockedSkipSuffix(int skippedLocked) {
    if (skippedLocked <= 0) return '';
    return ' Skipped $skippedLocked locked flight'
        '${skippedLocked == 1 ? '' : 's'}.';
  }

  Future<Map<int, _BatchFlightSnapshot>> _loadBatchSnapshots(
    Set<int> ids,
  ) async {
    if (ids.isEmpty) return const {};
    final db = ref.read(databaseProvider);
    final flights = await (db.select(
      db.flights,
    )..where((t) => t.id.isIn(ids.toList()))).get();
    final depTimelineIds = flights
        .map((flight) => flight.departureDateTimeId)
        .toSet()
        .toList(growable: false);
    final timelines = await (db.select(
      db.timeLines,
    )..where((t) => t.id.isIn(depTimelineIds))).get();
    final timelineById = <int, TimeLine>{
      for (final timeline in timelines) timeline.id: timeline,
    };
    final airportIds = flights
        .expand(
          (flight) => [flight.departureAirportId, flight.arrivalAirportId],
        )
        .toSet()
        .toList(growable: false);
    final airports = await (db.select(
      db.airports,
    )..where((t) => t.id.isIn(airportIds))).get();
    final airportById = <int, Airport>{
      for (final airport in airports) airport.id: airport,
    };
    final result = <int, _BatchFlightSnapshot>{};
    for (final flight in flights) {
      final depTimeline = timelineById[flight.departureDateTimeId];
      if (depTimeline == null) continue;
      final depAirport = airportById[flight.departureAirportId];
      final arrAirport = airportById[flight.arrivalAirportId];
      result[flight.id] = _BatchFlightSnapshot(
        id: flight.id,
        isLocked: flight.isLocked,
        departureUtc: DbDateTime.dbToUtc(depTimeline.eventDateTime),
        arrivalUtc: DbDateTime.dbToUtcOrNull(flight.arrivalDateTime),
        takeoffUtc: DbDateTime.dbToUtcOrNull(flight.takeOffDateTime),
        landingUtc: DbDateTime.dbToUtcOrNull(flight.landingDateTime),
        fromIcao: depAirport?.icao ?? '',
        toIcao: arrAirport?.icao ?? '',
        fromLatitude: depAirport?.latitude,
        fromLongitude: depAirport?.longitude,
        toLatitude: arrAirport?.latitude,
        toLongitude: arrAirport?.longitude,
        pilotFunction: PilotFunctionLogic.fromEnum(flight.pilotFunction),
        timeBlockMinutes: flight.timeBlockMinutes,
        timeTotalBlockMinutes: flight.timeTotalBlockMinutes,
        timePICMinutes: flight.timePICMinutes,
        timePICUSMinutes: flight.timePICUSMinutes,
        timeSICMinutes: flight.timeSICMinutes,
        timeDualMinutes: flight.timeDualMinutes,
        timeInstructorMinutes: flight.timeInstructorMinutes,
        timeIFRMinutes: flight.timeIFRMinutes,
        timeNightMinutes: flight.timeNightMinutes,
        timeCrossCountryMinutes: flight.timeCrossCountryMinutes,
        timeCustom1Minutes: flight.timeCustom1Minutes,
        timeCustom2Minutes: flight.timeCustom2Minutes,
        timeCustom3Minutes: flight.timeCustom3Minutes,
        timeCustom4Minutes: flight.timeCustom4Minutes,
        timeFlightMinutes: flight.timeFlightMinutes,
        takeOffsDays: flight.takeOffsDays,
        takeOffsNight: flight.takeOffsNight,
        landingsDay: flight.landingsDay,
        landingsNight: flight.landingsNight,
        distanceNm: flight.distanceNM,
      );
    }
    return result;
  }

  Future<void> _updateFlightFromSnapshot(_BatchFlightSnapshot snapshot) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.flights)..where((t) => t.id.equals(snapshot.id))).write(
      FlightsCompanion(
        timeBlockMinutes: d.Value(snapshot.timeBlockMinutes),
        timeTotalBlockMinutes: d.Value(snapshot.timeTotalBlockMinutes),
        timePICMinutes: d.Value(snapshot.timePICMinutes),
        timePICUSMinutes: d.Value(snapshot.timePICUSMinutes),
        timeSICMinutes: d.Value(snapshot.timeSICMinutes),
        timeDualMinutes: d.Value(snapshot.timeDualMinutes),
        timeInstructorMinutes: d.Value(snapshot.timeInstructorMinutes),
        timeIFRMinutes: d.Value(snapshot.timeIFRMinutes),
        timeFlightMinutes: d.Value(snapshot.timeFlightMinutes),
        timeNightMinutes: d.Value(snapshot.timeNightMinutes),
        timeCrossCountryMinutes: d.Value(snapshot.timeCrossCountryMinutes),
        timeCustom1Minutes: d.Value(snapshot.timeCustom1Minutes),
        timeCustom2Minutes: d.Value(snapshot.timeCustom2Minutes),
        timeCustom3Minutes: d.Value(snapshot.timeCustom3Minutes),
        timeCustom4Minutes: d.Value(snapshot.timeCustom4Minutes),
        takeOffsDays: d.Value(snapshot.takeOffsDays),
        takeOffsNight: d.Value(snapshot.takeOffsNight),
        landingsDay: d.Value(snapshot.landingsDay),
        landingsNight: d.Value(snapshot.landingsNight),
        distanceNM: d.Value(snapshot.distanceNm),
      ),
    );
  }

  _BatchNightResult? _calculateNightForSnapshot(_BatchFlightSnapshot snapshot) {
    final dep = snapshot.takeoffUtc ?? snapshot.departureUtc;
    final arr = snapshot.landingUtc ?? snapshot.arrivalUtc;
    if (arr == null) return null;
    final latDep = snapshot.fromLatitude;
    final lonDep = snapshot.fromLongitude;
    final latArr = snapshot.toLatitude;
    final lonArr = snapshot.toLongitude;
    if (latDep == null || lonDep == null || latArr == null || lonArr == null) {
      return null;
    }
    final calc = FlightCalculations(
      latDep: latDep,
      longDep: lonDep,
      latArr: latArr,
      longArr: lonArr,
      depTimeEpochSeconds: dep.millisecondsSinceEpoch ~/ 1000,
      arrTimeEpochSeconds: arr.millisecondsSinceEpoch ~/ 1000,
    );
    final canonicalFunction = PilotFunctionLogic.canonicalize(
      snapshot.pilotFunction,
      takeoffCount: snapshot.takeOffsDays + snapshot.takeOffsNight,
      landingCount: snapshot.landingsDay + snapshot.landingsNight,
    );
    final takeoffCount =
        (canonicalFunction == PilotFunctionLogic.pf ||
            canonicalFunction == PilotFunctionLogic.pfPnf)
        ? 1
        : 0;
    final landingCount =
        (canonicalFunction == PilotFunctionLogic.pf ||
            canonicalFunction == PilotFunctionLogic.pnfPf)
        ? 1
        : 0;
    var takeoffsDay = 0;
    var takeoffsNight = 0;
    var landingsDay = 0;
    var landingsNight = 0;
    if (takeoffCount > 0) {
      if (calc.dayTakeOff) {
        takeoffsDay = takeoffCount;
      } else {
        takeoffsNight = takeoffCount;
      }
    }
    if (landingCount > 0) {
      if (calc.dayLanding) {
        landingsDay = landingCount;
      } else {
        landingsNight = landingCount;
      }
    }
    return _BatchNightResult(
      nightMinutes: calc.nightTimeMinutes.clamp(0, snapshot.timeBlockMinutes),
      takeoffsDay: takeoffsDay,
      takeoffsNight: takeoffsNight,
      landingsDay: landingsDay,
      landingsNight: landingsNight,
    );
  }

  List<_BatchFieldChange> _buildBatchFieldChanges(
    _BatchFlightSnapshot before,
    _BatchFlightSnapshot after,
  ) {
    final changes = <_BatchFieldChange>[];
    void addTime(String label, int from, int to) {
      if (from == to) return;
      changes.add(
        _BatchFieldChange(
          label: label,
          before: TimeInputField.formatMinutes(from),
          after: TimeInputField.formatMinutes(to),
        ),
      );
    }

    void addCount(String label, int from, int to) {
      if (from == to) return;
      changes.add(
        _BatchFieldChange(
          label: label,
          before: '$from',
          after: '$to',
        ),
      );
    }

    addTime('Block time', before.timeBlockMinutes, after.timeBlockMinutes);
    addTime(
      'Total Block time',
      before.timeTotalBlockMinutes,
      after.timeTotalBlockMinutes,
    );
    addTime('PIC time', before.timePICMinutes, after.timePICMinutes);
    addTime('PICUS time', before.timePICUSMinutes, after.timePICUSMinutes);
    addTime('SIC time', before.timeSICMinutes, after.timeSICMinutes);
    addTime('Dual time', before.timeDualMinutes, after.timeDualMinutes);
    addTime(
      'Instructor time',
      before.timeInstructorMinutes,
      after.timeInstructorMinutes,
    );
    addTime('IFR time', before.timeIFRMinutes, after.timeIFRMinutes);
    addTime('Flight time', before.timeFlightMinutes, after.timeFlightMinutes);
    addTime('Night time', before.timeNightMinutes, after.timeNightMinutes);
    addTime(
      'Cross-country',
      before.timeCrossCountryMinutes,
      after.timeCrossCountryMinutes,
    );
    addTime('Custom1', before.timeCustom1Minutes, after.timeCustom1Minutes);
    addTime('Custom2', before.timeCustom2Minutes, after.timeCustom2Minutes);
    addTime('Custom3', before.timeCustom3Minutes, after.timeCustom3Minutes);
    addTime('Custom4', before.timeCustom4Minutes, after.timeCustom4Minutes);
    addCount('Takeoffs day', before.takeOffsDays, after.takeOffsDays);
    addCount('Takeoffs night', before.takeOffsNight, after.takeOffsNight);
    addCount('Landings day', before.landingsDay, after.landingsDay);
    addCount('Landings night', before.landingsNight, after.landingsNight);
    addCount('Distance NM', before.distanceNm, after.distanceNm);
    return changes;
  }

  Future<void> _showBatchIssues(List<String> issues) async {
    final parsedIssues = issues
        .map(_BatchIssueCardData.fromIssueLine)
        .toList(growable: false);
    final groupedIssues = <_BatchIssueGroupData>[];
    final flightGroupIndex = <int, int>{};
    for (final issue in parsedIssues) {
      final flightId = issue.flightId;
      if (flightId == null) {
        groupedIssues.add(
          _BatchIssueGroupData(flightId: null, messages: [issue.message]),
        );
        continue;
      }
      final existingIndex = flightGroupIndex[flightId];
      if (existingIndex != null) {
        groupedIssues[existingIndex].messages.add(issue.message);
      } else {
        flightGroupIndex[flightId] = groupedIssues.length;
        groupedIssues.add(
          _BatchIssueGroupData(flightId: flightId, messages: [issue.message]),
        );
      }
    }
    final flightIds = groupedIssues
        .map((issue) => issue.flightId)
        .whereType<int>()
        .toSet();
    final entriesByFlight = await _loadIssueFlightEntries(flightIds);
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;
    final dialogWidth = math.min<double>(screenWidth * 0.92, 1080);
    final issueScreen = StatefulBuilder(
      builder: (context, setStateDialog) {
        final content = groupedIssues.isEmpty
            ? Text(AppLocalizations.of(context)!.reportsNoFlightIssuesFound)
            : ListView.builder(
                shrinkWrap: true,
                itemCount: groupedIssues.length,
                itemBuilder: (context, index) {
                  final issue = groupedIssues[index];
                  final flightId = issue.flightId;
                  final entry = flightId == null
                      ? null
                      : entriesByFlight[flightId];
                  final issueSummary = issue.messages.length == 1
                      ? issue.messages.first
                      : AppLocalizations.of(
                          context,
                        )!.reportsIssueCount(issue.messages.length);
                  final issueTitle = entry == null
                      ? issueSummary
                      : '${DateFormat('yyyy-MM-dd').format(
                          DbDateTime.dbToUtc(entry.timeLine.eventDateTime),
                        )} - $issueSummary';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            issueTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (issue.messages.length > 1) ...[
                            const SizedBox(height: 6),
                            for (final message in issue.messages)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('• $message'),
                              ),
                          ],
                          if (entry != null) ...[
                            const SizedBox(height: 8),
                            Card(
                              margin: EdgeInsets.zero,
                              child: LogbookListItem(
                                entry: entry,
                                isCompact:
                                    MediaQuery.of(context).size.width < 760,
                                onOpen: (_) => unawaited(
                                  LogbookEntryDialogs.show(
                                    context,
                                    entry: entry,
                                    useCases: ref.read(
                                      logbookUseCasesProvider,
                                    ),
                                  ),
                                ),
                                onToggleLock: (_) async {
                                  final useCases = ref.read(
                                    logbookUseCasesProvider,
                                  );
                                  await useCases.toggleEntryLock(entry);
                                  if (!mounted) return;
                                  final refreshed = await useCases
                                      .fetchEntryByTimelineId(
                                        entry.timeLine.id,
                                      );
                                  if (refreshed != null &&
                                      refreshed.flight != null &&
                                      flightId != null) {
                                    setStateDialog(() {
                                      entriesByFlight[flightId] = refreshed;
                                    });
                                  }
                                },
                                onEdit: (_) => unawaited(
                                  _openFlightEditFromIssue(
                                    flightId!,
                                    onChanged: () async {
                                      final useCases = ref.read(
                                        logbookUseCasesProvider,
                                      );
                                      final refreshed = await useCases
                                          .fetchEntryByTimelineId(
                                            entry.timeLine.id,
                                          );
                                      if (refreshed != null &&
                                          refreshed.flight != null) {
                                        setStateDialog(() {
                                          entriesByFlight[flightId] = refreshed;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                onDelete: (_) async {
                                  final useCases = ref.read(
                                    logbookUseCasesProvider,
                                  );
                                  await useCases.deleteEntry(entry);
                                  if (!mounted || flightId == null) {
                                    return;
                                  }
                                  setStateDialog(() {
                                    entriesByFlight.remove(flightId);
                                  });
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
        return SizedBox(
          width: dialogWidth,
          child: AdaptiveFormShell(
            onClose: () => AppNavigator.pop(context),
            title: AppLocalizations.of(context)!.reportsChecksTitle,
            leading: const SizedBox.shrink(),
            popupMaxWidth: dialogWidth,
            actions: [
              TextButton(
                onPressed: () => AppNavigator.pop(context),
                child: Text(AppLocalizations.of(context)!.okAction),
              ),
            ],
            contentView: Padding(
              padding: const EdgeInsets.all(12),
              child: content,
            ),
          ),
        );
      },
    );
    if (isCompact) {
      await AppNavigator.pushMaterial<void>(
        context,
        (_) => issueScreen,
        rootNavigator: true,
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => issueScreen,
    );
  }

  Future<void> _openFlightEditFromIssue(
    int flightId, {
    Future<void> Function()? onChanged,
  }) async {
    if (!mounted) return;
    final isCompact = MediaQuery.of(context).size.width < 600;
    final screen = FlightEditScreen(flightId: flightId);
    var changed = false;
    if (isCompact) {
      changed =
          await AppNavigator.pushMaterial<bool>(context, (_) => screen) ??
          false;
    } else {
      changed =
          await showDialog<bool>(
            context: context,
            builder: (context) => screen,
          ) ??
          false;
    }
    if (!changed) return;
    if (onChanged != null) {
      await onChanged();
    }
    await _loadOverviewData();
    if (!mounted) return;
    await _ensureDetailsLoaded(
      includeEntries: false,
    );
  }

  Future<Map<int, LogbookEntry>> _loadIssueFlightEntries(
    Set<int> flightIds,
  ) async {
    if (flightIds.isEmpty) return {};
    final db = ref.read(databaseProvider);
    final placeholders = List.filled(flightIds.length, '?').join(',');
    final rows = await db
        .customSelect(
          '''
SELECT id AS flight_id, departure_date_time_id AS timeline_id
FROM flights
WHERE id IN ($placeholders)
''',
          variables: flightIds.map(d.Variable<int>.new).toList(),
          readsFrom: {db.flights},
        )
        .get();
    final useCases = ref.read(logbookUseCasesProvider);
    final result = <int, LogbookEntry>{};
    for (final row in rows) {
      final flightId = row.read<int>('flight_id');
      final timelineId = row.read<int>('timeline_id');
      final entry = await useCases.fetchEntryByTimelineId(timelineId);
      if (entry?.flight != null) {
        result[flightId] = entry!;
      }
    }
    return result;
  }

  Future<void> _showBatchChanges(List<_BatchFlightChange> changes) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reportsBatchChangesTitle),
        content: SizedBox(
          width: 760,
          child: changes.isEmpty
              ? Text(AppLocalizations.of(context)!.reportsNoChangesApplied)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: changes.length,
                  itemBuilder: (context, index) {
                    final change = changes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            change.snapshot.summaryLine,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          for (final field in change.fields)
                            Text(
                              '${field.label} ${field.before} '
                              'to ${field.after}',
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          FilledButton(
            onPressed: () => AppNavigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _BatchIssueCardData {
  const _BatchIssueCardData({
    required this.flightId,
    required this.message,
  });

  factory _BatchIssueCardData.fromIssueLine(String line) {
    final match = RegExp(r'^Flight\s+(\d+):\s*(.*)$').firstMatch(line.trim());
    if (match == null) {
      return _BatchIssueCardData(flightId: null, message: line.trim());
    }
    final id = int.tryParse(match.group(1) ?? '');
    final explanation = (match.group(2) ?? '').trim();
    return _BatchIssueCardData(
      flightId: id,
      message: explanation.isEmpty ? line.trim() : explanation,
    );
  }

  final int? flightId;
  final String message;
}

class _BatchIssueGroupData {
  _BatchIssueGroupData({
    required this.flightId,
    required this.messages,
  });

  final int? flightId;
  final List<String> messages;
}

enum _BatchFlightCheck {
  timelineConsistency,
  chocksEqualsTotalBlock,
  flightElapsedMatchesTimes,
  crewTimesEqualBlock,
  cappedTimesWithinBlock,
  customTimesWithinTotalBlock,
  distanceValidation,
  pilotFunctionPattern,
}

class _BatchFlightChecksDialog extends StatefulWidget {
  const _BatchFlightChecksDialog();

  static Future<Set<_BatchFlightCheck>?> show(BuildContext context) {
    const screen = _BatchFlightChecksDialog();
    if (isCompactDialogScreen(context)) {
      return AppNavigator.pushMaterial<Set<_BatchFlightCheck>>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<Set<_BatchFlightCheck>>(
      context: context,
      builder: (_) => screen,
    );
  }

  @override
  State<_BatchFlightChecksDialog> createState() =>
      _BatchFlightChecksDialogState();
}

class _BatchFlightChecksDialogState extends State<_BatchFlightChecksDialog> {
  late final Set<_BatchFlightCheck> _selected = Set<_BatchFlightCheck>.from(
    _BatchFlightCheck.values,
  );

  (String, String) _copy(_BatchFlightCheck check) {
    return switch (check) {
      _BatchFlightCheck.timelineConsistency => (
        'Timeline consistency',
        'Arrival/departure order, negatives and airport consistency',
      ),
      _BatchFlightCheck.chocksEqualsTotalBlock => (
        'Chocks block matches Total Block',
        'Checks if chocks elapsed equals total block time',
      ),
      _BatchFlightCheck.flightElapsedMatchesTimes => (
        'Takeoff/landing elapsed = Flight',
        'Compares airborne elapsed time against Flight field',
      ),
      _BatchFlightCheck.crewTimesEqualBlock => (
        'PIC + PICUS + SIC + Dual = Block',
        'Validates crew position times add up to block',
      ),
      _BatchFlightCheck.cappedTimesWithinBlock => (
        'Time caps within Block',
        'Night, IFR, CrossCountry and Flight cannot exceed Block',
      ),
      _BatchFlightCheck.customTimesWithinTotalBlock => (
        'Custom1-4 within Total Block',
        'Custom time fields must not exceed total block',
      ),
      _BatchFlightCheck.distanceValidation => (
        'Distance validation',
        'Validates distance consistency and allowed values',
      ),
      _BatchFlightCheck.pilotFunctionPattern => (
        'Pilot function pattern',
        'Validates takeoff/landing function sequence',
      ),
    };
  }

  void _toggleCheck(_BatchFlightCheck check, bool enabled) {
    setState(() {
      if (enabled) {
        _selected.add(check);
      } else {
        _selected.remove(check);
      }
    });
  }

  Widget _buildCheckTile({
    required _BatchFlightCheck check,
    required ThemeData theme,
    required Color cardColor,
    required Color borderColor,
  }) {
    final copy = _copy(check);
    final isSelected = _selected.contains(check);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _toggleCheck(check, !isSelected),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.$1,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        copy.$2,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Checkbox.adaptive(
                  value: isSelected,
                  onChanged: (value) => _toggleCheck(check, value ?? false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.45,
    );
    final borderColor = theme.colorScheme.outline.withValues(alpha: 0.35);
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: AppLocalizations.of(context)!.reportsChecksTitle,
      popupMaxWidth: 680,
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(context, _selected),
          child: Text(AppLocalizations.of(context)!.reportsRunAction),
        ),
      ],
      contentView: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.30,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.rule_folder_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selected.length} of '
                      '${_BatchFlightCheck.values.length} checks selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Buttons(
                  onPressed: () {
                    setState(() {
                      _selected
                        ..clear()
                        ..addAll(_BatchFlightCheck.values);
                    });
                  },
                  label: AppLocalizations.of(context)!.reportsSelectAll,
                ),
                const SizedBox(width: 8),
                Buttons(
                  onPressed: () {
                    setState(_selected.clear);
                  },
                  label: AppLocalizations.of(context)!.reportsClearAction,
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final check in _BatchFlightCheck.values)
              _buildCheckTile(
                check: check,
                theme: theme,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
          ],
        ),
      ),
    );
  }
}

enum _BatchCalcField {
  block,
  instructor,
  night,
  takeoffDay,
  takeoffNight,
  landingDay,
  landingNight,
  distanceNm,
  ifr,
  crossCountry,
  flight,
  custom1,
  custom2,
  custom3,
  custom4,
}

enum _BatchFieldMode { dontChange, recalculate, setZero }

class _BatchCalculateAllPreferences {
  const _BatchCalculateAllPreferences({
    required this.fieldModes,
  });

  factory _BatchCalculateAllPreferences.fromJson(
    Map<String, dynamic> json, {
    required List<_BatchCalcField> fallbackFields,
  }) {
    final rawFieldModes = json['fieldModes'];
    final fieldModes = <_BatchCalcField, _BatchFieldMode>{
      for (final field in fallbackFields) field: _BatchFieldMode.dontChange,
    };
    if (rawFieldModes is Map) {
      for (final field in fallbackFields) {
        final raw = rawFieldModes[field.name];
        fieldModes[field] = _modeFromRaw(raw) ?? _BatchFieldMode.dontChange;
      }
    }
    return _BatchCalculateAllPreferences(fieldModes: fieldModes);
  }

  final Map<_BatchCalcField, _BatchFieldMode> fieldModes;

  _BatchCalculateAllPreferences copyWith({
    Map<_BatchCalcField, _BatchFieldMode>? fieldModes,
  }) {
    return _BatchCalculateAllPreferences(
      fieldModes: fieldModes ?? this.fieldModes,
    );
  }

  _BatchFieldMode modeFor(_BatchCalcField field) {
    return fieldModes[field] ?? _BatchFieldMode.dontChange;
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldModes': {
        for (final entry in fieldModes.entries)
          entry.key.name: entry.value.name,
      },
    };
  }

  static _BatchFieldMode? _modeFromRaw(Object? raw) {
    if (raw is! String) return null;
    for (final mode in _BatchFieldMode.values) {
      if (mode.name == raw) return mode;
    }
    return null;
  }
}

class _BatchCalculateAllDialog extends StatefulWidget {
  const _BatchCalculateAllDialog({required this.initialPreferences});

  final _BatchCalculateAllPreferences initialPreferences;

  static Future<_BatchCalculateAllPreferences?> show(
    BuildContext context, {
    required _BatchCalculateAllPreferences initialPreferences,
  }) {
    final screen = _BatchCalculateAllDialog(
      initialPreferences: initialPreferences,
    );
    if (isCompactDialogScreen(context)) {
      return AppNavigator.pushMaterial<_BatchCalculateAllPreferences>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<_BatchCalculateAllPreferences>(
      context: context,
      builder: (_) => screen,
    );
  }

  @override
  State<_BatchCalculateAllDialog> createState() =>
      _BatchCalculateAllDialogState();
}

class _BatchCalculateAllDialogState extends State<_BatchCalculateAllDialog> {
  late _BatchCalculateAllPreferences _preferences = widget.initialPreferences;

  static const _fields = <_BatchCalcField>[
    _BatchCalcField.block,
    _BatchCalcField.ifr,
    _BatchCalcField.crossCountry,
    _BatchCalcField.distanceNm,
    _BatchCalcField.flight,
    _BatchCalcField.night,
    _BatchCalcField.takeoffDay,
    _BatchCalcField.takeoffNight,
    _BatchCalcField.landingDay,
    _BatchCalcField.landingNight,
    _BatchCalcField.instructor,
    _BatchCalcField.custom1,
    _BatchCalcField.custom2,
    _BatchCalcField.custom3,
    _BatchCalcField.custom4,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNarrow = MediaQuery.of(context).size.width < 400;
    final isCompact = isCompactDialogScreen(context);

    String label(_BatchCalcField field) {
      return switch (field) {
        _BatchCalcField.block => 'Block',
        _BatchCalcField.instructor => 'Instructor',
        _BatchCalcField.night => 'Night',
        _BatchCalcField.takeoffDay => 'Takeoff Day',
        _BatchCalcField.takeoffNight => 'Takeoff Night',
        _BatchCalcField.landingDay => 'Landing Day',
        _BatchCalcField.landingNight => 'Landing Night',
        _BatchCalcField.distanceNm => 'Distance NM',
        _BatchCalcField.ifr => 'IFR',
        _BatchCalcField.crossCountry => 'Cross-country',
        _BatchCalcField.flight => 'Flight',
        _BatchCalcField.custom1 => 'Custom 1',
        _BatchCalcField.custom2 => 'Custom 2',
        _BatchCalcField.custom3 => 'Custom 3',
        _BatchCalcField.custom4 => 'Custom 4',
      };
    }

    String modeLabel(_BatchFieldMode mode) {
      return switch (mode) {
        _BatchFieldMode.dontChange => "Don't change",
        _BatchFieldMode.recalculate => 'Recalculate',
        _BatchFieldMode.setZero => 'Set Zero',
      };
    }

    String compactModeLabel(_BatchFieldMode mode) {
      return switch (mode) {
        _BatchFieldMode.dontChange => 'No change',
        _BatchFieldMode.recalculate => 'Recalc',
        _BatchFieldMode.setZero => 'Zero',
      };
    }

    Widget modeDropdown({
      required String fieldLabel,
      required _BatchFieldMode value,
      required ValueChanged<_BatchFieldMode?> onChanged,
      required bool showFieldLabel,
    }) {
      final useCompactLabels = isCompact || isNarrow;
      return DropdownInputField<_BatchFieldMode>(
        label: fieldLabel,
        value: value,
        showLabel: showFieldLabel,
        items: _BatchFieldMode.values
            .map(
              (mode) => DropdownMenuItem(
                value: mode,
                child: Text(
                  useCompactLabels ? compactModeLabel(mode) : modeLabel(mode),
                ),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      );
    }

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.reportsCalculateAllFlightsTitle,
      popupMaxWidth: 620,
      actions: [
        InfoHelpButton(
          title: l10n.reportsCalculateAllHelpTitle,
          message: l10n.reportsCalculateAllHelpBody,
        ),
        TextButton(
          onPressed: () => AppNavigator.pop(context, _preferences),
          child: Text(l10n.applyAction),
        ),
      ],
      contentView: Padding(
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final field in _fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: isNarrow
                      ? modeDropdown(
                          fieldLabel: label(field),
                          showFieldLabel: true,
                          value: _preferences.modeFor(field),
                          onChanged: (value) {
                            if (value == null) return;
                            final nextModes =
                                Map<_BatchCalcField, _BatchFieldMode>.from(
                                  _preferences.fieldModes,
                                )..[field] = value;
                            setState(() {
                              _preferences = _preferences.copyWith(
                                fieldModes: nextModes,
                              );
                            });
                          },
                        )
                      : Row(
                          children: [
                            Expanded(child: Text(label(field))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: modeDropdown(
                                fieldLabel: label(field),
                                showFieldLabel: false,
                                value: _preferences.modeFor(field),
                                onChanged: (value) {
                                  if (value == null) return;
                                  final nextModes =
                                      Map<
                                          _BatchCalcField,
                                          _BatchFieldMode
                                        >.from(
                                          _preferences.fieldModes,
                                        )
                                        ..[field] = value;
                                  setState(() {
                                    _preferences = _preferences.copyWith(
                                      fieldModes: nextModes,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchNightResult {
  const _BatchNightResult({
    required this.nightMinutes,
    required this.takeoffsDay,
    required this.takeoffsNight,
    required this.landingsDay,
    required this.landingsNight,
  });

  final int nightMinutes;
  final int takeoffsDay;
  final int takeoffsNight;
  final int landingsDay;
  final int landingsNight;
}

class _BatchLockTargets {
  const _BatchLockTargets({
    required this.totalCount,
    required this.flightIds,
    required this.simulatorIds,
    required this.positioningIds,
    required this.dutyIds,
  });

  final int totalCount;
  final List<int> flightIds;
  final List<int> simulatorIds;
  final List<int> positioningIds;
  final List<int> dutyIds;

  int get changeCount =>
      flightIds.length +
      simulatorIds.length +
      positioningIds.length +
      dutyIds.length;
}

class _BatchFlightSnapshot {
  _BatchFlightSnapshot({
    required this.id,
    required this.isLocked,
    required this.departureUtc,
    required this.arrivalUtc,
    required this.takeoffUtc,
    required this.landingUtc,
    required this.fromIcao,
    required this.toIcao,
    required this.fromLatitude,
    required this.fromLongitude,
    required this.toLatitude,
    required this.toLongitude,
    required this.pilotFunction,
    required this.timeBlockMinutes,
    required this.timeTotalBlockMinutes,
    required this.timePICMinutes,
    required this.timePICUSMinutes,
    required this.timeSICMinutes,
    required this.timeDualMinutes,
    required this.timeInstructorMinutes,
    required this.timeIFRMinutes,
    required this.timeNightMinutes,
    required this.timeCrossCountryMinutes,
    required this.timeCustom1Minutes,
    required this.timeCustom2Minutes,
    required this.timeCustom3Minutes,
    required this.timeCustom4Minutes,
    required this.timeFlightMinutes,
    required this.takeOffsDays,
    required this.takeOffsNight,
    required this.landingsDay,
    required this.landingsNight,
    required this.distanceNm,
  });

  final int id;
  final bool isLocked;
  final DateTime departureUtc;
  final DateTime? arrivalUtc;
  final DateTime? takeoffUtc;
  final DateTime? landingUtc;
  final String fromIcao;
  final String toIcao;
  final double? fromLatitude;
  final double? fromLongitude;
  final double? toLatitude;
  final double? toLongitude;
  final String pilotFunction;
  int timeBlockMinutes;
  int timeTotalBlockMinutes;
  int timePICMinutes;
  int timePICUSMinutes;
  int timeSICMinutes;
  int timeDualMinutes;
  int timeInstructorMinutes;
  int timeIFRMinutes;
  int timeNightMinutes;
  int timeCrossCountryMinutes;
  int timeCustom1Minutes;
  int timeCustom2Minutes;
  int timeCustom3Minutes;
  int timeCustom4Minutes;
  int timeFlightMinutes;
  int takeOffsDays;
  int takeOffsNight;
  int landingsDay;
  int landingsNight;
  int distanceNm;

  _BatchFlightSnapshot copy() {
    return _BatchFlightSnapshot(
      id: id,
      isLocked: isLocked,
      departureUtc: departureUtc,
      arrivalUtc: arrivalUtc,
      takeoffUtc: takeoffUtc,
      landingUtc: landingUtc,
      fromIcao: fromIcao,
      toIcao: toIcao,
      fromLatitude: fromLatitude,
      fromLongitude: fromLongitude,
      toLatitude: toLatitude,
      toLongitude: toLongitude,
      pilotFunction: pilotFunction,
      timeBlockMinutes: timeBlockMinutes,
      timeTotalBlockMinutes: timeTotalBlockMinutes,
      timePICMinutes: timePICMinutes,
      timePICUSMinutes: timePICUSMinutes,
      timeSICMinutes: timeSICMinutes,
      timeDualMinutes: timeDualMinutes,
      timeInstructorMinutes: timeInstructorMinutes,
      timeIFRMinutes: timeIFRMinutes,
      timeNightMinutes: timeNightMinutes,
      timeCrossCountryMinutes: timeCrossCountryMinutes,
      timeCustom1Minutes: timeCustom1Minutes,
      timeCustom2Minutes: timeCustom2Minutes,
      timeCustom3Minutes: timeCustom3Minutes,
      timeCustom4Minutes: timeCustom4Minutes,
      timeFlightMinutes: timeFlightMinutes,
      takeOffsDays: takeOffsDays,
      takeOffsNight: takeOffsNight,
      landingsDay: landingsDay,
      landingsNight: landingsNight,
      distanceNm: distanceNm,
    );
  }

  String get summaryLine {
    final formatter = DateFormat('yyyy-MM-dd');
    final dep = DateFormat('HH:mm').format(departureUtc);
    final arr = arrivalUtc == null
        ? '--:--'
        : DateFormat('HH:mm').format(arrivalUtc!);
    final total = TimeInputField.formatMinutes(timeTotalBlockMinutes);
    return '${formatter.format(departureUtc)} $fromIcao $dep '
        '$toIcao $arr total $total';
  }
}

class _BatchFieldChange {
  const _BatchFieldChange({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final String before;
  final String after;
}

class _BatchFlightChange {
  const _BatchFlightChange({
    required this.snapshot,
    required this.fields,
  });

  final _BatchFlightSnapshot snapshot;
  final List<_BatchFieldChange> fields;
}

class _CoverFleetTotals {
  _CoverFleetTotals();

  factory _CoverFleetTotals.fromTemplateTotals(ReportTemplateTotals totals) {
    return _CoverFleetTotals()
      ..night = totals.nightMinutes
      ..ifr = totals.ifrMinutes
      ..pic = totals.picMinutes
      ..picus = totals.picusMinutes
      ..sic = totals.sicMinutes
      ..dual = totals.dualMinutes
      ..instructor = totals.instructorMinutes
      ..examiner = 0
      ..total = totals.totalMinutes;
  }

  factory _CoverFleetTotals.from(_CoverFleetTotals source) {
    return _CoverFleetTotals()
      ..night = source.night
      ..ifr = source.ifr
      ..pic = source.pic
      ..picus = source.picus
      ..sic = source.sic
      ..dual = source.dual
      ..instructor = source.instructor
      ..examiner = source.examiner
      ..total = source.total;
  }

  int night = 0;
  int ifr = 0;
  int pic = 0;
  int picus = 0;
  int sic = 0;
  int dual = 0;
  int instructor = 0;
  int examiner = 0;
  int total = 0;

  void add(_CoverFleetTotals other) {
    night += other.night;
    ifr += other.ifr;
    pic += other.pic;
    picus += other.picus;
    sic += other.sic;
    dual += other.dual;
    instructor += other.instructor;
    examiner += other.examiner;
    total += other.total;
  }

  void addFlight(Flight flight) {
    night += flight.timeNightMinutes;
    ifr += flight.timeIFRMinutes;
    pic += flight.timePICMinutes;
    picus += flight.timePICUSMinutes;
    sic += flight.timeSICMinutes;
    dual += flight.timeDualMinutes;
    instructor += flight.timeInstructorMinutes;
    total += flight.timeBlockMinutes;
  }
}

class _ReportsSectionCard extends StatelessWidget {
  const _ReportsSectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
    this.headerTrailing,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (headerTrailing != null) ...[
                  const Spacer(),
                  headerTrailing!,
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ReportsActionButton extends StatelessWidget {
  const _ReportsActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Buttons(
        onPressed: onPressed,
        icon: icon,
        label: label,
        variant: filled ? ButtonsVariant.filled : ButtonsVariant.outlined,
      ),
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

String _reportDateRangePresetLabel(
  AppLocalizations l10n,
  _ReportDateRangePreset value,
) {
  switch (value) {
    case _ReportDateRangePreset.sinceBeginning:
      return l10n.logbookFilterPresetSinceFirstFlight;
    case _ReportDateRangePreset.last7Days:
      return l10n.logbookFilterPresetLast7Days;
    case _ReportDateRangePreset.last14Days:
      return l10n.logbookFilterPresetLast14Days;
    case _ReportDateRangePreset.last21Days:
      return l10n.logbookFilterPresetLast21Days;
    case _ReportDateRangePreset.last28Days:
      return l10n.logbookFilterPresetLast28Days;
    case _ReportDateRangePreset.last1Month:
      return l10n.reportsDatePresetLastMonthRolling;
    case _ReportDateRangePreset.last365Days:
      return l10n.logbookFilterPresetLast365Days;
    case _ReportDateRangePreset.currentMonth:
      return l10n.logbookFilterPresetCurrentMonth;
    case _ReportDateRangePreset.currentYear:
      return l10n.logbookFilterPresetCurrentYear;
    case _ReportDateRangePreset.lastMonth:
      return l10n.logbookFilterPresetLastMonth;
    case _ReportDateRangePreset.lastYear:
      return l10n.logbookFilterPresetLastYear;
    case _ReportDateRangePreset.custom:
      return l10n.logbookFilterPresetCustom;
  }
}

enum _AnalysisGroupBy { aircraft, type, family, airport, year, month }

enum _AnalysisOrderBy { natural, hours, landings, takeoff, operations }

String _reportFilterFieldLabel(
  AppLocalizations l10n,
  ReportsFilterField field,
) {
  switch (field) {
    case ReportsFilterField.departureIcao:
      return l10n.reportsFilterFieldDepartureIcao;
    case ReportsFilterField.departureIata:
      return l10n.reportsFilterFieldDepartureIata;
    case ReportsFilterField.departureName:
      return l10n.reportsFilterFieldDepartureName;
    case ReportsFilterField.departureCity:
      return l10n.reportsFilterFieldDepartureCity;
    case ReportsFilterField.departureCountry:
      return l10n.reportsFilterFieldDepartureCountry;
    case ReportsFilterField.arrivalIcao:
      return l10n.reportsFilterFieldArrivalIcao;
    case ReportsFilterField.arrivalIata:
      return l10n.reportsFilterFieldArrivalIata;
    case ReportsFilterField.arrivalName:
      return l10n.reportsFilterFieldArrivalName;
    case ReportsFilterField.arrivalCity:
      return l10n.reportsFilterFieldArrivalCity;
    case ReportsFilterField.arrivalCountry:
      return l10n.reportsFilterFieldArrivalCountry;
    case ReportsFilterField.aircraftTail:
      return l10n.reportsFilterFieldAircraftRegistration;
    case ReportsFilterField.aircraftTypeCode:
      return l10n.reportsFilterFieldAircraftTypeCode;
    case ReportsFilterField.aircraftTypeFamily:
      return l10n.reportsFilterFieldAircraftTypeFamily;
    case ReportsFilterField.aircraftTypeName:
      return l10n.reportsFilterFieldAircraftTypeName;
    case ReportsFilterField.approachType:
      return l10n.reportsFilterFieldApproachType;
    case ReportsFilterField.remarks:
      return l10n.reportsFilterFieldRemarks;
    case ReportsFilterField.notes:
      return l10n.reportsFilterFieldNotes;
    case ReportsFilterField.blockTime:
      return l10n.reportsFilterFieldBlockTime;
    case ReportsFilterField.flightTime:
      return l10n.reportsFilterFieldFlightTime;
    case ReportsFilterField.totalTime:
      return l10n.reportsFilterFieldTotalTime;
    case ReportsFilterField.nightTime:
      return l10n.reportsFilterFieldNightTime;
    case ReportsFilterField.ifrTime:
      return l10n.reportsFilterFieldIfrTime;
    case ReportsFilterField.picTime:
      return l10n.reportsFilterFieldPicTime;
    case ReportsFilterField.picusTime:
      return l10n.reportsFilterFieldPicusTime;
    case ReportsFilterField.sicTime:
      return l10n.reportsFilterFieldSicTime;
    case ReportsFilterField.dualTime:
      return l10n.reportsFilterFieldDualTime;
    case ReportsFilterField.instructorTime:
      return l10n.reportsFilterFieldInstructorTime;
    case ReportsFilterField.crossCountryTime:
      return l10n.reportsFilterFieldCrossCountryTime;
    case ReportsFilterField.custom1Time:
      return l10n.reportsFilterFieldCustom1Time;
    case ReportsFilterField.custom2Time:
      return l10n.reportsFilterFieldCustom2Time;
    case ReportsFilterField.custom3Time:
      return l10n.reportsFilterFieldCustom3Time;
    case ReportsFilterField.custom4Time:
      return l10n.reportsFilterFieldCustom4Time;
    case ReportsFilterField.distanceNm:
      return l10n.reportsFilterFieldDistanceNm;
    case ReportsFilterField.takeoffs:
      return l10n.reportsFilterFieldTakeoffs;
    case ReportsFilterField.takeoffsDay:
      return l10n.reportsFilterFieldTakeoffsDay;
    case ReportsFilterField.takeoffsNight:
      return l10n.reportsFilterFieldTakeoffsNight;
    case ReportsFilterField.landings:
      return l10n.reportsFilterFieldLandings;
    case ReportsFilterField.landingsDay:
      return l10n.reportsFilterFieldLandingsDay;
    case ReportsFilterField.landingsNight:
      return l10n.reportsFilterFieldLandingsNight;
    case ReportsFilterField.ifrApproaches:
      return l10n.reportsFilterFieldIfrApproaches;
    case ReportsFilterField.isMultiPilot:
      return l10n.reportsFilterFieldMultiPilot;
    case ReportsFilterField.isSimulator:
      return l10n.reportsFilterFieldSimulator;
  }
}

String _reportFilterOperatorLabel(
  AppLocalizations l10n,
  ReportsFilterOperator operator,
) {
  switch (operator) {
    case ReportsFilterOperator.contains:
      return l10n.reportsFilterOperatorContains;
    case ReportsFilterOperator.doesNotContain:
      return l10n.reportsFilterOperatorDoesNotContain;
    case ReportsFilterOperator.startsWith:
      return l10n.reportsFilterOperatorStartsWith;
    case ReportsFilterOperator.doesNotStartWith:
      return l10n.reportsFilterOperatorDoesNotStartWith;
    case ReportsFilterOperator.endsWith:
      return l10n.reportsFilterOperatorEndsWith;
    case ReportsFilterOperator.doesNotEndWith:
      return l10n.reportsFilterOperatorDoesNotEndWith;
    case ReportsFilterOperator.isExactly:
      return l10n.reportsFilterOperatorIs;
    case ReportsFilterOperator.isNot:
      return l10n.reportsFilterOperatorIsNot;
    case ReportsFilterOperator.greaterThan:
      return l10n.reportsFilterOperatorGreaterThan;
    case ReportsFilterOperator.lessThan:
      return l10n.reportsFilterOperatorLessThan;
    case ReportsFilterOperator.equals:
      return l10n.reportsFilterOperatorEquals;
    case ReportsFilterOperator.isTrue:
      return l10n.reportsFilterOperatorIsTrue;
    case ReportsFilterOperator.isFalse:
      return l10n.reportsFilterOperatorIsFalse;
  }
}

extension on _AnalysisGroupBy {
  ReportsAnalysisGroupBy toRepoGroupBy() {
    switch (this) {
      case _AnalysisGroupBy.aircraft:
        return ReportsAnalysisGroupBy.aircraft;
      case _AnalysisGroupBy.type:
        return ReportsAnalysisGroupBy.type;
      case _AnalysisGroupBy.family:
        return ReportsAnalysisGroupBy.family;
      case _AnalysisGroupBy.airport:
        return ReportsAnalysisGroupBy.airport;
      case _AnalysisGroupBy.year:
        return ReportsAnalysisGroupBy.year;
      case _AnalysisGroupBy.month:
        return ReportsAnalysisGroupBy.month;
    }
  }

  String keyFor(
    ReportsFlightRow row, {
    required String unknownAircraft,
    required String unknownType,
    required String unknownFamily,
    required String unknownAirport,
  }) {
    switch (this) {
      case _AnalysisGroupBy.aircraft:
        return row.registration.trim().isEmpty
            ? unknownAircraft
            : row.registration;
      case _AnalysisGroupBy.type:
        return row.modelCode.trim().isEmpty ? unknownType : row.modelCode;
      case _AnalysisGroupBy.family:
        return row.modelFamily.trim().isEmpty ? unknownFamily : row.modelFamily;
      case _AnalysisGroupBy.airport:
        final fromIcao = row.fromIcao.trim();
        final toIcao = row.toIcao.trim();
        if (fromIcao.isNotEmpty) {
          return fromIcao;
        }
        if (toIcao.isNotEmpty) {
          return toIcao;
        }
        return unknownAirport;
      case _AnalysisGroupBy.year:
        return row.departureDateTime.year.toString();
      case _AnalysisGroupBy.month:
        return DateFormat('yyyy-MM').format(row.departureDateTime);
    }
  }
}

class _AnalysisGroupAccumulator {
  _AnalysisGroupAccumulator();

  factory _AnalysisGroupAccumulator.fromAggregateRow(
    ReportsAnalysisAggregateRow row,
  ) {
    return _AnalysisGroupAccumulator()
      ..totalMinutes = row.totalMinutes
      ..picMinutes = row.picMinutes
      ..picusMinutes = row.picusMinutes
      ..sicMinutes = row.sicMinutes
      ..dualMinutes = row.dualMinutes
      ..ifrMinutes = row.ifrMinutes
      ..nightMinutes = row.nightMinutes
      ..takeoffs = row.takeoffs
      ..landings = row.landings
      ..operations = row.operations
      ..firstFlightUtc = row.firstFlightUtc
      ..lastFlightUtc = row.lastFlightUtc;
  }

  int totalMinutes = 0;
  int picMinutes = 0;
  int picusMinutes = 0;
  int sicMinutes = 0;
  int dualMinutes = 0;
  int ifrMinutes = 0;
  int nightMinutes = 0;
  int takeoffs = 0;
  int landings = 0;
  int operations = 0;
  DateTime? firstFlightUtc;
  DateTime? lastFlightUtc;

  _AnalysisGroupAccumulator copy() {
    return _AnalysisGroupAccumulator()
      ..totalMinutes = totalMinutes
      ..picMinutes = picMinutes
      ..picusMinutes = picusMinutes
      ..sicMinutes = sicMinutes
      ..dualMinutes = dualMinutes
      ..ifrMinutes = ifrMinutes
      ..nightMinutes = nightMinutes
      ..takeoffs = takeoffs
      ..landings = landings
      ..operations = operations
      ..firstFlightUtc = firstFlightUtc
      ..lastFlightUtc = lastFlightUtc;
  }

  void addAll(_AnalysisGroupAccumulator other) {
    totalMinutes += other.totalMinutes;
    picMinutes += other.picMinutes;
    picusMinutes += other.picusMinutes;
    sicMinutes += other.sicMinutes;
    dualMinutes += other.dualMinutes;
    ifrMinutes += other.ifrMinutes;
    nightMinutes += other.nightMinutes;
    takeoffs += other.takeoffs;
    landings += other.landings;
    operations += other.operations;
    if (other.firstFlightUtc != null &&
        (firstFlightUtc == null ||
            other.firstFlightUtc!.isBefore(firstFlightUtc!))) {
      firstFlightUtc = other.firstFlightUtc;
    }
    if (other.lastFlightUtc != null &&
        (lastFlightUtc == null ||
            other.lastFlightUtc!.isAfter(lastFlightUtc!))) {
      lastFlightUtc = other.lastFlightUtc;
    }
  }

  void add(ReportsFlightRow row) {
    _addBase(row);
    takeoffs += row.takeoffs;
    landings += row.landings;
    operations += 1;
  }

  void addForAirport(
    ReportsFlightRow row, {
    required String airportIcao,
    required String unknownAirportLabel,
  }) {
    _addBase(row);
    final fromIcao = row.fromIcao.trim();
    final toIcao = row.toIcao.trim();
    final isUnknownBucket = airportIcao == unknownAirportLabel;
    final matchesFrom =
        fromIcao == airportIcao || (isUnknownBucket && fromIcao.isEmpty);
    final matchesTo =
        toIcao == airportIcao || (isUnknownBucket && toIcao.isEmpty);
    if (matchesFrom && row.takeoffs > 0) {
      takeoffs += row.takeoffs;
    }
    if (matchesTo && row.landings > 0) {
      landings += row.landings;
    }
    operations += 1;
  }

  void _addBase(ReportsFlightRow row) {
    totalMinutes += row.totalMinutes;
    picMinutes += row.picMinutes;
    picusMinutes += row.picusMinutes;
    sicMinutes += row.sicMinutes;
    dualMinutes += row.dualMinutes;
    ifrMinutes += row.ifrMinutes;
    nightMinutes += row.nightMinutes;
    if (firstFlightUtc == null ||
        row.departureDateTime.isBefore(firstFlightUtc!)) {
      firstFlightUtc = row.departureDateTime;
    }
    if (lastFlightUtc == null ||
        row.departureDateTime.isAfter(lastFlightUtc!)) {
      lastFlightUtc = row.departureDateTime;
    }
  }

  void addPreviousExperience(ReportsPreviousExperienceRow row) {
    totalMinutes += row.totalMinutes;
    picMinutes += row.picMinutes;
    picusMinutes += row.picusMinutes;
    sicMinutes += row.sicMinutes;
    dualMinutes += row.dualMinutes;
    ifrMinutes += row.ifrMinutes;
    nightMinutes += row.nightMinutes;
    takeoffs += row.takeoffs;
    landings += row.landings;
    operations += row.operations;
    final first = row.firstFlightUtc;
    final last = row.lastFlightUtc;
    if (first != null &&
        (firstFlightUtc == null || first.isBefore(firstFlightUtc!))) {
      firstFlightUtc = first;
    }
    if (last != null &&
        (lastFlightUtc == null || last.isAfter(lastFlightUtc!))) {
      lastFlightUtc = last;
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
    required this.fromTimeController,
    required this.toTimeController,
    required this.preset,
    required this.eventTypes,
    required this.savedQueries,
    required this.filters,
    required this.matchMode,
    required this.includePreviousExperience,
    required this.onPresetChanged,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onFromTimeChanged,
    required this.onToTimeChanged,
    required this.onEventTypesChanged,
    required this.onMatchModeChanged,
    required this.onAddFilter,
    required this.onRemoveFilter,
    required this.onToggleIncludePreviousExperience,
    required this.onSaveQuery,
    required this.onApplySavedQuery,
    required this.onDeleteSavedQuery,
    this.useOuterCardFrame = true,
  });

  final DateTime from;
  final DateTime to;
  final TextEditingController fromTimeController;
  final TextEditingController toTimeController;
  final _ReportDateRangePreset preset;
  final ReportsEventTypesSelection eventTypes;
  final List<SavedReportsQuery> savedQueries;
  final List<ReportsFilterCondition> filters;
  final ReportsFilterMatchMode matchMode;
  final bool includePreviousExperience;
  final Future<void> Function(_ReportDateRangePreset preset) onPresetChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final ValueChanged<int> onFromTimeChanged;
  final ValueChanged<int> onToTimeChanged;
  final Future<void> Function(ReportsEventTypesSelection) onEventTypesChanged;
  final Future<void> Function(ReportsFilterMatchMode mode) onMatchModeChanged;
  final Future<void> Function() onAddFilter;
  final Future<void> Function(int index) onRemoveFilter;
  final VoidCallback onToggleIncludePreviousExperience;
  final Future<void> Function() onSaveQuery;
  final Future<void> Function(SavedReportsQuery query) onApplySavedQuery;
  final Future<void> Function(String id) onDeleteSavedQuery;
  final bool useOuterCardFrame;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final topControlsHeight = compact ? 57.0 : 61.0;
        const sectionSpacingHeight = 21.0;
        final availableScrollableHeight = constraints.maxHeight.isFinite
            ? math
                  .max(
                    120,
                    constraints.maxHeight -
                        topControlsHeight -
                        sectionSpacingHeight,
                  )
                  .toDouble()
            : (compact ? 460.0 : 520.0);
        final locale = Localizations.localeOf(context).toString();
        final content = Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownInputField<String>(
                        label: l10n.reportsSavedQueriesLabel,
                        hintText: l10n.reportsSavedQueriesLabel,
                        items: savedQueries
                            .map(
                              (query) => DropdownMenuItem(
                                value: query.id,
                                child: _overflowText(query.name),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) return;
                          final query = savedQueries.firstWhere(
                            (item) => item.id == value,
                          );
                          unawaited(onApplySavedQuery(query));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Buttons(
                      onPressed: onSaveQuery,
                      label: l10n.saveAction,
                      variant: ButtonsVariant.filled,
                    ),
                    const SizedBox(width: 8),
                    if (savedQueries.isNotEmpty)
                      PopupMenuButton<String>(
                        onSelected: onDeleteSavedQuery,
                        itemBuilder: (context) => savedQueries
                            .map(
                              (query) => PopupMenuItem(
                                value: query.id,
                                child: Text(
                                  l10n.reportsDeleteSavedQuery(
                                    query.name,
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                        child: IgnorePointer(
                          child: Buttons(
                            onPressed: () {},
                            label: l10n.deleteAction,
                          ),
                        ),
                      )
                    else
                      Buttons(
                        onPressed: null,
                        label: l10n.deleteAction,
                      ),
                    const SizedBox(width: 8),
                    InfoHelpButton(
                      title: l10n.reportsFiltersHelpTitle,
                      message: l10n.reportsFiltersHelpBody,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: compact ? 168 : 190,
                    child: EventTypeToggleButton(
                      label: l10n.reportsPreviousExperienceLabel,
                      selected: includePreviousExperience,
                      onTap: onToggleIncludePreviousExperience,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                SizedBox(
                  height: math.min(
                    availableScrollableHeight,
                    compact ? 460 : 520,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: EventTypeToggleButton(
                                    label: l10n.logbookEventFlight,
                                    selected: eventTypes.flights,
                                    onTap: () => onEventTypesChanged(
                                      eventTypes.copyWith(
                                        flights: !eventTypes.flights,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: EventTypeToggleButton(
                                    label: l10n.fieldIsSimulator,
                                    selected: eventTypes.simulator,
                                    onTap: () => onEventTypesChanged(
                                      eventTypes.copyWith(
                                        simulator: !eventTypes.simulator,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: EventTypeToggleButton(
                                    label: l10n.reportsMetricDuty,
                                    selected: eventTypes.duty,
                                    onTap: () => onEventTypesChanged(
                                      eventTypes.copyWith(
                                        duty: !eventTypes.duty,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: EventTypeToggleButton(
                                    label: l10n.logbookEventPositioning,
                                    selected: eventTypes.positioning,
                                    onTap: () => onEventTypesChanged(
                                      eventTypes.copyWith(
                                        positioning: !eventTypes.positioning,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReportsEnumDropdownField<_ReportDateRangePreset>(
                              value: preset,
                              label: l10n.logbookFilterRange,
                              options: _ReportDateRangePreset.values.toList(
                                growable: false,
                              ),
                              optionLabel: (value) =>
                                  _reportDateRangePresetLabel(l10n, value),
                              onChanged: (value) =>
                                  unawaited(onPresetChanged(value)),
                            ),
                            const SizedBox(height: 8),
                            DateAndHourRow(
                              dateLabel: l10n.logbookFilterFromDate,
                              dateValueText: DateFormat(
                                'dd/MMM yyyy',
                                locale,
                              ).format(from),
                              onPickDate: onPickStart,
                              timeController: fromTimeController,
                              onTimeChanged: onFromTimeChanged,
                            ),
                            const SizedBox(height: 8),
                            DateAndHourRow(
                              dateLabel: l10n.logbookFilterToDate,
                              dateValueText: DateFormat(
                                'dd/MMM yyyy',
                                locale,
                              ).format(to),
                              onPickDate: onPickEnd,
                              timeController: toTimeController,
                              onTimeChanged: onToTimeChanged,
                            ),
                            const SizedBox(height: 8),
                            ReportsEnumDropdownField<ReportsFilterMatchMode>(
                              value: matchMode,
                              label: l10n.reportsMatchModeLabel,
                              options: const [
                                ReportsFilterMatchMode.all,
                                ReportsFilterMatchMode.any,
                              ],
                              optionLabel: (value) =>
                                  value == ReportsFilterMatchMode.all
                                  ? l10n.reportsMatchAll
                                  : l10n.reportsMatchAny,
                              onChanged: (value) =>
                                  unawaited(onMatchModeChanged(value)),
                            ),
                            const SizedBox(height: 8),
                            Buttons(
                              onPressed: onAddFilter,
                              icon: Icons.add,
                              label: compact
                                  ? l10n.addAction
                                  : l10n.reportsAddFilter,
                              variant: ButtonsVariant.filled,
                            ),
                          ],
                        ),
                        if (filters.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (
                                var index = 0;
                                index < filters.length;
                                index++
                              )
                                InputChip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(
                                    l10n.reportsFilterChipLabel(
                                      _reportFilterFieldLabel(
                                        l10n,
                                        filters[index].field,
                                      ),
                                      _reportFilterOperatorLabel(
                                        l10n,
                                        filters[index].operator,
                                      ),
                                      filters[index].displayValue,
                                    ),
                                  ),
                                  onDeleted: () => onRemoveFilter(index),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        if (!useOuterCardFrame) {
          return content;
        }
        return Card(child: content);
      },
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.totals,
    required this.customTimeLabels,
    this.firstFlightDate,
    this.lastFlightDate,
  });

  final ReportsTotals totals;
  final CustomTimeLabels customTimeLabels;
  final DateTime? firstFlightDate;
  final DateTime? lastFlightDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compact = MediaQuery.sizeOf(context).width < 600;
    final operations = <(String, String)>[
      (l10n.reportsMetricDistanceNm, _formatCount(totals.distanceNM)),
      (l10n.reportsMetricIfrApproaches, _formatCount(totals.ifrApproaches)),
      (l10n.reportsMetricTakeoffDay, _formatCount(totals.takeoffsDay)),
      (l10n.reportsMetricTakeoffNight, _formatCount(totals.takeoffsNight)),
      (l10n.reportsMetricLandingDay, _formatCount(totals.landingsDay)),
      (l10n.reportsMetricLandingNight, _formatCount(totals.landingsNight)),
    ];
    final times = <(String, String)>[
      (l10n.reportsMetricPic, _formatMinutes(totals.picMinutes)),
      (l10n.reportsMetricPicus, _formatMinutes(totals.picusMinutes)),
      (l10n.reportsMetricSic, _formatMinutes(totals.sicMinutes)),
      (l10n.reportsMetricDual, _formatMinutes(totals.dualMinutes)),
      (l10n.reportsMetricInstructor, _formatMinutes(totals.instructorMinutes)),
      (l10n.reportsMetricIfr, _formatMinutes(totals.ifrMinutes)),
      (l10n.reportsMetricNight, _formatMinutes(totals.nightMinutes)),
      (
        l10n.reportsMetricCrossCountry,
        _formatMinutes(totals.crossCountryMinutes),
      ),
      (customTimeLabels.custom1, _formatMinutes(totals.custom1Minutes)),
      (customTimeLabels.custom2, _formatMinutes(totals.custom2Minutes)),
      (customTimeLabels.custom3, _formatMinutes(totals.custom3Minutes)),
      (customTimeLabels.custom4, _formatMinutes(totals.custom4Minutes)),
      (
        l10n.reportsFilterFieldFlightTime,
        _formatMinutes(totals.flightMinutes),
      ),
      (l10n.reportsMetricTotalBlock, _formatMinutes(totals.totalMinutes)),
      (l10n.reportsMetricSimulator, _formatMinutes(totals.simulatorMinutes)),
      (l10n.reportsMetricDuty, _formatMinutes(totals.dutyMinutes)),
    ];
    final dateFormatter = DateFormat('dd/MMM/yyyy');
    final firstDateLabel = firstFlightDate == null
        ? '-'
        : dateFormatter.format(firstFlightDate!.toUtc());
    final lastDateLabel = lastFlightDate == null
        ? '-'
        : dateFormatter.format(lastFlightDate!.toUtc());
    final dateRangeLabel = 'First: $firstDateLabel | Last: $lastDateLabel';

    return Card(
      margin: compact ? EdgeInsets.zero : const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectionArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactHeader = constraints.maxWidth < 560;
              return Column(
                children: [
                  if (compactHeader)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Count: ${_formatCount(totals.sectors)}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            dateRangeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Text(
                          l10n.reportsFlightCount(_formatCount(totals.sectors)),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            dateRangeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.end,
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
              );
            },
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
        final isPhoneMiniWidth = constraints.maxWidth < 390;
        final spacing = isPhoneMiniWidth ? 6.0 : 8.0;
        final columns = isPhoneMiniWidth
            ? 2
            : constraints.maxWidth >= 900
            ? 6
            : (constraints.maxWidth / 170.0).floor().clamp(1, 4);
        final tileWidth =
            (constraints.maxWidth - (columns - 1) * spacing) / columns;
        final tilePadding = isPhoneMiniWidth
            ? const EdgeInsets.symmetric(horizontal: 7, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 7);
        final labelFontSize = isPhoneMiniWidth ? 10.0 : 11.0;
        final valueFontSize = isPhoneMiniWidth ? 13.0 : 14.0;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: tileWidth,
                child: Container(
                  padding: tilePadding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
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
                          fontSize: labelFontSize,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        metric.$2,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: valueFontSize,
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
    final l10n = AppLocalizations.of(context)!;
    final compact = MediaQuery.sizeOf(context).width < 600;
    if (groups.isEmpty) {
      return Card(
        margin: compact ? EdgeInsets.zero : const EdgeInsets.all(4),
        child: Center(child: Text(l10n.reportsNoDataForQuery)),
      );
    }

    final maxTotal = groups.fold<int>(
      0,
      (maxValue, group) => group.totals.totalMinutes > maxValue
          ? group.totals.totalMinutes
          : maxValue,
    );

    return ListView.separated(
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          margin: compact ? EdgeInsets.zero : const EdgeInsets.all(4),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            title: _AnalysisBarRow(
              label: group.title,
              valueText: _formatMinutes(group.totals.totalMinutes),
              ratio: maxTotal > 0 ? group.totals.totalMinutes / maxTotal : 0,
              emphasized: true,
            ),
            children: [
              _AnalysisBarRow(
                label: l10n.reportsMetricPic,
                valueText: _formatMinutes(group.totals.picMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.picMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: l10n.reportsMetricPicus,
                valueText: _formatMinutes(group.totals.picusMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.picusMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: l10n.reportsMetricSic,
                valueText: _formatMinutes(group.totals.sicMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.sicMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: l10n.reportsMetricDual,
                valueText: _formatMinutes(group.totals.dualMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.dualMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: l10n.reportsMetricNight,
                valueText: _formatMinutes(group.totals.nightMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.nightMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: l10n.reportsMetricIfr,
                valueText: _formatMinutes(group.totals.ifrMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.ifrMinutes / group.totals.totalMinutes
                    : 0,
              ),
              _AnalysisBarRow(
                label: l10n.reportsMetricLandings,
                valueText: '${group.totals.landings}',
                ratio: group.totals.operations > 0
                    ? group.totals.landings / group.totals.operations
                    : 0,
              ),
              _AnalysisBarRow(
                label: l10n.reportsMetricTakeoff,
                valueText: '${group.totals.takeoffs}',
                ratio: group.totals.operations > 0
                    ? group.totals.takeoffs / group.totals.operations
                    : 0,
              ),
              _AnalysisBarRow(
                label: l10n.reportsMetricOperations,
                valueText: '${group.totals.operations}',
                ratio: 1,
              ),
              const SizedBox(height: 8),
              if (group.totals.firstFlightUtc != null)
                Text(
                  l10n.reportsFirstFlightAt(
                    DateFormat(
                      'dd MMM yyyy HH:mm',
                    ).format(group.totals.firstFlightUtc!),
                  ),
                ),
              if (group.totals.lastFlightUtc != null)
                Text(
                  l10n.reportsLastFlightAt(
                    DateFormat(
                      'dd MMM yyyy HH:mm',
                    ).format(group.totals.lastFlightUtc!),
                  ),
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
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
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
    _operator = _operatorsForField(_field).first;
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
      _operator = _operatorsForField(value).first;
      _textController.clear();
      _numberController.clear();
      _timeController.text = '0:00';
    });
  }

  List<ReportsFilterField> _availableFields() {
    return ReportsFilterField.values.toList(growable: false);
  }

  List<ReportsFilterOperator> _operatorsForField(ReportsFilterField field) {
    return field.valueType.supportedOperators;
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

    AppNavigator.pop(
      context,
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
    final l10n = AppLocalizations.of(context)!;
    final operators = _operatorsForField(_field);
    final fields = _availableFields();
    return ReportsDialogScaffoldSection(
      title: l10n.reportsAddFilter,
      actionLabel: l10n.addAction,
      onAction: _save,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportsEnumDropdownField<ReportsFilterField>(
            value: _field,
            label: l10n.reportsFieldNameLabel,
            options: fields,
            optionLabel: (field) => _reportFilterFieldLabel(l10n, field),
            onChanged: _onFieldChanged,
          ),
          const SizedBox(height: 12),
          ReportsEnumDropdownField<ReportsFilterOperator>(
            value: _operator,
            label: l10n.reportsConditionLabel,
            options: operators,
            optionLabel: (operator) =>
                _reportFilterOperatorLabel(l10n, operator),
            onChanged: (value) => setState(() => _operator = value),
          ),
          if (_field.valueType != ReportsFilterValueType.boolean) ...[
            const SizedBox(height: 12),
            _buildValueField(),
          ],
        ],
      ),
    );
  }

  Widget _buildValueField() {
    final l10n = AppLocalizations.of(context)!;
    switch (_field.valueType) {
      case ReportsFilterValueType.text:
        return ReportsLabeledInputField(
          controller: _textController,
          label: l10n.reportsValueLabel,
        );
      case ReportsFilterValueType.number:
        return ReportsLabeledInputField(
          controller: _numberController,
          label: l10n.reportsValueLabel,
          keyboardType: TextInputType.number,
        );
      case ReportsFilterValueType.time:
        return TimeInputField(
          controller: _timeController,
          label: l10n.reportsValueLabel,
        );
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
    final l10n = AppLocalizations.of(context)!;
    return ReportsDialogScaffoldSection(
      title: l10n.reportsSaveQuery,
      actionLabel: l10n.saveAction,
      maxWidth: 420,
      onAction: () => AppNavigator.pop(context, _controller.text),
      content: ReportsLabeledInputField(
        controller: _controller,
        label: l10n.fieldName,
      ),
    );
  }
}

class _EntriesPanel extends StatelessWidget {
  const _EntriesPanel({required this.entries, required this.onEntryTap});

  final List<LogbookEntry> entries;
  final ValueChanged<LogbookEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.reportsFlightsAndSimulatorTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  l10n.reportsEntriesCount(entries.length),
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
                  ? Center(child: Text(l10n.reportsNoFlightsInPeriod))
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
    required this.mapData,
    this.fullscreen = false,
    this.initialShowLines = true,
  });

  final ReportsMapData mapData;
  final bool fullscreen;
  final bool initialShowLines;

  @override
  State<_FlightsMapDialog> createState() => _FlightsMapDialogState();
}

class _FlightsMapDialogState extends State<_FlightsMapDialog> {
  late bool _showLines;

  @override
  void initState() {
    super.initState();
    _showLines = widget.initialShowLines;
  }

  Future<void> _exportInteractiveHtmlMap() async {
    final l10n = AppLocalizations.of(context)!;
    final html = _buildInteractiveMapHtml();
    const fileName = 'SimpleLogMap.html';
    final bytes = Uint8List.fromList(utf8.encode(html));

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Interactive Flight Map',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['html'],
      bytes: Platform.isIOS || Platform.isAndroid ? bytes : null,
    );
    if (path == null || path.isEmpty || !mounted) return;

    if (!Platform.isIOS && !Platform.isAndroid) {
      try {
        await File(path).writeAsBytes(bytes, flush: true);
      } on FileSystemException {
        final docsDir = await getApplicationDocumentsDirectory();
        final fallbackPath =
            '${docsDir.path}${Platform.pathSeparator}$fileName';
        await File(fallbackPath).writeAsBytes(bytes, flush: true);
        if (!mounted) return;
        await showAppMessageDialog(
          context,
          title: l10n.reportsFlightMapTitle,
          message:
              'Interactive map exported.\n\n'
              'Requested location was not writable.\n'
              'Saved to: $fallbackPath\n\n'
              'You can open or share this HTML file directly.',
        );
        return;
      }
    }

    if (!mounted) return;
    await showAppMessageDialog(
      context,
      title: l10n.reportsFlightMapTitle,
      message:
          'Interactive map exported.\n\n'
          'File: $path\n\n'
          'You can open or share this HTML file directly.',
    );
  }

  String _buildInteractiveMapHtml() {
    final points = <Map<String, dynamic>>[];
    final routeFeatures = widget.mapData.routes.map((route) {
      final fromPoint = LatLng(route.airportALatitude, route.airportALongitude);
      final toPoint = LatLng(route.airportBLatitude, route.airportBLongitude);
      final greatCircle = _greatCirclePointsForHtml(
        fromPoint,
        toPoint,
        segments: 24,
      );
      final coordinates = greatCircle
          .map((p) => [_roundCoord(p.longitude), _roundCoord(p.latitude)])
          .toList(growable: false);
      return <String, dynamic>{
        'type': 'Feature',
        'geometry': {'type': 'LineString', 'coordinates': coordinates},
        'properties': {
          'route': '${route.airportAIcao} ↔ ${route.airportBIcao}',
          'fromIcao': route.airportAIcao,
          'toIcao': route.airportBIcao,
          'count': route.flightsTotal,
        },
      };
    }).toList();

    for (final airport in widget.mapData.airports) {
      points.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [
            _roundCoord(airport.longitude),
            _roundCoord(airport.latitude),
          ],
        },
        'properties': {'icao': airport.icao},
      });
    }

    final collection = {
      'type': 'FeatureCollection',
      'features': [...routeFeatures, ...points],
    };
    final geoJson = const JsonEncoder.withIndent('  ').convert(collection);
    final center = _centerFromAirports(widget.mapData.airports);
    final centerLat = (center.$1 + center.$3) / 2;
    final centerLon = (center.$2 + center.$4) / 2;

    return '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>SimpleLog Interactive Flight Map</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    html, body { margin: 0; height: 100%; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
    #layout { height: 100%; display: grid; grid-template-rows: 56px 1fr; }
    #topbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 14px;
      border-bottom: 1px solid #dce4ef;
      background: #0f243f;
      color: #e7eef8;
    }
    #title { font-size: 14px; font-weight: 600; letter-spacing: 0.02em; }
    #stats { font-size: 12px; color: #bfd1eb; }
    #map { width: 100%; height: 100%; }
    .leaflet-popup-content { margin: 8px 10px; line-height: 1.35; }
    .leaflet-control-attribution { font-size: 10px; }
    #note {
      position: fixed;
      left: 12px;
      bottom: 12px;
      z-index: 500;
      background: rgba(15, 31, 54, 0.9);
      color: #dbe7f8;
      font-size: 12px;
      padding: 8px 10px;
      border-radius: 8px;
    }
  </style>
</head>
<body>
  <div id="layout">
    <div id="topbar">
      <div id="title">SimpleLog Interactive Flight Map</div>
      <div id="stats"></div>
    </div>
    <div id="map"></div>
  </div>
  <div id="note">Interactive map: pan, zoom, click flights and airports</div>
  <script>
    const flights = $geoJson;
    const stats = document.getElementById('stats');
    const lineFeatures = flights.features.filter(function(f) {
      return f.geometry && f.geometry.type === 'LineString';
    });
    const pointFeatures = flights.features.filter(function(f) {
      return f.geometry && f.geometry.type === 'Point';
    });
    const airportSet = new Set(
      pointFeatures
        .map(function(f) { return ((f.properties && f.properties.icao) || '').trim(); })
        .filter(Boolean)
    );
    stats.textContent = lineFeatures.length + ' routes · ' + airportSet.size + ' airports';

    const map = L.map('map').setView([${centerLat.toStringAsFixed(8)}, ${centerLon.toStringAsFixed(8)}], 2);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    const routeLayer = L.geoJSON(flights, {
      style: function(feature) {
        if (feature.geometry && feature.geometry.type === 'LineString') {
          return { color: '#2f7de1', weight: 2, opacity: 0.75 };
        }
        return { color: '#0f7f74', weight: 1, fillColor: '#2dd4bf', fillOpacity: 0.9 };
      },
      pointToLayer: function(feature, latlng) {
        return L.circleMarker(latlng, {
          radius: 4,
          color: '#0f7f74',
          weight: 1,
          fillColor: '#2dd4bf',
          fillOpacity: 0.9
        });
      },
      onEachFeature: function(feature, layer) {
        const p = feature.properties || {};
        if (feature.geometry && feature.geometry.type === 'LineString') {
          layer.bindPopup(
            '<b>' + (p.route || ((p.fromIcao || '-') + ' ↔ ' + (p.toIcao || '-'))) + '</b><br>' +
            Number(p.count || 0) + ' flights'
          );
          return;
        }
        const c = feature.geometry && feature.geometry.coordinates
          ? feature.geometry.coordinates
          : [0, 0];
        layer.bindPopup(
          '<b>Airport:</b> ' + (p.icao || '-') + '<br>' +
          Number(c[1] || 0).toFixed(4) + ', ' + Number(c[0] || 0).toFixed(4)
        );
      }
    }).addTo(map);

    if (routeLayer.getBounds && routeLayer.getBounds().isValid()) {
      map.fitBounds(routeLayer.getBounds(), { padding: [24, 24] });
    }
  </script>
</body>
</html>
''';
  }

  double _roundCoord(double value) {
    return double.parse(value.toStringAsFixed(5));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pairs = widget.mapData.routes
        .map(
          (route) => FlightRoutePair(
            from: LatLng(route.airportALatitude, route.airportALongitude),
            to: LatLng(route.airportBLatitude, route.airportBLongitude),
          ),
        )
        .toList(growable: false);
    final airportCount = widget.mapData.airports.length;

    final mapBody = pairs.isEmpty
        ? Center(child: Text(l10n.reportsNoCoordinatesAvailable))
        : FlightRoutesMapView(
            pairs: pairs,
            airportCountLabel: l10n.reportsAirportsCount(airportCount),
            showLines: _showLines,
          );

    final actions = <Widget>[
      IconButton(
        tooltip: _showLines ? l10n.reportsHideLines : l10n.reportsShowLines,
        onPressed: () => setState(() => _showLines = !_showLines),
        icon: Icon(_showLines ? Icons.route : Icons.scatter_plot),
      ),
      IconButton(
        tooltip: l10n.reportsExportInteractiveMap,
        onPressed: _exportInteractiveHtmlMap,
        icon: const Icon(Icons.ios_share_outlined),
      ),
    ];

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.reportsFlightMapTitle,
      popupMaxWidth: 1100,
      actions: actions,
      contentView: mapBody,
    );
  }

  List<LatLng> _greatCirclePointsForHtml(
    LatLng from,
    LatLng to, {
    int segments = 48,
  }) {
    final lat1 = from.latitude * math.pi / 180.0;
    final lon1 = from.longitude * math.pi / 180.0;
    final lat2 = to.latitude * math.pi / 180.0;
    final lon2 = to.longitude * math.pi / 180.0;

    final d =
        2 *
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

      final x =
          a * math.cos(lat1) * math.cos(lon1) +
          b * math.cos(lat2) * math.cos(lon2);
      final y =
          a * math.cos(lat1) * math.sin(lon1) +
          b * math.cos(lat2) * math.sin(lon2);
      final z = a * math.sin(lat1) + b * math.sin(lat2);

      final lat = math.atan2(z, math.sqrt(x * x + y * y));
      final lon = math.atan2(y, x);
      points.add(LatLng(lat * 180.0 / math.pi, lon * 180.0 / math.pi));
    }
    return points;
  }

  (double, double, double, double) _centerFromAirports(
    List<ReportsMapAirportPoint> airports,
  ) {
    if (airports.isEmpty) return (-45, -90, 45, 90);
    var minLat = airports.first.latitude;
    var maxLat = airports.first.latitude;
    var minLon = airports.first.longitude;
    var maxLon = airports.first.longitude;
    for (final airport in airports.skip(1)) {
      minLat = math.min(minLat, airport.latitude);
      maxLat = math.max(maxLat, airport.latitude);
      minLon = math.min(minLon, airport.longitude);
      maxLon = math.max(maxLon, airport.longitude);
    }
    return (minLat, minLon, maxLat, maxLon);
  }
}

class _TemplateEntryItem {
  const _TemplateEntryItem({
    required this.templateName,
    required this.templateJson,
  });

  final String templateName;
  final String templateJson;
}

class _EditTemplatesDialog extends StatefulWidget {
  const _EditTemplatesDialog({
    required this.db,
  });

  final AppDatabase db;

  @override
  State<_EditTemplatesDialog> createState() => _EditTemplatesDialogState();
}

class _EditTemplatesDialogState extends State<_EditTemplatesDialog> {
  static const _sharedCoverTemplateNames = <String>['cover_page_default'];

  List<_TemplateEntryItem> _items = const [];
  bool _isBusy = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadItems());
  }

  String _displayTemplateName(String rawName) {
    if (rawName == 'cover_page_default') {
      return 'Cover Page';
    }
    return rawName;
  }

  Future<void> _loadItems() async {
    setState(() => _isBusy = true);
    final rows = await (widget.db.select(
      widget.db.reportTemplates,
    )..orderBy([(t) => d.OrderingTerm.asc(t.templateName)])).get();
    if (!mounted) {
      return;
    }
    final items = <_TemplateEntryItem>[];
    for (final row in rows) {
      items.add(
        _TemplateEntryItem(
          templateName: row.templateName,
          templateJson: row.templateJson,
        ),
      );
    }
    final existingNames = items
        .map((item) => item.templateName.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    for (final name in _sharedCoverTemplateNames) {
      if (existingNames.contains(name)) continue;
      try {
        final raw = await rootBundle.loadString(
          'assets/reports/templates/$name.json',
        );
        final parsed = jsonDecode(raw);
        if (parsed is! Map<String, dynamic>) continue;
        items.add(
          _TemplateEntryItem(
            templateName: name,
            templateJson: const JsonEncoder.withIndent('  ').convert(parsed),
          ),
        );
      } on Object {
        continue;
      }
    }
    items.sort((a, b) {
      if (a.templateName == 'cover_page_default') {
        return -1;
      }
      if (b.templateName == 'cover_page_default') {
        return 1;
      }
      return a.templateName.toLowerCase().compareTo(
        b.templateName.toLowerCase(),
      );
    });
    if (mounted) {
      setState(() {
        _items = items;
        _isBusy = false;
      });
    }
  }

  Future<void> _downloadTemplate(_TemplateEntryItem item) async {
    final decodedRaw = jsonDecode(item.templateJson);
    if (decodedRaw is! Map<String, dynamic>) {
      if (!mounted) return;
      await showAppMessageDialog(context, message: 'Template JSON is invalid.');
      return;
    }
    final decoded = await _resolveTemplateJsonForExport(
      Map<String, dynamic>.from(decodedRaw),
    );
    if (decoded['coverPage'] is Map<String, dynamic>) {
      decoded.remove('coverPageImport');
    }
    decoded['templateName'] ??= item.templateName;
    decoded
      ..remove('reportName')
      ..remove('displayName');
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save template JSON',
      fileName: '${item.templateName}.json',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (outputPath == null || outputPath.isEmpty) {
      return;
    }
    await File(outputPath).writeAsString(jsonEncode(decoded), flush: true);
    if (!mounted) {
      return;
    }
    await showAppMessageDialog(context, message: 'Template exported.');
  }

  Future<Map<String, dynamic>> _resolveTemplateJsonForExport(
    Map<String, dynamic> templateJson,
  ) async {
    final importKey = (templateJson['coverPageImport'] ?? '').toString().trim();
    if (importKey.isEmpty ||
        templateJson['coverPage'] is Map<String, dynamic>) {
      return templateJson;
    }
    try {
      final dbRow = await (widget.db.select(
        widget.db.reportTemplates,
      )..where((t) => t.templateName.equals(importKey))).getSingleOrNull();
      if (dbRow != null && dbRow.templateJson.trim().isNotEmpty) {
        final dbJson = jsonDecode(dbRow.templateJson);
        if (dbJson is Map<String, dynamic>) {
          if (dbJson['coverPage'] is Map<String, dynamic>) {
            templateJson['coverPage'] = dbJson['coverPage'];
          } else {
            templateJson['coverPage'] = dbJson;
          }
          return templateJson;
        }
      }
      final importedRaw = await rootBundle.loadString(
        'assets/reports/templates/$importKey.json',
      );
      final importedJson = jsonDecode(importedRaw);
      if (importedJson is Map<String, dynamic>) {
        if (importedJson['coverPage'] is Map<String, dynamic>) {
          templateJson['coverPage'] = importedJson['coverPage'];
        } else {
          templateJson['coverPage'] = importedJson;
        }
      }
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
    return templateJson;
  }

  Future<void> _deleteTemplate(_TemplateEntryItem item) async {
    if (item.templateName == 'cover_page_default') {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.reportsDeleteTemplateTitle),
          content: Text(
            AppLocalizations.of(
              context,
            )!.reportsDeleteTemplateBody(item.templateName),
          ),
          actions: [
            TextButton(
              onPressed: () => AppNavigator.pop(dialogContext, false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => AppNavigator.pop(dialogContext, true),
              child: Text(AppLocalizations.of(context)!.deleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    await widget.db.customStatement(
      'DELETE FROM report_templates WHERE template_name = ?',
      [item.templateName],
    );
    _changed = true;
    await _loadItems();
  }

  Future<void> _editTemplate(_TemplateEntryItem item) async {
    final prettyJson = () {
      try {
        final decoded = jsonDecode(item.templateJson);
        if (decoded is Map<String, dynamic>) {
          return const JsonEncoder.withIndent('  ').convert(decoded);
        }
      } on Object catch (error, stackTrace) {
        Zone.current.handleUncaughtError(error, stackTrace);
      }
      return item.templateJson;
    }();

    final editedJson = await _presentAdaptiveShellDialog<String>(
      _TemplateJsonEditorDialog(
        templateName: item.templateName,
        initialJson: prettyJson,
      ),
    );
    if (editedJson == null) {
      return;
    }

    final raw = editedJson.trim();
    if (raw.isEmpty) {
      if (!mounted) return;
      await showAppMessageDialog(context, message: 'Template JSON is empty.');
      return;
    }

    late final Map<String, dynamic> decoded;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('Template JSON must be an object.');
      }
      decoded = parsed;
    } on Object {
      if (!mounted) return;
      await showAppMessageDialog(
        context,
        message: 'Template JSON is invalid. Fix the JSON and try again.',
      );
      return;
    }

    decoded
      ..remove('reportName')
      ..remove('displayName')
      ..['templateName'] = item.templateName;

    await widget.db.customStatement(
      'INSERT INTO report_templates (template_name, template_json) '
      'VALUES (?, ?) '
      'ON CONFLICT(template_name) DO UPDATE SET '
      'template_json = excluded.template_json',
      [item.templateName, jsonEncode(decoded)],
    );
    _changed = true;
    await _loadItems();
    if (!mounted) return;
    await showAppMessageDialog(context, message: 'Template updated.');
  }

  Future<void> _uploadAsNewTemplate() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return;
    }
    final file = picked.files.single;
    String? raw;
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      raw = utf8.decode(file.bytes!);
    } else if (file.path != null && file.path!.isNotEmpty) {
      raw = await File(file.path!).readAsString();
    }
    if (raw == null || raw.trim().isEmpty) {
      if (!mounted) return;
      await showAppMessageDialog(context, message: 'Selected JSON is empty.');
      return;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      if (!mounted) return;
      await showAppMessageDialog(context, message: 'Selected JSON is invalid.');
      return;
    }
    final templateName = _templateNameFromFile(file);
    decoded['templateName'] = templateName;
    decoded
      ..remove('reportName')
      ..remove('displayName');
    await widget.db.customStatement(
      'INSERT INTO report_templates '
      '(template_name, template_json) VALUES (?, ?)',
      [templateName, jsonEncode(decoded)],
    );
    _changed = true;
    await _loadItems();
  }

  String _templateNameFromFile(PlatformFile file) {
    final sourceName = file.name.trim().isNotEmpty
        ? file.name.trim()
        : _fileNameFromPath(file.path);
    final withoutExtension = _removeJsonExtension(sourceName).trim();
    final sanitized = _sanitizeTemplateName(withoutExtension);
    final baseName = sanitized.isEmpty ? 'template' : sanitized;
    return _makeUniqueTemplateName(baseName);
  }

  String _fileNameFromPath(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }
    final normalized = path.replaceAll(String.fromCharCode(92), '/');
    final segments = normalized.split('/');
    return segments.isEmpty ? normalized : segments.last;
  }

  String _removeJsonExtension(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.toLowerCase().endsWith('.json')) {
      return trimmed.substring(0, trimmed.length - 5);
    }
    return trimmed;
  }

  String _makeUniqueTemplateName(String baseName) {
    final usedNames = _items.map((item) => item.templateName).toSet();
    if (!usedNames.contains(baseName)) {
      return baseName;
    }
    var suffix = 1;
    while (usedNames.contains('$baseName ($suffix)')) {
      suffix++;
    }
    return '$baseName ($suffix)';
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: _isBusy
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final canDelete =
                          item.templateName != 'cover_page_default';
                      final tile = ListTile(
                        title: Text(_displayTemplateName(item.templateName)),
                      );
                      if (isCompact) {
                        final actions = <Widget>[
                          SlidableAction(
                            onPressed: (_) => unawaited(_editTemplate(item)),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            icon: Icons.edit_note,
                          ),
                          SlidableAction(
                            onPressed: (_) =>
                                unawaited(_downloadTemplate(item)),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            icon: Icons.download,
                          ),
                        ];
                        if (canDelete) {
                          actions.add(
                            SlidableAction(
                              onPressed: (_) =>
                                  unawaited(_deleteTemplate(item)),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onError,
                              icon: Icons.delete_outline,
                            ),
                          );
                        }
                        return Slidable(
                          key: ValueKey(item.templateName),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: actions,
                          ),
                          child: tile,
                        );
                      }
                      final trailingActions = <Widget>[
                        SquareOutlineButton(
                          onPressed: () => unawaited(_editTemplate(item)),
                          icon: Icons.edit_note,
                          label: AppLocalizations.of(context)!.editAction,
                        ),
                        SquareOutlineButton(
                          onPressed: () => unawaited(_downloadTemplate(item)),
                          icon: Icons.download,
                          label: AppLocalizations.of(
                            context,
                          )!.reportsDownloadAction,
                        ),
                      ];
                      if (canDelete) {
                        trailingActions.add(
                          SquareOutlineButton(
                            onPressed: () => unawaited(_deleteTemplate(item)),
                            icon: Icons.delete_outline,
                            label: AppLocalizations.of(context)!.deleteAction,
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(_displayTemplateName(item.templateName)),
                        trailing: Wrap(
                          spacing: 8,
                          children: trailingActions,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context, _changed),
      title: AppLocalizations.of(context)!.reportsEditTemplates,
      actions: [
        TextButton(
          onPressed: _uploadAsNewTemplate,
          child: Text(AppLocalizations.of(context)!.reportsUploadJson),
        ),
      ],
      popupMaxWidth: 980,
      contentView: body,
    );
  }

  Future<T?> _presentAdaptiveShellDialog<T>(Widget child) async {
    if (isCompactDialogScreen(context)) {
      return AppNavigator.pushMaterial<T>(
        context,
        (_) => child,
        rootNavigator: true,
      );
    }
    return showDialog<T>(
      context: context,
      builder: (_) => child,
    );
  }
}

class _TemplateJsonEditorDialog extends StatefulWidget {
  const _TemplateJsonEditorDialog({
    required this.templateName,
    required this.initialJson,
  });

  final String templateName;
  final String initialJson;

  @override
  State<_TemplateJsonEditorDialog> createState() =>
      _TemplateJsonEditorDialogState();
}

class _TemplateJsonEditorDialogState extends State<_TemplateJsonEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialJson);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Template JSON',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => AppNavigator.pop(context),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => AppNavigator.pop(context, _controller.text),
                child: Text(AppLocalizations.of(context)!.saveAction),
              ),
            ],
          ),
        ],
      ),
    );

    final title = AppLocalizations.of(context)!.reportsEditTemplates;
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: title,
      popupMaxWidth: 980,
      contentView: body,
    );
  }
}

Widget _overflowText(String value) {
  return Text(
    value,
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.ellipsis,
  );
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
