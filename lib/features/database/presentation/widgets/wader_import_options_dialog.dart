import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/data/import/wader_import_options.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/sections/import_recalculation_section.dart';

/// Dialog to configure Wader CSV import behavior.
class WaderImportOptionsDialog extends StatefulWidget {
  /// Creates the import options dialog.
  const WaderImportOptionsDialog({
    required this.fileName,
    super.key,
    this.initial = const WaderImportOptions(),
  });

  /// Display name of the selected source file.
  final String fileName;

  /// Initial options loaded from persisted preferences.
  final WaderImportOptions initial;

  /// Opens the dialog and resolves selected options.
  static Future<WaderImportOptions?> show(
    BuildContext context, {
    required String fileName,
    WaderImportOptions initial = const WaderImportOptions(),
  }) {
    final screen = WaderImportOptionsDialog(
      fileName: fileName,
      initial: initial,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<WaderImportOptions>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<WaderImportOptions>(
      context: context,
      builder: (_) => screen,
    );
  }

  @override
  State<WaderImportOptionsDialog> createState() =>
      _WaderImportOptionsDialogState();
}

class _WaderImportOptionsDialogState extends State<WaderImportOptionsDialog> {
  late bool _recalculateTotalTime;
  bool _showRecalculations = true;

  @override
  void initState() {
    super.initState();
    _recalculateTotalTime = widget.initial.recalculateTotalTime;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.databaseFileLabel(widget.fileName))),
              InfoHelpButton(
                title: l10n.waderImportOptionsHelpTitle,
                message: l10n.waderImportOptionsHelpBody,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ImportRecalculationSection(
            labels: ImportRecalculationSectionLabels(
              title: l10n.waderImportRecalculationsTitle,
              recalculateTotal: l10n.waderRecalculateTotalTimeLabel,
            ),
            initiallyExpanded: _showRecalculations,
            onExpansionChanged: (expanded) =>
                setState(() => _showRecalculations = expanded),
            recalcTotalValue: _recalculateTotalTime,
            onRecalcTotalChanged: (value) =>
                setState(() => _recalculateTotalTime = value),
          ),
        ],
      ),
    );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.waderImportOptionsTitle,
      popupMaxWidth: 560,
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(
            context,
            WaderImportOptions(recalculateTotalTime: _recalculateTotalTime),
          ),
          child: Text(l10n.waderImportAction),
        ),
      ],
      contentView: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: body,
      ),
    );
  }
}
