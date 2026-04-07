import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';

/// User decision for a Southwest preflight dialog.
enum SouthwestPreflightDialogDecision {
  /// Continue import with the primary action.
  primary,

  /// Continue import with the secondary action.
  secondary,

  /// Cancel the import.
  cancel,
}

/// Decision dialog used by Southwest import preflight checks.
class SouthwestImportPreflightDialog extends StatelessWidget {
  /// Creates a preflight decision dialog.
  const SouthwestImportPreflightDialog({
    required this.title,
    required this.message,
    required this.issues,
    required this.primaryActionLabel,
    this.secondaryActionLabel,
    this.infoTitle,
    this.infoMessage,
    this.showInfoNextToProceedLabel = false,
    super.key,
  });

  /// Dialog title.
  final String title;

  /// Intro message shown before issue list.
  final String message;

  /// Per-line issues to display.
  final List<String> issues;

  /// Primary action label.
  final String primaryActionLabel;

  /// Secondary action label.
  final String? secondaryActionLabel;

  /// Optional title shown in the info popup.
  final String? infoTitle;

  /// Optional message shown in the info popup.
  final String? infoMessage;

  /// Whether info button should be rendered next to "How to proceed" label.
  final bool showInfoNextToProceedLabel;

  /// Opens the dialog and returns the selected decision.
  static Future<SouthwestPreflightDialogDecision> show(
    BuildContext context, {
    required String title,
    required String message,
    required List<String> issues,
    required String primaryActionLabel,
    String? secondaryActionLabel,
    String? infoTitle,
    String? infoMessage,
    bool showInfoNextToProceedLabel = false,
  }) {
    final screen = SouthwestImportPreflightDialog(
      title: title,
      message: message,
      issues: issues,
      primaryActionLabel: primaryActionLabel,
      secondaryActionLabel: secondaryActionLabel,
      infoTitle: infoTitle,
      infoMessage: infoMessage,
      showInfoNextToProceedLabel: showInfoNextToProceedLabel,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final future = isCompact
        ? AppNavigator.pushMaterial<SouthwestPreflightDialogDecision>(
            context,
            (_) => screen,
            rootNavigator: true,
          )
        : showDialog<SouthwestPreflightDialogDecision>(
            context: context,
            barrierDismissible: false,
            builder: (_) => screen,
          );
    return future.then(
      (value) => value ?? SouthwestPreflightDialogDecision.cancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(message)),
                  if (!showInfoNextToProceedLabel &&
                      (infoMessage ?? '').trim().isNotEmpty)
                    InfoHelpButton(
                      title: infoTitle,
                      message: infoMessage!,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: issues.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) => Text(issues[index]),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.southwestPreflightHowProceedLabel),
                  ),
                  if (showInfoNextToProceedLabel &&
                      (infoMessage ?? '').trim().isNotEmpty)
                    InfoHelpButton(
                      title: infoTitle,
                      message: infoMessage!,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (secondaryActionLabel == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => AppNavigator.pop(
                      context,
                      SouthwestPreflightDialogDecision.primary,
                    ),
                    child: Text(
                      primaryActionLabel,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => AppNavigator.pop(
                          context,
                          SouthwestPreflightDialogDecision.secondary,
                        ),
                        child: Text(
                          secondaryActionLabel!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => AppNavigator.pop(
                          context,
                          SouthwestPreflightDialogDecision.primary,
                        ),
                        child: Text(
                          primaryActionLabel,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => AppNavigator.pop(
                    context,
                    SouthwestPreflightDialogDecision.cancel,
                  ),
                  child: Text(l10n.cancelAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(
        context,
        SouthwestPreflightDialogDecision.cancel,
      ),
      title: title,
      contentView: body,
    );
  }
}
