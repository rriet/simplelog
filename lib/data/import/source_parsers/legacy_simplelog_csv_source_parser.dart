import 'dart:math';

import 'package:intl/intl.dart';
import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/core/flight/ifr_calculation.dart';
import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';

/// Parses legacy SimpleLog CSV exports into normalized import records.
class LegacySimpleLogCsvSourceParser {
  /// Creates a parser.
  const LegacySimpleLogCsvSourceParser();

  /// Parses legacy CSV content into a normalized batch.
  NormalizedImportBatch parse(
    String content, {
    SimpleLogImportOptions options = const SimpleLogImportOptions(),
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    if (rows.isEmpty) {
      return NormalizedImportBatch(
        totalRows: 0,
        records: const [],
        entityOptions: ImportedEntityOptions(
          overrideAirportValues: options.overrideAirportValues,
          overrideAircraftValues: options.overrideAircraftValues,
          overrideAircraftTypeValues: options.overrideAircraftTypeValues,
          overrideCrewValues: options.overrideExistingValues,
        ),
      );
    }

    final header = rows.first;
    final index = <String, int>{};
    for (var i = 0; i < header.length; i += 1) {
      index[SimpleLogCsvSupport.clean(header[i])] = i;
    }

    int readIndex(String name) => index[SimpleLogCsvSupport.clean(name)] ?? -1;

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
    final records = <NormalizedImportRecord>[];
    var skipped = 0;
    var errors = 0;
    var progressOrdinal = 0;

    for (var rowIndex = rows.length - 1; rowIndex >= 1; rowIndex -= 1) {
      progressOrdinal += 1;
      final row = rows[rowIndex];
      if (row.isEmpty) continue;

      try {
        String get(int idx) => idx >= 0 && idx < row.length ? row[idx] : '';

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

        final departureDate = _resolveDepartureDateTime(
          depEpochText: get(idxDepEpoch),
          dateFormat: dateFormat,
          dateText: get(idxDate),
          timeText: get(idxDepTime),
        );
        if (departureDate == null) {
          skipped += 1;
          continue;
        }

        final arrivalDate = _resolveArrivalDateTime(
          arrEpochText: get(idxArrEpoch),
          dateFormat: dateFormat,
          dateText: get(idxDate),
          depTimeText: get(idxDepTime),
          arrTimeText: get(idxArrTime),
        );

        final typeMtow = _parseInt(get(idxModelMtow));
        final typeMultiPilot = _parseBool(get(idxModelMultiPilot));
        final aircraftType = ImportedAircraftTypeDraft(
          code: get(idxModelCode).trim(),
          family: get(idxModelGroup).trim(),
          longName: get(idxModelCode).trim(),
          manufacturer: '',
          category: AircraftCategory.landplane,
          engineType: _mapEngineType(get(idxModelEngine).trim()),
          mtow: typeMtow,
          engineCount: _parseBool(get(idxModelMultiEngine)) ? 2 : 1,
          multiPilot: typeMultiPilot,
          complex: typeMultiPilot,
          efis: _parseBool(get(idxModelEfis)),
          highPerformance: typeMultiPilot,
        );

        final aircraft = ImportedAircraftDraft(
          registration: get(idxReg).trim().toUpperCase(),
          mtow: _parseInt(get(idxAircraftMtow)),
          isSimulator: _parseBool(get(idxAircraftSim)),
        );
        if (aircraft.registration.isEmpty || aircraftType.code.isEmpty) {
          skipped += 1;
          continue;
        }

        final totalMinutesRaw = _parseInt(get(idxTotalMinutes));
        var computedTotal = totalMinutesRaw;
        final shouldDeriveMissingBlockTime = options.recalculateTotalTime;
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

        FlightCalculations? calculations;
        if (arrivalDate != null && _hasCoords(depLat, depLon, arrLat, arrLon)) {
          final depEpoch = _parseInt(get(idxDepEpoch)) > 0
              ? _parseInt(get(idxDepEpoch))
              : _wallClockAsUtcEpochSeconds(departureDate);
          final arrEpoch = _parseInt(get(idxArrEpoch)) > 0
              ? _parseInt(get(idxArrEpoch))
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
        final distanceValue = _calculateDistanceNm(
          depLat,
          depLon,
          arrLat,
          arrLon,
        );
        final distanceNm = distanceValue.isFinite ? distanceValue.round() : 0;

        if (aircraft.isSimulator) {
          final crewAssignments = _buildSimulatorCrewAssignments(
            picName: get(idxPicName),
            picEmail: get(idxPicEmail),
            picPhone: get(idxPicPhone),
            picNotes: get(idxPicComments),
            sicName: get(idxSicName),
            sicEmail: get(idxSicEmail),
            sicPhone: get(idxSicPhone),
            sicNotes: get(idxSicComments),
          );
          records.add(
            NormalizedSimulatorRecord(
              progressOrdinal: progressOrdinal,
              aircraftType: aircraftType,
              aircraft: aircraft,
              startDateTime: departureDate,
              endDateTime: arrivalDate,
              timeTotal: _parseInt(get(idxSimulatorMinutes)) > 0
                  ? _parseInt(get(idxSimulatorMinutes))
                  : totalMinutesRaw,
              remarks: get(idxRemarks),
              notes: get(idxNotes),
              crewAssignments: crewAssignments,
            ),
          );
          continue;
        }

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
          crossCountryMinutes = distanceNm >= options.crossCountryThresholdNm
              ? computedTotal
              : 0;
        }

        var ifrMinutes = _parseInt(get(idxIfrMinutes));
        if (options.recalculateIfrTime && computedTotal > 0) {
          ifrMinutes = calculateIfrMinutes(
            totalMinutes: computedTotal,
            percent: options.ifrPercent,
            subtractMinutes: options.ifrSubtractMinutes,
            minimumMinutes: options.ifrMinimumMinutes,
          );
        }

        final crewAssignments = _buildFlightCrewAssignments(
          picName: get(idxPicName),
          picEmail: get(idxPicEmail),
          picPhone: get(idxPicPhone),
          picNotes: get(idxPicComments),
          sicName: get(idxSicName),
          sicEmail: get(idxSicEmail),
          sicPhone: get(idxSicPhone),
          sicNotes: get(idxSicComments),
          picMinutes: picMinutes,
          picusMinutes: picusMinutes,
          sicMinutes: sicMinutes,
          dualMinutes: dualMinutes,
        );

        records.add(
          NormalizedFlightRecord(
            progressOrdinal: progressOrdinal,
            departureAirport: ImportedAirportDraft(
              icao: depIcao,
              iata: get(idxDepIata),
              name: get(idxDepName),
              city: get(idxDepCity),
              country: get(idxDepCountry),
              latitude: depLat,
              longitude: depLon,
              latitudeRaw: depLatRaw,
              longitudeRaw: depLonRaw,
            ),
            arrivalAirport: ImportedAirportDraft(
              icao: arrIcao,
              iata: get(idxArrIata),
              name: get(idxArrName),
              city: get(idxArrCity),
              country: get(idxArrCountry),
              latitude: arrLat,
              longitude: arrLon,
              latitudeRaw: arrLatRaw,
              longitudeRaw: arrLonRaw,
            ),
            aircraftType: aircraftType,
            aircraft: aircraft,
            departureDateTime: departureDate,
            arrivalDateTime: arrivalDate,
            timePicMinutes: picMinutes,
            timePicusMinutes: picusMinutes,
            timeSicMinutes: sicMinutes,
            timeDualMinutes: dualMinutes,
            timeInstructorMinutes: instructorMinutes,
            timeIfrMinutes: ifrMinutes,
            timeNightMinutes: nightMinutes,
            timeCrossCountryMinutes: crossCountryMinutes,
            timeCustom1Minutes: _parseInt(get(idxCustom1)),
            timeCustom2Minutes: _parseInt(get(idxCustom2)),
            timeCustom3Minutes: _parseInt(get(idxCustom3)),
            timeCustom4Minutes: _parseInt(get(idxCustom4)),
            timeFlightMinutes: 0,
            timeBlockMinutes: computedTotal,
            timeTotalBlockMinutes: totalBlockMinutes,
            distanceNm: distanceNm,
            ifrApproaches: _parseInt(get(idxIfrApproaches)),
            takeoffsDay: takeoffDay,
            takeoffsNight: takeoffNight,
            landingsDay: landingDay,
            landingsNight: landingNight,
            pilotFunction: pilotFunction,
            approachType: get(idxApproachType),
            remarks: get(idxRemarks),
            notes: get(idxNotes),
            crewAssignments: crewAssignments,
          ),
        );
      } on Object catch (_) {
        errors += 1;
      }
    }

    return NormalizedImportBatch(
      totalRows: rows.length - 1,
      records: records,
      entityOptions: ImportedEntityOptions(
        overrideAirportValues: options.overrideAirportValues,
        overrideAircraftValues: options.overrideAircraftValues,
        overrideAircraftTypeValues: options.overrideAircraftTypeValues,
        overrideCrewValues: options.overrideExistingValues,
      ),
      skippedRows: skipped,
      errorRows: errors,
    );
  }
}

List<ImportedCrewAssignmentDraft> _buildSimulatorCrewAssignments({
  required String picName,
  required String picEmail,
  required String picPhone,
  required String picNotes,
  required String sicName,
  required String sicEmail,
  required String sicPhone,
  required String sicNotes,
}) {
  final assignments = <ImportedCrewAssignmentDraft>[];
  if (picName.trim().isNotEmpty) {
    assignments.add(
      ImportedCrewAssignmentDraft.crew(
        position: CrewPosition.pic,
        crew: ImportedCrewDraft(
          name: picName.trim(),
          email: picEmail,
          phone: picPhone,
          notes: picNotes,
        ),
      ),
    );
  }
  if (sicName.trim().isNotEmpty) {
    assignments.add(
      ImportedCrewAssignmentDraft.crew(
        position: CrewPosition.sic,
        crew: ImportedCrewDraft(
          name: sicName.trim(),
          email: sicEmail,
          phone: sicPhone,
          notes: sicNotes,
        ),
      ),
    );
  }
  return assignments;
}

List<ImportedCrewAssignmentDraft> _buildFlightCrewAssignments({
  required String picName,
  required String picEmail,
  required String picPhone,
  required String picNotes,
  required String sicName,
  required String sicEmail,
  required String sicPhone,
  required String sicNotes,
  required int picMinutes,
  required int picusMinutes,
  required int sicMinutes,
  required int dualMinutes,
}) {
  final assignments = _buildSimulatorCrewAssignments(
    picName: picName,
    picEmail: picEmail,
    picPhone: picPhone,
    picNotes: picNotes,
    sicName: sicName,
    sicEmail: sicEmail,
    sicPhone: sicPhone,
    sicNotes: sicNotes,
  );
  final hasSelfNameProvided =
      picName.trim().toLowerCase() == 'self' ||
      sicName.trim().toLowerCase() == 'self';
  if (picName.trim().isEmpty || sicName.trim().isEmpty) {
    if (!hasSelfNameProvided) {
      assignments.add(
        ImportedCrewAssignmentDraft.self(
          position: _resolveSelfCrewPosition(
            picMinutes: picMinutes,
            picusMinutes: picusMinutes,
            sicMinutes: sicMinutes,
            dualMinutes: dualMinutes,
          ),
          createSelfIfMissing: true,
        ),
      );
    }
  }
  return assignments;
}

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
  } on Object catch (_) {
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

DateTime? _resolveDepartureDateTime({
  required String depEpochText,
  required DateFormat dateFormat,
  required String dateText,
  required String timeText,
}) {
  final depEpoch = _parseInt(depEpochText);
  if (depEpoch > 0) {
    return DateTime.fromMillisecondsSinceEpoch(depEpoch * 1000, isUtc: true);
  }
  return _parseDateTime(dateFormat, dateText, timeText);
}

DateTime? _resolveArrivalDateTime({
  required String arrEpochText,
  required DateFormat dateFormat,
  required String dateText,
  required String depTimeText,
  required String arrTimeText,
}) {
  if (_isMissingTime(depTimeText) && _isMissingTime(arrTimeText)) {
    return null;
  }
  final arrEpoch = _parseInt(arrEpochText);
  if (arrEpoch > 0) {
    return DateTime.fromMillisecondsSinceEpoch(arrEpoch * 1000, isUtc: true);
  }
  return _parseArrivalDateTime(dateFormat, dateText, depTimeText, arrTimeText);
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

double _degToRad(double angleDeg) => angleDeg * pi / 180.0;

enum _Role { pic, picus, sic, dual, instructor, none }

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
  return PilotFunctionLogic.canonicalize(
    raw,
    takeoffCount: takeoffCount,
    landingCount: landingCount,
  );
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
  if (normalized != 'IRP3' && normalized != 'IRP4') return totalMinutes;
  final percent = normalized == 'IRP3' ? irp3Percent : irp4Percent;
  final subtract = normalized == 'IRP3'
      ? irp3SubtractMinutes
      : irp4SubtractMinutes;
  var base = totalMinutes - subtract;
  if (base < 0) base = 0;
  return ((base * percent.clamp(0, 100)) / 100).round();
}

CrewPosition _resolveSelfCrewPosition({
  required int picMinutes,
  required int picusMinutes,
  required int sicMinutes,
  required int dualMinutes,
}) {
  if (picMinutes > 0) return CrewPosition.pic;
  if (picusMinutes > 0) return CrewPosition.picus;
  if (sicMinutes > 0) return CrewPosition.sic;
  if (dualMinutes > 0) return CrewPosition.trainee;
  return CrewPosition.other;
}
