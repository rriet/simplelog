import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';
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
  late bool _recalcBlock;
  late bool _recalcNight;
  late bool _recalcIfr;
  late bool _recalcCrossCountry;
  late bool _recalcInstrument;
  late bool _overrideExisting;
  late bool _addCopilotStaff;
  late bool _addFlightNumber;
  late final TextEditingController _crossCountryController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _defaultSelfPosition = initial.defaultSelfPosition;
    _recalcBlock = initial.recalculateBlockTime;
    _recalcNight = initial.recalculateNightTime;
    _recalcIfr = initial.recalculateIfrTime;
    _recalcCrossCountry = initial.recalculateCrossCountry;
    _recalcInstrument = initial.recalculateInstrumentTime;
    _overrideExisting = initial.overrideExistingData;
    _addCopilotStaff = initial.addCopilotStaffNumberToNotes;
    _addFlightNumber = initial.addFlightNumberToNotes;
    _crossCountryController = TextEditingController(
      text: initial.crossCountryThresholdNm.toString(),
    );
  }

  @override
  void dispose() {
    _crossCountryController.dispose();
    super.dispose();
  }

  void _submit() {
    AppNavigator.pop(
      context,
      SouthwestImportOptions(
        defaultSelfPosition: _defaultSelfPosition,
        recalculateBlockTime: _recalcBlock,
        recalculateNightTime: _recalcNight,
        recalculateIfrTime: _recalcIfr,
        recalculateCrossCountry: _recalcCrossCountry,
        crossCountryThresholdNm:
            int.tryParse(
              _crossCountryController.text.trim(),
            ) ??
            50,
        recalculateInstrumentTime: _recalcInstrument,
        overrideExistingData: _overrideExisting,
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
          Text(l10n.databaseFileLabel(widget.fileName)),
          const SizedBox(height: 12),
          DropdownButtonFormField<CrewPosition>(
            initialValue: _defaultSelfPosition,
            decoration: InputDecoration(
              labelText: l10n.southwestDefaultSelfPositionLabel,
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
                setState(() => _defaultSelfPosition = value);
              }
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestRecalculateBlockTimeLabel),
            value: _recalcBlock,
            onChanged: (value) => setState(() => _recalcBlock = value ?? true),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestCalculateNightTimeLabel),
            value: _recalcNight,
            onChanged: (value) => setState(() => _recalcNight = value ?? true),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestCalculateIfrTimeLabel),
            value: _recalcIfr,
            onChanged: (value) => setState(() => _recalcIfr = value ?? true),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestCalculateCrossCountryTimeLabel),
            value: _recalcCrossCountry,
            onChanged: (value) =>
                setState(() => _recalcCrossCountry = value ?? true),
          ),
          NumberInputField(
            controller: _crossCountryController,
            label: l10n.southwestCrossCountryThresholdLabel,
            enabled: _recalcCrossCountry,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestCalculateInstrumentTimeLabel),
            value: _recalcInstrument,
            onChanged: (value) =>
                setState(() => _recalcInstrument = value ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestOverrideExistingDataLabel),
            value: _overrideExisting,
            onChanged: (value) =>
                setState(() => _overrideExisting = value ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestAddCopilotStaffNumberLabel),
            value: _addCopilotStaff,
            onChanged: (value) =>
                setState(() => _addCopilotStaff = value ?? true),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.southwestAddFlightNumberToNotesLabel),
            value: _addFlightNumber,
            onChanged: (value) =>
                setState(() => _addFlightNumber = value ?? true),
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
