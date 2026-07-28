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

  /// Whether the root navigator can pop.
  static bool canPopRoot(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).canPop();
  }

  /// Attempts to pop the current route.
  static Future<bool> maybePop<T extends Object?>(
    BuildContext context, [
    T? result,
  ]) {
    return Navigator.of(context).maybePop<T>(result);
  }

  /// Pushes a pre-built [route].
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Route<T> route, {
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push<T>(route);
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

  /// Pushes a route with a custom [PageRouteBuilder].
  static Future<T?> pushCustom<T extends Object?>(
    BuildContext context,
    Widget Function(
      BuildContext context,
      Animation<double> a1,
      Animation<double> a2,
    )
    builder, {
    bool rootNavigator = false,
    Duration transitionDuration = Duration.zero,
    Duration reverseTransitionDuration = Duration.zero,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).push<T>(
      PageRouteBuilder(
        pageBuilder: builder,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        transitionsBuilder: (_, _, _, child) => child,
      ),
    );
  }
}
