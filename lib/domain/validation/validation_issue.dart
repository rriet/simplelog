/// Public API documentation.
enum ValidationSeverity {
  /// Public API documentation.
  error,

  /// Public API documentation.
  warning,
}
/// Public API documentation.

/// Public API documentation.
class ValidationIssue {
  /// Public API documentation.
  const ValidationIssue({
    required this.code,
    required this.message,
    required this.severity,
    /// Public API documentation.
    this.field,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final String code;
  /// Public API documentation.
  final String message;
  /// Public API documentation.
  final ValidationSeverity severity;
  /// Public API documentation.
  final String? field;
}
/// Public API documentation.

/// Public API documentation.
class ValidationReport {
  /// Public API documentation.
  const ValidationReport({
    this.errors = const <ValidationIssue>[],
    this.warnings = const <ValidationIssue>[],
  /// Public API documentation.
  });

  /// Public API documentation.
  final List<ValidationIssue> errors;
  /// Public API documentation.
  final List<ValidationIssue> warnings;

  /// Public API documentation.
  bool get hasErrors => errors.isNotEmpty;
  /// Public API documentation.
  bool get hasWarnings => warnings.isNotEmpty;
}

/// Public API documentation.
class WriteResult<T> {
  const WriteResult._({
    required this.isSuccess,
    this.data,
    /// Public API documentation.
    this.errors = const <ValidationIssue>[],
    /// Public API documentation.
    this.warnings = const <ValidationIssue>[],
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  const WriteResult.success({
    T? data,
    List<ValidationIssue> warnings = const [],
  }) : this._(isSuccess: true, data: data, warnings: warnings);

  /// Public API documentation.
  const WriteResult.failure({
    List<ValidationIssue> errors = const [],
    List<ValidationIssue> warnings = const [],
  }) : this._(isSuccess: false, errors: errors, warnings: warnings);

  /// Public API documentation.
  final bool isSuccess;
  /// Public API documentation.
  final T? data;
  /// Public API documentation.
  final List<ValidationIssue> errors;
  /// Public API documentation.
  final List<ValidationIssue> warnings;
}
