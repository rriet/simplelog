import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/providers/theme_mode_provider.dart';

class SettingsController extends Notifier<void> {
  @override
  void build() {}

  void setThemeMode(AppThemeMode mode) {
    ref.read(themeModeProvider.notifier).state = mode;
  }
}
