import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/user_settings_json.dart';
import 'package:simplelog/state/providers/database_provider.dart';

const _defaultCrewPositionKey = 'simulator_default_crew_position';

/// Persists and exposes the default crew position for simulator entries.
class SimulatorDefaultCrewPositionNotifier extends AsyncNotifier<CrewPosition> {
  @override
  Future<CrewPosition> build() async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    return loadSettingWithLegacy<CrewPosition>(
      store: store,
      key: _defaultCrewPositionKey,
      fallback: _normalizeDefaultPosition(null),
      parse: (raw) {
        if (raw is String && raw.isNotEmpty) {
          return _normalizeDefaultPosition(_parseCrewPosition(raw));
        }
        return null;
      },
      encode: (value) => value.name,
    );
  }

  /// Updates and saves the default simulator crew position.
  Future<void> setPosition(CrewPosition position) async {
    final normalized = _normalizeDefaultPosition(position);
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    await store.patch(
      (json) => json[_defaultCrewPositionKey] = normalized.name,
    );
    state = AsyncData(normalized);
  }
}

/// Provider for the default simulator crew position.
final simulatorDefaultCrewPositionProvider =
    AsyncNotifierProvider<SimulatorDefaultCrewPositionNotifier, CrewPosition>(
      SimulatorDefaultCrewPositionNotifier.new,
    );

CrewPosition? _parseCrewPosition(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final value in CrewPosition.values) {
    if (value.name == raw && value != CrewPosition.unknown) {
      return value;
    }
  }
  return null;
}

CrewPosition _normalizeDefaultPosition(CrewPosition? value) {
  if (value == CrewPosition.pic) return CrewPosition.pic;
  return CrewPosition.sic;
}
