/// Indicates how serious a validation issue is.
enum ValidationSeverity {
  /// Prevents the operation from completing.
  error,

  /// Non‑blocking advisory for the user.
  warning,
}

/// Single validation message with code, text and severity.
class ValidationIssue {
  /// Creates a validation issue.
  const ValidationIssue({
    required this.code,
    required this.message,
    required this.severity,
    this.field,
  });

  /// Machine‑readable code for the issue.
  final String code;

  /// Human‑readable description of the issue.
  final String message;

  /// Severity of this issue.
  final ValidationSeverity severity;

  /// Optional field name associated with the issue.
  final String? field;
}

/// Collection of errors and warnings returned from a validation step.
class ValidationReport {
  /// Creates a report from lists of [errors] and [warnings].
  const ValidationReport({
    this.errors = const <ValidationIssue>[],
    this.warnings = const <ValidationIssue>[],
  });

  /// Blocking issues.
  final List<ValidationIssue> errors;

  /// Non‑blocking advisory issues.
  final List<ValidationIssue> warnings;

  /// Whether the report contains any errors.
  bool get hasErrors => errors.isNotEmpty;

  /// Whether the report contains any warnings.
  bool get hasWarnings => warnings.isNotEmpty;
}

/// Result of a write operation that may have validation side‑effects.
class WriteResult<T> {
  const WriteResult._({
    required this.isSuccess,
    this.data,
    this.errors = const <ValidationIssue>[],
    this.warnings = const <ValidationIssue>[],
  });

  /// Successful write with optional [data] and [warnings].
  const WriteResult.success({
    T? data,
    List<ValidationIssue> warnings = const [],
  }) : this._(isSuccess: true, data: data, warnings: warnings);

  /// Failed write with one or more [errors] (and optional [warnings]).
  const WriteResult.failure({
    List<ValidationIssue> errors = const [],
    List<ValidationIssue> warnings = const [],
  }) : this._(isSuccess: false, errors: errors, warnings: warnings);

  /// Indicates whether the operation completed successfully.
  final bool isSuccess;

  /// Optional payload returned from the operation.
  final T? data;

  /// Errors that caused the operation to fail.
  final List<ValidationIssue> errors;

  /// Non‑blocking warnings encountered during the operation.
  final List<ValidationIssue> warnings;
}
