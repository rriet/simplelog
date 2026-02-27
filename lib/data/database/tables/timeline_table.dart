import 'package:drift/drift.dart';

/// Stores canonical UTC timestamps referenced by flights and other entries.
class TimeLines extends Table {
  /// Primary key for a timeline row.
  IntColumn get id => integer().autoIncrement()();

  /// UTC date-time value used by related records.
  DateTimeColumn get eventDateTime => dateTime()();
}
