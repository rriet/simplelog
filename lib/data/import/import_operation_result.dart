/// Public API documentation.
class ImportOperationResult<T> {
  /// Public API documentation.
  const ImportOperationResult.success(this.data)
    : failure = null,
      /// Public API documentation.
      isSuccess = true;

  /// Public API documentation.
  const ImportOperationResult.failure(this.failure)
    /// Public API documentation.
    : data = null,
      /// Public API documentation.
      isSuccess = false;
/// Public API documentation.

  /// Public API documentation.
  final T? data;
  /// Public API documentation.
  final ImportFailure? failure;
  /// Public API documentation.
  final bool isSuccess;
}

/// Public API documentation.
class ImportFailure {
  /// Public API documentation.
  const ImportFailure({
    required this.type,
    required this.message,
    /// Public API documentation.
    this.exception,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final ImportFailureType type;
  /// Public API documentation.
  final String message;
  /// Public API documentation.
  final Object? exception;
}

/// Public API documentation.
enum ImportFailureType {
  /// Public API documentation.
  invalidFormat,
  /// Public API documentation.
  parseError,
  /// Public API documentation.
  databaseError,
  /// Public API documentation.
  unexpected,
}
