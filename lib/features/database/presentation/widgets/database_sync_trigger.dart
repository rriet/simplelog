import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/export/simplelog_csv_exporter.dart';
import 'package:simplelog/data/import/dashboard_rules_seed_importer.dart';
import 'package:simplelog/data/import/import_operation_result.dart';
import 'package:simplelog/data/import/import_source_dispatcher.dart';
import 'package:simplelog/data/import/legacy_simplelog_db_importer.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/logten_pro_tsv_inspector.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/qatar_airways_workbook_inspector.dart';
import 'package:simplelog/data/import/simplelog_csv_importer.dart';
import 'package:simplelog/features/aircraft/presentation/aircraft_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/database/presentation/widgets/import_options_preferences.dart';
import 'package:simplelog/features/database/presentation/widgets/local_sync_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/logten_pro_import_options_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/logten_pro_import_review_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/qatar_airways_import_options_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/qatar_airways_preflight_dialogs.dart';
import 'package:simplelog/features/database/presentation/widgets/simplelog_import_options_dialog.dart';
import 'package:simplelog/features/database/presentation/widgets/southwest_import_options_dialog.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_preferences_provider.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';
import 'package:simplelog/state/providers/simulator_default_crew_position_provider.dart';

/// Main Database tab panel for sync, import/export, backup, and restore tools.
class DatabaseSyncTrigger extends ConsumerWidget {
  /// Creates the database tools panel.
  const DatabaseSyncTrigger({super.key});

  static const _sourceDispatcher = ImportSourceDispatcher();
  static const _logTenProInspector = LogTenProTsvInspector();
  static const _qatarAirwaysInspector = QatarAirwaysWorkbookInspector();
  static const _syncSubtitle = 'Connect two devices on the same network.';
  static const _importExportSubtitle =
      'Import supported files with automatic format detection, or export CSV.';
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
  }) {
    return _DatabaseSectionCard(
      title: title,
      subtitle: subtitle,
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
    final colorScheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Database Tools',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _DatabaseSectionCard(
              title: 'Sync',
              subtitle: _syncSubtitle,
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
              title: 'Import / Export',
              subtitle: _importExportSubtitle,
              firstIcon: Icons.upload_file,
              firstLabel: 'Import File',
              onFirstPressed: () => _importCsv(context, ref),
              secondIcon: Icons.download_outlined,
              secondLabel: 'Export CSV',
              onSecondPressed: () => _exportCsv(context, ref),
            ),
            const SizedBox(height: 12),
            _buildTwoActionSection(
              title: 'Backup / Restore',
              subtitle: 'Create and restore SQLite backups.',
              firstIcon: Icons.save_alt_outlined,
              firstLabel: 'Backup Logbook',
              onFirstPressed: () => _backupDatabase(context, ref),
              secondIcon: Icons.restore_outlined,
              secondLabel: 'Restore Logbook',
              onSecondPressed: () => _restoreDatabase(context, ref),
            ),
            const SizedBox(height: 12),
            _DatabaseSectionCard(
              title: 'Danger Zone',
              subtitle: 'Permanent operations.',
              accentColor: colorScheme.error,
              children: [
                _DatabaseActionButton(
                  icon: Icons.delete_forever_outlined,
                  label: 'Database Dump (Temporary)',
                  onPressed: () => _clearDatabase(context, ref),
                  danger: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importCsv(BuildContext context, WidgetRef ref) async {
    final isAndroid = Platform.isAndroid;
    final result = await FilePicker.platform.pickFiles(
      type: isAndroid ? FileType.any : FileType.custom,
      allowedExtensions: isAndroid
          ? null
          : const ['csv', 'sqlite', 'db', 'xlsx', 'txt', 'tsv'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (!context.mounted) return;
    final detectedFromName = _sourceDispatcher.detect(fileName: file.name);
    if (detectedFromName == ImportSourceKind.legacySimpleLogDb) {
      await _importDatabaseFile(context, ref, file);
      return;
    }
    final bytes =
        (file.path == null ? null : await File(file.path!).readAsBytes()) ??
        file.bytes;
    if (bytes == null) return;
    final content = _decodeCsvBytes(bytes);
    final type = _sourceDispatcher.detect(
      fileName: file.name,
      content: file.name.toLowerCase().endsWith('.xlsx') ? null : content,
      bytes: bytes,
    );
    if (!context.mounted) return;
    final db = ref.read(databaseProvider);

    if (type == ImportSourceKind.legacySimpleLogCsv) {
      final initialOptions = await ImportOptionsPreferences.loadSimpleLog(db);
      if (!context.mounted) return;
      final options = await SimpleLogImportOptionsDialog.show(
        context,
        fileName: file.name,
        initial: initialOptions,
      );
      if (options == null || !context.mounted) return;
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
      final airportsReady = await _resolveMissingQatarAirports(
        context,
        db: db,
        inspection: inspection,
      );
      if (!airportsReady || !context.mounted) return;
      final aircraftReady = await _resolveMissingQatarSimulatorAircraft(
        context,
        db: db,
        inspection: inspection,
      );
      if (!aircraftReady || !context.mounted) return;
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
        inspection: inspection,
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
      final initialOptions = await ImportOptionsPreferences.loadSouthwest(
        db: db,
        fallbackPosition: defaultPosition == CrewPosition.unknown
            ? CrewPosition.sic
            : defaultPosition,
      );
      if (!context.mounted) return;
      final options = await SouthwestImportOptionsDialog.show(
        context,
        fileName: file.name,
        initial: initialOptions,
      );
      if (options == null || !context.mounted) return;
      await ImportOptionsPreferences.saveSouthwest(db, options);
      if (!context.mounted) return;
      final importer = SimpleLogCsvImporter(db);
      final progress = ValueNotifier<_ImportProgress>(
        const _ImportProgress(processed: 0, total: 0),
      );
      _showImportProgressDialog(context, progress);
      ImportOperationResult<SimpleLogImportResult>? outcome;
      try {
        outcome = await importer.importSouthwestCsvSafely(
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
    } else {
      await _showOptionsDialog(context, type, file.name);
      if (!context.mounted) return;
      await _showInfoDialog(context, 'Unsupported CSV format.');
    }
  }

  Future<void> _importDatabaseFile(
    BuildContext context,
    WidgetRef ref,
    PlatformFile file,
  ) async {
    final bytes =
        (file.path == null ? null : await File(file.path!).readAsBytes()) ??
        file.bytes;
    if (bytes == null || bytes.isEmpty || !context.mounted) return;

    final confirmed = await _showDestructiveReplaceConfirmation(
      context: context,
      title: 'Import database file?',
      confirmLabel: 'Import',
    );
    if (confirmed != true || !context.mounted) return;

    final db = ref.read(databaseProvider);
    final importer = LegacySimpleLogDbImporter(db);
    final result = await importer.importFromBytes(bytes);
    if (!context.mounted) return;
    await _showLegacyImportSummary(context, result);
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

  Future<void> _restoreDatabase(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['sqlite', 'db', 'backup'],
    );
    if (picked == null || picked.files.isEmpty || !context.mounted) return;
    final file = picked.files.single;
    final bytes =
        (file.path == null ? null : await File(file.path!).readAsBytes()) ??
        file.bytes;
    if (bytes == null || bytes.isEmpty || !context.mounted) return;

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

  String _decodeCsvBytes(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      return utf8.decode(bytes.sublist(3));
    }

    try {
      return utf8.decode(bytes);
    } on FormatException {
      // Keep UTF-8 as the default even when a few malformed bytes exist.
      // Falling back to latin1 for the whole file corrupts valid UTF-8 text
      // into mojibake (e.g. accented names).
      return utf8.decode(bytes, allowMalformed: true);
    }
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
          title: const Text('Importing'),
          content: ValueListenableBuilder<_ImportProgress>(
            valueListenable: progress,
            builder: (context, value, _) {
              final total = value.total;
              final processed = value.processed;
              final percent = total > 0 ? processed / total : null;
              final label = total > 0
                  ? 'Processed $processed of $total'
                  : 'Preparing...';
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
    await showAppMessageDialog(
      context,
      title: 'Import Summary',
      message:
          'Rows: ${stats.totalRows}\n'
          'Flights: ${stats.flights}\n'
          'Positionings: ${stats.positionings}\n'
          'Simulators: ${stats.simulators}\n'
          'Airports: ${stats.airports}\n'
          'Aircraft Types: ${stats.aircraftTypes}\n'
          'Aircraft: ${stats.aircrafts}\n'
          'Crew: ${stats.crew}\n'
          'Skipped: ${stats.skipped}\n'
          'Errors: ${stats.errors}',
    );
  }

  Future<void> _showLogTenImportSummary(
    BuildContext context,
    LogTenImportResult result,
  ) async {
    final stats = result.summary;
    final issues = result.issues;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Summary'),
        content: SizedBox(
          width: 720,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rows: ${stats.totalRows}\n'
                'Flights: ${stats.flights}\n'
                'Positionings: ${stats.positionings}\n'
                'Simulators: ${stats.simulators}\n'
                'Airports: ${stats.airports}\n'
                'Aircraft Types: ${stats.aircraftTypes}\n'
                'Aircraft: ${stats.aircrafts}\n'
                'Crew: ${stats.crew}\n'
                'Skipped: ${stats.skipped}\n'
                'Errors: ${stats.errors}',
              ),
              if (issues.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Skipped lines',
                  style: TextStyle(fontWeight: FontWeight.w600),
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
                          'Line ${issue.lineNumber}: ${issue.reason}',
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
            child: const Text('OK'),
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

  Future<void> _clearDatabase(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmationDialog(
      context: context,
      title: l10n.clearDatabaseTitle,
      message: l10n.clearDatabaseMessage,
      confirmLabel: l10n.clearAction,
      cancelLabel: l10n.cancelAction,
    );
    if (confirmed != true || !context.mounted) return;
    final db = ref.read(databaseProvider);
    await db.clearAllData();
    await DashboardRulesSeedImporter.clearSeedFlag(db);
    if (!context.mounted) return;
    await _showInfoDialog(context, 'Database cleared.');
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

  Future<bool> _resolveMissingQatarAirports(
    BuildContext context, {
    required AppDatabase db,
    required QatarAirwaysWorkbookInspection inspection,
  }) async {
    while (true) {
      final missingCodes = await _findMissingQatarAirportCodes(db, inspection);
      if (missingCodes.isEmpty) {
        return true;
      }
      if (!context.mounted) return false;
      final shouldContinue = await QatarAirwaysMissingAirportsDialog.show(
        context,
        missingIataCodes: missingCodes,
        onCreateAirport: (iataCode) =>
            _createMissingAirport(context, db: db, iataCode: iataCode),
      );
      if (!shouldContinue) {
        return false;
      }
    }
  }

  Future<bool> _resolveMissingQatarSimulatorAircraft(
    BuildContext context, {
    required AppDatabase db,
    required QatarAirwaysWorkbookInspection inspection,
  }) async {
    while (true) {
      final missingAircraft = await _findMissingQatarSimulatorAircraft(
        db,
        inspection,
      );
      if (missingAircraft.isEmpty) {
        return true;
      }
      if (!context.mounted) return false;
      final shouldContinue = await QatarAirwaysMissingAircraftDialog.show(
        context,
        missingAircraft: missingAircraft,
        onCreateAircraft: (aircraft) => _createMissingSimulatorAircraft(
          context,
          db: db,
          missingAircraft: aircraft,
        ),
      );
      if (!shouldContinue) {
        return false;
      }
    }
  }

  Future<List<String>> _findMissingQatarAirportCodes(
    AppDatabase db,
    QatarAirwaysWorkbookInspection inspection,
  ) async {
    final airports = await db.select(db.airports).get();
    final existingIata = <String>{
      for (final airport in airports)
        if ((airport.iata ?? '').trim().isNotEmpty)
          airport.iata!.trim().toUpperCase(),
    };
    final missing = <String>{};
    for (final row in inspection.rows) {
      final flightDate = row.read('DATE (dd/mm/yy)').trim();
      if (flightDate.isEmpty) continue;
      final departure = row.read('DEPARTURE PLACE').trim().toUpperCase();
      final arrival = row.read('ARRIVAL PLACE').trim().toUpperCase();
      if (departure.length == 3 && !existingIata.contains(departure)) {
        missing.add(departure);
      }
      if (arrival.length == 3 && !existingIata.contains(arrival)) {
        missing.add(arrival);
      }
    }
    final ordered = missing.toList()..sort();
    return ordered;
  }

  Future<List<QatarAirwaysMissingAircraft>> _findMissingQatarSimulatorAircraft(
    AppDatabase db,
    QatarAirwaysWorkbookInspection inspection,
  ) async {
    final aircraftRows = await db.select(db.aircrafts).get();
    final existingRegistrations = <String>{
      for (final aircraft in aircraftRows)
        aircraft.registration.trim().toUpperCase(),
    };
    final missing = <String, QatarAirwaysMissingAircraft>{};
    for (final row in inspection.rows) {
      final simulatorRegistration = row
          .read('FSTD SESSION TYPE')
          .trim()
          .toUpperCase();
      if (simulatorRegistration.isEmpty ||
          existingRegistrations.contains(simulatorRegistration)) {
        continue;
      }
      missing[simulatorRegistration] = QatarAirwaysMissingAircraft(
        registration: simulatorRegistration,
        aircraftTypeCode: row.read('AIRCRAFT TYPE').trim().toUpperCase(),
      );
    }
    final ordered = missing.values.toList()
      ..sort((left, right) => left.registration.compareTo(right.registration));
    return ordered;
  }

  Future<bool> _createMissingAirport(
    BuildContext context, {
    required AppDatabase db,
    required String iataCode,
  }) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const placeholder = Airport(
      id: kPlaceholderId,
      icao: '',
      latitude: 0,
      longitude: 0,
      isFavorite: false,
      isLocked: false,
    );
    if (isCompact) {
      await AppNavigator.pushMaterial<void>(
        context,
        (_) => AirportEditScreen(
          item: placeholder,
          isCreate: true,
          initialIata: iataCode,
        ),
      );
    } else {
      await showDialog<Object?>(
        context: context,
        builder: (context) {
          final size = MediaQuery.sizeOf(context);
          return Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                maxHeight: size.height * 0.9,
              ),
              child: AirportEditScreen(
                item: placeholder,
                isCreate: true,
                initialIata: iataCode,
              ),
            ),
          );
        },
      );
    }
    final airports = await db.select(db.airports).get();
    return airports.any(
      (airport) => airport.iata?.trim().toUpperCase() == iataCode,
    );
  }

  Future<bool> _createMissingSimulatorAircraft(
    BuildContext context, {
    required AppDatabase db,
    required QatarAirwaysMissingAircraft missingAircraft,
  }) async {
    final aircraftTypeId = await _findExistingQatarAircraftTypeId(
      db,
      typeCode: missingAircraft.aircraftTypeCode,
    );
    if (!context.mounted) return false;
    final isCompact = MediaQuery.of(context).size.width < 600;
    const placeholder = Aircraft(
      id: kPlaceholderId,
      aircraftTypeId: 0,
      registration: '',
      isSimulator: true,
      isFavorite: false,
      isLocked: false,
    );
    if (isCompact) {
      await AppNavigator.pushMaterial<void>(
        context,
        (_) => AircraftEditScreen(
          item: placeholder,
          isCreate: true,
          initialIsSimulator: true,
          initialRegistration: missingAircraft.registration,
          initialAircraftTypeId: aircraftTypeId,
        ),
      );
    } else {
      if (!context.mounted) return false;
      await showDialog<Object?>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SizedBox(
              width: 520,
              child: AircraftEditScreen(
                item: placeholder,
                isCreate: true,
                initialIsSimulator: true,
                initialRegistration: missingAircraft.registration,
                initialAircraftTypeId: aircraftTypeId,
              ),
            ),
          ),
        ),
      );
    }
    final aircraftRows = await db.select(db.aircrafts).get();
    return aircraftRows.any(
      (aircraft) =>
          aircraft.registration.trim().toUpperCase() ==
          missingAircraft.registration,
    );
  }

  Future<int?> _findExistingQatarAircraftTypeId(
    AppDatabase db, {
    required String typeCode,
  }) async {
    final normalizedCode = typeCode.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      return null;
    }
    final existing = await (db.select(
      db.aircraftTypes,
    )..where((tbl) => tbl.code.equals(normalizedCode))).getSingleOrNull();
    return existing?.id;
  }

  Future<Uint8List> _readDatabaseBytes(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final path = await _databasePath();
    return File(path).readAsBytes();
  }

  Future<void> _replaceDatabaseBytes(WidgetRef ref, Uint8List bytes) async {
    final db = ref.read(databaseProvider);
    await db.close();
    final path = await _databasePath();
    await File(path).writeAsBytes(bytes, flush: true);
    ref
      ..invalidate(databaseProvider)
      ..invalidate(flightFactoringSettingsProvider)
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

class _DatabaseSectionCard extends StatelessWidget {
  const _DatabaseSectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
    this.accentColor,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleColor = accentColor ?? colorScheme.onSurface;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
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
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = danger ? colorScheme.error : null;
    final textColor = danger ? colorScheme.error : null;

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
        icon: Icon(icon, color: iconColor),
        label: Text(
          label,
          style: textColor == null ? null : TextStyle(color: textColor),
        ),
      ),
    );
  }
}

class _ImportProgress {
  const _ImportProgress({required this.processed, required this.total});

  final int processed;
  final int total;
}
