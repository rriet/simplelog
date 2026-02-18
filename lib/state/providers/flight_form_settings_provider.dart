import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _logTkLdKey = 'flight_form_log_takeoff_landing';
const _timeChecksKey = 'flight_form_time_checks';

class FlightFormTimeChecks {
  const FlightFormTimeChecks({
    this.pic = false,
    this.picus = false,
    this.sic = true,
    this.dual = false,
    this.instructor = false,
    this.ifr = false,
    this.instrument = false,
    this.simInstrument = false,
    this.night = false,
    this.crossCountry = false,
    this.custom1 = false,
    this.custom2 = false,
    this.custom3 = false,
    this.custom4 = false,
    this.flight = false,
  });

  final bool pic;
  final bool picus;
  final bool sic;
  final bool dual;
  final bool instructor;
  final bool ifr;
  final bool instrument;
  final bool simInstrument;
  final bool night;
  final bool crossCountry;
  final bool custom1;
  final bool custom2;
  final bool custom3;
  final bool custom4;
  final bool flight;

  FlightFormTimeChecks copyWith({
    bool? pic,
    bool? picus,
    bool? sic,
    bool? dual,
    bool? instructor,
    bool? ifr,
    bool? instrument,
    bool? simInstrument,
    bool? night,
    bool? crossCountry,
    bool? custom1,
    bool? custom2,
    bool? custom3,
    bool? custom4,
    bool? flight,
  }) {
    return FlightFormTimeChecks(
      pic: pic ?? this.pic,
      picus: picus ?? this.picus,
      sic: sic ?? this.sic,
      dual: dual ?? this.dual,
      instructor: instructor ?? this.instructor,
      ifr: ifr ?? this.ifr,
      instrument: instrument ?? this.instrument,
      simInstrument: simInstrument ?? this.simInstrument,
      night: night ?? this.night,
      crossCountry: crossCountry ?? this.crossCountry,
      custom1: custom1 ?? this.custom1,
      custom2: custom2 ?? this.custom2,
      custom3: custom3 ?? this.custom3,
      custom4: custom4 ?? this.custom4,
      flight: flight ?? this.flight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pic': pic,
      'picus': picus,
      'sic': sic,
      'dual': dual,
      'instructor': instructor,
      'ifr': ifr,
      'instrument': instrument,
      'simInstrument': simInstrument,
      'night': night,
      'crossCountry': crossCountry,
      'custom1': custom1,
      'custom2': custom2,
      'custom3': custom3,
      'custom4': custom4,
      'flight': flight,
    };
  }

  static FlightFormTimeChecks fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return const FlightFormTimeChecks();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return const FlightFormTimeChecks();
    return FlightFormTimeChecks(
      pic: decoded['pic'] == true,
      picus: decoded['picus'] == true,
      sic: decoded['sic'] == true,
      dual: decoded['dual'] == true,
      instructor: decoded['instructor'] == true,
      ifr: decoded['ifr'] == true,
      instrument: decoded['instrument'] == true,
      simInstrument: decoded['simInstrument'] == true,
      night: decoded['night'] == true,
      crossCountry: decoded['crossCountry'] == true,
      custom1: decoded['custom1'] == true,
      custom2: decoded['custom2'] == true,
      custom3: decoded['custom3'] == true,
      custom4: decoded['custom4'] == true,
      flight: decoded['flight'] == true,
    );
  }
}

class FlightFormTakeoffLandingLogNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_logTkLdKey) ?? true;
  }

  Future<void> setValue(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_logTkLdKey, enabled);
    state = AsyncData(enabled);
  }
}

class FlightFormTimeChecksNotifier extends AsyncNotifier<FlightFormTimeChecks> {
  @override
  Future<FlightFormTimeChecks> build() async {
    final prefs = await SharedPreferences.getInstance();
    return FlightFormTimeChecks.fromJson(prefs.getString(_timeChecksKey));
  }

  Future<void> setValue(FlightFormTimeChecks value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeChecksKey, jsonEncode(value.toJson()));
    state = AsyncData(value);
  }
}

final flightFormTakeoffLandingLogProvider =
    AsyncNotifierProvider<FlightFormTakeoffLandingLogNotifier, bool>(
  FlightFormTakeoffLandingLogNotifier.new,
);

final flightFormTimeChecksProvider =
    AsyncNotifierProvider<FlightFormTimeChecksNotifier, FlightFormTimeChecks>(
  FlightFormTimeChecksNotifier.new,
);
