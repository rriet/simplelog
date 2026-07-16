import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/export/simplelog_csv_exporter.dart';
import 'package:simplelog/data/import/import_operation_result.dart';
import 'package:simplelog/data/import/import_source_dispatcher.dart';
import 'package:simplelog/data/import/legacy_simplelog_db_importer.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/logten_pro_tsv_inspector.dart';
import 'package:simplelog/data/import/multi_source_importer.dart';
import 'package:simplelog/data/import/pipeline/import_critical_issue_resolver.dart';
import 'package:simplelog/data/import/pipeline/import_issue_adapter.dart';
import 'package:simplelog/data/import/pipeline/import_pipeline_coordinator.dart';
import 'package:simplelog/data/import/pipeline/import_pipeline_models.dart';
import 'package:simplelog/data/import/pipeline/row_import_aircraft_issue.dart';
import 'package:simplelog/data/import/pipeline/row_import_airport_issue.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/qatar_airways_workbook_inspector.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';
import 'package:simplelog/data/import/source_parsers/southwest_csv_source_parser.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';
import 'package:simplelog/data/import/unified_import_options.dart';
import 'package:simplelog/data/import/wader_import_models.dart';
import 'package:simplelog/data/import/wader_import_options.dart';
import 'package:simplelog/features/database/presentation/widgets/import_options_preferences.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/sections/row_import_aircraft_resolution_sheet.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/sections/row_import_airport_resolution_sheet.dart';
import 'package:simplelog/features/database/presentation/widgets/local_sync_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/logten_pro_import_options_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/logten_pro_import_review_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/qatar_airways_import_options_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/southwest_import_options_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/southwest_import_preflight_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/southwest_type_mappings_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/unified_import_options_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/unified_import_options_mapper.dart';
import 'package:simplelog/features/database/presentation/widgets/wader_import_review_dialog.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_preferences_provider.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/duty_rules_settings_provider.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';
import 'package:simplelog/state/providers/initial_data_provider.dart';
import 'package:simplelog/state/providers/onboarding_provider.dart';
import 'package:simplelog/state/providers/simulator_default_crew_position_provider.dart';

/// Main Database tab panel for sync, import/export, backup, and restore tools.
class DatabaseSyncTrigger extends ConsumerWidget {
  /// Creates the database tools panel.
  const DatabaseSyncTrigger({super.key});

  static const _sourceDispatcher = ImportSourceDispatcher();
  static const _logTenProInspector = LogTenProTsvInspector();
  static const _qatarAirwaysInspector = QatarAirwaysWorkbookInspector();
  static const _pipelineCoordinator = ImportPipelineCoordinator();
  static const _criticalIssueResolver = ImportCriticalIssueResolver();
  static const _replaceDataWarningMessage =
      'Current logbook data will be replaced. This cannot be undone.';

  _DatabaseSectionCard _buildTwoActionSection({
    required String title,
    required String subtitle,
    required IconData firstIcon,
    required String firstLabel,
    required VoidCallback onFirstPressed,
    required IconData secondIcon,
    required String secondLabel,
    required VoidCallback onSecondPressed,
    Widget? headerTrailing,
  }) {
    return _DatabaseSectionCard(
      title: title,
      subtitle: subtitle,
      headerTrailing: headerTrailing,
      children: [
        _DatabaseActionButton(
          icon: firstIcon,
          label: firstLabel,
          onPressed: onFirstPressed,
        ),
        const SizedBox(height: 8),
        _DatabaseActionButton(
          icon: secondIcon,
          label: secondLabel,
          onPressed: onSecondPressed,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.databaseToolsTitle,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _DatabaseSectionCard(
              title: l10n.databaseSyncTitle,
              subtitle: l10n.databaseSyncSubtitle,
              headerTrailing: InfoHelpButton(
                title: l10n.databaseLocalTransferInfoTitle,
                message: l10n.databaseLocalTransferInfoMessage,
              ),
              children: [
                _DatabaseActionButton(
                  icon: Icons.sync,
                  label: l10n.databaseSyncStartLocal,
                  onPressed: () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const LocalSyncDialog(),
                  ),
                  filled: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTwoActionSection(
              title: l10n.databaseImportExportTitle,
              subtitle: l10n.databaseImportExportSubtitle,
              headerTrailing: InfoHelpButton(
                title: l10n.databaseImportExportInfoTitle,
                message: l10n.databaseImportExportInfoMessage,
              ),
              firstIcon: Icons.upload_file,
              firstLabel: l10n.databaseImportFileAction,
              onFirstPressed: () => _importCsv(context, ref),
              secondIcon: Icons.download_outlined,
              secondLabel: l10n.databaseExportFileAction,
              onSecondPressed: () => _exportData(context, ref),
            ),
            const SizedBox(height: 12),
            _DatabaseSectionCard(
              title: l10n.databaseResetTitle,
              subtitle: l10n.databaseResetSubtitle,
              children: [
                _DatabaseActionButton(
                  icon: Icons.delete_forever_outlined,
                  label: l10n.databaseDeleteAllDataAction,
                  onPressed: () => _deleteAllData(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDestructiveReplaceConfirmation(
      context: context,
      title: 'Delete all database data?',
      confirmLabel: 'Delete all',
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final db = ref.read(databaseProvider);
    await db.clearAllData();
    ref
      ..invalidate(databaseProvider)
      ..invalidate(initialDataProvider)
      ..invalidate(onboardingCompletedProvider)
      ..invalidate(flightFactoringSettingsProvider)
      ..invalidate(dutyRulesSettingsProvider)
      ..invalidate(reportPilotInfoProvider);
    if (!context.mounted) {
      return;
    }
    await _showInfoDialog(context, 'All data deleted.');
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final choice = await _showExportTypeDialog(context);
    if (!context.mounted || choice == null) return;
    if (choice == _DatabaseExportChoice.csv) {
      await _exportCsv(context, ref);
      return;
    }
    await _backupDatabase(context, ref);
  }

  Future<void> _importCsv(BuildContext context, WidgetRef ref) async {
    final isAndroid = Platform.isAndroid;
    final isIOS = Platform.isIOS;
    final result = await FilePicker.platform.pickFiles(
      type: isAndroid || isIOS ? FileType.any : FileType.custom,
      allowedExtensions: isAndroid || isIOS
          ? null
          : const [
              'csv',
              'sqlite',
              'db',
              'backup',
              'xlsx',
              'txt',
              'tsv',
            ],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (!context.mounted) return;
    final bytes =
        (file.path == null ? null : await File(file.path!).readAsBytes()) ??
        file.bytes;
    if (bytes == null) return;
    final detection = await _pipelineCoordinator.detect(
      fileName: file.name,
      bytes: bytes,
    );
    if (!context.mounted) return;
    if (detection.kind ==
        ImportPipelineDetectionKind.currentSimpleLogDatabase) {
      await _restoreDatabaseBytes(context, ref, bytes);
      return;
    }
    if (detection.kind == ImportPipelineDetectionKind.legacySimpleLogDatabase) {
      await _importDatabaseFile(context, ref, bytes);
      return;
    }
    if (detection.kind ==
        ImportPipelineDetectionKind.unsupportedSqliteDatabase) {
      await _showInfoDialog(context, 'Unsupported database file format.');
      return;
    }
    final content = detection.decodedContent ?? '';
    final type = detection.sourceKind ?? ImportSourceKind.unknown;
    if (!context.mounted) return;
    final db = ref.read(databaseProvider);
    final preOptions = await UnifiedImportOptionsDialog.show(
      context,
      fileName: file.name,
      title: _titleForImportType(context, type),
      initial: UnifiedImportOptions.defaultsFor(type),
    );
    if (preOptions == null || !context.mounted) return;

    if (type == ImportSourceKind.legacySimpleLogCsv) {
      final initialOptions = await ImportOptionsPreferences.loadSimpleLog(db);
      final options = UnifiedImportOptionsMapper.applyToSimpleLog(
        preOptions,
        initialOptions,
      );
      await ImportOptionsPreferences.saveSimpleLog(db, options);
      if (!context.mounted) return;
      final importer = SimpleLogCsvImporter(db);
      final progress = ValueNotifier<_ImportProgress>(
        const _ImportProgress(processed: 0, total: 0),
      );
      _showImportProgressDialog(context, progress);
      ImportOperationResult<SimpleLogImportResult>? outcome;
      try {
        outcome = await importer.importCsvSafely(
          content,
          options: options,
          onProgress: (processed, total) => progress.value = _ImportProgress(
            processed: processed,
            total: total,
          ),
        );
      } finally {
        progress.dispose();
      }
      if (!context.mounted) return;
      AppNavigator.popRoot(context);
      if (!context.mounted) return;
      if (!outcome.isSuccess) {
        final message = _buildImportErrorMessage(outcome.failure);
        await _showInfoDialog(context, message);
        return;
      }
      await _showImportSummary(context, outcome.data!);
    } else if (type == ImportSourceKind.qatarAirwaysXlsx) {
      final inspection = _qatarAirwaysInspector.inspect(bytes);
      if (inspection == null) {
        await _showInfoDialog(context, 'Unsupported Qatar Airways workbook.');
        return;
      }
      _logQatarAirwaysColumns(inspection);
      final selfCrew = await _loadSelfCrew(db);
      if (!context.mounted) return;
      if (selfCrew == null) {
        await _showInfoDialog(
          context,
          'Select one crew member as self before importing Qatar Airways data.',
        );
        return;
      }
      if (!context.mounted) return;
      final resolvedInspection = await _resolveQatarAirportIssues(
        context,
        db: db,
        inspection: inspection,
      );
      if (resolvedInspection == null || !context.mounted) return;
      final resolvedAircraftInspection = await _resolveQatarAircraftIssues(
        context,
        db: db,
        inspection: resolvedInspection,
      );
      if (resolvedAircraftInspection == null || !context.mounted) return;
      final initialOptions = await ImportOptionsPreferences.loadQatarAirways(
        db: db,
      );
      if (!context.mounted) return;
      final options = await QatarAirwaysImportOptionsDialog.show(
        context,
        fileName: file.name,
        inspection: inspection,
        initial: initialOptions,
      );
      if (options == null || !context.mounted) return;
      await ImportOptionsPreferences.saveQatarAirways(db, options);
      if (!context.mounted) return;
      await _importQatarAirwaysWorkbook(
        context,
        db: db,
        inspection: resolvedAircraftInspection,
        options: options,
      );
    } else if (type == ImportSourceKind.logTenProTsv) {
      final inspection = _logTenProInspector.inspect(content);
      if (inspection == null) {
        await _showInfoDialog(context, 'Unsupported LogTen Pro export.');
        return;
      }
      _logLogTenProColumns(inspection);
      final options = await LogTenProImportOptionsDialog.show(
        context,
        fileName: file.name,
        inspection: inspection,
        initial: LogTenImportOptions(
          assignments: buildDefaultLogTenAssignments(inspection.columns),
        ),
      );
      if (options == null || !context.mounted) return;
      final importer = SimpleLogCsvImporter(db);
      final validatedOptions = await _reviewLogTenImportIssues(
        context,
        importer: importer,
        content: content,
        fileName: file.name,
        inspection: inspection,
        initialOptions: options,
      );
      if (validatedOptions == null || !context.mounted) return;
      final progress = ValueNotifier<_ImportProgress>(
        const _ImportProgress(processed: 0, total: 0),
      );
      _showImportProgressDialog(context, progress);
      ImportOperationResult<LogTenImportResult>? outcome;
      try {
        outcome = await importer.importLogTenProTsvSafely(
          content,
          options: validatedOptions,
          onProgress: (processed, total) => progress.value = _ImportProgress(
            processed: processed,
            total: total,
          ),
        );
      } finally {
        progress.dispose();
      }
      if (!context.mounted) return;
      AppNavigator.popRoot(context);
      if (!context.mounted) return;
      if (!outcome.isSuccess) {
        final message = _buildImportErrorMessage(outcome.failure);
        await _showInfoDialog(context, message);
        return;
      }
      await _showLogTenImportSummary(context, outcome.data!);
    } else if (type == ImportSourceKind.southwestCsv) {
      final defaultPosition = await ref.read(
        simulatorDefaultCrewPositionProvider.future,
      );
      final loadedOptions = await ImportOptionsPreferences.loadSouthwest(
        db: db,
        fallbackPosition: defaultPosition == CrewPosition.unknown
            ? CrewPosition.sic
            : defaultPosition,
      );
      final initialOptions = UnifiedImportOptionsMapper.applyToSouthwest(
        preOptions,
        loadedOptions,
      );
      if (!context.mounted) return;
      final options = await SouthwestImportOptionsDialog.show(
        context,
        fileName: file.name,
        initial: initialOptions,
      );
      if (options == null || !context.mounted) return;
      final airportResolvedOptions = await _resolveSouthwestAirportIssues(
        context,
        db: db,
        content: content,
        options: options,
      );
      if (airportResolvedOptions == null || !context.mounted) return;
      final importer = SimpleLogCsvImporter(db);
      final resolvedTypeMappings = await _resolveSouthwestTypeMappings(
        context,
        importer: importer,
        content: content,
        fileName: file.name,
        initialMappings: airportResolvedOptions.aircraftTypeMappings,
      );
      if (resolvedTypeMappings == null || !context.mounted) return;
      final optionsWithMappings = airportResolvedOptions.copyWith(
        aircraftTypeMappings: resolvedTypeMappings,
      );
      final preflightOptions = await _resolveSouthwestCriticalIssues(
        context,
        importer: importer,
        content: content,
        initialOptions: optionsWithMappings,
      );
      if (preflightOptions == null || !context.mounted) return;
      await ImportOptionsPreferences.saveSouthwest(db, optionsWithMappings);
      if (!context.mounted) return;
      final progress = ValueNotifier<_ImportProgress>(
        const _ImportProgress(processed: 0, total: 0),
      );
      _showImportProgressDialog(context, progress);
      ImportOperationResult<SimpleLogImportResult>? outcome;
      try {
        outcome = await importer.importSouthwestCsvSafely(
          content,
          options: preflightOptions,
          onProgress: (processed, total) => progress.value = _ImportProgress(
            processed: processed,
            total: total,
          ),
        );
      } finally {
        progress.dispose();
      }
      if (!context.mounted) return;
      AppNavigator.popRoot(context);
      if (!context.mounted) return;
      if (!outcome.isSuccess) {
        final message = _buildImportErrorMessage(outcome.failure);
        await _showInfoDialog(context, message);
        return;
      }
      await _showImportSummary(context, outcome.data!);
    } else if (type == ImportSourceKind.waderLogbookCsv) {
      final importer = SimpleLogCsvImporter(db);
      final importOptions = UnifiedImportOptionsMapper.applyToWader(preOptions);
      final reviewOptions = await _reviewWaderImportIssues(
        context,
        db: db,
        importer: importer,
        content: content,
        importOptions: importOptions,
      );
      if (reviewOptions == null || !context.mounted) return;
      await ImportOptionsPreferences.saveWader(db, importOptions);
      if (!context.mounted) return;
      final progress = ValueNotifier<_ImportProgress>(
        const _ImportProgress(processed: 0, total: 0),
      );
      _showImportProgressDialog(context, progress);
      ImportOperationResult<SimpleLogImportResult>? outcome;
      try {
        outcome = await importer.importWaderLogbookCsvSafely(
          content,
          options: importOptions,
          reviewOptions: reviewOptions,
          onProgress: (processed, total) => progress.value = _ImportProgress(
            processed: processed,
            total: total,
          ),
        );
      } finally {
        progress.dispose();
      }
      if (!context.mounted) return;
      AppNavigator.popRoot(context);
      if (!context.mounted) return;
      if (!outcome.isSuccess) {
        final message = _buildImportErrorMessage(outcome.failure);
        await _showInfoDialog(context, message);
        return;
      }
      await _showImportSummary(context, outcome.data!);
    } else {
      await _showOptionsDialog(context, type, file.name);
      if (!context.mounted) return;
      await _showInfoDialog(context, 'Unsupported import format.');
    }
  }

  Future<void> _importDatabaseFile(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
  ) async {
    if (bytes.isEmpty || !context.mounted) return;

    final confirmed = await _showDestructiveReplaceConfirmation(
      context: context,
      title: 'Import legacy database file?',
      confirmLabel: 'Import',
    );
    if (confirmed != true || !context.mounted) return;

    final db = ref.read(databaseProvider);
    final importer = LegacySimpleLogDbImporter(db);
    final result = await importer.importFromBytes(bytes);
    if (!context.mounted) return;
    await _showLegacyImportSummary(context, result);
  }

  Future<void> _restoreDatabaseBytes(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
  ) async {
    if (bytes.isEmpty || !context.mounted) return;

    final confirmed = await _showDestructiveReplaceConfirmation(
      context: context,
      title: 'Restore database backup?',
      confirmLabel: 'Restore',
    );
    if (confirmed != true || !context.mounted) return;

    await _replaceDatabaseBytes(ref, bytes);
    if (!context.mounted) return;
    await _showInfoDialog(context, 'Database restored from backup.');
  }

  Future<void> _showLegacyImportSummary(
    BuildContext context,
    LegacySimpleLogDbImportResult stats,
  ) async {
    await showAppMessageDialog(
      context,
      title: 'Import Summary',
      message:
          'Aircraft Types: ${stats.aircraftTypes}\n'
          'Aircraft: ${stats.aircrafts}\n'
          'Airports: ${stats.airports}\n'
          'Crew: ${stats.crew}\n'
          'Flights: ${stats.flights}\n'
          'Simulator Sessions: ${stats.simulators}\n'
          'Flight Crew Assignments: ${stats.flightCrewAssignments}\n'
          'Simulator Crew Assignments: ${stats.simulatorCrewAssignments}',
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final exporter = SimpleLogCsvExporter(db);
    final csv = await exporter.exportFlightsAndSimulatorsCsv();
    if (!context.mounted) return;

    final timestamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('-', '')
        .split('.')
        .first;
    final fileName = 'simplelog_export_$timestamp.csv';
    final bytes = Uint8List.fromList(<int>[
      0xEF,
      0xBB,
      0xBF,
      ...utf8.encode(csv),
    ]);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV Export',
      fileName: fileName,
      type: Platform.isIOS || Platform.isAndroid
          ? FileType.custom
          : FileType.any,
      allowedExtensions: Platform.isIOS || Platform.isAndroid
          ? const ['csv']
          : null,
      bytes: Platform.isIOS || Platform.isAndroid ? bytes : null,
    );
    if (path == null || path.isEmpty || !context.mounted) return;

    if (!Platform.isIOS && !Platform.isAndroid) {
      try {
        await File(path).writeAsBytes(bytes, flush: true);
      } on FileSystemException {
        final docsDir = await getApplicationDocumentsDirectory();
        final fallbackPath =
            '${docsDir.path}${Platform.pathSeparator}$fileName';
        await File(fallbackPath).writeAsBytes(bytes, flush: true);
        if (!context.mounted) return;
        await _showInfoDialog(context, 'CSV exported to fallback location.');
        return;
      }
    }

    if (!context.mounted) return;
    await _showInfoDialog(context, 'CSV exported.');
  }

  Future<void> _backupDatabase(BuildContext context, WidgetRef ref) async {
    final bytes = await _readDatabaseBytes(ref);
    if (!context.mounted) return;

    final nowUtc = DateTime.now().toUtc();
    final yyyy = nowUtc.year.toString().padLeft(4, '0');
    final mm = nowUtc.month.toString().padLeft(2, '0');
    final dd = nowUtc.day.toString().padLeft(2, '0');
    final fileName = 'simplelog-backup-$yyyy-$mm-$dd.sqlite';
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save database backup',
      fileName: fileName,
      type: Platform.isIOS || Platform.isAndroid
          ? FileType.custom
          : FileType.any,
      allowedExtensions: Platform.isIOS || Platform.isAndroid
          ? const ['sqlite']
          : null,
      bytes: Platform.isIOS || Platform.isAndroid ? bytes : null,
    );
    if (path == null || path.isEmpty || !context.mounted) return;

    if (!Platform.isIOS && !Platform.isAndroid) {
      try {
        await File(path).writeAsBytes(bytes, flush: true);
      } on FileSystemException {
        final docsDir = await getApplicationDocumentsDirectory();
        final fallbackPath =
            '${docsDir.path}${Platform.pathSeparator}$fileName';
        await File(fallbackPath).writeAsBytes(bytes, flush: true);
        if (!context.mounted) return;
        await _showInfoDialog(
          context,
          'Backup saved.',
        );
        return;
      }
    }

    if (!context.mounted) return;
    await _showInfoDialog(context, 'Backup saved.');
  }

  void _showImportProgressDialog(
    BuildContext context,
    ValueNotifier<_ImportProgress> progress,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.databaseImportingTitle),
          content: ValueListenableBuilder<_ImportProgress>(
            valueListenable: progress,
            builder: (context, value, _) {
              final total = value.total;
              final processed = value.processed;
              final percent = total > 0 ? processed / total : null;
              final label = total > 0
                  ? AppLocalizations.of(
                      context,
                    )!.databaseImportProgressLabel(processed, total)
                  : AppLocalizations.of(context)!.databasePreparingLabel;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: percent),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: Text(label)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showImportSummary(
    BuildContext context,
    SimpleLogImportResult stats,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showAppMessageDialog(
      context,
      title: l10n.databaseImportSummaryTitle,
      message:
          '''
${l10n.databaseRowsLabel(stats.totalRows)}
${l10n.databaseFlightsLabel(stats.flights)}
${l10n.databasePositioningsLabel(stats.positionings)}
${l10n.databaseSimulatorsLabel(stats.simulators)}
${l10n.databaseAirportsLabel(stats.airports)}
${l10n.databaseAircraftTypesLabel(stats.aircraftTypes)}
${l10n.databaseAircraftLabel(stats.aircrafts)}
${l10n.databaseCrewLabel(stats.crew)}
${l10n.databaseSkippedLabel(stats.skipped)}
${l10n.databaseErrorsLabel(stats.errors)}
''',
    );
  }

  Future<void> _showLogTenImportSummary(
    BuildContext context,
    LogTenImportResult result,
  ) async {
    final stats = result.summary;
    final issues = ImportIssueAdapter.mapLogTenIssues(result.issues);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.databaseImportSummaryTitle),
        content: SizedBox(
          width: 720,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text('''
${l10n.databaseRowsLabel(stats.totalRows)}
${l10n.databaseFlightsLabel(stats.flights)}
${l10n.databasePositioningsLabel(stats.positionings)}
${l10n.databaseSimulatorsLabel(stats.simulators)}
${l10n.databaseAirportsLabel(stats.airports)}
${l10n.databaseAircraftTypesLabel(stats.aircraftTypes)}
${l10n.databaseAircraftLabel(stats.aircrafts)}
${l10n.databaseCrewLabel(stats.crew)}
${l10n.databaseSkippedLabel(stats.skipped)}
${l10n.databaseErrorsLabel(stats.errors)}
''');
                },
              ),
              if (issues.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.databaseSkippedLinesTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    itemCount: issues.length,
                    itemBuilder: (context, index) {
                      final issue = issues[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          AppLocalizations.of(context)!.databaseLineIssueLabel(
                            issue.sourceLineNumber ?? 0,
                            issue.message,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => AppNavigator.pop(context),
            child: Text(AppLocalizations.of(context)!.okAction),
          ),
        ],
      ),
    );
  }

  Future<LogTenImportOptions?> _reviewLogTenImportIssues(
    BuildContext context, {
    required SimpleLogCsvImporter importer,
    required String content,
    required String fileName,
    required LogTenProTsvInspection inspection,
    required LogTenImportOptions initialOptions,
  }) async {
    var options = initialOptions;
    while (true) {
      final issues = await importer.validateLogTenProTsv(
        content,
        options: options,
      );
      if (!context.mounted) return null;
      if (issues.isEmpty) {
        return options;
      }
      final review = await LogTenProImportReviewDialog.show(
        context,
        issues: issues,
        options: options,
      );
      if (review == null) {
        if (!context.mounted) return null;
        final updatedOptions = await LogTenProImportOptionsDialog.show(
          context,
          fileName: fileName,
          inspection: inspection,
          initial: options,
        );
        if (updatedOptions == null || !context.mounted) {
          return null;
        }
        options = updatedOptions;
        continue;
      }
      options = options.copyWith(
        valueOverrides: review.valueOverrides,
        ignoredLines: review.ignoredLines,
      );
    }
  }

  Future<WaderImportReviewOptions?> _reviewWaderImportIssues(
    BuildContext context, {
    required AppDatabase db,
    required SimpleLogCsvImporter importer,
    required String content,
    required WaderImportOptions importOptions,
  }) async {
    var reviewOptions = const WaderImportReviewOptions();
    while (true) {
      final issues = await importer.validateWaderLogbookCsv(
        content,
        options: importOptions,
        reviewOptions: reviewOptions,
      );
      if (!context.mounted) return null;
      if (issues.isEmpty) {
        return reviewOptions;
      }
      final review = await WaderImportReviewDialog.show(
        context,
        db: db,
        issues: issues,
        initialOptions: reviewOptions,
      );
      if (review == null) {
        return null;
      }
      reviewOptions = review;
    }
  }

  Future<SouthwestImportOptions?> _resolveSouthwestCriticalIssues(
    BuildContext context, {
    required SimpleLogCsvImporter importer,
    required String content,
    required SouthwestImportOptions initialOptions,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final report = importer.inspectSouthwestCsv(content);
    final hasBlockingIssues =
        report.missingRequiredIssues.isNotEmpty ||
        report.missingAircraftTailIssues.isNotEmpty;
    if (!hasBlockingIssues) {
      return initialOptions.copyWith(
        missingAircraftTypePolicy:
            SouthwestMissingAircraftTypePolicy.useUnknown,
        missingAircraftTailPolicy:
            SouthwestMissingAircraftTailPolicy.useTypeAsTail,
        skippedSourceLineNumbers: const <int>{},
      );
    }

    final skippedLines = <int>{};
    var tailPolicy = SouthwestMissingAircraftTailPolicy.useTypeAsTail;

    if (report.missingRequiredIssues.isNotEmpty) {
      final requiredIssues = _criticalIssueResolver
          .mapSouthwestMissingRequiredIssues(
            report.missingRequiredIssues,
            fieldLabelBuilder: (field) {
              return switch (field) {
                SouthwestMissingRequiredField.date =>
                  l10n.southwestPreflightFieldDate,
                SouthwestMissingRequiredField.departureAirport =>
                  l10n.southwestPreflightFieldDepartureAirport,
                SouthwestMissingRequiredField.arrivalAirport =>
                  l10n.southwestPreflightFieldArrivalAirport,
                SouthwestMissingRequiredField.departureTime =>
                  l10n.southwestPreflightFieldDepartureTime,
                SouthwestMissingRequiredField.arrivalTime =>
                  l10n.southwestPreflightFieldArrivalTime,
              };
            },
            reasonBuilder: l10n.southwestPreflightMissingFieldsReason,
          );
      final decision = await SouthwestImportPreflightDialog.show(
        context,
        title: l10n.southwestPreflightMissingRequiredTitle,
        message: l10n.southwestPreflightMissingRequiredMessage,
        issues: [
          for (final issue in requiredIssues)
            l10n.databaseLineIssueLabel(
              issue.sourceLineNumber ?? 0,
              issue.message,
            ),
        ],
        primaryActionLabel: l10n.southwestPreflightSkipLinesAction,
      );
      if (decision != SouthwestPreflightDialogDecision.primary) {
        return null;
      }
      skippedLines.addAll(_criticalIssueResolver.sourceLinesOf(requiredIssues));
      if (!context.mounted) return null;
    }

    final unresolvedTailIssues = report.missingAircraftTailIssues
        .where((issue) => !skippedLines.contains(issue.sourceLineNumber))
        .toList(growable: false);
    if (unresolvedTailIssues.isNotEmpty) {
      final tailIssues = _criticalIssueResolver.mapSouthwestMissingTailIssues(
        unresolvedTailIssues,
        unknownTypeLabel: l10n.southwestPreflightUnknownTypeLabel,
      );
      final decision = await SouthwestImportPreflightDialog.show(
        context,
        title: l10n.southwestPreflightMissingTailTitle,
        message: l10n.southwestPreflightMissingTailMessage,
        issues: [
          for (final issue in tailIssues)
            l10n.databaseLineIssueLabel(
              issue.sourceLineNumber ?? 0,
              issue.message,
            ),
        ],
        primaryActionLabel: l10n.southwestPreflightImportAnywayAction,
        secondaryActionLabel: l10n.southwestPreflightSkipLinesAction,
        infoTitle: l10n.southwestPreflightMissingTailInfoTitle,
        infoMessage: l10n.southwestPreflightMissingTailInfoMessage,
        showInfoNextToProceedLabel: true,
      );
      if (decision == SouthwestPreflightDialogDecision.cancel) {
        return null;
      }
      if (decision == SouthwestPreflightDialogDecision.secondary) {
        skippedLines.addAll(_criticalIssueResolver.sourceLinesOf(tailIssues));
        tailPolicy = SouthwestMissingAircraftTailPolicy.skipLines;
      }
    }

    return initialOptions.copyWith(
      missingAircraftTailPolicy: tailPolicy,
      skippedSourceLineNumbers: skippedLines,
    );
  }

  Future<SouthwestImportOptions?> _resolveSouthwestAirportIssues(
    BuildContext context, {
    required AppDatabase db,
    required String content,
    required SouthwestImportOptions options,
  }) async {
    final airportResolutionTitle = AppLocalizations.of(
      context,
    )!.waderReviewTitle;
    final existingAirportIcaos = <String>{
      for (final airport in await db.select(db.airports).get())
        airport.icao.trim().toUpperCase(),
    };
    final issues = _collectSouthwestAirportIssues(
      content,
      existingAirportIcaos: existingAirportIcaos,
      skippedLines: options.skippedSourceLineNumbers,
      overrides: options.airportCodeOverrides,
    );
    if (issues.isEmpty) {
      return options;
    }
    if (!context.mounted) {
      return null;
    }
    final resolution = await RowImportAirportResolutionSheet.show(
      context,
      db: db,
      title: airportResolutionTitle,
      issues: issues,
    );
    if (resolution == null || resolution.stopImport) {
      return null;
    }
    final mergedSkipped = <int>{
      ...options.skippedSourceLineNumbers,
      ...resolution.skippedLines,
    };
    final mergedOverrides = <int, Map<String, String>>{
      for (final entry in options.airportCodeOverrides.entries)
        entry.key: Map<String, String>.from(entry.value),
    };
    for (final entry in resolution.replacements.entries) {
      final map = mergedOverrides.putIfAbsent(
        entry.key,
        () => <String, String>{},
      );
      for (final fieldEntry in entry.value.entries) {
        map[fieldEntry.key == RowImportAirportField.departure ? 'from' : 'to'] =
            fieldEntry.value.trim().toUpperCase();
      }
    }
    return options.copyWith(
      skippedSourceLineNumbers: mergedSkipped,
      airportCodeOverrides: mergedOverrides,
    );
  }

  List<RowImportAirportIssue> _collectSouthwestAirportIssues(
    String content, {
    required Set<String> existingAirportIcaos,
    required Set<int> skippedLines,
    required Map<int, Map<String, String>> overrides,
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    final headerRowIndex = rows.indexWhere(
      (row) =>
          row.isNotEmpty &&
          SimpleLogCsvSupport.clean(row.first).toUpperCase() == 'DATE',
    );
    if (headerRowIndex < 0) {
      return const <RowImportAirportIssue>[];
    }
    final header = rows[headerRowIndex];
    final index = <String, int>{
      for (var i = 0; i < header.length; i += 1)
        SimpleLogCsvSupport.clean(header[i]).toUpperCase(): i,
    };
    int idx(String name) => index[name.toUpperCase()] ?? -1;
    String get(List<String> row, int i) =>
        i >= 0 && i < row.length ? row[i].trim() : '';

    final issues = <RowImportAirportIssue>[];
    final fromIdx = idx('From');
    final toIdx = idx('To');
    for (
      var rowIndex = headerRowIndex + 1;
      rowIndex < rows.length;
      rowIndex += 1
    ) {
      final line = rowIndex + 1;
      if (skippedLines.contains(line)) {
        continue;
      }
      final row = rows[rowIndex];
      if (row.isEmpty) continue;
      final lineOverrides = overrides[line];
      final from = (lineOverrides?['from'] ?? get(row, fromIdx)).toUpperCase();
      final to = (lineOverrides?['to'] ?? get(row, toIdx)).toUpperCase();
      _appendAirportIssue(
        issues,
        lineNumber: line,
        field: RowImportAirportField.departure,
        code: from,
        existingAirportIcaos: existingAirportIcaos,
      );
      _appendAirportIssue(
        issues,
        lineNumber: line,
        field: RowImportAirportField.arrival,
        code: to,
        existingAirportIcaos: existingAirportIcaos,
      );
    }
    return issues;
  }

  void _appendAirportIssue(
    List<RowImportAirportIssue> issues, {
    required int lineNumber,
    required RowImportAirportField field,
    required String code,
    required Set<String> existingAirportIcaos,
  }) {
    final codeTrim = code.trim().toUpperCase();
    if (codeTrim.isEmpty) {
      issues.add(
        RowImportAirportIssue(
          lineNumber: lineNumber,
          field: field,
          code: codeTrim,
          reason: field == RowImportAirportField.departure
              ? 'Departure airport is missing.'
              : 'Arrival airport is missing.',
        ),
      );
      return;
    }
    final isValid = RegExp(r'^[A-Z0-9]{4}$').hasMatch(codeTrim);
    if (!isValid) {
      issues.add(
        RowImportAirportIssue(
          lineNumber: lineNumber,
          field: field,
          code: codeTrim,
          reason: 'Airport ICAO code $codeTrim is not valid.',
        ),
      );
      return;
    }
    if (!existingAirportIcaos.contains(codeTrim)) {
      issues.add(
        RowImportAirportIssue(
          lineNumber: lineNumber,
          field: field,
          code: codeTrim,
          reason: 'Airport $codeTrim does not exist in the database.',
        ),
      );
    }
  }

  Future<Map<String, String>?> _resolveSouthwestTypeMappings(
    BuildContext context, {
    required SimpleLogCsvImporter importer,
    required String content,
    required String fileName,
    required Map<String, String> initialMappings,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final normalizedInitialMappings = _normalizeSouthwestTypeMappings(
      initialMappings,
    );
    final inferredMappings = _normalizeSouthwestTypeMappings(
      await importer.inferSouthwestTypeMappingsFromExistingAircraft(content),
    );
    final knownMappings = <String, String>{
      ...inferredMappings,
      ...normalizedInitialMappings,
    };

    final rawTypeCodes =
        (await importer.extractSouthwestRawTypeCodesForAircraftCreation(
          content,
        )).toList()..sort(_compareSouthwestRawTypeCodes);
    final registrationsByRawType = await importer
        .extractSouthwestAircraftRegistrationsByRawTypeForAircraftCreation(
          content,
        );
    if (!context.mounted) {
      return null;
    }
    if (rawTypeCodes.isEmpty) {
      return knownMappings;
    }

    final scopedKnownMappings = <String, String>{
      for (final rawTypeCode in rawTypeCodes)
        if (knownMappings.containsKey(rawTypeCode))
          rawTypeCode: knownMappings[rawTypeCode]!,
    };
    final unresolvedTypeCodes = rawTypeCodes
        .where((rawTypeCode) => !scopedKnownMappings.containsKey(rawTypeCode))
        .toList(growable: false);

    if (unresolvedTypeCodes.isEmpty) {
      final decision = await _showSouthwestMappingsReviewChoice(
        context,
        message: l10n.southwestTypeMappingsResolvedPrompt,
      );
      if (!context.mounted) {
        return null;
      }
      if (decision == _SouthwestMappingsReviewChoice.cancel) {
        return null;
      }
      if (decision == _SouthwestMappingsReviewChoice.skipReview) {
        return knownMappings;
      }
    }

    if (!context.mounted) {
      return null;
    }
    final reviewedMappings = await SouthwestTypeMappingsDialog.show(
      context,
      fileName: fileName,
      rawTypeCodes: rawTypeCodes,
      rawTypeAircraftRegistrations: registrationsByRawType,
      initialMappings: scopedKnownMappings,
    );
    if (reviewedMappings == null || !context.mounted) {
      return null;
    }
    return <String, String>{
      ...knownMappings,
      ..._normalizeSouthwestTypeMappings(reviewedMappings),
    };
  }

  Future<_SouthwestMappingsReviewChoice> _showSouthwestMappingsReviewChoice(
    BuildContext context, {
    required String message,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await _showThreeChoiceDialog<_SouthwestMappingsReviewChoice>(
      context: context,
      title: l10n.southwestTypeMappingsDialogTitle,
      message: message,
      cancelLabel: l10n.cancelAction,
      cancelValue: _SouthwestMappingsReviewChoice.cancel,
      secondaryLabel: l10n.southwestTypeMappingsContinueWithoutReviewAction,
      secondaryValue: _SouthwestMappingsReviewChoice.skipReview,
      primaryLabel: l10n.southwestTypeMappingsReviewAction,
      primaryValue: _SouthwestMappingsReviewChoice.reviewNow,
    );
    return choice ?? _SouthwestMappingsReviewChoice.cancel;
  }

  int _compareSouthwestRawTypeCodes(String left, String right) {
    if (left.isEmpty && right.isNotEmpty) {
      return -1;
    }
    if (left.isNotEmpty && right.isEmpty) {
      return 1;
    }
    return left.compareTo(right);
  }

  Map<String, String> _normalizeSouthwestTypeMappings(
    Map<String, String> mappings,
  ) {
    return <String, String>{
      for (final entry in mappings.entries)
        if (_normalizeSouthwestTypeCode(entry.value) != null)
          _normalizeSouthwestTypeCode(entry.key) ?? '':
              _normalizeSouthwestTypeCode(entry.value)!,
    };
  }

  String? _normalizeSouthwestTypeCode(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Future<_DatabaseExportChoice?> _showExportTypeDialog(
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<_DatabaseExportChoice?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ExportChoiceTile(
              icon: Icons.table_view_outlined,
              label: l10n.databaseExportCsvAction,
              onTap: () =>
                  AppNavigator.pop(sheetContext, _DatabaseExportChoice.csv),
            ),
            _ExportChoiceTile(
              icon: Icons.save_alt_outlined,
              label: l10n.databaseBackupLogbookAction,
              onTap: () =>
                  AppNavigator.pop(sheetContext, _DatabaseExportChoice.backup),
            ),
            _ExportChoiceTile(
              icon: Icons.close,
              label: l10n.cancelAction,
              onTap: () => AppNavigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  Future<T?> _showThreeChoiceDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String cancelLabel,
    required T? cancelValue,
    required String secondaryLabel,
    required T secondaryValue,
    required String primaryLabel,
    required T primaryValue,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(dialogContext, cancelValue),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => AppNavigator.pop(dialogContext, secondaryValue),
            child: Text(secondaryLabel),
          ),
          FilledButton(
            onPressed: () => AppNavigator.pop(dialogContext, primaryValue),
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context, String message) async {
    if (!context.mounted) return;
    await showAppMessageDialog(context, message: message);
  }

  Future<bool?> _showDestructiveReplaceConfirmation({
    required BuildContext context,
    required String title,
    required String confirmLabel,
  }) {
    return _showConfirmationDialog(
      context: context,
      title: title,
      message: _replaceDataWarningMessage,
      confirmLabel: confirmLabel,
      cancelLabel: 'Cancel',
    );
  }

  Future<bool?> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => AppNavigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _importQatarAirwaysWorkbook(
    BuildContext context, {
    required AppDatabase db,
    required QatarAirwaysWorkbookInspection inspection,
    required QatarAirwaysImportOptions options,
  }) async {
    final importer = SimpleLogCsvImporter(db);
    final progress = ValueNotifier<_ImportProgress>(
      const _ImportProgress(processed: 0, total: 0),
    );
    _showImportProgressDialog(context, progress);
    ImportOperationResult<SimpleLogImportResult>? outcome;
    try {
      outcome = await importer.importQatarAirwaysWorkbookSafely(
        inspection,
        options: options,
        onProgress: (processed, total) => progress.value = _ImportProgress(
          processed: processed,
          total: total,
        ),
      );
    } finally {
      progress.dispose();
    }
    if (!context.mounted) return;
    AppNavigator.popRoot(context);
    if (!context.mounted) return;
    if (!outcome.isSuccess) {
      final message = _buildImportErrorMessage(outcome.failure);
      await _showInfoDialog(context, message);
      return;
    }
    await _showImportSummary(context, outcome.data!);
  }

  void _logQatarAirwaysColumns(QatarAirwaysWorkbookInspection inspection) {
    debugPrint(
      'Qatar Airways workbook detected. '
      'Sheet: ${inspection.sheetName}. '
      'Columns: ${inspection.columns.length}',
    );
    for (var index = 0; index < inspection.columns.length; index++) {
      debugPrint(
        'Qatar Airways column ${index + 1}: ${inspection.columns[index]}',
      );
    }
  }

  void _logLogTenProColumns(LogTenProTsvInspection inspection) {
    debugPrint(
      'LogTen Pro export detected. Columns: ${inspection.columns.length}',
    );
    for (var index = 0; index < inspection.columns.length; index++) {
      debugPrint(
        'LogTen Pro column ${index + 1}: ${inspection.columns[index]}',
      );
    }
  }

  Future<CrewData?> _loadSelfCrew(AppDatabase db) async {
    final crew = await (db.select(
      db.crew,
    )..where((tbl) => tbl.isSelf.equals(true))).get();
    return crew.isEmpty ? null : crew.first;
  }

  Future<QatarAirwaysWorkbookInspection?> _resolveQatarAirportIssues(
    BuildContext context, {
    required AppDatabase db,
    required QatarAirwaysWorkbookInspection inspection,
  }) async {
    final knownIata = <String>{
      for (final airport in await db.select(db.airports).get())
        if ((airport.iata ?? '').trim().isNotEmpty)
          airport.iata!.trim().toUpperCase(),
    };
    final issues = <RowImportAirportIssue>[];
    for (final row in inspection.rows) {
      final hasFlight = _isValidQatarDateText(row.read('DATE (dd/mm/yy)'));
      final hasSimulator = _isValidQatarDateText(
        row.read('FSTD SESSION DATE (dd/mm/yy)'),
      );
      if (!hasFlight && !hasSimulator) {
        continue;
      }
      if (!hasFlight) {
        // Simulator-only rows must not require departure/arrival airports.
        continue;
      }
      final departure = row.read('DEPARTURE PLACE').trim().toUpperCase();
      final arrival = row.read('ARRIVAL PLACE').trim().toUpperCase();
      if (departure.isEmpty || departure.length != 3) {
        issues.add(
          RowImportAirportIssue(
            lineNumber: row.rowNumber,
            field: RowImportAirportField.departure,
            code: departure,
            reason: departure.isEmpty
                ? 'Departure airport is missing.'
                : 'Airport IATA code $departure is not valid.',
            codeKind: RowImportAirportCodeKind.iata,
          ),
        );
      } else if (!knownIata.contains(departure)) {
        issues.add(
          RowImportAirportIssue(
            lineNumber: row.rowNumber,
            field: RowImportAirportField.departure,
            code: departure,
            reason: 'Airport $departure does not exist in the database.',
            codeKind: RowImportAirportCodeKind.iata,
          ),
        );
      }
      if (arrival.isEmpty || arrival.length != 3) {
        issues.add(
          RowImportAirportIssue(
            lineNumber: row.rowNumber,
            field: RowImportAirportField.arrival,
            code: arrival,
            reason: arrival.isEmpty
                ? 'Arrival airport is missing.'
                : 'Airport IATA code $arrival is not valid.',
            codeKind: RowImportAirportCodeKind.iata,
          ),
        );
      } else if (!knownIata.contains(arrival)) {
        issues.add(
          RowImportAirportIssue(
            lineNumber: row.rowNumber,
            field: RowImportAirportField.arrival,
            code: arrival,
            reason: 'Airport $arrival does not exist in the database.',
            codeKind: RowImportAirportCodeKind.iata,
          ),
        );
      }
    }
    if (issues.isEmpty) {
      return inspection;
    }
    if (!context.mounted) return null;
    final resolution = await RowImportAirportResolutionSheet.show(
      context,
      db: db,
      title: AppLocalizations.of(context)!.waderReviewTitle,
      issues: issues,
    );
    if (resolution == null || resolution.stopImport) {
      return null;
    }

    final replacedRows = inspection.rows
        .map((row) {
          final hasFlight = _isValidQatarDateText(row.read('DATE (dd/mm/yy)'));
          final hasSimulator = _isValidQatarDateText(
            row.read('FSTD SESSION DATE (dd/mm/yy)'),
          );
          if (!hasFlight && !hasSimulator) {
            return null;
          }
          if (resolution.skippedLines.contains(row.rowNumber)) {
            return null;
          }
          final replacements = resolution.replacements[row.rowNumber];
          if (replacements == null || replacements.isEmpty) {
            return row;
          }
          final values = Map<String, String>.from(row.valuesByColumn);
          final depReplacement = replacements[RowImportAirportField.departure];
          final arrReplacement = replacements[RowImportAirportField.arrival];
          if (depReplacement != null && depReplacement.trim().isNotEmpty) {
            values['DEPARTURE PLACE'] = depReplacement.trim().toUpperCase();
          }
          if (arrReplacement != null && arrReplacement.trim().isNotEmpty) {
            values['ARRIVAL PLACE'] = arrReplacement.trim().toUpperCase();
          }
          return QatarAirwaysWorkbookRow(
            rowNumber: row.rowNumber,
            valuesByColumn: values,
          );
        })
        .whereType<QatarAirwaysWorkbookRow>()
        .toList(growable: false);

    return QatarAirwaysWorkbookInspection(
      sheetName: inspection.sheetName,
      columns: inspection.columns,
      rows: replacedRows,
    );
  }

  bool _isValidQatarDateText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    try {
      DateFormat('dd/MM/yy').parseStrict(trimmed);
      return true;
    } on FormatException {
      return false;
    }
  }

  Future<QatarAirwaysWorkbookInspection?> _resolveQatarAircraftIssues(
    BuildContext context, {
    required AppDatabase db,
    required QatarAirwaysWorkbookInspection inspection,
  }) async {
    final reviewTitle = AppLocalizations.of(context)!.waderReviewTitle;
    await _autoCreateQatarAircraftWithType(db, inspection);
    if (!context.mounted) {
      return null;
    }
    final issues = await _findQatarMissingAircraftIssues(db, inspection);
    if (!context.mounted) {
      return null;
    }
    if (issues.isEmpty) {
      return inspection;
    }
    final resolution = await RowImportAircraftResolutionSheet.show(
      context,
      db: db,
      title: reviewTitle,
      issues: issues,
    );
    if (resolution == null || resolution.stopImport || !context.mounted) {
      return null;
    }
    final replacedRows = inspection.rows
        .map((row) {
          final hasFlight = _isValidQatarDateText(row.read('DATE (dd/mm/yy)'));
          final hasSimulator = _isValidQatarDateText(
            row.read('FSTD SESSION DATE (dd/mm/yy)'),
          );
          if (!hasFlight && !hasSimulator) {
            return null;
          }
          if (resolution.skippedLines.contains(row.rowNumber)) {
            return null;
          }
          final replacement = resolution.replacements[row.rowNumber];
          if (replacement == null || replacement.trim().isEmpty) {
            return row;
          }
          final values = Map<String, String>.from(row.valuesByColumn);
          if (hasFlight) {
            values['AIRCRAFT REG'] = replacement.trim().toUpperCase();
          } else {
            values['FSTD SESSION TYPE'] = replacement.trim().toUpperCase();
          }
          return QatarAirwaysWorkbookRow(
            rowNumber: row.rowNumber,
            valuesByColumn: values,
          );
        })
        .whereType<QatarAirwaysWorkbookRow>()
        .toList(growable: false);
    return QatarAirwaysWorkbookInspection(
      sheetName: inspection.sheetName,
      columns: inspection.columns,
      rows: replacedRows,
    );
  }

  Future<void> _autoCreateQatarAircraftWithType(
    AppDatabase db,
    QatarAirwaysWorkbookInspection inspection,
  ) async {
    final existingAircraft = await db.select(db.aircrafts).get();
    final existingTypes = await db.select(db.aircraftTypes).get();
    final aircraftKeys = <String>{
      for (final aircraft in existingAircraft)
        _aircraftIdentityKey(
          aircraft.registration.trim().toUpperCase(),
          aircraft.isSimulator,
        ),
    };
    final typeIdByCode = <String, int>{
      for (final type in existingTypes) type.code.trim().toUpperCase(): type.id,
    };

    for (final row in inspection.rows) {
      final hasFlight = _isValidQatarDateText(row.read('DATE (dd/mm/yy)'));
      final hasSimulator = _isValidQatarDateText(
        row.read('FSTD SESSION DATE (dd/mm/yy)'),
      );
      if (!hasFlight && !hasSimulator) {
        continue;
      }
      final isSimulator = !hasFlight && hasSimulator;
      final registration =
          (isSimulator
                  ? row.read('FSTD SESSION TYPE')
                  : row.read('AIRCRAFT REG'))
              .trim()
              .toUpperCase();
      if (registration.isEmpty) {
        continue;
      }
      final key = _aircraftIdentityKey(registration, isSimulator);
      if (aircraftKeys.contains(key)) {
        continue;
      }
      final typeCode = row.read('AIRCRAFT TYPE').trim().toUpperCase();
      if (typeCode.isEmpty) {
        continue;
      }
      var typeId = typeIdByCode[typeCode];
      if (typeId == null) {
        typeId = await db
            .into(db.aircraftTypes)
            .insert(
              AircraftTypesCompanion.insert(
                code: typeCode,
                family: typeCode,
                longName: typeCode,
                manufacturer: const Value(null),
                category: AircraftCategory.landplane,
                engineType: EngineType.jet,
                mtow: 0,
                engineCount: 2,
                multiPilot: true,
                complex: true,
                efis: true,
                highPerformance: true,
                isLocked: false,
              ),
            );
        typeIdByCode[typeCode] = typeId;
      }
      await db
          .into(db.aircrafts)
          .insert(
            AircraftsCompanion.insert(
              aircraftTypeId: typeId,
              registration: registration,
              mtow: const Value(null),
              isSimulator: isSimulator,
              isFavorite: false,
              isLocked: false,
              notes: const Value(null),
            ),
          );
      aircraftKeys.add(key);
    }
  }

  Future<List<RowImportAircraftIssue>> _findQatarMissingAircraftIssues(
    AppDatabase db,
    QatarAirwaysWorkbookInspection inspection,
  ) async {
    final existingAircraft = await db.select(db.aircrafts).get();
    final existingKeys = <String>{
      for (final aircraft in existingAircraft)
        _aircraftIdentityKey(
          aircraft.registration.trim().toUpperCase(),
          aircraft.isSimulator,
        ),
    };
    final issues = <RowImportAircraftIssue>[];
    for (final row in inspection.rows) {
      final hasFlight = _isValidQatarDateText(row.read('DATE (dd/mm/yy)'));
      final hasSimulator = _isValidQatarDateText(
        row.read('FSTD SESSION DATE (dd/mm/yy)'),
      );
      if (!hasFlight && !hasSimulator) {
        continue;
      }
      final isSimulator = !hasFlight && hasSimulator;
      final registration =
          (isSimulator
                  ? row.read('FSTD SESSION TYPE')
                  : row.read('AIRCRAFT REG'))
              .trim()
              .toUpperCase();
      if (registration.isEmpty) {
        continue;
      }
      final key = _aircraftIdentityKey(registration, isSimulator);
      if (existingKeys.contains(key)) {
        continue;
      }
      final typeCode = row.read('AIRCRAFT TYPE').trim().toUpperCase();
      if (typeCode.isNotEmpty) {
        continue;
      }
      issues.add(
        RowImportAircraftIssue(
          lineNumber: row.rowNumber,
          registration: registration,
          kind: isSimulator
              ? RowImportAircraftKind.simulator
              : RowImportAircraftKind.aircraft,
          reason:
              '${isSimulator ? 'Simulator' : 'Aircraft'} $registration '
              'does not exist in the database.',
        ),
      );
    }
    return issues;
  }

  Future<Uint8List> _readDatabaseBytes(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final path = await _databasePath();
    return File(path).readAsBytes();
  }

  String _aircraftIdentityKey(String registration, bool isSimulator) {
    return '$registration|${isSimulator ? 1 : 0}';
  }

  Future<void> _replaceDatabaseBytes(WidgetRef ref, Uint8List bytes) async {
    final db = ref.read(databaseProvider);
    await db.close();
    final path = await _databasePath();
    await File(path).writeAsBytes(bytes, flush: true);
    ref
      ..invalidate(databaseProvider)
      ..invalidate(flightFactoringSettingsProvider)
      ..invalidate(dutyRulesSettingsProvider)
      ..invalidate(reportPilotInfoProvider);
  }

  Future<String> _databasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final currentPath = '${dir.path}/$appDatabaseFileName.sqlite';
    final legacyPath = '${dir.path}/simplelog.sqlite';
    if (File(currentPath).existsSync()) {
      return currentPath;
    }
    if (File(legacyPath).existsSync()) {
      return legacyPath;
    }
    return currentPath;
  }

  Future<bool> _showOptionsDialog(
    BuildContext context,
    ImportSourceKind type,
    String fileName,
  ) async {
    final label = _sourceDispatcher.labelFor(type);
    final result = await _showConfirmationDialog(
      context: context,
      title: 'Import Options',
      message: 'File: $fileName\nDetected: $label',
      confirmLabel: 'Continue',
      cancelLabel: 'Cancel',
    );
    return result ?? false;
  }

  String _titleForImportType(BuildContext context, ImportSourceKind type) {
    final l10n = AppLocalizations.of(context)!;
    return switch (type) {
      ImportSourceKind.legacySimpleLogCsv => l10n.simplelogImportOptionsTitle,
      ImportSourceKind.southwestCsv => l10n.southwestImportOptionsTitle,
      ImportSourceKind.qatarAirwaysXlsx => l10n.qatarImportTitle,
      ImportSourceKind.logTenProTsv => l10n.logtenImportTitle,
      ImportSourceKind.waderLogbookCsv => l10n.waderImportOptionsTitle,
      ImportSourceKind.unknown => l10n.databaseImportFileAction,
    };
  }

  String _buildImportErrorMessage(ImportFailure? failure) {
    if (failure == null) return 'Import failed.';
    final prefix = switch (failure.type) {
      ImportFailureType.invalidFormat => 'Import failed: invalid CSV format.',
      ImportFailureType.parseError => 'Import failed while parsing data.',
      ImportFailureType.databaseError =>
        'Import failed while saving to database.',
      ImportFailureType.unexpected =>
        'Import failed due to an unexpected error.',
    };
    if (failure.message.isEmpty) return prefix;
    return '$prefix ${failure.message}';
  }
}

enum _SouthwestMappingsReviewChoice {
  cancel,
  skipReview,
  reviewNow,
}

enum _DatabaseExportChoice {
  csv,
  backup,
}

class _ExportChoiceTile extends StatelessWidget {
  const _ExportChoiceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _DatabaseSectionCard extends StatelessWidget {
  const _DatabaseSectionCard({
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
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (headerTrailing != null) ...<Widget>[headerTrailing!],
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

class _DatabaseActionButton extends StatelessWidget {
  const _DatabaseActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _ImportProgress {
  const _ImportProgress({required this.processed, required this.total});

  final int processed;
  final int total;
}
