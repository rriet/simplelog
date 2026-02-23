import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/aircrafts_table.dart';
import 'package:simplelog/data/database/tables/timeline_table.dart';

/// Public API documentation.
class SimulatorTrainings extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  IntColumn get aircraftId => integer().references(Aircrafts, #id)();
  /// Public API documentation.
  IntColumn get startTimeLineId => integer().references(TimeLines, #id)();
  /// Public API documentation.
  DateTimeColumn get endDateTime => dateTime().nullable()();
  /// Public API documentation.
  IntColumn get timeTotal => integer()();
  /// Public API documentation.
  TextColumn get remarks => text()();
  /// Public API documentation.
  TextColumn get notes => text()();
  /// Public API documentation.
  BoolColumn get isLocked => boolean()();
  /// Public API documentation.
  BlobColumn get signatureImage => blob().nullable()();
}
