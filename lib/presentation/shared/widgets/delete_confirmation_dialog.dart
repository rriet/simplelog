import 'package:flutter/material.dart';

/// Simple reusable dialog asking the user to confirm a delete action.
class DeleteConfirmationDialog extends StatelessWidget {
  /// Builds a confirmation dialog with [title], [content] and button labels.
  const DeleteConfirmationDialog({
    required this.title,
    required this.content,
    required this.cancelLabel,
    required this.deleteLabel,
    super.key,
  });

  /// Title text displayed at the top of the dialog.
  final String title;

  /// Body content explaining what will be deleted.
  final String content;

  /// Label for the cancel button.
  final String cancelLabel;

  /// Label for the delete/confirm button.
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
          child: Text(deleteLabel),
        ),
      ],
    );
  }

  /// Shows the dialog and resolves to `true` when the user confirms deletion.
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
