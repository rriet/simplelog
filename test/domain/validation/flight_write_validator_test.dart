import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/models/flight_write_input.dart';
import 'package:simplelog/domain/validation/flight_write_validator.dart';

void main() {
  group('FlightWriteValidator', () {
    const validator = FlightWriteValidator();

    test('returns error when arrival is before departure', () {
      final departure = DateTime.utc(2026, 1, 1, 10);
      final input = _baseInput(
        departureDateTime: departure,
        arrivalDateTime: departure.subtract(const Duration(minutes: 1)),
      );

      final report = validator.validate(input);

      expect(report.hasErrors, isTrue);
      expect(
        report.errors.any(
          (issue) => issue.code == 'flight.arrival.beforeDeparture',
        ),
        isTrue,
      );
    });

    test('returns warning when primary times do not equal block', () {
      final input = _baseInput(
        timeBlockMinutes: 120,
        timePICMinutes: 30,
        timeSICMinutes: 30,
      );

      final report = validator.validate(input);

      expect(report.hasErrors, isFalse);
      expect(report.hasWarnings, isTrue);
      expect(
        report.warnings.any(
          (issue) => issue.code == 'flight.primarySum.notEqualBlock',
        ),
        isTrue,
      );
    });
  });
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
    departureDateTime: departureDateTime ?? DateTime.utc(2026, 1, 1, 10),
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
