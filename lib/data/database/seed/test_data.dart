import 'dart:math';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../enums/aircraft_category.dart';
import '../enums/crew_position.dart';
import '../enums/engine_type.dart';

extension TestDataSeeder on AppDatabase {
  Future<void> seedTestData({
    int aircraftTypesCount = 5,
    int aircraftCount = 5,
    int airportsCount = 6,
    int crewCount = 8,
    int flightsCount = 8,
    int positioningsCount = 4,
    int simulatorTrainingsCount = 3,
    int dutyPeriodsCount = 4,
    int flightCrewAssignmentsPerFlight = 2,
    int simulatorCrewAssignmentsPerSim = 2,
  }) async {
    final random = Random();

    int randomInt(int min, int max) =>
        min + random.nextInt(max - min + 1);

    bool randomBool() => random.nextBool();

    T randomFrom<T>(List<T> values) =>
        values[random.nextInt(values.length)];

    final engineTypes = EngineType.values
        .where((value) => value != EngineType.unknown)
        .toList();
    final categories = AircraftCategory.values
        .where((value) => value != AircraftCategory.unknown)
        .toList();
    final crewPositions = CrewPosition.values
        .where((value) => value != CrewPosition.unknown)
        .toList();

    await transaction(() async {
      final aircraftTypeIds = <int>[];
      for (var i = 0; i < aircraftTypesCount; i += 1) {
        final id = await into(aircraftTypes).insert(
          AircraftTypesCompanion.insert(
            code: 'AT${100 + i}',
            family: 'Family ${i + 1}',
            longName: 'Aircraft Type ${i + 1}',
            manufacturer: Value(randomBool() ? 'Maker ${i + 1}' : null),
            category: randomFrom(categories),
            engineType: randomFrom(engineTypes),
            mtow: randomInt(800, 8000),
            engineCount: randomInt(1, 4),
            multiPilot: randomBool(),
            complex: randomBool(),
            efis: randomBool(),
            highPerformance: randomBool(),
            isLocked: false,
          ),
        );
        aircraftTypeIds.add(id);
      }

      final aircraftIds = <int>[];
      for (var i = 0; i < aircraftCount; i += 1) {
        final id = await into(aircrafts).insert(
          AircraftsCompanion.insert(
            aircraftTypeId: randomFrom(aircraftTypeIds),
            registration: 'N${randomInt(1000, 9999)}',
            mtow: randomInt(800, 8000),
            isSimulator: randomBool(),
            isFavorite: randomBool(),
            isLocked: false,
          ),
        );
        aircraftIds.add(id);
      }

      final airportIds = <int>[];
      for (var i = 0; i < airportsCount; i += 1) {
        final id = await into(airports).insert(
          AirportsCompanion.insert(
            icao: 'K${String.fromCharCode(65 + i)}${String.fromCharCode(65 + i)}${String.fromCharCode(65 + i)}',
            iata: Value('A${String.fromCharCode(65 + i)}'),
            name: Value('Airport ${i + 1}'),
            city: Value('City ${i + 1}'),
            country: Value('Country ${i + 1}'),
            latitude: random.nextDouble() * 180 - 90,
            longitude: random.nextDouble() * 360 - 180,
            isFavorite: randomBool(),
            isLocked: false,
          ),
        );
        airportIds.add(id);
      }

      final crewIds = <int>[];
      for (var i = 0; i < crewCount; i += 1) {
        final id = await into(crew).insert(
          CrewCompanion.insert(
            name: 'Crew Member ${i + 1}',
            email: Value('crew${i + 1}@example.com'),
            notes: const Value(null),
            phone: Value('+1-555-${randomInt(1000, 9999)}'),
            picture: const Value(null),
            isSelf: i == 0,
            isFavorite: randomBool(),
            isLocked: false,
          ),
        );
        crewIds.add(id);
      }

      Future<int> insertTimeline(DateTime dateTime) {
        return into(timeLines).insert(
          TimeLinesCompanion.insert(eventDateTime: dateTime),
        );
      }

      final now = DateTime.now();

      Future<int> insertFlight({
        required DateTime departure,
        required DateTime takeoff,
        required DateTime landing,
        required DateTime arrival,
        required int aircraftId,
        required int departureAirportId,
        required int arrivalAirportId,
      }) async {
        final departureTimelineId = await insertTimeline(departure);
        final id = await into(flights).insert(
          FlightsCompanion.insert(
            aircraftId: aircraftId,
            departureAirportId: departureAirportId,
            arrivalAirportId: arrivalAirportId,
            departureDateTimeId: departureTimelineId,
            takeOffDateTime: Value(takeoff),
            landingDateTime: Value(landing),
            arrivalDateTime: Value(arrival),
            timePICMinutes: randomInt(0, 240),
            timePICUSMinutes: randomInt(0, 240),
            timeSICMinutes: randomInt(0, 240),
            timeDualMinutes: randomInt(0, 240),
            timeInstructorMinutes: randomInt(0, 240),
            timeIFRMinutes: randomInt(0, 240),
            timeInstrumentMinutes: randomInt(0, 240),
            timeSimulatedInstrumentMinutes: randomInt(0, 240),
            timeNightMinutes: randomInt(0, 240),
            timeCrossCountryMinutes: randomInt(0, 240),
            timeCustom1Minutes: randomInt(0, 240),
            timeCustom2Minutes: randomInt(0, 240),
            timeCustom3Minutes: randomInt(0, 240),
            timeCustom4Minutes: randomInt(0, 240),
            timeFlightMinutes: randomInt(0, 240),
            timeBlockMinutes: randomInt(0, 300),
            distanceNM: randomInt(50, 900),
            ifrApproaches: randomInt(0, 3),
            takeOffsDays: randomInt(0, 2),
            takeOffsNight: randomInt(0, 2),
            landingsDay: randomInt(0, 2),
            landingsNight: randomInt(0, 2),
            approachType: 'ILS',
            remarks: 'Test flight',
            notes: '',
            isLocked: false,
            signatureImage: const Value(null),
          ),
        );
        for (var j = 0; j < flightCrewAssignmentsPerFlight; j += 1) {
          await into(flightCrewAssignments).insert(
            FlightCrewAssignmentsCompanion.insert(
              flightId: id,
              crewId: randomFrom(crewIds),
              position: randomFrom(crewPositions),
            ),
          );
        }
        return id;
      }

      Future<int> insertPositioning({
        required DateTime departure,
        required DateTime arrival,
        required int departureAirportId,
        required int arrivalAirportId,
      }) async {
        final departureTimelineId = await insertTimeline(departure);
        return into(positionings).insert(
          PositioningsCompanion.insert(
            departurePlaceId: departureAirportId,
            arrivalPlaceId: arrivalAirportId,
            departureDateTimeId: departureTimelineId,
            arrivalDateTime: Value(arrival),
            timeTotalMinutes: arrival.difference(departure).inMinutes,
            isLocked: false,
          ),
        );
      }

      Future<void> seedDutyScenario(DateTime baseDate) async {
        if (aircraftIds.isEmpty || airportIds.length < 2) return;
        final dutyStart = baseDate;
        final dutyEnd = baseDate.add(const Duration(hours: 6, minutes: 45));
        final dutyStartId = await insertTimeline(dutyStart);
        final dutyEndId = await insertTimeline(dutyEnd);

        final aircraftId = aircraftIds.first;
        final departureAirportId = airportIds.first;
        final arrivalAirportId = airportIds.last;

        await insertFlight(
          departure: baseDate.add(const Duration(hours: 1)),
          takeoff: baseDate.add(const Duration(hours: 1, minutes: 10)),
          landing: baseDate.add(const Duration(hours: 4, minutes: 10)),
          arrival: baseDate.add(const Duration(hours: 4, minutes: 20)),
          aircraftId: aircraftId,
          departureAirportId: departureAirportId,
          arrivalAirportId: arrivalAirportId,
        );

        await insertFlight(
          departure: baseDate.add(const Duration(hours: 5, minutes: 22)),
          takeoff: baseDate.add(const Duration(hours: 5, minutes: 30)),
          landing: baseDate.add(const Duration(hours: 6, minutes: 2)),
          arrival: baseDate.add(const Duration(hours: 6, minutes: 8)),
          aircraftId: aircraftId,
          departureAirportId: arrivalAirportId,
          arrivalAirportId: departureAirportId,
        );

        await insertPositioning(
          departure: baseDate.add(const Duration(hours: 6, minutes: 20)),
          arrival: baseDate.add(const Duration(hours: 6, minutes: 40)),
          departureAirportId: departureAirportId,
          arrivalAirportId: arrivalAirportId,
        );

        await into(dutyPeriods).insert(
          DutyPeriodsCompanion.insert(
            dutyStartTimeLineId: dutyStartId,
            dutyEndTimeLineId: dutyEndId,
            timeDutyMinutes: dutyEnd.difference(dutyStart).inMinutes,
            timeFactoredDutyMinutes: dutyEnd.difference(dutyStart).inMinutes,
            isLocked: false,
          ),
        );
      }

      final todayMorning = DateTime(now.year, now.month, now.day, 10, 0);
      final midLastYear = DateTime(now.year - 1, 6, 18, 8, 15);
      final earlyTwoYearsAgo = DateTime(now.year - 2, 1, 5, 9, 30);

      await seedDutyScenario(todayMorning);
      await seedDutyScenario(midLastYear);
      await seedDutyScenario(earlyTwoYearsAgo);

      if (aircraftIds.isNotEmpty && airportIds.length >= 2) {
        final aircraftId = aircraftIds.first;
        final depId = airportIds.first;
        final arrId = airportIds.last;
        final lastYearDate = DateTime(now.year - 1, 12, 20, 14, 0);
        final twoYearsAgoDate = DateTime(now.year - 2, 11, 11, 7, 40);

        await insertFlight(
          departure: lastYearDate,
          takeoff: lastYearDate.add(const Duration(minutes: 10)),
          landing: lastYearDate.add(const Duration(hours: 2)),
          arrival: lastYearDate.add(const Duration(hours: 2, minutes: 10)),
          aircraftId: aircraftId,
          departureAirportId: depId,
          arrivalAirportId: arrId,
        );

        await insertPositioning(
          departure: twoYearsAgoDate,
          arrival: twoYearsAgoDate.add(const Duration(minutes: 45)),
          departureAirportId: depId,
          arrivalAirportId: arrId,
        );
      }

      final flightIds = <int>[];
      for (var i = 0; i < flightsCount; i += 1) {
        final startTime = now.subtract(Duration(hours: randomInt(1, 500)));

        final takeoff = startTime.add(Duration(minutes: randomInt(5, 30)));
        final landing = takeoff.add(Duration(minutes: randomInt(30, 180)));
        final arrival = landing.add(Duration(minutes: randomInt(5, 20)));

        final id = await insertFlight(
          departure: startTime,
          takeoff: takeoff,
          landing: landing,
          arrival: arrival,
          aircraftId: randomFrom(aircraftIds),
          departureAirportId: randomFrom(airportIds),
          arrivalAirportId: randomFrom(airportIds),
        );

        flightIds.add(id);
      }

      for (var i = 0; i < positioningsCount; i += 1) {
        final startTime = now.subtract(Duration(hours: randomInt(1, 500)));
        final departureTimelineId = await insertTimeline(startTime);
        await into(positionings).insert(
          PositioningsCompanion.insert(
            departurePlaceId: randomFrom(airportIds),
            arrivalPlaceId: randomFrom(airportIds),
            departureDateTimeId: departureTimelineId,
            arrivalDateTime: Value(
              startTime.add(Duration(minutes: randomInt(30, 120))),
            ),
            timeTotalMinutes: randomInt(30, 180),
            isLocked: false,
          ),
        );
      }

      final simulatorIds = <int>[];
      for (var i = 0; i < simulatorTrainingsCount; i += 1) {
        final startTime = now.subtract(Duration(hours: randomInt(1, 500)));
        final startTimelineId = await insertTimeline(startTime);
        final id = await into(simulatorTrainings).insert(
          SimulatorTrainingsCompanion.insert(
            aircraftId: randomFrom(aircraftIds),
            startTimeLineId: startTimelineId,
            endDateTime: Value(
              startTime.add(Duration(minutes: randomInt(60, 180))),
            ),
            timeTotal: randomInt(60, 180),
            remarks: 'SIM ${i + 1}',
            notes: '',
            isLocked: false,
            signatureImage: const Value(null),
          ),
        );
        simulatorIds.add(id);

        for (var j = 0; j < simulatorCrewAssignmentsPerSim; j += 1) {
          await into(simulatorCrewAssignments).insert(
            SimulatorCrewAssignmentsCompanion.insert(
              simulatorId: id,
              crewId: randomFrom(crewIds),
              position: randomFrom(crewPositions),
            ),
          );
        }
      }

      for (var i = 0; i < dutyPeriodsCount; i += 1) {
        final startTime = now.subtract(Duration(hours: randomInt(1, 500)));
        final endTime =
            startTime.add(Duration(minutes: randomInt(120, 480)));
        final startTimelineId = await insertTimeline(startTime);
        final endTimelineId = await insertTimeline(endTime);

        if (aircraftIds.isNotEmpty && airportIds.length >= 2) {
          final aircraftId = randomFrom(aircraftIds);
          final depId = randomFrom(airportIds);
          final arrId = randomFrom(airportIds);
          final eventStart = startTime.add(const Duration(minutes: 30));
          final eventEnd = endTime.subtract(const Duration(minutes: 30));
          if (eventStart.isBefore(eventEnd)) {
            final pick = randomInt(0, 2);
            if (pick == 0) {
              await insertFlight(
                departure: eventStart,
                takeoff: eventStart.add(const Duration(minutes: 10)),
                landing: eventStart.add(const Duration(minutes: 70)),
                arrival: eventStart.add(const Duration(minutes: 80)),
                aircraftId: aircraftId,
                departureAirportId: depId,
                arrivalAirportId: arrId,
              );
            } else if (pick == 1) {
              final simStartTimelineId = await insertTimeline(eventStart);
              await into(simulatorTrainings).insert(
                SimulatorTrainingsCompanion.insert(
                  aircraftId: aircraftId,
                  startTimeLineId: simStartTimelineId,
                  endDateTime: Value(eventEnd),
                  timeTotal: eventEnd.difference(eventStart).inMinutes,
                  remarks: 'SIM Duty ${i + 1}',
                  notes: '',
                  isLocked: false,
                  signatureImage: const Value(null),
                ),
              );
            } else {
              await insertPositioning(
                departure: eventStart,
                arrival: eventEnd,
                departureAirportId: depId,
                arrivalAirportId: arrId,
              );
            }
          }
        }
        await into(dutyPeriods).insert(
          DutyPeriodsCompanion.insert(
            dutyStartTimeLineId: startTimelineId,
            dutyEndTimeLineId: endTimelineId,
            timeDutyMinutes: randomInt(120, 480),
            timeFactoredDutyMinutes: randomInt(120, 480),
            isLocked: false,
          ),
        );
      }
    });
  }
}
