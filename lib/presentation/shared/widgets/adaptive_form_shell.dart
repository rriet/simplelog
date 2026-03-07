import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/dialog_adaptive_presenter.dart';
import 'package:simplelog/presentation/shared/widgets/dialog_header_bar.dart';

/// Shared shell for forms that must adapt between full-screen route and dialog.
class AdaptiveFormShell extends StatelessWidget {
  /// Creates an adaptive form shell.
  const AdaptiveFormShell({
    required this.onClose,
    required this.longTitle,
    required this.shortTitle,
    required this.contentView,
    super.key,
    this.actions = const <Widget>[],
  });

  /// Called when user closes the screen.
  final VoidCallback onClose;

  /// Title used on wide layouts.
  final String longTitle;

  /// Title used on compact layouts.
  final String shortTitle;

  /// Action widgets shown on the top-right.
  final List<Widget> actions;

  /// Main content widget.
  final Widget contentView;

  @override
  Widget build(BuildContext context) {
    final isCompact = isCompactDialogScreen(context);
    final title = isCompact ? shortTitle : longTitle;
    final isInDialog = context.findAncestorWidgetOfExactType<Dialog>() != null;

    if (isInDialog) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeaderBar(
              title: title,
              onClose: onClose,
              actions: actions,
            ),
            const Divider(height: 1),
            Flexible(child: contentView),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onClose),
        title: Text(title),
        actions: actions,
      ),
      body: contentView,
    );
  }
}
