// Import source enum cases are intentionally self-explanatory in UI code.
// ignore_for_file: public_member_api_docs

import 'package:simplelog/data/import/simplelog_csv_support.dart';

/// Supported import source kinds.
enum ImportSourceKind {
  legacySimpleLogCsv,
  southwestCsv,
  legacySimpleLogDb,
  unknown,
}

/// Detects import source types before handing off to a parser/importer.
class ImportSourceDispatcher {
  /// Creates a dispatcher.
  const ImportSourceDispatcher();

  /// Detects a source kind from file metadata and optional file contents.
  ImportSourceKind detect({
    required String fileName,
    String? content,
  }) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.sqlite') || lowerName.endsWith('.db')) {
      return ImportSourceKind.legacySimpleLogDb;
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
    final normalized = SimpleLogCsvSupport.normalizeHeader(first);
    if (normalized ==
        SimpleLogCsvSupport.normalizeHeader(
          SimpleLogCsvSupport.simpleLogOldHeader,
        )) {
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

  /// Human-readable label used by the UI.
  String labelFor(ImportSourceKind kind) {
    return switch (kind) {
      ImportSourceKind.legacySimpleLogCsv => 'SimpleLog (old version)',
      ImportSourceKind.southwestCsv => 'SWAPA',
      ImportSourceKind.legacySimpleLogDb => 'SimpleLog database',
      ImportSourceKind.unknown => 'Unknown file',
    };
  }
}
