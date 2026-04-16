import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart';

/// Reusable info action that shows explanatory text in popup/sheet style.
class InfoHelpButton extends StatelessWidget {
  /// Creates an info help button.
  const InfoHelpButton({
    required this.message,
    super.key,
    this.title,
  });

  /// Optional title for the popover/sheet.
  final String? title;

  /// Main explanatory text.
  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.eventInfoTitle,
      icon: const Icon(Icons.info_outline),
      onPressed: () => showSmallDialogScreen<void>(
        context: context,
        builder: (context) {
          final resolvedTitle = (title ?? '').trim().isEmpty
              ? l10n.eventInfoTitle
              : title!.trim();
          return _InfoHelpDialog(title: resolvedTitle, message: message);
        },
      ),
    );
  }
}

class _InfoHelpDialog extends StatelessWidget {
  const _InfoHelpDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AdaptiveFormShell(
      title: title,
      onClose: () => AppNavigator.pop(context),
      fullScreen: false,
      popupMaxWidth: 520,
      contentView: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: SingleChildScrollView(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
