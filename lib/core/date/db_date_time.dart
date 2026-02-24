import 'package:intl/intl.dart';

/// Precomputed pieces of a UTC `DateTime` useful for formatting.
class DbDateTimeParts {
  /// Creates a new value object with broken‑out date and time fields.
  const DbDateTimeParts({
    required this.year,
    required this.monthNumber,
    required this.monthShort,
    required this.day,
    required this.hour,
    required this.minute,
    required this.hhmm,
  });

  /// Four‑digit year component.
  final int year;

  /// Month number \[1–12\].
  final int monthNumber;

  /// Short localized month name (e.g. `Jan`).
  final String monthShort;

  /// Day of month.
  final int day;

  /// Hour in 24‑hour clock.
  final int hour;

  /// Minute component.
  final int minute;

  /// Cached `"HH:mm"` representation.
  final String hhmm;
}

/// Helpers for converting between wall‑clock times and UTC database values.
class DbDateTime {
  /// Private constructor to prevent instantiation.
  const DbDateTime._();

  /// Normalizes a database timestamp as UTC.
  static DateTime dbToUtc(DateTime value) {
    return DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: true,
    );
  }

  /// Like [dbToUtc] but accepts nullable input.
  static DateTime? dbToUtcOrNull(DateTime? value) {
    if (value == null) return null;
    return dbToUtc(value);
  }

  /// Converts wall-clock fields to UTC for storage without timezone shifting.
  static DateTime wallClockToDbUtc(DateTime value) {
    return DateTime.utc(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
    );
  }

  /// Like [wallClockToDbUtc] but accepts nullable input.
  static DateTime? wallClockToDbUtcOrNull(DateTime? value) {
    if (value == null) return null;
    return wallClockToDbUtc(value);
  }

  /// Extracts [DbDateTimeParts] from a UTC database timestamp.
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
