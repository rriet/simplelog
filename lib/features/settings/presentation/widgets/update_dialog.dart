import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/data/services/update_service.dart';

/// Shows an update dialog when a newer release is available.
///
/// The dialog is non-blocking (dismissible by tapping outside).
/// Actions:
/// - **Download** – calls [onDownload].
/// - **Skip this version** – calls [onSkip] and dismisses.
/// - **Later** – just dismisses without setting skipped.
Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateResult update,
  required VoidCallback onSkip,
  required VoidCallback onDownload,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _UpdateDialogBody(
      update: update,
      l10n: l10n,
      theme: theme,
      onSkip: onSkip,
      onDownload: onDownload,
    ),
  );
}

class _UpdateDialogBody extends StatefulWidget {
  const _UpdateDialogBody({
    required this.update,
    required this.l10n,
    required this.theme,
    required this.onSkip,
    required this.onDownload,
  });

  final UpdateResult update;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onSkip;
  final VoidCallback onDownload;

  @override
  State<_UpdateDialogBody> createState() => _UpdateDialogBodyState();
}

class _UpdateDialogBodyState extends State<_UpdateDialogBody> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final update = widget.update;
    final l10n = widget.l10n;
    final theme = widget.theme;
    final notes = update.releaseNotes;

    const maxLines = 8;

    return AlertDialog(
      icon: Icon(
        Icons.system_update_rounded,
        color: theme.colorScheme.primary,
        size: 40,
      ),
      title: Text(l10n.updateDialogTitle(update.latestVersion)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notes != null && notes.isNotEmpty) ...[
            Text(
              l10n.updateDialogReleaseNotes,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              notes,
              maxLines: _expanded ? null : maxLines,
              overflow:
                  _expanded ? null : TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? l10n.updateDialogShowLess
                    : l10n.updateDialogShowMore,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(context),
          child: Text(l10n.updateDialogLaterAction),
        ),
        TextButton(
          onPressed: () {
            widget.onSkip();
            AppNavigator.pop(context);
          },
          child: Text(l10n.updateDialogSkipAction),
        ),
        FilledButton(
          onPressed: () {
            widget.onDownload();
            AppNavigator.pop(context);
          },
          child: Text(l10n.updateDialogDownloadAction),
        ),
      ],
    );
  }
}
