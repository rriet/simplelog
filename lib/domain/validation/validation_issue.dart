enum ValidationSeverity { error, warning }

class ValidationIssue {
  const ValidationIssue({
    required this.code,
    required this.message,
    required this.severity,
    this.field,
  });

  final String code;
  final String message;
  final ValidationSeverity severity;
  final String? field;
}

class ValidationReport {
  const ValidationReport({
    this.errors = const <ValidationIssue>[],
    this.warnings = const <ValidationIssue>[],
  });

  final List<ValidationIssue> errors;
  final List<ValidationIssue> warnings;

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}

class WriteResult<T> {
  const WriteResult._({
    required this.isSuccess,
    this.data,
    this.errors = const <ValidationIssue>[],
    this.warnings = const <ValidationIssue>[],
  });

  const WriteResult.success({T? data, List<ValidationIssue> warnings = const []})
    : this._(isSuccess: true, data: data, warnings: warnings);

  const WriteResult.failure({
    List<ValidationIssue> errors = const [],
    List<ValidationIssue> warnings = const [],
  }) : this._(isSuccess: false, errors: errors, warnings: warnings);

  final bool isSuccess;
  final T? data;
  final List<ValidationIssue> errors;
  final List<ValidationIssue> warnings;
}
