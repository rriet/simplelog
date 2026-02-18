import 'package:drift/drift.dart';

import 'airports_table.dart';
import 'timeline_table.dart';

class Positionings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get departurePlaceId => integer().references(Airports, #id)();
  IntColumn get arrivalPlaceId => integer().references(Airports, #id)();
  IntColumn get departureDateTimeId => integer().references(TimeLines, #id)();
  DateTimeColumn get arrivalDateTime => dateTime().nullable()();
  IntColumn get timeTotalMinutes => integer()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get isLocked => boolean()();
}
