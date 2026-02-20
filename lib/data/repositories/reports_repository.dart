import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/reports_models.dart';

class ReportsRepository {
  ReportsRepository(this._db);

  final AppDatabase _db;

  Future<ReportsTotals> loadQuickTotals({
    required DateTime from,
    required DateTime to,
    required bool includePreviousExperience,
  }) async {
    final depTimeLines = _db.alias(_db.timeLines, 'quick_dep_tl');
    final sectorsExpr = _db.flights.id.count();
    final takeoffDayExpr = _db.flights.takeOffsDays.sum();
    final takeoffNightExpr = _db.flights.takeOffsNight.sum();
    final landingDayExpr = _db.flights.landingsDay.sum();
    final landingNightExpr = _db.flights.landingsNight.sum();
    final ifrApproachesExpr = _db.flights.ifrApproaches.sum();
    final distanceExpr = _db.flights.distanceNM.sum();
    final totalExpr = _db.flights.timeBlockMinutes.sum();
    final nightExpr = _db.flights.timeNightMinutes.sum();
    final ifrExpr = _db.flights.timeIFRMinutes.sum();
    final simInstExpr = _db.flights.timeSimulatedInstrumentMinutes.sum();
    final picExpr = _db.flights.timePICMinutes.sum();
    final picusExpr = _db.flights.timePICUSMinutes.sum();
    final sicExpr = _db.flights.timeSICMinutes.sum();
    final dualExpr = _db.flights.timeDualMinutes.sum();
    final instructorExpr = _db.flights.timeInstructorMinutes.sum();
    final xcExpr = _db.flights.timeCrossCountryMinutes.sum();
    final custom1Expr = _db.flights.timeCustom1Minutes.sum();
    final custom2Expr = _db.flights.timeCustom2Minutes.sum();
    final custom3Expr = _db.flights.timeCustom3Minutes.sum();
    final custom4Expr = _db.flights.timeCustom4Minutes.sum();

    final query = _db.selectOnly(_db.flights).join([
      innerJoin(
        depTimeLines,
        depTimeLines.id.equalsExp(_db.flights.departureDateTimeId),
      ),
      innerJoin(_db.aircrafts, _db.aircrafts.id.equalsExp(_db.flights.aircraftId)),
      leftOuterJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
    ])
      ..where(depTimeLines.eventDateTime.isBiggerOrEqualValue(from))
      ..where(depTimeLines.eventDateTime.isSmallerOrEqualValue(to))
      ..where(_db.aircrafts.isSimulator.equals(false))
      ..addColumns([
        sectorsExpr,
        takeoffDayExpr,
        takeoffNightExpr,
        landingDayExpr,
        landingNightExpr,
        ifrApproachesExpr,
        distanceExpr,
        totalExpr,
        nightExpr,
        ifrExpr,
        simInstExpr,
        picExpr,
        picusExpr,
        sicExpr,
        dualExpr,
        instructorExpr,
        xcExpr,
        custom1Expr,
        custom2Expr,
        custom3Expr,
        custom4Expr,
      ]);

    final row = await query.getSingle();
    var totals = ReportsTotals(
      sectors: row.read(sectorsExpr) ?? 0,
      takeoffsDay: row.read(takeoffDayExpr) ?? 0,
      takeoffsNight: row.read(takeoffNightExpr) ?? 0,
      landingsDay: row.read(landingDayExpr) ?? 0,
      landingsNight: row.read(landingNightExpr) ?? 0,
      ifrApproaches: row.read(ifrApproachesExpr) ?? 0,
      distanceNM: row.read(distanceExpr) ?? 0,
      totalMinutes: row.read(totalExpr) ?? 0,
      nightMinutes: row.read(nightExpr) ?? 0,
      ifrMinutes: row.read(ifrExpr) ?? 0,
      simulatedInstrumentMinutes: row.read(simInstExpr) ?? 0,
      picMinutes: row.read(picExpr) ?? 0,
      picusMinutes: row.read(picusExpr) ?? 0,
      sicMinutes: row.read(sicExpr) ?? 0,
      dualMinutes: row.read(dualExpr) ?? 0,
      instructorMinutes: row.read(instructorExpr) ?? 0,
      crossCountryMinutes: row.read(xcExpr) ?? 0,
      simulatorMinutes: 0,
      dutyMinutes: 0,
      custom1Minutes: row.read(custom1Expr) ?? 0,
      custom2Minutes: row.read(custom2Expr) ?? 0,
      custom3Minutes: row.read(custom3Expr) ?? 0,
      custom4Minutes: row.read(custom4Expr) ?? 0,
      multiPilotMinutes: 0,
    );

    final simulatorMinutes = await _sumSimulatorMinutes(from: from, to: to);
    final dutyMinutes = await _sumDutyMinutes(from: from, to: to);
    totals = totals.copyWithExtraTimes(
      simulatorMinutes: simulatorMinutes,
      dutyMinutes: dutyMinutes,
    );
    if (includePreviousExperience) {
      totals = totals +
          await _sumPreviousExperience(
            ReportsQuery(
              from: from,
              to: to,
              includePreviousExperience: includePreviousExperience,
              filterMatchMode: ReportsFilterMatchMode.all,
              filters: const [],
            ),
          );
    }
    return totals;
  }

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
          modelFamily: type?.family ?? '',
          fromIcao: depAirport?.icao ?? '',
          toIcao: arrAirport?.icao ?? '',
          fromLatitude: depAirport?.latitude,
          fromLongitude: depAirport?.longitude,
          toLatitude: arrAirport?.latitude,
          toLongitude: arrAirport?.longitude,
          totalMinutes: flight.timeBlockMinutes,
          picMinutes: flight.timePICMinutes,
          picusMinutes: flight.timePICUSMinutes,
          sicMinutes: flight.timeSICMinutes,
          dualMinutes: flight.timeDualMinutes,
          ifrMinutes: flight.timeIFRMinutes,
          instrumentMinutes:
              flight.timeInstrumentMinutes + flight.timeSimulatedInstrumentMinutes,
          nightMinutes: flight.timeNightMinutes,
          landings: flight.landingsDay + flight.landingsNight,
        ),
        flight: flight,
        isSimulator: aircraft.isSimulator,
        isMultiPilot: type?.multiPilot == true,
        departureIcao: depAirport?.icao ?? '',
        departureIata: depAirport?.iata ?? '',
        departureName: depAirport?.name ?? '',
        departureCity: depAirport?.city ?? '',
        departureCountry: depAirport?.country ?? '',
        arrivalIcao: arrAirport?.icao ?? '',
        arrivalIata: arrAirport?.iata ?? '',
        arrivalName: arrAirport?.name ?? '',
        arrivalCity: arrAirport?.city ?? '',
        arrivalCountry: arrAirport?.country ?? '',
        aircraftTail: aircraft.registration,
        aircraftTypeCode: type?.code ?? '',
        aircraftTypeFamily: type?.family ?? '',
        aircraftTypeName: type?.longName ?? '',
        pilotNames: pilotNamesByFlight[flight.id] ?? '',
        approachType: flight.approachType,
        remarks: flight.remarks,
        notes: flight.notes,
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
    final dutyMinutes = await _sumDutyMinutes(
      from: query.from,
      to: query.to,
    );
    final flights = filteredFlightData.map((e) => e.row).toList(growable: false);

    var totals = _sumFlightData(filteredFlightData).copyWithExtraTimes(
      simulatorMinutes: simulatorMinutes,
      dutyMinutes: dutyMinutes,
    );
    if (query.includePreviousExperience) {
      totals = totals + await _sumPreviousExperience(query);
    }
    return ReportsData(totals: totals, flights: flights);
  }

  ReportsTotals _sumFlightData(List<_ReportFlightData> rows) {
    var totals = const ReportsTotals.zero();
    for (final row in rows) {
      final flight = row.flight;
      if (row.isSimulator) {
        totals = totals +
            ReportsTotals(
              sectors: 0,
              takeoffsDay: 0,
              takeoffsNight: 0,
              landingsDay: 0,
              landingsNight: 0,
              ifrApproaches: 0,
              distanceNM: 0,
              totalMinutes: 0,
              nightMinutes: 0,
              ifrMinutes: 0,
              simulatedInstrumentMinutes: 0,
              picMinutes: 0,
              picusMinutes: 0,
              sicMinutes: 0,
              dualMinutes: 0,
              instructorMinutes: 0,
              crossCountryMinutes: 0,
              simulatorMinutes: flight.timeBlockMinutes,
              dutyMinutes: 0,
              custom1Minutes: 0,
              custom2Minutes: 0,
              custom3Minutes: 0,
              custom4Minutes: 0,
              multiPilotMinutes: 0,
            );
        continue;
      }
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
            dutyMinutes: 0,
            custom1Minutes: flight.timeCustom1Minutes,
            custom2Minutes: flight.timeCustom2Minutes,
            custom3Minutes: flight.timeCustom3Minutes,
            custom4Minutes: flight.timeCustom4Minutes,
            multiPilotMinutes:
                (!row.isSimulator && row.isMultiPilot) ? flight.timeBlockMinutes : 0,
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
      case ReportsFilterField.departureName:
        return row.departureName;
      case ReportsFilterField.departureCity:
        return row.departureCity;
      case ReportsFilterField.departureCountry:
        return row.departureCountry;
      case ReportsFilterField.arrivalIcao:
        return row.arrivalIcao;
      case ReportsFilterField.arrivalIata:
        return row.arrivalIata;
      case ReportsFilterField.arrivalName:
        return row.arrivalName;
      case ReportsFilterField.arrivalCity:
        return row.arrivalCity;
      case ReportsFilterField.arrivalCountry:
        return row.arrivalCountry;
      case ReportsFilterField.aircraftTail:
        return row.aircraftTail;
      case ReportsFilterField.aircraftTypeCode:
        return row.aircraftTypeCode;
      case ReportsFilterField.aircraftTypeFamily:
        return row.aircraftTypeFamily;
      case ReportsFilterField.aircraftTypeName:
        return row.aircraftTypeName;
      case ReportsFilterField.pilotName:
        return row.pilotNames;
      case ReportsFilterField.approachType:
        return row.approachType;
      case ReportsFilterField.remarks:
        return row.remarks;
      case ReportsFilterField.notes:
        return row.notes;
      default:
        return '';
    }
  }

  int _numberFieldValue(_ReportFlightData row, ReportsFilterField field) {
    switch (field) {
      case ReportsFilterField.blockTime:
      case ReportsFilterField.totalTime:
        return row.flight.timeBlockMinutes;
      case ReportsFilterField.flightTime:
        return row.flight.timeFlightMinutes;
      case ReportsFilterField.nightTime:
        return row.flight.timeNightMinutes;
      case ReportsFilterField.ifrTime:
        return row.flight.timeIFRMinutes;
      case ReportsFilterField.instrumentTime:
        return row.flight.timeInstrumentMinutes;
      case ReportsFilterField.simulatedInstrumentTime:
        return row.flight.timeSimulatedInstrumentMinutes;
      case ReportsFilterField.picTime:
        return row.flight.timePICMinutes;
      case ReportsFilterField.picusTime:
        return row.flight.timePICUSMinutes;
      case ReportsFilterField.sicTime:
        return row.flight.timeSICMinutes;
      case ReportsFilterField.dualTime:
        return row.flight.timeDualMinutes;
      case ReportsFilterField.instructorTime:
        return row.flight.timeInstructorMinutes;
      case ReportsFilterField.crossCountryTime:
        return row.flight.timeCrossCountryMinutes;
      case ReportsFilterField.custom1Time:
        return row.flight.timeCustom1Minutes;
      case ReportsFilterField.custom2Time:
        return row.flight.timeCustom2Minutes;
      case ReportsFilterField.custom3Time:
        return row.flight.timeCustom3Minutes;
      case ReportsFilterField.custom4Time:
        return row.flight.timeCustom4Minutes;
      case ReportsFilterField.distanceNm:
        return row.flight.distanceNM;
      case ReportsFilterField.takeoffs:
        return row.flight.takeOffsDays + row.flight.takeOffsNight;
      case ReportsFilterField.takeoffsDay:
        return row.flight.takeOffsDays;
      case ReportsFilterField.takeoffsNight:
        return row.flight.takeOffsNight;
      case ReportsFilterField.landings:
        return row.flight.landingsDay + row.flight.landingsNight;
      case ReportsFilterField.landingsDay:
        return row.flight.landingsDay;
      case ReportsFilterField.landingsNight:
        return row.flight.landingsNight;
      case ReportsFilterField.ifrApproaches:
        return row.flight.ifrApproaches;
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

  Future<int> _sumDutyMinutes({
    DateTime? from,
    DateTime? to,
  }) async {
    final startTimeLines = _db.alias(_db.timeLines, 'report_duty_tl');
    final minutesExpr = _db.dutyPeriods.timeDutyMinutes.sum();
    final query = _db.selectOnly(_db.dutyPeriods).join([
      innerJoin(
        startTimeLines,
        startTimeLines.id.equalsExp(_db.dutyPeriods.dutyStartTimeLineId),
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
            dutyMinutes: 0,
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
    required this.departureName,
    required this.departureCity,
    required this.departureCountry,
    required this.arrivalIcao,
    required this.arrivalIata,
    required this.arrivalName,
    required this.arrivalCity,
    required this.arrivalCountry,
    required this.aircraftTail,
    required this.aircraftTypeCode,
    required this.aircraftTypeFamily,
    required this.aircraftTypeName,
    required this.pilotNames,
    required this.approachType,
    required this.remarks,
    required this.notes,
  });

  final ReportsFlightRow row;
  final Flight flight;
  final bool isSimulator;
  final bool isMultiPilot;
  final String departureIcao;
  final String departureIata;
  final String departureName;
  final String departureCity;
  final String departureCountry;
  final String arrivalIcao;
  final String arrivalIata;
  final String arrivalName;
  final String arrivalCity;
  final String arrivalCountry;
  final String aircraftTail;
  final String aircraftTypeCode;
  final String aircraftTypeFamily;
  final String aircraftTypeName;
  final String pilotNames;
  final String approachType;
  final String remarks;
  final String notes;
}

extension on ReportsTotals {
  ReportsTotals copyWithExtraTimes({
    required int simulatorMinutes,
    required int dutyMinutes,
  }) {
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
      dutyMinutes: dutyMinutes,
      custom1Minutes: custom1Minutes,
      custom2Minutes: custom2Minutes,
      custom3Minutes: custom3Minutes,
      custom4Minutes: custom4Minutes,
      multiPilotMinutes: multiPilotMinutes,
    );
  }
}
