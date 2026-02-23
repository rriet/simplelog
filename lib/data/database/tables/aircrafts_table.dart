import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/aircraft_types_table.dart';

/// Public API documentation.
class Aircrafts extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  IntColumn get aircraftTypeId => integer().references(AircraftTypes, #id)();
  /// Public API documentation.
  TextColumn get registration => text()();
  /// Public API documentation.
  IntColumn get mtow => integer().nullable()();
  /// Public API documentation.
  BoolColumn get isSimulator => boolean()();
  /// Public API documentation.
  BoolColumn get isFavorite => boolean()();
  /// Public API documentation.
  BoolColumn get isLocked => boolean()();
  /// Public API documentation.
  TextColumn get notes => text().nullable()();
}
