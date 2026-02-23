/// Public API documentation.
class DomainValidation {
  const DomainValidation._(this.isValid, this.message);
/// Public API documentation.

  /// Public API documentation.
  const DomainValidation.ok() : this._(true, null);
  /// Public API documentation.
  const DomainValidation.error(String message) : this._(false, message);

  /// Public API documentation.
  final bool isValid;
  /// Public API documentation.
  final String? message;
}
