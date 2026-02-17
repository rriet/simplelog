import 'package:drift/drift.dart';

import 'aircraft_types_table.dart';

class Aircrafts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aircraftTypeId => integer().references(AircraftTypes, #id)();
  TextColumn get registration => text()();
  IntColumn get mtow => integer()();
  BoolColumn get isSimulator => boolean()();
  BoolColumn get isFavorite => boolean()();
  BoolColumn get isLocked => boolean()();
  TextColumn get notes => text().nullable()();
}
