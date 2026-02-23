import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/settings_controller.dart';

/// Provides the app settings controller.
final settingsControllerProvider = NotifierProvider<SettingsController, void>(
  SettingsController.new,
);
