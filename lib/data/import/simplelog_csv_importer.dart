import 'dart:math';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';

class SimpleLogImportResult {
  const SimpleLogImportResult({
    required this.totalRows,
    required this.flights,
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
      for (var rowIndex = 1; rowIndex < rows.length; rowIndex += 1) {
        if (rowIndex % 200 == 0) {
          onProgress?.call(rowIndex - 1, totalRows);
        }
        final row = rows[rowIndex];
        if (row.isEmpty) continue;
        try {

        String get(int idx) =>
            idx >= 0 && idx < row.length ? row[idx] : '';

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
        if (aircraftTypeResult != null &&
            aircraftTypeResult.created) {
          aircraftTypes += 1;
        }
        final aircraftTypeId = aircraftTypeResult?.id;

        final registration = get(idxReg).trim().toUpperCase();
        final aircraftId = await _getOrCreateAircraft(
          registration: registration,
          aircraftTypeId: aircraftTypeId,
          mtow: _parseInt(get(idxAircraftMtow)),
          isSimulator: _parseBool(get(idxAircraftSim)),
          cache: aircraftCache,
          options: options,
        );
        if (aircraftId == null) {
          skipped += 1;
          continue;
        }
        if (aircraftId.created) aircrafts += 1;

        final departureDate = _parseDateTime(
          dateFormat,
          dateText,
          depTimeText,
        );
        if (departureDate == null) {
          skipped += 1;
          continue;
        }

        DateTime? arrivalDate;
        if (_isMissingTime(depTimeText) && _isMissingTime(arrTimeText)) {
          arrivalDate = null;
        } else {
          arrivalDate = _parseArrivalDateTime(
            dateFormat,
            dateText,
            depTimeText,
            arrTimeText,
          );
        }

        final departureTimelineId = await db.into(db.timeLines).insert(
              TimeLinesCompanion.insert(eventDateTime: departureDate),
            );

        final isSimulator = _parseBool(get(idxAircraftSim));
        int? flightId;
        int? simId;

        final totalMinutesRaw = _parseInt(get(idxTotalMinutes));
        var computedTotal = totalMinutesRaw;
        if (computedTotal == 0 && arrivalDate != null) {
          computedTotal = arrivalDate.difference(departureDate).inMinutes;
        }

        final distanceValue = _calculateDistanceNm(
          depLat,
          depLon,
          arrLat,
          arrLon,
        );
        final distanceNm =
            distanceValue.isFinite ? distanceValue.round() : 0;

        FlightCalculations? calculations;
        if (arrivalDate != null &&
            _hasCoords(depLat, depLon, arrLat, arrLon)) {
          calculations = FlightCalculations(
            latDep: depLat,
            longDep: depLon,
            latArr: arrLat,
            longArr: arrLon,
            depTimeEpochSeconds: departureDate.toUtc().millisecondsSinceEpoch ~/
                1000,
            arrTimeEpochSeconds: arrivalDate.toUtc().millisecondsSinceEpoch ~/
                1000,
          );
        }

        if (isSimulator) {
          final simMinutes = _parseInt(get(idxSimulatorMinutes));
          final simTime = simMinutes > 0 ? simMinutes : totalMinutesRaw;
          simId = await db.into(db.simulatorTrainings).insert(
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
            instructorMinutes =
                role == _Role.instructor ? computedTotal : 0;
          }

          var nightMinutes = _parseInt(get(idxNightMinutes));
          if (options.recalculateNightTime && calculations != null) {
            nightMinutes = calculations.nightTimeMinutes;
          }

          var takeoffDay = _parseInt(get(idxTakeoffDay));
          var takeoffNight = _parseInt(get(idxTakeoffNight));
          var landingDay = _parseInt(get(idxLandingDay));
          var landingNight = _parseInt(get(idxLandingNight));
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

          var instrumentMinutes = 0;
          if (options.recalculateInstrument && computedTotal > 0) {
            instrumentMinutes = _calculateInstrumentMinutes(
              computedTotal,
              options,
            );
          }

          flightId = await db.into(db.flights).insert(
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
                  timeIFRMinutes: _parseInt(get(idxIfrMinutes)),
                  timeInstrumentMinutes: instrumentMinutes,
                  timeSimulatedInstrumentMinutes:
                      _parseInt(get(idxSimInstrument)),
                  timeNightMinutes: nightMinutes,
                  timeCrossCountryMinutes: crossCountryMinutes,
                  timeCustom1Minutes: _parseInt(get(idxCustom1)),
                  timeCustom2Minutes: _parseInt(get(idxCustom2)),
                  timeCustom3Minutes: _parseInt(get(idxCustom3)),
                  timeCustom4Minutes: _parseInt(get(idxCustom4)),
                  timeFlightMinutes: computedTotal,
                  timeBlockMinutes: computedTotal,
                  distanceNM: distanceNm,
                  ifrApproaches: _parseInt(get(idxIfrApproaches)),
                  takeOffsDays: takeoffDay,
                  takeOffsNight: takeoffNight,
                  landingsDay: landingDay,
                  landingsNight: landingNight,
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
              await db.into(db.flightCrewAssignments).insert(
                    FlightCrewAssignmentsCompanion.insert(
                      flightId: flightId,
                      crewId: picId.id,
                      position: _mapCrewPosition(get(idxPilotFunction)),
                    ),
                  );
            } else if (isSimulator) {
              await db.into(db.simulatorCrewAssignments).insert(
                    SimulatorCrewAssignmentsCompanion.insert(
                      simulatorId: simId!,
                      crewId: picId.id,
                      position: _mapCrewPosition(get(idxPilotFunction)),
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
              await db.into(db.flightCrewAssignments).insert(
                    FlightCrewAssignmentsCompanion.insert(
                      flightId: flightId,
                      crewId: sicId.id,
                      position: CrewPosition.sic,
                    ),
                  );
            } else if (isSimulator) {
              await db.into(db.simulatorCrewAssignments).insert(
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
      simulators: simulators,
      airports: airports,
      aircraftTypes: aircraftTypes,
      aircrafts: aircrafts,
      crew: crew,
      skipped: skipped,
      errors: errors,
    );
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
        if (char == '\r' &&
            i + 1 < content.length &&
            content[i + 1] == '\n') {
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
      return DateTime(date.year, date.month, date.day, hour, minute);
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

  int _parseInt(String value) =>
      int.tryParse(value.trim()) ?? 0;

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

  CrewPosition _mapCrewPosition(String value) {
    final clean = value.trim().toLowerCase();
    if (clean == 'pnf' || clean == 'sic') return CrewPosition.sic;
    return CrewPosition.pic;
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
      if (options.airportStrategy == MergeStrategy.keep) {
        return _IdResult(id: existing.id, created: false);
      }

      final hasIata = iata.trim().isNotEmpty;
      final hasName = name.trim().isNotEmpty;
      final hasCity = city.trim().isNotEmpty;
      final hasCountry = country.trim().isNotEmpty;
      final hasLat = latitudeRaw.trim().isNotEmpty;
      final hasLon = longitudeRaw.trim().isNotEmpty;

      final mergedIata =
          _mergeText(existing.iata, iata, options.airportStrategy, hasIata);
      final mergedName =
          _mergeText(existing.name, name, options.airportStrategy, hasName);
      final mergedCity =
          _mergeText(existing.city, city, options.airportStrategy, hasCity);
      final mergedCountry = _mergeText(
        existing.country,
        country,
        options.airportStrategy,
        hasCountry,
      );
      final mergedLat = _mergeDouble(
        existing.latitude,
        latitude,
        options.airportStrategy,
        hasLat,
      );
      final mergedLon = _mergeDouble(
        existing.longitude,
        longitude,
        options.airportStrategy,
        hasLon,
      );

      await (db.update(db.airports)..where((tbl) => tbl.id.equals(existing.id)))
          .write(
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
    final id = await db.into(db.airports).insert(
          AirportsCompanion.insert(
            icao: icao.toUpperCase(),
            iata: iata.trim().isEmpty ? const Value(null) : Value(iata),
            name: name.trim().isEmpty ? const Value(null) : Value(name),
            city: city.trim().isEmpty ? const Value(null) : Value(city),
            country: country.trim().isEmpty ? const Value(null) : Value(country),
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
    required bool efis,
    required Map<String, AircraftType> cache,
    required SimpleLogImportOptions options,
  }) async {
    final clean = code.trim();
    if (clean.isEmpty) return null;
    final key = _normalizeKey(clean);
    final existing = cache[key];
    if (existing != null) {
      if (options.aircraftTypeStrategy == MergeStrategy.keep) {
        return _IdResult(id: existing.id, created: false);
      }

      final mergedFamily = _mergeText(
        existing.family,
        family,
        options.aircraftTypeStrategy,
        family.trim().isNotEmpty,
      );
      final mergedLongName = _mergeText(
        existing.longName,
        clean,
        options.aircraftTypeStrategy,
        clean.isNotEmpty,
      );
      final mergedEngineType = options.aircraftTypeStrategy ==
              MergeStrategy.keep
          ? existing.engineType
          : engineType;
      final mergedMtow = _mergeInt(
        existing.mtow,
        mtow,
        options.aircraftTypeStrategy,
        mtow > 0,
      );
      final mergedEngineCount = _mergeInt(
        existing.engineCount,
        engineCount == 0 ? 1 : engineCount,
        options.aircraftTypeStrategy,
        engineCount > 0,
      );
      final mergedMultiPilot = options.aircraftTypeStrategy ==
              MergeStrategy.keep
          ? existing.multiPilot
          : multiPilot;
      final mergedEfis = options.aircraftTypeStrategy == MergeStrategy.keep
          ? existing.efis
          : efis;

      await (db.update(db.aircraftTypes)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        AircraftTypesCompanion(
          family: Value(mergedFamily ?? clean),
          longName: Value(mergedLongName ?? clean),
          engineType: Value(mergedEngineType),
          mtow: Value(mergedMtow),
          engineCount: Value(mergedEngineCount),
          multiPilot: Value(mergedMultiPilot),
          efis: Value(mergedEfis),
        ),
      );

      cache[key] = existing.copyWith(
        family: mergedFamily ?? clean,
        longName: mergedLongName ?? clean,
        engineType: mergedEngineType,
        mtow: mergedMtow,
        engineCount: mergedEngineCount,
        multiPilot: mergedMultiPilot,
        efis: mergedEfis,
      );
      return _IdResult(id: existing.id, created: false);
    }
    final id = await db.into(db.aircraftTypes).insert(
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
            complex: false,
            efis: efis,
            highPerformance: false,
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
      complex: false,
      efis: efis,
      highPerformance: false,
      isLocked: false,
    );
    return _IdResult(id: id, created: true);
  }

  Future<_IdResult?> _getOrCreateAircraft({
    required String registration,
    required int? aircraftTypeId,
    required int mtow,
    required bool isSimulator,
    required Map<String, Aircraft> cache,
    required SimpleLogImportOptions options,
  }) async {
    if (registration.isEmpty || aircraftTypeId == null) return null;
    final key = _normalizeKey(registration);
    final existing = cache[key];
    if (existing != null) {
      if (options.aircraftStrategy == MergeStrategy.keep) {
        return _IdResult(id: existing.id, created: false);
      }

      final mergedTypeId = options.aircraftStrategy == MergeStrategy.keep
          ? existing.aircraftTypeId
          : aircraftTypeId;
      final mergedMtow = _mergeInt(
        existing.mtow,
        mtow,
        options.aircraftStrategy,
        mtow > 0,
      );
      final mergedSimulator = options.aircraftStrategy == MergeStrategy.keep
          ? existing.isSimulator
          : isSimulator;

      await (db.update(db.aircrafts)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        AircraftsCompanion(
          aircraftTypeId: Value(mergedTypeId),
          mtow: Value(mergedMtow),
          isSimulator: Value(mergedSimulator),
        ),
      );

      cache[key] = existing.copyWith(
        aircraftTypeId: mergedTypeId,
        mtow: mergedMtow,
        isSimulator: mergedSimulator,
      );
      return _IdResult(id: existing.id, created: false);
    }
    final id = await db.into(db.aircrafts).insert(
          AircraftsCompanion.insert(
            aircraftTypeId: aircraftTypeId,
            registration: registration,
            mtow: mtow,
            isSimulator: isSimulator,
            isFavorite: false,
            isLocked: false,
          ),
        );
    cache[key] = Aircraft(
      id: id,
      aircraftTypeId: aircraftTypeId,
      registration: registration,
      mtow: mtow,
      isSimulator: isSimulator,
      isFavorite: false,
      isLocked: false,
      notes: null,
    );
    return _IdResult(id: id, created: true);
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
      if (options.crewStrategy == MergeStrategy.keep) {
        return _IdResult(id: existing.id, created: false);
      }

      final hasEmail = email.trim().isNotEmpty;
      final hasPhone = phone.trim().isNotEmpty;
      final hasNotes = notes.trim().isNotEmpty;

      final mergedEmail =
          _mergeText(existing.email, email, options.crewStrategy, hasEmail);
      final mergedPhone =
          _mergeText(existing.phone, phone, options.crewStrategy, hasPhone);
      final mergedNotes =
          _mergeText(existing.notes, notes, options.crewStrategy, hasNotes);

      await (db.update(db.crew)..where((tbl) => tbl.id.equals(existing.id)))
          .write(
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
    final id = await db.into(db.crew).insert(
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

bool _hasCoords(
  double latDep,
  double longDep,
  double latArr,
  double longArr,
) {
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
  final a = sin(dLat / 2) * sin(dLat / 2) +
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
  MergeStrategy strategy,
  bool hasIncoming,
) {
  final clean = incoming.trim();
  switch (strategy) {
    case MergeStrategy.keep:
      return existing;
    case MergeStrategy.override:
      return clean.isEmpty ? null : clean;
    case MergeStrategy.mix:
      return hasIncoming ? clean : existing;
  }
}

double _mergeDouble(
  double existing,
  double incoming,
  MergeStrategy strategy,
  bool hasIncoming,
) {
  switch (strategy) {
    case MergeStrategy.keep:
      return existing;
    case MergeStrategy.override:
      return incoming;
    case MergeStrategy.mix:
      return hasIncoming ? incoming : existing;
  }
}

int _mergeInt(
  int existing,
  int incoming,
  MergeStrategy strategy,
  bool hasIncoming,
) {
  switch (strategy) {
    case MergeStrategy.keep:
      return existing;
    case MergeStrategy.override:
      return incoming;
    case MergeStrategy.mix:
      return hasIncoming ? incoming : existing;
  }
}

int _calculateInstrumentMinutes(
  int totalMinutes,
  SimpleLogImportOptions options,
) {
  final percent = options.instrumentPercent.clamp(0, 100);
  var result = ((totalMinutes * percent) / 100).round();
  result -= options.instrumentSubtractMinutes;
  if (result < 0) result = 0;
  if (result < options.instrumentMinimumMinutes) {
    result = options.instrumentMinimumMinutes;
  }
  if (result > totalMinutes) result = totalMinutes;
  return result;
}

_Role _pickRole(
  int pic,
  int picus,
  int sic,
  int dual,
  int instructor,
) {
  if (pic > 0) return _Role.pic;
  if (picus > 0) return _Role.picus;
  if (sic > 0) return _Role.sic;
  if (dual > 0) return _Role.dual;
  if (instructor > 0) return _Role.instructor;
  return _Role.none;
}

double _degToRad(double angleDeg) => angleDeg * pi / 180.0;

class _IdResult {
  const _IdResult({required this.id, required this.created});

  final int id;
  final bool created;
}
