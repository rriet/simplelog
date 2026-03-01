import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/import_operation_result.dart';
import 'package:simplelog/data/import/normalized_import_persistence_service.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/simplelog_import_result.dart';
import 'package:simplelog/data/import/source_parsers/legacy_simplelog_csv_source_parser.dart';
import 'package:simplelog/data/import/source_parsers/southwest_csv_source_parser.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';

export 'package:simplelog/data/import/simplelog_import_result.dart';

/// Facade that imports supported CSV sources into the local database.
class SimpleLogCsvImporter {
  /// Creates an importer bound to the given [db] instance.
  SimpleLogCsvImporter(this.db)
    : _legacyParser = const LegacySimpleLogCsvSourceParser(),
      _southwestParser = const SouthwestCsvSourceParser(),
      _persistence = NormalizedImportPersistenceService(db);

  /// Database used as the target for the import.
  final AppDatabase db;

  final LegacySimpleLogCsvSourceParser _legacyParser;
  final SouthwestCsvSourceParser _southwestParser;
  final NormalizedImportPersistenceService _persistence;

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
}
