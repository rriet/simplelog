import 'dart:async';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/logbook_entry.dart';
import '../models/logbook_filters.dart';

class LogbookRepository {
  LogbookRepository(this._db);

  final AppDatabase _db;

  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters) {
    if (filters.types.isEmpty) {
      return Stream.value(<LogbookEntry>[]);
    }

    final departureAirport = _db.alias(_db.airports, 'departure_airports');
    final arrivalAirport = _db.alias(_db.airports, 'arrival_airports');
    final positioningDeparture =
        _db.alias(_db.airports, 'positioning_departure');
    final positioningArrival =
        _db.alias(_db.airports, 'positioning_arrival');
    final dutyStart = _db.alias(_db.dutyPeriods, 'duty_start');
    final dutyEnd = _db.alias(_db.dutyPeriods, 'duty_end');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simAircraftType =
        _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final query = _buildQuery(
      filters,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );

    return query.watch().map((rows) {
      return _mapRows(
        rows,
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport,
        positioningDeparture: positioningDeparture,
        positioningArrival: positioningArrival,
        dutyStart: dutyStart,
        dutyEnd: dutyEnd,
        simAircraft: simAircraft,
        simAircraftType: simAircraftType,
      );
    });
  }

  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId) async {
    final departureAirport = _db.alias(_db.airports, 'departure_airports');
    final arrivalAirport = _db.alias(_db.airports, 'arrival_airports');
    final positioningDeparture =
        _db.alias(_db.airports, 'positioning_departure');
    final positioningArrival =
        _db.alias(_db.airports, 'positioning_arrival');
    final dutyStart = _db.alias(_db.dutyPeriods, 'duty_start');
    final dutyEnd = _db.alias(_db.dutyPeriods, 'duty_end');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simAircraftType =
        _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final query = _buildBaseQuery(
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    )..where(_db.timeLines.id.equals(timeLineId));

    final rows = await query.get();
    if (rows.isEmpty) return null;
    final mapped = _mapRows(
      rows,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );
    return mapped.isEmpty ? null : mapped.first;
  }

  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
  }) async {
    if (filters.types.isEmpty) {
      return <LogbookEntry>[];
    }
    final departureAirport = _db.alias(_db.airports, 'departure_airports');
    final arrivalAirport = _db.alias(_db.airports, 'arrival_airports');
    final positioningDeparture =
        _db.alias(_db.airports, 'positioning_departure');
    final positioningArrival =
        _db.alias(_db.airports, 'positioning_arrival');
    final dutyStart = _db.alias(_db.dutyPeriods, 'duty_start');
    final dutyEnd = _db.alias(_db.dutyPeriods, 'duty_end');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simAircraftType =
        _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final query = _buildQuery(
      filters,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );
    query.limit(limit, offset: offset);

    final rows = await query.get();
    return _mapRows(
      rows,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );
  }

  JoinedSelectStatement _buildBaseQuery({
    required $AirportsTable departureAirport,
    required $AirportsTable arrivalAirport,
    required $AirportsTable positioningDeparture,
    required $AirportsTable positioningArrival,
    required $DutyPeriodsTable dutyStart,
    required $DutyPeriodsTable dutyEnd,
    required $AircraftsTable simAircraft,
    required $AircraftTypesTable simAircraftType,
  }) {
    final query = _db.select(_db.timeLines).join([
      leftOuterJoin(
        _db.flights,
        _db.flights.departureDateTimeId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        _db.aircrafts,
        _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
      ),
      leftOuterJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
      leftOuterJoin(
        departureAirport,
        departureAirport.id.equalsExp(_db.flights.departureAirportId),
      ),
      leftOuterJoin(
        arrivalAirport,
        arrivalAirport.id.equalsExp(_db.flights.arrivalAirportId),
      ),
      leftOuterJoin(
        _db.positionings,
        _db.positionings.departureDateTimeId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        positioningDeparture,
        positioningDeparture.id.equalsExp(_db.positionings.departurePlaceId),
      ),
      leftOuterJoin(
        positioningArrival,
        positioningArrival.id.equalsExp(_db.positionings.arrivalPlaceId),
      ),
      leftOuterJoin(
        dutyStart,
        dutyStart.dutyStartTimeLineId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        dutyEnd,
        dutyEnd.dutyEndTimeLineId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        _db.simulatorTrainings,
        _db.simulatorTrainings.startTimeLineId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        simAircraft,
        simAircraft.id.equalsExp(_db.simulatorTrainings.aircraftId),
      ),
      leftOuterJoin(
        simAircraftType,
        simAircraftType.id.equalsExp(simAircraft.aircraftTypeId),
      ),
    ]);
    return query;
  }

  JoinedSelectStatement _buildQuery(
    LogbookFilters filters, {
    required $AirportsTable departureAirport,
    required $AirportsTable arrivalAirport,
    required $AirportsTable positioningDeparture,
    required $AirportsTable positioningArrival,
    required $DutyPeriodsTable dutyStart,
    required $DutyPeriodsTable dutyEnd,
    required $AircraftsTable simAircraft,
    required $AircraftTypesTable simAircraftType,
  }) {
    final query = _buildBaseQuery(
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );

    if (filters.from != null) {
      query.where(
        _db.timeLines.eventDateTime.isBiggerOrEqualValue(filters.from!),
      );
    }
    if (filters.to != null) {
      query.where(
        _db.timeLines.eventDateTime.isSmallerOrEqualValue(filters.to!),
      );
    }
    query.where(_typesPredicate(filters.types, dutyStart, dutyEnd));

    query.orderBy([
      OrderingTerm.desc(_db.timeLines.eventDateTime),
      OrderingTerm.desc(_db.timeLines.id),
    ]);

    return query;
  }

  List<LogbookEntry> _mapRows(
    List<TypedResult> rows, {
    required $AirportsTable departureAirport,
    required $AirportsTable arrivalAirport,
    required $AirportsTable positioningDeparture,
    required $AirportsTable positioningArrival,
    required $DutyPeriodsTable dutyStart,
    required $DutyPeriodsTable dutyEnd,
    required $AircraftsTable simAircraft,
    required $AircraftTypesTable simAircraftType,
  }) {
    return rows.map((row) {
      final flightAircraft = row.readTableOrNull(_db.aircrafts);
      final simAircraftRow = row.readTableOrNull(simAircraft);
      final flightType = row.readTableOrNull(_db.aircraftTypes);
      final simType = row.readTableOrNull(simAircraftType);
      final aircraft = flightAircraft ?? simAircraftRow;
      final aircraftType = flightType ?? simType;
      return LogbookEntry(
        timeLine: row.readTable(_db.timeLines),
        flight: row.readTableOrNull(_db.flights),
        aircraft: aircraft,
        aircraftType: aircraftType,
        positioning: row.readTableOrNull(_db.positionings),
        simulatorTraining: row.readTableOrNull(_db.simulatorTrainings),
        dutyStart: row.readTableOrNull(dutyStart),
        dutyEnd: row.readTableOrNull(dutyEnd),
        departureAirport: row.readTableOrNull(departureAirport),
        arrivalAirport: row.readTableOrNull(arrivalAirport),
        positioningDepartureAirport:
            row.readTableOrNull(positioningDeparture),
        positioningArrivalAirport: row.readTableOrNull(positioningArrival),
      );
    }).toList();
  }

  Expression<bool> _typesPredicate(
    Set<LogbookEventType> types,
    $DutyPeriodsTable dutyStart,
    $DutyPeriodsTable dutyEnd,
  ) {
    final clauses = <Expression<bool>>[];
    if (types.contains(LogbookEventType.flight)) {
      clauses.add(_db.flights.id.isNotNull());
    }
    if (types.contains(LogbookEventType.positioning)) {
      clauses.add(_db.positionings.id.isNotNull());
    }
    if (types.contains(LogbookEventType.simulatorTraining)) {
      clauses.add(_db.simulatorTrainings.id.isNotNull());
    }
    if (types.contains(LogbookEventType.dutyPeriod)) {
      clauses.add(dutyStart.id.isNotNull() | dutyEnd.id.isNotNull());
    }
    return clauses.reduce((value, element) => value | element);
  }

  Future<DateTime?> fetchFirstEventDate() async {
    final row = await (_db.select(_db.timeLines)
          ..orderBy(
            [
              (t) => OrderingTerm.asc(t.eventDateTime),
            ],
          )
          ..limit(1))
        .getSingleOrNull();
    return row?.eventDateTime;
  }
}
