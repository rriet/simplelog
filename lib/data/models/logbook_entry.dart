import 'package:simplelog/data/database/app_database.dart';

/// High‑level type of event represented by a logbook entry.
enum LogbookEventType {
  /// A normal flight sector.
  flight,

  /// A simulator training session.
  simulatorTraining,

  /// A duty period boundary (start or end).
  dutyPeriod,

  /// A positioning (dead‑heading) segment.
  positioning,

  /// Fallback for entries that do not match any known type.
  unknown,
}

/// Rich view over a timeline entry and its associated domain entities.
class LogbookEntry {
  /// Creates a new logbook entry wrapper.
  LogbookEntry({
    required this.timeLine,
    this.flight,
    this.aircraft,
    this.aircraftType,
    this.positioning,
    this.simulatorTraining,
    this.dutyStart,
    this.dutyEnd,
    this.departureAirport,
    this.arrivalAirport,
    this.positioningDepartureAirport,
    this.positioningArrivalAirport,
  });

  /// Underlying timeline entry for this event.
  final TimeLine timeLine;

  /// Flight data when this entry represents a flight sector.
  final Flight? flight;

  /// Aircraft used for the event, if any.
  final Aircraft? aircraft;

  /// Aircraft type associated with the event, if any.
  final AircraftType? aircraftType;

  /// Positioning segment data, when applicable.
  final Positioning? positioning;

  /// Simulator training data, when applicable.
  final SimulatorTraining? simulatorTraining;

  /// Duty period that starts at this timeline entry, if any.
  final DutyPeriod? dutyStart;

  /// Duty period that ends at this timeline entry, if any.
  final DutyPeriod? dutyEnd;

  /// Departure airport for the flight or positioning leg, if resolved.
  final Airport? departureAirport;

  /// Arrival airport for the flight or positioning leg, if resolved.
  final Airport? arrivalAirport;

  /// Departure airport for positioning legs when 
  /// different from [departureAirport].
  final Airport? positioningDepartureAirport;

  /// Arrival airport for positioning legs when different from [arrivalAirport].
  final Airport? positioningArrivalAirport;

  /// Derives the [LogbookEventType] for this entry based on attached data.
  LogbookEventType get type {
    if (flight != null) return LogbookEventType.flight;
    if (positioning != null) return LogbookEventType.positioning;
    if (simulatorTraining != null) return LogbookEventType.simulatorTraining;
    if (dutyStart != null || dutyEnd != null) {
      return LogbookEventType.dutyPeriod;
    }
    return LogbookEventType.unknown;
  }

  /// Whether this entry marks the start of a duty period.
  bool get isDutyStart => dutyStart != null;

  /// Whether this entry marks the end of a duty period.
  bool get isDutyEnd => dutyEnd != null;
}

/// Small projection of a duty period with timing information.
class DutyRangeInfo {
  /// Creates a representation of a duty's [start]/[end] range.
  DutyRangeInfo({
    required this.dutyId,
    required this.start,
    required this.end,
    required this.isLocked,
  });

  /// Identifier of the duty period.
  final int dutyId;

  /// UTC start date/time of the duty period.
  final DateTime start;

  /// UTC end date/time of the duty period.
  final DateTime end;

  /// Whether the duty period is locked against modification.
  final bool isLocked;
}
