import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';

const _defaultCrewPositionKey = 'simulator_default_crew_position';

class SimulatorDefaultCrewPositionNotifier extends AsyncNotifier<CrewPosition> {
  @override
  Future<CrewPosition> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_defaultCrewPositionKey);
    return _normalizeDefaultPosition(_parseCrewPosition(raw));
  }

  Future<void> setPosition(CrewPosition position) async {
    final normalized = _normalizeDefaultPosition(position);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCrewPositionKey, normalized.name);
    state = AsyncData(normalized);
  }
}

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
