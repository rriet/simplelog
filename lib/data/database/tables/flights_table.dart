import 'package:drift/drift.dart';

import 'aircrafts_table.dart';
import 'airports_table.dart';
import 'timeline_table.dart';

class Flights extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aircraftId => integer().references(Aircrafts, #id)();
  IntColumn get departureAirportId => integer().references(Airports, #id)();
  IntColumn get arrivalAirportId => integer().references(Airports, #id)();
  IntColumn get departureDateTimeId => integer().references(TimeLines, #id)();
  DateTimeColumn get takeOffDateTime => dateTime().nullable()();
  DateTimeColumn get landingDateTime => dateTime().nullable()();
  DateTimeColumn get arrivalDateTime => dateTime().nullable()();
  IntColumn get timePICMinutes => integer()();
  IntColumn get timePICUSMinutes => integer()();
  IntColumn get timeSICMinutes => integer()();
  IntColumn get timeDualMinutes => integer()();
  IntColumn get timeInstructorMinutes => integer()();
  IntColumn get timeIFRMinutes => integer()();
  IntColumn get timeInstrumentMinutes => integer()();
  IntColumn get timeSimulatedInstrumentMinutes => integer()();
  IntColumn get timeNightMinutes => integer()();
  IntColumn get timeCrossCountryMinutes => integer()();
  IntColumn get timeCustom1Minutes => integer()();
  IntColumn get timeCustom2Minutes => integer()();
  IntColumn get timeCustom3Minutes => integer()();
  IntColumn get timeCustom4Minutes => integer()();
  IntColumn get timeFlightMinutes => integer()();
  IntColumn get timeBlockMinutes => integer()();
  IntColumn get distanceNM => integer()();
  IntColumn get ifrApproaches => integer()();
  IntColumn get takeOffsDays => integer()();
  IntColumn get takeOffsNight => integer()();
  IntColumn get landingsDay => integer()();
  IntColumn get landingsNight => integer()();
  TextColumn get approachType => text()();
  TextColumn get remarks => text()();
  TextColumn get notes => text()();
  BoolColumn get isLocked => boolean()();
  BlobColumn get signatureImage => blob().nullable()();
}
