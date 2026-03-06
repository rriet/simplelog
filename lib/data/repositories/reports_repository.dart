import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/models/reports_models.dart';

/// Data-access service used by report screens and PDF generation.
class ReportsRepository {
  /// Creates a repository backed by the shared application database.
  ReportsRepository(this._db);

  /// Database dependency used to query flights, timelines and related rows.
  final AppDatabase _db;

  /// Loads aggregate totals for the selected range.
  ///
  /// When [includePreviousExperience] is true, matching previous-experience
  /// totals are added to the computed values.
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
    final flightExpr = _db.flights.timeFlightMinutes.sum();
    final nightExpr = _db.flights.timeNightMinutes.sum();
    final ifrExpr = _db.flights.timeIFRMinutes.sum();
    final instrumentExpr = _db.flights.timeInstrumentMinutes.sum();
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

    final query =
        _db.selectOnly(_db.flights).join([
            innerJoin(
              depTimeLines,
              depTimeLines.id.equalsExp(_db.flights.departureDateTimeId),
            ),
            innerJoin(
              _db.aircrafts,
              _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
            ),
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
            flightExpr,
            nightExpr,
            ifrExpr,
            instrumentExpr,
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
      flightMinutes: row.read(flightExpr) ?? 0,
      nightMinutes: row.read(nightExpr) ?? 0,
      ifrMinutes: row.read(ifrExpr) ?? 0,
      instrumentMinutes: row.read(instrumentExpr) ?? 0,
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
      totals =
          totals +
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

  /// Loads first and last flight dates within the requested range.
  Future<(DateTime?, DateTime?)> loadFlightDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final depTimeLines = _db.alias(_db.timeLines, 'range_dep_tl');
    final minExpr = depTimeLines.eventDateTime.min();
    final maxExpr = depTimeLines.eventDateTime.max();

    final query =
        _db.selectOnly(_db.flights).join([
            innerJoin(
              depTimeLines,
              depTimeLines.id.equalsExp(_db.flights.departureDateTimeId),
            ),
            innerJoin(
              _db.aircrafts,
              _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
            ),
          ])
          ..where(depTimeLines.eventDateTime.isBiggerOrEqualValue(from))
          ..where(depTimeLines.eventDateTime.isSmallerOrEqualValue(to))
          ..where(_db.aircrafts.isSimulator.equals(false))
          ..addColumns([minExpr, maxExpr]);

    final row = await query.getSingle();
    return (row.read(minExpr), row.read(maxExpr));
  }

  /// Loads first/last dates from Previous Experience that are fully included
  /// by the requested range.
  Future<(DateTime?, DateTime?)> loadPreviousExperienceDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _db.select(_db.previousExperiences).get();
    DateTime? first;
    DateTime? last;
    for (final exp in rows) {
      final includesStart =
          exp.dateTimeFirstFlight == null ||
          _isBeforeOrEqual(from, exp.dateTimeFirstFlight!);
      final includesEnd =
          exp.dateTimeLastFlight == null ||
          _isAfterOrEqual(to, exp.dateTimeLastFlight!);
      if (!includesStart || !includesEnd) {
        continue;
      }
      final expFirst = exp.dateTimeFirstFlight;
      final expLast = exp.dateTimeLastFlight;
      if (expFirst != null) {
        first = first == null || expFirst.isBefore(first) ? expFirst : first;
      }
      if (expLast != null) {
        last = last == null || expLast.isAfter(last) ? expLast : last;
      }
    }
    return (first, last);
  }

  /// Loads detailed report data for the given [query] and active filters.
  ///
  /// Set [includePilotNames] to false when caller does not need PIC/SIC names,
  /// which avoids additional lookup work.
  Future<ReportsData> load(
    ReportsQuery query, {
    bool includePilotNames = false,
  }) async {
    final depTimeLines = _db.alias(_db.timeLines, 'report_dep_tl');
    final depAirports = _db.alias(_db.airports, 'report_dep_airports');
    final arrAirports = _db.alias(_db.airports, 'report_arr_airports');
    final flightsQuery =
        _db.select(_db.flights).join([
            innerJoin(
              depTimeLines,
              depTimeLines.id.equalsExp(_db.flights.departureDateTimeId),
            ),
            innerJoin(
              _db.aircrafts,
              _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
            ),
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

    Expression<bool>? buildSqlFilterExpr(ReportsFilterCondition filter) {
      Expression<bool>? buildTextExpression(Expression<String> column) {
        final value = (filter.textValue ?? '').trim().toLowerCase();
        if (value.isEmpty) {
          return const Constant(true);
        }
        final normalized = column.lower();
        switch (filter.operator) {
          case ReportsFilterOperator.contains:
            return normalized.like('%$value%');
          case ReportsFilterOperator.startsWith:
            return normalized.like('$value%');
          case ReportsFilterOperator.endsWith:
            return normalized.like('%$value');
          case ReportsFilterOperator.isExactly:
            return normalized.equals(value);
          case ReportsFilterOperator.doesNotContain:
          case ReportsFilterOperator.doesNotStartWith:
          case ReportsFilterOperator.doesNotEndWith:
          case ReportsFilterOperator.isNot:
          case ReportsFilterOperator.greaterThan:
          case ReportsFilterOperator.lessThan:
          case ReportsFilterOperator.equals:
          case ReportsFilterOperator.isTrue:
          case ReportsFilterOperator.isFalse:
            return null;
        }
      }

      Expression<bool>? buildNumberExpression(Expression<int> column) {
        final value = filter.numberValue;
        if (value == null) {
          return const Constant(true);
        }
        switch (filter.operator) {
          case ReportsFilterOperator.greaterThan:
            return column.isBiggerThanValue(value);
          case ReportsFilterOperator.lessThan:
            return column.isSmallerThanValue(value);
          case ReportsFilterOperator.equals:
            return column.equals(value);
          case ReportsFilterOperator.contains:
          case ReportsFilterOperator.doesNotContain:
          case ReportsFilterOperator.startsWith:
          case ReportsFilterOperator.doesNotStartWith:
          case ReportsFilterOperator.endsWith:
          case ReportsFilterOperator.doesNotEndWith:
          case ReportsFilterOperator.isExactly:
          case ReportsFilterOperator.isNot:
          case ReportsFilterOperator.isTrue:
          case ReportsFilterOperator.isFalse:
            return null;
        }
      }

      switch (filter.field) {
        case ReportsFilterField.departureIcao:
          return buildTextExpression(depAirports.icao);
        case ReportsFilterField.arrivalIcao:
          return buildTextExpression(arrAirports.icao);
        case ReportsFilterField.aircraftTail:
          return buildTextExpression(_db.aircrafts.registration);
        case ReportsFilterField.aircraftTypeCode:
          return buildTextExpression(_db.aircraftTypes.code);
        case ReportsFilterField.aircraftTypeFamily:
          return buildTextExpression(_db.aircraftTypes.family);
        case ReportsFilterField.aircraftTypeName:
          return buildTextExpression(_db.aircraftTypes.longName);
        case ReportsFilterField.approachType:
          return buildTextExpression(_db.flights.approachType);
        case ReportsFilterField.remarks:
          return buildTextExpression(_db.flights.remarks);
        case ReportsFilterField.notes:
          return buildTextExpression(_db.flights.notes);
        case ReportsFilterField.blockTime:
        case ReportsFilterField.totalTime:
          return buildNumberExpression(_db.flights.timeBlockMinutes);
        case ReportsFilterField.flightTime:
          return buildNumberExpression(_db.flights.timeFlightMinutes);
        case ReportsFilterField.nightTime:
          return buildNumberExpression(_db.flights.timeNightMinutes);
        case ReportsFilterField.ifrTime:
          return buildNumberExpression(_db.flights.timeIFRMinutes);
        case ReportsFilterField.instrumentTime:
          return buildNumberExpression(_db.flights.timeInstrumentMinutes);
        case ReportsFilterField.simulatedInstrumentTime:
          return buildNumberExpression(
            _db.flights.timeSimulatedInstrumentMinutes,
          );
        case ReportsFilterField.picTime:
          return buildNumberExpression(_db.flights.timePICMinutes);
        case ReportsFilterField.picusTime:
          return buildNumberExpression(_db.flights.timePICUSMinutes);
        case ReportsFilterField.sicTime:
          return buildNumberExpression(_db.flights.timeSICMinutes);
        case ReportsFilterField.dualTime:
          return buildNumberExpression(_db.flights.timeDualMinutes);
        case ReportsFilterField.instructorTime:
          return buildNumberExpression(_db.flights.timeInstructorMinutes);
        case ReportsFilterField.crossCountryTime:
          return buildNumberExpression(_db.flights.timeCrossCountryMinutes);
        case ReportsFilterField.custom1Time:
          return buildNumberExpression(_db.flights.timeCustom1Minutes);
        case ReportsFilterField.custom2Time:
          return buildNumberExpression(_db.flights.timeCustom2Minutes);
        case ReportsFilterField.custom3Time:
          return buildNumberExpression(_db.flights.timeCustom3Minutes);
        case ReportsFilterField.custom4Time:
          return buildNumberExpression(_db.flights.timeCustom4Minutes);
        case ReportsFilterField.distanceNm:
          return buildNumberExpression(_db.flights.distanceNM);
        case ReportsFilterField.takeoffs:
          return buildNumberExpression(
            _db.flights.takeOffsDays + _db.flights.takeOffsNight,
          );
        case ReportsFilterField.takeoffsDay:
          return buildNumberExpression(_db.flights.takeOffsDays);
        case ReportsFilterField.takeoffsNight:
          return buildNumberExpression(_db.flights.takeOffsNight);
        case ReportsFilterField.landings:
          return buildNumberExpression(
            _db.flights.landingsDay + _db.flights.landingsNight,
          );
        case ReportsFilterField.landingsDay:
          return buildNumberExpression(_db.flights.landingsDay);
        case ReportsFilterField.landingsNight:
          return buildNumberExpression(_db.flights.landingsNight);
        case ReportsFilterField.ifrApproaches:
          return buildNumberExpression(_db.flights.ifrApproaches);
        case ReportsFilterField.isMultiPilot:
          switch (filter.operator) {
            case ReportsFilterOperator.isTrue:
              return _db.aircraftTypes.multiPilot.equals(true);
            case ReportsFilterOperator.isFalse:
              return _db.aircraftTypes.multiPilot.equals(false) |
                  _db.aircraftTypes.multiPilot.isNull();
            case ReportsFilterOperator.contains:
            case ReportsFilterOperator.doesNotContain:
            case ReportsFilterOperator.startsWith:
            case ReportsFilterOperator.doesNotStartWith:
            case ReportsFilterOperator.endsWith:
            case ReportsFilterOperator.doesNotEndWith:
            case ReportsFilterOperator.isExactly:
            case ReportsFilterOperator.isNot:
            case ReportsFilterOperator.greaterThan:
            case ReportsFilterOperator.lessThan:
            case ReportsFilterOperator.equals:
              return null;
          }
        case ReportsFilterField.isSimulator:
          switch (filter.operator) {
            case ReportsFilterOperator.isTrue:
              return _db.aircrafts.isSimulator.equals(true);
            case ReportsFilterOperator.isFalse:
              return _db.aircrafts.isSimulator.equals(false);
            case ReportsFilterOperator.contains:
            case ReportsFilterOperator.doesNotContain:
            case ReportsFilterOperator.startsWith:
            case ReportsFilterOperator.doesNotStartWith:
            case ReportsFilterOperator.endsWith:
            case ReportsFilterOperator.doesNotEndWith:
            case ReportsFilterOperator.isExactly:
            case ReportsFilterOperator.isNot:
            case ReportsFilterOperator.greaterThan:
            case ReportsFilterOperator.lessThan:
            case ReportsFilterOperator.equals:
              return null;
          }
        case ReportsFilterField.departureIata:
        case ReportsFilterField.departureName:
        case ReportsFilterField.departureCity:
        case ReportsFilterField.departureCountry:
        case ReportsFilterField.arrivalIata:
        case ReportsFilterField.arrivalName:
        case ReportsFilterField.arrivalCity:
        case ReportsFilterField.arrivalCountry:
          return null;
      }
    }

    var residualFilters = query.filters;
    if (query.filters.isNotEmpty) {
      final sqlExpressions = <Expression<bool>>[];
      final unsupportedFilters = <ReportsFilterCondition>[];
      for (final filter in query.filters) {
        final expression = buildSqlFilterExpr(filter);
        if (expression == null) {
          unsupportedFilters.add(filter);
          continue;
        }
        sqlExpressions.add(expression);
      }

      if (query.filterMatchMode == ReportsFilterMatchMode.all) {
        sqlExpressions.forEach(flightsQuery.where);
        residualFilters = unsupportedFilters;
      } else if (unsupportedFilters.isEmpty && sqlExpressions.isNotEmpty) {
        var combined = sqlExpressions.first;
        for (var i = 1; i < sqlExpressions.length; i++) {
          combined = combined | sqlExpressions[i];
        }
        flightsQuery.where(combined);
        residualFilters = const [];
      }
    }

    final rows = await flightsQuery.get();
    final pilotNamesByFlight = includePilotNames
        ? await _fetchPilotNamesByFlight(
            rows
                .map((row) => row.readTable(_db.flights).id)
                .toList(growable: false),
          )
        : const <int, _PilotNamesByRole>{};
    final flightData = rows
        .map((row) {
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
              pilotNames:
                  pilotNamesByFlight[flight.id]?.allOnBoardNamesLower ?? '',
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
                  flight.timeInstrumentMinutes +
                  flight.timeSimulatedInstrumentMinutes,
              nightMinutes: flight.timeNightMinutes,
              takeoffs: flight.takeOffsDays + flight.takeOffsNight,
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
            pilotNames:
                pilotNamesByFlight[flight.id]?.allOnBoardNamesLower ?? '',
            pilotPicNames: pilotNamesByFlight[flight.id]?.picNamesLower ?? '',
            pilotSicNames: pilotNamesByFlight[flight.id]?.sicNamesLower ?? '',
            pilotTraineeNames:
                pilotNamesByFlight[flight.id]?.traineeNamesLower ?? '',
            approachType: flight.approachType,
            remarks: flight.remarks,
            notes: flight.notes,
          );
        })
        .toList(growable: false);

    final filteredFlightData = residualFilters.isEmpty
        ? flightData
        : _applyFilters(
            flightData,
            residualFilters,
            query.filterMatchMode,
          );
    final simulatorMinutes = await _sumSimulatorMinutes(
      from: query.from,
      to: query.to,
    );
    final dutyMinutes = await _sumDutyMinutes(from: query.from, to: query.to);
    final flights = filteredFlightData
        .map((e) => e.row)
        .toList(growable: false);

    var totals = _sumFlightData(filteredFlightData).copyWithExtraTimes(
      simulatorMinutes: simulatorMinutes,
      dutyMinutes: dutyMinutes,
    );
    if (query.includePreviousExperience) {
      totals = totals + await _sumPreviousExperience(query);
    }
    return ReportsData(totals: totals, flights: flights);
  }

  /// Loads only flight rows needed by the Analyses tab.
  Future<List<ReportsFlightRow>> loadFlightsForAnalysis({
    required DateTime from,
    required DateTime to,
    bool includePilotNames = false,
  }) async {
    final depTimeLines = _db.alias(_db.timeLines, 'analysis_dep_tl');
    final depAirports = _db.alias(_db.airports, 'analysis_dep_airports');
    final arrAirports = _db.alias(_db.airports, 'analysis_arr_airports');
    final flightsQuery =
        _db.select(_db.flights).join([
            innerJoin(
              depTimeLines,
              depTimeLines.id.equalsExp(_db.flights.departureDateTimeId),
            ),
            innerJoin(
              _db.aircrafts,
              _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
            ),
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
          ..where(depTimeLines.eventDateTime.isBiggerOrEqualValue(from))
          ..where(depTimeLines.eventDateTime.isSmallerOrEqualValue(to))
          ..orderBy([OrderingTerm.desc(depTimeLines.eventDateTime)]);

    final rows = await flightsQuery.get();
    final pilotNamesByFlight = includePilotNames
        ? await _fetchPilotNamesByFlight(
            rows
                .map((row) => row.readTable(_db.flights).id)
                .toList(growable: false),
          )
        : const <int, _PilotNamesByRole>{};

    final flights = <ReportsFlightRow>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final flight = row.readTable(_db.flights);
      final depTime = row.readTable(depTimeLines);
      final aircraft = row.readTable(_db.aircrafts);
      final type = row.readTableOrNull(_db.aircraftTypes);
      final depAirport = row.readTableOrNull(depAirports);
      final arrAirport = row.readTableOrNull(arrAirports);
      flights.add(
        ReportsFlightRow(
          flightId: flight.id,
          departureDateTime: depTime.eventDateTime,
          registration: aircraft.registration,
          modelCode: type?.code ?? '',
          modelFamily: type?.family ?? '',
          fromIcao: depAirport?.icao ?? '',
          toIcao: arrAirport?.icao ?? '',
          pilotNames: pilotNamesByFlight[flight.id]?.allOnBoardNamesLower ?? '',
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
              flight.timeInstrumentMinutes +
              flight.timeSimulatedInstrumentMinutes,
          nightMinutes: flight.timeNightMinutes,
          takeoffs: flight.takeOffsDays + flight.takeOffsNight,
          landings: flight.landingsDay + flight.landingsNight,
        ),
      );
      if (i % 250 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    return flights;
  }

  /// Loads previous experience rows shaped for analysis grouping.
  Future<List<ReportsPreviousExperienceRow>> loadPreviousExperienceForAnalysis({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _db.select(_db.previousExperiences).join([
      innerJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.previousExperiences.aircraftTypeId),
      ),
    ]).get();

    return rows
        .map((row) {
          final exp = row.readTable(_db.previousExperiences);
          final type = row.readTable(_db.aircraftTypes);
          final includesStart =
              exp.dateTimeFirstFlight == null ||
              _isBeforeOrEqual(from, exp.dateTimeFirstFlight!);
          final includesEnd =
              exp.dateTimeLastFlight == null ||
              _isAfterOrEqual(to, exp.dateTimeLastFlight!);
          if (!includesStart || !includesEnd) {
            return null;
          }
          return ReportsPreviousExperienceRow(
            modelCode: type.code,
            modelFamily: type.family,
            totalMinutes: exp.timeBlockMinutes,
            picMinutes: exp.timePICMinutes,
            picusMinutes: exp.timePICUSMinutes,
            sicMinutes: exp.timeSICMinutes,
            dualMinutes: exp.timeDualMinutes,
            ifrMinutes: exp.timeIFRMinutes,
            instrumentMinutes:
                exp.timeInstrumentMinutes + exp.timeSimulatedInstrumentMinutes,
            nightMinutes: exp.timeNightMinutes,
            takeoffs: exp.takeOffsDays + exp.takeOffsNight,
            landings: exp.landingsDay + exp.landingsNight,
            operations: exp.flightCount,
            firstFlightUtc: exp.dateTimeFirstFlight,
            lastFlightUtc: exp.dateTimeLastFlight,
          );
        })
        .whereType<ReportsPreviousExperienceRow>()
        .toList(growable: false);
  }

  ReportsTotals _sumFlightData(List<_ReportFlightData> rows) {
    var totals = const ReportsTotals.zero();
    for (final row in rows) {
      final flight = row.flight;
      if (row.isSimulator) {
        totals =
            totals +
            ReportsTotals(
              sectors: 0,
              takeoffsDay: 0,
              takeoffsNight: 0,
              landingsDay: 0,
              landingsNight: 0,
              ifrApproaches: 0,
              distanceNM: 0,
              totalMinutes: 0,
              flightMinutes: 0,
              nightMinutes: 0,
              ifrMinutes: 0,
              instrumentMinutes: 0,
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
      totals =
          totals +
          ReportsTotals(
            sectors: 1,
            takeoffsDay: flight.takeOffsDays,
            takeoffsNight: flight.takeOffsNight,
            landingsDay: flight.landingsDay,
            landingsNight: flight.landingsNight,
            ifrApproaches: flight.ifrApproaches,
            distanceNM: flight.distanceNM,
            totalMinutes: flight.timeBlockMinutes,
            flightMinutes: flight.timeFlightMinutes,
            nightMinutes: flight.timeNightMinutes,
            ifrMinutes: flight.timeIFRMinutes,
            instrumentMinutes: flight.timeInstrumentMinutes,
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
            multiPilotMinutes: (!row.isSimulator && row.isMultiPilot)
                ? flight.timeBlockMinutes
                : 0,
          );
    }
    return totals;
  }

  Future<Map<int, _PilotNamesByRole>> _fetchPilotNamesByFlight(
    List<int> flightIds,
  ) async {
    if (flightIds.isEmpty) {
      return const {};
    }
    final rows = await (_db.select(_db.flightCrewAssignments).join([
      innerJoin(
        _db.crew,
        _db.crew.id.equalsExp(_db.flightCrewAssignments.crewId),
      ),
    ])..where(_db.flightCrewAssignments.flightId.isIn(flightIds))).get();

    final map = <int, _PilotNamesAccumulator>{};
    for (final row in rows) {
      final assignment = row.readTable(_db.flightCrewAssignments);
      final crew = row.readTable(_db.crew);
      map
          .putIfAbsent(assignment.flightId, _PilotNamesAccumulator.new)
          .add(assignment.position, crew.name);
    }
    return map.map(
      (key, value) => MapEntry(key, value.toResult()),
    );
  }

  List<_ReportFlightData> _applyFilters(
    List<_ReportFlightData> rows,
    List<ReportsFilterCondition> filters,
    ReportsFilterMatchMode mode,
  ) {
    if (filters.isEmpty) return rows;
    return rows
        .where((row) {
          final matches = filters.map((f) => _matchesFilter(row, f));
          if (mode == ReportsFilterMatchMode.all) {
            return matches.every((m) => m);
          }
          return matches.any((m) => m);
        })
        .toList(growable: false);
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
          case ReportsFilterOperator.doesNotContain:
            return !target.contains(value);
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
          case ReportsFilterOperator.greaterThan:
          case ReportsFilterOperator.lessThan:
          case ReportsFilterOperator.equals:
          case ReportsFilterOperator.isTrue:
          case ReportsFilterOperator.isFalse:
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
          case ReportsFilterOperator.contains:
          case ReportsFilterOperator.doesNotContain:
          case ReportsFilterOperator.startsWith:
          case ReportsFilterOperator.doesNotStartWith:
          case ReportsFilterOperator.endsWith:
          case ReportsFilterOperator.doesNotEndWith:
          case ReportsFilterOperator.isExactly:
          case ReportsFilterOperator.isNot:
          case ReportsFilterOperator.isTrue:
          case ReportsFilterOperator.isFalse:
            return false;
        }
      case ReportsFilterValueType.boolean:
        final target = _boolFieldValue(row, filter.field);
        switch (filter.operator) {
          case ReportsFilterOperator.isTrue:
            return target;
          case ReportsFilterOperator.isFalse:
            return !target;
          case ReportsFilterOperator.contains:
          case ReportsFilterOperator.doesNotContain:
          case ReportsFilterOperator.startsWith:
          case ReportsFilterOperator.doesNotStartWith:
          case ReportsFilterOperator.endsWith:
          case ReportsFilterOperator.doesNotEndWith:
          case ReportsFilterOperator.isExactly:
          case ReportsFilterOperator.isNot:
          case ReportsFilterOperator.greaterThan:
          case ReportsFilterOperator.lessThan:
          case ReportsFilterOperator.equals:
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
      case ReportsFilterField.approachType:
        return row.approachType;
      case ReportsFilterField.remarks:
        return row.remarks;
      case ReportsFilterField.notes:
        return row.notes;
      case ReportsFilterField.blockTime:
      case ReportsFilterField.flightTime:
      case ReportsFilterField.totalTime:
      case ReportsFilterField.nightTime:
      case ReportsFilterField.ifrTime:
      case ReportsFilterField.instrumentTime:
      case ReportsFilterField.simulatedInstrumentTime:
      case ReportsFilterField.picTime:
      case ReportsFilterField.picusTime:
      case ReportsFilterField.sicTime:
      case ReportsFilterField.dualTime:
      case ReportsFilterField.instructorTime:
      case ReportsFilterField.crossCountryTime:
      case ReportsFilterField.custom1Time:
      case ReportsFilterField.custom2Time:
      case ReportsFilterField.custom3Time:
      case ReportsFilterField.custom4Time:
      case ReportsFilterField.distanceNm:
      case ReportsFilterField.takeoffs:
      case ReportsFilterField.takeoffsDay:
      case ReportsFilterField.takeoffsNight:
      case ReportsFilterField.landings:
      case ReportsFilterField.landingsDay:
      case ReportsFilterField.landingsNight:
      case ReportsFilterField.ifrApproaches:
      case ReportsFilterField.isMultiPilot:
      case ReportsFilterField.isSimulator:
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
      case ReportsFilterField.departureIcao:
      case ReportsFilterField.departureIata:
      case ReportsFilterField.departureName:
      case ReportsFilterField.departureCity:
      case ReportsFilterField.departureCountry:
      case ReportsFilterField.arrivalIcao:
      case ReportsFilterField.arrivalIata:
      case ReportsFilterField.arrivalName:
      case ReportsFilterField.arrivalCity:
      case ReportsFilterField.arrivalCountry:
      case ReportsFilterField.aircraftTail:
      case ReportsFilterField.aircraftTypeCode:
      case ReportsFilterField.aircraftTypeFamily:
      case ReportsFilterField.aircraftTypeName:
      case ReportsFilterField.approachType:
      case ReportsFilterField.remarks:
      case ReportsFilterField.notes:
      case ReportsFilterField.isMultiPilot:
      case ReportsFilterField.isSimulator:
        return 0;
    }
  }

  bool _boolFieldValue(_ReportFlightData row, ReportsFilterField field) {
    switch (field) {
      case ReportsFilterField.isMultiPilot:
        return row.isMultiPilot;
      case ReportsFilterField.isSimulator:
        return row.isSimulator;
      case ReportsFilterField.departureIcao:
      case ReportsFilterField.departureIata:
      case ReportsFilterField.departureName:
      case ReportsFilterField.departureCity:
      case ReportsFilterField.departureCountry:
      case ReportsFilterField.arrivalIcao:
      case ReportsFilterField.arrivalIata:
      case ReportsFilterField.arrivalName:
      case ReportsFilterField.arrivalCity:
      case ReportsFilterField.arrivalCountry:
      case ReportsFilterField.aircraftTail:
      case ReportsFilterField.aircraftTypeCode:
      case ReportsFilterField.aircraftTypeFamily:
      case ReportsFilterField.aircraftTypeName:
      case ReportsFilterField.approachType:
      case ReportsFilterField.remarks:
      case ReportsFilterField.notes:
      case ReportsFilterField.blockTime:
      case ReportsFilterField.flightTime:
      case ReportsFilterField.totalTime:
      case ReportsFilterField.nightTime:
      case ReportsFilterField.ifrTime:
      case ReportsFilterField.instrumentTime:
      case ReportsFilterField.simulatedInstrumentTime:
      case ReportsFilterField.picTime:
      case ReportsFilterField.picusTime:
      case ReportsFilterField.sicTime:
      case ReportsFilterField.dualTime:
      case ReportsFilterField.instructorTime:
      case ReportsFilterField.crossCountryTime:
      case ReportsFilterField.custom1Time:
      case ReportsFilterField.custom2Time:
      case ReportsFilterField.custom3Time:
      case ReportsFilterField.custom4Time:
      case ReportsFilterField.distanceNm:
      case ReportsFilterField.takeoffs:
      case ReportsFilterField.takeoffsDay:
      case ReportsFilterField.takeoffsNight:
      case ReportsFilterField.landings:
      case ReportsFilterField.landingsDay:
      case ReportsFilterField.landingsNight:
      case ReportsFilterField.ifrApproaches:
        return false;
    }
  }

  Future<int> _sumSimulatorMinutes({DateTime? from, DateTime? to}) async {
    final startTimeLines = _db.alias(_db.timeLines, 'report_sim_tl');
    final minutesExpr = _db.simulatorTrainings.timeTotal.sum();
    final query = _db.selectOnly(_db.simulatorTrainings).join([
      innerJoin(
        startTimeLines,
        startTimeLines.id.equalsExp(_db.simulatorTrainings.startTimeLineId),
      ),
    ])..addColumns([minutesExpr]);
    if (from != null) {
      query.where(startTimeLines.eventDateTime.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(startTimeLines.eventDateTime.isSmallerOrEqualValue(to));
    }
    final row = await query.getSingle();
    return row.read(minutesExpr) ?? 0;
  }

  Future<int> _sumDutyMinutes({DateTime? from, DateTime? to}) async {
    final startTimeLines = _db.alias(_db.timeLines, 'report_duty_tl');
    final minutesExpr = _db.dutyPeriods.timeDutyMinutes.sum();
    final query = _db.selectOnly(_db.dutyPeriods).join([
      innerJoin(
        startTimeLines,
        startTimeLines.id.equalsExp(_db.dutyPeriods.dutyStartTimeLineId),
      ),
    ])..addColumns([minutesExpr]);
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
      final includesStart =
          exp.dateTimeFirstFlight == null ||
          _isBeforeOrEqual(query.from, exp.dateTimeFirstFlight!);
      final includesEnd =
          exp.dateTimeLastFlight == null ||
          _isAfterOrEqual(query.to, exp.dateTimeLastFlight!);
      if (!includesStart || !includesEnd) {
        continue;
      }
      totals =
          totals +
          ReportsTotals(
            sectors: exp.flightCount,
            takeoffsDay: exp.takeOffsDays,
            takeoffsNight: exp.takeOffsNight,
            landingsDay: exp.landingsDay,
            landingsNight: exp.landingsNight,
            ifrApproaches: exp.ifrApproaches,
            distanceNM: exp.distanceNM,
            totalMinutes: exp.timeBlockMinutes,
            flightMinutes: exp.timeFlightMinutes,
            nightMinutes: exp.timeNightMinutes,
            ifrMinutes: exp.timeIFRMinutes,
            instrumentMinutes: exp.timeInstrumentMinutes,
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

  /// Sums Previous Experience totals included in the provided date range.
  Future<ReportsTotals> loadPreviousExperienceTotals({
    required DateTime from,
    required DateTime to,
  }) async {
    return _sumPreviousExperience(
      ReportsQuery(
        from: from,
        to: to,
        includePreviousExperience: true,
        filterMatchMode: ReportsFilterMatchMode.all,
        filters: const [],
      ),
    );
  }

  /// Sums all Previous Experience rows without applying any date filtering.
  Future<ReportsTotals> loadAllPreviousExperienceTotals() async {
    final rows = await _db.select(_db.previousExperiences).get();
    var totals = const ReportsTotals.zero();
    for (final exp in rows) {
      totals =
          totals +
          ReportsTotals(
            sectors: exp.flightCount,
            takeoffsDay: exp.takeOffsDays,
            takeoffsNight: exp.takeOffsNight,
            landingsDay: exp.landingsDay,
            landingsNight: exp.landingsNight,
            ifrApproaches: exp.ifrApproaches,
            distanceNM: exp.distanceNM,
            totalMinutes: exp.timeBlockMinutes,
            flightMinutes: exp.timeFlightMinutes,
            nightMinutes: exp.timeNightMinutes,
            ifrMinutes: exp.timeIFRMinutes,
            instrumentMinutes: exp.timeInstrumentMinutes,
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
    required this.pilotPicNames,
    required this.pilotSicNames,
    required this.pilotTraineeNames,
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
  final String pilotPicNames;
  final String pilotSicNames;
  final String pilotTraineeNames;
  final String approachType;
  final String remarks;
  final String notes;
}

class _PilotNamesAccumulator {
  final Set<String> allOnBoard = <String>{};
  final Set<String> pic = <String>{};
  final Set<String> sic = <String>{};
  final Set<String> trainee = <String>{};

  void add(CrewPosition position, String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) return;
    allOnBoard.add(normalized);
    if (position == CrewPosition.pic || position == CrewPosition.picus) {
      pic.add(normalized);
    } else if (position == CrewPosition.sic) {
      sic.add(normalized);
    } else if (position == CrewPosition.trainee) {
      trainee.add(normalized);
    }
  }

  _PilotNamesByRole toResult() {
    return _PilotNamesByRole(
      allOnBoardNamesLower: allOnBoard.join(' '),
      picNamesLower: pic.join(' '),
      sicNamesLower: sic.join(' '),
      traineeNamesLower: trainee.join(' '),
    );
  }
}

class _PilotNamesByRole {
  const _PilotNamesByRole({
    required this.allOnBoardNamesLower,
    required this.picNamesLower,
    required this.sicNamesLower,
    required this.traineeNamesLower,
  });

  final String allOnBoardNamesLower;
  final String picNamesLower;
  final String sicNamesLower;
  final String traineeNamesLower;
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
      flightMinutes: flightMinutes,
      nightMinutes: nightMinutes,
      ifrMinutes: ifrMinutes,
      instrumentMinutes: instrumentMinutes,
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
