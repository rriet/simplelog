import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/import_operation_result.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/normalized_import_persistence_service.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/qatar_airways_workbook_inspector.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/simplelog_import_result.dart';
import 'package:simplelog/data/import/source_parsers/legacy_simplelog_csv_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/logten_pro_tsv_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/qatar_airways_xlsx_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/southwest_csv_source_parser.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';

export 'package:simplelog/data/import/simplelog_import_result.dart';

/// Facade that imports supported CSV sources into the local database.
class SimpleLogCsvImporter {
  /// Creates an importer bound to the given [db] instance.
  SimpleLogCsvImporter(this.db)
    : _legacyParser = const LegacySimpleLogCsvSourceParser(),
      _logTenProParser = const LogTenProTsvSourceParser(),
      _qatarParser = const QatarAirwaysXlsxSourceParser(),
      _southwestParser = const SouthwestCsvSourceParser(),
      _persistence = NormalizedImportPersistenceService(db);

  /// Database used as the target for the import.
  final AppDatabase db;

  final LegacySimpleLogCsvSourceParser _legacyParser;
  final LogTenProTsvSourceParser _logTenProParser;
  final QatarAirwaysXlsxSourceParser _qatarParser;
  final SouthwestCsvSourceParser _southwestParser;
  final NormalizedImportPersistenceService _persistence;

  /// Inspects Southwest CSV rows and reports preflight issues.
  SouthwestCsvPreflightReport inspectSouthwestCsv(String content) {
    return _southwestParser.inspect(content);
  }

  /// Imports a legacy SimpleLog CSV string into the database.
  Future<SimpleLogImportResult> importCsv(
    String content, {
    SimpleLogImportOptions options = const SimpleLogImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    final batch = _legacyParser.parse(content, options: options);
    return _persistence.importBatch(batch, onProgress: onProgress);
  }

  /// Wraps [importCsv] and converts failures into [ImportOperationResult].
  Future<ImportOperationResult<SimpleLogImportResult>> importCsvSafely(
    String content, {
    SimpleLogImportOptions options = const SimpleLogImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final result = await importCsv(
        content,
        options: options,
        onProgress: onProgress,
      );
      return ImportOperationResult.success(result);
    } on FormatException catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.invalidFormat,
          message: 'Invalid CSV format.',
          exception: error,
        ),
      );
    } on Object catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.unexpected,
          message: 'Unexpected import error.',
          exception: error,
        ),
      );
    }
  }

  /// Imports Southwest Airlines CSV exports using convenience defaults.
  Future<SimpleLogImportResult> importSouthwestCsv(
    String content, {
    SouthwestImportOptions options = const SouthwestImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    final existingAirports = await db.select(db.airports).get();
    final airportsByIcao = <String, Airport>{
      for (final airport in existingAirports)
        airport.icao.trim().toLowerCase(): airport,
    };
    final existingCrew = await db.select(db.crew).get();
    final hasSelfCrew = existingCrew.any((member) => member.isSelf);
    final batch = _southwestParser.parse(
      content,
      options: options,
      existingAirportsByIcao: airportsByIcao,
      hasSelfCrew: hasSelfCrew,
    );
    return _persistence.importBatch(batch, onProgress: onProgress);
  }

  /// Safe variant of [importSouthwestCsv] that wraps errors in a result type.
  Future<ImportOperationResult<SimpleLogImportResult>> importSouthwestCsvSafely(
    String content, {
    SouthwestImportOptions options = const SouthwestImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final result = await importSouthwestCsv(
        content,
        options: options,
        onProgress: onProgress,
      );
      return ImportOperationResult.success(result);
    } on FormatException catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.invalidFormat,
          message: 'Invalid Southwest CSV format.',
          exception: error,
        ),
      );
    } on Object catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.unexpected,
          message: 'Unexpected Southwest import error.',
          exception: error,
        ),
      );
    }
  }

  /// Imports Qatar Airways workbook rows using direct field mapping.
  Future<SimpleLogImportResult> importQatarAirwaysWorkbook(
    QatarAirwaysWorkbookInspection workbook, {
    required QatarAirwaysImportOptions options,
    ImportProgressCallback? onProgress,
  }) async {
    final existingAirports = await db.select(db.airports).get();
    final airportsByIata = <String, Airport>{
      for (final airport in existingAirports)
        if ((airport.iata ?? '').trim().isNotEmpty)
          airport.iata!.trim().toLowerCase(): airport,
    };
    final batch = _qatarParser.parse(
      workbook,
      options: options,
      existingAirportsByIata: airportsByIata,
    );
    return _persistence.importBatch(batch, onProgress: onProgress);
  }

  /// Safe variant of [importQatarAirwaysWorkbook].
  Future<ImportOperationResult<SimpleLogImportResult>>
  importQatarAirwaysWorkbookSafely(
    QatarAirwaysWorkbookInspection workbook, {
    required QatarAirwaysImportOptions options,
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final result = await importQatarAirwaysWorkbook(
        workbook,
        options: options,
        onProgress: onProgress,
      );
      return ImportOperationResult.success(result);
    } on FormatException catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.invalidFormat,
          message: 'Invalid Qatar Airways workbook format.',
          exception: error,
        ),
      );
    } on Object catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.unexpected,
          message: 'Unexpected Qatar Airways import error.',
          exception: error,
        ),
      );
    }
  }

  /// Imports a LogTen Pro tab-separated export.
  Future<LogTenImportResult> importLogTenProTsv(
    String content, {
    required LogTenImportOptions options,
    ImportProgressCallback? onProgress,
  }) async {
    final existingAirports = await db.select(db.airports).get();
    final airportsByIcao = <String, Airport>{
      for (final airport in existingAirports)
        airport.icao.trim().toLowerCase(): airport,
    };
    final airportsByIata = <String, Airport>{
      for (final airport in existingAirports)
        if ((airport.iata ?? '').trim().isNotEmpty)
          airport.iata!.trim().toLowerCase(): airport,
    };
    final parseResult = _logTenProParser.parse(
      content,
      options: options,
      existingAirportsByIcao: airportsByIcao,
      existingAirportsByIata: airportsByIata,
      includeIgnoredLineIssues: true,
    );
    if (parseResult.issues.any(
      (issue) => issue.reason.toLowerCase() != 'ignored by user.',
    )) {
      throw const FormatException(
        'LogTen Pro import has unresolved validation issues.',
      );
    }
    final summary = await _persistence.importBatch(
      parseResult.batch,
      onProgress: onProgress,
    );
    return LogTenImportResult(summary: summary, issues: parseResult.issues);
  }

  /// Validates a LogTen Pro tab-separated export without persisting rows.
  Future<List<LogTenImportIssue>> validateLogTenProTsv(
    String content, {
    required LogTenImportOptions options,
  }) async {
    final existingAirports = await db.select(db.airports).get();
    final airportsByIcao = <String, Airport>{
      for (final airport in existingAirports)
        airport.icao.trim().toLowerCase(): airport,
    };
    final airportsByIata = <String, Airport>{
      for (final airport in existingAirports)
        if ((airport.iata ?? '').trim().isNotEmpty)
          airport.iata!.trim().toLowerCase(): airport,
    };
    final parseResult = _logTenProParser.parse(
      content,
      options: options,
      existingAirportsByIcao: airportsByIcao,
      existingAirportsByIata: airportsByIata,
    );
    return parseResult.issues;
  }

  /// Safe variant of [importLogTenProTsv].
  Future<ImportOperationResult<LogTenImportResult>> importLogTenProTsvSafely(
    String content, {
    required LogTenImportOptions options,
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final result = await importLogTenProTsv(
        content,
        options: options,
        onProgress: onProgress,
      );
      return ImportOperationResult.success(result);
    } on FormatException catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.parseError,
          message: error.message,
          exception: error,
        ),
      );
    } on Object catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.unexpected,
          message: 'Unexpected LogTen Pro import error.',
          exception: error,
        ),
      );
    }
  }
}
