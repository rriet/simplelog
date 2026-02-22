import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/models/flight_write_input.dart';
import 'package:simplelog/domain/repositories/logbook_repository_contract.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';

void main() {
  group('LogbookUseCases flight write', () {
    test('does not write when validator returns errors', () async {
      final repository = _FakeLogbookRepository();
      final useCases = LogbookUseCases(repository);
      final departure = DateTime.utc(2026, 1, 1, 10, 0);
      final input = _baseInput(
        departureDateTime: departure,
        arrivalDateTime: departure.subtract(const Duration(minutes: 1)),
      );

      final result = await useCases.createFlight(input: input);

      expect(result.isSuccess, isFalse);
      expect(repository.createFlightCalls, 0);
      expect(result.errors, isNotEmpty);
    });

    test('writes and returns warnings when warning rules are hit', () async {
      final repository = _FakeLogbookRepository();
      final useCases = LogbookUseCases(repository);
      final input = _baseInput(
        timeBlockMinutes: 120,
        timePICMinutes: 30,
        timeSICMinutes: 30,
      );

      final result = await useCases.createFlight(input: input);

      expect(result.isSuccess, isTrue);
      expect(repository.createFlightCalls, 1);
      expect(result.warnings, isNotEmpty);
    });
  });
}

class _FakeLogbookRepository implements LogbookRepositoryContract {
  int createFlightCalls = 0;

  @override
  Future<void> createFlight({required FlightWriteInput input}) async {
    createFlightCalls += 1;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FlightWriteInput _baseInput({
  DateTime? departureDateTime,
  DateTime? arrivalDateTime,
  int timeBlockMinutes = 60,
  int timePICMinutes = 60,
  int timeSICMinutes = 0,
}) {
  return FlightWriteInput(
    aircraftId: 1,
    departureAirportId: 1,
    arrivalAirportId: 2,
    departureDateTime: departureDateTime ?? DateTime.utc(2026, 1, 1, 10, 0),
    takeOffDateTime: null,
    landingDateTime: null,
    arrivalDateTime: arrivalDateTime,
    pilotFunction: 'PF',
    ifrApproaches: 0,
    approachType: '',
    takeOffsDays: 0,
    takeOffsNight: 0,
    landingsDay: 0,
    landingsNight: 0,
    timeBlockMinutes: timeBlockMinutes,
    timeTotalBlockMinutes: timeBlockMinutes,
    timeFlightMinutes: timeBlockMinutes,
    timePICMinutes: timePICMinutes,
    timePICUSMinutes: 0,
    timeSICMinutes: timeSICMinutes,
    timeDualMinutes: 0,
    timeInstructorMinutes: 0,
    timeIFRMinutes: 0,
    timeInstrumentMinutes: 0,
    timeSimulatedInstrumentMinutes: 0,
    timeNightMinutes: 0,
    timeCrossCountryMinutes: 0,
    timeCustom1Minutes: 0,
    timeCustom2Minutes: 0,
    timeCustom3Minutes: 0,
    timeCustom4Minutes: 0,
    distanceNM: 0,
    remarks: '',
    notes: '',
    crewAssignments: const [],
  );
}
