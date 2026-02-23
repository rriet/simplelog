import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/providers/theme_mode_provider.dart';

/// Handles settings-level write actions from the UI.
class SettingsController extends Notifier<void> {
  @override
  void build() {}

  /// Current global app theme mode.
  AppThemeMode get themeMode => ref.read(themeModeProvider);

  /// Sets the global app theme mode.
  set themeMode(AppThemeMode mode) {
    ref.read(themeModeProvider.notifier).state = mode;
  }
}
