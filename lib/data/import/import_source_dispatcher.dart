// Import source enum cases are intentionally self-explanatory in UI code.
// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:simplelog/data/import/logten_pro_tsv_inspector.dart';
import 'package:simplelog/data/import/qatar_airways_workbook_inspector.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';
import 'package:simplelog/data/import/source_parsers/foreflight_csv_source_parser.dart';

/// Supported import source kinds.
enum ImportSourceKind {
  legacySimpleLogCsv,
  southwestCsv,
  qatarAirwaysXlsx,
  logTenProTsv,
  waderLogbookCsv,
  foreFlightCsv,
  unknown,
}

/// Detects import source types before handing off to a parser/importer.
class ImportSourceDispatcher {
  /// Creates a dispatcher.
  const ImportSourceDispatcher();

  static const _logTenProInspector = LogTenProTsvInspector();
  static const _qatarAirwaysInspector = QatarAirwaysWorkbookInspector();
  static const _foreFlightParser = ForeFlightCsvSourceParser();
  static const Set<String> _waderRequiredHeaders = <String>{
    'ispreviousexperience',
    'issimulator',
    'flightdate',
    'starttime',
    'depairport',
    'arrairport',
    'aircrafttailnumber',
    'aircrafttype',
    'totaltime',
  };
  static final Set<String> _legacySimpleLogRequiredHeaders = () {
    final parsed = SimpleLogCsvSupport.parseCsv(
      SimpleLogCsvSupport.simpleLogOldHeader,
    );
    if (parsed.isEmpty) {
      return const <String>{};
    }
    return parsed.first
        .map(SimpleLogCsvSupport.clean)
        .map((value) => value.toLowerCase())
        .toSet();
  }();

  /// Detects a source kind from file metadata and optional file contents.
  ImportSourceKind detect({
    required String fileName,
    String? content,
    Uint8List? bytes,
  }) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.xlsx') &&
        bytes != null &&
        _qatarAirwaysInspector.inspect(bytes) != null) {
      return ImportSourceKind.qatarAirwaysXlsx;
    }
    if ((lowerName.endsWith('.txt') || lowerName.endsWith('.tsv')) &&
        content != null &&
        _logTenProInspector.inspect(content) != null) {
      return ImportSourceKind.logTenProTsv;
    }
    if (content == null) return ImportSourceKind.unknown;
    return detectCsv(content);
  }

  /// Detects the CSV source format from its contents.
  ImportSourceKind detectCsv(String content) {
    final lines = content
        .split(RegExp(r'\r\n|\n|\r'))
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) return ImportSourceKind.unknown;

    final first = lines.first.trim();
    if (_foreFlightParser.recognizes(content)) {
      return ImportSourceKind.foreFlightCsv;
    }
    if (_isWaderCsvHeader(first)) {
      return ImportSourceKind.waderLogbookCsv;
    }
    if (_isLegacySimpleLogHeader(first)) {
      return ImportSourceKind.legacySimpleLogCsv;
    }

    if (first.contains('TotalBlockhrsmins')) {
      final headerIndex = lines.indexWhere(
        (line) => line.startsWith('TAFB_RadialScale1_MinimumValue'),
      );
      if (headerIndex != -1) {
        return ImportSourceKind.southwestCsv;
      }
    }

    return ImportSourceKind.unknown;
  }

  bool _isLegacySimpleLogHeader(String headerLine) {
    final parsed = SimpleLogCsvSupport.parseCsv(headerLine);
    if (parsed.isEmpty || _legacySimpleLogRequiredHeaders.isEmpty) {
      return false;
    }
    final normalized = parsed.first
        .map(SimpleLogCsvSupport.clean)
        .map((value) => value.toLowerCase())
        .toSet();
    return _legacySimpleLogRequiredHeaders.every(normalized.contains);
  }

  bool _isWaderCsvHeader(String headerLine) {
    final parsed = SimpleLogCsvSupport.parseCsv(headerLine);
    if (parsed.isEmpty) {
      return false;
    }
    final normalized = parsed.first
        .map((value) => value.trim().toLowerCase())
        .toSet();
    return _waderRequiredHeaders.every(normalized.contains);
  }

  /// Human-readable label used by the UI.
  String labelFor(ImportSourceKind kind) {
    return switch (kind) {
      ImportSourceKind.legacySimpleLogCsv => 'SimpleLog (old version)',
      ImportSourceKind.southwestCsv => 'SWAPA',
      ImportSourceKind.qatarAirwaysXlsx => 'Qatar Airways',
      ImportSourceKind.logTenProTsv => 'LogTen Pro',
      ImportSourceKind.waderLogbookCsv => 'Wader Logbook CSV',
      ImportSourceKind.foreFlightCsv => 'ForeFlight',
      ImportSourceKind.unknown => 'Unknown file',
    };
  }
}
