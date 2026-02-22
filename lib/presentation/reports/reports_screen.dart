import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:simplelog/core/maps/map_tile_caching.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/report_pdf_models.dart';
import 'package:simplelog/data/reports/report_xsl_template_loader.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/features/reports/application/report_pdf_application_service.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/presentation/reports/providers/report_pdf_application_service_provider.dart';
import 'package:simplelog/presentation/reports/providers/reports_preferences_provider.dart';
import 'package:simplelog/presentation/reports/providers/reports_repository_provider.dart';
import 'package:simplelog/presentation/shared/widgets/app_message_dialog.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/time_input_field.dart';
import 'package:simplelog/state/providers/custom_time_labels_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

enum ReportsPanelSection {
  overview,
  flights,
  analizes,
  reports,
  filters,
  totals,
}

class _XslTemplateOption {
  const _XslTemplateOption({
    required this.fileName,
    required this.description,
    required this.numberOfLines,
    required this.template,
  });

  final String fileName;
  final String description;
  final int numberOfLines;
  final ReportPdfTemplate template;
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key, this.section});

  final ReportsPanelSection? section;

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
  bool _pendingDetailsLoad = false;
  String? _error;

  ReportsData _data = const ReportsData(
    totals: ReportsTotals.zero(),
    flights: [],
  );
  List<LogbookEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    final runtimeQuery = ref.read(reportsRuntimeQueryProvider);
    _from = runtimeQuery.from;
    _to = runtimeQuery.to;
    _filterMatchMode = runtimeQuery.matchMode;
    _filters
      ..clear()
      ..addAll(runtimeQuery.filters);
    _tabController = TabController(length: 3, vsync: this);
    _loadTemplateOptions();
    _loadOverviewData();
    if (widget.section == ReportsPanelSection.flights ||
        widget.section == ReportsPanelSection.analizes ||
        widget.section == ReportsPanelSection.reports) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ensureDetailsLoaded();
      });
    }
  }

  Future<void> _loadTemplateOptions() async {
    final templates = await ReportXslTemplateLoader().load();
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
    setState(() {
      _xslTemplateOptions = options;
      _selectedTemplate ??= options.first;
    });
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section &&
        widget.section != null &&
        (widget.section == ReportsPanelSection.flights ||
            widget.section == ReportsPanelSection.analizes ||
            widget.section == ReportsPanelSection.reports)) {
      _ensureDetailsLoaded();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        final flights = eventTypes.flights
            ? result.flights
            : const <ReportsFlightRow>[];
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
        if (_pendingDetailsLoad) {
          _pendingDetailsLoad = false;
          unawaited(_ensureDetailsLoaded());
        }
      }
    }
  }

  void _persistRuntimeQuery() {
    ref
        .read(reportsRuntimeQueryProvider.notifier)
        .setValue(
          ReportsRuntimeQueryState(
            from: _from,
            to: _to,
            matchMode: _filterMatchMode,
            filters: List<ReportsFilterCondition>.from(_filters),
          ),
        );
  }

  Future<void> _loadDetailed() async {
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
    return _fetchEntriesForRange(
      flights: flights,
      eventTypes: eventTypes,
      from: _from,
      to: _to,
    );
  }

  Future<List<LogbookEntry>> _fetchEntriesForRange({
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

  Future<void> _ensureDetailsLoaded() async {
    if (_detailsLoaded) return;
    if (_loading) {
      _pendingDetailsLoad = true;
      return;
    }
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
      initialDate: DateTime.utc(current.year, current.month, current.day),
      firstDate: DateTime.utc(1970),
      lastDate: DateTime.utc(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (pickedTime == null || !mounted) return;

    final selectedUtc = DateTime.utc(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      if (isStart) {
        _from = selectedUtc;
      } else {
        _to = selectedUtc;
      }
      _preset = _ReportDateRangePreset.custom;
    });
    _persistRuntimeQuery();
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
    _persistRuntimeQuery();
    await _loadOverviewData();
  }

  Future<void> _addFilter() async {
    final added = await showDialog<ReportsFilterCondition>(
      context: context,
      builder: (context) => const _AddFilterDialog(),
    );
    if (added == null || !mounted) return;
    setState(() => _filters.add(added));
    _persistRuntimeQuery();
    await _loadOverviewData();
  }

  Future<void> _removeFilter(int index) async {
    if (index < 0 || index >= _filters.length) return;
    setState(() => _filters.removeAt(index));
    _persistRuntimeQuery();
    await _loadOverviewData();
  }

  Future<void> _setMatchMode(ReportsFilterMatchMode mode) async {
    if (_filterMatchMode == mode) return;
    setState(() => _filterMatchMode = mode);
    _persistRuntimeQuery();
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
    _persistRuntimeQuery();
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
      builder: (context) => _FlightsMapDialog(
        flights: _data.flights,
        fullscreen: true,
        initialShowLines: _showPathOnMap,
      ),
    );
  }

  Future<void> _generatePdf() async {
    if (_isGeneratingPdf) {
      return;
    }
    final selectedTemplate = _selectedTemplate;
    if (selectedTemplate == null) {
      await _showInfoDialog(
        AppLocalizations.of(context)!.reportsNoTemplateAvailable,
      );
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await _setPdfGenerationProgress(l10n.reportsPdfPreparing, progress: 0.1);

    try {
      await _ensureDetailsLoaded();
      if (!mounted) return;
      final templateConfig = selectedTemplate.template;
      final pdfService = ref.read(reportPdfApplicationServiceProvider);

      await _setPdfGenerationProgress(l10n.reportsPdfGenerating, progress: 0.5);
      final includeHoursBefore = ref.read(includeHoursBeforeProvider);
      final startingTotals = includeHoursBefore
          ? await _loadStandardStartingTotals(pdfService)
          : const ReportTemplateTotals();
      final bytes = await pdfService.generateFromTemplate(
        template: templateConfig,
        entries: _entries,
        startingTotals: startingTotals,
      );

      await _setPdfGenerationProgress(l10n.reportsPdfSaving, progress: 0.85);
      final path = await _savePdfBytes(
        bytes: bytes,
        fileName:
            'simplelog_report_'
            '${DateTime.now().toUtc().toIso8601String().replaceAll(':', '').replaceAll('-', '').split('.').first}.pdf',
      );
      if (!mounted) return;
      await _setPdfGenerationProgress(l10n.reportsPdfDone, progress: 1);
      await _showInfoDialog(l10n.reportsPdfExported(path));
    } catch (error, stackTrace) {
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

  Future<void> _showInfoDialog(String message) async {
    if (!mounted) return;
    await showAppMessageDialog(context, message: message);
  }

  Future<ReportTemplateTotals> _loadStandardStartingTotals(
    ReportPdfApplicationService service,
  ) async {
    final cutoff = _from.subtract(const Duration(microseconds: 1));
    final firstDate = DateTime.utc(1970, 1, 1);
    if (cutoff.isBefore(firstDate)) {
      return const ReportTemplateTotals();
    }

    final repo = ref.read(reportsRepositoryProvider);
    final eventTypes = ref.read(reportsEventTypesProvider);
    final beforeResult = await repo.load(
      ReportsQuery(
        from: firstDate,
        to: cutoff,
        includePreviousExperience: false,
        filterMatchMode: _filterMatchMode,
        filters: _filters,
      ),
    );

    final flights = eventTypes.flights
        ? beforeResult.flights
        : const <ReportsFlightRow>[];
    final beforeEntries = await _fetchEntriesForRange(
      flights: flights,
      eventTypes: eventTypes,
      from: firstDate,
      to: cutoff,
    );
    final rows = service.buildRows(beforeEntries);
    return service.sumTotals(rows);
  }

  Future<String> _savePdfBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    String? path;
    if (Platform.isIOS || Platform.isAndroid) {
      path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.reportsSavePdfDialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: bytes,
      );
      if (path == null || path.isEmpty) {
        return l10n.reportsCancelled;
      }
      return path;
    }

    final directory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l10n.reportsChooseExportFolderTitle,
    );
    if (directory == null || directory.isEmpty) {
      return l10n.reportsCancelled;
    }
    path = '$directory${Platform.pathSeparator}$fileName';
    try {
      await File(path).writeAsBytes(bytes, flush: true);
    } on FileSystemException {
      final docsDir = await getApplicationDocumentsDirectory();
      path = '${docsDir.path}${Platform.pathSeparator}$fileName';
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return path;
  }

  List<_AnalysisGroup> _buildAnalysisGroups() {
    final l10n = AppLocalizations.of(context)!;
    final groups = <String, _AnalysisGroupAccumulator>{};
    for (final flight in _data.flights) {
      final keys = _analysisGroupKeysForFlight(flight, l10n);
      for (final key in keys) {
        final bucket = groups.putIfAbsent(
          key,
          () => _AnalysisGroupAccumulator(),
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
    }
    final list = groups.entries
        .map((entry) => _AnalysisGroup(title: entry.key, totals: entry.value))
        .toList(growable: false);
    list.sort(_analysisSortCompare);
    return list;
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
        unknownPilot: l10n.reportsUnknownPilot,
      ),
    ];
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
      simulatedInstrumentMinutes: selection.flights
          ? totals.simulatedInstrumentMinutes
          : 0,
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
      case _AnalysisGroupBy.pilot:
        return l10n.reportsAnalyzeByPilot;
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

        return Padding(
          padding: EdgeInsets.all(compact ? 8 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showTabbedLayout)
                TabBar(
                  controller: _tabController,
                  onTap: _onTabChanged,
                  isScrollable: compact,
                  tabs: [
                    Tab(text: l10n.reportsTabOverview),
                    Tab(text: l10n.reportsTabFlights),
                    Tab(text: l10n.reportsTabAnalyses),
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
                          _buildOverviewSection(
                            compact: compact,
                            includePreviousExperience:
                                includePreviousExperience,
                            eventTypes: eventTypes,
                            savedQueries: savedQueries,
                            customTimeLabels: customTimeLabels,
                          ),
                          _buildFlightsSection(logbookUseCases),
                          _buildAnalizesSection(compact: compact),
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
          includePreviousExperience: includePreviousExperience,
          eventTypes: eventTypes,
          savedQueries: savedQueries,
        );
      case ReportsPanelSection.totals:
        return _TotalsCard(
          totals: _data.totals,
          customTimeLabels: customTimeLabels,
        );
      case ReportsPanelSection.analizes:
        return _buildAnalizesSection(compact: compact);
      case ReportsPanelSection.reports:
        return _buildReportsSection(compact: compact);
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
          includePreviousExperience: includePreviousExperience,
          eventTypes: eventTypes,
          savedQueries: savedQueries,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _TotalsCard(
            totals: _data.totals,
            customTimeLabels: customTimeLabels,
          ),
        ),
        const SizedBox(height: 10),
        _buildReportsControls(compact: compact),
      ],
    );
  }

  Widget _buildFiltersSection({
    required bool includePreviousExperience,
    required ReportsEventTypesSelection eventTypes,
    required List<SavedReportsQuery> savedQueries,
  }) {
    return _FiltersCard(
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
      onIncludePreviousExperienceChanged: _setIncludePreviousExperience,
      onEventTypesChanged: _setEventTypes,
      onMatchModeChanged: _setMatchMode,
      onAddFilter: _addFilter,
      onRemoveFilter: _removeFilter,
      onSaveQuery: _saveCurrentQuery,
      onApplySavedQuery: _applySavedQuery,
      onDeleteSavedQuery: _deleteSavedQuery,
    );
  }

  Widget _buildFlightsSection(LogbookUseCases logbookUseCases) {
    return _EntriesPanel(
      entries: _entries,
      onEntryTap: (entry) {
        LogbookEntryDialogs.show(
          context,
          entry: entry,
          useCases: logbookUseCases,
        );
      },
    );
  }

  Widget _buildAnalizesSection({required bool compact}) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<_AnalysisGroupBy>(
                initialValue: _analysisGroupBy,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.reportsAnalyzeByLabel,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _AnalysisGroupBy.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: _overflowText(
                          _analysisGroupByLabel(l10n, value),
                        ),
                      ),
                    )
                    .toList(growable: false),
                selectedItemBuilder: (context) => _AnalysisGroupBy.values
                    .map(
                      (value) => _dropdownSelectedItem(
                        _analysisGroupByLabel(l10n, value),
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
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<_AnalysisOrderBy>(
                initialValue: _analysisOrderBy,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.reportsOrderByLabel,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _AnalysisOrderBy.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: _overflowText(
                          _analysisOrderByLabel(l10n, value),
                        ),
                      ),
                    )
                    .toList(growable: false),
                selectedItemBuilder: (context) => _AnalysisOrderBy.values
                    .map(
                      (value) => _dropdownSelectedItem(
                        _analysisOrderByLabel(l10n, value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _analysisOrderBy = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(child: _AnalysisList(groups: _buildAnalysisGroups())),
      ],
    );
  }

  Widget _buildReportsSection({required bool compact}) {
    return Column(children: [_buildReportsControls(compact: compact)]);
  }

  Widget _buildReportsControls({required bool compact}) {
    final l10n = AppLocalizations.of(context)!;
    final includeHoursBefore = ref.watch(includeHoursBeforeProvider);
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _isGeneratingPdf ? null : _openMapDialog,
                icon: const Icon(Icons.map_outlined),
                label: Text(l10n.reportsShowMap),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.reportsShowPath),
                  const SizedBox(width: 6),
                  Switch(
                    value: _showPathOnMap,
                    onChanged: _isGeneratingPdf
                        ? null
                        : (value) => setState(() => _showPathOnMap = value),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.reportsIncludeHoursBefore),
                  const SizedBox(width: 6),
                  Switch(
                    value: includeHoursBefore,
                    onChanged: _isGeneratingPdf
                        ? null
                        : (value) => ref
                              .read(includeHoursBeforeProvider.notifier)
                              .setValue(value),
                  ),
                ],
              ),
            ],
          ),
          if (_isGeneratingPdf) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(value: _pdfGenerationProgress),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _pdfGenerationStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: compact ? 260 : 330,
                child: DropdownButtonFormField<_XslTemplateOption>(
                  key: ValueKey(
                    _selectedTemplate?.fileName ?? 'template_selector',
                  ),
                  initialValue: _selectedTemplate,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.reportsXmlTemplateLabel,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _xslTemplateOptions
                      .map(
                        (template) => DropdownMenuItem<_XslTemplateOption>(
                          value: template,
                          child: _overflowText(template.description),
                        ),
                      )
                      .toList(growable: false),
                  selectedItemBuilder: (context) => _xslTemplateOptions
                      .map(
                        (template) =>
                            _dropdownSelectedItem(template.description),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (_isGeneratingPdf) return;
                    if (value == null) return;
                    setState(() {
                      _selectedTemplate = value;
                    });
                  },
                ),
              ),
              FilledButton.icon(
                onPressed: _isGeneratingPdf ? null : _generatePdf,
                icon: _isGeneratingPdf
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  _isGeneratingPdf
                      ? l10n.reportsGeneratingShort
                      : l10n.reportsGeneratePdf,
                ),
              ),
            ],
          ),
        ],
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

enum _AnalysisGroupBy { aircraft, type, family, airport, pilot, year, month }

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
    case ReportsFilterField.pilotName:
      return l10n.reportsFilterFieldPilotName;
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
    case ReportsFilterField.instrumentTime:
      return l10n.reportsFilterFieldInstrumentTime;
    case ReportsFilterField.simulatedInstrumentTime:
      return l10n.reportsFilterFieldSimInstrumentTime;
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
  String keyFor(
    ReportsFlightRow row, {
    required String unknownAircraft,
    required String unknownType,
    required String unknownFamily,
    required String unknownAirport,
    required String unknownPilot,
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
      case _AnalysisGroupBy.pilot:
        return row.pilotNames.trim().isEmpty ? unknownPilot : row.pilotNames;
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
  int takeoffs = 0;
  int landings = 0;
  int operations = 0;
  DateTime? firstFlightUtc;
  DateTime? lastFlightUtc;

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
    instrumentMinutes += row.instrumentMinutes;
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
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final maxFieldWidth = compact ? constraints.maxWidth - 40 : 250.0;
        return Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text(l10n.logbookFilterTitle),
            subtitle: Text(
              l10n.reportsFiltersSummary(
                filters.length,
                DateFormat('dd/MM/yyyy HH:mm').format(from),
                DateFormat('dd/MM/yyyy HH:mm').format(to),
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: compact ? 460 : 520),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: Text(l10n.logbookEventFlight),
                            selected: eventTypes.flights,
                            onSelected: (value) => onEventTypesChanged(
                              eventTypes.copyWith(flights: value),
                            ),
                          ),
                          FilterChip(
                            label: Text(l10n.reportsEventSimShort),
                            selected: eventTypes.simulator,
                            onSelected: (value) => onEventTypesChanged(
                              eventTypes.copyWith(simulator: value),
                            ),
                          ),
                          FilterChip(
                            label: Text(l10n.logbookEventDuty),
                            selected: eventTypes.duty,
                            onSelected: (value) => onEventTypesChanged(
                              eventTypes.copyWith(duty: value),
                            ),
                          ),
                          FilterChip(
                            label: Text(l10n.logbookEventPositioning),
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
                            width: maxFieldWidth,
                            child:
                                DropdownButtonFormField<_ReportDateRangePreset>(
                                  initialValue: preset,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.logbookFilterRange,
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: _ReportDateRangePreset.values
                                      .map(
                                        (value) => DropdownMenuItem(
                                          value: value,
                                          child: _overflowText(
                                            _reportDateRangePresetLabel(
                                              l10n,
                                              value,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                  selectedItemBuilder: (context) =>
                                      _ReportDateRangePreset.values
                                          .map(
                                            (value) => _dropdownSelectedItem(
                                              _reportDateRangePresetLabel(
                                                l10n,
                                                value,
                                              ),
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
                          _DateTimeButton(
                            label: l10n.logbookFilterFromDate,
                            value: from,
                            onTap: onPickStart,
                            width: maxFieldWidth,
                          ),
                          _DateTimeButton(
                            label: l10n.logbookFilterToDate,
                            value: to,
                            onTap: onPickEnd,
                            width: maxFieldWidth,
                          ),
                          SizedBox(
                            width: compact ? maxFieldWidth : 200,
                            child: DropdownButtonFormField<bool>(
                              initialValue: includePreviousExperience,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.reportsPreviousExperienceLabel,
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: true,
                                  child: _overflowText(l10n.reportsInclude),
                                ),
                                DropdownMenuItem(
                                  value: false,
                                  child: _overflowText(l10n.reportsExclude),
                                ),
                              ],
                              selectedItemBuilder: (context) => [
                                _dropdownSelectedItem(l10n.reportsInclude),
                                _dropdownSelectedItem(l10n.reportsExclude),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  onIncludePreviousExperienceChanged(value);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: compact ? maxFieldWidth : 150,
                            child:
                                DropdownButtonFormField<ReportsFilterMatchMode>(
                                  initialValue: matchMode,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.reportsMatchModeLabel,
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: ReportsFilterMatchMode.all,
                                      child: _overflowText(
                                        l10n.reportsMatchAll,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: ReportsFilterMatchMode.any,
                                      child: _overflowText(
                                        l10n.reportsMatchAny,
                                      ),
                                    ),
                                  ],
                                  selectedItemBuilder: (context) => [
                                    _dropdownSelectedItem(l10n.reportsMatchAll),
                                    _dropdownSelectedItem(l10n.reportsMatchAny),
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
                              label: Text(l10n.reportsAddFilter),
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
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: compact ? maxFieldWidth : 260,
                            child: DropdownButtonFormField<String>(
                              initialValue: null,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.reportsSavedQueriesLabel,
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: savedQueries
                                  .map(
                                    (query) => DropdownMenuItem(
                                      value: query.id,
                                      child: _overflowText(query.name),
                                    ),
                                  )
                                  .toList(growable: false),
                              selectedItemBuilder: (context) => savedQueries
                                  .map(
                                    (query) =>
                                        _dropdownSelectedItem(query.name),
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
                              label: Text(l10n.reportsSaveQuery),
                            ),
                          ),
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
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.delete_outline, size: 18),
                                    const SizedBox(width: 6),
                                    Text(l10n.reportsDeleteSavedLabel),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton({
    required this.label,
    required this.value,
    required this.onTap,
    this.width = 190,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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
  const _TotalsCard({required this.totals, required this.customTimeLabels});

  final ReportsTotals totals;
  final CustomTimeLabels customTimeLabels;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final operations = <(String, String)>[
      (l10n.reportsMetricIfrApproaches, _formatCount(totals.ifrApproaches)),
      (l10n.reportsMetricTakeoffDay, _formatCount(totals.takeoffsDay)),
      (l10n.reportsMetricTakeoffNight, _formatCount(totals.takeoffsNight)),
      (l10n.reportsMetricLandingDay, _formatCount(totals.landingsDay)),
      (l10n.reportsMetricLandingNight, _formatCount(totals.landingsNight)),
    ];
    final times = <(String, String)>[
      (l10n.reportsMetricTotalBlock, _formatMinutes(totals.totalMinutes)),
      (l10n.reportsMetricPic, _formatMinutes(totals.picMinutes)),
      (l10n.reportsMetricPicus, _formatMinutes(totals.picusMinutes)),
      (l10n.reportsMetricSic, _formatMinutes(totals.sicMinutes)),
      (l10n.reportsMetricDual, _formatMinutes(totals.dualMinutes)),
      (l10n.reportsMetricInstructor, _formatMinutes(totals.instructorMinutes)),
      (l10n.reportsMetricNight, _formatMinutes(totals.nightMinutes)),
      (l10n.reportsMetricIfr, _formatMinutes(totals.ifrMinutes)),
      (
        l10n.reportsMetricInstrument,
        _formatMinutes(totals.simulatedInstrumentMinutes + totals.ifrMinutes),
      ),
      (
        l10n.reportsMetricCrossCountry,
        _formatMinutes(totals.crossCountryMinutes),
      ),
      (l10n.reportsMetricSimulator, _formatMinutes(totals.simulatorMinutes)),
      (l10n.reportsMetricDuty, _formatMinutes(totals.dutyMinutes)),
      (l10n.reportsMetricDistanceNm, _formatCount(totals.distanceNM)),
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
                    l10n.reportsFlightCount(_formatCount(totals.sectors)),
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
        final isPhoneMiniWidth = constraints.maxWidth < 390;
        final spacing = isPhoneMiniWidth ? 6.0 : 8.0;
        final columns = isPhoneMiniWidth
            ? 2
            : constraints.maxWidth >= 700
            ? 5
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
                      const SizedBox(height: 3),
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
    if (groups.isEmpty) {
      return Card(child: Center(child: Text(l10n.reportsNoDataForQuery)));
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
                label: l10n.reportsMetricInstrument,
                valueText: _formatMinutes(group.totals.instrumentMinutes),
                ratio: group.totals.totalMinutes > 0
                    ? group.totals.instrumentMinutes / group.totals.totalMinutes
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
    final l10n = AppLocalizations.of(context)!;
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
                  Expanded(
                    child: Text(
                      l10n.reportsAddFilter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.reportsFieldNameLabel,
                  border: OutlineInputBorder(),
                ),
                items: ReportsFilterField.values
                    .map(
                      (field) => DropdownMenuItem(
                        value: field,
                        child: _overflowText(
                          _reportFilterFieldLabel(l10n, field),
                        ),
                      ),
                    )
                    .toList(growable: false),
                selectedItemBuilder: (context) => ReportsFilterField.values
                    .map(
                      (field) => _dropdownSelectedItem(
                        _reportFilterFieldLabel(l10n, field),
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
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.reportsConditionLabel,
                  border: OutlineInputBorder(),
                ),
                items: operators
                    .map(
                      (operator) => DropdownMenuItem(
                        value: operator,
                        child: _overflowText(
                          _reportFilterOperatorLabel(l10n, operator),
                        ),
                      ),
                    )
                    .toList(growable: false),
                selectedItemBuilder: (context) => operators
                    .map(
                      (operator) => _dropdownSelectedItem(
                        _reportFilterOperatorLabel(l10n, operator),
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
                  child: Text(l10n.addAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueField() {
    final l10n = AppLocalizations.of(context)!;
    switch (_field.valueType) {
      case ReportsFilterValueType.text:
        return TextFormField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: l10n.reportsValueLabel,
            border: OutlineInputBorder(),
          ),
        );
      case ReportsFilterValueType.number:
        return TextFormField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.reportsValueLabel,
            border: OutlineInputBorder(),
          ),
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
                  Expanded(
                    child: Text(
                      l10n.reportsSaveQuery,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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
                decoration: InputDecoration(
                  labelText: l10n.fieldName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_controller.text),
                  child: Text(l10n.saveAction),
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
    required this.flights,
    this.fullscreen = false,
    this.initialShowLines = true,
  });

  final List<ReportsFlightRow> flights;
  final bool fullscreen;
  final bool initialShowLines;

  @override
  State<_FlightsMapDialog> createState() => _FlightsMapDialogState();
}

class _FlightsMapDialogState extends State<_FlightsMapDialog> {
  final _mapController = MapController();
  double _zoom = 2.0;
  late bool _showLines;
  static const Color _mapLineColor = Color(0x994A90E2);
  static const Color _mapDotColor = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _showLines = widget.initialShowLines;
  }

  List<LatLng> _greatCirclePoints(LatLng from, LatLng to, {int segments = 48}) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      final fromKey =
          '${fromPoint.latitude.toStringAsFixed(4)}_${fromPoint.longitude.toStringAsFixed(4)}';
      if (markerKeys.add(fromKey)) {
        markers.add(
          Marker(
            point: fromPoint,
            width: 14,
            height: 14,
            child: const Icon(Icons.circle, size: 9, color: _mapDotColor),
          ),
        );
      }
      final toKey =
          '${toPoint.latitude.toStringAsFixed(4)}_${toPoint.longitude.toStringAsFixed(4)}';
      if (markerKeys.add(toKey)) {
        markers.add(
          Marker(
            point: toPoint,
            width: 14,
            height: 14,
            child: const Icon(Icons.circle, size: 9, color: _mapDotColor),
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
                      l10n.reportsFlightMapTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _showLines
                        ? l10n.reportsHideLines
                        : l10n.reportsShowLines,
                    onPressed: () => setState(() => _showLines = !_showLines),
                    icon: Icon(_showLines ? Icons.route : Icons.scatter_plot),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.reportsDone),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: markers.isEmpty
                  ? Center(child: Text(l10n.reportsNoCoordinatesAvailable))
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
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.rietlabs.simplelog',
                              tileProvider: NetworkTileProvider(
                                cachingProvider: appMapCachingProvider(),
                              ),
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
                              child: Text(
                                l10n.reportsAirportsCount(airportCount),
                              ),
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
                                    _mapController.move(
                                      _mapController.camera.center,
                                      _zoom,
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _zoom -= 1;
                                    _mapController.move(
                                      _mapController.camera.center,
                                      _zoom,
                                    );
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

Widget _overflowText(String value) {
  return Text(
    value,
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.ellipsis,
  );
}

Widget _dropdownSelectedItem(String value) {
  return Align(
    alignment: AlignmentDirectional.centerStart,
    child: _overflowText(value),
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
