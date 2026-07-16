import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/foreflight_import_options.dart';
import 'package:simplelog/data/import/import_operation_result.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/normalized_import_persistence_service.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/qatar_airways_workbook_inspector.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/simplelog_import_result.dart';
import 'package:simplelog/data/import/source_parsers/foreflight_csv_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/legacy_simplelog_csv_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/logten_pro_tsv_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/qatar_airways_xlsx_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/southwest_csv_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/wader_logbook_csv_source_parser.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';
import 'package:simplelog/data/import/wader_import_models.dart';
import 'package:simplelog/data/import/wader_import_options.dart';

export 'package:simplelog/data/import/simplelog_import_result.dart';

/// Facade that imports supported CSV sources into the local database.
class SimpleLogCsvImporter {
  /// Creates an importer bound to the given [db] instance.
  SimpleLogCsvImporter(this.db)
    : _legacyParser = const LegacySimpleLogCsvSourceParser(),
      _logTenProParser = const LogTenProTsvSourceParser(),
      _qatarParser = const QatarAirwaysXlsxSourceParser(),
      _southwestParser = const SouthwestCsvSourceParser(),
      _waderParser = const WaderLogbookCsvSourceParser(),
      _foreFlightParser = const ForeFlightCsvSourceParser(),
      _persistence = NormalizedImportPersistenceService(db);

  /// Database used as the target for the import.
  final AppDatabase db;

  final LegacySimpleLogCsvSourceParser _legacyParser;
  final LogTenProTsvSourceParser _logTenProParser;
  final QatarAirwaysXlsxSourceParser _qatarParser;
  final SouthwestCsvSourceParser _southwestParser;
  final WaderLogbookCsvSourceParser _waderParser;
  final ForeFlightCsvSourceParser _foreFlightParser;
  final NormalizedImportPersistenceService _persistence;

  /// Validates ForeFlight rows without persisting data.
  Future<List<WaderImportIssue>> validateForeFlightCsv(
    String content, {
    required ForeFlightImportOptions options,
  }) async {
    final existingAirports = await db.select(db.airports).get();
    final airportCodes = <String>{
      for (final airport in existingAirports) airport.icao.trim().toUpperCase(),
      for (final airport in existingAirports)
        if ((airport.iata ?? '').trim().isNotEmpty)
          airport.iata!.trim().toUpperCase(),
    };
    return _foreFlightParser.validate(
      content,
      options: options,
      existingAirportCodes: airportCodes,
    );
  }

  /// Imports a ForeFlight two-table CSV export.
  Future<SimpleLogImportResult> importForeFlightCsv(
    String content, {
    required ForeFlightImportOptions options,
    ImportProgressCallback? onProgress,
  }) async {
    final existingAirports = await db.select(db.airports).get();
    final airportsByCode = <String, Airport>{
      for (final airport in existingAirports)
        airport.icao.trim().toUpperCase(): airport,
      for (final airport in existingAirports)
        if ((airport.iata ?? '').trim().isNotEmpty)
          airport.iata!.trim().toUpperCase(): airport,
    };
    final batch = _foreFlightParser.parse(
      content,
      options: options,
      existingAirportsByCode: airportsByCode,
    );
    return _persistence.importBatch(batch, onProgress: onProgress);
  }

  /// Safe variant of [importForeFlightCsv].
  Future<ImportOperationResult<SimpleLogImportResult>>
  importForeFlightCsvSafely(
    String content, {
    required ForeFlightImportOptions options,
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final result = await importForeFlightCsv(
        content,
        options: options,
        onProgress: onProgress,
      );
      return ImportOperationResult.success(result);
    } on FormatException catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.invalidFormat,
          message: error.message,
          exception: error,
        ),
      );
    } on Object catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.unexpected,
          message: 'Unexpected ForeFlight import error.',
          exception: error,
        ),
      );
    }
  }

  /// Inspects Southwest CSV rows and reports preflight issues.
  SouthwestCsvPreflightReport inspectSouthwestCsv(String content) {
    return _southwestParser.inspect(content);
  }

  /// Returns unique raw Southwest aircraft type designators from source file.
  Set<String> extractSouthwestRawTypeCodes(String content) {
    return _southwestParser.extractUniqueRawTypeCodes(content);
  }

  /// Returns raw type designators only for rows that would create aircraft.
  Future<Set<String>> extractSouthwestRawTypeCodesForAircraftCreation(
    String content,
  ) async {
    final existingAircraft = await db.select(db.aircrafts).get();
    final existingRegistrations = <String>{
      for (final aircraft in existingAircraft)
        aircraft.registration.trim().toUpperCase(),
    };
    return _southwestParser.extractUniqueRawTypeCodes(
      content,
      existingAircraftRegistrations: existingRegistrations,
    );
  }

  /// Returns aircraft registrations grouped by raw type for creation rows only.
  Future<Map<String, List<String>>>
  extractSouthwestAircraftRegistrationsByRawTypeForAircraftCreation(
    String content,
  ) async {
    final existingAircraft = await db.select(db.aircrafts).get();
    final existingRegistrations = <String>{
      for (final aircraft in existingAircraft)
        aircraft.registration.trim().toUpperCase(),
    };
    return _southwestParser.collectAircraftRegistrationsByRawType(
      content,
      existingAircraftRegistrations: existingRegistrations,
    );
  }

  /// Infers Southwest raw type mappings from existing aircraft registrations.
  Future<Map<String, String>> inferSouthwestTypeMappingsFromExistingAircraft(
    String content,
  ) async {
    final existingAircraft = await db.select(db.aircrafts).get();
    final existingTypes = await db.select(db.aircraftTypes).get();
    final typeCodeById = <int, String>{
      for (final type in existingTypes) type.id: type.code.trim().toUpperCase(),
    };
    final typeCodeByRegistration = <String, String>{
      for (final aircraft in existingAircraft)
        aircraft.registration.trim().toUpperCase():
            typeCodeById[aircraft.aircraftTypeId] ?? '',
    };
    return _southwestParser.inferTypeMappingsFromExistingAircraft(
      content,
      existingAircraftTypeCodesByRegistration: typeCodeByRegistration,
    );
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
    final existingTypes = await db.select(db.aircraftTypes).get();
    final typeCodeById = <int, String>{
      for (final type in existingTypes) type.id: type.code.trim().toUpperCase(),
    };
    final existingAircraft = await db.select(db.aircrafts).get();
    final simulatorTypeCodesByRegistration = <String, String>{
      for (final aircraft in existingAircraft)
        if (aircraft.isSimulator)
          aircraft.registration.trim().toLowerCase():
              typeCodeById[aircraft.aircraftTypeId] ?? '',
    };
    final batch = _qatarParser.parse(
      workbook,
      options: options,
      existingAirportsByIata: airportsByIata,
      existingSimulatorTypeCodesByRegistration:
          simulatorTypeCodesByRegistration,
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

  /// Imports a Wader Logbook CSV export.
  Future<SimpleLogImportResult> importWaderLogbookCsv(
    String content, {
    WaderImportOptions options = const WaderImportOptions(),
    WaderImportReviewOptions reviewOptions = const WaderImportReviewOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    final batch = _waderParser.parse(
      content,
      options: options,
      reviewOptions: reviewOptions,
    );
    return _persistence.importBatch(batch, onProgress: onProgress);
  }

  /// Validates Wader CSV rows without persisting data.
  Future<List<WaderImportIssue>> validateWaderLogbookCsv(
    String content, {
    WaderImportOptions options = const WaderImportOptions(),
    WaderImportReviewOptions reviewOptions = const WaderImportReviewOptions(),
  }) async {
    final existingAirports = await db.select(db.airports).get();
    final airportCodes = <String>{
      for (final airport in existingAirports) airport.icao.trim().toUpperCase(),
    };
    return _waderParser.validate(
      content,
      options: options,
      reviewOptions: reviewOptions,
      existingAirportIcaoCodes: airportCodes,
    );
  }

  /// Safe variant of [importWaderLogbookCsv].
  Future<ImportOperationResult<SimpleLogImportResult>>
  importWaderLogbookCsvSafely(
    String content, {
    WaderImportOptions options = const WaderImportOptions(),
    WaderImportReviewOptions reviewOptions = const WaderImportReviewOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final result = await importWaderLogbookCsv(
        content,
        options: options,
        reviewOptions: reviewOptions,
        onProgress: onProgress,
      );
      return ImportOperationResult.success(result);
    } on FormatException catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.invalidFormat,
          message: error.message,
          exception: error,
        ),
      );
    } on Object catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.unexpected,
          message: 'Unexpected Wader CSV import error.',
          exception: error,
        ),
      );
    }
  }
}
