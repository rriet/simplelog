import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/user_settings_json.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// JSON key used to persist flight factoring settings in user profile state.
const flightFactoringSettingsKey = 'flight_factoring_settings';

/// Persisted calculation rules used for flight time factoring.
class FlightFactoringSettings {
  /// Creates factoring settings with defaults.
  const FlightFactoringSettings({
    this.crossCountryThresholdNm = 50,
    this.instrumentPercent = 100,
    this.instrumentMinimumMinutes = 0,
    this.instrumentSubtractMinutes = 0,
    this.ifrPercent = 100,
    this.ifrMinimumMinutes = 0,
    this.ifrSubtractMinutes = 0,
    this.irp3Percent = 66,
    this.irp3SubtractMinutes = 0,
    this.irp4Percent = 50,
    this.irp4SubtractMinutes = 0,
  });

  /// Builds settings from persisted JSON.
  factory FlightFactoringSettings.fromJson(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const FlightFactoringSettings();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const FlightFactoringSettings();
    }
    int readInt(String key, int fallback) {
      final value = decoded[key];
      if (value is int) return value;
      if (value is num) return value.round();
      return fallback;
    }

    return FlightFactoringSettings(
      crossCountryThresholdNm: readInt('crossCountryThresholdNm', 50),
      instrumentPercent: readInt('instrumentPercent', 100).clamp(0, 100),
      instrumentMinimumMinutes: readInt('instrumentMinimumMinutes', 0),
      instrumentSubtractMinutes: readInt('instrumentSubtractMinutes', 0),
      ifrPercent: readInt('ifrPercent', 100).clamp(0, 100),
      ifrMinimumMinutes: readInt('ifrMinimumMinutes', 0),
      ifrSubtractMinutes: readInt('ifrSubtractMinutes', 0),
      irp3Percent: readInt('irp3Percent', 33).clamp(0, 100),
      irp3SubtractMinutes: readInt('irp3SubtractMinutes', 0),
      irp4Percent: readInt('irp4Percent', 50).clamp(0, 100),
      irp4SubtractMinutes: readInt('irp4SubtractMinutes', 0),
    );
  }

  /// Minimum NM threshold to mark cross-country.
  final int crossCountryThresholdNm;

  /// Instrument factoring percentage.
  final int instrumentPercent;

  /// Minimum instrument minutes required after factoring.
  final int instrumentMinimumMinutes;

  /// Instrument minutes subtracted before percentage.
  final int instrumentSubtractMinutes;

  /// IFR factoring percentage.
  final int ifrPercent;

  /// Minimum IFR minutes required after factoring.
  final int ifrMinimumMinutes;

  /// IFR minutes subtracted before percentage.
  final int ifrSubtractMinutes;

  /// IRP3 percentage applied after subtraction.
  final int irp3Percent;

  /// IRP3 minutes subtracted before percentage.
  final int irp3SubtractMinutes;

  /// IRP4 percentage applied after subtraction.
  final int irp4Percent;

  /// IRP4 minutes subtracted before percentage.
  final int irp4SubtractMinutes;

  /// Returns a copy with selected values changed.
  FlightFactoringSettings copyWith({
    int? crossCountryThresholdNm,
    int? instrumentPercent,
    int? instrumentMinimumMinutes,
    int? instrumentSubtractMinutes,
    int? ifrPercent,
    int? ifrMinimumMinutes,
    int? ifrSubtractMinutes,
    int? irp3Percent,
    int? irp3SubtractMinutes,
    int? irp4Percent,
    int? irp4SubtractMinutes,
  }) {
    return FlightFactoringSettings(
      crossCountryThresholdNm:
          crossCountryThresholdNm ?? this.crossCountryThresholdNm,
      instrumentPercent: instrumentPercent ?? this.instrumentPercent,
      instrumentMinimumMinutes:
          instrumentMinimumMinutes ?? this.instrumentMinimumMinutes,
      instrumentSubtractMinutes:
          instrumentSubtractMinutes ?? this.instrumentSubtractMinutes,
      ifrPercent: ifrPercent ?? this.ifrPercent,
      ifrMinimumMinutes: ifrMinimumMinutes ?? this.ifrMinimumMinutes,
      ifrSubtractMinutes: ifrSubtractMinutes ?? this.ifrSubtractMinutes,
      irp3Percent: irp3Percent ?? this.irp3Percent,
      irp3SubtractMinutes: irp3SubtractMinutes ?? this.irp3SubtractMinutes,
      irp4Percent: irp4Percent ?? this.irp4Percent,
      irp4SubtractMinutes: irp4SubtractMinutes ?? this.irp4SubtractMinutes,
    );
  }

  /// Serializes settings for persistence.
  Map<String, dynamic> toJson() {
    return {
      'crossCountryThresholdNm': crossCountryThresholdNm,
      'instrumentPercent': instrumentPercent,
      'instrumentMinimumMinutes': instrumentMinimumMinutes,
      'instrumentSubtractMinutes': instrumentSubtractMinutes,
      'ifrPercent': ifrPercent,
      'ifrMinimumMinutes': ifrMinimumMinutes,
      'ifrSubtractMinutes': ifrSubtractMinutes,
      'irp3Percent': irp3Percent,
      'irp3SubtractMinutes': irp3SubtractMinutes,
      'irp4Percent': irp4Percent,
      'irp4SubtractMinutes': irp4SubtractMinutes,
    };
  }
}

/// Persists and exposes [FlightFactoringSettings].
class FlightFactoringSettingsNotifier
    extends AsyncNotifier<FlightFactoringSettings> {
  @override
  Future<FlightFactoringSettings> build() async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    return loadSettingWithLegacy<FlightFactoringSettings>(
      store: store,
      key: flightFactoringSettingsKey,
      fallback: const FlightFactoringSettings(),
      parse: (raw) {
        if (raw is String && raw.isNotEmpty) {
          return FlightFactoringSettings.fromJson(raw);
        }
        return null;
      },
      encode: (value) => jsonEncode(value.toJson()),
    );
  }

  /// Saves new settings and updates state.
  Future<void> setValue(FlightFactoringSettings value) async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    await store.patch(
      (settings) => settings[flightFactoringSettingsKey] = jsonEncode(
        value.toJson(),
      ),
    );
    state = AsyncData(value);
  }
}

/// Provider for [FlightFactoringSettings].
final flightFactoringSettingsProvider =
    AsyncNotifierProvider<
      FlightFactoringSettingsNotifier,
      FlightFactoringSettings
    >(FlightFactoringSettingsNotifier.new);
