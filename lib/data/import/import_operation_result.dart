/// Result of an import operation with either data or a failure.
class ImportOperationResult<T> {
  /// Creates a successful result containing imported [data].
  const ImportOperationResult.success(this.data)
    : failure = null,
      /// Indicates that the import completed successfully.
      isSuccess = true;

  /// Creates a failed result describing why the import did not succeed.
  const ImportOperationResult.failure(this.failure)
    /// No data is available when the import fails.
    : data = null,
      /// Indicates that the import failed.
      isSuccess = false;

  /// Imported data when the operation was successful, otherwise `null`.
  final T? data;

  /// Details about the failure when the operation did not succeed.
  final ImportFailure? failure;

  /// Whether the operation completed successfully.
  final bool isSuccess;
}

/// Describes why an import operation failed.
class ImportFailure {
  /// Creates a new failure description.
  const ImportFailure({
    required this.type,
    required this.message,
    /// Optional exception that triggered the failure.
    this.exception,
  });

  /// High‑level type of failure.
  final ImportFailureType type;

  /// Human‑readable description of what went wrong.
  final String message;

  /// Underlying exception, if one was thrown.
  final Object? exception;
}

/// Categories of failures that can occur during import.
enum ImportFailureType {
  /// The input file or payload could not be interpreted.
  invalidFormat,

  /// Parsing of individual rows or fields failed.
  parseError,

  /// Persisting data to the database failed.
  databaseError,

  /// Any other unexpected error.
  unexpected,
}
