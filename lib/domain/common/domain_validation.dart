class DomainValidation {
  const DomainValidation._(this.isValid, this.message);

  const DomainValidation.ok() : this._(true, null);
  const DomainValidation.error(String message) : this._(false, message);

  final bool isValid;
  final String? message;
}
