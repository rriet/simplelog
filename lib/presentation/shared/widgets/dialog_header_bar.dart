import 'package:flutter/material.dart';

/// Standard dialog header with a top-left dismiss button and optional actions.
class DialogHeaderBar extends StatelessWidget {
  /// Creates a standardized dialog header row.
  const DialogHeaderBar({
    required this.title,
    required this.onClose,
    super.key,
    this.actions = const <Widget>[],
  });

  /// Header title text.
  final String title;

  /// Called when the left dismiss button is pressed.
  final VoidCallback onClose;

  /// Optional widgets shown on the right side.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isCompact ? Icons.arrow_back_ios : Icons.close),
            onPressed: onClose,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
