import 'package:drift/drift.dart';

import 'aircrafts_table.dart';
import 'timeline_table.dart';

class SimulatorTrainings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aircraftId => integer().references(Aircrafts, #id)();
  IntColumn get startTimeLineId => integer().references(TimeLines, #id)();
  DateTimeColumn get endDateTime => dateTime().nullable()();
  IntColumn get timeTotal => integer()();
  TextColumn get remarks => text()();
  TextColumn get notes => text()();
  BoolColumn get isLocked => boolean()();
  BlobColumn get signatureImage => blob().nullable()();
}
