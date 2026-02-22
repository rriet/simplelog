import 'package:simplelog/data/database/app_database.dart';

extension CrewExtensions on CrewData {
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '';
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  String get formattedPhone {
    return formatPhoneDisplay(phone);
  }
}

String formatPhoneDisplay(String? input) {
  final raw = (input ?? '').trim();
  if (raw.isEmpty) return '';

  final hasPlus = raw.startsWith('+');
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
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
