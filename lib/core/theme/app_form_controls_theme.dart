import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppFormControlsTheme extends ThemeExtension<AppFormControlsTheme> {
  const AppFormControlsTheme({
    required this.pickerAddButtonSize,
    required this.pickerAddIconSize,
    required this.pickerAddBorderRadius,
  });

  final double pickerAddButtonSize;
  final double pickerAddIconSize;
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
      pickerAddBorderRadius: pickerAddBorderRadius ?? this.pickerAddBorderRadius,
    );
  }

  @override
  AppFormControlsTheme lerp(ThemeExtension<AppFormControlsTheme>? other, double t) {
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
