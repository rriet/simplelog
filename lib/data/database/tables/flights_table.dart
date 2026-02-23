import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/aircrafts_table.dart';
import 'package:simplelog/data/database/tables/airports_table.dart';
import 'package:simplelog/data/database/tables/timeline_table.dart';

/// Public API documentation.
class Flights extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  IntColumn get aircraftId => integer().references(Aircrafts, #id)();
  /// Public API documentation.
  IntColumn get departureAirportId => integer().references(Airports, #id)();
  /// Public API documentation.
  IntColumn get arrivalAirportId => integer().references(Airports, #id)();
  /// Public API documentation.
  IntColumn get departureDateTimeId => integer().references(TimeLines, #id)();
  /// Public API documentation.
  DateTimeColumn get takeOffDateTime => dateTime().nullable()();
  /// Public API documentation.
  DateTimeColumn get landingDateTime => dateTime().nullable()();
  /// Public API documentation.
  DateTimeColumn get arrivalDateTime => dateTime().nullable()();
  /// Public API documentation.
  IntColumn get timePICMinutes => integer()();
  /// Public API documentation.
  IntColumn get timePICUSMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeSICMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeDualMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeInstructorMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeIFRMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeInstrumentMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeSimulatedInstrumentMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeNightMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeCrossCountryMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeCustom1Minutes => integer()();
  /// Public API documentation.
  IntColumn get timeCustom2Minutes => integer()();
  /// Public API documentation.
  IntColumn get timeCustom3Minutes => integer()();
  /// Public API documentation.
  IntColumn get timeCustom4Minutes => integer()();
  /// Public API documentation.
  IntColumn get timeFlightMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeBlockMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeTotalBlockMinutes =>
      integer().withDefault(const Constant(0))();
  /// Public API documentation.
  IntColumn get distanceNM => integer()();
  /// Public API documentation.
  IntColumn get ifrApproaches => integer()();
  /// Public API documentation.
  IntColumn get takeOffsDays => integer()();
  /// Public API documentation.
  IntColumn get takeOffsNight => integer()();
  /// Public API documentation.
  IntColumn get landingsDay => integer()();
  /// Public API documentation.
  IntColumn get landingsNight => integer()();
  /// Public API documentation.
  TextColumn get pilotFunction => text().withDefault(const Constant('PF'))();
  /// Public API documentation.
  TextColumn get approachType => text()();
  /// Public API documentation.
  TextColumn get remarks => text()();
  /// Public API documentation.
  TextColumn get notes => text()();
  /// Public API documentation.
  BoolColumn get isLocked => boolean()();
  /// Public API documentation.
  BlobColumn get signatureImage => blob().nullable()();
}
