import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

const _reportsPreferencesFileName = 'reports_preferences.json';

final includePreviousExperienceProvider =
    NotifierProvider<IncludePreviousExperienceNotifier, bool>(
  IncludePreviousExperienceNotifier.new,
);

class IncludePreviousExperienceNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> setValue(bool value) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final value = data['includePreviousExperience'] == true;
      state = value;
    } catch (_) {
      // Keep default value.
    }
  }

  Future<void> _save(bool value) async {
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode({'includePreviousExperience': value}),
        flush: true,
      );
    } catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}
