/// Generic kind of critical import issue.
enum ImportCriticalIssueKind {
  /// One or more required fields are missing.
  missingRequiredField,

  /// Aircraft tail/registration is missing.
  missingAircraftTail,

  /// Airport reference is missing.
  missingAirport,

  /// Aircraft reference is missing.
  missingAircraft,
}

/// Normalized critical issue item used by shared preflight flows.
class ImportCriticalIssue {
  /// Creates an issue.
  const ImportCriticalIssue({
    required this.kind,
    required this.message,
    this.sourceLineNumber,
  });

  /// Issue category.
  final ImportCriticalIssueKind kind;

  /// User-facing summary message.
  final String message;

  /// Optional source line number.
  final int? sourceLineNumber;
}

/// User decision selected in a critical-issues decision dialog.
enum ImportCriticalIssueDecision {
  /// Continue with primary action.
  primary,

  /// Continue with secondary action.
  secondary,

  /// Cancel import.
  cancel,
}
