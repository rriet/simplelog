import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/aircraft_types_table.dart';

/// Aircraft instances table.
class Aircrafts extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();
  /// Linked aircraft type id.
  IntColumn get aircraftTypeId => integer().references(AircraftTypes, #id)();
  /// Registration/tail number.
  TextColumn get registration => text()();
  /// Optional per-aircraft MTOW override.
  IntColumn get mtow => integer().nullable()();
  /// Marks this row as simulator device/entry.
  BoolColumn get isSimulator => boolean()();
  /// Favorite/pinned flag.
  BoolColumn get isFavorite => boolean()();
  /// Lock flag preventing edits.
  BoolColumn get isLocked => boolean()();
  /// Optional notes.
  TextColumn get notes => text().nullable()();
}
