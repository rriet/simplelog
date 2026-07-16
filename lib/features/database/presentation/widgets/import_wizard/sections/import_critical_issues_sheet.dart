import 'package:flutter/material.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/data/import/pipeline/import_critical_issue_models.dart';

/// Shared decision sheet for import critical issues.
class ImportCriticalIssuesDecisionSheet extends StatelessWidget {
  /// Creates the sheet.
  const ImportCriticalIssuesDecisionSheet({
    required this.title,
    required this.message,
    required this.issues,
    required this.primaryActionLabel,
    required this.cancelActionLabel,
    required this.howToProceedLabel,
    this.secondaryActionLabel,
    this.infoTitle,
    this.infoMessage,
    this.showInfoNextToProceedLabel = false,
    this.issueLabelBuilder,
    super.key,
  });

  /// Dialog title.
  final String title;

  /// Intro message.
  final String message;

  /// Critical issues to render.
  final List<ImportCriticalIssue> issues;

  /// Primary action label.
  final String primaryActionLabel;

  /// Optional secondary action label.
  final String? secondaryActionLabel;

  /// Cancel action label.
  final String cancelActionLabel;

  /// "How to proceed" label.
  final String howToProceedLabel;

  /// Optional info popup title.
  final String? infoTitle;

  /// Optional info popup message.
  final String? infoMessage;

  /// Whether info button is shown beside proceed label.
  final bool showInfoNextToProceedLabel;

  /// Optional custom formatter for issue labels.
  final String Function(ImportCriticalIssue issue)? issueLabelBuilder;

  /// Opens the sheet and resolves the selected decision.
  static Future<ImportCriticalIssueDecision> show(
    BuildContext context, {
    required String title,
    required String message,
    required List<ImportCriticalIssue> issues,
    required String primaryActionLabel,
    required String cancelActionLabel,
    required String howToProceedLabel,
    String? secondaryActionLabel,
    String? infoTitle,
    String? infoMessage,
    bool showInfoNextToProceedLabel = false,
    String Function(ImportCriticalIssue issue)? issueLabelBuilder,
  }) async {
    final screen = ImportCriticalIssuesDecisionSheet(
      title: title,
      message: message,
      issues: issues,
      primaryActionLabel: primaryActionLabel,
      secondaryActionLabel: secondaryActionLabel,
      cancelActionLabel: cancelActionLabel,
      howToProceedLabel: howToProceedLabel,
      infoTitle: infoTitle,
      infoMessage: infoMessage,
      showInfoNextToProceedLabel: showInfoNextToProceedLabel,
      issueLabelBuilder: issueLabelBuilder,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final future = isCompact
        ? AppNavigator.pushMaterial<ImportCriticalIssueDecision>(
            context,
            (_) => screen,
            rootNavigator: true,
          )
        : showDialog<ImportCriticalIssueDecision>(
            context: context,
            barrierDismissible: false,
            builder: (_) => screen,
          );
    final result = await future;
    return result ?? ImportCriticalIssueDecision.cancel;
  }

  @override
  Widget build(BuildContext context) {
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
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final issue = issues[index];
                    final issueLabel =
                        issueLabelBuilder?.call(issue) ??
                        _defaultIssueLabel(issue);
                    return Text(issueLabel);
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(howToProceedLabel)),
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
                      ImportCriticalIssueDecision.primary,
                    ),
                    child: Text(primaryActionLabel),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => AppNavigator.pop(
                          context,
                          ImportCriticalIssueDecision.secondary,
                        ),
                        child: Text(secondaryActionLabel!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => AppNavigator.pop(
                          context,
                          ImportCriticalIssueDecision.primary,
                        ),
                        child: Text(primaryActionLabel),
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
                    ImportCriticalIssueDecision.cancel,
                  ),
                  child: Text(cancelActionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AdaptiveFormShell(
      onClose: () =>
          AppNavigator.pop(context, ImportCriticalIssueDecision.cancel),
      title: title,
      contentView: body,
    );
  }

  String _defaultIssueLabel(ImportCriticalIssue issue) {
    if (issue.sourceLineNumber == null) {
      return issue.message;
    }
    return 'Line ${issue.sourceLineNumber}: ${issue.message}';
  }
}

/// Shared list sheet where each pending issue can be resolved one-by-one.
class ImportCriticalPendingItemsSheet<T> extends StatefulWidget {
  /// Creates the sheet.
  const ImportCriticalPendingItemsSheet({
    required this.title,
    required this.message,
    required this.pendingItems,
    required this.actionLabel,
    required this.continueActionLabel,
    required this.cancelActionLabel,
    required this.itemLabelBuilder,
    required this.onResolveItem,
    super.key,
  });

  /// Title shown in the shell.
  final String title;

  /// Intro text.
  final String message;

  /// Initial pending items.
  final List<T> pendingItems;

  /// Label for per-item action button.
  final String actionLabel;

  /// Continue button label.
  final String continueActionLabel;

  /// Cancel button label.
  final String cancelActionLabel;

  /// Builds the label for each pending item.
  final String Function(T item) itemLabelBuilder;

  /// Resolves one pending item.
  final Future<bool> Function(T item) onResolveItem;

  /// Opens the sheet and resolves to `true` if user continues.
  static Future<bool> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<T> pendingItems,
    required String actionLabel,
    required String continueActionLabel,
    required String cancelActionLabel,
    required String Function(T item) itemLabelBuilder,
    required Future<bool> Function(T item) onResolveItem,
  }) async {
    final screen = ImportCriticalPendingItemsSheet<T>(
      title: title,
      message: message,
      pendingItems: pendingItems,
      actionLabel: actionLabel,
      continueActionLabel: continueActionLabel,
      cancelActionLabel: cancelActionLabel,
      itemLabelBuilder: itemLabelBuilder,
      onResolveItem: onResolveItem,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final future = isCompact
        ? AppNavigator.pushMaterial<bool>(
            context,
            (_) => screen,
            rootNavigator: true,
          )
        : showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => screen,
          );
    return (await future) ?? false;
  }

  @override
  State<ImportCriticalPendingItemsSheet<T>> createState() =>
      _ImportCriticalPendingItemsSheetState<T>();
}

class _ImportCriticalPendingItemsSheetState<T>
    extends State<ImportCriticalPendingItemsSheet<T>> {
  late final List<T> _pendingItems;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _pendingItems = List<T>.from(widget.pendingItems);
  }

  Future<void> _resolveItem(T item) async {
    setState(() => _busy = true);
    final resolved = await widget.onResolveItem(item);
    if (!mounted) {
      return;
    }
    if (mounted) {
      setState(() {
        _busy = false;
        if (resolved) {
          _pendingItems.remove(item);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _pendingItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final item = _pendingItems[index];
                    return Row(
                      children: [
                        Expanded(child: Text(widget.itemLabelBuilder(item))),
                        FilledButton(
                          onPressed: _busy ? null : () => _resolveItem(item),
                          child: Text(widget.actionLabel),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return AdaptiveFormShell(
      onClose: _busy ? () {} : () => AppNavigator.pop(context, false),
      title: widget.title,
      actions: [
        TextButton(
          onPressed: _busy ? null : () => AppNavigator.pop(context, false),
          child: Text(widget.cancelActionLabel),
        ),
        FilledButton(
          onPressed: _busy || _pendingItems.isNotEmpty
              ? null
              : () => AppNavigator.pop(context, true),
          child: Text(widget.continueActionLabel),
        ),
      ],
      contentView: body,
    );
  }
}
