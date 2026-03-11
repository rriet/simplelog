import 'package:flutter/material.dart';

/// Centralized navigation helper used by presentation code.
class AppNavigator {
  /// Pops current route and optionally returns [result].
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Pops from the root navigator and optionally returns [result].
  static void popRoot<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context, rootNavigator: true).pop<T>(result);
  }

  /// Pushes a Material route built by [builder].
  static Future<T?> pushMaterial<T extends Object?>(
    BuildContext context,
    WidgetBuilder builder, {
    bool rootNavigator = false,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).push<T>(
      MaterialPageRoute(
        builder: builder,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }
}
