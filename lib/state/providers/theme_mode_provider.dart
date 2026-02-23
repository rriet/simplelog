import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// App-supported theme selection modes.
enum AppThemeMode {
  /// Follow the platform theme.
  system,

  /// Always use light theme.
  light,

  /// Always use dark theme.
  dark,
}

/// Converts [AppThemeMode] to Flutter's [ThemeMode].
extension AppThemeModeTheme on AppThemeMode {
  /// Returns the corresponding [ThemeMode].
  ThemeMode toThemeMode() {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }
}

/// Holds the currently selected app theme mode.
final themeModeProvider = StateProvider<AppThemeMode>(
  (ref) => AppThemeMode.system,
);
