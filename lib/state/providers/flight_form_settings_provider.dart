import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/user_settings_json.dart';
import 'package:simplelog/state/providers/database_provider.dart';

const _logTkLdKey = 'flight_form_log_takeoff_landing';
const _timeChecksKey = 'flight_form_time_checks';

/// Default checked states for time allocation checkboxes in flight forms.
class FlightFormTimeChecks {
  /// Creates checkbox defaults.
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

  /// Builds checkbox state from persisted JSON.
  factory FlightFormTimeChecks.fromJson(String? raw) {
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

  /// Default checked state for PIC time.
  final bool pic;

  /// Default checked state for PICUS time.
  final bool picus;

  /// Default checked state for SIC time.
  final bool sic;

  /// Default checked state for Dual time.
  final bool dual;

  /// Default checked state for Instructor time.
  final bool instructor;

  /// Default checked state for IFR time.
  final bool ifr;

  /// Default checked state for Instrument time.
  final bool instrument;

  /// Default checked state for Sim Instrument time.
  final bool simInstrument;

  /// Default checked state for Night time.
  final bool night;

  /// Default checked state for Cross-Country time.
  final bool crossCountry;

  /// Default checked state for Custom 1.
  final bool custom1;

  /// Default checked state for Custom 2.
  final bool custom2;

  /// Default checked state for Custom 3.
  final bool custom3;

  /// Default checked state for Custom 4.
  final bool custom4;

  /// Default checked state for Flight time.
  final bool flight;

  /// Returns a copy with selected values changed.
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

  /// Serializes checkbox state for persistence.
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
}

/// Persists and exposes takeoff/landing logging preference.
class FlightFormTakeoffLandingLogNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    return loadSettingWithLegacy<bool>(
      store: store,
      key: _logTkLdKey,
      fallback: true,
      parse: (raw) => raw is bool ? raw : null,
      encode: (value) => value,
    );
  }

  /// Saves the takeoff/landing logging flag.
  Future<void> setValue({required bool enabled}) async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    await store.patch((json) => json[_logTkLdKey] = enabled);
    state = AsyncData(enabled);
  }
}

/// Persists and exposes default checkbox selections.
class FlightFormTimeChecksNotifier extends AsyncNotifier<FlightFormTimeChecks> {
  @override
  Future<FlightFormTimeChecks> build() async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    return loadSettingWithLegacy<FlightFormTimeChecks>(
      store: store,
      key: _timeChecksKey,
      fallback: const FlightFormTimeChecks(),
      parse: (raw) {
        if (raw is String && raw.isNotEmpty) {
          return FlightFormTimeChecks.fromJson(raw);
        }
        return null;
      },
      encode: (value) => jsonEncode(value.toJson()),
    );
  }

  /// Saves checkbox defaults and updates state.
  Future<void> setValue(FlightFormTimeChecks value) async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    await store.patch(
      (json) => json[_timeChecksKey] = jsonEncode(value.toJson()),
    );
    state = AsyncData(value);
  }
}

/// Provider for takeoff/landing logging preference.
final flightFormTakeoffLandingLogProvider =
    AsyncNotifierProvider<FlightFormTakeoffLandingLogNotifier, bool>(
      FlightFormTakeoffLandingLogNotifier.new,
    );

/// Provider for default flight form checkbox states.
final flightFormTimeChecksProvider =
    AsyncNotifierProvider<FlightFormTimeChecksNotifier, FlightFormTimeChecks>(
      FlightFormTimeChecksNotifier.new,
    );
