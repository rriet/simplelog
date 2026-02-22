import 'dart:math';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/import_operation_result.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';

class SimpleLogImportResult {
  const SimpleLogImportResult({
    required this.totalRows,
    required this.flights,
    required this.positionings,
    required this.simulators,
    required this.airports,
    required this.aircraftTypes,
    required this.aircrafts,
    required this.crew,
    required this.skipped,
    required this.errors,
  });

  final int totalRows;
  final int flights;
  final int positionings;
  final int simulators;
  final int airports;
  final int aircraftTypes;
  final int aircrafts;
  final int crew;
  final int skipped;
  final int errors;
}

typedef ImportProgressCallback = void Function(int processed, int total);

class SimpleLogCsvImporter {
  SimpleLogCsvImporter(this.db);

  final AppDatabase db;

  Future<SimpleLogImportResult> importCsv(
    String content, {
    SimpleLogImportOptions options = const SimpleLogImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    final rows = _parseCsv(content);
    if (rows.isEmpty) {
      return const SimpleLogImportResult(
        totalRows: 0,
        flights: 0,
        positionings: 0,
        simulators: 0,
        airports: 0,
        aircraftTypes: 0,
        aircrafts: 0,
        crew: 0,
        skipped: 0,
        errors: 0,
      );
    }

    final header = rows.first;
    final index = <String, int>{};
    for (var i = 0; i < header.length; i += 1) {
      index[_clean(header[i])] = i;
    }

    int readIndex(String name) => index[_clean(name)] ?? -1;

    final idxDate = readIndex('Date (DD/MM/YYYY)');
    final idxDepTime = readIndex('Departure Time (HH:MM)');
    final idxArrTime = readIndex('Arrival Time (HH:MM)');
    final idxDepEpoch = readIndex('Departure Epoch');
    final idxArrEpoch = readIndex('Arrival Epoch');
    final idxDepIcao = readIndex('Departure Icao');
    final idxDepIata = readIndex('Departure Iata');
    final idxDepName = readIndex('Departure Airport Name');
    final idxDepCity = readIndex('Departure City');
    final idxDepCountry = readIndex('Departure Country');
    final idxDepLat = readIndex('Departure Latitude');
    final idxDepLon = readIndex('Departure Longitude');
    final idxArrIcao = readIndex('Arrival Icao');
    final idxArrIata = readIndex('Arrival Iata');
    final idxArrName = readIndex('Arrival Airport Name');
    final idxArrCity = readIndex('Arrival City');
    final idxArrCountry = readIndex('Arrival Country');
    final idxArrLat = readIndex('Arrival Latitude');
    final idxArrLon = readIndex('Arrival Longitude');
    final idxReg = readIndex('Aircraft Registration');
    final idxAircraftMtow = readIndex('Aircraft MTOW');
    final idxAircraftSim = readIndex('Aircraft Simulator');
    final idxModelCode = readIndex('Model Make & Model');
    final idxModelGroup = readIndex('Model Group');
    final idxModelEngine = readIndex('Model Engine Type');
    final idxModelMtow = readIndex('Model MTOW');
    final idxModelMultiEngine = readIndex('Model Multi Engine');
    final idxModelMultiPilot = readIndex('Model Multi Pilot');
    final idxModelEfis = readIndex('Model EFIS');
    final idxPicName = readIndex('PIC Name');
    final idxPicEmail = readIndex('PIC Email');
    final idxPicPhone = readIndex('PIC Phone');
    final idxPicComments = readIndex('PIC Comments');
    final idxSicName = readIndex('SIC Name');
    final idxSicEmail = readIndex('SIC Email');
    final idxSicPhone = readIndex('SIC Phone');
    final idxSicComments = readIndex('SIC Comments');
    final idxPilotFunction = readIndex('Pilot Function');
    final idxRemarks = readIndex('Remarks');
    final idxNotes = readIndex('Private notes');
    final idxTakeoffDay = readIndex('Takeoff day');
    final idxTakeoffNight = readIndex('Takeoff night');
    final idxLandingDay = readIndex('Landing day');
    final idxLandingNight = readIndex('Landing night');
    final idxIfrApproaches = readIndex('IFR Approaches');
    final idxApproachType = readIndex('Approach Type');
    final idxIfrMinutes = readIndex('IFR Minutes');
    final idxSimInstrument = readIndex('Simulated Instrument Minutes');
    final idxNightMinutes = readIndex('Night Minutes');
    final idxCrossCountry = readIndex('Corss country Minutes');
    final idxPicMinutes = readIndex('PIC Minutes');
    final idxPicusMinutes = readIndex('PICUS Minutes');
    final idxSicMinutes = readIndex('SIC Minutes');
    final idxDualMinutes = readIndex('Dual Minutes');
    final idxInstructorMinutes = readIndex('Instructor Minutes');
    final idxSimulatorMinutes = readIndex('Simulator Minutes');
    final idxCustom1 = readIndex('Custom Time 1 Minutes');
    final idxCustom2 = readIndex('Custom Time 2 Minutes');
    final idxCustom3 = readIndex('Custom Time 3 Minutes');
    final idxCustom4 = readIndex('Custom Time 4 Minutes');
    final idxTotalMinutes = readIndex('Total Minutes');

    final dateFormat = DateFormat('dd/MM/yyyy');

    var flights = 0;
    var simulators = 0;
    var airports = 0;
    var aircraftTypes = 0;
    var aircrafts = 0;
    var crew = 0;
    var skipped = 0;
    var errors = 0;
    final totalRows = rows.length - 1;

    final airportCache = <String, Airport>{};
    final aircraftTypeCache = <String, AircraftType>{};
    final aircraftCache = <String, Aircraft>{};
    final crewCache = <String, CrewData>{};

    final existingAirports = await db.select(db.airports).get();
    for (final airport in existingAirports) {
      airportCache[_airportKey(airport.icao)] = airport;
    }
    final existingTypes = await db.select(db.aircraftTypes).get();
    for (final type in existingTypes) {
      aircraftTypeCache[_normalizeKey(type.code)] = type;
    }
    final existingAircraft = await db.select(db.aircrafts).get();
    for (final aircraft in existingAircraft) {
      aircraftCache[_normalizeKey(aircraft.registration)] = aircraft;
    }
    final existingCrew = await db.select(db.crew).get();
    for (final member in existingCrew) {
      crewCache[_crewKey(member.name)] = member;
    }

    await db.transaction(() async {
      var processedRows = 0;
      for (var rowIndex = rows.length - 1; rowIndex >= 1; rowIndex -= 1) {
        processedRows += 1;
        if (processedRows % 500 == 0) {
          onProgress?.call(processedRows, totalRows);
        }
        final row = rows[rowIndex];
        if (row.isEmpty) continue;
        try {
          String get(int idx) => idx >= 0 && idx < row.length ? row[idx] : '';

          final dateText = get(idxDate);
          final depTimeText = get(idxDepTime);
          final arrTimeText = get(idxArrTime);

          final depIcao = _pickCode(get(idxDepIcao), get(idxDepIata));
          final arrIcao = _pickCode(get(idxArrIcao), get(idxArrIata));
          if (depIcao.isEmpty || arrIcao.isEmpty) {
            skipped += 1;
            continue;
          }

          final depLatRaw = get(idxDepLat);
          final depLonRaw = get(idxDepLon);
          final arrLatRaw = get(idxArrLat);
          final arrLonRaw = get(idxArrLon);
          final depLat = _parseDouble(depLatRaw);
          final depLon = _parseDouble(depLonRaw);
          final arrLat = _parseDouble(arrLatRaw);
          final arrLon = _parseDouble(arrLonRaw);

          final depAirportId = await _getOrCreateAirport(
            icao: depIcao,
            iata: get(idxDepIata),
            name: get(idxDepName),
            city: get(idxDepCity),
            country: get(idxDepCountry),
            latitude: depLat,
            longitude: depLon,
            latitudeRaw: depLatRaw,
            longitudeRaw: depLonRaw,
            cache: airportCache,
            options: options,
          );
          if (depAirportId.created) airports += 1;

          final arrAirportId = await _getOrCreateAirport(
            icao: arrIcao,
            iata: get(idxArrIata),
            name: get(idxArrName),
            city: get(idxArrCity),
            country: get(idxArrCountry),
            latitude: arrLat,
            longitude: arrLon,
            latitudeRaw: arrLatRaw,
            longitudeRaw: arrLonRaw,
            cache: airportCache,
            options: options,
          );
          if (arrAirportId.created) airports += 1;

          final typeCode = get(idxModelCode).trim();
          final typeFamily = get(idxModelGroup).trim();
          final typeEngine = get(idxModelEngine).trim();
          final typeMtow = _parseInt(get(idxModelMtow));
          final typeMultiEngine = _parseBool(get(idxModelMultiEngine));
          final typeMultiPilot = _parseBool(get(idxModelMultiPilot));
          final typeEfis = _parseBool(get(idxModelEfis));
          final typeComplex = typeMultiPilot;
          final typeHighPerf = typeMultiPilot;

          final aircraftTypeResult = await _getOrCreateAircraftType(
            code: typeCode,
            family: typeFamily,
            engineType: _mapEngineType(typeEngine),
            mtow: typeMtow,
            engineCount: typeMultiEngine ? 2 : 1,
            multiPilot: typeMultiPilot,
            complex: typeComplex,
            efis: typeEfis,
            highPerformance: typeHighPerf,
            cache: aircraftTypeCache,
            options: options,
          );
          if (aircraftTypeResult != null && aircraftTypeResult.created) {
            aircraftTypes += 1;
          }
          final aircraftTypeId = aircraftTypeResult?.id;

          final registration = get(idxReg).trim().toUpperCase();
          final aircraftId = await _getOrCreateAircraft(
            registration: registration,
            aircraftTypeId: aircraftTypeId,
            mtow: _parseInt(get(idxAircraftMtow)),
            typeMtow: typeMtow > 0 ? typeMtow : null,
            isSimulator: _parseBool(get(idxAircraftSim)),
            cache: aircraftCache,
            options: options,
          );
          if (aircraftId == null) {
            skipped += 1;
            continue;
          }
          if (aircraftId.created) aircrafts += 1;

          final depEpochFromCsv = _parseInt(get(idxDepEpoch));
          final departureDate = depEpochFromCsv > 0
              ? DateTime.fromMillisecondsSinceEpoch(
                  depEpochFromCsv * 1000,
                  isUtc: true,
                )
              : _parseDateTime(dateFormat, dateText, depTimeText);
          if (departureDate == null) {
            skipped += 1;
            continue;
          }

          DateTime? arrivalDate;
          if (_isMissingTime(depTimeText) && _isMissingTime(arrTimeText)) {
            arrivalDate = null;
          } else {
            final arrEpochFromCsv = _parseInt(get(idxArrEpoch));
            arrivalDate = arrEpochFromCsv > 0
                ? DateTime.fromMillisecondsSinceEpoch(
                    arrEpochFromCsv * 1000,
                    isUtc: true,
                  )
                : _parseArrivalDateTime(
                    dateFormat,
                    dateText,
                    depTimeText,
                    arrTimeText,
                  );
          }

          final departureTimelineId = await db
              .into(db.timeLines)
              .insert(TimeLinesCompanion.insert(eventDateTime: departureDate));

          final isSimulator = _parseBool(get(idxAircraftSim));
          int? flightId;
          int? simId;

          final totalMinutesRaw = _parseInt(get(idxTotalMinutes));
          var computedTotal = totalMinutesRaw;
          final shouldDeriveMissingBlockTime =
              options.recalculateTotalTime ||
              options.recalculateCrossCountry ||
              options.recalculateInstrument;
          if (shouldDeriveMissingBlockTime &&
              computedTotal == 0 &&
              arrivalDate != null) {
            computedTotal = arrivalDate.difference(departureDate).inMinutes;
          }
          final totalBlockMinutes = () {
            if (arrivalDate == null) return computedTotal;
            final diff = arrivalDate.difference(departureDate).inMinutes;
            if (diff > 0) return diff;
            return computedTotal;
          }();

          final distanceValue = _calculateDistanceNm(
            depLat,
            depLon,
            arrLat,
            arrLon,
          );
          final distanceNm = distanceValue.isFinite ? distanceValue.round() : 0;

          FlightCalculations? calculations;
          if (arrivalDate != null &&
              _hasCoords(depLat, depLon, arrLat, arrLon)) {
            final depEpoch = depEpochFromCsv > 0
                ? depEpochFromCsv
                : _wallClockAsUtcEpochSeconds(departureDate);
            final arrEpochFromCsv = _parseInt(get(idxArrEpoch));
            final arrEpoch = arrEpochFromCsv > 0
                ? arrEpochFromCsv
                : _wallClockAsUtcEpochSeconds(arrivalDate);
            calculations = FlightCalculations(
              latDep: depLat,
              longDep: depLon,
              latArr: arrLat,
              longArr: arrLon,
              depTimeEpochSeconds: depEpoch,
              arrTimeEpochSeconds: arrEpoch,
            );
          }

          if (isSimulator) {
            final simMinutes = _parseInt(get(idxSimulatorMinutes));
            final simTime = simMinutes > 0 ? simMinutes : totalMinutesRaw;
            simId = await db
                .into(db.simulatorTrainings)
                .insert(
                  SimulatorTrainingsCompanion.insert(
                    aircraftId: aircraftId.id,
                    startTimeLineId: departureTimelineId,
                    endDateTime: arrivalDate == null
                        ? const Value(null)
                        : Value(arrivalDate),
                    timeTotal: simTime,
                    remarks: get(idxRemarks),
                    notes: get(idxNotes),
                    isLocked: false,
                    signatureImage: const Value(null),
                  ),
                );
            simulators += 1;
          } else {
            var picMinutes = _parseInt(get(idxPicMinutes));
            var picusMinutes = _parseInt(get(idxPicusMinutes));
            var sicMinutes = _parseInt(get(idxSicMinutes));
            var dualMinutes = _parseInt(get(idxDualMinutes));
            var instructorMinutes = _parseInt(get(idxInstructorMinutes));

            if (options.recalculateTotalTime && computedTotal > 0) {
              final role = _pickRole(
                picMinutes,
                picusMinutes,
                sicMinutes,
                dualMinutes,
                instructorMinutes,
              );
              picMinutes = role == _Role.pic ? computedTotal : 0;
              picusMinutes = role == _Role.picus ? computedTotal : 0;
              sicMinutes = role == _Role.sic ? computedTotal : 0;
              dualMinutes = role == _Role.dual ? computedTotal : 0;
              instructorMinutes = role == _Role.instructor ? computedTotal : 0;
            }

            var nightMinutes = _parseInt(get(idxNightMinutes));
            if (options.recalculateNightTime && calculations != null) {
              nightMinutes = calculations.nightTimeMinutes;
            }

            var takeoffDay = _parseInt(get(idxTakeoffDay));
            var takeoffNight = _parseInt(get(idxTakeoffNight));
            var landingDay = _parseInt(get(idxLandingDay));
            var landingNight = _parseInt(get(idxLandingNight));
            final pilotFunctionRaw = get(idxPilotFunction).trim();
            final pilotFunction = pilotFunctionRaw.isNotEmpty
                ? pilotFunctionRaw
                : _canonicalPilotFunction(
                    '',
                    takeoffCount: takeoffDay + takeoffNight,
                    landingCount: landingDay + landingNight,
                  );
            if (options.recalculateTotalTime && computedTotal > 0) {
              computedTotal = _applyIrpFactoring(
                totalMinutes: totalBlockMinutes,
                pilotFunction: _canonicalPilotFunction(
                  pilotFunction,
                  takeoffCount: takeoffDay + takeoffNight,
                  landingCount: landingDay + landingNight,
                ),
                irp3Percent: options.irp3Percent,
                irp3SubtractMinutes: options.irp3SubtractMinutes,
                irp4Percent: options.irp4Percent,
                irp4SubtractMinutes: options.irp4SubtractMinutes,
              );
            }
            if (options.recalculateTakeoffLanding && calculations != null) {
              final totalTakeoffs = takeoffDay + takeoffNight;
              final totalLandings = landingDay + landingNight;
              if (totalTakeoffs > 0) {
                if (calculations.dayTakeOff) {
                  takeoffDay = totalTakeoffs;
                  takeoffNight = 0;
                } else {
                  takeoffDay = 0;
                  takeoffNight = totalTakeoffs;
                }
              }
              if (totalLandings > 0) {
                if (calculations.dayLanding) {
                  landingDay = totalLandings;
                  landingNight = 0;
                } else {
                  landingDay = 0;
                  landingNight = totalLandings;
                }
              }
            }

            var crossCountryMinutes = _parseInt(get(idxCrossCountry));
            if (options.recalculateCrossCountry && computedTotal > 0) {
              crossCountryMinutes =
                  distanceNm >= options.crossCountryThresholdNm
                  ? computedTotal
                  : 0;
            }

            var ifrMinutes = _parseInt(get(idxIfrMinutes));
            if (options.recalculateIfrTime && computedTotal > 0) {
              ifrMinutes = _calculateFactoredMinutes(
                totalMinutes: computedTotal,
                percent: options.ifrPercent,
                subtractMinutes: options.ifrSubtractMinutes,
                minimumMinutes: options.ifrMinimumMinutes,
              );
            }

            var instrumentMinutes = 0;
            if (options.recalculateInstrument && computedTotal > 0) {
              instrumentMinutes = _calculateFactoredMinutes(
                totalMinutes: computedTotal,
                percent: options.instrumentPercent,
                subtractMinutes: options.instrumentSubtractMinutes,
                minimumMinutes: options.instrumentMinimumMinutes,
              );
            }

            flightId = await db
                .into(db.flights)
                .insert(
                  FlightsCompanion.insert(
                    aircraftId: aircraftId.id,
                    departureAirportId: depAirportId.id,
                    arrivalAirportId: arrAirportId.id,
                    departureDateTimeId: departureTimelineId,
                    takeOffDateTime: const Value(null),
                    landingDateTime: const Value(null),
                    arrivalDateTime: arrivalDate == null
                        ? const Value(null)
                        : Value(arrivalDate),
                    timePICMinutes: picMinutes,
                    timePICUSMinutes: picusMinutes,
                    timeSICMinutes: sicMinutes,
                    timeDualMinutes: dualMinutes,
                    timeInstructorMinutes: instructorMinutes,
                    timeIFRMinutes: ifrMinutes,
                    timeInstrumentMinutes: instrumentMinutes,
                    timeSimulatedInstrumentMinutes: _parseInt(
                      get(idxSimInstrument),
                    ),
                    timeNightMinutes: nightMinutes,
                    timeCrossCountryMinutes: crossCountryMinutes,
                    timeCustom1Minutes: _parseInt(get(idxCustom1)),
                    timeCustom2Minutes: _parseInt(get(idxCustom2)),
                    timeCustom3Minutes: _parseInt(get(idxCustom3)),
                    timeCustom4Minutes: _parseInt(get(idxCustom4)),
                    // Old SimpleLog CSV doesn't provide takeoff/landing timestamps,
                    // so flight time cannot be derived reliably.
                    timeFlightMinutes: 0,
                    timeBlockMinutes: computedTotal,
                    timeTotalBlockMinutes: Value(totalBlockMinutes),
                    distanceNM: distanceNm,
                    ifrApproaches: _parseInt(get(idxIfrApproaches)),
                    takeOffsDays: takeoffDay,
                    takeOffsNight: takeoffNight,
                    landingsDay: landingDay,
                    landingsNight: landingNight,
                    pilotFunction: Value(pilotFunction),
                    approachType: get(idxApproachType),
                    remarks: get(idxRemarks),
                    notes: get(idxNotes),
                    isLocked: false,
                    signatureImage: const Value(null),
                  ),
                );
            flights += 1;
          }

          final picName = get(idxPicName).trim();
          final sicName = get(idxSicName).trim();

          if (picName.isNotEmpty) {
            final picId = await _getOrCreateCrew(
              name: picName,
              email: get(idxPicEmail),
              phone: get(idxPicPhone),
              notes: get(idxPicComments),
              cache: crewCache,
              options: options,
            );
            if (picId != null) {
              if (picId.created) crew += 1;
              if (flightId != null) {
                await db
                    .into(db.flightCrewAssignments)
                    .insert(
                      FlightCrewAssignmentsCompanion.insert(
                        flightId: flightId,
                        crewId: picId.id,
                        position: CrewPosition.pic,
                      ),
                    );
              } else if (isSimulator) {
                await db
                    .into(db.simulatorCrewAssignments)
                    .insert(
                      SimulatorCrewAssignmentsCompanion.insert(
                        simulatorId: simId!,
                        crewId: picId.id,
                        position: CrewPosition.pic,
                      ),
                    );
              }
            }
          }

          if (sicName.isNotEmpty) {
            final sicId = await _getOrCreateCrew(
              name: sicName,
              email: get(idxSicEmail),
              phone: get(idxSicPhone),
              notes: get(idxSicComments),
              cache: crewCache,
              options: options,
            );
            if (sicId != null) {
              if (sicId.created) crew += 1;
              if (flightId != null) {
                await db
                    .into(db.flightCrewAssignments)
                    .insert(
                      FlightCrewAssignmentsCompanion.insert(
                        flightId: flightId,
                        crewId: sicId.id,
                        position: CrewPosition.sic,
                      ),
                    );
              } else if (isSimulator) {
                await db
                    .into(db.simulatorCrewAssignments)
                    .insert(
                      SimulatorCrewAssignmentsCompanion.insert(
                        simulatorId: simId!,
                        crewId: sicId.id,
                        position: CrewPosition.sic,
                      ),
                    );
              }
            }
          }
        } catch (_) {
          errors += 1;
        }
      }
    });
    onProgress?.call(totalRows, totalRows);

    return SimpleLogImportResult(
      totalRows: totalRows,
      flights: flights,
      positionings: 0,
      simulators: simulators,
      airports: airports,
      aircraftTypes: aircraftTypes,
      aircrafts: aircrafts,
      crew: crew,
      skipped: skipped,
      errors: errors,
    );
  }

  Future<ImportOperationResult<SimpleLogImportResult>> importCsvSafely(
    String content, {
    SimpleLogImportOptions options = const SimpleLogImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final result = await importCsv(
        content,
        options: options,
        onProgress: onProgress,
      );
      return ImportOperationResult.success(result);
    } on FormatException catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.invalidFormat,
          message: 'Invalid CSV format.',
          exception: error,
        ),
      );
    } on StateError catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.parseError,
          message: error.message,
          exception: error,
        ),
      );
    } on ArgumentError catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.parseError,
          message: error.message.toString(),
          exception: error,
        ),
      );
    } catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.unexpected,
          message: 'Unexpected import error.',
          exception: error,
        ),
      );
    }
  }

  Future<SimpleLogImportResult> importSouthwestCsv(
    String content, {
    SouthwestImportOptions options = const SouthwestImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    final rows = _parseCsv(content);
    final headerRowIndex = rows.indexWhere(
      (row) => row.isNotEmpty && _clean(row.first).toUpperCase() == 'DATE',
    );
    if (headerRowIndex < 0) {
      throw const FormatException('Southwest CSV header not found.');
    }

    final header = rows[headerRowIndex];
    final index = <String, int>{};
    for (var i = 0; i < header.length; i += 1) {
      index[_clean(header[i]).toUpperCase()] = i;
    }

    int readIndex(String name) => index[name.toUpperCase()] ?? -1;

    final idxDate = readIndex('DATE');
    final idxFlight = readIndex('Flight');
    final idxDhd = readIndex('dhd');
    final idxFrom = readIndex('From');
    final idxDepart = readIndex('Depart');
    final idxTo = readIndex('To');
    final idxArrive = readIndex('Arrive');
    final idxBlock = readIndex('Block');
    final idxTail = readIndex('Tail_Number');
    final idxType = readIndex('A_C_Type');
    final idxTakeoff = readIndex('TakeOff');
    final idxLanding = readIndex('Landing');
    final idxCopilot = readIndex('CoPilot');

    var flights = 0;
    var positionings = 0;
    var simulators = 0;
    var airports = 0;
    var aircraftTypes = 0;
    var aircrafts = 0;
    var crew = 0;
    var skipped = 0;
    var errors = 0;

    final totalRows = rows.length - headerRowIndex - 1;
    final entityOptions = SimpleLogImportOptions(
      overrideAirportValues: options.overrideExistingData,
      overrideAircraftValues: options.overrideExistingData,
      overrideAircraftTypeValues: options.overrideExistingData,
    );

    final airportCache = <String, Airport>{};
    final aircraftTypeCache = <String, AircraftType>{};
    final aircraftCache = <String, Aircraft>{};
    final crewCache = <String, CrewData>{};
    final existingAirports = await db.select(db.airports).get();
    for (final airport in existingAirports) {
      airportCache[_airportKey(airport.icao)] = airport;
    }
    final existingTypes = await db.select(db.aircraftTypes).get();
    for (final type in existingTypes) {
      aircraftTypeCache[_normalizeKey(type.code)] = type;
    }
    final existingAircraft = await db.select(db.aircrafts).get();
    for (final aircraft in existingAircraft) {
      aircraftCache[_normalizeKey(aircraft.registration)] = aircraft;
    }
    final existingCrew = await db.select(db.crew).get();
    CrewData? selfCrew;
    for (final member in existingCrew) {
      crewCache[_crewKey(member.name)] = member;
      if (member.isSelf && selfCrew == null) selfCrew = member;
    }

    final existingFlightKeys = await _loadExistingFlightDateKeys();
    await db.transaction(() async {
      for (
        var rowIndex = headerRowIndex + 1;
        rowIndex < rows.length;
        rowIndex += 1
      ) {
        final processed = rowIndex - headerRowIndex;
        if (processed % 250 == 0) {
          onProgress?.call(processed, totalRows);
        }

        final row = rows[rowIndex];
        if (row.isEmpty) continue;
        try {
          String get(int idx) =>
              idx >= 0 && idx < row.length ? row[idx].trim() : '';

          final dateText = get(idxDate);
          final fromCode = get(idxFrom).toUpperCase();
          final toCode = get(idxTo).toUpperCase();
          final departText = get(idxDepart);
          final arriveText = get(idxArrive);
          if (dateText.isEmpty ||
              fromCode.isEmpty ||
              toCode.isEmpty ||
              departText.isEmpty ||
              arriveText.isEmpty) {
            skipped += 1;
            continue;
          }

          final departureDateTime = _parseSouthwestDateTime(
            dateText,
            departText,
          );
          final arrivalDateTime = _parseSouthwestDateTime(dateText, arriveText);
          if (departureDateTime == null || arrivalDateTime == null) {
            skipped += 1;
            continue;
          }
          var resolvedArrival = arrivalDateTime;
          if (resolvedArrival.isBefore(departureDateTime)) {
            resolvedArrival = resolvedArrival.add(const Duration(days: 1));
          }

          final depAirportId = await _getOrCreateAirport(
            icao: fromCode,
            iata: '',
            name: '',
            city: '',
            country: '',
            latitude: airportCache[_airportKey(fromCode)]?.latitude ?? 0,
            longitude: airportCache[_airportKey(fromCode)]?.longitude ?? 0,
            latitudeRaw: '',
            longitudeRaw: '',
            cache: airportCache,
            options: entityOptions,
          );
          if (depAirportId.created) airports += 1;

          final arrAirportId = await _getOrCreateAirport(
            icao: toCode,
            iata: '',
            name: '',
            city: '',
            country: '',
            latitude: airportCache[_airportKey(toCode)]?.latitude ?? 0,
            longitude: airportCache[_airportKey(toCode)]?.longitude ?? 0,
            latitudeRaw: '',
            longitudeRaw: '',
            cache: airportCache,
            options: entityOptions,
          );
          if (arrAirportId.created) airports += 1;

          final isDeadhead = get(idxDhd).toUpperCase() == 'DH';
          final calculatedBlock = resolvedArrival
              .difference(departureDateTime)
              .inMinutes;
          final blockFromFile = _parseBlockHhMmToMinutes(get(idxBlock));
          final blockMinutes = options.recalculateBlockTime
              ? calculatedBlock
              : (blockFromFile > 0 ? blockFromFile : calculatedBlock);

          if (isDeadhead) {
            final timelineId = await db
                .into(db.timeLines)
                .insert(
                  TimeLinesCompanion.insert(eventDateTime: departureDateTime),
                );
            await db
                .into(db.positionings)
                .insert(
                  PositioningsCompanion.insert(
                    departurePlaceId: depAirportId.id,
                    arrivalPlaceId: arrAirportId.id,
                    departureDateTimeId: timelineId,
                    arrivalDateTime: Value(resolvedArrival),
                    timeTotalMinutes: max(0, blockMinutes),
                    notes: const Value(''),
                    isLocked: false,
                  ),
                );
            positionings += 1;
            continue;
          }

          final typeCode = get(idxType).toUpperCase();
          final family = _southwestFamily(typeCode);
          final typeResult = await _getOrCreateAircraftType(
            code: typeCode.isEmpty ? 'UNKNOWN' : typeCode,
            family: family,
            engineType: EngineType.jet,
            mtow: 0,
            engineCount: 2,
            multiPilot: true,
            complex: true,
            efis: true,
            highPerformance: true,
            cache: aircraftTypeCache,
            options: entityOptions,
          );
          if (typeResult?.created == true) aircraftTypes += 1;
          if (typeResult == null) {
            skipped += 1;
            continue;
          }

          final aircraftResult = await _getOrCreateAircraft(
            registration: get(idxTail).toUpperCase(),
            aircraftTypeId: typeResult.id,
            mtow: null,
            isSimulator: false,
            cache: aircraftCache,
            options: entityOptions,
          );
          if (aircraftResult == null) {
            skipped += 1;
            continue;
          }
          if (aircraftResult.created) aircrafts += 1;

          final depAirport = airportCache[_airportKey(fromCode)];
          final arrAirport = airportCache[_airportKey(toCode)];
          final hasCoords =
              depAirport != null &&
              arrAirport != null &&
              _hasCoords(
                depAirport.latitude,
                depAirport.longitude,
                arrAirport.latitude,
                arrAirport.longitude,
              );

          FlightCalculations? calculations;
          var distanceNm = 0;
          if (hasCoords) {
            calculations = FlightCalculations(
              latDep: depAirport.latitude,
              longDep: depAirport.longitude,
              latArr: arrAirport.latitude,
              longArr: arrAirport.longitude,
              depTimeEpochSeconds: _wallClockAsUtcEpochSeconds(
                departureDateTime,
              ),
              arrTimeEpochSeconds: _wallClockAsUtcEpochSeconds(resolvedArrival),
            );
            distanceNm = calculations.flightDistanceNm.round();
          }

          final flightKey = _flightDateKey(departureDateTime, resolvedArrival);
          final existing = existingFlightKeys[flightKey];
          if (existing != null && !options.overrideExistingData) {
            skipped += 1;
            continue;
          }

          final takeoffCount = _parseInt(get(idxTakeoff));
          final landingCount = _parseInt(get(idxLanding));
          var takeoffsDay = takeoffCount;
          var takeoffsNight = 0;
          var landingsDay = landingCount;
          var landingsNight = 0;
          if (options.recalculateNightTime && calculations != null) {
            if (takeoffCount > 0) {
              takeoffsDay = calculations.dayTakeOff ? takeoffCount : 0;
              takeoffsNight = calculations.dayTakeOff ? 0 : takeoffCount;
            }
            if (landingCount > 0) {
              landingsDay = calculations.dayLanding ? landingCount : 0;
              landingsNight = calculations.dayLanding ? 0 : landingCount;
            }
          }

          final nightMinutes =
              options.recalculateNightTime && calculations != null
              ? calculations.nightTimeMinutes
              : 0;
          final ifrMinutes = options.recalculateIfrTime ? blockMinutes : 0;
          final crossCountryMinutes = options.recalculateCrossCountry
              ? (distanceNm >= options.crossCountryThresholdNm
                    ? blockMinutes
                    : 0)
              : 0;
          final instrumentMinutes = options.recalculateInstrumentTime
              ? blockMinutes
              : 0;

          final selfPosition = _normalizeSelfPosition(
            options.defaultSelfPosition,
          );
          final selfIsPic = selfPosition == CrewPosition.pic;
          final pilotFunction = selfIsPic ? 'PF' : 'PNF';
          final picMinutes = selfIsPic ? blockMinutes : 0;
          final sicMinutes = selfIsPic ? 0 : blockMinutes;

          final coPilot = _parseSouthwestCoPilot(get(idxCopilot));
          final notes = _buildSouthwestNotes(
            flightNumber: get(idxFlight),
            includeFlightNumber: options.addFlightNumberToNotes,
          );

          late final int flightId;
          if (existing != null) {
            await (db.update(
              db.timeLines,
            )..where((t) => t.id.equals(existing.departureTimelineId))).write(
              TimeLinesCompanion(eventDateTime: Value(departureDateTime)),
            );
            await (db.update(
              db.flights,
            )..where((t) => t.id.equals(existing.flightId))).write(
              FlightsCompanion(
                aircraftId: Value(aircraftResult.id),
                departureAirportId: Value(depAirportId.id),
                arrivalAirportId: Value(arrAirportId.id),
                arrivalDateTime: Value(resolvedArrival),
                timePICMinutes: Value(picMinutes),
                timePICUSMinutes: const Value(0),
                timeSICMinutes: Value(sicMinutes),
                timeDualMinutes: const Value(0),
                timeInstructorMinutes: const Value(0),
                timeIFRMinutes: Value(ifrMinutes),
                timeInstrumentMinutes: Value(instrumentMinutes),
                timeSimulatedInstrumentMinutes: const Value(0),
                timeNightMinutes: Value(nightMinutes),
                timeCrossCountryMinutes: Value(crossCountryMinutes),
                timeCustom1Minutes: const Value(0),
                timeCustom2Minutes: const Value(0),
                timeCustom3Minutes: const Value(0),
                timeCustom4Minutes: const Value(0),
                timeFlightMinutes: const Value(0),
                timeBlockMinutes: Value(blockMinutes),
                timeTotalBlockMinutes: Value(blockMinutes),
                distanceNM: Value(distanceNm),
                ifrApproaches: const Value(0),
                takeOffsDays: Value(takeoffsDay),
                takeOffsNight: Value(takeoffsNight),
                landingsDay: Value(landingsDay),
                landingsNight: Value(landingsNight),
                pilotFunction: Value(pilotFunction),
                approachType: const Value(''),
                remarks: const Value(''),
                notes: Value(notes),
              ),
            );
            await (db.delete(
              db.flightCrewAssignments,
            )..where((t) => t.flightId.equals(existing.flightId))).go();
            flightId = existing.flightId;
          } else {
            final timelineId = await db
                .into(db.timeLines)
                .insert(
                  TimeLinesCompanion.insert(eventDateTime: departureDateTime),
                );
            flightId = await db
                .into(db.flights)
                .insert(
                  FlightsCompanion.insert(
                    aircraftId: aircraftResult.id,
                    departureAirportId: depAirportId.id,
                    arrivalAirportId: arrAirportId.id,
                    departureDateTimeId: timelineId,
                    takeOffDateTime: const Value(null),
                    landingDateTime: const Value(null),
                    arrivalDateTime: Value(resolvedArrival),
                    timePICMinutes: picMinutes,
                    timePICUSMinutes: 0,
                    timeSICMinutes: sicMinutes,
                    timeDualMinutes: 0,
                    timeInstructorMinutes: 0,
                    timeIFRMinutes: ifrMinutes,
                    timeInstrumentMinutes: instrumentMinutes,
                    timeSimulatedInstrumentMinutes: 0,
                    timeNightMinutes: nightMinutes,
                    timeCrossCountryMinutes: crossCountryMinutes,
                    timeCustom1Minutes: 0,
                    timeCustom2Minutes: 0,
                    timeCustom3Minutes: 0,
                    timeCustom4Minutes: 0,
                    timeFlightMinutes: 0,
                    timeBlockMinutes: blockMinutes,
                    timeTotalBlockMinutes: Value(blockMinutes),
                    distanceNM: distanceNm,
                    ifrApproaches: 0,
                    takeOffsDays: takeoffsDay,
                    takeOffsNight: takeoffsNight,
                    landingsDay: landingsDay,
                    landingsNight: landingsNight,
                    pilotFunction: Value(pilotFunction),
                    approachType: '',
                    remarks: '',
                    notes: notes,
                    isLocked: false,
                    signatureImage: const Value(null),
                  ),
                );
            existingFlightKeys[flightKey] = _ExistingFlightData(
              flightId: flightId,
              departureTimelineId: timelineId,
            );
          }

          if (selfCrew != null) {
            await db
                .into(db.flightCrewAssignments)
                .insert(
                  FlightCrewAssignmentsCompanion.insert(
                    flightId: flightId,
                    crewId: selfCrew.id,
                    position: selfPosition,
                  ),
                );
          }

          if (coPilot.name.isNotEmpty) {
            final coPilotCrew = await _getOrCreateCrew(
              name: coPilot.name,
              email: '',
              phone: '',
              notes:
                  options.addCopilotStaffNumberToNotes &&
                      (coPilot.staffNumber ?? '').isNotEmpty
                  ? 'Staff Number: ${coPilot.staffNumber}'
                  : '',
              cache: crewCache,
              options: entityOptions,
            );
            if (coPilotCrew?.created == true) crew += 1;
            if (coPilotCrew != null &&
                (selfCrew == null || coPilotCrew.id != selfCrew.id)) {
              await db
                  .into(db.flightCrewAssignments)
                  .insert(
                    FlightCrewAssignmentsCompanion.insert(
                      flightId: flightId,
                      crewId: coPilotCrew.id,
                      position: _oppositePosition(selfPosition),
                    ),
                  );
            }
          }

          flights += 1;
        } catch (_) {
          errors += 1;
        }
      }
    });
    onProgress?.call(totalRows, totalRows);

    return SimpleLogImportResult(
      totalRows: totalRows,
      flights: flights,
      positionings: positionings,
      simulators: simulators,
      airports: airports,
      aircraftTypes: aircraftTypes,
      aircrafts: aircrafts,
      crew: crew,
      skipped: skipped,
      errors: errors,
    );
  }

  Future<ImportOperationResult<SimpleLogImportResult>> importSouthwestCsvSafely(
    String content, {
    SouthwestImportOptions options = const SouthwestImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final result = await importSouthwestCsv(
        content,
        options: options,
        onProgress: onProgress,
      );
      return ImportOperationResult.success(result);
    } on FormatException catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.invalidFormat,
          message: 'Invalid Southwest CSV format.',
          exception: error,
        ),
      );
    } on StateError catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.parseError,
          message: error.message,
          exception: error,
        ),
      );
    } on ArgumentError catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.parseError,
          message: error.message.toString(),
          exception: error,
        ),
      );
    } catch (error) {
      return ImportOperationResult.failure(
        ImportFailure(
          type: ImportFailureType.unexpected,
          message: 'Unexpected Southwest import error.',
          exception: error,
        ),
      );
    }
  }

  Future<Map<String, _ExistingFlightData>> _loadExistingFlightDateKeys() async {
    final result = <String, _ExistingFlightData>{};
    final query = db.customSelect(
      '''
SELECT f.id AS flight_id,
       f.arrival_date_time AS arrival_date_time,
       f.departure_date_time_id AS departure_timeline_id,
       tl.event_date_time AS departure_date_time
FROM flights f
INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
''',
      readsFrom: {db.flights, db.timeLines},
    );
    final rows = await query.get();
    for (final row in rows) {
      final flightId = row.read<int>('flight_id');
      final departureTimelineId = row.read<int>('departure_timeline_id');
      final departure = row.read<DateTime>('departure_date_time');
      final arrival = row.readNullable<DateTime>('arrival_date_time');
      result[_flightDateKey(departure, arrival)] = _ExistingFlightData(
        flightId: flightId,
        departureTimelineId: departureTimelineId,
      );
    }
    return result;
  }

  List<List<String>> _parseCsv(String content) {
    final rows = <List<String>>[];
    final buffer = StringBuffer();
    var row = <String>[];
    var inQuotes = false;

    for (var i = 0; i < content.length; i += 1) {
      final char = content[i];
      if (char == '"') {
        final next = i + 1 < content.length ? content[i + 1] : '';
        if (inQuotes && next == '"') {
          buffer.write('"');
          i += 1;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }
      if (char == ',' && !inQuotes) {
        row.add(buffer.toString());
        buffer.clear();
        continue;
      }
      if ((char == '\n' || char == '\r') && !inQuotes) {
        if (char == '\r' && i + 1 < content.length && content[i + 1] == '\n') {
          i += 1;
        }
        row.add(buffer.toString());
        buffer.clear();
        if (row.any((value) => value.trim().isNotEmpty)) {
          rows.add(row);
        }
        row = <String>[];
        continue;
      }
      buffer.write(char);
    }
    if (buffer.isNotEmpty || row.isNotEmpty) {
      row.add(buffer.toString());
      if (row.any((value) => value.trim().isNotEmpty)) {
        rows.add(row);
      }
    }
    return rows;
  }

  String _clean(String value) => value.replaceAll('"', '').trim();

  String _pickCode(String icao, String iata) {
    final cleanIcao = icao.trim().toUpperCase();
    if (cleanIcao.isNotEmpty) return cleanIcao;
    return iata.trim().toUpperCase();
  }

  bool _isMissingTime(String value) {
    final clean = value.trim();
    return clean.isEmpty || clean == '00:00';
  }

  DateTime? _parseDateTime(
    DateFormat dateFormat,
    String dateText,
    String timeText,
  ) {
    if (dateText.trim().isEmpty) return null;
    try {
      final date = dateFormat.parseStrict(dateText.trim());
      final timeParts = timeText.split(':');
      final hour = timeParts.length > 1 ? int.parse(timeParts[0]) : 0;
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      return DateTime.utc(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseArrivalDateTime(
    DateFormat dateFormat,
    String dateText,
    String depTime,
    String arrTime,
  ) {
    final departure = _parseDateTime(dateFormat, dateText, depTime);
    final arrival = _parseDateTime(dateFormat, dateText, arrTime);
    if (departure == null || arrival == null) return null;
    if (arrival.isBefore(departure)) {
      return arrival.add(const Duration(days: 1));
    }
    return arrival;
  }

  int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

  int _wallClockAsUtcEpochSeconds(DateTime dt) {
    return DateTime.utc(
          dt.year,
          dt.month,
          dt.day,
          dt.hour,
          dt.minute,
          dt.second,
          dt.millisecond,
          dt.microsecond,
        ).millisecondsSinceEpoch ~/
        1000;
  }

  double _parseDouble(String value) {
    final parsed = double.tryParse(value.trim()) ?? 0;
    return parsed.isFinite ? parsed : 0;
  }

  bool _parseBool(String value) {
    final clean = value.trim().toLowerCase();
    return clean == 'true' || clean == '1';
  }

  EngineType _mapEngineType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'piston':
        return EngineType.piston;
      case 'turboprop':
        return EngineType.turboprop;
      case 'jet':
      case 'turbofan':
        return EngineType.jet;
      case 'electric':
        return EngineType.electric;
      default:
        return EngineType.jet;
    }
  }

  Future<_IdResult> _getOrCreateAirport({
    required String icao,
    required String iata,
    required String name,
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required String latitudeRaw,
    required String longitudeRaw,
    required Map<String, Airport> cache,
    required SimpleLogImportOptions options,
  }) async {
    final key = _airportKey(icao);
    final existing = cache[key];
    if (existing != null) {
      if (!options.overrideAirportValues) {
        return _IdResult(id: existing.id, created: false);
      }

      final hasIata = iata.trim().isNotEmpty;
      final hasName = name.trim().isNotEmpty;
      final hasCity = city.trim().isNotEmpty;
      final hasCountry = country.trim().isNotEmpty;
      final hasLat = latitudeRaw.trim().isNotEmpty;
      final hasLon = longitudeRaw.trim().isNotEmpty;

      final mergedIata = _mergeText(
        existing.iata,
        iata,
        options.overrideAirportValues,
        hasIata,
      );
      final mergedName = _mergeText(
        existing.name,
        name,
        options.overrideAirportValues,
        hasName,
      );
      final mergedCity = _mergeText(
        existing.city,
        city,
        options.overrideAirportValues,
        hasCity,
      );
      final mergedCountry = _mergeText(
        existing.country,
        country,
        options.overrideAirportValues,
        hasCountry,
      );
      final mergedLat = _mergeDouble(
        existing.latitude,
        latitude,
        options.overrideAirportValues,
        hasLat,
      );
      final mergedLon = _mergeDouble(
        existing.longitude,
        longitude,
        options.overrideAirportValues,
        hasLon,
      );

      final hasAirportChanges =
          mergedIata != existing.iata ||
          mergedName != existing.name ||
          mergedCity != existing.city ||
          mergedCountry != existing.country ||
          mergedLat != existing.latitude ||
          mergedLon != existing.longitude;

      if (!hasAirportChanges) {
        return _IdResult(id: existing.id, created: false);
      }

      await (db.update(
        db.airports,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        AirportsCompanion(
          iata: Value(mergedIata),
          name: Value(mergedName),
          city: Value(mergedCity),
          country: Value(mergedCountry),
          latitude: Value(mergedLat),
          longitude: Value(mergedLon),
        ),
      );

      cache[key] = Airport(
        id: existing.id,
        icao: existing.icao,
        iata: mergedIata,
        name: mergedName,
        city: mergedCity,
        country: mergedCountry,
        latitude: mergedLat,
        longitude: mergedLon,
        isFavorite: existing.isFavorite,
        isLocked: existing.isLocked,
      );
      return _IdResult(id: existing.id, created: false);
    }
    final id = await db
        .into(db.airports)
        .insert(
          AirportsCompanion.insert(
            icao: icao.toUpperCase(),
            iata: iata.trim().isEmpty ? const Value(null) : Value(iata),
            name: name.trim().isEmpty ? const Value(null) : Value(name),
            city: city.trim().isEmpty ? const Value(null) : Value(city),
            country: country.trim().isEmpty
                ? const Value(null)
                : Value(country),
            latitude: latitude,
            longitude: longitude,
            isFavorite: false,
            isLocked: false,
          ),
        );
    cache[key] = Airport(
      id: id,
      icao: icao.toUpperCase(),
      iata: iata.trim().isEmpty ? null : iata.trim(),
      name: name.trim().isEmpty ? null : name.trim(),
      city: city.trim().isEmpty ? null : city.trim(),
      country: country.trim().isEmpty ? null : country.trim(),
      latitude: latitude,
      longitude: longitude,
      isFavorite: false,
      isLocked: false,
    );
    return _IdResult(id: id, created: true);
  }

  Future<_IdResult?> _getOrCreateAircraftType({
    required String code,
    required String family,
    required EngineType engineType,
    required int mtow,
    required int engineCount,
    required bool multiPilot,
    required bool complex,
    required bool efis,
    required bool highPerformance,
    required Map<String, AircraftType> cache,
    required SimpleLogImportOptions options,
  }) async {
    final clean = code.trim();
    if (clean.isEmpty) return null;
    final key = _normalizeKey(clean);
    final existing = cache[key];
    if (existing != null) {
      if (!options.overrideAircraftTypeValues) {
        return _IdResult(id: existing.id, created: false);
      }

      final mergedFamily = _mergeText(
        existing.family,
        family,
        options.overrideAircraftTypeValues,
        family.trim().isNotEmpty,
      );
      final mergedLongName = _mergeText(
        existing.longName,
        clean,
        options.overrideAircraftTypeValues,
        clean.isNotEmpty,
      );
      final mergedEngineType = !options.overrideAircraftTypeValues
          ? existing.engineType
          : engineType;
      final mergedMtow = _mergeInt(
        existing.mtow,
        mtow,
        options.overrideAircraftTypeValues,
        mtow > 0,
      );
      final mergedEngineCount = _mergeInt(
        existing.engineCount,
        engineCount == 0 ? 1 : engineCount,
        options.overrideAircraftTypeValues,
        engineCount > 0,
      );
      final mergedMultiPilot = !options.overrideAircraftTypeValues
          ? existing.multiPilot
          : multiPilot;
      final mergedComplex = !options.overrideAircraftTypeValues
          ? existing.complex
          : complex;
      final mergedEfis = !options.overrideAircraftTypeValues
          ? existing.efis
          : efis;
      final mergedHighPerformance = !options.overrideAircraftTypeValues
          ? existing.highPerformance
          : highPerformance;

      final hasAircraftTypeChanges =
          (mergedFamily ?? clean) != existing.family ||
          (mergedLongName ?? clean) != existing.longName ||
          mergedEngineType != existing.engineType ||
          mergedMtow != existing.mtow ||
          mergedEngineCount != existing.engineCount ||
          mergedMultiPilot != existing.multiPilot ||
          mergedComplex != existing.complex ||
          mergedEfis != existing.efis ||
          mergedHighPerformance != existing.highPerformance;

      if (!hasAircraftTypeChanges) {
        return _IdResult(id: existing.id, created: false);
      }

      await (db.update(
        db.aircraftTypes,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        AircraftTypesCompanion(
          family: Value(mergedFamily ?? clean),
          longName: Value(mergedLongName ?? clean),
          engineType: Value(mergedEngineType),
          mtow: Value(mergedMtow),
          engineCount: Value(mergedEngineCount),
          multiPilot: Value(mergedMultiPilot),
          complex: Value(mergedComplex),
          efis: Value(mergedEfis),
          highPerformance: Value(mergedHighPerformance),
        ),
      );

      cache[key] = existing.copyWith(
        family: mergedFamily ?? clean,
        longName: mergedLongName ?? clean,
        engineType: mergedEngineType,
        mtow: mergedMtow,
        engineCount: mergedEngineCount,
        multiPilot: mergedMultiPilot,
        complex: mergedComplex,
        efis: mergedEfis,
        highPerformance: mergedHighPerformance,
      );
      return _IdResult(id: existing.id, created: false);
    }
    final id = await db
        .into(db.aircraftTypes)
        .insert(
          AircraftTypesCompanion.insert(
            code: clean,
            family: family.trim().isEmpty ? clean : family.trim(),
            longName: clean,
            manufacturer: const Value(null),
            category: AircraftCategory.landplane,
            engineType: engineType,
            mtow: mtow,
            engineCount: engineCount == 0 ? 1 : engineCount,
            multiPilot: multiPilot,
            complex: complex,
            efis: efis,
            highPerformance: highPerformance,
            isLocked: false,
          ),
        );
    cache[key] = AircraftType(
      id: id,
      code: clean,
      family: family.trim().isEmpty ? clean : family.trim(),
      longName: clean,
      manufacturer: null,
      category: AircraftCategory.landplane,
      engineType: engineType,
      mtow: mtow,
      engineCount: engineCount == 0 ? 1 : engineCount,
      multiPilot: multiPilot,
      complex: complex,
      efis: efis,
      highPerformance: highPerformance,
      isLocked: false,
    );
    return _IdResult(id: id, created: true);
  }

  Future<_IdResult?> _getOrCreateAircraft({
    required String registration,
    required int? aircraftTypeId,
    required int? mtow,
    int? typeMtow,
    required bool isSimulator,
    required Map<String, Aircraft> cache,
    required SimpleLogImportOptions options,
  }) async {
    if (registration.isEmpty || aircraftTypeId == null) return null;
    final normalizedMtow = _normalizeAircraftMtow(
      aircraftMtow: mtow,
      typeMtow: typeMtow,
    );
    final key = _normalizeKey(registration);
    final existing = cache[key];
    if (existing != null) {
      if (!options.overrideAircraftValues) {
        return _IdResult(id: existing.id, created: false);
      }

      final mergedTypeId = !options.overrideAircraftValues
          ? existing.aircraftTypeId
          : aircraftTypeId;
      final mergedMtow = _mergeNullableInt(
        existing.mtow,
        normalizedMtow,
        options.overrideAircraftValues,
        normalizedMtow != null,
      );
      final mergedSimulator = !options.overrideAircraftValues
          ? existing.isSimulator
          : isSimulator;

      final hasAircraftChanges =
          mergedTypeId != existing.aircraftTypeId ||
          mergedMtow != existing.mtow ||
          mergedSimulator != existing.isSimulator;

      if (!hasAircraftChanges) {
        return _IdResult(id: existing.id, created: false);
      }

      await (db.update(
        db.aircrafts,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        AircraftsCompanion(
          aircraftTypeId: Value(mergedTypeId),
          mtow: Value(mergedMtow),
          isSimulator: Value(mergedSimulator),
        ),
      );

      cache[key] = existing.copyWith(
        aircraftTypeId: mergedTypeId,
        mtow: Value(mergedMtow),
        isSimulator: mergedSimulator,
      );
      return _IdResult(id: existing.id, created: false);
    }
    final id = await db
        .into(db.aircrafts)
        .insert(
          AircraftsCompanion.insert(
            aircraftTypeId: aircraftTypeId,
            registration: registration,
            mtow: Value(normalizedMtow),
            isSimulator: isSimulator,
            isFavorite: false,
            isLocked: false,
          ),
        );
    cache[key] = Aircraft(
      id: id,
      aircraftTypeId: aircraftTypeId,
      registration: registration,
      mtow: normalizedMtow,
      isSimulator: isSimulator,
      isFavorite: false,
      isLocked: false,
      notes: null,
    );
    return _IdResult(id: id, created: true);
  }

  int? _normalizeAircraftMtow({required int? aircraftMtow, int? typeMtow}) {
    if (aircraftMtow == null || aircraftMtow <= 0) return null;
    if (typeMtow != null && typeMtow > 0 && aircraftMtow == typeMtow) {
      return null;
    }
    return aircraftMtow;
  }

  Future<_IdResult?> _getOrCreateCrew({
    required String name,
    required String email,
    required String phone,
    required String notes,
    required Map<String, CrewData> cache,
    required SimpleLogImportOptions options,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) return null;
    final key = _crewKey(clean);
    final existing = cache[key];
    if (existing != null) {
      if (!options.overrideExistingValues) {
        return _IdResult(id: existing.id, created: false);
      }

      final hasEmail = email.trim().isNotEmpty;
      final hasPhone = phone.trim().isNotEmpty;
      final hasNotes = notes.trim().isNotEmpty;

      final mergedEmail = _mergeText(
        existing.email,
        email,
        options.overrideExistingValues,
        hasEmail,
      );
      final mergedPhone = _mergeText(
        existing.phone,
        phone,
        options.overrideExistingValues,
        hasPhone,
      );
      final mergedNotes = _mergeText(
        existing.notes,
        notes,
        options.overrideExistingValues,
        hasNotes,
      );

      final hasCrewChanges =
          mergedEmail != existing.email ||
          mergedPhone != existing.phone ||
          mergedNotes != existing.notes;

      if (!hasCrewChanges) {
        return _IdResult(id: existing.id, created: false);
      }

      await (db.update(
        db.crew,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        CrewCompanion(
          email: Value(mergedEmail),
          phone: Value(mergedPhone),
          notes: Value(mergedNotes),
        ),
      );

      cache[key] = existing.copyWith(
        email: Value(mergedEmail),
        phone: Value(mergedPhone),
        notes: Value(mergedNotes),
      );
      return _IdResult(id: existing.id, created: false);
    }
    final id = await db
        .into(db.crew)
        .insert(
          CrewCompanion.insert(
            name: clean,
            email: email.trim().isEmpty ? const Value(null) : Value(email),
            notes: notes.trim().isEmpty ? const Value(null) : Value(notes),
            phone: phone.trim().isEmpty ? const Value(null) : Value(phone),
            picture: const Value(null),
            isSelf: false,
            isFavorite: false,
            isLocked: false,
          ),
        );
    cache[key] = CrewData(
      id: id,
      name: clean,
      email: email.trim().isEmpty ? null : email.trim(),
      notes: notes.trim().isEmpty ? null : notes.trim(),
      phone: phone.trim().isEmpty ? null : phone.trim(),
      picture: null,
      isSelf: false,
      isFavorite: false,
      isLocked: false,
    );
    return _IdResult(id: id, created: true);
  }
}

enum _Role { pic, picus, sic, dual, instructor, none }

String _normalizeKey(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[\s\-]'), '');
}

String _airportKey(String icao) => icao.trim().toLowerCase();

String _crewKey(String name) => name.trim().toLowerCase();

bool _hasCoords(double latDep, double longDep, double latArr, double longArr) {
  return (latDep != 0 || longDep != 0) && (latArr != 0 || longArr != 0);
}

double _calculateDistanceNm(
  double latDep,
  double longDep,
  double latArr,
  double longArr,
) {
  if (!latDep.isFinite ||
      !longDep.isFinite ||
      !latArr.isFinite ||
      !longArr.isFinite) {
    return 0;
  }
  final dLat = _degToRad(latArr - latDep);
  final dLon = _degToRad(longArr - longDep);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(latDep)) *
          cos(_degToRad(latArr)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * asin(sqrt(a));
  return 3443.89849 * c;
}

String? _mergeText(
  String? existing,
  String incoming,
  bool overrideExistingValues,
  bool hasIncoming,
) {
  final clean = incoming.trim();
  if (!overrideExistingValues) return existing;
  return hasIncoming ? (clean.isEmpty ? null : clean) : existing;
}

double _mergeDouble(
  double existing,
  double incoming,
  bool overrideExistingValues,
  bool hasIncoming,
) {
  if (!overrideExistingValues) return existing;
  return hasIncoming ? incoming : existing;
}

int _mergeInt(
  int existing,
  int incoming,
  bool overrideExistingValues,
  bool hasIncoming,
) {
  if (!overrideExistingValues) return existing;
  return hasIncoming ? incoming : existing;
}

int? _mergeNullableInt(
  int? existing,
  int? incoming,
  bool overrideExistingValues,
  bool hasIncoming,
) {
  if (!overrideExistingValues) return existing;
  return hasIncoming ? incoming : existing;
}

int _calculateFactoredMinutes({
  required int totalMinutes,
  required int percent,
  required int subtractMinutes,
  required int minimumMinutes,
}) {
  final clampedPercent = percent.clamp(0, 100);
  var result = ((totalMinutes * clampedPercent) / 100).round();
  result -= subtractMinutes;
  if (result < 0) result = 0;
  if (result < minimumMinutes) {
    result = minimumMinutes;
  }
  if (result > totalMinutes) result = totalMinutes;
  return result;
}

_Role _pickRole(int pic, int picus, int sic, int dual, int instructor) {
  if (pic > 0) return _Role.pic;
  if (picus > 0) return _Role.picus;
  if (sic > 0) return _Role.sic;
  if (dual > 0) return _Role.dual;
  if (instructor > 0) return _Role.instructor;
  return _Role.none;
}

String _canonicalPilotFunction(
  String raw, {
  required int takeoffCount,
  required int landingCount,
}) {
  final normalized = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  switch (normalized) {
    case 'PF':
      return 'PF';
    case 'PNF':
    case 'PM':
      return 'PNF';
    case 'PF/PNF':
      return 'PF/PNF';
    case 'PNF/PF':
    case 'PM/PF':
      return 'PNF/PF';
    case 'IRP3':
      return 'IRP 3';
    case 'IRP4':
      return 'IRP 4';
  }
  if (takeoffCount > 0 && landingCount > 0) return 'PF';
  if (takeoffCount > 0 && landingCount == 0) return 'PF/PNF';
  if (takeoffCount == 0 && landingCount > 0) return 'PNF/PF';
  return 'PNF';
}

int _applyIrpFactoring({
  required int totalMinutes,
  required String pilotFunction,
  required int irp3Percent,
  required int irp3SubtractMinutes,
  required int irp4Percent,
  required int irp4SubtractMinutes,
}) {
  final normalized = pilotFunction.trim().toUpperCase().replaceAll(' ', '');
  if (normalized != 'IRP3' && normalized != 'IRP4') {
    return totalMinutes;
  }
  final percent = normalized == 'IRP3' ? irp3Percent : irp4Percent;
  final subtract = normalized == 'IRP3'
      ? irp3SubtractMinutes
      : irp4SubtractMinutes;
  var base = totalMinutes - subtract;
  if (base < 0) base = 0;
  final clampedPercent = percent.clamp(0, 100);
  return ((base * clampedPercent) / 100).round();
}

DateTime? _parseSouthwestDateTime(String date, String time) {
  try {
    final d = DateFormat('yyyy-MM-dd').parseStrict(date.trim());
    final parts = time.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return _dallasLocalToUtc(
      year: d.year,
      month: d.month,
      day: d.day,
      hour: hour,
      minute: minute,
    );
  } catch (_) {
    return null;
  }
}

int _parseBlockHhMmToMinutes(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 0;
  final raw = int.tryParse(digits) ?? 0;
  if (digits.length <= 2) return raw;
  final hours = raw ~/ 100;
  final mins = raw % 100;
  if (mins < 0 || mins > 59) return 0;
  return hours * 60 + mins;
}

String _southwestFamily(String typeCode) {
  final clean = typeCode.trim().toUpperCase();
  if (clean.isEmpty) return 'UNKNOWN';
  final split = clean.split('-');
  return split.isEmpty ? clean : split.first;
}

_SouthwestCopilot _parseSouthwestCoPilot(String raw) {
  final clean = raw.trim();
  if (clean.isEmpty || clean.toLowerCase().contains('deadheading')) {
    return const _SouthwestCopilot(name: '', staffNumber: null);
  }
  final staffMatch = RegExp(r'\[(\d+)\]').firstMatch(clean);
  final staffNumber = staffMatch?.group(1);
  var name = clean.replaceAll(RegExp(r'\[[^\]]*\]'), '');
  name = name.replaceAll('*CKP*', ' ');
  name = name.replaceAll(RegExp(r'^(CA|CP|FO)\s+', caseSensitive: false), '');
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  return _SouthwestCopilot(name: name, staffNumber: staffNumber);
}

String _buildSouthwestNotes({
  required String flightNumber,
  required bool includeFlightNumber,
}) {
  final lines = <String>[];
  if (includeFlightNumber && flightNumber.trim().isNotEmpty) {
    lines.add('Flight Number: ${flightNumber.trim()}');
  }
  return lines.join('\n');
}

String _flightDateKey(DateTime departure, DateTime? arrival) {
  return '${departure.millisecondsSinceEpoch}|${arrival?.millisecondsSinceEpoch ?? -1}';
}

CrewPosition _normalizeSelfPosition(CrewPosition value) {
  if (value == CrewPosition.pic || value == CrewPosition.sic) return value;
  return CrewPosition.sic;
}

CrewPosition _oppositePosition(CrewPosition selfPosition) {
  return selfPosition == CrewPosition.sic ? CrewPosition.pic : CrewPosition.sic;
}

DateTime _dallasLocalToUtc({
  required int year,
  required int month,
  required int day,
  required int hour,
  required int minute,
}) {
  final local = DateTime(year, month, day, hour, minute);
  final dstStart = _secondSunday(year, 3, 2); // 02:00 local
  final dstEnd = _firstSunday(year, 11, 2); // 02:00 local
  final isDst = !local.isBefore(dstStart) && local.isBefore(dstEnd);
  final offsetHours = isDst ? 5 : 6; // Dallas: UTC-5 (DST), UTC-6 (standard)
  final shiftedUtc = DateTime.utc(
    year,
    month,
    day,
    hour,
    minute,
  ).add(Duration(hours: offsetHours));
  // Store as wall-clock UTC (non-timezone-shifting DateTime) to match app model.
  return DateTime(
    shiftedUtc.year,
    shiftedUtc.month,
    shiftedUtc.day,
    shiftedUtc.hour,
    shiftedUtc.minute,
  );
}

DateTime _firstSunday(int year, int month, int hour) {
  final firstDay = DateTime(year, month, 1, hour);
  final delta = (DateTime.sunday - firstDay.weekday + 7) % 7;
  return firstDay.add(Duration(days: delta));
}

DateTime _secondSunday(int year, int month, int hour) {
  return _firstSunday(year, month, hour).add(const Duration(days: 7));
}

double _degToRad(double angleDeg) => angleDeg * pi / 180.0;

class _IdResult {
  const _IdResult({required this.id, required this.created});

  final int id;
  final bool created;
}

class _SouthwestCopilot {
  const _SouthwestCopilot({required this.name, required this.staffNumber});

  final String name;
  final String? staffNumber;
}

class _ExistingFlightData {
  const _ExistingFlightData({
    required this.flightId,
    required this.departureTimelineId,
  });

  final int flightId;
  final int departureTimelineId;
}
