import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/core/presentation/widgets/inputs/text_input_field.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/qatar_airways_workbook_inspector.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/import_wizard_section_card.dart';

/// Configuration dialog shown before importing a Qatar Airways workbook.
class QatarAirwaysImportOptionsDialog extends StatefulWidget {
  /// Creates the dialog.
  const QatarAirwaysImportOptionsDialog({
    required this.fileName,
    required this.inspection,
    required this.initial,
    super.key,
  });

  /// Picked workbook file name.
  final String fileName;

  /// Extracted worksheet metadata.
  final QatarAirwaysWorkbookInspection inspection;

  /// Initial values used to populate the controls.
  final QatarAirwaysImportOptions initial;

  /// Opens the dialog and returns selected options.
  static Future<QatarAirwaysImportOptions?> show(
    BuildContext context, {
    required String fileName,
    required QatarAirwaysWorkbookInspection inspection,
    required QatarAirwaysImportOptions initial,
  }) {
    final screen = QatarAirwaysImportOptionsDialog(
      fileName: fileName,
      inspection: inspection,
      initial: initial,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<QatarAirwaysImportOptions>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<QatarAirwaysImportOptions>(
      context: context,
      builder: (_) => screen,
    );
  }

  @override
  State<QatarAirwaysImportOptionsDialog> createState() =>
      _QatarAirwaysImportOptionsDialogState();
}

class _QatarAirwaysImportOptionsDialogState
    extends State<QatarAirwaysImportOptionsDialog> {
  late CrewPosition _defaultPosition;
  late final TextEditingController _myNameController;

  @override
  void initState() {
    super.initState();
    _defaultPosition = widget.initial.defaultPosition;
    _myNameController = TextEditingController(text: widget.initial.myName);
  }

  @override
  void dispose() {
    _myNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final myName = _myNameController.text.trim();
    if (_defaultPosition == CrewPosition.pic && myName.isEmpty) {
      return;
    }
    AppNavigator.pop(
      context,
      QatarAirwaysImportOptions(
        defaultPosition: _defaultPosition,
        myName: myName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showMyName = _defaultPosition == CrewPosition.pic;
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.databaseFileLabel(widget.fileName))),
              InfoHelpButton(
                title: l10n.qatarImportOptionsHelpTitle,
                message: l10n.qatarImportOptionsHelpBody,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ImportWizardSectionCard(
            title: l10n.qatarDefaultPositionLabel,
            initiallyExpanded: true,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              DropdownButtonFormField<CrewPosition>(
                initialValue: _defaultPosition,
                decoration: InputDecoration(
                  labelText: l10n.qatarDefaultPositionLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: CrewPosition.pic,
                    child: Text(l10n.qatarPositionPic),
                  ),
                  DropdownMenuItem(
                    value: CrewPosition.sic,
                    child: Text(l10n.qatarPositionSic),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _defaultPosition = value);
                  }
                },
              ),
              if (showMyName) ...[
                const SizedBox(height: 12),
                TextInputField(
                  controller: _myNameController,
                  label: l10n.qatarPilotNameAsWrittenLabel,
                ),
              ],
            ],
          ),
        ],
      ),
    );
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.qatarImportTitle,
      actions: [
        TextButton(onPressed: _submit, child: Text(l10n.qatarImportAction)),
      ],
      contentView: body,
    );
  }
}
