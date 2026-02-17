import '../database/app_database.dart';

enum LogbookEventType {
  flight,
  simulatorTraining,
  dutyPeriod,
  positioning,
  unknown,
}

class LogbookEntry {
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

  final TimeLine timeLine;
  final Flight? flight;
  final Aircraft? aircraft;
  final AircraftType? aircraftType;
  final Positioning? positioning;
  final SimulatorTraining? simulatorTraining;
  final DutyPeriod? dutyStart;
  final DutyPeriod? dutyEnd;
  final Airport? departureAirport;
  final Airport? arrivalAirport;
  final Airport? positioningDepartureAirport;
  final Airport? positioningArrivalAirport;

  LogbookEventType get type {
    if (flight != null) return LogbookEventType.flight;
    if (positioning != null) return LogbookEventType.positioning;
    if (simulatorTraining != null) return LogbookEventType.simulatorTraining;
    if (dutyStart != null || dutyEnd != null) {
      return LogbookEventType.dutyPeriod;
    }
    return LogbookEventType.unknown;
  }

  bool get isDutyStart => dutyStart != null;
  bool get isDutyEnd => dutyEnd != null;
}

class DutyRangeInfo {
  DutyRangeInfo({
    required this.dutyId,
    required this.start,
    required this.end,
    required this.isLocked,
  });

  final int dutyId;
  final DateTime start;
  final DateTime end;
  final bool isLocked;
}
