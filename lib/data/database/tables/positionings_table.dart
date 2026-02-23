import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/airports_table.dart';
import 'package:simplelog/data/database/tables/timeline_table.dart';

/// Public API documentation.
class Positionings extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  IntColumn get departurePlaceId => integer().references(Airports, #id)();
  /// Public API documentation.
  IntColumn get arrivalPlaceId => integer().references(Airports, #id)();
  /// Public API documentation.
  IntColumn get departureDateTimeId => integer().references(TimeLines, #id)();
  /// Public API documentation.
  DateTimeColumn get arrivalDateTime => dateTime().nullable()();
  /// Public API documentation.
  IntColumn get timeTotalMinutes => integer()();
  /// Public API documentation.
  TextColumn get notes => text().withDefault(const Constant(''))();
  /// Public API documentation.
  BoolColumn get isLocked => boolean()();
}
