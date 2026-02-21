import 'package:intl/intl.dart';

class DbDateTimeParts {
  const DbDateTimeParts({
    required this.year,
    required this.monthNumber,
    required this.monthShort,
    required this.day,
    required this.hour,
    required this.minute,
    required this.hhmm,
  });

  final int year;
  final int monthNumber;
  final String monthShort;
  final int day;
  final int hour;
  final int minute;
  final String hhmm;
}

class DbDateTime {
  const DbDateTime._();

  /// Normalizes a database timestamp as UTC.
  static DateTime dbToUtc(DateTime value) {
    return DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: true,
    );
  }

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

  static DateTime? wallClockToDbUtcOrNull(DateTime? value) {
    if (value == null) return null;
    return wallClockToDbUtc(value);
  }

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
