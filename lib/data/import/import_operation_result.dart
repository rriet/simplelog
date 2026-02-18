class ImportOperationResult<T> {
  const ImportOperationResult.success(this.data)
      : failure = null,
        isSuccess = true;

  const ImportOperationResult.failure(this.failure)
      : data = null,
        isSuccess = false;

  final T? data;
  final ImportFailure? failure;
  final bool isSuccess;
}

class ImportFailure {
  const ImportFailure({
    required this.type,
    required this.message,
    this.exception,
  });

  final ImportFailureType type;
  final String message;
  final Object? exception;
}

enum ImportFailureType {
  invalidFormat,
  parseError,
  databaseError,
  unexpected,
}
