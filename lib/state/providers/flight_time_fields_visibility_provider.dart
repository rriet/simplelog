import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _flightTimeFieldsVisibilityKey = 'flight_time_fields_visibility';

/// Visibility preferences for optional time fields in flight forms.
class FlightTimeFieldsVisibility {
  /// Creates visibility flags with default values.
  const FlightTimeFieldsVisibility({
    this.pic = true,
    this.picus = true,
    this.sic = true,
    this.dual = true,
    this.instructor = true,
    this.ifr = true,
    this.instrument = true,
    this.simInstrument = true,
    this.night = true,
    this.crossCountry = true,
    this.custom1 = true,
    this.custom2 = true,
    this.custom3 = true,
    this.custom4 = true,
    this.flight = true,
  });

  /// Builds visibility flags from persisted JSON.
  factory FlightTimeFieldsVisibility.fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return const FlightTimeFieldsVisibility();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const FlightTimeFieldsVisibility();
    }
    return FlightTimeFieldsVisibility(
      pic: decoded['pic'] != false,
      picus: decoded['picus'] != false,
      sic: decoded['sic'] != false,
      dual: decoded['dual'] != false,
      instructor: decoded['instructor'] != false,
      ifr: decoded['ifr'] != false,
      instrument: decoded['instrument'] != false,
      simInstrument: decoded['simInstrument'] != false,
      night: decoded['night'] != false,
      crossCountry: decoded['crossCountry'] != false,
      custom1: decoded['custom1'] != false,
      custom2: decoded['custom2'] != false,
      custom3: decoded['custom3'] != false,
      custom4: decoded['custom4'] != false,
      flight: decoded['flight'] != false,
    );
  }

  /// Whether the PIC time field is visible.
  final bool pic;

  /// Whether the PICUS time field is visible.
  final bool picus;

  /// Whether the SIC time field is visible.
  final bool sic;

  /// Whether the Dual time field is visible.
  final bool dual;

  /// Whether the Instructor time field is visible.
  final bool instructor;

  /// Whether the IFR time field is visible.
  final bool ifr;

  /// Whether the Instrument time field is visible.
  final bool instrument;

  /// Whether the Sim Instrument time field is visible.
  final bool simInstrument;

  /// Whether the Night time field is visible.
  final bool night;

  /// Whether the Cross-Country field is visible.
  final bool crossCountry;

  /// Whether Custom Time 1 is visible.
  final bool custom1;

  /// Whether Custom Time 2 is visible.
  final bool custom2;

  /// Whether Custom Time 3 is visible.
  final bool custom3;

  /// Whether Custom Time 4 is visible.
  final bool custom4;

  /// Whether the Flight time field is visible.
  final bool flight;

  /// Returns a copy with selected visibility flags updated.
  FlightTimeFieldsVisibility copyWith({
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
    return FlightTimeFieldsVisibility(
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

  /// Serializes visibility flags for persistence.
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

/// Persists and exposes flight time field visibility preferences.
class FlightTimeFieldsVisibilityNotifier
    extends AsyncNotifier<FlightTimeFieldsVisibility> {
  @override
  Future<FlightTimeFieldsVisibility> build() async {
    final prefs = await SharedPreferences.getInstance();
    return FlightTimeFieldsVisibility.fromJson(
      prefs.getString(_flightTimeFieldsVisibilityKey),
    );
  }

  /// Updates and saves the current visibility preferences.
  Future<void> setValue(FlightTimeFieldsVisibility value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _flightTimeFieldsVisibilityKey,
      jsonEncode(value.toJson()),
    );
    state = AsyncData(value);
  }
}

/// Provider for flight time field visibility preferences.
final flightTimeFieldsVisibilityProvider =
    AsyncNotifierProvider<
      FlightTimeFieldsVisibilityNotifier,
      FlightTimeFieldsVisibility
    >(
      FlightTimeFieldsVisibilityNotifier.new,
    );
