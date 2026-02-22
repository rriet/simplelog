import 'package:flutter/material.dart';

/// Shows a standardized one-action message dialog.
Future<void> showAppMessageDialog(
  BuildContext context, {
  String? message,
  String? title,
  String? okLabel,
  bool useRootNavigator = true,
}) async {
  final effectiveOkLabel = okLabel ?? MaterialLocalizations.of(context).okButtonLabel;

  await showDialog<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => AlertDialog(
      title: title == null ? null : Text(title),
      content: (message == null || message.isEmpty) ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(effectiveOkLabel),
        ),
      ],
    ),
  );
}
