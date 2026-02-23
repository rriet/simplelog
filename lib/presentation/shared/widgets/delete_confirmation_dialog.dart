import 'package:flutter/material.dart';

/// Public API documentation.
class DeleteConfirmationDialog extends StatelessWidget {
  /// Public API documentation.
  const DeleteConfirmationDialog({
    required this.title,
    required this.content,
    required this.cancelLabel,
    required this.deleteLabel,
    super.key,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final String title;
  /// Public API documentation.
  final String content;
  /// Public API documentation.
  final String cancelLabel;
  /// Public API documentation.
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          /// Public API documentation.
          child: Text(deleteLabel),
        ),
      ],
    );
  }

  /// Public API documentation.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    required String cancelLabel,
    required String deleteLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        content: content,
        cancelLabel: cancelLabel,
        deleteLabel: deleteLabel,
      ),
    );
    return result ?? false;
  }
}
