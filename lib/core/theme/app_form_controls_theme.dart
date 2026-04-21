import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
/// Theme extension for shared form-control sizing and compact input styling.
class AppFormControlsTheme extends ThemeExtension<AppFormControlsTheme> {
  /// Creates form controls theme values.
  const AppFormControlsTheme({
    required this.pickerAddButtonSize,
    required this.pickerAddIconSize,
    required this.pickerAddBorderRadius,
    required this.compactFieldHeight,
    required this.compactBorderRadius,
    required this.compactBorderWidth,
    required this.horizontalContentPadding,
    required this.verticalContentPadding,
    required this.fieldVerticalGap,
    required this.labelOffsetTop,
    required this.labelOffsetLeft,
    required this.labelChipHorizontalPadding,
    required this.errorTopSpacing,
    required this.errorLeftPadding,
    required this.suffixIconMinSize,
    required this.bodyFontSize,
    required this.labelFontSize,
    required this.errorFontSize,
  });

  /// Default values used as the single source of truth.
  static const defaults = AppFormControlsTheme(
    pickerAddButtonSize: 40,
    pickerAddIconSize: 20,
    pickerAddBorderRadius: 8,
    compactFieldHeight: 38,
    compactBorderRadius: 8,
    compactBorderWidth: 1,
    horizontalContentPadding: 10,
    verticalContentPadding: 4,
    fieldVerticalGap: 7,
    labelOffsetTop: -8,
    labelOffsetLeft: 10,
    labelChipHorizontalPadding: 4,
    errorTopSpacing: 4,
    errorLeftPadding: 12,
    suffixIconMinSize: 24,
    bodyFontSize: 14,
    labelFontSize: 11,
    errorFontSize: 12,
  );

  /// Light-theme form-control overrides built from [defaults].
  static AppFormControlsTheme get light => defaults.copyWith(
    pickerAddButtonSize: 33,
    pickerAddBorderRadius: 6,
  );

  /// Dark-theme form-control values.
  static AppFormControlsTheme get dark => defaults;

  /// Fallback values used when the extension is not found in theme.
  static AppFormControlsTheme get fallback => defaults;

  /// Button size for picker "add" buttons.
  final double pickerAddButtonSize;

  /// Icon size for picker "add" buttons.
  final double pickerAddIconSize;

  /// Corner radius for picker "add" buttons.
  final double pickerAddBorderRadius;

  /// Fixed control height for compact single-line fields.
  final double compactFieldHeight;

  /// Border radius for compact input fields.
  final double compactBorderRadius;

  /// Border width for compact input fields.
  final double compactBorderWidth;

  /// Horizontal content padding inside compact input fields.
  final double horizontalContentPadding;

  /// Vertical content padding inside compact input fields.
  final double verticalContentPadding;

  /// Vertical gap between adjacent form controls.
  ///
  /// Applied as half-gap above and below each control so the effective
  /// spacing between two controls is exactly this value.
  final double fieldVerticalGap;

  /// Vertical offset for custom floating-label chips.
  final double labelOffsetTop;

  /// Horizontal offset for custom floating-label chips.
  final double labelOffsetLeft;

  /// Horizontal padding for custom floating-label chips.
  final double labelChipHorizontalPadding;

  /// Vertical spacing between control and inline error text.
  final double errorTopSpacing;

  /// Left padding for inline error text.
  final double errorLeftPadding;

  /// Minimum width/height for suffix icons.
  final double suffixIconMinSize;

  /// Body text font size for compact controls.
  final double bodyFontSize;

  /// Label font size for compact controls.
  final double labelFontSize;

  /// Error text font size for compact controls.
  final double errorFontSize;

  /// Shared compact input decoration for standard text-based fields.
  InputDecoration compactDecoration({
    required BuildContext context,
    required String label,
    String? hintText,
    String? errorText,
    Widget? suffixIcon,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.always,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(compactBorderRadius);
    return InputDecoration(
      visualDensity: VisualDensity.standard,
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: floatingLabelBehavior,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: horizontalContentPadding,
        vertical: verticalContentPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(width: compactBorderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: colorScheme.outlineVariant,
          width: compactBorderWidth,
        ),
      ),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        fontSize: labelFontSize,
      ),
      floatingLabelStyle: theme.textTheme.labelMedium?.copyWith(
        fontSize: labelFontSize,
        color: colorScheme.onSurfaceVariant,
      ),
      errorStyle: theme.textTheme.bodySmall?.copyWith(fontSize: errorFontSize),
      errorText: errorText,
      suffixIconConstraints: BoxConstraints(
        minWidth: suffixIconMinSize,
        minHeight: suffixIconMinSize,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  AppFormControlsTheme copyWith({
    double? pickerAddButtonSize,
    double? pickerAddIconSize,
    double? pickerAddBorderRadius,
    double? compactFieldHeight,
    double? compactBorderRadius,
    double? compactBorderWidth,
    double? horizontalContentPadding,
    double? verticalContentPadding,
    double? fieldVerticalGap,
    double? labelOffsetTop,
    double? labelOffsetLeft,
    double? labelChipHorizontalPadding,
    double? errorTopSpacing,
    double? errorLeftPadding,
    double? suffixIconMinSize,
    double? bodyFontSize,
    double? labelFontSize,
    double? errorFontSize,
  }) {
    return AppFormControlsTheme(
      pickerAddButtonSize: pickerAddButtonSize ?? this.pickerAddButtonSize,
      pickerAddIconSize: pickerAddIconSize ?? this.pickerAddIconSize,
      pickerAddBorderRadius:
          pickerAddBorderRadius ?? this.pickerAddBorderRadius,
      compactFieldHeight: compactFieldHeight ?? this.compactFieldHeight,
      compactBorderRadius: compactBorderRadius ?? this.compactBorderRadius,
      compactBorderWidth: compactBorderWidth ?? this.compactBorderWidth,
      horizontalContentPadding:
          horizontalContentPadding ?? this.horizontalContentPadding,
      verticalContentPadding:
          verticalContentPadding ?? this.verticalContentPadding,
      fieldVerticalGap: fieldVerticalGap ?? this.fieldVerticalGap,
      labelOffsetTop: labelOffsetTop ?? this.labelOffsetTop,
      labelOffsetLeft: labelOffsetLeft ?? this.labelOffsetLeft,
      labelChipHorizontalPadding:
          labelChipHorizontalPadding ?? this.labelChipHorizontalPadding,
      errorTopSpacing: errorTopSpacing ?? this.errorTopSpacing,
      errorLeftPadding: errorLeftPadding ?? this.errorLeftPadding,
      suffixIconMinSize: suffixIconMinSize ?? this.suffixIconMinSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      errorFontSize: errorFontSize ?? this.errorFontSize,
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
      compactFieldHeight: lerpDouble(
        compactFieldHeight,
        other.compactFieldHeight,
        t,
      )!,
      compactBorderRadius: lerpDouble(
        compactBorderRadius,
        other.compactBorderRadius,
        t,
      )!,
      compactBorderWidth: lerpDouble(
        compactBorderWidth,
        other.compactBorderWidth,
        t,
      )!,
      horizontalContentPadding: lerpDouble(
        horizontalContentPadding,
        other.horizontalContentPadding,
        t,
      )!,
      verticalContentPadding: lerpDouble(
        verticalContentPadding,
        other.verticalContentPadding,
        t,
      )!,
      fieldVerticalGap: lerpDouble(
        fieldVerticalGap,
        other.fieldVerticalGap,
        t,
      )!,
      labelOffsetTop: lerpDouble(labelOffsetTop, other.labelOffsetTop, t)!,
      labelOffsetLeft: lerpDouble(labelOffsetLeft, other.labelOffsetLeft, t)!,
      labelChipHorizontalPadding: lerpDouble(
        labelChipHorizontalPadding,
        other.labelChipHorizontalPadding,
        t,
      )!,
      errorTopSpacing: lerpDouble(errorTopSpacing, other.errorTopSpacing, t)!,
      errorLeftPadding: lerpDouble(
        errorLeftPadding,
        other.errorLeftPadding,
        t,
      )!,
      suffixIconMinSize: lerpDouble(
        suffixIconMinSize,
        other.suffixIconMinSize,
        t,
      )!,
      bodyFontSize: lerpDouble(bodyFontSize, other.bodyFontSize, t)!,
      labelFontSize: lerpDouble(labelFontSize, other.labelFontSize, t)!,
      errorFontSize: lerpDouble(errorFontSize, other.errorFontSize, t)!,
    );
  }
}
