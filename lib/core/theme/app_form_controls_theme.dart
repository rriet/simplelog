import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
/// Public API documentation.
class AppFormControlsTheme extends ThemeExtension<AppFormControlsTheme> {
  /// Public API documentation.
  const AppFormControlsTheme({
    required this.pickerAddButtonSize,
    required this.pickerAddIconSize,
    required this.pickerAddBorderRadius,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final double pickerAddButtonSize;
  /// Public API documentation.
  final double pickerAddIconSize;
  /// Public API documentation.
  final double pickerAddBorderRadius;

  @override
  AppFormControlsTheme copyWith({
    double? pickerAddButtonSize,
    double? pickerAddIconSize,
    double? pickerAddBorderRadius,
  }) {
    return AppFormControlsTheme(
      pickerAddButtonSize: pickerAddButtonSize ?? this.pickerAddButtonSize,
      pickerAddIconSize: pickerAddIconSize ?? this.pickerAddIconSize,
      pickerAddBorderRadius:
          pickerAddBorderRadius ?? this.pickerAddBorderRadius,
    );
  }

  @override
  AppFormControlsTheme lerp(
    ThemeExtension<AppFormControlsTheme>? other,
    double t,
  ) {
    if (other is! AppFormControlsTheme) return this;
    return AppFormControlsTheme(
      pickerAddButtonSize: lerpDouble(
        pickerAddButtonSize,
        other.pickerAddButtonSize,
        t,
      )!,
      pickerAddIconSize: lerpDouble(
        pickerAddIconSize,
        other.pickerAddIconSize,
        t,
      )!,
      pickerAddBorderRadius: lerpDouble(
        pickerAddBorderRadius,
        other.pickerAddBorderRadius,
        t,
      )!,
    );
  }
}
