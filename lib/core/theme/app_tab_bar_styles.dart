import 'package:flutter/material.dart';

/// Shared styling configuration for tab bars used in the app.
class AppTabBarStyles {
  const AppTabBarStyles._();

  /// Whether tab bars should be horizontally scrollable.
  static const bool isScrollable = true;

  /// Alignment of tabs within the available space.
  static const TabAlignment tabAlignment = TabAlignment.start;

  /// Default padding around each tab label.
  static const EdgeInsetsGeometry labelPadding = EdgeInsets.symmetric(
    horizontal: 12,
  );
}
