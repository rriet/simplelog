/// Aircraft kind expected for a source row.
enum RowImportAircraftKind {
  /// Regular aircraft row.
  aircraft,

  /// Simulator row.
  simulator,
}

/// One missing-aircraft issue detected in a source row.
class RowImportAircraftIssue {
  /// Creates a missing-aircraft issue.
  const RowImportAircraftIssue({
    required this.lineNumber,
    required this.registration,
    required this.kind,
    required this.reason,
  });

  /// 1-based source line number.
  final int lineNumber;

  /// Missing registration found in source.
  final String registration;

  /// Aircraft kind for this row.
  final RowImportAircraftKind kind;

  /// User-facing reason text.
  final String reason;
}

/// Resolution values selected for missing-aircraft issues.
class RowImportAircraftResolution {
  /// Creates a resolution set.
  const RowImportAircraftResolution({
    this.replacements = const <int, String>{},
    this.skippedLines = const <int>{},
    this.stopImport = false,
  });

  /// Replacement registration by source line.
  final Map<int, String> replacements;

  /// Lines user asked to skip.
  final Set<int> skippedLines;

  /// Whether user stopped the import flow.
  final bool stopImport;
}
