import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/settings_controller.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, void>(
  SettingsController.new,
);
