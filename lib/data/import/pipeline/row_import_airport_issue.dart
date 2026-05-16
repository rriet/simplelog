/// Airport field side within a source row.
enum RowImportAirportField {
  /// Departure airport field.
  departure,

  /// Arrival airport field.
  arrival,
}

/// Airport code kind expected for this issue.
enum RowImportAirportCodeKind {
  /// ICAO (typically 4-char) code.
  icao,

  /// IATA (typically 3-char) code.
  iata,
}

/// One airport issue detected in an import source row.
class RowImportAirportIssue {
  /// Creates an airport issue.
  const RowImportAirportIssue({
    required this.lineNumber,
    required this.field,
    required this.code,
    required this.reason,
    this.codeKind = RowImportAirportCodeKind.icao,
  });

  /// 1-based source line number.
  final int lineNumber;

  /// Field with issue.
  final RowImportAirportField field;

  /// Raw airport code from source row.
  final String code;

  /// User-facing reason text.
  final String reason;

  /// Expected code kind for replacement.
  final RowImportAirportCodeKind codeKind;
}

/// Per-line/field airport correction selected by user.
class RowImportAirportResolution {
  /// Creates a resolution set.
  const RowImportAirportResolution({
    this.replacements = const <int, Map<RowImportAirportField, String>>{},
    this.skippedLines = const <int>{},
    this.stopImport = false,
  });

  /// Replacement airport code values by source line and field.
  final Map<int, Map<RowImportAirportField, String>> replacements;

  /// Lines user asked to skip.
  final Set<int> skippedLines;

  /// Whether user stopped import.
  final bool stopImport;
}
