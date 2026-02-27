import 'package:simplelog/data/database/app_database.dart';

/// Convenience formatting helpers for [CrewData] used by the
/// presentation layer.
extension CrewExtensions on CrewData {
  /// Returns uppercase initials derived from the crew member name.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '';
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// Returns the phone number formatted for display.
  String get formattedPhone {
    return formatPhoneDisplay(phone);
  }
}

/// Formats a raw phone number into a human-friendly representation.
///
/// Returns an empty string when [input] is null or blank, and falls back to
/// the original text when the value cannot be safely normalized.
String formatPhoneDisplay(String? input) {
  final raw = (input ?? '').trim();
  if (raw.isEmpty) return '';

  final hasPlus = raw.startsWith('+');
  final digits = raw.replaceAll(RegExp('[^0-9]'), '');
  if (digits.isEmpty) return raw;

  String format10(String tenDigits) {
    return '(${tenDigits.substring(0, 3)}) '
        '${tenDigits.substring(3, 6)}-${tenDigits.substring(6)}';
  }

  if (!hasPlus && digits.length == 7) {
    return '${digits.substring(0, 3)}-${digits.substring(3)}';
  }

  if (!hasPlus && digits.length == 10) {
    return format10(digits);
  }

  if (!hasPlus && digits.length == 11 && digits.startsWith('1')) {
    final local = digits.substring(1);
    return '+1 ${format10(local)}';
  }

  if (hasPlus && digits.length > 10) {
    final country = digits.substring(0, digits.length - 10);
    final local = digits.substring(digits.length - 10);
    return '+$country ${format10(local)}';
  }

  return raw;
}
