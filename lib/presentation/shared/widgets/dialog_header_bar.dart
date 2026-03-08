import 'package:flutter/material.dart';

/// Standard dialog header with a top-left dismiss button and optional actions.
class DialogHeaderBar extends StatelessWidget {
  /// Creates a standardized dialog header row.
  const DialogHeaderBar({
    required this.title,
    required this.onClose,
    super.key,
    this.actions = const <Widget>[],
    this.forceCloseIcon = false,
  });

  /// Header title text.
  final String title;

  /// Called when the left dismiss button is pressed.
  final VoidCallback onClose;

  /// Optional widgets shown on the right side.
  final List<Widget> actions;

  /// Forces the close (`X`) icon even on compact screens.
  final bool forceCloseIcon;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final useCloseIcon = forceCloseIcon || !isCompact;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(useCloseIcon ? Icons.close : Icons.arrow_back_ios),
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
