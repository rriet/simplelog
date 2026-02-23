/// Result object returned by validation routines.
class ValidationResult {
  /// Creates a validation result.
  const ValidationResult({
    required this.isValid,
    this.message,
  });

  /// Successful validation result.
  factory ValidationResult.ok() => const ValidationResult(isValid: true);

  /// Failed validation result with a user-facing message.
  factory ValidationResult.error(String message) =>
      ValidationResult(isValid: false, message: message);

  /// Whether validation passed.
  final bool isValid;

  /// Optional validation message for failed cases.
  final String? message;
}
