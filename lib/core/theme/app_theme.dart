import 'package:flutter/material.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

/// Public API documentation.
class AppTheme {
  static const _fontFamily = 'Inter';

  // Southwest-inspired palette
  static const _navy = Color(0xFF0B2D5C);
  static const _red = Color(0xFFE31837);
  static const _yellow = Color(0xFFF9C80E);
/// Public API documentation.

  /// Public API documentation.
  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _navy,
        ).copyWith(
          primary: _navy,
          onPrimary: Colors.white,
          secondary: _red,
          onSecondary: Colors.white,
          tertiary: _yellow,
          onTertiary: const Color(0xFF1F1F1F),
          error: const Color(0xFFB00020),
          onError: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF1C1F24),
          surfaceContainerHighest: const Color(0xFFE6E8EC),
          onSurfaceVariant: const Color(0xFF4A4F57),
          outline: const Color(0xFFB8BDC7),
          outlineVariant: const Color(0xFFD6D9E0),
          shadow: const Color(0x33000000),
          scrim: const Color(0x66000000),
          inverseSurface: const Color(0xFF2A2F36),
          onInverseSurface: const Color(0xFFF2F3F5),
          inversePrimary: const Color(0xFF9DB7E8),
        );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: _fontFamily,
      extensions: const <ThemeExtension<dynamic>>[
        AppFormControlsTheme(
          pickerAddButtonSize: 33,
          pickerAddIconSize: 20,
          pickerAddBorderRadius: 6,
        ),
      ],
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  /// Public API documentation.
  }

  /// Public API documentation.
  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _navy,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _yellow,
          onPrimary: const Color(0xFF1F1F1F),
          secondary: _red,
          onSecondary: Colors.white,
          tertiary: _navy,
          onTertiary: Colors.white,
          error: const Color(0xFFF2B8B5),
          onError: const Color(0xFF601410),
          surface: const Color(0xFF121826),
          onSurface: const Color(0xFFE6E9EF),
          surfaceContainerHighest: const Color(0xFF1E2433),
          onSurfaceVariant: const Color(0xFFB7BFCC),
          outline: const Color(0xFF6B7280),
          outlineVariant: const Color(0xFF394150),
          shadow: const Color(0x66000000),
          scrim: const Color(0x99000000),
          inverseSurface: const Color(0xFFE6E9EF),
          onInverseSurface: const Color(0xFF1C1F24),
          inversePrimary: _navy,
        );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: _fontFamily,
      extensions: const <ThemeExtension<dynamic>>[
        AppFormControlsTheme(
          pickerAddButtonSize: 40,
          pickerAddIconSize: 20,
          pickerAddBorderRadius: 8,
        ),
      ],
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
