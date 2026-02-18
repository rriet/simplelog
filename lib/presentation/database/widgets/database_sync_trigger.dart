import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/import/import_operation_result.dart';
import 'package:simplelog/data/import/simplelog_csv_importer.dart';
import 'package:simplelog/presentation/database/widgets/import_options_preferences.dart';
import 'package:simplelog/presentation/database/widgets/southwest_import_options_dialog.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/simulator_default_crew_position_provider.dart';

import 'local_sync_dialog.dart';
import 'simplelog_import_options_dialog.dart';

class DatabaseSyncTrigger extends ConsumerWidget {
  const DatabaseSyncTrigger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.sync),
            label: Text(l10n.databaseSyncStartLocal),
            onPressed: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const LocalSyncDialog(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Import CSV'),
            onPressed: () => _importCsv(context, ref),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Database Dump (Temporary)'),
            onPressed: () => _clearDatabase(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _importCsv(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (bytes == null) return;
    final content = String.fromCharCodes(bytes);
    final type = _detectCsvType(content);
    if (!context.mounted) return;

    if (type == _CsvImportType.simpleLogOld) {
      final initialOptions = await ImportOptionsPreferences.loadSimpleLog();
      if (!context.mounted) return;
      final options = await SimpleLogImportOptionsDialog.show(
        context,
        fileName: file.name,
        initial: initialOptions,
      );
      if (options == null || !context.mounted) return;
      await ImportOptionsPreferences.saveSimpleLog(options);
      if (!context.mounted) return;
      final db = ref.read(databaseProvider);
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
          onProgress: (processed, total) =>
              progress.value = _ImportProgress(
                processed: processed,
                total: total,
              ),
        );
      } finally {
        progress.dispose();
      }
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (!context.mounted) return;
      if (!outcome.isSuccess) {
        final message = _buildImportErrorMessage(outcome.failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }
      await _showImportSummary(context, outcome.data!);
    } else if (type == _CsvImportType.swapa) {
      final defaultPosition = await ref.read(
        simulatorDefaultCrewPositionProvider.future,
      );
      final initialOptions = await ImportOptionsPreferences.loadSouthwest(
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
      await ImportOptionsPreferences.saveSouthwest(options);
      if (!context.mounted) return;
      final db = ref.read(databaseProvider);
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
      Navigator.of(context, rootNavigator: true).pop();
      if (!context.mounted) return;
      if (!outcome.isSuccess) {
        final message = _buildImportErrorMessage(outcome.failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }
      await _showImportSummary(context, outcome.data!);
    } else {
      await _showOptionsDialog(context, type, file.name);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unsupported CSV format.')),
      );
    }
  }

  void _showImportProgressDialog(
    BuildContext context,
    ValueNotifier<_ImportProgress> progress,
  ) {
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
            final percent =
                total > 0 ? processed / total : null;
            final label = total > 0
                ? 'Processed $processed of $total'
                : 'Preparing...';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: percent),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(label),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showImportSummary(
    BuildContext context,
    SimpleLogImportResult stats,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Summary'),
        content: Text(
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
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearDatabase(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Database'),
        content: const Text(
          'This will delete all data and recreate empty tables.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final db = ref.read(databaseProvider);
    await db.clearAllData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database cleared.')),
    );
  }

  Future<bool> _showOptionsDialog(
    BuildContext context,
    _CsvImportType type,
    String fileName,
  ) async {
    final label = switch (type) {
      _CsvImportType.simpleLogOld => 'SimpleLog (old version)',
      _CsvImportType.swapa => 'SWAPA',
      _CsvImportType.unknown => 'Unknown file',
    };
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Options'),
        content: Text('File: $fileName\nDetected: $label'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  _CsvImportType _detectCsvType(String content) {
    final lines = content
        .split(RegExp(r'\r\n|\n|\r'))
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) return _CsvImportType.unknown;

    final first = lines.first.trim();
    final normalized = _normalizeHeader(first);
    if (normalized == _normalizeHeader(_simpleLogOldHeader)) {
      return _CsvImportType.simpleLogOld;
    }

    if (first.contains('TotalBlockhrsmins')) {
      final headerIndex = lines.indexWhere(
        (line) => line.startsWith('TAFB_RadialScale1_MinimumValue'),
      );
      if (headerIndex != -1) {
        return _CsvImportType.swapa;
      }
    }

    return _CsvImportType.unknown;
  }

  String _normalizeHeader(String header) {
    return header.replaceAll('"', '').replaceAll(' ', '');
  }

  String _buildImportErrorMessage(ImportFailure? failure) {
    if (failure == null) return 'Import failed.';
    final prefix = switch (failure.type) {
      ImportFailureType.invalidFormat => 'Import failed: invalid CSV format.',
      ImportFailureType.parseError => 'Import failed while parsing data.',
      ImportFailureType.databaseError => 'Import failed while saving to database.',
      ImportFailureType.unexpected => 'Import failed due to an unexpected error.',
    };
    if (failure.message.isEmpty) return prefix;
    return '$prefix ${failure.message}';
  }
}

enum _CsvImportType { simpleLogOld, swapa, unknown }

class _ImportProgress {
  const _ImportProgress({required this.processed, required this.total});

  final int processed;
  final int total;
}

const _simpleLogOldHeader =
    '"Date (DD/MM/YYYY)","Departure Time (HH:MM)","Arrival Time (HH:MM)","Departure Epoch","Arrival Epoch","Departure Icao","Departure Iata","Departure Airport Name","Departure City","Departure Country","Departure Latitude","Departure Longitude","Arrival Icao","Arrival Iata","Arrival Airport Name","Arrival City","Arrival Country","Arrival Latitude","Arrival Longitude","Aircraft Registration","Aircraft MTOW","Aircraft Simulator","Model Make & Model","Model Group","Model Engine Type","Model MTOW","Model Multi Engine","Model Multi Pilot","Model EFIS","Model Seaplane","PIC Name","PIC Email","PIC Phone","PIC Comments","SIC Name","SIC Email","SIC Phone","SIC Comments","Pilot Function","Remarks","Private notes","Takeoff day","Takeoff night","Landing day","Landing night","IFR Approaches","Approach Type","IFR Minutes","Simulated Instrument Minutes","Night Minutes","Corss country Minutes","PIC Minutes","PICUS Minutes","SIC Minutes","Dual Minutes","Instructor Minutes","Simulator Minutes","Custom Time 1 Minutes","Custom Time 2 Minutes","Custom Time 3 Minutes","Custom Time 4 Minutes","Total Minutes"';
