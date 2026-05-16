import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/core/presentation/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';

/// Dialog to configure Southwest CSV import rules before processing.
///
/// Input: [fileName] and [initial] options.
/// Output: selected [SouthwestImportOptions] if user presses Import.
class SouthwestImportOptionsDialog extends StatefulWidget {
  /// Creates the dialog widget.
  const SouthwestImportOptionsDialog({
    required this.fileName,
    required this.initial,
    super.key,
  });

  /// Display name of the file being imported.
  final String fileName;

  /// Initial values used to populate all controls.
  final SouthwestImportOptions initial;

  /// Opens the dialog and returns chosen import options, or `null` if canceled.
  static Future<SouthwestImportOptions?> show(
    BuildContext context, {
    required String fileName,
    required SouthwestImportOptions initial,
  }) {
    final screen = SouthwestImportOptionsDialog(
      fileName: fileName,
      initial: initial,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<SouthwestImportOptions>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<SouthwestImportOptions>(
      context: context,
      builder: (_) => screen,
    );
  }

  @override
  State<SouthwestImportOptionsDialog> createState() =>
      _SouthwestImportOptionsDialogState();
}

class _SouthwestImportOptionsDialogState
    extends State<SouthwestImportOptionsDialog> {
  late CrewPosition _defaultSelfPosition;
  late bool _addCopilotStaff;
  late bool _addFlightNumber;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _defaultSelfPosition = initial.defaultSelfPosition;
    _addCopilotStaff = initial.addCopilotStaffNumberToNotes;
    _addFlightNumber = initial.addFlightNumberToNotes;
  }

  void _submit() {
    AppNavigator.pop(
      context,
      SouthwestImportOptions(
        defaultSelfPosition: _defaultSelfPosition,
        recalculateBlockTime: widget.initial.recalculateBlockTime,
        recalculateNightTime: widget.initial.recalculateNightTime,
        recalculateIfrTime: widget.initial.recalculateIfrTime,
        ifrPercent: widget.initial.ifrPercent,
        ifrSubtractMinutes: widget.initial.ifrSubtractMinutes,
        ifrMinimumMinutes: widget.initial.ifrMinimumMinutes,
        recalculateCrossCountry: widget.initial.recalculateCrossCountry,
        crossCountryThresholdNm: widget.initial.crossCountryThresholdNm,
        overrideExistingData: widget.initial.overrideExistingData,
        addCopilotStaffNumberToNotes: _addCopilotStaff,
        addFlightNumberToNotes: _addFlightNumber,
      ),
    );
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
                title: l10n.southwestImportOptionsHelpTitle,
                message: l10n.southwestImportOptionsHelpBody,
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownInputField<CrewPosition>(
            label: l10n.southwestDefaultSelfPositionLabel,
            value: _defaultSelfPosition,
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
                setState(() => _defaultSelfPosition = value);
              }
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestAddCopilotStaffNumberLabel),
            value: _addCopilotStaff,
            onChanged: (value) => setState(() => _addCopilotStaff = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestAddFlightNumberToNotesLabel),
            value: _addFlightNumber,
            onChanged: (value) => setState(() => _addFlightNumber = value),
          ),
        ],
      ),
    );
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.southwestImportOptionsTitle,
      actions: [
        TextButton(onPressed: _submit, child: Text(l10n.southwestImportAction)),
      ],
      contentView: body,
    );
  }
}
