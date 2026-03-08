import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/dialog_adaptive_presenter.dart';

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
    this.fullScreen = true,
  });

  /// Called when user closes the screen.
  final VoidCallback onClose;

  /// Title used on wide layouts.
  final String longTitle;

  /// Title used on compact layouts.
  final String shortTitle;

  /// Action widgets shown on the top-right.
  final List<Widget> actions;

  /// Whether compact screens should use a full-screen page presentation.
  ///
  /// When `false`, compact screens render a centered popup-style card instead
  /// of taking over the full screen.
  final bool fullScreen;

  /// Main content widget.
  final Widget contentView;

  @override
  Widget build(BuildContext context) {
    final isCompact = isCompactDialogScreen(context);
    final title = isCompact ? shortTitle : longTitle;
    final isInDialog = context.findAncestorWidgetOfExactType<Dialog>() != null;
    final useDialogStyle = isInDialog || (isCompact && !fullScreen);

    if (useDialogStyle) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
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
