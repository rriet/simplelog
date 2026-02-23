import 'package:simplelog/data/models/flight_write_input.dart';
import 'package:simplelog/domain/validation/validation_issue.dart';

/// Public API documentation.
class FlightWriteValidator {
  /// Public API documentation.
  const FlightWriteValidator();

  /// Public API documentation.
  ValidationReport validate(FlightWriteInput input) {
    final errors = <ValidationIssue>[];
    final warnings = <ValidationIssue>[];

    if (input.aircraftId <= 0) {
      errors.add(
        const ValidationIssue(
          code: 'flight.aircraft.required',
          field: 'aircraftId',
          message: 'Aircraft is required.',
          severity: ValidationSeverity.error,
        ),
      );
    }
    if (input.departureAirportId <= 0) {
      errors.add(
        const ValidationIssue(
          code: 'flight.departureAirport.required',
          field: 'departureAirportId',
          message: 'Departure airport is required.',
          severity: ValidationSeverity.error,
        ),
      );
    }
    if (input.arrivalAirportId <= 0) {
      errors.add(
        const ValidationIssue(
          code: 'flight.arrivalAirport.required',
          field: 'arrivalAirportId',
          message: 'Arrival airport is required.',
          severity: ValidationSeverity.error,
        ),
      );
    }

    if (input.timeBlockMinutes < 0 || input.timeBlockMinutes > 24 * 60) {
      errors.add(
        const ValidationIssue(
          code: 'flight.block.invalid',
          field: 'timeBlockMinutes',
          message: 'Block time must be between 0:00 and 24:00.',
          severity: ValidationSeverity.error,
        ),
      );
    }
    if (input.timeTotalBlockMinutes < 0 ||
        input.timeTotalBlockMinutes > 24 * 60) {
      errors.add(
        const ValidationIssue(
          code: 'flight.totalBlock.invalid',
          field: 'timeTotalBlockMinutes',
          message: 'Total block time must be between 0:00 and 24:00.',
          severity: ValidationSeverity.error,
        ),
      );
    }

    final arrival = input.arrivalDateTime;
    if (arrival != null && arrival.isBefore(input.departureDateTime)) {
      errors.add(
        const ValidationIssue(
          code: 'flight.arrival.beforeDeparture',
          field: 'arrivalDateTime',
          message: 'Chocks ON must be after or equal to Chocks OFF.',
          severity: ValidationSeverity.error,
        ),
      );
    }
    final takeoff = input.takeOffDateTime;
    final landing = input.landingDateTime;
    if (takeoff != null && takeoff.isBefore(input.departureDateTime)) {
      errors.add(
        const ValidationIssue(
          code: 'flight.takeoff.beforeChocksOff',
          field: 'takeOffDateTime',
          message: 'Takeoff must be after or equal to Chocks OFF.',
          severity: ValidationSeverity.error,
        ),
      );
    }
    if (takeoff != null && landing != null && landing.isBefore(takeoff)) {
      errors.add(
        const ValidationIssue(
          code: 'flight.landing.beforeTakeoff',
          field: 'landingDateTime',
          message: 'Landing must be after or equal to Takeoff.',
          severity: ValidationSeverity.error,
        ),
      );
    }
    if (landing != null && arrival != null && landing.isAfter(arrival)) {
      errors.add(
        const ValidationIssue(
          code: 'flight.landing.afterChocksOn',
          field: 'landingDateTime',
          message: 'Landing must be before or equal to Chocks ON.',
          severity: ValidationSeverity.error,
        ),
      );
    }

    final primaryTimes = [
      input.timePICMinutes,
      input.timePICUSMinutes,
      input.timeSICMinutes,
      input.timeDualMinutes,
      input.timeInstructorMinutes,
    ];
    final primaryWithTime = primaryTimes.where((m) => m > 0).length;
    if (primaryWithTime > 1) {
      warnings.add(
        const ValidationIssue(
          code: 'flight.primaryRoles.multiple',
          message:
              'More than one of PIC, PICUS, SIC, Dual, Instructor '
              'has time greater than 0.',
          severity: ValidationSeverity.warning,
        ),
      );
    }

    final primarySum =
        input.timePICMinutes +
        input.timePICUSMinutes +
        input.timeSICMinutes +
        input.timeDualMinutes +
        input.timeInstructorMinutes;
    if (primarySum != input.timeBlockMinutes) {
      warnings.add(
        const ValidationIssue(
          code: 'flight.primarySum.notEqualBlock',
          message:
              'PIC + PICUS + SIC + Dual + Instructor must equal Block time.',
          severity: ValidationSeverity.warning,
        ),
      );
    }

    if (input.timeNightMinutes > input.timeBlockMinutes) {
      warnings.add(
        const ValidationIssue(
          code: 'flight.night.greaterThanBlock',
          field: 'timeNightMinutes',
          message: 'Night time is greater than Block time.',
          severity: ValidationSeverity.warning,
        ),
      );
    }
    if (input.timeCrossCountryMinutes > input.timeBlockMinutes) {
      warnings.add(
        const ValidationIssue(
          code: 'flight.crossCountry.greaterThanBlock',
          field: 'timeCrossCountryMinutes',
          message: 'Cross-country time is greater than Block time.',
          severity: ValidationSeverity.warning,
        ),
      );
    }
    if (input.timeIFRMinutes > input.timeBlockMinutes) {
      warnings.add(
        const ValidationIssue(
          code: 'flight.ifr.greaterThanBlock',
          field: 'timeIFRMinutes',
          message: 'IFR time is greater than Block time.',
          severity: ValidationSeverity.warning,
        ),
      );
    }

    return ValidationReport(errors: errors, warnings: warnings);
  }
}
