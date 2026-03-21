import 'package:flutter/material.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart';

/// Shared shell for forms that must adapt between full-screen route and dialog.
class AdaptiveFormShell extends StatelessWidget {
  /// Creates an adaptive form shell.
  const AdaptiveFormShell({
    required this.onClose,
    required this.title,
    required this.contentView,
    super.key,
    this.actions = const <Widget>[],
    this.fullScreen = true,
    this.popupMaxWidth = 460,
    this.leading,
  });

  /// Called when user closes the screen.
  final VoidCallback onClose;

  /// Single title used for both compact and wide layouts.
  final String title;

  /// Action widgets shown on the top-right.
  final List<Widget> actions;

  /// Optional leading widget override.
  ///
  /// When `null`, the shell uses the default close/back control.
  /// Provide a custom widget to replace it, or `SizedBox.shrink()` to remove.
  final Widget? leading;

  /// Whether compact screens should use a full-screen page presentation.
  ///
  /// When `false`, compact screens render a centered popup-style card instead
  /// of taking over the full screen.
  final bool fullScreen;

  /// Main content widget.
  final Widget contentView;

  /// Max width used by popup mode (non-fullscreen).
  final double popupMaxWidth;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = isCompactDialogScreen(context);
    final isDialogRoute = ModalRoute.of(context) is DialogRoute<dynamic>;
    final resolvedTitle = title;
    final useDialogStyle = !isCompact || !fullScreen || isDialogRoute;

    if (useDialogStyle) {
      final maxWidth = isCompact ? screenSize.width - 24 : popupMaxWidth;
      final leadingWidget =
          leading ??
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          );
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: screenSize.height * 0.82,
            ),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 12,
              shadowColor: Colors.black.withValues(alpha: 0.24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      children: [
                        leadingWidget,
                        Expanded(
                          child: Text(
                            resolvedTitle,
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
            ),
          ),
        ),
      );
    }

    final leadingWidget = leading ?? BackButton(onPressed: onClose);
    return Scaffold(
      appBar: AppBar(
        leading: leadingWidget,
        title: Text(resolvedTitle),
        actions: actions,
      ),
      body: contentView,
    );
  }
}
