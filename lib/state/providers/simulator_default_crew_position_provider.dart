import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';

const _defaultCrewPositionKey = 'simulator_default_crew_position';

class SimulatorDefaultCrewPositionNotifier extends AsyncNotifier<CrewPosition> {
  @override
  Future<CrewPosition> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_defaultCrewPositionKey);
    return _parseCrewPosition(raw) ?? CrewPosition.sic;
  }

  Future<void> setPosition(CrewPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCrewPositionKey, position.name);
    state = AsyncData(position);
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

