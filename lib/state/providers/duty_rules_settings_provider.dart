import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/user_settings_json.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// JSON key used to persist duty rules in user profile state.
const dutyRulesSettingsKey = 'duty_rules_settings';

/// Persisted duty rules used by duty calculations/import logic.
class DutyRulesSettings {
  /// Creates duty rules settings with defaults.
  const DutyRulesSettings({
    this.crewHomeBaseAirportId,
    this.reportingTimeOnBaseMinutes = 0,
    this.reportingTimeOffBaseMinutes = 0,
    this.dutyEndTimeAllowanceMinutes = 0,
    this.minimumRestTimeMinutes = 0,
  });

  /// Builds settings from persisted JSON.
  factory DutyRulesSettings.fromJson(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const DutyRulesSettings();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const DutyRulesSettings();
    }

    int readInt(String key, int fallback) {
      final value = decoded[key];
      if (value is int) return value;
      if (value is num) return value.round();
      return fallback;
    }

    int? readNullableInt(String key) {
      final value = decoded[key];
      if (value is int) return value;
      if (value is num) return value.round();
      return null;
    }

    return DutyRulesSettings(
      crewHomeBaseAirportId: readNullableInt('crewHomeBaseAirportId'),
      reportingTimeOnBaseMinutes: readInt('reportingTimeOnBaseMinutes', 0),
      reportingTimeOffBaseMinutes: readInt('reportingTimeOffBaseMinutes', 0),
      dutyEndTimeAllowanceMinutes: readInt('dutyEndTimeAllowanceMinutes', 0),
      minimumRestTimeMinutes: readInt('minimumRestTimeMinutes', 0),
    );
  }

  /// Crew home-base airport id used for on/off-base duty logic.
  final int? crewHomeBaseAirportId;

  /// Reporting time (minutes) when reporting at home base.
  final int reportingTimeOnBaseMinutes;

  /// Reporting time (minutes) when reporting off base.
  final int reportingTimeOffBaseMinutes;

  /// Allowed duty-end buffer in minutes.
  final int dutyEndTimeAllowanceMinutes;

  /// Minimum rest time in minutes.
  final int minimumRestTimeMinutes;

  /// Returns a copy with selected fields replaced.
  DutyRulesSettings copyWith({
    int? crewHomeBaseAirportId,
    bool clearCrewHomeBaseAirportId = false,
    int? reportingTimeOnBaseMinutes,
    int? reportingTimeOffBaseMinutes,
    int? dutyEndTimeAllowanceMinutes,
    int? minimumRestTimeMinutes,
  }) {
    return DutyRulesSettings(
      crewHomeBaseAirportId: clearCrewHomeBaseAirportId
          ? null
          : (crewHomeBaseAirportId ?? this.crewHomeBaseAirportId),
      reportingTimeOnBaseMinutes:
          reportingTimeOnBaseMinutes ?? this.reportingTimeOnBaseMinutes,
      reportingTimeOffBaseMinutes:
          reportingTimeOffBaseMinutes ?? this.reportingTimeOffBaseMinutes,
      dutyEndTimeAllowanceMinutes:
          dutyEndTimeAllowanceMinutes ?? this.dutyEndTimeAllowanceMinutes,
      minimumRestTimeMinutes:
          minimumRestTimeMinutes ?? this.minimumRestTimeMinutes,
    );
  }

  /// Serializes settings for persistence.
  Map<String, dynamic> toJson() {
    return {
      'crewHomeBaseAirportId': crewHomeBaseAirportId,
      'reportingTimeOnBaseMinutes': reportingTimeOnBaseMinutes,
      'reportingTimeOffBaseMinutes': reportingTimeOffBaseMinutes,
      'dutyEndTimeAllowanceMinutes': dutyEndTimeAllowanceMinutes,
      'minimumRestTimeMinutes': minimumRestTimeMinutes,
    };
  }
}

/// Persists and exposes [DutyRulesSettings].
class DutyRulesSettingsNotifier extends AsyncNotifier<DutyRulesSettings> {
  @override
  Future<DutyRulesSettings> build() async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    return loadSettingWithLegacy<DutyRulesSettings>(
      store: store,
      key: dutyRulesSettingsKey,
      fallback: const DutyRulesSettings(),
      parse: (raw) {
        if (raw is String && raw.isNotEmpty) {
          return DutyRulesSettings.fromJson(raw);
        }
        return null;
      },
      encode: (value) => jsonEncode(value.toJson()),
    );
  }

  /// Saves new settings and updates state.
  Future<void> setValue(DutyRulesSettings value) async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    await store.patch(
      (settings) => settings[dutyRulesSettingsKey] = jsonEncode(value.toJson()),
    );
    state = AsyncData(value);
  }
}

/// Provider for [DutyRulesSettings].
final dutyRulesSettingsProvider =
    AsyncNotifierProvider<DutyRulesSettingsNotifier, DutyRulesSettings>(
      DutyRulesSettingsNotifier.new,
    );
