import 'package:flutter/material.dart';

/// Shows an edit dialog constrained to a desktop-friendly maximum size.
Future<T?> showConstrainedEditDialog<T>({
  required BuildContext context,
  required Widget child,
  double width = 520,
  double maxHeightFactor = 0.9,
}) {
  final maxHeight = MediaQuery.of(context).size.height * maxHeightFactor;
  return showDialog<T>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}
