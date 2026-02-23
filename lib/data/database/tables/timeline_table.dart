import 'package:drift/drift.dart';

/// Public API documentation.
class TimeLines extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  DateTimeColumn get eventDateTime => dateTime()();
}
