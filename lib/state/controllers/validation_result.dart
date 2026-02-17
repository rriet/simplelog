class ValidationResult {
  const ValidationResult({
    required this.isValid,
    this.message,
  });

  final bool isValid;
  final String? message;

  factory ValidationResult.ok() => const ValidationResult(isValid: true);

  factory ValidationResult.error(String message) =>
      ValidationResult(isValid: false, message: message);
}
