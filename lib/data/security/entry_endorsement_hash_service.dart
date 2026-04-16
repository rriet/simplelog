import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/converters/pilot_function_converter.dart';

/// Computes stable endorsement hashes for signed logbook entries.
class EntryEndorsementHashService {
  static const _pilotFunctionConverter = PilotFunctionConverter();

  /// Returns SHA-256 hash for a flight entry payload.
  String hashFlight({
    required Flight flight,
    required DateTime departureDateTime,
    required List<FlightCrewAssignment> crewAssignments,
    String? pilotFunctionValue,
    bool? isLockedValue,
  }) {
    final payload = <String, Object?>{
      'kind': 'flight',
      'id': flight.id,
      'aircraftId': flight.aircraftId,
      'departureAirportId': flight.departureAirportId,
      'arrivalAirportId': flight.arrivalAirportId,
      'departureDateTime': departureDateTime.toIso8601String(),
      'takeOffDateTime': flight.takeOffDateTime?.toIso8601String(),
      'landingDateTime': flight.landingDateTime?.toIso8601String(),
      'arrivalDateTime': flight.arrivalDateTime?.toIso8601String(),
      'timePICMinutes': flight.timePICMinutes,
      'timePICUSMinutes': flight.timePICUSMinutes,
      'timeSICMinutes': flight.timeSICMinutes,
      'timeDualMinutes': flight.timeDualMinutes,
      'timeInstructorMinutes': flight.timeInstructorMinutes,
      'timeIFRMinutes': flight.timeIFRMinutes,
      'timeNightMinutes': flight.timeNightMinutes,
      'timeCrossCountryMinutes': flight.timeCrossCountryMinutes,
      'timeCustom1Minutes': flight.timeCustom1Minutes,
      'timeCustom2Minutes': flight.timeCustom2Minutes,
      'timeCustom3Minutes': flight.timeCustom3Minutes,
      'timeCustom4Minutes': flight.timeCustom4Minutes,
      'timeFlightMinutes': flight.timeFlightMinutes,
      'timeBlockMinutes': flight.timeBlockMinutes,
      'timeTotalBlockMinutes': flight.timeTotalBlockMinutes,
      'distanceNM': flight.distanceNM,
      'ifrApproaches': flight.ifrApproaches,
      'takeOffsDays': flight.takeOffsDays,
      'takeOffsNight': flight.takeOffsNight,
      'landingsDay': flight.landingsDay,
      'landingsNight': flight.landingsNight,
      'pilotFunction':
          pilotFunctionValue ??
          _pilotFunctionConverter.toSql(flight.pilotFunction),
      'approachType': flight.approachType,
      'remarks': flight.remarks,
      'notes': flight.notes,
      'isLocked': isLockedValue ?? flight.isLocked,
      'signatureImage': _bytesToBase64(flight.signatureImage),
      'endorsementData': _normalizeEndorsementJson(flight.endorsementData),
      'crewAssignments': crewAssignments
          .map(
            (row) => <String, Object?>{
              'crewId': row.crewId,
              'position': row.position.name,
            },
          )
          .toList(growable: false),
    };
    return _digest(payload);
  }

  /// Returns SHA-256 hash for a simulator entry payload.
  String hashSimulator({
    required SimulatorTraining simulator,
    required DateTime startDateTime,
    required List<SimulatorCrewAssignment> crewAssignments,
    bool? isLockedValue,
  }) {
    final payload = <String, Object?>{
      'kind': 'simulator',
      'id': simulator.id,
      'aircraftId': simulator.aircraftId,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': simulator.endDateTime?.toIso8601String(),
      'timeTotal': simulator.timeTotal,
      'remarks': simulator.remarks,
      'notes': simulator.notes,
      'isLocked': isLockedValue ?? simulator.isLocked,
      'signatureImage': _bytesToBase64(simulator.signatureImage),
      'endorsementData': _normalizeEndorsementJson(simulator.endorsementData),
      'crewAssignments': crewAssignments
          .map(
            (row) => <String, Object?>{
              'crewId': row.crewId,
              'position': row.position.name,
            },
          )
          .toList(growable: false),
    };
    return _digest(payload);
  }

  String _digest(Map<String, Object?> payload) {
    final bytes = utf8.encode(jsonEncode(payload));
    return sha256.convert(bytes).toString();
  }

  String? _bytesToBase64(List<int>? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return base64Encode(value);
  }

  Object? _normalizeEndorsementJson(String? endorsementData) {
    final raw = endorsementData?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(raw);
    } on Object {
      return raw;
    }
  }
}
