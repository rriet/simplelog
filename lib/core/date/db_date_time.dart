import 'package:intl/intl.dart';

/// Public API documentation.
class DbDateTimeParts {
  /// Public API documentation.
  const DbDateTimeParts({
    required this.year,
    required this.monthNumber,
    required this.monthShort,
    required this.day,
    required this.hour,
    required this.minute,
    required this.hhmm,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final int year;
  /// Public API documentation.
  final int monthNumber;
  /// Public API documentation.
  final String monthShort;
  /// Public API documentation.
  final int day;
  /// Public API documentation.
  final int hour;
  /// Public API documentation.
  final int minute;
  /// Public API documentation.
  final String hhmm;
}

/// Public API documentation.
class DbDateTime {
  /// Public API documentation.
  const DbDateTime._();

  /// Normalizes a database timestamp as UTC.
  static DateTime dbToUtc(DateTime value) {
    return DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: true,
    );
  }

  /// Public API documentation.
  static DateTime? dbToUtcOrNull(DateTime? value) {
    if (value == null) return null;
    return dbToUtc(value);
  }

  /// Converts wall-clock fields to UTC for storage without timezone shifting.
  static DateTime wallClockToDbUtc(DateTime value) {
    return DateTime.utc(
      /// Public API documentation.
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      /// Public API documentation.
      value.second,
      value.millisecond,
      value.microsecond,
    );
  }

  /// Public API documentation.
  static DateTime? wallClockToDbUtcOrNull(DateTime? value) {
    if (value == null) return null;
    return wallClockToDbUtc(value);
  }

  /// Public API documentation.
  static DbDateTimeParts parts(DateTime dbValue, {String? locale}) {
    final utc = dbToUtc(dbValue);
    final hh = utc.hour.toString().padLeft(2, '0');
    final mm = utc.minute.toString().padLeft(2, '0');
    return DbDateTimeParts(
      year: utc.year,
      monthNumber: utc.month,
      monthShort: DateFormat('MMM', locale).format(utc),
      day: utc.day,
      hour: utc.hour,
      minute: utc.minute,
      hhmm: '$hh:$mm',
    );
  }
}
