import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
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
      onPressed: () => showLargeDialogScreen<void>(
        context: context,
        maxWidth: 520,
        maxHeightFactor: 0.6,
        builder: (context) {
          final resolvedTitle = (title ?? '').trim().isEmpty
              ? l10n.eventInfoTitle
              : title!.trim();
          return _InfoHelpSheet(title: resolvedTitle, message: message);
        },
      ),
    );
  }
}

class _InfoHelpSheet extends StatelessWidget {
  const _InfoHelpSheet({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(message),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.okAction),
            ),
          ),
        ],
      ),
    );
  }
}
