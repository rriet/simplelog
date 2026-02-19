import 'package:drift/drift.dart';

import 'aircraft_types_table.dart';

class PreviousExperiences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aircraftTypeId => integer().references(AircraftTypes, #id)();
  DateTimeColumn get dateTimeFirstFlight => dateTime().nullable()();
  DateTimeColumn get dateTimeLastFlight => dateTime().nullable()();
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
  IntColumn get timeSimulatorMinutes => integer()();
  IntColumn get distanceNM => integer()();
  IntColumn get ifrApproaches => integer()();
  IntColumn get takeOffsDays => integer()();
  IntColumn get takeOffsNight => integer()();
  IntColumn get landingsDay => integer()();
  IntColumn get landingsNight => integer()();
}
