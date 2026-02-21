import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const flightFactoringSettingsKey = 'flight_factoring_settings';

class FlightFactoringSettings {
  const FlightFactoringSettings({
    this.crossCountryThresholdNm = 50,
    this.instrumentPercent = 0,
    this.instrumentMinimumMinutes = 0,
    this.instrumentSubtractMinutes = 0,
    this.ifrPercent = 0,
    this.ifrMinimumMinutes = 0,
    this.ifrSubtractMinutes = 0,
    this.irp3Percent = 100,
    this.irp3SubtractMinutes = 0,
    this.irp4Percent = 100,
    this.irp4SubtractMinutes = 0,
  });

  final int crossCountryThresholdNm;
  final int instrumentPercent;
  final int instrumentMinimumMinutes;
  final int instrumentSubtractMinutes;
  final int ifrPercent;
  final int ifrMinimumMinutes;
  final int ifrSubtractMinutes;
  final int irp3Percent;
  final int irp3SubtractMinutes;
  final int irp4Percent;
  final int irp4SubtractMinutes;

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

  static FlightFactoringSettings fromJson(String? raw) {
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
      instrumentPercent: readInt('instrumentPercent', 0).clamp(0, 100),
      instrumentMinimumMinutes: readInt('instrumentMinimumMinutes', 0),
      instrumentSubtractMinutes: readInt('instrumentSubtractMinutes', 0),
      ifrPercent: readInt('ifrPercent', 0).clamp(0, 100),
      ifrMinimumMinutes: readInt('ifrMinimumMinutes', 0),
      ifrSubtractMinutes: readInt('ifrSubtractMinutes', 0),
      irp3Percent: readInt('irp3Percent', 100).clamp(0, 100),
      irp3SubtractMinutes: readInt('irp3SubtractMinutes', 0),
      irp4Percent: readInt('irp4Percent', 100).clamp(0, 100),
      irp4SubtractMinutes: readInt('irp4SubtractMinutes', 0),
    );
  }
}

class FlightFactoringSettingsNotifier
    extends AsyncNotifier<FlightFactoringSettings> {
  @override
  Future<FlightFactoringSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return FlightFactoringSettings.fromJson(
      prefs.getString(flightFactoringSettingsKey),
    );
  }

  Future<void> setValue(FlightFactoringSettings value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      flightFactoringSettingsKey,
      jsonEncode(value.toJson()),
    );
    state = AsyncData(value);
  }
}

final flightFactoringSettingsProvider =
    AsyncNotifierProvider<
      FlightFactoringSettingsNotifier,
      FlightFactoringSettings
    >(FlightFactoringSettingsNotifier.new);
