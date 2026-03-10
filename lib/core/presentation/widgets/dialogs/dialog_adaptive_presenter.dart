import 'package:flutter/material.dart';

/// Breakpoint used to switch between compact and wide dialog presentation.
const double dialogCompactBreakpoint = 600;

/// Returns `true` when the current screen should use compact dialog behavior.
bool isCompactDialogScreen(BuildContext context) {
  return MediaQuery.sizeOf(context).width < dialogCompactBreakpoint;
}

/// Shows a "large dialog screen":
/// - wide screens: modal [Dialog]
/// - compact screens: full-screen route
Future<T?> showLargeDialogScreen<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxWidth = 760,
  double maxHeightFactor = 0.9,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) async {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  if (isCompactDialogScreen(context)) {
    return navigator.push<T>(MaterialPageRoute(builder: builder));
  }
  final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: SizedBox(width: maxWidth, child: builder(dialogContext)),
      ),
    ),
  );
}

/// Shows a "small dialog" as modal [Dialog] on all screen sizes.
Future<T?> showSmallDialogScreen<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: builder,
  );
}
