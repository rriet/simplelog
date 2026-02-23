import 'package:intl/intl.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';

/// Public API documentation.
class SimpleLogCsvExporter {
  /// Public API documentation.
  SimpleLogCsvExporter(this.db);

  /// Public API documentation.
  final AppDatabase db;

  static const List<String> _headers = [
    'Date (DD/MM/YYYY)',
    'Departure Time (HH:MM)',
    'Arrival Time (HH:MM)',
    'Departure Epoch',
    'Arrival Epoch',
    'Departure Icao',
    'Departure Iata',
    'Departure Airport Name',
    'Departure City',
    'Departure Country',
    'Departure Latitude',
    'Departure Longitude',
    'Arrival Icao',
    'Arrival Iata',
    'Arrival Airport Name',
    'Arrival City',
    'Arrival Country',
    'Arrival Latitude',
    'Arrival Longitude',
    'Aircraft Registration',
    'Aircraft MTOW',
    'Aircraft Simulator',
    'Model Make & Model',
    'Model Group',
    'Model Engine Type',
    'Model MTOW',
    'Model Multi Engine',
    'Model Multi Pilot',
    'Model EFIS',
    'Model Seaplane',
    'PIC Name',
    'PIC Email',
    'PIC Phone',
    'PIC Comments',
    'SIC Name',
    'SIC Email',
    'SIC Phone',
    'SIC Comments',
    'Pilot Function',
    'Remarks',
    'Private notes',
    'Takeoff day',
    'Takeoff night',
    'Landing day',
    'Landing night',
    'IFR Approaches',
    'Approach Type',
    'IFR Minutes',
    'Simulated Instrument Minutes',
    'Night Minutes',
    'Corss country Minutes',
    'PIC Minutes',
    'PICUS Minutes',
    'SIC Minutes',
    'Dual Minutes',
    'Instructor Minutes',
    'Simulator Minutes',
    'Custom Time 1 Minutes',
    'Custom Time 2 Minutes',
    'Custom Time 3 Minutes',
    'Custom Time 4 Minutes',
    /// Public API documentation.
    'Total Minutes',
  ];

  /// Public API documentation.
  Future<String> exportFlightsAndSimulatorsCsv() async {
    final flights = await db.select(db.flights).get();
    final simulators = await db.select(db.simulatorTrainings).get();
    final aircrafts = await db.select(db.aircrafts).get();
    final aircraftTypes = await db.select(db.aircraftTypes).get();
    final airports = await db.select(db.airports).get();
    final timeLines = await db.select(db.timeLines).get();
    final crews = await db.select(db.crew).get();
    final flightAssignments = await db.select(db.flightCrewAssignments).get();
    final simulatorAssignments = await db
        .select(db.simulatorCrewAssignments)
        .get();

    final aircraftById = {for (final row in aircrafts) row.id: row};
    final typeById = {for (final row in aircraftTypes) row.id: row};
    final airportById = {for (final row in airports) row.id: row};
    final timelineById = {for (final row in timeLines) row.id: row};
    final crewById = {for (final row in crews) row.id: row};

    final flightAssignmentsByFlight = <int, List<FlightCrewAssignment>>{};
    for (final assignment in flightAssignments) {
      flightAssignmentsByFlight
          .putIfAbsent(assignment.flightId, () => <FlightCrewAssignment>[])
          .add(assignment);
    }
    final simulatorAssignmentsBySim = <int, List<SimulatorCrewAssignment>>{};
    for (final assignment in simulatorAssignments) {
      simulatorAssignmentsBySim
          .putIfAbsent(
            assignment.simulatorId,
            () => <SimulatorCrewAssignment>[],
          )
          .add(assignment);
    }

    final rows = <_ExportRow>[];
    for (final flight in flights) {
      final departureTimeLine = timelineById[flight.departureDateTimeId];
      if (departureTimeLine == null) continue;
      final departureDateTime = _asUtcLiteral(departureTimeLine.eventDateTime);
      final arrivalDateTime = _asUtcLiteral(
        flight.arrivalDateTime ?? departureDateTime,
      );
      final aircraft = aircraftById[flight.aircraftId];
      if (aircraft == null) continue;
      final type = typeById[aircraft.aircraftTypeId];
      final depAirport = airportById[flight.departureAirportId];
      final arrAirport = airportById[flight.arrivalAirportId];
      final crewSet = _pickPicAndSic(
        flightAssignmentsByFlight[flight.id] ?? const [],
        crewById,
      );

      rows.add(
        _ExportRow(
          sortDateTime: departureDateTime,
          sortTimelineId: departureTimeLine.id,
          values: _headers
              .map((header) {
                switch (header) {
                  case 'Date (DD/MM/YYYY)':
                    return DateFormat('dd/MM/yyyy').format(departureDateTime);
                  case 'Departure Time (HH:MM)':
                    return DateFormat('HH:mm').format(departureDateTime);
                  case 'Arrival Time (HH:MM)':
                    return flight.arrivalDateTime == null
                        ? '00:00'
                        : DateFormat('HH:mm').format(arrivalDateTime);
                  case 'Departure Epoch':
                    return (departureDateTime.millisecondsSinceEpoch ~/ 1000)
                        .toString();
                  case 'Arrival Epoch':
                    return (arrivalDateTime.millisecondsSinceEpoch ~/ 1000)
                        .toString();
                  case 'Departure Icao':
                    return depAirport?.icao ?? '';
                  case 'Departure Iata':
                    return depAirport?.iata ?? '';
                  case 'Departure Airport Name':
                    return depAirport?.name ?? '';
                  case 'Departure City':
                    return depAirport?.city ?? '';
                  case 'Departure Country':
                    return depAirport?.country ?? '';
                  case 'Departure Latitude':
                    return depAirport == null
                        ? ''
                        : depAirport.latitude.toString();
                  case 'Departure Longitude':
                    return depAirport == null
                        ? ''
                        : depAirport.longitude.toString();
                  case 'Arrival Icao':
                    return arrAirport?.icao ?? '';
                  case 'Arrival Iata':
                    return arrAirport?.iata ?? '';
                  case 'Arrival Airport Name':
                    return arrAirport?.name ?? '';
                  case 'Arrival City':
                    return arrAirport?.city ?? '';
                  case 'Arrival Country':
                    return arrAirport?.country ?? '';
                  case 'Arrival Latitude':
                    return arrAirport == null
                        ? ''
                        : arrAirport.latitude.toString();
                  case 'Arrival Longitude':
                    return arrAirport == null
                        ? ''
                        : arrAirport.longitude.toString();
                  case 'Aircraft Registration':
                    return aircraft.registration;
                  case 'Aircraft MTOW':
                    return (aircraft.mtow ?? type?.mtow ?? 0).toString();
                  case 'Aircraft Simulator':
                    return aircraft.isSimulator.toString();
                  case 'Model Make & Model':
                    return type?.code ?? '';
                  case 'Model Group':
                    return type?.family ?? '';
                  case 'Model Engine Type':
                    return _engineTypeLabel(type?.engineType);
                  case 'Model MTOW':
                    return (type?.mtow ?? aircraft.mtow ?? 0).toString();
                  case 'Model Multi Engine':
                    return ((type?.engineCount ?? 1) > 1).toString();
                  case 'Model Multi Pilot':
                    return (type?.multiPilot ?? false).toString();
                  case 'Model EFIS':
                    return (type?.efis ?? false).toString();
                  case 'Model Seaplane':
                    return ((type?.category == AircraftCategory.seaplane) ||
                            (type?.category == AircraftCategory.amphibian))
                        .toString();
                  case 'PIC Name':
                    return crewSet.pic?.name ?? '';
                  case 'PIC Email':
                    return crewSet.pic?.email ?? '';
                  case 'PIC Phone':
                    return crewSet.pic?.phone ?? '';
                  case 'PIC Comments':
                    return crewSet.pic?.notes ?? '';
                  case 'SIC Name':
                    return crewSet.sic?.name ?? '';
                  case 'SIC Email':
                    return crewSet.sic?.email ?? '';
                  case 'SIC Phone':
                    return crewSet.sic?.phone ?? '';
                  case 'SIC Comments':
                    return crewSet.sic?.notes ?? '';
                  case 'Pilot Function':
                    return flight.pilotFunction;
                  case 'Remarks':
                    return flight.remarks;
                  case 'Private notes':
                    return flight.notes;
                  case 'Takeoff day':
                    return flight.takeOffsDays.toString();
                  case 'Takeoff night':
                    return flight.takeOffsNight.toString();
                  case 'Landing day':
                    return flight.landingsDay.toString();
                  case 'Landing night':
                    return flight.landingsNight.toString();
                  case 'IFR Approaches':
                    return flight.ifrApproaches.toString();
                  case 'Approach Type':
                    return flight.approachType;
                  case 'IFR Minutes':
                    return flight.timeIFRMinutes.toString();
                  case 'Simulated Instrument Minutes':
                    return flight.timeSimulatedInstrumentMinutes.toString();
                  case 'Night Minutes':
                    return flight.timeNightMinutes.toString();
                  case 'Corss country Minutes':
                    return flight.timeCrossCountryMinutes.toString();
                  case 'PIC Minutes':
                    return flight.timePICMinutes.toString();
                  case 'PICUS Minutes':
                    return flight.timePICUSMinutes.toString();
                  case 'SIC Minutes':
                    return flight.timeSICMinutes.toString();
                  case 'Dual Minutes':
                    return flight.timeDualMinutes.toString();
                  case 'Instructor Minutes':
                    return flight.timeInstructorMinutes.toString();
                  case 'Simulator Minutes':
                    return '0';
                  case 'Custom Time 1 Minutes':
                    return flight.timeCustom1Minutes.toString();
                  case 'Custom Time 2 Minutes':
                    return flight.timeCustom2Minutes.toString();
                  case 'Custom Time 3 Minutes':
                    return flight.timeCustom3Minutes.toString();
                  case 'Custom Time 4 Minutes':
                    return flight.timeCustom4Minutes.toString();
                  case 'Total Minutes':
                    return flight.timeBlockMinutes.toString();
                  default:
                    return '';
                }
              })
              .toList(growable: false),
        ),
      );
    }

    for (final simulator in simulators) {
      final startTimeLine = timelineById[simulator.startTimeLineId];
      if (startTimeLine == null) continue;
      final startDateTime = _asUtcLiteral(startTimeLine.eventDateTime);
      final endDateTime = _asUtcLiteral(simulator.endDateTime ?? startDateTime);
      final aircraft = aircraftById[simulator.aircraftId];
      if (aircraft == null) continue;
      final type = typeById[aircraft.aircraftTypeId];
      final crewSet = _pickPicAndSicFromSimulator(
        simulatorAssignmentsBySim[simulator.id] ?? const [],
        crewById,
      );

      rows.add(
        _ExportRow(
          sortDateTime: startDateTime,
          sortTimelineId: startTimeLine.id,
          values: _headers
              .map((header) {
                switch (header) {
                  case 'Date (DD/MM/YYYY)':
                    return DateFormat('dd/MM/yyyy').format(startDateTime);
                  case 'Departure Time (HH:MM)':
                    return DateFormat('HH:mm').format(startDateTime);
                  case 'Arrival Time (HH:MM)':
                    return DateFormat('HH:mm').format(endDateTime);
                  case 'Departure Epoch':
                    return (startDateTime.millisecondsSinceEpoch ~/ 1000)
                        .toString();
                  case 'Arrival Epoch':
                    return (endDateTime.millisecondsSinceEpoch ~/ 1000)
                        .toString();
                  case 'Aircraft Registration':
                    return aircraft.registration;
                  case 'Aircraft MTOW':
                    return (aircraft.mtow ?? type?.mtow ?? 0).toString();
                  case 'Aircraft Simulator':
                    return 'true';
                  case 'Model Make & Model':
                    return type?.code ?? '';
                  case 'Model Group':
                    return type?.family ?? '';
                  case 'Model Engine Type':
                    return _engineTypeLabel(type?.engineType);
                  case 'Model MTOW':
                    return (type?.mtow ?? aircraft.mtow ?? 0).toString();
                  case 'Model Multi Engine':
                    return ((type?.engineCount ?? 1) > 1).toString();
                  case 'Model Multi Pilot':
                    return (type?.multiPilot ?? false).toString();
                  case 'Model EFIS':
                    return (type?.efis ?? false).toString();
                  case 'Model Seaplane':
                    return ((type?.category == AircraftCategory.seaplane) ||
                            (type?.category == AircraftCategory.amphibian))
                        .toString();
                  case 'PIC Name':
                    return crewSet.pic?.name ?? '';
                  case 'PIC Email':
                    return crewSet.pic?.email ?? '';
                  case 'PIC Phone':
                    return crewSet.pic?.phone ?? '';
                  case 'PIC Comments':
                    return crewSet.pic?.notes ?? '';
                  case 'SIC Name':
                    return crewSet.sic?.name ?? '';
                  case 'SIC Email':
                    return crewSet.sic?.email ?? '';
                  case 'SIC Phone':
                    return crewSet.sic?.phone ?? '';
                  case 'SIC Comments':
                    return crewSet.sic?.notes ?? '';
                  case 'Pilot Function':
                    return '';
                  case 'Remarks':
                    return simulator.remarks;
                  case 'Private notes':
                    return simulator.notes;
                  case 'Simulator Minutes':
                    return simulator.timeTotal.toString();
                  case 'Total Minutes':
                    return '0';
                  default:
                    return '';
                }
              })
              .map((value) => value)
              .toList(growable: false),
        ),
      );
    }

    rows.sort((a, b) {
      final byDate = b.sortDateTime.compareTo(a.sortDateTime);
      if (byDate != 0) return byDate;
      return b.sortTimelineId.compareTo(a.sortTimelineId);
    });
    final buffer = StringBuffer()..writeln(_serializeCsvRow(_headers));
    for (final row in rows) {
      final normalized = row.values.length == _headers.length
          ? row.values
          : List<String>.generate(
              _headers.length,
              (index) => index < row.values.length ? row.values[index] : '',
            );
      buffer.writeln(_serializeCsvRow(normalized));
    }
    return buffer.toString();
  }

  _PicSicSet _pickPicAndSic(
    List<FlightCrewAssignment> assignments,
    Map<int, CrewData> crewById,
  ) {
    CrewData? pic;
    CrewData? sic;
    for (final assignment in assignments) {
      final crew = crewById[assignment.crewId];
      if (crew == null) continue;
      if (assignment.position == CrewPosition.pic && pic == null) {
        pic = crew;
      } else if (assignment.position == CrewPosition.sic && sic == null) {
        sic = crew;
      }
    }
    return _PicSicSet(pic: pic, sic: sic);
  }

  _PicSicSet _pickPicAndSicFromSimulator(
    List<SimulatorCrewAssignment> assignments,
    Map<int, CrewData> crewById,
  ) {
    CrewData? pic;
    CrewData? sic;
    for (final assignment in assignments) {
      final crew = crewById[assignment.crewId];
      if (crew == null) continue;
      if (assignment.position == CrewPosition.pic && pic == null) {
        pic = crew;
      } else if (assignment.position == CrewPosition.sic && sic == null) {
        sic = crew;
      }
    }
    return _PicSicSet(pic: pic, sic: sic);
  }

  String _serializeCsvRow(List<String> values) {
    return values.map(_escapeCsv).join(',');
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _engineTypeLabel(EngineType? engineType) {
    return switch (engineType) {
      EngineType.jet => 'Turbofan',
      EngineType.turboprop => 'Turboprop',
      EngineType.piston => 'Piston',
      EngineType.electric => 'Electric',
      EngineType.rocket => 'Rocket',
      EngineType.ultraLightAircraft => 'Ultralight',
      EngineType.drone => 'Drone',
      EngineType.glider => 'Glider',
      EngineType.airship => 'Airship',
      EngineType.balloon => 'Balloon',
      EngineType.paraplane => 'Paraplane',
      EngineType.unknown => '',
      null => '',
    };
  }

  /// Drift can return DateTime values with local timezone flag.
  /// Export requires UTC clock values exactly as stored in the logbook.
  DateTime _asUtcLiteral(DateTime value) {
    return DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: true,
    );
  }
}

class _ExportRow {
  const _ExportRow({
    required this.sortDateTime,
    required this.sortTimelineId,
    required this.values,
  });

  final DateTime sortDateTime;
  final int sortTimelineId;
  final List<String> values;
}

class _PicSicSet {
  const _PicSicSet({this.pic, this.sic});

  final CrewData? pic;
  final CrewData? sic;
}
