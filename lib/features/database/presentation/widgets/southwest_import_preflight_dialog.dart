import 'package:flutter/widgets.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/import/pipeline/import_critical_issue_models.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/sections/import_critical_issues_sheet.dart';

/// User decision for a Southwest preflight dialog.
enum SouthwestPreflightDialogDecision {
  /// Continue import with the primary action.
  primary,

  /// Continue import with the secondary action.
  secondary,

  /// Cancel the import.
  cancel,
}

/// Decision dialog facade used by Southwest import preflight checks.
class SouthwestImportPreflightDialog {
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
  }) async {
    final decision = await ImportCriticalIssuesDecisionSheet.show(
      context,
      title: title,
      message: message,
      issues: issues
          .map(
            (issueText) => ImportCriticalIssue(
              kind: ImportCriticalIssueKind.missingRequiredField,
              message: issueText,
            ),
          )
          .toList(growable: false),
      issueLabelBuilder: (issue) => issue.message,
      primaryActionLabel: primaryActionLabel,
      secondaryActionLabel: secondaryActionLabel,
      cancelActionLabel: AppLocalizations.of(context)!.cancelAction,
      howToProceedLabel: AppLocalizations.of(
        context,
      )!.southwestPreflightHowProceedLabel,
      infoTitle: infoTitle,
      infoMessage: infoMessage,
      showInfoNextToProceedLabel: showInfoNextToProceedLabel,
    );
    return switch (decision) {
      ImportCriticalIssueDecision.primary =>
        SouthwestPreflightDialogDecision.primary,
      ImportCriticalIssueDecision.secondary =>
        SouthwestPreflightDialogDecision.secondary,
      ImportCriticalIssueDecision.cancel =>
        SouthwestPreflightDialogDecision.cancel,
    };
  }
}
