import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
enum LogbookEventType {
  /// Public API documentation.
  flight,
  /// Public API documentation.
  simulatorTraining,
  /// Public API documentation.
  dutyPeriod,
  /// Public API documentation.
  positioning,
  /// Public API documentation.
  unknown,
}

/// Public API documentation.
class LogbookEntry {
  /// Public API documentation.
  LogbookEntry({
    required this.timeLine,
    this.flight,
    this.aircraft,
    this.aircraftType,
    this.positioning,
    this.simulatorTraining,
    /// Public API documentation.
    this.dutyStart,
    /// Public API documentation.
    this.dutyEnd,
    /// Public API documentation.
    this.departureAirport,
    /// Public API documentation.
    this.arrivalAirport,
    /// Public API documentation.
    this.positioningDepartureAirport,
    /// Public API documentation.
    this.positioningArrivalAirport,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final TimeLine timeLine;
  /// Public API documentation.
  final Flight? flight;
  /// Public API documentation.
  final Aircraft? aircraft;
  /// Public API documentation.
  final AircraftType? aircraftType;
  /// Public API documentation.
  final Positioning? positioning;
  /// Public API documentation.
  final SimulatorTraining? simulatorTraining;
  /// Public API documentation.
  final DutyPeriod? dutyStart;
  /// Public API documentation.
  final DutyPeriod? dutyEnd;
  /// Public API documentation.
  final Airport? departureAirport;
  /// Public API documentation.
  final Airport? arrivalAirport;
  /// Public API documentation.
  final Airport? positioningDepartureAirport;
  /// Public API documentation.
  final Airport? positioningArrivalAirport;

  /// Public API documentation.
  LogbookEventType get type {
    /// Public API documentation.
    if (flight != null) return LogbookEventType.flight;
    /// Public API documentation.
    if (positioning != null) return LogbookEventType.positioning;
    /// Public API documentation.
    if (simulatorTraining != null) return LogbookEventType.simulatorTraining;
    /// Public API documentation.
    if (dutyStart != null || dutyEnd != null) {
      return LogbookEventType.dutyPeriod;
    }
    return LogbookEventType.unknown;
  }

  /// Public API documentation.
  bool get isDutyStart => dutyStart != null;
  /// Public API documentation.
  bool get isDutyEnd => dutyEnd != null;
}

/// Public API documentation.
class DutyRangeInfo {
  /// Public API documentation.
  DutyRangeInfo({
    required this.dutyId,
    required this.start,
    required this.end,
    required this.isLocked,
  });

  /// Public API documentation.
  final int dutyId;
  /// Public API documentation.
  final DateTime start;
  /// Public API documentation.
  final DateTime end;
  /// Public API documentation.
  final bool isLocked;
}
