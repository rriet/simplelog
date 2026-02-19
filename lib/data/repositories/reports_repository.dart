import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/reports_models.dart';

class ReportsRepository {
  ReportsRepository(this._db);

  final AppDatabase _db;

  Future<ReportsData> load(ReportsQuery query) async {
    final depTimeLines = _db.alias(_db.timeLines, 'report_dep_tl');
    final depAirports = _db.alias(_db.airports, 'report_dep_airports');
    final arrAirports = _db.alias(_db.airports, 'report_arr_airports');
    final flightsQuery = _db.select(_db.flights).join([
      innerJoin(
        depTimeLines,
        depTimeLines.id.equalsExp(_db.flights.departureDateTimeId),
      ),
      innerJoin(_db.aircrafts, _db.aircrafts.id.equalsExp(_db.flights.aircraftId)),
      leftOuterJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
      leftOuterJoin(
        depAirports,
        depAirports.id.equalsExp(_db.flights.departureAirportId),
      ),
      leftOuterJoin(
        arrAirports,
        arrAirports.id.equalsExp(_db.flights.arrivalAirportId),
      ),
    ])
      ..where(depTimeLines.eventDateTime.isBiggerOrEqualValue(query.from))
      ..where(depTimeLines.eventDateTime.isSmallerOrEqualValue(query.to))
      ..orderBy([OrderingTerm.desc(depTimeLines.eventDateTime)]);

    final rows = await flightsQuery.get();
    final pilotNamesByFlight = await _fetchPilotNamesByFlight(
      rows.map((row) => row.readTable(_db.flights).id).toList(growable: false),
    );
    final flightData = rows.map((row) {
      final flight = row.readTable(_db.flights);
      final depTime = row.readTable(depTimeLines);
      final aircraft = row.readTable(_db.aircrafts);
      final type = row.readTableOrNull(_db.aircraftTypes);
      final depAirport = row.readTableOrNull(depAirports);
      final arrAirport = row.readTableOrNull(arrAirports);
      return _ReportFlightData(
        row: ReportsFlightRow(
          flightId: flight.id,
          departureDateTime: depTime.eventDateTime,
          registration: aircraft.registration,
          modelCode: type?.code ?? '',
          fromIcao: depAirport?.icao ?? '',
          toIcao: arrAirport?.icao ?? '',
          totalMinutes: flight.timeBlockMinutes,
        ),
        flight: flight,
        isSimulator: aircraft.isSimulator,
        isMultiPilot: type?.multiPilot == true,
        departureIcao: depAirport?.icao ?? '',
        departureIata: depAirport?.iata ?? '',
        departureCountry: depAirport?.country ?? '',
        aircraftTail: aircraft.registration,
        aircraftType: type?.code ?? '',
        pilotNames: pilotNamesByFlight[flight.id] ?? '',
      );
    }).toList(growable: false);

    final filteredFlightData = _applyFilters(
      flightData,
      query.filters,
      query.filterMatchMode,
    );
    final simulatorMinutes = await _sumSimulatorMinutes(
      from: query.from,
      to: query.to,
    );
    final flights = filteredFlightData.map((e) => e.row).toList(growable: false);

    var totals = _sumFlightData(filteredFlightData).copyWithSimulator(simulatorMinutes);
    if (query.includePreviousExperience) {
      totals = totals + await _sumPreviousExperience(query);
    }
    return ReportsData(totals: totals, flights: flights);
  }

  ReportsTotals _sumFlightData(List<_ReportFlightData> rows) {
    var totals = const ReportsTotals.zero();
    for (final row in rows) {
      final flight = row.flight;
      totals = totals +
          ReportsTotals(
            sectors: 1,
            takeoffsDay: flight.takeOffsDays,
            takeoffsNight: flight.takeOffsNight,
            landingsDay: flight.landingsDay,
            landingsNight: flight.landingsNight,
            ifrApproaches: flight.ifrApproaches,
            distanceNM: flight.distanceNM,
            totalMinutes: flight.timeBlockMinutes,
            nightMinutes: flight.timeNightMinutes,
            ifrMinutes: flight.timeIFRMinutes,
            simulatedInstrumentMinutes: flight.timeSimulatedInstrumentMinutes,
            picMinutes: flight.timePICMinutes,
            picusMinutes: flight.timePICUSMinutes,
            sicMinutes: flight.timeSICMinutes,
            dualMinutes: flight.timeDualMinutes,
            instructorMinutes: flight.timeInstructorMinutes,
            crossCountryMinutes: flight.timeCrossCountryMinutes,
            simulatorMinutes: 0,
            custom1Minutes: flight.timeCustom1Minutes,
            custom2Minutes: flight.timeCustom2Minutes,
            custom3Minutes: flight.timeCustom3Minutes,
            custom4Minutes: flight.timeCustom4Minutes,
            multiPilotMinutes: row.isMultiPilot ? flight.timeBlockMinutes : 0,
          );
    }
    return totals;
  }

  Future<Map<int, String>> _fetchPilotNamesByFlight(List<int> flightIds) async {
    if (flightIds.isEmpty) {
      return const {};
    }
    final rows = await (_db.select(_db.flightCrewAssignments).join([
      innerJoin(
        _db.crew,
        _db.crew.id.equalsExp(_db.flightCrewAssignments.crewId),
      ),
    ])
          ..where(_db.flightCrewAssignments.flightId.isIn(flightIds)))
        .get();

    final map = <int, List<String>>{};
    for (final row in rows) {
      final assignment = row.readTable(_db.flightCrewAssignments);
      final crew = row.readTable(_db.crew);
      map.putIfAbsent(assignment.flightId, () => <String>[]).add(crew.name);
    }
    return map.map(
      (key, value) => MapEntry(key, value.join(' ').toLowerCase()),
    );
  }

  List<_ReportFlightData> _applyFilters(
    List<_ReportFlightData> rows,
    List<ReportsFilterCondition> filters,
    ReportsFilterMatchMode mode,
  ) {
    if (filters.isEmpty) return rows;
    return rows.where((row) {
      final matches = filters.map((f) => _matchesFilter(row, f));
      if (mode == ReportsFilterMatchMode.all) {
        return matches.every((m) => m);
      }
      return matches.any((m) => m);
    }).toList(growable: false);
  }

  bool _matchesFilter(_ReportFlightData row, ReportsFilterCondition filter) {
    switch (filter.field.valueType) {
      case ReportsFilterValueType.text:
        final target = _textFieldValue(row, filter.field).toLowerCase();
        final value = (filter.textValue ?? '').trim().toLowerCase();
        if (value.isEmpty) return true;
        switch (filter.operator) {
          case ReportsFilterOperator.contains:
            return target.contains(value);
          case ReportsFilterOperator.startsWith:
            return target.startsWith(value);
          case ReportsFilterOperator.doesNotStartWith:
            return !target.startsWith(value);
          case ReportsFilterOperator.endsWith:
            return target.endsWith(value);
          case ReportsFilterOperator.doesNotEndWith:
            return !target.endsWith(value);
          case ReportsFilterOperator.isExactly:
            return target == value;
          case ReportsFilterOperator.isNot:
            return target != value;
          default:
            return false;
        }
      case ReportsFilterValueType.number:
      case ReportsFilterValueType.time:
        final target = _numberFieldValue(row, filter.field);
        final value = filter.numberValue;
        if (value == null) return true;
        switch (filter.operator) {
          case ReportsFilterOperator.greaterThan:
            return target > value;
          case ReportsFilterOperator.lessThan:
            return target < value;
          case ReportsFilterOperator.equals:
            return target == value;
          default:
            return false;
        }
      case ReportsFilterValueType.boolean:
        final target = _boolFieldValue(row, filter.field);
        switch (filter.operator) {
          case ReportsFilterOperator.isTrue:
            return target == true;
          case ReportsFilterOperator.isFalse:
            return target == false;
          default:
            return false;
        }
    }
  }

  String _textFieldValue(_ReportFlightData row, ReportsFilterField field) {
    switch (field) {
      case ReportsFilterField.departureIcao:
        return row.departureIcao;
      case ReportsFilterField.departureIata:
        return row.departureIata;
      case ReportsFilterField.departureCountry:
        return row.departureCountry;
      case ReportsFilterField.aircraftTail:
        return row.aircraftTail;
      case ReportsFilterField.aircraftType:
        return row.aircraftType;
      case ReportsFilterField.pilotName:
        return row.pilotNames;
      default:
        return '';
    }
  }

  int _numberFieldValue(_ReportFlightData row, ReportsFilterField field) {
    switch (field) {
      case ReportsFilterField.blockTime:
        return row.flight.timeBlockMinutes;
      case ReportsFilterField.nightTime:
        return row.flight.timeNightMinutes;
      case ReportsFilterField.distanceNm:
        return row.flight.distanceNM;
      default:
        return 0;
    }
  }

  bool _boolFieldValue(_ReportFlightData row, ReportsFilterField field) {
    switch (field) {
      case ReportsFilterField.isMultiPilot:
        return row.isMultiPilot;
      case ReportsFilterField.isSimulator:
        return row.isSimulator;
      default:
        return false;
    }
  }

  Future<int> _sumSimulatorMinutes({
    DateTime? from,
    DateTime? to,
  }) async {
    final startTimeLines = _db.alias(_db.timeLines, 'report_sim_tl');
    final minutesExpr = _db.simulatorTrainings.timeTotal.sum();
    final query = _db.selectOnly(_db.simulatorTrainings).join([
      innerJoin(
        startTimeLines,
        startTimeLines.id.equalsExp(_db.simulatorTrainings.startTimeLineId),
      ),
    ])
      ..addColumns([minutesExpr]);
    if (from != null) {
      query.where(startTimeLines.eventDateTime.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(startTimeLines.eventDateTime.isSmallerOrEqualValue(to));
    }
    final row = await query.getSingle();
    return row.read(minutesExpr) ?? 0;
  }

  Future<ReportsTotals> _sumPreviousExperience(ReportsQuery query) async {
    final rows = await _db.select(_db.previousExperiences).get();
    var totals = const ReportsTotals.zero();
    for (final exp in rows) {
      final includesStart = exp.dateTimeFirstFlight == null
          ? true
          : _isBeforeOrEqual(query.from, exp.dateTimeFirstFlight!);
      final includesEnd = exp.dateTimeLastFlight == null
          ? true
          : _isAfterOrEqual(query.to, exp.dateTimeLastFlight!);
      if (!includesStart || !includesEnd) {
        continue;
      }
      totals = totals +
          ReportsTotals(
            sectors: 0,
            takeoffsDay: exp.takeOffsDays,
            takeoffsNight: exp.takeOffsNight,
            landingsDay: exp.landingsDay,
            landingsNight: exp.landingsNight,
            ifrApproaches: exp.ifrApproaches,
            distanceNM: exp.distanceNM,
            totalMinutes: exp.timeBlockMinutes,
            nightMinutes: exp.timeNightMinutes,
            ifrMinutes: exp.timeIFRMinutes,
            simulatedInstrumentMinutes: exp.timeSimulatedInstrumentMinutes,
            picMinutes: exp.timePICMinutes,
            picusMinutes: exp.timePICUSMinutes,
            sicMinutes: exp.timeSICMinutes,
            dualMinutes: exp.timeDualMinutes,
            instructorMinutes: exp.timeInstructorMinutes,
            crossCountryMinutes: exp.timeCrossCountryMinutes,
            simulatorMinutes: exp.timeSimulatorMinutes,
            custom1Minutes: exp.timeCustom1Minutes,
            custom2Minutes: exp.timeCustom2Minutes,
            custom3Minutes: exp.timeCustom3Minutes,
            custom4Minutes: exp.timeCustom4Minutes,
            multiPilotMinutes: 0,
          );
    }
    return totals;
  }

  bool _isBeforeOrEqual(DateTime left, DateTime right) {
    return left.isBefore(right) || left.isAtSameMomentAs(right);
  }

  bool _isAfterOrEqual(DateTime left, DateTime right) {
    return left.isAfter(right) || left.isAtSameMomentAs(right);
  }
}

class _ReportFlightData {
  const _ReportFlightData({
    required this.row,
    required this.flight,
    required this.isSimulator,
    required this.isMultiPilot,
    required this.departureIcao,
    required this.departureIata,
    required this.departureCountry,
    required this.aircraftTail,
    required this.aircraftType,
    required this.pilotNames,
  });

  final ReportsFlightRow row;
  final Flight flight;
  final bool isSimulator;
  final bool isMultiPilot;
  final String departureIcao;
  final String departureIata;
  final String departureCountry;
  final String aircraftTail;
  final String aircraftType;
  final String pilotNames;
}

extension on ReportsTotals {
  ReportsTotals copyWithSimulator(int simulatorMinutes) {
    return ReportsTotals(
      sectors: sectors,
      takeoffsDay: takeoffsDay,
      takeoffsNight: takeoffsNight,
      landingsDay: landingsDay,
      landingsNight: landingsNight,
      ifrApproaches: ifrApproaches,
      distanceNM: distanceNM,
      totalMinutes: totalMinutes,
      nightMinutes: nightMinutes,
      ifrMinutes: ifrMinutes,
      simulatedInstrumentMinutes: simulatedInstrumentMinutes,
      picMinutes: picMinutes,
      picusMinutes: picusMinutes,
      sicMinutes: sicMinutes,
      dualMinutes: dualMinutes,
      instructorMinutes: instructorMinutes,
      crossCountryMinutes: crossCountryMinutes,
      simulatorMinutes: simulatorMinutes,
      custom1Minutes: custom1Minutes,
      custom2Minutes: custom2Minutes,
      custom3Minutes: custom3Minutes,
      custom4Minutes: custom4Minutes,
      multiPilotMinutes: multiPilotMinutes,
    );
  }
}
