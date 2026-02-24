/// Lightweight success/error wrapper used for domain-level validations.
class DomainValidation {
  const DomainValidation._(this.isValid, this.message);


  /// Successful validation with no message.
  const DomainValidation.ok() : this._(true, null);

  /// Failed validation with a human‑readable [message].
  const DomainValidation.error(String message) : this._(false, message);

  /// Whether the validation passed.
  final bool isValid;

  /// Optional human‑readable error message.
  final String? message;
}
